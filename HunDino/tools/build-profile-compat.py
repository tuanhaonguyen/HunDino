"""Restore the established HelloHunDino patch on the current merchant/mining branch."""
import ast
import json
from pathlib import Path

root = Path(__file__).resolve().parent.parent
helper = root / 'tools/prepare-hello-code.py'
parsed = ast.parse(helper.read_text(encoding='utf-8-sig'))
# Reuse only the deterministic text patch functions; do not execute old installers.
functions = ast.Module(body=[n for n in parsed.body if isinstance(n, ast.FunctionDef)
                            and n.name in {'once', 'rules', 'policy', 'service'}], type_ignores=[])
scope = {}
exec(compile(functions, str(helper), 'exec'), scope)
patchers = {'HuntEconomyRules': scope['rules'], 'AdminRedeemPolicy': scope['policy'],
            'HuntEconomyService': scope['service']}
rows = json.loads((root/'backups/profile-compat-20261027/sources.json').read_text(encoding='utf-8'))
plan = []
for row in rows:
    patched = patchers[row['Name']](row['Source'])
    path = 'assets/profile-compat/' + row['Name'] + '.luau'
    (root/path).write_text(patched, encoding='utf-8')
    plan.append({'Path': row['Path'], 'File': path, 'Source': patched, 'Baseline': row['Source']})
(root/'assets/profile-compat/install.json').write_text(json.dumps(plan, ensure_ascii=False, indent=2), encoding='utf-8')
print('Prepared three minimal HelloHunDino changes on the native merchant/mining branch')
