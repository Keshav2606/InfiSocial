const mongoose = require("mongoose");
 
let isConnected = false;
 
const connectDB = async () => {
  if (isConnected) {
    console.log("Using existing MongoDB connection");
    return;
  }
 
  try {
    await mongoose.connect(process.env.MONGO_URI);
    isConnected = true;
    console.log("MongoDB Connected");
    console.log(mongoose.connection.db.databaseName);
  }
  catch (error) {
    console.error("MongoDB Connection Failed:", error);
    throw new Error("Database connection error");
  }
};
 
module.exports = connectDB;