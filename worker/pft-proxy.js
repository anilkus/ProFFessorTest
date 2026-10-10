// Cloudflare Worker: ProFFessorTest -> Anthropic API proxy.
// API anahtarı tarayıcıya hiç gitmez; Worker'a "ANTHROPIC_API_KEY" adlı secret olarak eklenir.
const ANTHROPIC_BASE = 'https://api.anthropic.com';
const ALLOWED_ORIGINS = ['https://anilkus.github.io', 'http://localhost', 'http://127.0.0.1'];
const ALLOWED_MODELS = ['claude-sonnet-4-6'];
const MAX_TOKENS = 4000;

function corsHeaders(origin) {
  return {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Vary': 'Origin',
  };
}

function originAllowed(origin) {
  return ALLOWED_ORIGINS.some(o => origin === o || origin.startsWith(o + ':'));
}

function json(status, obj, cors) {
  return new Response(JSON.stringify(obj), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
}

export default {
  async fetch(request, env) {
    const origin = request.headers.get('Origin') || '';
    if (!originAllowed(origin)) return new Response('Forbidden', { status: 403 });
    const cors = corsHeaders(origin);

    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });

    const url = new URL(request.url);
    if (request.method !== 'POST' || url.pathname !== '/v1/messages') {
      return json(404, { error: { message: 'Not found' } }, cors);
    }
    if (!env.ANTHROPIC_API_KEY) {
      return json(500, { error: { message: 'Worker ayarı eksik: ANTHROPIC_API_KEY secret tanımlı değil.' } }, cors);
    }

    let body;
    try { body = await request.json(); } catch (e) {
      return json(400, { error: { message: 'Geçersiz istek gövdesi.' } }, cors);
    }
    if (!ALLOWED_MODELS.includes(body.model)) {
      return json(400, { error: { message: 'İzin verilmeyen model: ' + body.model } }, cors);
    }
    body.max_tokens = Math.min(Number(body.max_tokens) || 1000, MAX_TOKENS);

    const res = await fetch(ANTHROPIC_BASE + '/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify(body),
    });
    const nh = new Headers(res.headers);
    for (const [k, v] of Object.entries(cors)) nh.set(k, v);
    return new Response(res.body, { status: res.status, headers: nh });
  },
};
