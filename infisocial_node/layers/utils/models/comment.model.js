const mongoose = require("mongoose");

const commentSchema = new mongoose.Schema({
    postId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Post",
        required: true,
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    content: {
        type: String,
        required: true,
    },
    likes: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "User",
        default: [],
    },
    isActive: {
        type: Boolean,
        default: true,
    }
}, { timestamps: true }
);

const Comment = mongoose.model("Comment", commentSchema);

module.exports = Comment;
