#!/usr/bin/env python3
"""Server statico per lo spike, con header COOP/COEP per la cross-origin
isolation (abilita i thread WASM di tfjs-tflite).

Uso:
    python3 serve.py [porta]        # default 8765, COOP/COEP ATTIVI

Note:
 - I thread WASM richiedono un *secure context*: funziona su http://localhost
   (laptop) ma NON su http://IP-LAN (telefono). Per il test multi-thread su
   mobile serve HTTPS (es. un tunnel come cloudflared/ngrok).
 - Con COEP=require-corp gli script CDN potrebbero essere bloccati (manca CORP):
   se succede, usa la modalità senza isolation (qualsiasi server statico, anche
   `python3 -m http.server`) per validare correttezza+latenza single-thread,
   oppure self-hosta tf.min.js / tf-tflite.min.js. Vedi README.
"""
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "cross-origin")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


def main() -> None:
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    with ThreadingHTTPServer(("0.0.0.0", port), Handler) as httpd:
        print(f"Spike server su http://localhost:{port}  (COOP/COEP attivi)")
        print("Ctrl+C per fermare.")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
