const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        index: true,
        lowercase: true,
        trim: true
    },
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true
    },
    firstName: {
        type: String,
        required: true,
        index: true
    },
    lastName: {
        type: String,
        index: true
    },
    age: {
        type: Number,
        min: 0,
        max: 150,
        set: (v) => Math.floor(v),
    },
    gender: {
        type: String,
        enum: ['male', 'female', 'other']
    },
    bio: {
        type: String,
        default: ""
    },
    avatarUrl: {
        type: String,
        default: ""
    },
    deviceToken: {
        type: String,
        default: null
    },
    followers: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "User",
        default: []
    },
    following: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "User",
        default: []
    },
    isActive: {
        type: Boolean,
        default: true
    },
}, { timestamps: true });

const User = mongoose.model("User", userSchema);

module.exports = User;
