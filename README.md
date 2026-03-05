# DeepSeek-Cloudflare Agent (Self-Hosted)

> A serverless, memory-enabled AI personal assistant powered by DeepSeek V3, running on Cloudflare Workers & R2.

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Status](https://img.shields.io/badge/status-active-success.svg) ![Stack](https://img.shields.io/badge/tech-Cloudflare%20Workers%20%7C%20R2%20%7C%20DeepSeek-lightgrey)

---

## ⚠️ CRITICAL WARNING: The Serverless Billing Trap

**PLEASE READ THIS BEFORE YOU ATTACH YOUR CREDIT CARD TO CLOUDFLARE.** Cloudflare markets their "Workers Paid" plan as a flat $5.00/month. **This is highly misleading when using Sandbox Containers / Workers Unbound.** During the development of this bot, a script error caused the AI container to hang. Because Sandbox containers bill by **GiB-seconds (Duration + RAM)** instead of CPU milliseconds, the hung container racked up an $80.00 bill in the background before I noticed.

If you deploy this to Cloudflare:

1. **You cannot set a hard dollar limit.**
2. **You MUST set up Usage-Based Billing Alerts** for "Workers Unbound Duration".
3. If you run heavy text processing (like parsing hundreds of emails at once), implement strict `setTimeout` kill-switches in your Node.js code so the container crashes gracefully instead of hanging.

*Because of this risk, I highly recommend adapting this Node.js logic to run locally on a Mac Mini or Raspberry Pi if you are a beginner.* Proceed with Cloudflare at your own financial risk.

---

## Overview

This project is a highly modified, security-hardened fork of OpenClaw/Moltworker, re-engineered to run **DeepSeek V3** as its cognitive engine. It features **Persistent Long-Term Memory** via Cloudflare R2 (S3-compatible storage), allowing it to remember user details, preferences, and context across sessions.

## Key Features

- **DeepSeek V3 Integration:** Replaced default OpenAI drivers with DeepSeek's advanced reasoning model.
- **Infinite Memory:** Uses **Cloudflare R2** to store JSON/Markdown logs of conversations. It doesn't "forget" when the server restarts.
- **Enterprise Security:** Custom "Allowlist" protocol. The bot ignores all Telegram messages unless the User ID matches the verified owner.
- **Search Engine Routing:** Built-in failover search script (Google Custom Search -> Brave Search).

## Tech Stack

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Compute** | Cloudflare Sandbox | Serverless execution environment |
| **State** | Durable Objects | Manages active chat sessions & "Brain" state |
| **Storage** | Cloudflare R2 | Long-term memory (S3 Protocol) |
| **Model** | DeepSeek V3 | LLM for reasoning and chat |
| **Interface** | Telegram Bot API | User interaction frontend |

## Installation & Setup

### Prerequisites

- Cloudflare Account (Workers & R2 enabled)
- Telegram Bot Token (@BotFather)
- DeepSeek API Key

### 1. Configuration

Clone the repo and copy the example config:

```bash
cp wrangler.example.jsonc wrangler.jsonc
```

### 2. Security Setup (The Allowlist)

This agent uses a strict allowlist to prevent unauthorized access.

1. **Find your Telegram ID:** Message the bot [@userinfobot](https://t.me/userinfobot) on Telegram. It will reply with your numeric ID.
2. **Add it to Cloudflare Secrets:**
   ```bash
   npx wrangler secret put TELEGRAM_ALLOWED_USER
   ```

### 3. Deploy

```bash
npm run deploy
```

## Credits

- **Core Framework:** [OpenClaw](https://github.com/openclaw) & [Moltworker](https://github.com/cloudflare/moltworker)
- **Modifications:** **Terry (@daboss88)** - DeepSeek migration, R2 persistence fix, Security hardening.
````