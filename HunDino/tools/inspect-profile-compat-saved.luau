-- READ ONLY: verify native Studio output. Never serialize a place or decode voxels.
local fs=require('@lune/fs')
local r=require('@lune/roblox')
local luau=require('@lune/luau')
local serde=require('@lune/serde')
local function hash(v)return serde.hash('sha256',v)end
local checks=0
local function check(ok,label)checks+=1;assert(ok,label)end
local function norm(v)return v:gsub('\r\n','\n'):gsub('%s+$','')end
local function pathOf(o)local p={};while o and not o:IsA('DataModel')do table.insert(p,1,o.Name);o=o.Parent end;return table.concat(p,'.')end
local function at(root,path)for n in path:gmatch('[^.]+')do root=root and root:FindFirstChild(n)end;return root end
local backupPath='ServerStorage.ProfileCompatBackup_20261027'
local function inside(path)return path==backupPath or path:sub(1,#backupPath+1)==backupPath..'.'end
-- Reuse the scene/metadata comparison from the mining inspector without running it.
local helperSource=fs.readFile('tools/inspect-iron-mining-saved.luau')
local helperFirst=assert(helperSource:find('local function stable',1,true))
local helperLast=assert(helperSource:find('local function configFrom',helperFirst,true))
local helpers=luau.load(helperSource:sub(helperFirst,helperLast-1)..'\nreturn {stable=stable,value=value,optional=optional,scene=scene}',{environment={serde=serde,hash=hash,pathOf=pathOf,inside=function()return false end},injectGlobals=true})()
local stable,value,optional=helpers.stable,helpers.value,helpers.optional
local report={Version='ProfileCompatSavedValidation.1',Target='HunDino_MerchantWeapons_20261026.rbxl',Baseline='backups/profile-compat-20261027/HunDino_MerchantWeapons_20261026.rbxl'}
local function main()
 local oldBytes,bytes=fs.readFile(report.Baseline),fs.readFile(report.Target)
 report.Bytes,report.SHA256,report.BaselineSHA256=#bytes,hash(bytes),hash(oldBytes)
 check(#oldBytes==4480005,'Unexpected native baseline')
 local before,after=r.deserializePlace(oldBytes),r.deserializePlace(bytes)
 local plan=serde.decode('json',fs.readFile('assets/profile-compat/install.json'))
 check(#plan==3,'Expected three source changes')
 local allowed={}
 local backup=assert(at(after,backupPath),'Missing native backup folder')
 check(backup:IsA('Folder') and #backup:GetChildren()==3,'Invalid backup structure')
 check(backup:GetAttribute('BeforePlaceVersion')==12,'Invalid backup version')
 for _,row in plan do
  allowed[row.Path]=true
  local old,new=assert(at(before,row.Path)),assert(at(after,row.Path))
  check(norm(old.Source)==norm(row.Baseline),'Wrong baseline source: '..row.Path)
  check(new.ClassName==old.ClassName and norm(new.Source)==norm(row.Source),'Wrong patched source: '..row.Path)
  local b=backup:FindFirstChild(new.Name)
  check(b and b:IsA('StringValue') and norm(b.Value)==norm(old.Source) and b:GetAttribute('OriginalPath')==row.Path,'Wrong original source backup: '..row.Path)
 end
 local function index(root,isAfter)
  local rows,sources={},0
  local selectionCount=0
  for _,o in root:GetDescendants()do
   local p=pathOf(o)
   if inside(p)then continue end
   -- Studio changes the number of its empty root selection bookkeeping objects.
   if p=='FilteredSelection' then
    check(o.ClassName=='Instance' and #o:GetChildren()==0 and next(o:GetAttributes())==nil and #o:GetTags()==0,'Unexpected selection bookkeeping content')
    selectionCount+=1;continue
   end
   local row={path=p,class=o.ClassName,attributes=value(o:GetAttributes()),tags=o:GetTags(),archivable=o.Archivable}
   if o:IsA('ValueBase')then row.stored=optional(o,'Value')end
   if o:IsA('LuaSourceContainer')then
    sources+=1
    if isAfter then check(pcall(luau.compile,o.Source),'Source does not compile: '..p)end
    if not allowed[p]then row.sourceHash=hash(norm(o.Source))end
    row.disabled=optional(o,'Disabled');row.runContext=optional(o,'RunContext')
   end
   table.insert(rows,stable(row))
  end
  table.sort(rows);return rows,sources,selectionCount
 end
 local oldRows,oldScripts,oldSelection=index(before,false)
 local rows,scripts,selection=index(after,true)
 report.StudioSelectionBookkeeping={Before=oldSelection,After=selection}
 local oldSet,newSet={},{}
 for _,row in oldRows do oldSet[row]=(oldSet[row]or 0)+1 end
 for _,row in rows do newSet[row]=(newSet[row]or 0)+1 end
 report.RemovedRows,report.AddedRows={},{}
 for row,n in oldSet do if n~=(newSet[row]or 0)then table.insert(report.RemovedRows,{Row=row,Before=n,After=newSet[row]or 0})end end
 for row,n in newSet do if n~=(oldSet[row]or 0)then table.insert(report.AddedRows,{Row=row,Before=oldSet[row]or 0,After=n})end end
 report.BeforeInstanceCount,report.AfterInstanceCount=#oldRows,#rows
 check(#rows==#oldRows,'Unexpected instance additions/removals')
 for i,row in oldRows do check(row==rows[i],'Original metadata or source changed: '..row)end
 check(scripts==163 and scripts==oldScripts,'Script count changed')
 local oldScene,oldCounts=helpers.scene(before,false)
 local scene,counts=helpers.scene(after,false)
 check(scene==oldScene and stable(counts)==stable(oldCounts),'Scene geometry or joints changed')
 local opaqueSource=fs.readFile('tools/inspect-persistence-saved.luau')
 local first=assert(opaqueSource:find('local function uncompressBlock',1,true))
 local last=assert(opaqueSource:find('local function sourceBindings',first,true))
 local opaque=luau.load(opaqueSource:sub(first,last-1)..'\nreturn opaqueTerrain',{environment={serde=serde,check=check,hash=hash},injectGlobals=true})()
 local oldTerrain,terrain=opaque(oldBytes),opaque(bytes)
 local n,m=0,0
 for name,payload in oldTerrain do n+=1;check(terrain[name] and terrain[name].sha256==payload.sha256 and terrain[name].bytes==payload.bytes,'Terrain bytes changed: '..name)end
 for _ in terrain do m+=1 end;check(n==m,'Terrain fields changed')
 check(#assert(at(after,'Workspace.HuntingRainforest.MineableIron')):GetChildren()==30,'Ore models changed')
 check(at(after,'ServerScriptService.AccountData'):GetAttribute('StudioMemoryTest')==nil,'Temporary memory override saved')
 report.OriginalInstancesPreserved,report.ScriptsCompiled,report.SceneHash,report.Geometry,report.OpaqueTerrainProperties,report.ChangedSources=#rows,scripts,scene,counts,n,3
end
local ok,err=xpcall(main,debug.traceback)
report.Ok,report.Checks=ok,checks
if not ok then report.Error=tostring(err)end
fs.writeFile('assets/profile-compat/saved-inspection.json',serde.encode('json',report,true))
print(serde.encode('json',report,true))
assert(ok,'Native profile compatibility validation failed: '..tostring(err))
