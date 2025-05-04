const mongoose = require('mongoose');

const chatBotMessageSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    conversationId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Conversation",
        required: true,
    },
    sender: {
        type: String,
        enum: ['user', 'bot'],
        required: true,
    },
    message: {
        type: String,
        required: true,
    },
    timestamp: {
        type: Date,
        default: Date.now,
    },
});

const ChatBotMessage = mongoose.model('ChatBotMessage', chatBotMessageSchema);

module.exports = ChatBotMessage;
