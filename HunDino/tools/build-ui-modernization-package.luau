-- Builds a source-only .rbxm package. Never writes/serializes an rbxl or Terrain.
-- In native Studio v2.4 Edit mode, insert the model into ServerStorage, then:
-- require(game.ServerStorage.HunDinoUIModernization.Install).Install({DryRun=true})
-- require(game.ServerStorage.HunDinoUIModernization.Install).Install()
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local function normalized(source)
	return source:gsub("\r\n", "\n"):gsub("^\239\187\191", ""):gsub("%s+$", "")
end
local function at(root, path)
	for part in path:gmatch("[^.]+") do root = assert(root:FindFirstChild(part), path) end
	return root
end
local bindings = {
	{"ReplicatedStorage.Shared.UITheme", "src/dark-jungle/UITheme.luau", "ModuleScript", false, 0},
	{"ReplicatedStorage.Shared.EquipmentInventory", "src/dark-jungle/EquipmentInventory.luau", "ModuleScript", true, 1},
	{"ReplicatedStorage.Shared.HubUI", "src/dark-jungle/HubUI.luau", "ModuleScript", true, 2},
	{"StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest", "src/hunting/HuntQuest.client.luau", "LocalScript", true, 3},
	{"StarterPlayer.StarterPlayerScripts.HunDinoPetCompanion", "src/hunting/PetCompanion.client.luau", "LocalScript", true, 4},
	{"StarterPlayer.StarterPlayerScripts.HunDinoEconomy", "src/hunting/HuntEconomy.client.luau", "LocalScript", true, 5},
	{"StarterPlayer.StarterPlayerScripts.HunDinoTraining", "studio-pet-integration/Training.client.luau", "LocalScript", true, 6},
	{"StarterPlayer.StarterPlayerScripts.ConnectedHuntingViewer", "src/hunting/ConnectedHuntingViewer.client.luau", "LocalScript", true, 7},
	{"StarterPlayer.StarterPlayerScripts.HunDinoHoldProgress", "src/hunting/HoldProgress.client.luau", "LocalScript", false, 8},
}
local installerSource = [==[
-- Source-only installer: run from native Studio Command Bar in v2.4 Edit mode.
local K = {
0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
}
local function normalized(source)
 return source:gsub("\r\n","\n"):gsub("^\239\187\191",""):gsub("%s+$","")
end
local function sha256(message)
 local H={0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}
 local bits=#message*8
 message=message..string.char(128)..string.rep(string.char(0),(55-#message)%64)..string.pack(">I4I4",math.floor(bits/4294967296),bits%4294967296)
 local xor,band,rr,sr=bit32.bxor,bit32.band,bit32.rrotate,bit32.rshift
 for block=1,#message,64 do
  local w={}
  for j=0,15 do w[j+1]=string.unpack(">I4",message,block+j*4) end
  for j=17,64 do
   local a,b=w[j-15],w[j-2]
   w[j]=(w[j-16]+xor(rr(a,7),rr(a,18),sr(a,3))+w[j-7]+xor(rr(b,17),rr(b,19),sr(b,10)))%4294967296
  end
  local a,b,c,d,e,f,g,h=table.unpack(H)
  for j=1,64 do
   local t1=(h+xor(rr(e,6),rr(e,11),rr(e,25))+xor(band(e,f),band(bit32.bnot(e),g))+K[j]+w[j])%4294967296
   local t2=(xor(rr(a,2),rr(a,13),rr(a,22))+xor(band(a,b),band(a,c),band(b,c)))%4294967296
   h,g,f,e,d,c,b,a=g,f,e,(d+t1)%4294967296,c,b,a,(t1+t2)%4294967296
  end
  for j,v in {a,b,c,d,e,f,g,h} do H[j]=(H[j]+v)%4294967296 end
 end
 local out={};for _,v in H do table.insert(out,string.format("%08x",v)) end
 return table.concat(out)
end
assert(sha256("abc")=="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad","Installer SHA-256 self-test failed")
local function locate(path)
 local node=game
 for name in path:gmatch("[^.]+") do node=node and node:FindFirstChild(name) end
 return node
end
local function parentAt(path)
 local parent,name=path:match("^(.*)%.([^.]+)$")
 return assert(locate(parent),"Missing parent: "..parent),name
end
return {Install=function(options)
 options=options or {}
 assert(game:GetService("RunService"):IsStudio() and not game:GetService("RunService"):IsRunning(),"Install only in native Roblox Studio Edit mode")
 local forest=assert(workspace:FindFirstChild("HuntingRainforest"),"Open HunDino_DarkJungle_v2_4.rbxl first")
 assert(forest:GetAttribute("Version")=="H2.0" and forest:GetAttribute("TreesPlaced")==2400,"Wrong HunDino map")
 assert(locate("ServerScriptService.HuntingRuntime.HuntQuestService") and locate("ServerScriptService.HuntingRuntime.HuntEconomyRules") and locate("ServerScriptService.HuntingRuntime.SpecimenPreviewModel"),"Expected v2.4 quest/economy/specimen production bindings")
 local packageModel=script.Parent
 local sources=packageModel.Sources:GetChildren()
 table.sort(sources,function(a,b)return a:GetAttribute("Order")<b:GetAttribute("Order") end)
 assert(#sources==9,"Incomplete UI package")
 local serverStorage=game:GetService("ServerStorage")
 assert(not serverStorage:FindFirstChild("UIBackup_20261020"),"UI backup already exists; inspect current installation before retrying")
 local plan={}
 -- Entire preflight is read-only. A wrong place or changed source stops here.
 for _,entry in sources do
  assert(entry:IsA("StringValue"),"Unexpected package object")
  local path=entry:GetAttribute("TargetPath")
  local text=entry.Value
  assert(sha256(normalized(text))==entry:GetAttribute("SourceSHA256"),"Package source hash mismatch: "..path)
  local current=locate(path)
  local parent,name=parentAt(path)
  if entry:GetAttribute("Existing") then
   assert(current and current.ClassName==entry:GetAttribute("ClassName"),"Wrong/missing original binding: "..path)
   assert(sha256(normalized(current.Source))==entry:GetAttribute("BaselineSHA256"),"Wrong v2.4 baseline source hash: "..path)
   assert(normalized(current.Source)==normalized(entry.Baseline.Value),"Original source differs: "..path)
  else assert(current==nil,"New UI binding already exists: "..path) end
  table.insert(plan,{entry=entry,path=path,parent=parent,name=name,current=current,original=current and current.Source or nil,text=text})
 end
 local report={Preflight="passed",UpdatedSources=7,NewSources=2,MapWrites=0,TerrainWrites=0,Backup="ServerStorage.UIBackup_20261020"}
 if options.DryRun then print("HunDino UI modernization preflight passed (9 sources, no writes)");return report end
 local backup=Instance.new("Folder");backup.Name="UIBackup_20261020"
 local created={}
 -- Preserve all originals before the first source edit.
 for _,row in plan do
  if row.original then
   local copy=Instance.new("StringValue");copy.Name=row.name;copy.Value=row.original
   copy:SetAttribute("OriginalPath",row.path);copy:SetAttribute("SHA256",row.entry:GetAttribute("BaselineSHA256"));copy.Parent=backup
  end
 end
 local ok,err=xpcall(function()
  backup.Parent=serverStorage
  for _,row in plan do
   -- UITheme is order zero and must be present before any client update.
   if row.entry:GetAttribute("Order")>0 then assert(locate("ReplicatedStorage.Shared.UITheme"),"UITheme must be installed first") end
   local target=row.current
   if not target then
    target=Instance.new(row.entry:GetAttribute("ClassName"));target.Name=row.name
    table.insert(created,target)
   end
   target.Source=row.text
   if not row.current then target.Parent=row.parent end
   assert(sha256(normalized(target.Source))==row.entry:GetAttribute("SourceSHA256"),"Installed source verification failed: "..row.path)
  end
 end,debug.traceback)
 if not ok then
  local rollbackErrors={}
  for _,row in plan do
   if row.current then
    local restored,why=pcall(function()row.current.Source=row.original end)
    if not restored then table.insert(rollbackErrors,row.path..": "..tostring(why)) end
   end
  end
  for _,object in created do object:Destroy() end
  if #rollbackErrors==0 then backup:Destroy() end
  error("UI install failed: "..tostring(err)..(if #rollbackErrors>0 then "\nBackup retained. Rollback errors: "..table.concat(rollbackErrors,"; ") else "\nOriginal sources restored."))
 end
 print("HunDino UI modernization installed. Seven originals backed up; no map/Terrain writes. Use native Studio Save, then run the saved inspector.")
 packageModel:Destroy()
 return report
end}
]==]
luau.compile(installerSource)
-- Execute just the pure SHA-256 self-test during package construction. The
-- installer returns a function and does not access game until it is invoked.
luau.load(installerSource)()
local baseline = roblox.deserializePlace(fs.readFile("backups/Hub_v24_before_ui_modernization_20261020.rbxl"))
local model = roblox.Instance.new("Model")
model.Name = "HunDinoUIModernization"
model:SetAttribute("Version", "UI.20261020.1")
model:SetAttribute("RequiredNativePlace", "HunDino_DarkJungle_v2_4.rbxl")
model:SetAttribute("MapWrites", false)
local installer = roblox.Instance.new("ModuleScript")
installer.Name, installer.Source, installer.Parent = "Install", installerSource, model
local folder = roblox.Instance.new("Folder")
folder.Name, folder.Parent = "Sources", model
local manifest = {version = "UI.20261020.1", package = "assets/ui/HunDinoUIModernization.rbxm", sourceOnly = true, bindings = {}}
for _, binding in bindings do
	local path, file, className, existing, order = table.unpack(binding)
	local source = fs.readFile(file)
	luau.compile(source)
	local entry = roblox.Instance.new("StringValue")
	entry.Name, entry.Value = path:match("[^.]+$"), source
	entry:SetAttribute("TargetPath", path)
	entry:SetAttribute("SourceFile", file)
	entry:SetAttribute("ClassName", className)
	entry:SetAttribute("Existing", existing)
	entry:SetAttribute("Order", order)
	entry:SetAttribute("SourceSHA256", serde.hash("sha256", normalized(source)))
	local oldHash = nil
	if existing then
		local original = at(baseline, path)
		assert(original.ClassName == className, "Original class mismatch: " .. path)
		oldHash = serde.hash("sha256", normalized(original.Source))
		entry:SetAttribute("BaselineSHA256", oldHash)
		local old = roblox.Instance.new("StringValue")
		old.Name, old.Value, old.Parent = "Baseline", original.Source, entry
	end
	entry.Parent = folder
	table.insert(manifest.bindings, {target = path, file = file, className = className, existing = existing,
		sourceSHA256 = entry:GetAttribute("SourceSHA256"), baselineSHA256 = oldHash})
end
assert(#model:GetDescendants() == 18, "Unexpected source-only package structure")
for _, object in model:GetDescendants() do
	assert(object:IsA("Folder") or object:IsA("StringValue") or object:IsA("ModuleScript"), "Geometry in source-only package")
end
fs.writeDir("assets/ui")
fs.writeFile("assets/ui/HunDinoUIModernization.rbxm", roblox.serializeModel({model}))
fs.writeFile("assets/ui/ui-modernization-install.json", serde.encode("json", manifest, true))
local reread = roblox.deserializeModel(fs.readFile("assets/ui/HunDinoUIModernization.rbxm"))
assert(#reread == 1 and reread[1].Name == model.Name, "Package readback failed")
luau.compile(reread[1].Install.Source)
print("PASS: nine UI sources compiled; 7 SHA-256 baseline guards; source-only package written and read back; no rbxl writes")
