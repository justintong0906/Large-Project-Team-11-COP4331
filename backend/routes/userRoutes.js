import express from "express";
import {requireAuth} from "../middleware/requireAuth.js"
import { getUserProfile,getRandomCompatibleUser, saveQuizResults} from "../controllers/userController.js";
const router = express.Router();

router.get("/:id", getUserProfile);
router.get("/random-compatible",requireAuth, getRandomCompatibleUser);

// Authenticated self-update (recommended)
router.put("/me/quiz", requireAuth, saveQuizResults);

// (Optional) Admin-style update by id
router.put("/:id/quiz", requireAuth, saveQuizResults);


export default router;
