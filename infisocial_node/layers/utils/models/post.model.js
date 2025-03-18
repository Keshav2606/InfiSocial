const mongoose = require("mongoose");

const postSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    content: {
        type: String,
        required: true,
    },
    mediaUrl: {
        type: String,
    },
    mediaType: {
        type: String,
        enum: ["image", "video", "audio", "other"],
    },
    tags: {
        type: [String],
        default: [],
    },
    likes: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "User",
        default: [],
    },
    comments: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "Comment",
        default: [],
    },
    isActive: {
        type: Boolean,
        default: true
    }
},
    { timestamps: true }
);

const Post = mongoose.model("Post", postSchema);

module.exports = Post;
