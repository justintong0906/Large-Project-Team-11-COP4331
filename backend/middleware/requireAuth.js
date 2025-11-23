// middleware/requireAuth.js
import jwt from "jsonwebtoken";
import User from "../models/User.js";

export const requireAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ message: "Missing or invalid Authorization header." });
    }

    const token = authHeader.split(" ")[1];
    if (!token) {
      return res.status(401).json({ message: "Token missing." });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (!decoded?.id) {
      return res.status(401).json({ message: "Invalid token payload." });
    }

    // Attach user to req
    const user = await User.findById(decoded.id).select("-password");
    if (!user) {
      return res.status(401).json({ message: "User not found." });
    }

    req.user = user;
    req.userId = user._id;
    next();
  } catch (err) {
    console.error("[requireAuth] error:", err.message);
    return res.status(401).json({ message: "Unauthorized or expired token." });
  }
};
