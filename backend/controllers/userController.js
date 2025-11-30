import User from "../models/User.js";
import mongoose from "mongoose";

export const getUserProfile = async (req, res) => {
  try {
    /**
     * If hitting /me → req.params.id is undefined.
     * So default to req.userId (set by requireAuth).
     */
    const id = req.params.id ?? req.userId;

    if (!id || !mongoose.isValidObjectId(id)) {
      return res.status(400).json({ message: "Invalid or missing user id" });
    }

    const user = await User.findById(id)
      .select("-password -emailVerifyTokenHash -emailVerifyTokenExpiresAt")
      .populate("friends", "_id username profile"); // added to convert friendIds to objects of their profiles

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.json(user);
  } catch (err) {
    console.error("[getUserProfile] error:", err);
    return res.status(500).json({ message: "Failed to fetch profile" });
  }
};


export const getRandomUser = async (req, res) => {
  try {
  
    const [user] = await User.aggregate([
      { $sample: { size: 1 } }, // randomly picks one document
      {
        $project: {
          password: 0,
          emailVerifyTokenHash: 0,
          emailVerifyTokenExpiresAt: 0,
          email: 0,
        },
      },
    ]);

    if (!user) {
      return res.status(404).json({ message: "No users found" });
    }

    return res.json(user);
  } catch (err) {
    console.error("[getRandomUser] error:", err);
    return res.status(500).json({ message: "Failed to fetch random user" });
  }
};


export const getRandomCompatibleUser = async (req, res) => {
  try {
    const meId = req.userId; // set by auth middleware

    if (!meId || !mongoose.isValidObjectId(meId)) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    // Load only what we need
    const me = await User.findById(meId).select("questionnaireBitmask profile.gender profile.genderPreferences").lean();
    if (!me) return res.status(404).json({ message: "Current user not found" });

    const myMask = me.questionnaireBitmask ?? 0;

    // Bit groups:
    // - Group A: bits 0..6  (7 bits)      maskA = 0x7F
    // - Group B: bits 7..9  (3 bits)      maskB = 0x380
    // - Group C: bits 10..12 (3 bits)     maskC = 0x1C00
    const MASK_A = 0x7F;     // 0b0000000001111111
    const MASK_B = 0x380;    // 0b0000001110000000
    const MASK_C = 0x1C00;   // 0b0001110000000000

    const myA = myMask & MASK_A;
    const myB = myMask & MASK_B;
    const myC = myMask & MASK_C;

    // If the caller has no bits set in a group, nobody can "share" that group with them.
    if (!myA || !myB || !myC) {
      return res.status(400).json({
        message:
          "Your questionnaireBitmask has no selections in one or more required groups (0–6, 7–9, 10–12).",
      });
    }

    // Build a pipeline that:
    // 1) excludes the current user
    // 2) requires sharing at least one bit with the caller in each group
    // 3) samples a random compatible user

    //match filter: default is just bitmask
    const matchingFilter = {
      _id: { $ne: new mongoose.Types.ObjectId(meId) },
      $and: [
        { questionnaireBitmask: { $bitsAnySet: myA } },
        { questionnaireBitmask: { $bitsAnySet: myB } },
        { questionnaireBitmask: { $bitsAnySet: myC } },
      ],
    };

    // If user wants "single_gender", also filter by their gender
    if (me.profile?.genderPreferences === "single_gender") {
        matchingFilter["profile.gender"] = me.profile?.gender; 
    }

    const [user] = await User.aggregate([
      {
        $match: matchingFilter,
      },
      { $sample: { size: 1 } },
      {
        $project: {
          password: 0,
          emailVerifyTokenHash: 0,
          emailVerifyTokenExpiresAt: 0,
          email: 0,
        },
      },
    ]);

    if (!user) {
      return res.status(404).json({ message: "No compatible users found" });
    }

    return res.json(user);
  } catch (err) {
    console.error("[getRandomCompatibleUser] error:", err);
    return res.status(500).json({ message: "Failed to fetch random compatible user" });
  }
};


