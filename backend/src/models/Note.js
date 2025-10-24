import mongoose from "mongoose";

// 1. create schema
// 2. model based off that schema

const noteSchema = new mongoose.Schema(
    {
        title: {
            type:String,
            required:true,
        },
        content: {
            type: String,
            required: true
        }
    },
    {
        timestamps: true
    }
);

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, index: true },
    password: { type: String, required: true, minlength: 6 }
  },
  { timestamps: true }
);
export const User = mongoose.model("User", userSchema);
export const Note = mongoose.model("Note", noteSchema);


