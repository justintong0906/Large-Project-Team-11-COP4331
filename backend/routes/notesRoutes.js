import express from "express"
const router = express.Router()

export default router;

import { getAllNotes, createNote, updateNote, deleteNote } from "../controllers/nodeController.js";

router.get("/", getAllNotes);
router.post("/", createNote);
router.put("/:id", updateNote);
router.delete("/:id", deleteNote);