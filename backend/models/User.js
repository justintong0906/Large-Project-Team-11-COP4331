import mongoose from "mongoose";


const profileSchema = new mongoose.Schema(
  {
    age: { type: Number, min: 0, max: 120 },
    gender: { type: String, enum: ["male", "female", "nonbinary", "other", "prefer_not_to_say"], trim: true },
    major: { type: String, trim: true, maxlength: 120 },
    bio: { type: String, trim: true, maxlength: 2000 },
    photo: { type: String, trim: true }, // URL (optional). If you use Cloudinary/S3 later, you can store an object here.
    yearsOfExperience: { type: Number, min: 0, max: 100 },
    genderPreferences: { type: String, enum: ["coed", "single_gender", "no_preference"], default: "no_preference" },
  },
  { _id: false }
);

const userSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, index: true },
    password: { type: String, required: true, minlength: 6 },
    emailVerified: { type: Boolean, default: false },

    // temporary on signup
    emailVerifyTokenHash: { type: String, index: true },
    emailVerifyTokenExpiresAt: { type: Date },


    questionnaireBitmask: { type: Number, default: 0 },

    profile: { type: profileSchema, default: {} },




  },
  { timestamps: true }
);




const User = mongoose.model("User", userSchema);
export default User;