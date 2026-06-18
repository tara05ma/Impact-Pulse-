const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// 🔐 Gmail transporter using App Password
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "mandyamtara@gmail.com", // 🔁 REPLACE with your Gmail
    pass: "husx aaxz kzqn tpsm",  // ✅ your App Password
  },
});

exports.sendSOS = functions.https.onRequest(async (req, res) => {
  const { email, time, location } = req.body;

  if (!email || !location) {
    return res.status(400).send("Missing email or location");
  }

  try {
    await transporter.sendMail({
      from: "ImpactPulse SOS <mandyamtara@gmail.com>", // same Gmail
      to: email,
      subject: "🚨 Emergency Alert",
      text: `Crash detected.\n\nTime: ${time}\nLocation: ${location}\n\nPlease respond immediately.`,
    });

    return res.status(200).send("Email sent");
  } catch (error) {
    console.error("Email error:", error);
    return res.status(500).send("Failed to send email");
  }
});
