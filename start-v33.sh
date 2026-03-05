#!/bin/bash
# VERSION CHECK: v33-google-calendar
echo ">>> STARTING SCRIPT v33 (Google Calendar Integration) <<<"

echo "----------------------------------------"
echo "DEBUG: Checking for R2 Backups..."
sleep 2
if [ -d "/data/moltbot/clawdbot" ] && [ "$(ls -A /data/moltbot/clawdbot 2>/dev/null)" ]; then
    echo "DEBUG: Found R2 backup! Restoring memory..."
    mkdir -p /root/.clawdbot /root/clawd/agent /root/clawd/skills
    rsync -a /data/moltbot/clawdbot/ /root/.clawdbot/
    rsync -a /data/moltbot/agent/ /root/clawd/agent/ 2>/dev/null || true
    rsync -au /data/moltbot/skills/ /root/clawd/skills/ 2>/dev/null || true
    echo "DEBUG: Memory restored. ✅"
else
    echo "DEBUG: No backup found. Starting fresh. ❌"
fi
echo "----------------------------------------"

# --- THE CLEAN .ENV FIX ---
echo "DEBUG: Writing environment variables to .env file..."
echo "GOOGLE_API_KEY=${GOOGLE_API_KEY}" > /root/clawd/.env
echo "GOOGLE_CSE_ID=${GOOGLE_CSE_ID}" >> /root/clawd/.env
echo "EMAIL_USER=${EMAIL_USER}" >> /root/clawd/.env
echo "EMAIL_PASS=${EMAIL_PASS}" >> /root/clawd/.env

# --- GOOGLE CALENDAR CREDENTIALS ---
if [ -n "$GCP_SERVICE_ACCOUNT_JSON" ]; then
    echo "DEBUG: Writing Google Calendar credentials..."
    # Write the JSON string safely to a file
    echo "$GCP_SERVICE_ACCOUNT_JSON" > /root/clawd/calendar-keys.json
    
    # Set the standard Google SDK environment variable
    echo "GOOGLE_APPLICATION_CREDENTIALS=/root/clawd/calendar-keys.json" >> /root/clawd/.env
    
    # Give your bot the exact Calendar ID she needs to read
    echo "CALENDAR_ID=${CALENDAR_ID:-your-email@gmail.com}" >> /root/clawd/.env
fi

mkdir -p /root/.clawdbot
CONFIG_FILE="/root/.clawdbot/clawdbot.json"
if [ ! -f "$CONFIG_FILE" ]; then echo "{}" > "$CONFIG_FILE"; fi

node -e '
const fs = require("fs");
const configFile = "/root/.clawdbot/clawdbot.json";
let config = {};
try { config = JSON.parse(fs.readFileSync(configFile)); } catch (e) {}
if (config.search) { delete config.search; }
config.models = config.models || {};
config.models.providers = config.models.providers || {};
config.agents = config.agents || {};
let rawKey = process.env.OPENAI_API_KEY || "";
let cleanKey = rawKey.replace(/["'\''"]/g, "").trim();
let vipUser = process.env.TELEGRAM_ALLOWED_USER || ""; 
let policy = vipUser ? "allowlist" : "pairing";
config.models.providers.deepseek = {
    api: "openai-completions",
    baseUrl: "https://api.deepseek.com/v1",
    apiKey: cleanKey,
    models: [{ id: "deepseek-chat", name: "DeepSeek Chat", contextWindow: 64000 }]
};
config.agents.defaults = { model: { primary: "deepseek/deepseek-chat" } };
config.gateway = { port: 18789, auth: { token: process.env.CLAWDBOT_GATEWAY_TOKEN || "admin" } };
if (config.gateway.token) { delete config.gateway.token; }
if (config.gateway.bind) { delete config.gateway.bind; }
config.channels = config.channels || {};
if (process.env.TELEGRAM_BOT_TOKEN) {
    config.channels.telegram = {
        botToken: process.env.TELEGRAM_BOT_TOKEN,
        dmPolicy: policy,
        allowFrom: vipUser ? [vipUser] : ["*"],
        enabled: true
    };
}
fs.writeFileSync(configFile, JSON.stringify(config, null, 2));
'

echo "Config patched. Starting Gateway..."
exec clawdbot gateway --port 18789 --bind "lan" --token "${CLAWDBOT_GATEWAY_TOKEN:-admin}" --allow-unconfigured