export default async function handler(req, res) {
  const { url } = req.query;

  if (!url) {
    return res.status(400).json({ error: 'Missing url parameter' });
  }

  let targetUrl;
  try {
    targetUrl = new URL(decodeURIComponent(url));
    if (!['http:', 'https:'].includes(targetUrl.protocol)) {
      return res.status(400).json({ error: 'Invalid protocol' });
    }
  } catch (e) {
    return res.status(400).json({ error: 'Invalid URL' });
  }

  // SSRF protection — block private/internal IPs
  const hostname = targetUrl.hostname;
  const blocked = [
    /^localhost$/i, /^127\./, /^10\./, /^172\.(1[6-9]|2\d|3[01])\./,
    /^192\.168\./, /^169\.254\./, /^0\./, /^\[::1\]$/, /^\[fc/i,
    /^\[fd/i, /^\[fe80/i, /^metadata\.google\.internal$/i,
  ];
  if (blocked.some(p => p.test(hostname))) {
    return res.status(403).json({ error: 'Blocked host' });
  }

  // Restrict CORS to our domain
  const origin = req.headers.origin || '';
  const allowedOrigins = ['https://autobiz.digital', 'https://autonomous-seo.vercel.app', 'http://localhost:3000'];
  res.setHeader('Access-Control-Allow-Origin', allowedOrigins.includes(origin) ? origin : allowedOrigins[0]);
  res.setHeader('Access-Control-Allow-Methods', 'GET');
  res.setHeader('Cache-Control', 'public, max-age=300');

  try {
    const response = await fetch(targetUrl.href, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; AutonomousSEO/1.0; +https://autonomous.co.il)',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9',
        'Accept-Language': 'he,en;q=0.9',
      },
      redirect: 'follow',
      signal: AbortSignal.timeout(15000),
    });

    // Only allow text/html/xml content
    const contentType = response.headers.get('content-type') || '';
    if (!contentType.includes('text/') && !contentType.includes('application/xhtml') && !contentType.includes('application/xml')) {
      return res.status(403).json({ error: 'Only HTML/XML content allowed' });
    }

    const text = await response.text();

    // Limit response size (5MB max)
    if (text.length > 5 * 1024 * 1024) {
      return res.status(413).json({ error: 'Response too large' });
    }

    // Force safe content type
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('X-Final-Url', response.url);
    res.status(response.status).send(text);
  } catch (e) {
    res.status(502).json({ error: 'Failed to fetch target URL' });
  }
}