// Maps defining bit positions
const DAY_BITS = { sun: 0, mon: 1, tue: 2, wed: 3, thu: 4, fri: 5, sat: 6 };
const TIME_BITS = { morning: 7, afternoon: 8, evening: 9 };
const SPLIT_BITS = { arnold: 10, ppl: 11, brosplit: 12 };

function toBitmask({ days = [], times = [], splits = [] }) {
  let mask = 0;

  const pushBits = (items, map) => {
    for (const raw of items) {
      if (!raw) continue;
      const key = String(raw).trim().toLowerCase();
      if (map[key] === undefined) continue;
      mask |= (1 << map[key]);
    }
  };

  pushBits(days, DAY_BITS);
  pushBits(times, TIME_BITS);
  pushBits(splits, SPLIT_BITS);
  return mask >>> 0; // ensure unsigned
}

export const saveQuizResults = async (req, res) => {
  try {
    // Prefer auth middleware to set userId; allow :id fallback (admin flows)
    const userId = req.userId ?? req.params.id;

    if (!userId || !mongoose.isValidObjectId(userId)) {
      return res.status(401).json({ message: "Unauthorized or invalid user id." });
    }

    // --- Part 1: bitmask from days/times/splits ---
    const { days, times, splits } = req.body ?? {};

    const isArrOrUndef = (v) => v === undefined || Array.isArray(v);
    if (!isArrOrUndef(days) || !isArrOrUndef(times) || !isArrOrUndef(splits)) {
      return res.status(400).json({ message: "days/times/splits must be arrays." });
    }

    const badDay = (days ?? []).find(d => !(String(d).toLowerCase() in DAY_BITS));
    const badTime = (times ?? []).find(t => !(String(t).toLowerCase() in TIME_BITS));
    const badSplit = (splits ?? []).find(s => !(String(s).toLowerCase() in SPLIT_BITS));
    if (badDay || badTime || badSplit) {
      return res.status(400).json({
        message: "Invalid value(s) in days/times/splits.",
        allowed: {
          days: Object.keys(DAY_BITS),
          times: Object.keys(TIME_BITS),
          splits: Object.keys(SPLIT_BITS),
        },
        invalid: { badDay, badTime, badSplit }
      });
    }

    const questionnaireBitmask = toBitmask({ days, times, splits });

    // --- Part 2: optional profile fields (saved alongside) ---
    const {
      // all optional
      name,
      age,
      gender, // "male" | "female" | "nonbinary" | "other" | "prefer_not_to_say"
      major,
      bio,
      photo,
      yearsOfExperience,
      genderPreferences, // "coed" | "single_gender" | "no_preference"
      phone,
    } = req.body?.profile ?? {};

    // Build $set only with provided/allowed fields
    const profileSet = {};
    const pushIfDefined = (key, value, test = (v) => v !== undefined) => {
      console.log("key:", key,"\nvalue:", value,"\ntest(value):", test(value));
      if (test(value)) 
        profileSet[`profile.${key}`] = value;
    };
    // Basic validations mirroring your schema constraints
    const inEnum = (v, arr) => v === undefined || arr.includes(String(v));
    const within = (v, min, max) => v === undefined || (typeof v === "number" && v >= min && v <= max);
    const strMax = (v, max) => v === undefined || (typeof v === "string" && v.trim().length <= max);

    // Validate
    if (!strMax(name, 120)) {
      return res.status(400).json({ message: "name too long (max 120)" });
    }

    if (!within(age, 0, 120)) return res.status(400).json({ message: "age must be 0..120" });
    if (!inEnum(gender, ["male", "female", "nonbinary", "other", "prefer_not_to_say"])) {
      return res.status(400).json({ message: "gender invalid" });
    }
    if (!strMax(major, 120)) return res.status(400).json({ message: "major too long (max 120)" });
    if (!strMax(bio, 2000)) return res.status(400).json({ message: "bio too long (max 2000)" });
    if (!within(yearsOfExperience, 0, 100)) {
      return res.status(400).json({ message: "yearsOfExperience must be 0..100" });
    }
    if (!inEnum(genderPreferences, ["coed", "single_gender", "no_preference"])) {
      return res.status(400).json({ message: "genderPreferences invalid" });
    }
    if (!strMax(phone, 30)) {
       res.status(400).json({ message: "phone too long (max 30)" });
    }

    // Pack allowed fields if present
    console.log(req.body);
    console.log(gender);

    pushIfDefined("name", typeof name === "string" ? name.trim() : name);
    pushIfDefined("age", age);
    pushIfDefined("gender", gender);
    pushIfDefined("major", typeof major === "string" ? major.trim() : major);
    pushIfDefined("bio", typeof bio === "string" ? bio.trim() : bio);
    pushIfDefined("photo", typeof photo === "string" ? photo.trim() : photo);
    pushIfDefined("yearsOfExperience", yearsOfExperience);
    pushIfDefined("genderPreferences", genderPreferences);
    pushIfDefined("phone", typeof phone === "string" ? phone.trim() : phone);

    // Final update document
    const updateDoc = {
      $set: {
        questionnaireBitmask,
        ...profileSet,
      },
    };

    const user = await User.findByIdAndUpdate(
      userId,
      updateDoc,
      {
        new: true,
        projection: { password: 0, emailVerifyTokenHash: 0, emailVerifyTokenExpiresAt: 0 }
      }
    ).lean();

    if (!user) return res.status(404).json({ message: "User not found." });

    return res.json({
      message: "Quiz results saved.",
      questionnaireBitmask,
      normalized: {
        days: (days ?? []).map(s => String(s).toLowerCase()),
        times: (times ?? []).map(s => String(s).toLowerCase()),
        splits: (splits ?? []).map(s => String(s).toLowerCase()),
      },
      updatedProfileFields: Object.keys(profileSet).map(k => k.replace(/^profile\./, "")),
      user,
    });
  } catch (err) {
    console.error("[saveQuizResults] error:", err);
    return res.status(500).json({ message: "Failed to save quiz results." });
  }
};

