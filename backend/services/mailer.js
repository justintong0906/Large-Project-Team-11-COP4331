import nodemailer from "nodemailer";
import 'dotenv/config';

/**
 * Required env:
 * MAILERSEND_HOST=smtp.mailersend.net
 * MAILERSEND_PORT=587
 * MAILERSEND_USER=ms_...@your-mailersend-domain
 * MAILERSEND_PASS=...
 * MAIL_FROM="WebApp <no-reply@your-verified-domain.com>"
 * FRONTEND_URL=https://yourfrontend.com   // or http://localhost:5173 while testing
 */



const transporter = nodemailer.createTransport({
  host: process.env.MAILERSEND_HOST,
  port: process.env.MAILERSEND_PORT,
  secure: false, // STARTTLS on 587
  auth: {
    user: process.env.MAILERSEND_USER,
    pass: process.env.MAILERSEND_PASS,
  },
  
});

/**
 * Sends the verification email used by your signup flow.
 */
export async function sendVerificationEmail({ to, uid, token }) {
  const base = process.env.FRONTEND_URL;
  const from = process.env.MAIL_FROM;

  const verifyUrl = `${base}/verify?uid=${encodeURIComponent(uid)}&token=${encodeURIComponent(token)}`;

  const html = `
    <div style="font-family:system-ui,Segoe UI,Roboto,Arial,sans-serif;line-height:1.6">
      <h2>Verify your email</h2>
      <p>Thanks for signing up. Click the button below to verify your email.</p>
      <p>
        <a href="${verifyUrl}" style="display:inline-block;padding:10px 16px;border:1px solid #ddd;border-radius:8px;text-decoration:none">
          Verify Email
        </a>
      </p>
      <p>If the button doesn't work, copy and paste this link:</p>
      <p><a href="${verifyUrl}">${verifyUrl}</a></p>
    </div>
  `;

  await transporter.sendMail({
    from,
    to,
    subject: "Verify your email",
    html,
  });
}

/** Optional: call once on server boot to confirm SMTP connectivity */
export async function verifyMailerConnection() {
  try {
    await transporter.verify();
    console.log(" MailerSend SMTP verified");
    console.log("MAILERSEND_HOST =", process.env.MAILERSEND_HOST);
  } catch (err) {
    console.error(" MailerSend SMTP verification failed:", err.message);
    console.log("MAILERSEND_HOST =", process.env.MAILERSEND_HOST);
  }
}
