const express = require("express");
const { loginController, signupController, googleLoginController, getUserById } = require("../controllers/user.controller");

const router = express.Router();


router.post('/login', loginController);
router.post('/google-login', googleLoginController);
router.post('/signup', signupController);
router.get('/get-user', getUserById);


module.exports = router;