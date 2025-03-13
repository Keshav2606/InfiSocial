const mongoose = require('mongoose');

const connectMongoDB = async (url) => {
    return await mongoose.connect(url);
}

module.exports = connectMongoDB;