#!/usr/bin/env python3
"""Server statico "silenzioso" per servire build/web durante i test.

A differenza di `python3 -m http.server`, ignora gli errori di connessione
interrotta dal client (ConnectionResetError / BrokenPipeError) — tipici quando
il telefono annulla il download del modello attraverso un tunnel — quindi il
terminale resta pulito.

Uso:
    python3 tool/serve_web.py [porta] [cartella]
    python3 tool/serve_web.py 8080 build/web
"""
import http.server
import socketserver
import sys

port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
directory = sys.argv[2] if len(sys.argv) > 2 else "."


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=directory, **kwargs)

    # Silenzia il log di default per le connessioni interrotte.
    def handle_one_request(self):
        try:
            super().handle_one_request()
        except (ConnectionResetError, BrokenPipeError):
            self.close_connection = True


class QuietServer(socketserver.ThreadingTCPServer):
    daemon_threads = True
    allow_reuse_address = True

    def handle_error(self, request, client_address):
        exc = sys.exc_info()[1]
        if isinstance(exc, (ConnectionResetError, BrokenPipeError)):
            return  # rumore: il client ha chiuso, non ci interessa
        super().handle_error(request, client_address)


with QuietServer(("0.0.0.0", port), Handler) as httpd:
    print(f"Servo '{directory}' su http://0.0.0.0:{port}  (Ctrl+C per fermare)")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nFermato.")
