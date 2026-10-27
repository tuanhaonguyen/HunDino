"""Temporary loopback source/report bridge, never accesses account storage."""
from http.server import SimpleHTTPRequestHandler,ThreadingHTTPServer
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parent.parent/'assets/base-clearance'
class Handler(SimpleHTTPRequestHandler):
 def __init__(self,*args,**kwargs):super().__init__(*args,directory=str(ROOT),**kwargs)
 def log_message(self,*args):pass
 def do_POST(self):
  names={'/plan':'plan.json','/survey':'survey.json','/qa':'studio-play.json','/native-sources':'native-sources.json'}
  if self.client_address[0]!='127.0.0.1' or self.path not in names:self.send_error(403);return
  length=int(self.headers.get('Content-Length','0'))
  if not 0<length<4_000_000:self.send_error(400);return
  value=json.loads(self.rfile.read(length))
  (ROOT/names[self.path]).write_text(json.dumps(value,ensure_ascii=False,indent=2),encoding='utf-8')
  self.send_response(200);self.end_headers();self.wfile.write(b'OK')
ThreadingHTTPServer(('127.0.0.1',18770),Handler).serve_forever()
