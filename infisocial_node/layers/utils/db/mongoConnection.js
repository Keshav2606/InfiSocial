const mongoose = require("mongoose");

let isConnected = false;

const connectDB = async () => {
  if (isConnected) {
    console.log("Using existing MongoDB connection");
    return;
  }

  const uri = process.env.MONGO_URI;
  if (!uri) {
    console.error("MONGO_URI is not defined in environment variables");
    throw new Error("MONGO_URI is not defined");
  }
  if (!uri.startsWith("mongodb://") && !uri.startsWith("mongodb+srv://")) {
    console.error("Invalid MONGO_URI scheme:", uri);
    throw new Error("MONGO_URI must start with 'mongodb://' or 'mongodb+srv://'");
  }

  try {
    await mongoose.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    isConnected = true;
    console.log("MongoDB Connected");
    console.log("Database:", mongoose.connection.db.databaseName);
  } catch (error) {
    console.error("MongoDB Connection Failed:", error.message);
    throw error; // Preserve the original error
  }
};

module.exports = connectDB;