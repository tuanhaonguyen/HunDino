"""Temporary loopback-only source bridge; no persistent account access."""
from http.server import SimpleHTTPRequestHandler,ThreadingHTTPServer
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parent.parent/'assets/inventory-crafting'
class Handler(SimpleHTTPRequestHandler):
 def __init__(self,*args,**kwargs):super().__init__(*args,directory=str(ROOT),**kwargs)
 def log_message(self,*args):pass
 def do_POST(self):
  if self.client_address[0]!='127.0.0.1' or self.path!='/qa-report':self.send_error(403);return
  size=int(self.headers.get('Content-Length','0'))
  if not 0<size<2_000_000:self.send_error(400);return
  (ROOT/'studio-play.json').write_text(json.dumps(json.loads(self.rfile.read(size)),ensure_ascii=False,indent=2),encoding='utf-8')
  self.send_response(200);self.end_headers();self.wfile.write(b'OK')
ThreadingHTTPServer(('127.0.0.1',18769),Handler).serve_forever()
