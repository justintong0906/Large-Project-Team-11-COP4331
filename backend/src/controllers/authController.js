//NOT DONE YET
import User from "../models/User.js";



export const signup = async (req, res) => {
    try{
        const { username, email, password} = req.body || {};
        
        if(!username || !email || !password) return res.status(400).json({message: "Username, email, and password are required."});
        //password length check
        if(password.length < 6) {
            return res.status(400).json({message: " Password must be at least 6 characters."});
        }

        //normalization
        const normalizedEmail = String(email).toLowerCase().trim();
        const normalizedusername = String(username).toLowerCase().trim();

        //Checks if Username or Email already exist
        const existing = await User.findOne({$or: [{email: normalizedEmail}, {username: normalizedusername}],})
        if (existing) {
            const field =
            existing.email === normalizedEmail ? "email" : "username";
            return res.status(409).json({ message: `That ${field} is already in use.` });
        }
        
        //hash and insert into DB
        const hash = await bcrypt.hash(password, 10);
        const user = await User.create({
            username: normalizedUsername,
            email: normalizedEmail,
            password: hash,
        });

        // Issue JWT
        const token = signToken(user);
        return res.status(201).json({
            token,
            user: { id: user._id, email: user.email, username: user.username },
        });



    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Signup failed" });
    }
}
export const login = async (req, res) => {
  try {
    const { identifier, password } = req.body || {};

    if (!identifier || !password) {
      return res
        .status(400)
        .json({ message: "Identifier and password are required." });
    }

    const idNorm = String(identifier).toLowerCase().trim();
    const looksLikeEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(idNorm);

    // Find by email OR username
    const user = await User.findOne(
      looksLikeEmail ? { email: idNorm } : { username: idNorm }
    );
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials." });
    }

    // Verify password
    const ok = await bcrypt.compare(password, user.password);
    if (!ok) {
      return res.status(401).json({ message: "Invalid credentials." });
    }

    // Issue JWT
    const token = signToken(user);
    return res.json({
      token,
      user: { id: user._id, email: user.email, username: user.username },
    });
  } catch (err) {
    console.error("[login] error:", err);
    return res.status(500).json({ message: "Login failed" });
  }
};

export const updatePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body || {};
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ message: "currentPassword and newPassword are required." });
    }
    if (newPassword.length < 6) {
      return res.status(400).json({ message: "New password must be at least 6 characters." });
    }

    // load user so we can compare/update password
    const user = await User.findById(req.user.id);
    if (!user) return res.status(401).json({ message: "User not found." });

    const ok = await bcrypt.compare(currentPassword, user.password);
    if (!ok) return res.status(401).json({ message: "Current password is incorrect." });

    const sameAsOld = await bcrypt.compare(newPassword, user.password);
    if (sameAsOld) {
      return res.status(400).json({ message: "New password must be different from current password." });
    }

    const hash = await bcrypt.hash(newPassword, 10);
    user.password = hash;
    await user.save();

    const token = signToken(user);
    return res.json({ message: "Password updated.", token });
  } catch (err) {
    console.error("[updatePassword] error:", err);
    return res.status(500).json({ message: "Failed to update password." });
  }
};
