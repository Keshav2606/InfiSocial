const User = require("../models/user.model");
const bcrypt = require("bcrypt");

const loginController = async (req, res) => {
    try {

        const { email, password } = req.body;

        if (!email, !password) {
            return res.status(400).json({ message: "Missing required fields." });
        }

        const user = User.findOne({ email });

        if (!user) {
            return res.status(404).json({ message: "User with provided email not found." });
        }

        const isPasswordValid = bcrypt.compare(password, user.password);

        if (!isPasswordValid) {
            return res.status(400).json({ message: "Invalid Password" });
        }

        return res.status(200).json({message: "User fetched successfully", user: user});

    } catch (error) {
        return res.status(400).json({ error: error.message });
    }


};

const signupController = async (req, res) => {
    try {
        const { fullName, email, username, bio, avatarUrl, age, gender, followers, following, password } = req.body;

        if (!fullName, !email, !username, !password) {
            return res.status(400).json({ message: "Missing required fields." });
        }
        const hashedPassword = await bcrypt.hash(password, 10);

        const userRecord = await User.create({
            fullName,
            email,
            username,
            bio,
            avatarUrl,
            age,
            gender,
            followers,
            following,
            password: hashedPassword,
        });

        return res.status(201).json({ message: "User created successfully" });
    } catch (error) {
        return res.status(400).json({ error: error.message });
    }


}

module.exports = { loginController, signupController };