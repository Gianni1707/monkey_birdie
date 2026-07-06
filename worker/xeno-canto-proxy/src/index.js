// Proxy minimale per xeno-canto API v3.
// L'app chiama  /api/xc?query=<...>  e il Worker inoltra a xeno-canto
// aggiungendo la API key (secret XC_KEY), mai esposta al client.
// Dati pubblici/CC → cache all'edge (gentile con xeno-canto) + CORS aperto.

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const query = url.searchParams.get("query");
    if (!query) return json({ error: "missing query" }, 400);
    if (!env.XC_KEY) return json({ error: "server not configured" }, 500);

    const target = new URL("https://xeno-canto.org/api/3/recordings");
    target.searchParams.set("query", query);
    target.searchParams.set("key", env.XC_KEY);
    const page = url.searchParams.get("page");
    if (page) target.searchParams.set("page", page);

    let resp;
    try {
      resp = await fetch(target.toString(), {
        headers: {
          "User-Agent": "MonkeyBirdie/1.0 (birdwatching; non-commercial)",
        },
        cf: { cacheTtl: 86400, cacheEverything: true },
      });
    } catch (_) {
      return json({ error: "upstream_unreachable" }, 502);
    }

    const body = await resp.text();
    return new Response(body, {
      status: resp.status,
      headers: {
        "content-type": "application/json; charset=utf-8",
        "access-control-allow-origin": "*",
        "cache-control": "public, max-age=86400",
      },
    });
  },
};

function json(obj, status) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: {
      "content-type": "application/json",
      "access-control-allow-origin": "*",
    },
  });
}
