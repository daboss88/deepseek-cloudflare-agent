#!/usr/bin/env node
/**
 * Smart Router Search Script
 * Usage: node search.js "your search query"
 */

const https = require('https');
const url = require('url');

const query = process.argv[2];

if (!query) {
    console.error("Error: No query provided. Usage: node search.js <query>");
    process.exit(1);
}

function fetchJson(requestUrl, headers = {}) {
    return new Promise((resolve, reject) => {
        const parsedUrl = url.parse(requestUrl);
        const options = { ...parsedUrl, method: 'GET', headers: headers };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                if (res.statusCode >= 400) reject(new Error(`Status Code: ${res.statusCode}`));
                else {
                    try { resolve(JSON.parse(data)); } catch (e) { reject(e); }
                }
            });
        });
        req.on('error', reject);
        req.end();
    });
}

async function search() {
    const GOOGLE_KEY = process.env.GOOGLE_API_KEY;
    const GOOGLE_CX = process.env.GOOGLE_CSE_ID;
    const BRAVE_KEY = process.env.BRAVE_API_KEY;

    // --- STRATEGY A: Google Custom Search ---
    if (GOOGLE_KEY && GOOGLE_CX) {
        try {
            console.error(`[Search-Primary] 🔍 Googling: "${query}"`);
            const googleUrl = `https://www.googleapis.com/customsearch/v1?key=${GOOGLE_KEY}&cx=${GOOGLE_CX}&q=${encodeURIComponent(query)}`;
            const data = await fetchJson(googleUrl);

            if (!data.items || data.items.length === 0) throw new Error('No results');

            const results = data.items.slice(0, 5).map(item => ({
                title: item.title,
                link: item.link,
                snippet: item.snippet,
                source: 'Google'
            }));

            console.log(JSON.stringify(results, null, 2));
            return;
        } catch (err) {
            console.error(`[Search-Primary] ⚠️ Failed (${err.message}). Switching to Backup...`);
        }
    }

    // --- STRATEGY B: Brave Search API ---
    if (BRAVE_KEY) {
        try {
            console.error(`[Search-Backup] 🛡️ Activating Brave for: "${query}"`);
            const braveUrl = `https://api.search.brave.com/res/v1/web/search?q=${encodeURIComponent(query)}&count=5`;
            const data = await fetchJson(braveUrl, {
                'Accept': 'application/json',
                'X-Subscription-Token': BRAVE_KEY
            });

            const results = (data.web?.results || []).map(item => ({
                title: item.title,
                link: item.url,
                snippet: item.description,
                source: 'Brave'
            }));

            console.log(JSON.stringify(results, null, 2));
            return;
        } catch (err) {
            console.error(`[Search-Backup] ❌ Failed: ${err.message}`);
        }
    }

    console.log(JSON.stringify({ error: "All search engines failed." }));
}

search();