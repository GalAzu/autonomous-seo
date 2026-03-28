export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const origin = req.headers.origin || '';
  const allowed = ['https://autobiz.digital', 'http://localhost:3000'];
  res.setHeader('Access-Control-Allow-Origin', allowed.includes(origin) ? origin : allowed[0]);
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'X-API-Key');
  res.setHeader('Cache-Control', 'public, max-age=600');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const apiKey = req.headers['x-api-key'];
  if (!apiKey || !apiKey.startsWith('AIza')) {
    return res.status(401).json({ error: 'Missing or invalid API key' });
  }

  const { url, strategy } = req.query;
  if (!url) {
    return res.status(400).json({ error: 'Missing url parameter' });
  }

  try {
    const apiUrl = `https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=${encodeURIComponent(url)}&key=${apiKey}&strategy=${strategy || 'mobile'}&category=performance`;

    const resp = await fetch(apiUrl, {
      signal: AbortSignal.timeout(30000),
    });

    const data = await resp.json();
    res.status(resp.status).json(data);
  } catch (e) {
    res.status(502).json({ error: 'PageSpeed API request failed' });
  }
}
