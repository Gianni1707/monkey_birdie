# Proxy xeno-canto (Cloudflare Worker)

Nasconde la API key di xeno-canto (v3) e serve le ricerche su
`https://monkeybirdie.com/api/xc?query=<...>`. L'app non vede mai la key.

## Deploy (una volta)

```bash
cd worker/xeno-canto-proxy
npx wrangler secret put XC_KEY      # incolla la tua API key xeno-canto (account)
npx wrangler deploy
```

- La key vive come **secret** del Worker: NON è nel repo né nel client.
- Il Worker gira solo sul path `/api/xc*` del dominio; Pages serve tutto il resto.
- La risposta è cachata all'edge 24h (gentile con xeno-canto).

Per aggiornarlo in futuro: modifica `src/index.js` e rilancia `npx wrangler deploy`.
