const nodemailer = require("nodemailer");

const sendEmail = async (to, subject, text) => {
    console.log("Initializing email sending process with Office 365...");

    try {
        let transporter = nodemailer.createTransport({
            host: process.env.MAIL_HOST,
            port: process.env.MAIL_PORT,
            secure: false, // true for 465, false for other ports
            auth: {
                user: process.env.MAIL_USER,
                pass: process.env.MAIL_PASS,
            },
            tls: {
                ciphers: 'SSLv3',
                rejectUnauthorized: false
            }
        });

        console.log("Office 365 transporter configured successfully.");

        // Add this after creating the transporter
        await transporter.verify();
        console.log("Server is ready to take our messages");

        const mailOptions = {
            from: process.env.MAIL_USER, // Sender address
            to, // Recipient email
            subject, // Email subject
            text, // Email body
        };

        console.log("Sending email with the following options:", mailOptions);

        const info = await transporter.sendMail(mailOptions);
        console.log("Email sent successfully:", info.messageId);

        return info;
    } catch (error) {
        console.error("Error occurred while sending email:", error.message);
        throw error;
    }
};


module.exports = sendEmail;
