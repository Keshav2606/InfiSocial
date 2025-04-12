const mongoose = require("mongoose");

const postSchema = new mongoose.Schema({
    postedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    content: {
        type: String,
    },
    mediaUrl: {
        type: String,
    },
    mediaType: {
        type: String,
        enum: ["image", "video"],
    },
    tags: {
        type: [String],
        default: [],
        index: true,
    },
    taggedUsers: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: 'User',
        default: [],
        index: true,
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
