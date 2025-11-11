import express from "express";
import {requireAuth} from "../middleware/requireAuth.js"
import {
  signup,
  login,
  updatePassword,
  verifyEmail,
  resendVerification,
} from "../controllers/authController.js";

const router = express.Router();

// --- Public routes ---
router.post("/signup", signup);
router.post("/login", login);
router.get("/verify-email", verifyEmail);
router.post("/resend-verification", resendVerification);
router.get("/health", (_req, res) => res.json({ ok: true }));


// --- Protected route (requires valid JWT) ---
router.post("/update-password", requireAuth, updatePassword);

export default router;
