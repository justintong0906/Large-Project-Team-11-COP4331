//---setup---//
import dotenv from "dotenv";
import express from "express";
import notesRoutes from "./routes/notesRoutes.js";
import { connectDB } from "./config/db.js";
import authRoutes from "./routes/authRoutes.js";
import cors from "cors";
import { verifyMailerConnection } from "./services/mailer.js";
import userRoutes from "./routes/userRoutes.js";




dotenv.config();
console.log(process.env.MONGO_URI);

const app = express();
const port = process.env.PORT || 5001;

app.use(express.json());
app.use(cors());

app.use("/api/users", userRoutes);

connectDB();
verifyMailerConnection();

app.use("/api/notes", notesRoutes)
//app.use("/api/products", productRoutes)

app.use("/api/auth", authRoutes)


app.listen(port, () => {
    console.log("Server is running on port 5001");
});





// FOR DIGITAL OCEAN SERVER

import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Serve static files from React build
app.use(express.static(path.join(__dirname, '../frontend/build')));

// Handle React routing
app.get('/*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/build', 'index.html'));
});
//