export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // CORS
  const origin = req.headers.origin || '';
  const allowed = ['https://autobiz.digital', 'http://localhost:3000'];
  res.setHeader('Access-Control-Allow-Origin', allowed.includes(origin) ? origin : allowed[0]);
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-API-Key');

  if (req.method === 'OPTIONS') return res.status(200).end();

  // Key from header (never in URL)
  const apiKey = req.headers['x-api-key'];
  if (!apiKey || !apiKey.startsWith('AIza')) {
    return res.status(401).json({ error: 'Missing or invalid API key' });
  }

  try {
    const body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
    const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`;

    const resp = await fetch(apiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(20000),
    });

    const data = await resp.json();
    res.status(resp.status).json(data);
  } catch (e) {
    res.status(502).json({ error: 'Gemini API request failed' });
  }
}
