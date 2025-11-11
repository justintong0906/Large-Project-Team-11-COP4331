import { Resend } from "resend";
import "dotenv/config";

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendVerificationEmail({ to, uid, token }) {
  const base = process.env.FRONTEND_URL;
  const from = process.env.MAIL_FROM;
  const verifyUrl = `${base}/verify?uid=${encodeURIComponent(uid)}&token=${encodeURIComponent(token)}`;

  const html = `
    <div style="font-family:system-ui,Segoe UI,Roboto,Arial,sans-serif;line-height:1.6">
      <h2>Verify your email</h2>
      <p>Thanks for signing up. Click the button below to verify your email.</p>
      <p>
        <a href="${verifyUrl}"
           style="display:inline-block;padding:10px 16px;border:1px solid #ddd;
                  border-radius:8px;text-decoration:none;background:#111;color:#fff">
          Verify Email
        </a>
      </p>
      <p>If the button doesn't work, copy and paste this link:</p>
      <p><a href="${verifyUrl}">${verifyUrl}</a></p>
    </div>
  `;

  await resend.emails.send({
    from,
    to,
    subject: "Verify your email",
    html,
    text: `Verify your email: ${verifyUrl}`,
  });
}

/** Optional: lightweight connectivity check */
export async function verifyMailerConnection() {
  try {
    const result = await resend.domains.list(); // simple API call
    console.log("✅ Resend API reachable. Domains count:", result.data?.length ?? "unknown");
  } catch (err) {
    console.error("❌ Resend API check failed:", err.message);
  }
}
