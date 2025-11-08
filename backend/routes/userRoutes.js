import express from "express";
import { getUserProfile,getRandomCompatibleUser,getRandomUser } from "../controllers/userController.js";
const router = express.Router();

router.get("/:id", getUserProfile);
router.get("/random", getRandomUser);
router.get("/random-compatible", getRandomCompatibleUser);


export default router;
