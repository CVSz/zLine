import { useState } from "react";
import axios from "axios";

export default function App() {
  const [msg, setMsg] = useState("");
  const [res, setRes] = useState("");
  const [sending, setSending] = useState(false);

  const send = async () => {
    setSending(true);
    try {
      const r = await axios.post(
        "/api/chat",
        { message: msg },
        {
          headers: { Authorization: "Bearer " + localStorage.token },
        }
      );
      setRes(r.data.reply);
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100">
      <main className="mx-auto max-w-5xl p-8 md:p-12">
        <section className="rounded-2xl border border-slate-800 bg-slate-900/60 p-8 shadow-2xl">
          <p className="inline-block rounded-full border border-emerald-400/30 bg-emerald-400/10 px-3 py-1 text-xs font-semibold text-emerald-300">
            DEPLOY LIVE NOW
          </p>
          <h1 className="mt-4 text-3xl font-bold leading-tight md:text-5xl">
            ทำเงินด้วย AI ใน 10 นาที
          </h1>
          <p className="mt-4 max-w-2xl text-slate-300">
            เปิดใช้ AI SaaS ของคุณทันทีบนโดเมนจริง พร้อมระบบจ่ายเงิน Stripe
            และแพลนเริ่มต้นสำหรับลูกค้ากลุ่มแรกภายใน 24 ชั่วโมง
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <button
              onClick={() => (window.location.href = "/api/create-checkout")}
              className="rounded-lg bg-emerald-500 px-5 py-3 font-semibold text-slate-950 transition hover:bg-emerald-400"
            >
              Upgrade $9
            </button>
            <button
              onClick={() => {
                const chatSection = document.getElementById("chat-demo");
                chatSection?.scrollIntoView({ behavior: "smooth" });
              }}
              className="rounded-lg border border-slate-600 px-5 py-3 font-semibold transition hover:border-slate-400"
            >
              Start Free
            </button>
          </div>
        </section>

        <section className="mt-8 grid gap-4 md:grid-cols-3">
          {[
            { title: "Hosting", value: "VPS (DO / Vultr)" },
            { title: "Payment", value: "Stripe Checkout" },
            { title: "Traffic", value: "TikTok / Reddit" },
          ].map((item) => (
            <div
              key={item.title}
              className="rounded-xl border border-slate-800 bg-slate-900 p-5"
            >
              <div className="text-sm text-slate-400">{item.title}</div>
              <div className="mt-2 text-lg font-semibold">{item.value}</div>
            </div>
          ))}
        </section>

        <section
          id="chat-demo"
          className="mt-8 rounded-2xl border border-slate-800 bg-slate-900 p-6"
        >
          <h2 className="text-xl font-semibold">Live Demo: AI Response</h2>
          <p className="mt-2 text-sm text-slate-300">
            ลองส่งข้อความเพื่อดูคุณภาพโมเดลก่อนตัดสินใจอัปเกรดแพลน
          </p>
          <div className="mt-4 flex flex-col gap-3 md:flex-row">
            <input
              onChange={(e) => setMsg(e.target.value)}
              placeholder="พิมพ์สิ่งที่อยากให้ AI ช่วย..."
              className="w-full rounded-lg border border-slate-700 bg-slate-950 p-3 text-slate-100"
            />
            <button
              onClick={send}
              disabled={sending || !msg.trim()}
              className="rounded-lg bg-blue-500 px-6 py-3 font-semibold text-white transition hover:bg-blue-400 disabled:cursor-not-allowed disabled:bg-blue-700"
            >
              {sending ? "Sending..." : "Send"}
            </button>
          </div>
          <div className="mt-4 min-h-20 rounded-lg border border-slate-800 bg-slate-950/80 p-4 text-slate-200">
            {res || "ผลลัพธ์จาก AI จะแสดงที่นี่"}
          </div>
        </section>
      </main>
    </div>
  );
}
