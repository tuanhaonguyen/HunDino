"""Patch only redemption source text; never serialize a Roblox place."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
def read(path):
    return (ROOT / path).read_text(encoding='utf-8-sig')
def write(path, text):
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding='utf-8')
def once(source, old, new):
    assert source.count(old) == 1, old
    return source.replace(old, new, 1)

def rules(source):
    helper = '''-- Legacy material codes and consumable codes share the permanent claim ledger.
local function validGrantRewards(materials, consumables)
\tif materials == nil and consumables == nil then return false end
\tfor _, group in {{Value=materials, Keys=Materials}, {Value=consumables, Keys=Items}} do
\t\tif group.Value ~= nil then
\t\t\tif not counts(group.Value, group.Keys) then return false end
\t\t\tfor key, quantity in group.Value do
\t\t\t\tif not table.find(group.Keys, key) or quantity == 0 then return false end
\t\t\tend
\t\tend
\tend
\treturn true
end

'''
    source = once(source, 'local function validProfile(profile)', helper + 'local function validProfile(profile)')
    source = once(source, '''or not counts(receipt.Materials, Materials) then return false end
\t\tfor material, quantity in receipt.Materials do
\t\t\tif not table.find(Materials, material) or quantity == 0 then return false end
\t\tend''', 'or not validGrantRewards(receipt.Materials, receipt.Consumables) then return false end')
    source = once(source, 'Coins=true,Materials=true,RedeemedAt=true', 'Coins=true,Materials=true,Consumables=true,RedeemedAt=true')
    source = once(source, '''or not counts(request.Materials, Materials) then return rejected("InvalidGrant") end
\t\tfor material, quantity in request.Materials do
\t\t\tif not table.find(Materials, material) or quantity == 0 then return rejected("InvalidGrant") end
\t\tend''', 'or not validGrantRewards(request.Materials, request.Consumables) then return rejected("InvalidGrant") end')
    source = once(source, '''for _, material in Materials do
\t\t\tif not add(nextProfile.Materials, material, request.Materials[material]) then return rejected("Capacity") end
\t\tend
\t\tlocal receipt = accepted("CodeRedeemed", {CodeId=request.CodeId, Coins=request.Coins,
\t\t\tMaterials=clone(request.Materials), RedeemedAt=request.RedeemedAt})''', '''for material, quantity in request.Materials or {} do
\t\t\tif not add(nextProfile.Materials, material, quantity) then return rejected("Capacity") end
\t\tend
\t\tfor item, quantity in request.Consumables or {} do
\t\t\tif not add(nextProfile.StoredConsumables, item, quantity) then return rejected("Capacity") end
\t\tend
\t\tlocal receipt = accepted("CodeRedeemed", {CodeId=request.CodeId, Coins=request.Coins,
\t\t\tMaterials=clone(request.Materials), Consumables=clone(request.Consumables), RedeemedAt=request.RedeemedAt})''')
    return source

def policy(source):
    source = once(source, '-- Server-only test grant. Eligibility never comes from a client attribute.', '-- Server-owned public and admin rewards. Clients submit only a code string.')
    source = once(source, '''\tif userId ~= USER_ID then return nil, "NotEligible" end
\tif type(rawCode) ~= "string" or #rawCode > 64 then return nil, "InvalidCode" end
\tlocal code = rawCode:match("^%s*(.-)%s*$"):upper()''', '''\tif type(rawCode) ~= "string" or #rawCode > 64 then return nil, "InvalidCode" end
\tlocal code = rawCode:match("^%s*(.-)%s*$"):upper()
\tif code == "HELLOHUNDINO" then
\t\treturn {Op="RedeemCode", CodeId="HelloHunDino", Coins=50,
\t\t\tConsumables={RawTrap=2, IronTrap=2, SleepPotion=2}}
\tend
\tif userId ~= USER_ID then return nil, "NotEligible" end''')
    source = once(source, '\tif userId ~= USER_ID then return nil, "NotEligible" end\n\tif code ~= CODE then return nil, "InvalidCode" end', '\tif code ~= CODE then return nil, "InvalidCode" end\n\tif userId ~= USER_ID then return nil, "NotEligible" end')
    return source

def service(source):
    old = 'local message = "Đã nhận 500 xu và 10 mỗi loại: da, răng, vảy, xương, sắt. Đã lưu vào tài khoản."'
    local_old = '''local destination=if self.Persistence.Mode=="LocalFile" then "trên máy" else "vào tài khoản"
\t\tlocal message = "Đã nhận 500 xu và 10 mỗi loại: da, răng, vảy, xương, sắt. Đã lưu "..destination.."."'''
    new = '''local destination=if self.Persistence.Mode=="LocalFile" then "trên máy" else "vào tài khoản"
\t\tlocal reward=if request.CodeId=="HelloHunDino" then "50 xu, 2 bẫy thô, 2 bẫy sắt và 2 thuốc ngủ" else "500 xu và 10 mỗi loại: da, răng, vảy, xương, sắt"
\t\tlocal message = "Đã nhận "..reward..". Đã lưu "..destination.."."'''
    return once(source, local_old if local_old in source else old, new)

patchers = {'HuntEconomyRules': rules, 'AdminRedeemPolicy': policy, 'HuntEconomyService': service}
originals = json.loads(read('backups/hello-code-20261022/studio-sources.json'))
plan = []
for row in originals:
    name = row['Path'].split('.')[-1]
    if name not in patchers:
        continue
    patched = patchers[name](row['Source'])
    path = 'assets/redeem/hello-code/' + name + '.luau'
    write(path, patched)
    plan.append({'Path': row['Path'], 'File': path, 'Source': patched, 'Baseline': row['Source']})
    for local in ['src/hunting/' + name + '.luau', 'assets/data/ServerScriptService__HuntingRuntime__' + name + '.luau']:
        if (ROOT / local).exists():
            write('backups/hello-code-20261022/' + local.replace('/', '__'), read(local))
            write(local, patchers[name](read(local)))
write('assets/redeem/hello-code/install.json', json.dumps(plan, ensure_ascii=False, indent=2))
print('Prepared 3 source changes from Studio with backups; local source copies updated.')
