# 🚨 PROJECT DISCONTINUED & ARCHIVED 🚨

**Reason:** High operational costs on Cloudflare Workers (Unbound) and unnecessary complexity. 
**Recommendation:** Do not deploy this. If you want a personal AI agent, run DeepSeek locally (via Ollama or LM Studio) on a Mac Mini or Raspberry Pi and use **Tailscale** to access it securely from anywhere.

---

## ⚠️ CRITICAL WARNING: The Serverless Billing Trap

**PLEASE READ THIS BEFORE ATTACHING A CREDIT CARD TO CLOUDFLARE.**

Cloudflare markets "Workers Paid" as a flat $5.00/month. This is highly misleading when using **Sandbox Containers / Workers Unbound**. 

During development, a script error caused the AI container to hang. Because Sandbox containers bill by **GiB-seconds (Duration + RAM)** instead of CPU milliseconds, a hung container racked up an **$80.00 bill** in the background before it was noticed.

### Why this architecture is flawed for LLMs:
1. **No Hard Limits:** Cloudflare does not allow you to set a hard dollar cap; they will keep billing as long as the process "runs."
2. **The "Hang" Risk:** Long-polling or streaming responses can easily keep a worker active longer than intended.
3. **Better Alternative:** Running a local Node.js server behind a **Tailscale Funnel** or **Cloudflare Tunnel** provides the same remote access with $0.00 marginal cost and 0% risk of a "billing surprise."

---

## Project Overview (Legacy Reference Only)

This project was a security-hardened fork of OpenClaw/Moltworker, engineered to run **DeepSeek V3** as its cognitive engine with persistent memory via Cloudflare R2.

### Tech Stack
* **Compute:** Cloudflare Sandbox (Workers Unbound)
* **State:** Durable Objects (Chat sessions)
* **Storage:** Cloudflare R2 (Long-term JSON memory)
* **Model:** DeepSeek V3
* **Interface:** Telegram Bot API

### Key Lessons Learned
* **Memory Persistence:** Using R2 for JSON/Markdown logs is highly effective for "infinite" memory, but the latency of fetching state on every worker wake-up adds to the execution duration.
* **Security:** The "Allowlist" protocol (ignoring all Telegram IDs except the owner) is the bare minimum requirement for any public-facing bot.

---

## Legacy Setup (Not Recommended)

If you choose to proceed despite the warnings, ensure you:
1. Set up **Usage-Based Billing Alerts** for "Workers Unbound Duration."
2. Implement strict `setTimeout` kill-switches in your TypeScript code.

### 1. Configuration
`cp wrangler.example.jsonc wrangler.jsonc`

### 2. Security Setup
Find your Telegram ID via `@userinfobot` and add it to secrets:
`npx wrangler secret put TELEGRAM_ALLOWED_USER`

### 3. Deploy
`npm run deploy`

---

**Credits:**
* Core Framework: [OpenClaw](https://github.com/OpenClaw) & Moltworker
* Modifications: Terry (@daboss88)
