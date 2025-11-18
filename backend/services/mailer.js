import { Resend } from "resend";
import "dotenv/config";
const API_BASE = process.env.API_BASE;

const resend = new Resend(process.env.RESEND_API_KEY);

/**
 * Sends a verification email to the user with a link that hits the backend verify endpoint.
 * Backend (5001) verifies the token and then redirects to frontend (3000) with ?status=success or ?status=failed.
 */
export async function sendVerificationEmail({ to, uid, token }) {
  const apiBase = process.env.API_BASE_URL || `${API_BASE}`;
  const from = process.env.MAIL_FROM;

  // ✅ This URL hits your backend API first (not the frontend)
  const verifyUrl = `${apiBase}/api/auth/verify-email?uid=${encodeURIComponent(uid)}&token=${encodeURIComponent(token)}`;

  const html = `
    <div style="font-family:system-ui,Segoe UI,Roboto,Arial,sans-serif;line-height:1.6">
      <h2>Verify your email</h2>
      <p>Thanks for signing up! Click the button below to verify your email.</p>
      <p>
        <a href="${verifyUrl}"
           style="display:inline-block;padding:10px 16px;border-radius:8px;
                  text-decoration:none;background:#111;color:#fff">
          Verify Email
        </a>
      </p>
      <p>If the button doesn’t work, copy and paste this link:</p>
      <p><a href="${verifyUrl}">${verifyUrl}</a></p>
    </div>
  `;

  try {
    console.log("[sendVerificationEmail] Sending email to:", to);
    console.log("[sendVerificationEmail] Verify URL:", verifyUrl);

    await resend.emails.send({
      from,
      to,
      subject: "Verify your email",
      html,
      text: `Verify your email: ${verifyUrl}`,
    });

    console.log("✅ Verification email sent successfully");
  } catch (err) {
    console.error("❌ Failed to send verification email:", err.message);
    throw err;
  }
}

/** Optional: lightweight API connectivity check */
export async function verifyMailerConnection() {
  try {
    const domains = await resend.domains.list();
    console.log(`✅ Resend API reachable (${domains.data?.length ?? 0} domains found)`);
  } catch (err) {
    console.error("❌ Resend API check failed:", err.message);
  }
}

export async function sendPasswordResetEmail({ to, resetToken }) {
  const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;

  await resend.emails.send({
    from: process.env.MAIL_FROM,
    to,
    subject: "Reset your password",
    html: `
      <h2>Password Reset Request</h2>
      <p>Click below to reset your password:</p>
      <p><a href="${resetUrl}">${resetUrl}</a></p>
      <p>This link is valid for 15 minutes.</p>
    `
  });
}

