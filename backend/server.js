// --- setup ---
import dotenv from "dotenv";
import express from "express";
import notesRoutes from "./routes/notesRoutes.js";
import { connectDB } from "./config/db.js";
import authRoutes from "./routes/authRoutes.js";
import cors from "cors";
import { verifyMailerConnection } from "./services/mailer.js";
import userRoutes from "./routes/userRoutes.js";
import path from "path";
import { fileURLToPath } from "url";

dotenv.config();
console.log(process.env.MONGO_URI);

const app = express();
const port = process.env.PORT || 5001;

// Middleware
app.use(express.json());
app.use(cors());

// API routes
app.use("/api/users", userRoutes);
app.use("/api/notes", notesRoutes);
app.use("/api/auth", authRoutes);

// DB + mail
connectDB();
try {
  verifyMailerConnection();
} catch (err) {
  console.error("verifyMailerConnection error:", err?.message || err);
}

// --- DigitalOcean / production static hosting ---

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Serve static files from React build
app.use(express.static(path.join(__dirname, "../frontend/build")));

// ✅ SPA fallback without path-to-regexp parsing
// (No path string; matches anything not handled above)
app.use((req, res) => {
  res.sendFile(path.join(__dirname, "../frontend/build", "index.html"));
});

// Start server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
