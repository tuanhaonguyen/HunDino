-- READ ONLY: no place serialization, including opaque native Terrain.
local fs=require('@lune/fs')
local r=require('@lune/roblox')
local luau=require('@lune/luau')
local serde=require('@lune/serde')
local process=require('@lune/process')
local target=process.args[1] or 'HunDino_SaveGame.rbxl'
local baseline=process.args[2] or 'backups/bow-pet-20261026/HunDino_SaveGame.rbxl'
local checks=0
local function check(ok,label)checks+=1;assert(ok,label)end
local function hash(s)return serde.hash('sha256',s)end
local function norm(s)return s:gsub('\r\n','\n'):gsub('%s+$','')end
local function at(root,path)for name in path:gmatch('[^.]+')do root=root and root:FindFirstChild(name)end;return root end
local function pathOf(o)local p={};while o and not o:IsA('DataModel')do table.insert(p,1,o.Name);o=o.Parent end;return table.concat(p,'.')end
local oldBytes,bytes=fs.readFile(baseline),fs.readFile(target)
local before,after=r.deserializePlace(oldBytes),r.deserializePlace(bytes)
local rows=serde.decode('json',fs.readFile(process.args[3] or 'assets/qa/bow-pet-install.json'))
local backupFolder=process.args[5] or 'BowPetBackup_20261026'
local allowed={}
for _,row in rows do
 allowed[row.Path]=true
 check(norm(assert(at(after,row.Path),'Missing binding '..row.Path).Source)==norm(fs.readFile(row.File)),'Binding mismatch '..row.Path)
 if row.Before then
  local backup=at(after,'ServerStorage.'..backupFolder..'.'..row.Path:gsub('%.','__'))
  check(backup and norm(backup.Source)==norm(row.Before),'Backup mismatch '..row.Path)
 end
end
local scripts=0
local function sourceRows(root,isAfter)
 local out={}
 for _,s in root:GetDescendants()do
  local path=pathOf(s)
  if s:IsA('LuaSourceContainer')then
   if isAfter then
    scripts+=1;check(pcall(luau.compile,s.Source),'Compile '..path)
    check(not s.Source:find('BowPetQAProbe',1,true),'QA probe persisted')
    check(not s.Source:find('BowUpgradeQAProbe',1,true),'Upgrade QA probe persisted')
   end
   if not allowed[path] and not path:find('ServerStorage.'..backupFolder..'.',1,true)then
    table.insert(out,path..'|'..hash(norm(s.Source)))
   end
  end
 end
 table.sort(out);return out
end
local oldSource,newSource=sourceRows(before,false),sourceRows(after,true)
check(#oldSource==#newSource,'Unrelated script count changed')
for i,row in oldSource do check(row==newSource[i],'Unrelated source changed '..row)end
local function scene(root)
 local out={};local parts,joints=0,0
 for _,p in root:GetService('Workspace'):GetDescendants()do
  if p:IsA('BasePart')and not p:IsA('Terrain')then
   parts+=1
   table.insert(out,table.concat({pathOf(p),p.ClassName,tostring(p.CFrame),tostring(p.Size),tostring(p.Color),tostring(p.Material),tostring(p.Transparency),tostring(p.Anchored),tostring(p.CanCollide),tostring(p.CanTouch),tostring(p.CanQuery)},'|'))
  elseif p:IsA('JointInstance')or p:IsA('WeldConstraint')then
   joints+=1
   table.insert(out,table.concat({pathOf(p),p.ClassName,tostring(p.Part0 and pathOf(p.Part0)),tostring(p.Part1 and pathOf(p.Part1))},'|'))
  end
 end
 table.sort(out);return hash(table.concat(out,'\n')),parts,joints
end
local oldScene,oldParts,oldJoints=scene(before)
local newScene,parts,joints=scene(after)
check(oldScene==newScene and oldParts==parts and oldJoints==joints,'Workspace geometry/joints changed')
check(at(after,'ServerScriptService.AccountData'):GetAttribute('StudioMemoryTest')~=true,'TestMemory flag persisted')
check(at(after,'ServerScriptService.HunDinoTraining'):GetAttribute('BowPetQA')==nil,'QA flag persisted')
check(at(after,'ServerScriptService.HunDinoTraining'):GetAttribute('BowUpgradeQA')==nil,'Upgrade QA flag persisted')
check(at(after,'ServerScriptService.AccountData'):GetAttribute('InventoryCraftQAOriginalTest')==nil,'Inventory craft QA flag persisted')
check(not at(after,'ServerScriptService.InventoryCraftQA'),'Inventory craft QA driver persisted')
local config=at(after,'ServerScriptService.AccountData.ProfileConfig').Source
check(config:find('StudioMemoryTest=false',1,true)~=nil,'TestMemory config persisted')
check(norm(config)==norm(at(before,'ServerScriptService.AccountData.ProfileConfig').Source),'Persistence configuration changed')
for _,o in after:GetDescendants()do check(not o.Name:find('PetSortieQA',1,true)and not o.Name:find('PetCompanionIntegrationTest_',1,true)and not o.Name:find('PetPathTest_',1,true),'QA geometry persisted')end
-- Reuse the proven container-only decoder, without deserializing Terrain data.
local opaqueSource=fs.readFile('tools/inspect-persistence-saved.luau')
local first=assert(opaqueSource:find('local function uncompressBlock',1,true))
local last=assert(opaqueSource:find('local function sourceBindings',first,true))
local opaque=luau.load(opaqueSource:sub(first,last-1)..'\nreturn opaqueTerrain',{
 environment={serde=serde,check=check,hash=hash},injectGlobals=true})()
local oldTerrain,terrain=opaque(oldBytes),opaque(bytes)
local terrainCount=0
for name,value in oldTerrain do
 terrainCount+=1
 check(terrain[name]and terrain[name].sha256==value.sha256,'Opaque Terrain changed '..name)
end
local report={Ok=true,Checks=checks,Target=target,Baseline=baseline,SHA256=hash(bytes),Bytes=#bytes,
 SourceBindings=#rows,ScriptsCompiled=scripts,WorkspaceParts=parts,WorkspaceJoints=joints,SceneHash=newScene,
 OpaqueTerrainProperties=terrainCount,VoxelContentMap=terrain.VoxelGridAssetContentMap,QAFlagsRemoved=true}
fs.writeFile(process.args[4] or 'assets/qa/bow-pet-saved.json',serde.encode('json',report,true))
print(serde.encode('json',report,true))
