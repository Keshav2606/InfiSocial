const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    startTime: {
        type: Date,
        default: Date.now,
    },
    endTime: {
        type: Date,
    },
    status: {
        type: String,
        enum: ['active', 'completed', 'archived'],
        default: 'active',
    },
});

const Conversation = mongoose.model('Conversation', conversationSchema);

module.exports = Conversation;
