import express from "express";
import {requireAuth} from "../middleware/requireAuth.js"
import { getUserProfile,getRandomCompatibleUser, saveQuizResults} from "../controllers/userController.js";
import { SendMatch } from "../controllers/userController.js";

const router = express.Router();

router.post("/match/:id", requireAuth, SendMatch);

router.get("/me", requireAuth, getUserProfile);

router.get("/random-compatible",requireAuth, getRandomCompatibleUser);


router.get("/:id", requireAuth, getUserProfile);


// Authenticated self-update (recommended)
router.put("/me/quiz", requireAuth, saveQuizResults);

// (Optional) Admin-style update by id
router.put("/:id/quiz", requireAuth, saveQuizResults);


export default router;
