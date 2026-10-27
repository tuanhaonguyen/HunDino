"""Prepare a placement-only update. Studio moves existing geometry and saves it."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/'assets/base-clearance'
BACKUP=ROOT/'backups/base-clearance-20261027'
def once(s,old,new):
 assert s.count(old)==1,(old[:100],s.count(old))
 return s.replace(old,new,1)
def patch(s,rows):
 s=once(s,'Version = "BioTubeGeometry.4"','Version = "BioTubeGeometry.5"')
 start=s.index('Geometry.ClusterLayout = {')
 end=s.index('\nlocal C = {',start)
 layouts=[]
 for row in rows:
  assert not row.get('Error'),row
  x,z,yaw=row['ShiftX'],row['Distance'],row['YawDegrees']
  if abs(x-round(x))<.001:x=round(x)
  if abs(z-round(z))<.001:z=round(z)
  if abs(yaw-round(yaw))<.002:yaw=round(yaw)
  layouts.append(f'\t[{row["Id"]}] = {{Distance = {z:.8g}, ShiftX = {x:.8g}, YawDegrees = {yaw:.8g}}},')
 s=s[:start]+'Geometry.LayoutVersion = "TransitClearance.1"\nGeometry.ClusterLayout = {\n'+'\n'.join(layouts)+'\n}\n'+s[end:]
 s=once(s,'* CFrame.new(layout.ShiftX, 0, layout.Distance)','* CFrame.new(layout.ShiftX, 0, layout.Distance)\n\t\t* CFrame.Angles(0, math.rad(layout.YawDegrees or 0), 0)')
 s=s.replace('-- Leave the inherited shelter, transit and crafting furniture untouched.\n-- The three small lateral exceptions avoid their pre-existing boulders.',
  '-- Native-surveyed placement keeps existing buildings, transit pads and crafting\n-- furniture untouched. Every base retains an open arrival-to-spawn/camp corridor.\n-- Base 11 keeps its previously authored safe placement, now reproducible in code.')
 return s
plan=json.loads((OUT/'plan.json').read_text(encoding='utf-8'))
rows=plan['Bases']
assert len(rows)==12 and all('Frame' in row for row in rows)
originals=json.loads((OUT/'native-sources.json').read_text(encoding='utf-8'))
original=next(row for row in originals if row['Path'].endswith('BioTubeGeometry'))
source=patch(original['Source'],rows)
canonical=ROOT/'src/hunting/BioTubeGeometry.luau'
backup=BACKUP/'BioTubeGeometry.luau'
assert not backup.exists(),'Preserve original backup; patch already prepared'
backup.write_text(canonical.read_text(encoding='utf-8-sig'),encoding='utf-8')
canonical.write_text(patch(canonical.read_text(encoding='utf-8-sig'),rows),encoding='utf-8')
(OUT/'BioTubeGeometry.luau').write_text(source,encoding='utf-8')
manifest=[dict(Path=original['Path'],File='assets/base-clearance/BioTubeGeometry.luau',Source=source,Before=original['Source'])]
(OUT/'install.json').write_text(json.dumps(manifest,ensure_ascii=False),encoding='utf-8')
(BACKUP/'native-sources.json').write_text(json.dumps(originals,ensure_ascii=False),encoding='utf-8')
print('Prepared twelve verified layouts; one module changes, no place serialization')
