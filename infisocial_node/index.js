const express = require("express");
const dotenv = require("dotenv");
const connectMongoDB = require("./connection.js");
const userRouter = require("./routes/user.routes.js");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8000;

connectMongoDB(process.env.MONGODB_CONNECTION_URI)
    .then(() => console.log('MongoDB Connected!'));

app.use(express.json());
app.use(express.urlencoded());

// User Routes
app.use("/api/users", userRouter);


app.listen(PORT, () => console.log("Server is listening at port: ", PORT));
