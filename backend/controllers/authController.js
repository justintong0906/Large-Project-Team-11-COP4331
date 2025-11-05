// controllers/auth.controller.js
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/User.js";
import crypto from "crypto";
import { sendVerificationEmail } from "../services/mailer.js";


const signToken = (user) =>
  jwt.sign(
    { id: user._id, email: user.email, username: user.username },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );

// POST /api/auth/signup
export const signup = async (req, res) => {
  try {
    const { username, email, password, confirmpassword} = req.body || {};

    // Basic validation
    if (!username || !email || !password) {
      return res
        .status(400)
        .json({ message: "Username, email, and password are required." });
    }
    if (password.length < 6) {
      return res
        .status(400)
        .json({ message: "Password must be at least 6 characters." });
    }
    
    if(password !== confirmpassword){
      return res
        .status(400)
        .json({ message: "Passwords do not match." });
    }
    console.log("email", email);
    if (!email.includes("@ucf.edu") && !email.includes("@mail.valenciacollege.edu")) {
      return res
        .status(400)
        .json({ message: "Invalid email. Must be @ucf or @mail.valenciacollege email." });
    }

    // Normalize input
    const normalizedEmail = String(email).toLowerCase().trim();
    const normalizedUsername = String(username).toLowerCase().trim();

    // Ensure uniqueness for email or username
    const existing = await User.findOne({
      $or: [{ email: normalizedEmail }, { username: normalizedUsername }],
    });
    if (existing) {
      const field =
        existing.email === normalizedEmail ? "email" : "username";
      return res.status(409).json({ message: `That ${field} is already in use.` });
    }


    const rawToken = crypto.randomBytes(32).toString("hex");
    const tokenHash = crypto.createHash("sha256").update(rawToken).digest("hex");
    const expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24); // 24h

    // Hash password and create user
    const hash = await bcrypt.hash(password, 10);
    const user = await User.create({
      username: normalizedUsername,
      email: normalizedEmail,
      password: hash,
      emailVerified: false,
      emailVerifyTokenHash: tokenHash,
      emailVerifyTokenExpiresAt: expiresAt,

    });

    await sendVerificationEmail({
      to: normalizedEmail, // not the raw 'email' from req
      uid: user._id.toString(),
      token: rawToken,
    });


    return res.status(201).json({ message: "Signup successful. Check your email to verify your account." });

  } catch (err) {
    if (err?.code === 11000) {
      const key = Object.keys(err.keyPattern || {})[0] || "field";
      return res.status(409).json({ message: `That ${key} is already in use.` });
    }
    console.error("[signup] error:", err);
    return res.status(500).json({ message: "Signup failed" });
  }
};

// POST /api/auth/login
// Body: { identifier: "<username OR email>", password: "..." }
export const login = async (req, res) => {
  try {
    const { identifier, password } = req.body || {};

    if (!identifier || !password) {
      return res
        .status(400)
        .json({ message: "Identifier and password are required." });
    }

    const idNorm = String(identifier).toLowerCase().trim();
    const looksLikeEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(idNorm);

    // Find by email OR username
    const user = await User.findOne(
      looksLikeEmail ? { email: idNorm } : { username: idNorm }
    );
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials." });
    }

    // Verify password
    const ok = await bcrypt.compare(password, user.password);
    if (!ok) {
      return res.status(401).json({ message: "Invalid credentials." });
    }

    if (!user.emailVerified) {
    return res.status(403).json({ message: "Please verify your email to continue." });
}

    // Issue JWT
    const token = signToken(user);
    return res.json({
      token,
      user: { id: user._id, email: user.email, username: user.username },
    });
  } catch (err) {
    console.error("[login] error:", err);
    return res.status(500).json({ message: "Login failed" });
  }
};

export const updatePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body || {};
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ message: "currentPassword and newPassword are required." });
    }
    if (newPassword.length < 6) {
      return res.status(400).json({ message: "New password must be at least 6 characters." });
    }

    // load user so we can compare/update password
    const user = await User.findById(req.user.id);
    if (!user) return res.status(401).json({ message: "User not found." });

    const ok = await bcrypt.compare(currentPassword, user.password);
    if (!ok) return res.status(401).json({ message: "Current password is incorrect." });

    const sameAsOld = await bcrypt.compare(newPassword, user.password);
    if (sameAsOld) {
      return res.status(400).json({ message: "New password must be different from current password." });
    }

    const hash = await bcrypt.hash(newPassword, 10);
    user.password = hash;
    await user.save();

    const token = signToken(user);
    return res.json({ message: "Password updated.", token });
  } catch (err) {
    console.error("[updatePassword] error:", err);
    return res.status(500).json({ message: "Failed to update password." });
  }
};

// GET /api/auth/verify-email?uid=...&token=...
// controllers/auth.controller.js
export const verifyEmail = async (req, res) => {
  try {
    const { uid, token } = req.query;
    if (!uid || !token) return res.status(400).json({ message: "Missing uid or token." });

    const tokenHash = crypto.createHash("sha256").update(token).digest("hex");

    const result = await User.updateOne(
      {
        _id: uid,
        emailVerifyTokenHash: tokenHash,
        emailVerifyTokenExpiresAt: { $gt: new Date() },
      },
      {
        $set: { emailVerified: true },
        $unset: { emailVerifyTokenHash: "", emailVerifyTokenExpiresAt: "" },
      }
    );

    if (result.modifiedCount === 0) {
      // Handle already-verified OR invalid/expired token separately if you want:
      const already = await User.findOne({ _id: uid, emailVerified: true });
      if (already) {
        return res.redirect(`${process.env.FRONTEND_URL}/verified?status=already`);

      }
      return res.status(400).json({ message: "Verification link is invalid or expired." });
    }

    return res.redirect(`${process.env.FRONTEND_URL}/verified?status=success`);
  } catch (e) {
    console.error("[verifyEmail] error:", e);
    return res.status(500).json({ message: "Verification failed." });
  }
};


// POST /api/auth/resend-verification { email }
export const resendVerification = async (req, res) => {
  try {
    const { email } = req.body || {};
    if (!email) return res.status(400).json({ message: "Email is required." });

    const user = await User.findOne({ email: String(email).toLowerCase().trim() });
    // Don’t reveal existence
    if (!user) return res.json({ message: "If the account exists, a new email was sent." });
    if (user.emailVerified) return res.json({ message: "Account already verified." });

    const rawToken = crypto.randomBytes(32).toString("hex");
    const tokenHash = crypto.createHash("sha256").update(rawToken).digest("hex");
    user.emailVerifyTokenHash = tokenHash;
    user.emailVerifyTokenExpiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24);
    await user.save();

    await sendVerificationEmail({ to: user.email, uid: user._id.toString(), token: rawToken });
    return res.json({ message: "Verification email resent." });
  } catch (e) {
    console.error("[resendVerification] error:", e);
    return res.status(500).json({ message: "Failed to resend." });
  }
};


