---
name: web-search
description: Search the live internet for up-to-date information, news, and facts using Google (with Brave failover).
---

# Web Search (Smart Router)

Searches the internet using a hybrid Google/Brave engine. Use this when you need current information, news, weather, or facts that are not in your training data.

## Usage

Run the search script with a query string.

```bash
node skills/web-search/search.js "your search query here"
```

## Environment Variables

This skill uses the following environment variables (set in `.env`):

- `GOOGLE_API_KEY`: Your Google Custom Search API Key.
- `GOOGLE_CSE_ID`: Your Google Custom Search Engine ID.
- `BRAVE_API_KEY`: Your Brave Search API Key (Backup).

---

### **3. The Final Step: Cleanup**
Just to keep things tidy:
1.  **Delete** the file `src/skills/web_search.ts` (the one we made earlier). It is in the wrong spot.
2.  **Delete** the `webSearchTool` import from `src/index.ts`.

### **4. Deploy & Test**
Now, you can deploy! The bot will scan the `skills` folder, see `web-search`, and automatically know how to use it because of `SKILL.md`.

```powershell
npm run deploy