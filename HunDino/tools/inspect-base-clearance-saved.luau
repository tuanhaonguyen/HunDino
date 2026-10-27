-- Read-only: never serialize the place or decode/rebuild Terrain.
local fs=require('@lune/fs')
local r=require('@lune/roblox')
local luau=require('@lune/luau')
local serde=require('@lune/serde')
local target='HunDino_MerchantWeapons_20261026.rbxl'
local baseline='backups/base-clearance-20261027/HunDino_MerchantWeapons_20261026.rbxl'
local bytes,oldBytes=fs.readFile(target),fs.readFile(baseline)
local after,before=r.deserializePlace(bytes),r.deserializePlace(oldBytes)
local checks=0
local function check(ok,label)checks+=1;assert(ok,label)end
local function hash(s)return serde.hash('sha256',s)end
local function norm(s)return s:gsub('\r\n','\n'):gsub('%s+$','')end
local function path(o)
 local names={};while o and not o:IsA('DataModel') do table.insert(names,1,o.Name);o=o.Parent end
 return table.concat(names,'.')
end
local function at(o,p)for name in p:gmatch('[^.]+')do o=o and o:FindFirstChild(name)end;return o end
local geometryPath='ServerScriptService.HuntingRuntime.BioTubeGeometry'
local expected=fs.readFile('assets/base-clearance/BioTubeGeometry.luau')
check(norm(at(after,geometryPath).Source)==norm(expected),'Geometry source differs from verified layout')
check(norm(at(after,'ServerStorage.BaseClearanceBackup_20261027.ServerScriptService__HuntingRuntime__BioTubeGeometry').Source)==norm(at(before,geometryPath).Source),'Native module backup differs')
local backupPrefix='ServerStorage.BaseClearanceBackup_20261027.'
local function sources(root,new)
 local rows={};local count=0
 for _,o in root:GetDescendants()do
  local p=path(o)
  if o:IsA('LuaSourceContainer')then
   if new then count+=1;check(pcall(luau.compile,o.Source),'Compile '..p)end
   if p~=geometryPath and p:sub(1,#backupPrefix)~=backupPrefix then table.insert(rows,p..'|'..hash(norm(o.Source)))end
  end
 end
 table.sort(rows);return rows,count
end
local oldSources=sources(before,false);local newSources,scriptCount=sources(after,true)
check(#newSources==#oldSources,'Unrelated script count changed')
for i,row in oldSources do check(row==newSources[i],'Unrelated source changed')end
local function outside(root)
 local rows={};local world=root:GetService('Workspace');local tubes=world.SpecimenTubeDisplays
 for _,o in world:GetDescendants()do
  if not o:IsDescendantOf(tubes) then
   local values={path(o),o.ClassName}
   if o:IsA('BasePart')and not o:IsA('Terrain')then
    for _,name in {'CFrame','Size','Color','Material','Transparency','Anchored','CanCollide','CanTouch','CanQuery'}do table.insert(values,tostring(o[name]))end
   elseif o:IsA('JointInstance')or o:IsA('WeldConstraint')then
    table.insert(values,o.Part0 and path(o.Part0)or'nil');table.insert(values,o.Part1 and path(o.Part1)or'nil')
   end
   table.insert(rows,table.concat(values,'|'))
  end
 end
 table.sort(rows);return hash(table.concat(rows,'\n')),#rows
end
local oldHash,oldCount=outside(before);local newHash,newCount=outside(after)
check(oldHash==newHash and oldCount==newCount,'Map outside display tubes changed')
local env={Vector3=r.Vector3,CFrame=r.CFrame,Color3=r.Color3,Enum=r.Enum,Instance=r.Instance}
local Geometry=luau.load(expected,{environment=env,injectGlobals=true})()
local offsets={r.Vector3.new(-28,0,-10),r.Vector3.new(-15,0,0),r.Vector3.new(15,0,0),r.Vector3.new(28,0,-10),r.Vector3.new(0,0,5)}
local angles={22,11,-11,-22,0}
local world=after:GetService('Workspace').SpecimenTubeDisplays
local oldWorld=before:GetService('Workspace').SpecimenTubeDisplays
check(world:GetAttribute('GeometryVersion')==Geometry.Version and world:GetAttribute('LayoutVersion')==Geometry.LayoutVersion,'Layout version differs')
local function near(a,b,label)
 check((a.Position-b.Position).Magnitude<.012,label..' position')
 check(a.LookVector:Dot(b.LookVector)>.9999 and a.UpVector:Dot(b.UpVector)>.9999,label..' rotation')
end
local function distance(p,a,b)
 local d=b-a;local t=math.clamp((p-a):Dot(d)/d:Dot(d),0,1);return(p-a-d*t).Magnitude
end
local tubes,parts,minimum=0,0,math.huge
for id=1,12 do
 local base=at(after,'Workspace.DarkJungle.Bases.Base'..id)
 local arrival=at(after,'Workspace.HunDinoL0.BaseTransit.Bases.Base'..id..'.Arrival').CFrame.Position
 local origin=Geometry.clusterFrame(base.SpawnPad.CFrame.Position,base.ShelterFloor.CFrame.Position,id)
 local cluster=world['Base'..id]
 near(cluster:GetAttribute('ClusterOrigin'),origin,'Cluster '..id)
 local start=base.SpawnPad.CFrame.Position;start=r.Vector3.new(start.X,origin.Position.Y,start.Z)
 local entry=arrival-start;entry=r.Vector3.new(entry.X,0,entry.Z).Unit*66+start
 for slot=1,5 do
  tubes+=1
  local tube=cluster['BioTube_'..slot];local oldTube=oldWorld['Base'..id]['BioTube_'..slot]
  local frame=origin*r.CFrame.new(offsets[slot])*r.CFrame.Angles(0,math.rad(angles[slot]),0)
  near(tube:GetAttribute('StaticOrigin'),frame,'Tube metadata')
  near(tube.TubeRoot.CFrame,frame*r.CFrame.new(0,.025,0),'Tube root')
  near(tube.SpecimenAnchor.CFrame,frame*r.CFrame.new(0,8.7,0),'Specimen anchor')
  near(tube.Interaction.CFrame,frame*r.CFrame.new(0,3.1,-6.8),'Interaction anchor')
  check(tube:GetAttribute('BioTubeGeometryVersion')==Geometry.Version,'Stale tube geometry version')
  check(not tube:FindFirstChild('SpecimenAssembly'),'Runtime specimen saved in empty display')
  local point=r.Vector3.new(frame.Position.X,start.Y,frame.Position.Z)
  local clearance=distance(point,start,entry);minimum=math.min(minimum,clearance)
  check(clearance>=9.45,'Tube blocks base/transit/camp walking corridor')
  local oldParts,newParts={},{}
  for _,o in oldTube:GetDescendants()do if o:IsA('BasePart')then oldParts[path(o):sub(#path(oldTube)+2)]=o end end
  for _,o in tube:GetDescendants()do if o:IsA('BasePart')then newParts[path(o):sub(#path(tube)+2)]=o end end
  local oldN,newN=0,0
  for name,o in newParts do
   newN+=1;parts+=1;local old=assert(oldParts[name],'Unexpected tube part '..name)
   for _,property in {'Size','Color','Material','Transparency','Anchored','CanCollide','CanTouch','CanQuery'}do check(tostring(o[property])==tostring(old[property]),'Tube art/collision changed '..name..'/'..property)end
   near(tube.TubeRoot.CFrame:ToObjectSpace(o.CFrame),oldTube.TubeRoot.CFrame:ToObjectSpace(old.CFrame),'Rigid tube art '..name)
  end
  for _ in oldParts do oldN+=1 end
  check(oldN==newN,'Tube part count changed')
 end
end
check(tubes==60 and parts==12000,'Lost tube geometry')
local data=at(after,'ServerScriptService.AccountData')
check(data:GetAttribute('StudioMemoryTest')~=true and data:GetAttribute('BaseClearanceQAOriginalTest')==nil,'QA override persisted')
check(not at(after,'ServerScriptService.BaseClearanceQA'),'QA driver persisted')
check(at(after,'ServerScriptService.AccountData.ProfileConfig').Source==at(before,'ServerScriptService.AccountData.ProfileConfig').Source,'Persistence config changed')
local opaqueSource=fs.readFile('tools/inspect-persistence-saved.luau')
local first=assert(opaqueSource:find('local function uncompressBlock',1,true));local last=assert(opaqueSource:find('local function sourceBindings',first,true))
local opaque=luau.load(opaqueSource:sub(first,last-1)..'\nreturn opaqueTerrain',{environment={serde=serde,hash=hash,check=check},injectGlobals=true})()
local oldTerrain,terrain=opaque(oldBytes),opaque(bytes);local terrainCount=0
for name,value in oldTerrain do terrainCount+=1;check(terrain[name] and terrain[name].sha256==value.sha256,'Terrain payload changed '..name)end
local play=serde.decode('json',fs.readFile('assets/base-clearance/studio-play.json'))
local seen={}
for _,row in play.Cases do check(not seen[row.Base] and row.Arrived and row.ReturnedViaG and row.WalkDistance>=8 and row.BaseOwnershipPreserved,'Failed or duplicate transit Play case');seen[row.Base]=true end
for id=1,12 do check(seen[id],'Missing real transit test '..id)end
local report={Ok=true,Checks=checks,ScriptsCompiled=scriptCount,Tubes=tubes,TubeParts=parts,
 OutsideMapHash=newHash,OutsideMapInstances=newCount,MinimumTubeCenterToWalkCorridor=minimum,
 TerrainProperties=terrainCount,VoxelContentMap=terrain.VoxelGridAssetContentMap,
 PlayBases=12,PersistenceUnchanged=true,Target=target,Bytes=#bytes,SHA256=hash(bytes)}
fs.writeFile('assets/base-clearance/saved-inspection.json',serde.encode('json',report,true))
print(serde.encode('json',report,true))
