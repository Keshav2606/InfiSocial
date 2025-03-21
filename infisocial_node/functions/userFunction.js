const mongoose = require("mongoose");
const connectDB = require("/opt/utils/db/mongoConnection.js");

const AWS = require("aws-sdk");
const StreamChat = require('stream-chat').StreamChat;
const serverClient = StreamChat.getInstance(process.env.STREAM_API_KEY, process.env.STREAM_API_SECRET);

const User = require("/opt/utils/models/user.model.js");
const auth = require("./auth.js");
const { buildResponse } = require("/opt/utils/config/buildResponse.js");

exports.handler = async (event) => {
    await connectDB();

    try {
        const httpMethod = event.httpMethod;
        const path = event.path;

        console.log(httpMethod);
        console.log(path);

        if (httpMethod === "GET" && path === "/test") {
            return {
                statusCode: 200,
                body: JSON.stringify({ message: "Hello, World!" }),
            };
        }
        else if (httpMethod === "POST" && path === "/users/signup") {
            const body = JSON.parse(event.body);
            return await userRegistration(body);
        }
        else if (httpMethod === "POST" && path === "/users/login") {
            const body = JSON.parse(event.body);
            return await userLogin(body);
        }
        else if (httpMethod === "POST" && path === "/users/google-login") {
            const body = JSON.parse(event.body);
            return await googleLogin(body);
        }
        else if (httpMethod === "GET" && path === "/users/get-user") {
            const queryParams = event.queryStringParameters;
            return await getUserById(queryParams);
        }
        else if (httpMethod === "GET" && path === "/users/get-all-users") {
            return await getAllUsers();
        }
        else if (httpMethod === "PUT" && path === "/users/update-user") {
            const body = JSON.parse(event.body);
            return await updateUser(body);
        }
        else if (httpMethod === "GET" && path === "/users/get-stream-token") {
            const queryParams = event.queryStringParameters;
            return await generateStreamToken(queryParams);
        }
        return {
            statusCode: 404,
            body: JSON.stringify({ error: "Route not found" }),
        };
    }
    catch (error) {
        console.error("Error handling request:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: "Internal Server Error" }),
        };
    }
};

const generateStreamToken = (queryParams) => {
    try {
        const { userId } = queryParams;

        if (!userId) {
            return buildResponse(400, { error: "User ID is required!" });
        }
        const token = serverClient.createToken(userId);
        return buildResponse(200, { token });
    } catch (error) {
        return buildResponse(500, { error });
    }

};

const userRegistration = async (body) => {
    try {
        console.log("Received registration request:", body);

        const { firstName, lastName, email, username, age, gender, password } = body;

        // Step 1: Check if the email is already in Firebase Auth
        console.log("Checking if email exists in Firebase:", email);
        const existingUser = await auth.getUserByEmail(email).catch(() => null);
        if (existingUser) {
            console.log("Email is already registered in Firebase.");
            return buildResponse(400, { error: "User with this Email is already registered!" });
        }

        // Step 2: Check if the username is already taken in MongoDB
        console.log("Checking if username exists in MongoDB:", username);
        const existingUsername = await User.findOne({ username, isActive: true });
        if (existingUsername) {
            console.log("Username is already taken.");
            return buildResponse(400, { error: "Username is already taken!" });
        }

        // Step 3: Create a new user ID
        const user_id = new mongoose.Types.ObjectId();
        console.log("Generated new user ID:", user_id.toString());

        // Step 4: Create user in Firebase Auth
        console.log("Creating user in Firebase Auth...");
        const userRecord = await auth.createUser({
            uid: user_id.toString(),
            email,
            password,
            displayName: username,
        });
        console.log("User created in Firebase Auth:", userRecord.uid);

        // Step 5: Create user in MongoDB
        console.log("Saving user to MongoDB...");
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
        console.log("User saved in MongoDB:", savedUser._id);

        // Step 6: Send response back
        console.log("User registration successful!");
        return buildResponse(201, { message: "User created successfully!", user: savedUser });
    } catch (error) {
        console.error("Error during user registration:", error.message);
        return buildResponse(400, { error: error.message });
    }
};


const userLogin = async (body) => {
    const { email, password } = body;

    if (!email || !password) {
        return buildResponse(400, { error: "Email and Password are required." });
    }

    try {
        // Sign in the user using Firebase Authentication REST API
        const response = await fetch(
            `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${process.env.FIREBASE_API_KEY}`,
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    email,
                    password,
                    returnSecureToken: true
                }),
            }
        );

        const data = await response.json();

        if (data.error) {
            return buildResponse(401, { error: data.error.message });
        }

        // Extract user info and ID token
        const { idToken, localId } = data;

        // Retrieve user from Firestore or Database
        const user = await User.findOne({_id: localId, isActive: true});

        if (!user) {
            return buildResponse(400, { message: "User not found in database." });
        }

        return buildResponse(200, { message: "User Login successful!", user, token: idToken });
    } catch (error) {
        console.error("Login Error:", error);
        return buildResponse(500, { error: "Something went wrong" });
    }
};

const googleLogin = async (body) => {
    const { idToken } = body; // ID token from the Flutter app

    if (!idToken) {
        return buildResponse(400, { error: "ID token is required!" });
    }

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
        let user = await User.findOne({_id: uid, isActive: true});

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

        return buildResponse(200, { message: "Login successful!", user });
    } catch (error) {
        return buildResponse(401, { error: "Invalid or expired Google ID token" });
    }
};

const getUserById = async (queryParams) => {
    try {
        const { userId } = queryParams;

        if (!userId) {
            return buildResponse(400, { error: "User Id is required." });
        }

        const user = await User.findOne({_id: userId, isActive: true});

        if (!user) {
            return buildResponse(400, { error: "User not found." });
        }

        return buildResponse(200, { message: "User fetched successfully!", user });

    } catch (error) {
        return buildResponse(500, { error: "Something went wrong, while fetching user", details: error });
    }
};

const getAllUsers = async () => {
    try {
        const users = await User.find({ isActive: true });

        return buildResponse(200, { message: "Users fetched successfully!", users });
    } catch (error) {
        return buildResponse(500, { error: "Something went wrong, while fetching users", details: error });
    }
};

const updateUser = async (body) => {
    try {
        const { userId, updateData } = body;

        if (!userId) {
            return buildResponse(400, { error: "User Id is required." });
        }
        
        const user = await User.findByIdAndUpdate(userId, updateData, { new: true });

        if (!user) {
            return buildResponse(400, { error: "User not found." });
        }

        return buildResponse(200, { message: "User updated successfully!", user });
    } catch (error) {
        return buildResponse(500, { error: "Something went wrong, while updating user", details: error });
    }
};
