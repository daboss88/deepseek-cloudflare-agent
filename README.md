# DeepSeek-Cloudflare Agent (Research Archive)

This repository serves as a functional proof-of-concept for a serverless, memory-enabled AI assistant powered by **DeepSeek V3**, running on **Cloudflare Workers & R2**. 

---

### 💡 Project Status & Architectural Note

While this implementation is fully functional, I have moved my active development to a **Local-Inference + Mesh Network** (Tailscale) model. 

**Engineering Retrospective:**
During the development of this agent, I evaluated the trade-offs of the Cloudflare **Workers Unbound** runtime for LLM orchestration. For high-duration tasks (like processing large context windows or streaming DeepSeek responses), the **GiB-second billing model** of serverless containers can become significantly less cost-effective than dedicated local hardware. 

To optimize for both performance and long-term operational costs, I now recommend adapting the Node.js logic found in this repo to run on local hardware (e.g., Mac Mini or Raspberry Pi) accessed via a **Tailscale** tunnel. This provides the same global accessibility with superior resource control.

---

### 🚀 Key Engineering Highlights

Despite the pivot to local hosting, this project demonstrates several advanced serverless patterns:

* **DeepSeek V3 Integration:** Custom-built drivers to leverage DeepSeek’s reasoning capabilities within a worker environment.
* **Persistent Long-Term Memory:** Implemented a stateful memory system using **Cloudflare R2** (S3-compatible) to store JSON/Markdown conversation logs, ensuring context is maintained across worker cold-starts.
* **Security Hardening:** A strict "Allowlist" protocol that validates Telegram User IDs at the edge, ensuring the bot only responds to the verified owner.
* **Resilient Search Routing:** A failover logic system that switches between Google Custom Search and Brave Search APIs for real-time data retrieval.

### 🛠️ Tech Stack
* **Compute:** Cloudflare Workers (Sandbox/Unbound)
* **State Management:** Durable Objects
* **Storage:** Cloudflare R2
* **Model:** DeepSeek V3
* **Interface:** Telegram Bot API

---

### ⚠️ Implementation Note (Legacy)

If you choose to deploy this to Cloudflare, it is highly recommended to:
1.  **Monitor Usage:** Set strict Usage-Based Billing Alerts for "Workers Unbound Duration."
2.  **Execution Limits:** Implement `setTimeout` kill-switches within the handler to prevent unexpected execution tail-growth during API timeouts.

---

**Credits:**
* **Core Framework:** OpenClaw & Moltworker
* **Modifications:** Terry (@daboss88) — DeepSeek migration, R2 persistence layer, and security hardening.
