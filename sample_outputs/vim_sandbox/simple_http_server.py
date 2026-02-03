#!/usr/bin/env python3
# This file contains a simple HTTP server
# The server responds to all get requests with 200, "The server is here"
# The server sets the cookie "X-Listened-To" to the value "yes"

import http.server
import socketserver

PORT = 8000

class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.send_header("Set-Cookie", "X-Listened-To=yes")
        self.end_headers()
        self.wfile.write(b"The server is here")

with socketserver.TCPServer(("", PORT), MyHttpRequestHandler) as httpd:
    print("serving at port", PORT)
    httpd.serve_forever()
