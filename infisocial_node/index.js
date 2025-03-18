const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const dotenv = require("dotenv");
const connectMongoDB = require("./connection.js");
const userRouter = require("./routes/user.routes.js");

dotenv.config();

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 8000;

connectMongoDB(process.env.MONGODB_CONNECTION_URI)
    .then(() => console.log('MongoDB Connected!'));

app.use(express.json());
app.use(express.urlencoded());

// User Routes
app.use("/api/users", userRouter);

const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    // Listen for messages
    socket.on("sendMessage", (data) => {
        console.log("Message received:", data);
        io.emit("receiveMessage", data); // Broadcast message
    });

    // Handle user disconnect
    socket.on("disconnect", () => {
        console.log("User disconnected:", socket.id);
    });
});

server.listen(PORT, () => console.log("Server is listening at port: ", PORT));