export const SendMatch = async (req, res) => {
  try {
    const callerId = req.userId;               // authenticated user
    const targetId = req.params.id;            // user being matched with

    if (!mongoose.isValidObjectId(targetId)) {
      return res.status(400).json({ message: "Invalid target user id" });
    }

    if (callerId === targetId) {
      return res.status(400).json({ message: "You cannot match with yourself." });
    }

    const caller = await User.findById(callerId)
      .select("pendingMatches friends");
    const target = await User.findById(targetId)
      .select("pendingMatches friends");

    if (!caller || !target) {
      return res.status(404).json({ message: "User not found." });
    }

    // ------------------------------------------
    // CASE 1: target already requested caller → MATCH!
    // ------------------------------------------
    const targetPending = target.pendingMatches.map(String);

    // console.log(targetPending);
    // console.log(callerId);
    // console.log(targetId);
    const StringCallerId = String(callerId);
    const StringTargetId = String(targetId);
    // console.log(callerId);
    // console.log(targetId);
    if (targetPending.includes(StringCallerId)) {
      // console.log("in if statement");

      // Add each other to `friends` sets (no duplicates)
      caller.friends.addToSet(targetId);
      target.friends.addToSet(callerId);

      // Remove target→caller pending request
      target.pendingMatches = target.pendingMatches.filter(
        (id) => id.toString() !== StringCallerId
      );

      // Remove caller->target pending request
      caller.pendingMatches = caller.pendingMatches.filter(
        (id) => id.toString() !== StringTargetId
      );

      await caller.save();
      await target.save();

      return res.json({
        message: "It's a match!",
        matchedWith: targetId
      });
    }

    // ------------------------------------------
    // CASE 2: caller already sent a request before
    // ------------------------------------------
    const callerPending = caller.pendingMatches.map(String);
    if (callerPending.includes(StringTargetId)) {
      return res.json({
        message: "Match request already sent.",
        pendingTo: targetId
      });
    }

    // ------------------------------------------
    // CASE 3: new pending request
    // ------------------------------------------
    caller.pendingMatches.push(targetId);
    await caller.save();

    return res.json({
      message: "Match request sent.",
      pendingTo: targetId
    });

  } catch (err) {
    console.error("[SendMatch] error:", err);
    return res.status(500).json({ message: "Failed to send match request." });
  }
};



