//---setup---//
import express from "express";
import notesRoutes from "./routes/notesRoutes.js";
import { connectDB } from "./config/db.js";
import dotenv from "dotenv";

dotenv.config();
console.log(process.env.MONGO_URI);

const app = express();
const port = process.env.PORT || 5001;

connectDB();

app.use("/api/notes", notesRoutes)
//app.use("/api/products", productRoutes)

app.listen(port, () => {
    console.log("Server is running on port 5001");
});