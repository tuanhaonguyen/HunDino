from pathlib import Path
root=Path(__file__).resolve().parent.parent
source=(root/'tools/qa/admin-redeem.server.luau').read_text(encoding='utf-8')
source=source.replace('11605296816, "HUNDINO-ADMIN-500", "AdminTest20261021"','987654321, "HelloHunDino", "HelloHunDino"')
source=source.replace('{"Skin", "Tooth", "Scale", "Bone", "Iron"}','{"RawTrap", "IronTrap", "SleepPotion"}')
source=source.replace('.Materials[material]', '.StoredConsumables[material]')
source=source.replace('== 580','== 130').replace(', 580, 10)', ', 130, 2)').replace('== 10, "Successful reply','== 2, "Successful reply')
source=source.replace('check(not response.Ok and response.Code == "NotEligible", "Only configured admin is eligible")',
 'check(response.Ok and response.Code == "CodeRedeemed", "Public code is available to another ordinary account")')
source=source.replace('check(wrong.Backend.Writes == writes and #wrong.Adapter.Publications == 0, "Denied identity makes no reward write or publication")',
 'check(wrong.Backend.Writes == writes+1 and #wrong.Adapter.Publications == 1, "Other account receives one independent saved reward")')
source=source.replace('Server rejects other accounts and malformed client payloads','Public code accepts ordinary accounts and rejects malformed payloads')
source=source.replace('local live', 'local live')
(root/'tools/qa/hello-code.server.luau').write_text(source,encoding='utf-8')
print('Prepared isolated Studio service QA for public code.')
