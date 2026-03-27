export default async function handler(req, res) {
  const { url } = req.query;

  if (!url) {
    return res.status(400).json({ error: 'Missing url parameter' });
  }

  // Validate URL
  let targetUrl;
  try {
    targetUrl = new URL(decodeURIComponent(url));
    if (!['http:', 'https:'].includes(targetUrl.protocol)) {
      return res.status(400).json({ error: 'Invalid protocol' });
    }
  } catch (e) {
    return res.status(400).json({ error: 'Invalid URL' });
  }

  // Rate limiting headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET');
  res.setHeader('Cache-Control', 'public, max-age=300');

  try {
    const response = await fetch(targetUrl.href, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; AutonomousSEO/1.0; +https://autonomous.co.il)',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'he,en;q=0.9',
      },
      redirect: 'follow',
      signal: AbortSignal.timeout(15000),
    });

    const contentType = response.headers.get('content-type') || '';
    const text = await response.text();

    res.setHeader('Content-Type', contentType || 'text/html');
    res.setHeader('X-Final-Url', response.url);
    res.status(response.status).send(text);
  } catch (e) {
    res.status(502).json({ error: 'Failed to fetch: ' + e.message });
  }
}
