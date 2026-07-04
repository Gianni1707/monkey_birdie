#!/usr/bin/env python3
"""Server statico minimale per lo spike foto.
Il modello immagine gira in WASM single-thread: NON servono COOP/COEP (a differenza
del primo spike audio tfjs-tflite). Un http.server qualsiasi basta.

    python3 serve.py 8080
Poi apri http://localhost:8080 (laptop) o http://IP-DEL-LAPTOP:8080 (telefono, stessa Wi-Fi).
Per iPhone Safari con getUserMedia/camera serve HTTPS: usa un tunnel (cloudflared) sull'URL.
"""
import http.server
import socketserver
import sys

port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080


class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        '.tflite': 'application/octet-stream',
        '.wasm': 'application/wasm',
    }

    def end_headers(self):
        # niente cache: durante lo spike vogliamo sempre l'ultima versione dei file
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

    def log_message(self, *_):  # silenzioso
        pass


with socketserver.TCPServer(('', port), Handler) as httpd:
    print(f'Spike foto su http://localhost:{port}  (Ctrl-C per uscire)')
    httpd.serve_forever()
