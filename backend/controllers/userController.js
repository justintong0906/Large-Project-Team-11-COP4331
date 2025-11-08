import User from "../models/User.js";
import mongoose from "mongoose";

export const getUserProfile = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({ message: "Invalid user id" });
    }

    // find user but exclude sensitive info
    const user = await User.findById(id)
      .select("-password -emailVerifyTokenHash -emailVerifyTokenExpiresAt");

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
    const me = await User.findById(meId).select("questionnaireBitmask").lean();
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
    const [user] = await User.aggregate([
      {
        $match: {
          _id: { $ne: new mongoose.Types.ObjectId(meId) },
          $and: [
            { questionnaireBitmask: { $bitsAnySet: myA } }, // share a bit in 0–6
            { questionnaireBitmask: { $bitsAnySet: myB } }, // share a bit in 7–9
            { questionnaireBitmask: { $bitsAnySet: myC } }, // share a bit in 10–12
          ],
        },
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
    // Expect auth middleware to set req.userId (preferred).
    // Fallback to :id param if you want to support admin updates.
    const userId = req.userId ?? req.params.id;

    if (!userId || !mongoose.isValidObjectId(userId)) {
      return res.status(401).json({ message: "Unauthorized or invalid user id." });
    }

    const { days, times, splits } = req.body ?? {};

    // Validate payload shapes (arrays or undefined)
    const isArrOrUndef = (v) => v === undefined || Array.isArray(v);
    if (!isArrOrUndef(days) || !isArrOrUndef(times) || !isArrOrUndef(splits)) {
      return res.status(400).json({ message: "days/times/splits must be arrays." });
    }

    // Optional: strict allow-list validation with clear errors
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

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: { questionnaireBitmask } },
      { new: true, projection: { password: 0, emailVerifyTokenHash: 0, emailVerifyTokenExpiresAt: 0 } }
    ).lean();

    if (!user) return res.status(404).json({ message: "User not found." });

    return res.json({
      message: "Quiz results saved.",
      questionnaireBitmask,
      // Echo normalized selections back (handy for UI confirmation)
      normalized: {
        days: (days ?? []).map(s => String(s).toLowerCase()),
        times: (times ?? []).map(s => String(s).toLowerCase()),
        splits: (splits ?? []).map(s => String(s).toLowerCase()),
      },
      user
    });
  } catch (err) {
    console.error("[saveQuizResults] error:", err);
    return res.status(500).json({ message: "Failed to save quiz results." });
  }
};


