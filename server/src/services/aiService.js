const fetch = require('node-fetch'); // optional, used only if integrating an external API
const GroceryItem = require('../models/GroceryItem');

/**
 * suggestGroceries(user, recentContext)
 * - user: mongoose user doc
 * - recentContext: optional object { tasks: [...], events: [...] } to provide hints
 *
 * Returns an array of suggested item names.
 */
const DEFAULT_SUGGESTIONS = ['Milk', 'Eggs', 'Bread', 'Coffee', 'Bananas'];

async function suggestGroceries(user, recentContext = {}) {
  // If configured to use OpenAI (or other provider), call it here.
  if (process.env.USE_OPENAI === 'true' && process.env.OPENAI_API_KEY) {
    // Placeholder: show how to integrate but we do not include a hard dependency.
    // You can replace this with an official OpenAI client call.
    const prompt = `You are a helpful grocery assistant. Based on user history ${JSON.stringify(user.groceryHistory || [])} and context ${JSON.stringify(recentContext)}, suggest 6 common grocery items as a JSON array of strings.`;
    try {
      // Example fetch to an OpenAI-like endpoint (replace with real SDK)
      const resp = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          messages: [{ role: 'system', content: prompt }],
          max_tokens: 120
        })
      });
      const data = await resp.json();
      // parse text to array defensively
      const text = data?.choices?.[0]?.message?.content || '';
      const parsed = extractArrayFromText(text);
      if (parsed.length) return parsed;
    } catch (err) {
      console.warn('AI provider call failed, falling back to heuristics', err?.message || err);
    }
  }

  // Heuristic approach:
  const history = Array.isArray(user.groceryHistory) ? user.groceryHistory.slice().reverse() : [];
  const freq = {};
  history.forEach((name) => {
    const key = name.trim().toLowerCase();
    if (!key) return;
    freq[key] = (freq[key] || 0) + 1;
  });

  // sort by frequency, merge with default suggestions
  const ranked = Object.keys(freq).sort((a, b) => freq[b] - freq[a]);
  const output = [];
  for (const k of ranked) {
    output.push(capitalize(k));
    if (output.length >= 6) break;
  }
  for (const d of DEFAULT_SUGGESTIONS) {
    if (output.length >= 6) break;
    if (!output.includes(d)) output.push(d);
  }
  return output;
}

function capitalize(s) {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

function extractArrayFromText(text) {
  try {
    // Try to find a JSON array inside text
    const m = text.match(/\[.*\]/s);
    if (m) {
      const arr = JSON.parse(m[0]);
      if (Array.isArray(arr)) return arr.map(String);
    }
    // fallback: split lines and commas
    return text.split(/[\n,]+/).map(s => s.trim()).filter(Boolean).slice(0,6);
  } catch (e) {
    return [];
  }
}

module.exports = { suggestGroceries };
