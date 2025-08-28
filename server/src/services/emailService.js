const createTransporter = require('../config/mailer')();
const nodemailer = require('nodemailer');

async function sendEmail({ to, subject, text, html }) {
  const transporter = createTransporter();
  if (!transporter) {
    console.warn('Email transporter not configured - skipping sendEmail');
    return null;
  }
  const info = await transporter.sendMail({
    from: process.env.SMTP_USER,
    to,
    subject,
    text,
    html,
  });
  return info;
}

module.exports = { sendEmail };
