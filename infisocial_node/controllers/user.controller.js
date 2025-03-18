const { default: mongoose } = require("mongoose");
const User = require("../models/user.model");
const auth = require("./auth.controller");

const loginController = async (req, res) => {
    const { idToken } = req.body;

    try {
        const decodedToken = await auth.verifyIdToken(idToken);

        const user = User.findById(decodedToken.uid);

        if (!user) {
            return res.status(400).json({ message: "User not found in database." });
        }
        return res.status(200).json({ message: "User Login successful!", user });
    } catch (error) {
        return res.status(401).json({ error: "Invalid Token" });
    }
};

const googleLoginController = async (req, res) => {
    const { idToken } = req.body; // ID token from the Flutter app

    try {
        // Verify the ID token with Firebase
        const decodedToken = await auth.verifyIdToken(idToken);
        const { uid, email, name, picture } = decodedToken;

        const fullName = name || "";
        const nameParts = fullName.split(" ");
        const emailParts = email.split("@");
        const username = emailParts[0];
        const firstName = nameParts[0] || "";
        const lastName = nameParts.slice(1).join(" ") || "";


        // Check if user already exists in MongoDB
        let user = await User.findById(uid);

        if (!user) {
            // Create a new user in MongoDB if they don't exist
            user = new User({
                _id: uid,
                firstName,
                lastName,
                username,
                email,
                avatarUrl: picture,
                bio: "",
                age: null,
                gender: null,
            });

            await user.save();
        }

        return res.status(200).json({ message: "Login successful!", user });
    } catch (error) {
        return res.status(401).json({ error: "Invalid or expired Google ID token" });
    }
};


const signupController = async (req, res) => {
    const { firstName, lastName, email, username, age, gender, followers, following, password } = req.body;

    try {
        // Check if the email is already in Firebase Auth
        const existingUser = await auth.getUserByEmail(email).catch(() => null);
        if (existingUser) {
            return res.status(400).json({ error: "Email is already registered!" });
        }

        // Check if the username is already taken in MongoDB
        const existingUsername = await User.findOne({ username });
        if (existingUsername) {
            return res.status(400).json({ error: "Username is already taken!" });
        }

        const user_id = new mongoose.Types.ObjectId();

        const userRecord = await auth.createUser({
            uid: user_id.toString(),
            email,
            password,
            displayName: username,
        });

        const user = new User({
            _id: userRecord.uid,
            firstName,
            lastName,
            username,
            email,
            bio: null,
            avatarUrl: null,
            age,
            gender,
        });

        const savedUser = await user.save();

        return res.status(201).json({ message: "User created successfully!", user: savedUser });
    } catch (error) {
        return res.status(400).json({ error: error.message });
    }
}

const getUserById = async (req, res) => {
    try {
        const { userId } = req.query;

        if (!userId) {
            return res.status(400).json({ error: "User Id is required." });
        }

        const user = await User.findById(userId);

        if (!user) {
            return res.status(400).json({ error: "User not found." });
        }

        return res.status(200).json({ message: "User fetched successfully!", user });
    } catch (error) {
        return res.status(500).json({ error: "Something went wrong, while fetching user", details: error });
    }
};

module.exports = { loginController, googleLoginController, signupController, getUserById };