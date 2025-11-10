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

// import path from "path";
// //import express from "express";
// //const app = express();

// app.use(express.static(path.join(__dirname, "../frontend/build")));

// app.get("*", (req, res) => {
//   res.sendFile(path.join(__dirname, "../frontend/build", "index.html"));
// });

//