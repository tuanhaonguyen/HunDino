-- Read-only verification: no place serialization and no Terrain reconstruction.
local fs=require('@lune/fs')
local r=require('@lune/roblox')
local serde=require('@lune/serde')
local luau=require('@lune/luau')
local args=require('@lune/process').args
local beforePath=args[1] or 'backups/merchant-weapons-20261026/HunDino_SaveGame.rbxl'
local afterPath=args[2] or 'HunDino_MerchantWeapons_20261026.rbxl'
local before=r.deserializePlace(fs.readFile(beforePath))
local after=r.deserializePlace(fs.readFile(afterPath))
local checks,scripts=0,0
local function check(v,m) checks+=1;assert(v,m) end
local function path(o)
 local names={}
 while o and not o:IsA('DataModel') do table.insert(names,1,o.Name);o=o.Parent end
 return table.concat(names,'.')
end
local function at(root,p) for name in p:gmatch('[^.]+') do root=root and root:FindFirstChild(name) end return root end
local function norm(s) return s:gsub('\r\n','\n'):gsub('%s+$','') end
local allowed={['ServerScriptService.HunDinoTraining']=true}
for _,row in serde.decode('json',fs.readFile('assets/merchant-weapons/install.json')) do
 check(norm(at(after,row.Path).Source)==norm(row.Source),'Installed source differs: '..row.Path)
 allowed[row.Path]=true
end
local backupPrefix='ServerStorage.MerchantWeaponsBackup_20261026.'
local oldScripts={}
for _,o in before:GetDescendants() do
 if o:IsA('LuaSourceContainer') and not allowed[path(o)] then
  local signature=path(o)..'|'..serde.hash('sha256',norm(o.Source))
  oldScripts[signature]=(oldScripts[signature] or 0)+1
 end
end
for _,o in after:GetDescendants() do
 if o:IsA('LuaSourceContainer') then
  scripts+=1;check(pcall(luau.compile,o.Source),'Compile: '..path(o))
  local p=path(o)
  if p:sub(1,#backupPrefix)~=backupPrefix and not allowed[p] then
   local signature=p..'|'..serde.hash('sha256',norm(o.Source))
   check((oldScripts[signature] or 0)>0,'Unrelated source changed: '..p)
   oldScripts[signature]-=1
  end
 end
end
for signature,count in oldScripts do check(count==0,'Unrelated script removed: '..signature) end
for p in allowed do
 local original=at(before,p)
 local backup=at(after,backupPrefix..p:gsub('%.','__'))
 check(backup and norm(backup.Source)==norm(original.Source),'Backup differs: '..p)
end
local training=at(after,'ServerScriptService.HunDinoTraining').Source
check(training:find('economy:DamageMultiplier(s.Player,s.WeaponId)',1,true)~=nil,'Combat did not use selected weapon level')
check(not training:find('s.WeaponId=="Hammer" and economy',1,true),'Hammer-only multiplier still present')
local data=at(after,'ServerScriptService.AccountData')
check(data:GetAttribute('StudioMemoryTest')~=true,'Disposable QA override remained enabled')
check(not at(after,'ServerScriptService.MerchantQA'),'QA driver saved into release')
local status=at(after,'StarterPlayer.StarterPlayerScripts.HunDinoProfileStatus').Source
check(not status:find('strip.Name="SaveStatus"',1,true),'Persistent save HUD still created')
local function scene(root)
 local rows,counts={},{}
 for _,o in root:GetService('Workspace'):GetDescendants() do
  counts[o.ClassName]=(counts[o.ClassName] or 0)+1
  local fields={path(o),o.ClassName}
  if o:IsA('BasePart') and not o:IsA('Terrain') then
   for _,prop in {'CFrame','Size','Color','Material','Transparency','Anchored','CanCollide','CanTouch','CanQuery'} do table.insert(fields,prop..'='..tostring(o[prop])) end
  elseif o:IsA('JointInstance') then
   for _,prop in {'C0','C1'} do table.insert(fields,prop..'='..tostring(o[prop])) end
   for _,prop in {'Part0','Part1'} do table.insert(fields,prop..'='..(o[prop] and path(o[prop]) or 'nil')) end
  end
  table.insert(rows,table.concat(fields,'|'))
 end
 table.sort(rows);return serde.hash('sha256',table.concat(rows,'\n')),counts
end
local hash,counts=scene(after);local oldHash,oldCounts=scene(before)
check(hash==oldHash,'Workspace instance/part/joint fingerprint changed')
for name,count in oldCounts do check(counts[name]==count,'Workspace class count changed: '..name) end
local reflected=r.getReflectionDatabase()
local compared=0
local oldTerrain=before:GetService('Workspace'):FindFirstChildOfClass('Terrain')
local terrain=after:GetService('Workspace'):FindFirstChildOfClass('Terrain')
check(oldTerrain and terrain,'Terrain missing')
local class=reflected:GetClass('Terrain');local seen={}
while class do
 for name in class.Properties do
  if not seen[name] and name~='Parent' and name~='HistoryId' and name~='UniqueId' then
   seen[name]=true
   local ok,a=pcall(function() return oldTerrain[name] end)
   local ok2,b=pcall(function() return terrain[name] end)
   if ok and ok2 then compared+=1;check(tostring(a)==tostring(b),'Terrain changed: '..name) end
  end
 end
 class=class.Superclass and reflected:GetClass(class.Superclass) or nil
end
local report={Checks=checks,ScriptsCompiled=scripts,SceneHash=hash,WorkspaceCounts=counts,
 TerrainPropertiesCompared=compared,TerrainUnreadableProperty='VoxelGridAssetContentMap (unsupported by Lune; saved only through native Studio)',
 Before=beforePath,After=afterPath,Bytes=#fs.readFile(afterPath),SHA256=serde.hash('sha256',fs.readFile(afterPath))}
fs.writeFile('assets/merchant-weapons/saved-inspection.json',serde.encode('json',report,true))
print(serde.encode('json',report,true))
