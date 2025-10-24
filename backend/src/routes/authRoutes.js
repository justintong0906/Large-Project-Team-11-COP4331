import express from "express";
import { signup, login } from "../controllers/authController.js";

const router = express.Router();

//run signup when signup POST
router.post("/signup", signup);
//run login on login POST
router.post("/login", login);

export default router;