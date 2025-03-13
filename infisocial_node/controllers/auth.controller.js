const admin = require("firebase-admin");

// Load Firebase service account key
const serviceAccount = require("./path-to-service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
