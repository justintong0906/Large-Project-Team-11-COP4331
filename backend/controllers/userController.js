import User from "../models/User.js";
import mongoose from "mongoose";

export const getUserProfile = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({ message: "Invalid user id" });
    }

    // find user but exclude sensitive info
    const user = await User.findById(id)
      .select("-password -emailVerifyTokenHash -emailVerifyTokenExpiresAt");

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.json(user);
  } catch (err) {
    console.error("[getUserProfile] error:", err);
    return res.status(500).json({ message: "Failed to fetch profile" });
  }
};
