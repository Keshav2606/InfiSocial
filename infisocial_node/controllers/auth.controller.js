const admin = require("firebase-admin");

// Load Firebase service account key
const serviceAccount = require("C:/Users/KESHAVKUMAR/Downloads/infisocial-90d8b-firebase-adminsdk-x6g6i-0200a4e0b5.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();

module.exports = auth;
