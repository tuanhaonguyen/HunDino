from pathlib import Path
import importlib.util
import json
ROOT=Path(__file__).resolve().parent.parent
spec=importlib.util.spec_from_file_location('patches',ROOT/'tools/prepare-merchant-weapons.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
rows=json.loads((ROOT/'backups/merchant-weapons-20261026/saved-sources.json').read_text(encoding='utf-8'))
patches={
 'ReplicatedStorage.Shared.HubUI':('src/dark-jungle/HubUI.luau',m.hub),
 'ReplicatedStorage.Shared.EquipmentInventory':('src/dark-jungle/EquipmentInventory.luau',m.inventory),
 'ServerScriptService.HuntingRuntime.HuntEconomyRules':('src/hunting/HuntEconomyRules.luau',m.rules),
 'ServerScriptService.HuntingRuntime.HuntEconomyService':('src/hunting/HuntEconomyService.luau',m.service),
 'StarterPlayer.StarterPlayerScripts.HunDinoEconomy':('src/hunting/HuntEconomy.client.luau',m.client),
 'StarterPlayer.StarterPlayerScripts.HunDinoProfileStatus':('src/data/ProfileStatus.client.luau',lambda s:(ROOT/'src/data/ProfileStatus.client.luau').read_text(encoding='utf-8-sig')),
}
folder=ROOT/'assets/merchant-weapons';folder.mkdir(exist_ok=True)
plan=[]
for row in rows:
 if row['Path'] not in patches:continue
 canonical,patch=patches[row['Path']]
 source=patch(row['Source'])
 file='assets/merchant-weapons/'+row['Path']+'.luau'
 (ROOT/file).write_text(source,encoding='utf-8')
 plan.append(dict(Path=row['Path'],File=file,Source=source,Baseline=row['Source']))
assert len(plan)==6
(folder/'install.json').write_text(json.dumps(plan,ensure_ascii=False),encoding='utf-8')
print('Prepared six native-preserving script replacements; training hook applies to current source at installation')
