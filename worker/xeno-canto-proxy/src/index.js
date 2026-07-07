// Proxy minimale per xeno-canto API v3.
// L'app chiama  /api/xc?query=<...>  e il Worker inoltra a xeno-canto
// aggiungendo la API key (secret XC_KEY), mai esposta al client.
// Dati pubblici/CC → cache all'edge (gentile con xeno-canto) + CORS aperto.

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // Ramo FEEDBACK: Database Webhook Supabase (INSERT su `feedback`) → invia
    // l'email di notifica via Resend. Solo server-to-server, protetto da secret.
    if (url.pathname.startsWith("/api/feedback-mail")) {
      return feedbackMail(request, env);
    }

    // Ramo GBIF: /api/gbif?... → proxa la occurrence search (stessa query
    // string) aggiungendo CORS. Evita i 403/CORS lato browser (Uccelli in zona).
    if (url.pathname.startsWith("/api/gbif")) return proxyGbif(url);

    // Ramo AUDIO: /api/xc?audio=<xcId> → streama il file da xeno-canto SENZA
    // Content-Disposition (così il web lo riproduce inline) e same-origin.
    const audio = url.searchParams.get("audio");
    if (audio) return proxyAudio(audio, request);

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

// Streama l'audio della registrazione (xeno-canto /<id>/download) rimuovendo
// il Content-Disposition: attachment, che sul web impedisce la riproduzione
// inline. Passa attraverso il Range (seek) e cacha all'edge.
async function proxyAudio(id, request) {
  if (!/^\d+$/.test(id)) return json({ error: "bad id" }, 400);
  const range = request.headers.get("Range");
  let upstream;
  try {
    upstream = await fetch(`https://xeno-canto.org/${id}/download`, {
      headers: {
        "User-Agent": "MonkeyBirdie/1.0 (birdwatching; non-commercial)",
        ...(range ? { Range: range } : {}),
      },
      cf: { cacheTtl: 604800, cacheEverything: true },
    });
  } catch (_) {
    return json({ error: "upstream_unreachable" }, 502);
  }

  const headers = new Headers();
  headers.set("content-type", upstream.headers.get("content-type") || "audio/mpeg");
  headers.set("access-control-allow-origin", "*");
  headers.set("cache-control", "public, max-age=604800");
  for (const h of ["accept-ranges", "content-range", "content-length"]) {
    const v = upstream.headers.get(h);
    if (v) headers.set(h, v);
  }
  // NIENTE content-disposition → riproduzione inline nel browser.
  return new Response(upstream.body, { status: upstream.status, headers });
}

// Proxy della occurrence search GBIF (stessa query string dell'app), con CORS
// e cache edge 1h. GBIF vede l'IP dell'edge Cloudflare, niente 403 dal browser.
async function proxyGbif(url) {
  const target = "https://api.gbif.org/v1/occurrence/search" + url.search;
  let resp;
  try {
    resp = await fetch(target, {
      headers: {
        "User-Agent": "MonkeyBirdie/1.0 (birdwatching; non-commercial)",
        Accept: "application/json",
      },
      cf: { cacheTtl: 3600, cacheEverything: true },
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
      "cache-control": "public, max-age=3600",
    },
  });
}

// Notifica email dei feedback. Riceve il payload del Database Webhook Supabase
// (INSERT su `feedback`) e invia un'email via Resend. Protetto da un secret
// (header Authorization: Bearer <FEEDBACK_HOOK_SECRET>) così nessuno può spammare.
const _DEST_FEEDBACK = "beneficogianni@gmail.com";
const _MITTENTE_FEEDBACK = "MonkeyBirdie <no-reply@monkeybirdie.com>";

async function feedbackMail(request, env) {
  if (request.method !== "POST") return json({ error: "method" }, 405);
  const atteso = `Bearer ${env.FEEDBACK_HOOK_SECRET || ""}`;
  if (!env.FEEDBACK_HOOK_SECRET || request.headers.get("authorization") !== atteso) {
    return json({ error: "unauthorized" }, 401);
  }
  if (!env.RESEND_API_KEY) return json({ error: "server not configured" }, 500);

  let record;
  try {
    const body = await request.json();
    record = body.record || body; // supporta payload webhook o riga diretta
  } catch (_) {
    return json({ error: "bad payload" }, 400);
  }

  const tipo = esc(record.tipo || "altro");
  const testo = [
    `Tipo: ${record.tipo || "altro"}`,
    `Messaggio: ${record.messaggio || ""}`,
    `Versione app: ${record.versione_app || "-"}`,
    `Piattaforma: ${record.piattaforma || "-"}`,
    `Utente: ${record.utente_id || "-"}`,
    `Data: ${record.creato_il || ""}`,
  ].join("\n");
  const html = `<h2>Nuovo feedback: ${tipo}</h2><pre style="font:14px/1.5 monospace;white-space:pre-wrap">${esc(testo)}</pre>`;

  let resp;
  try {
    resp = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.RESEND_API_KEY}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        from: _MITTENTE_FEEDBACK,
        to: [_DEST_FEEDBACK],
        subject: `[MonkeyBirdie] Nuovo ${record.tipo || "feedback"}`,
        text: testo,
        html,
      }),
    });
  } catch (_) {
    return json({ error: "resend_unreachable" }, 502);
  }
  return json({ ok: resp.ok }, resp.ok ? 200 : 502);
}

function esc(s) {
  return String(s)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function json(obj, status) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: {
      "content-type": "application/json",
      "access-control-allow-origin": "*",
    },
  });
}
