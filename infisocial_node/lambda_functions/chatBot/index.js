const connectDB = require("/opt/utils/db/mongoConnection.js");
const { buildResponse } = require("/opt/utils/config/buildResponse.js");

const AWS = require("aws-sdk");

const ChatBotMessage = require("/opt/utils/models/chatBotMessage.model.js");
const Conversation = require("/opt/utils/models/conversation.model.js");

exports.handler = async (event) => {
    await connectDB();

    try {
        const httpMethod = event.httpMethod;
        const path = event.path;

        if (httpMethod === "POST" && path === "/chatbot/messages") {
            const body = JSON.parse(event.body);
            return await addMessages(body);
        }
        else if (httpMethod === "GET" && path === "/chatbot/messages") {
            const query = event.queryStringParameters;
            return await getMessages(query);
        }
        else if (httpMethod === "GET" && path === "/chatbot/conversations") {
            const userId = event?.queryStringParameters?.userId;
            return await getUserConversations(userId);
        }

        return buildResponse(404, { error: "Route not found" });

    }
    catch (error) {
        console.error("Error handling request:", error);
        return buildResponse(500, { error: "Internal Server Error" });
    }
};

const addMessages = async (body) => {
    try {
        const { userId, conversationId, sender, message } = body;


        if (!userId || !sender || !message) {
            return buildResponse(400, { error: "Missing required fields" });
        }

        let finalConversationId = conversationId;

        if (!finalConversationId) {
            const newConversation = new Conversation({
                userId,
                startTime: new Date(),
            });
            const savedConversation = await newConversation.save();
            finalConversationId = savedConversation._id;
        }

        const newMessage = new ChatBotMessage({
            userId,
            conversationId: finalConversationId,
            sender,
            message,
            timestamp: new Date(),
        });

        await newMessage.save();

        return buildResponse(200, { success: true, message: "Message added" });


    } catch (error) {
        console.error("Error adding message:", error);
        return buildResponse(500, { error: error.message });
    }
};

const getMessages = async (query) => {
    try {
        const userId = query?.userId;
        const conversationId = query?.conversationId;

        if (!userId) {
            return buildResponse(400, { error: "Missing userId" });
        }

        const filter = { userId };
        if (conversationId) filter.conversationId = conversationId;

        const messages = await ChatBotMessage.find(filter).sort({ timestamp: 1 });

        return buildResponse(200, messages);


    } catch (error) {
        console.error("Error fetching messages:", error);
        return buildResponse(500, { error: error.message });
    }
};

const getUserConversations = async (userId) => {
    try {
        if (!userId) {
            return buildResponse(400, { error: "Missing userId" });
        }

        const conversations = await Conversation.find({ userId }).sort({ startTime: -1 });

        return buildResponse(200, conversations);

    } catch (error) {
        console.error("Error fetching conversations:", error);
        return buildResponse(500, { error: error.message });
    }
};
