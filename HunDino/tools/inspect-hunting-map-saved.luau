-- Read-only verification of the Studio-saved place. Never serializes Terrain back to disk.
local fs=require("@lune/fs")
local r=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local path="HunDino_HuntingRainforest_v1.rbxl"
local function normalized(s) return (s:gsub("\r\n","\n"):gsub("\239\187\191",""):gsub("%s+$","")) end
local bytes=fs.readFile(path)
local game=r.deserializePlace(bytes)
local w=game:GetService("Workspace")
local root=assert(w:FindFirstChild("HuntingRainforest"))
assert(root:GetAttribute("BuildStage")=="Complete")
assert(root:GetAttribute("Version")=="H1.1" and root:GetAttribute("RouteAIReady")==true)
assert(root:GetAttribute("AnimalZoneCount")==8 and #root.Zones:GetChildren()==9)
assert(#root.Paths:GetChildren()==15)
assert(root.Camp:FindFirstChild("CampSpawn") and root.Camp.CampSpawn:IsA("SpawnLocation"))
assert(normalized(game:GetService("ReplicatedStorage").HuntingMapConfig.Source)==normalized(fs.readFile("src/hunting/HuntingMapConfig.luau")))
local scripts,parts,meshes,motors,welds,anchors=0,0,0,0,0,0
local d=assert(w:FindFirstChild("Dinosaur01_TRex_Visual"))
for _,x in d:GetDescendants() do
	if x:IsA("BasePart") then parts+=1;if x.Anchored then anchors+=1 end end
	if x:IsA("MeshPart") then meshes+=1 end
	if x:IsA("Motor6D") then motors+=1;assert(x.Part0 and x.Part1) end
	if x:IsA("WeldConstraint") then welds+=1;assert(x.Part0 and x.Part1) end
end
assert(parts==255 and motors==7 and welds==247 and anchors==1)
assert(d:GetAttribute("HuntingZone")=="A" and not d:GetAttribute("PreviewWalking"))
assert(d:GetAttribute("RouteEnabled")==true and d.MotionRuntime.Disabled)
local enhancement=assert(root.Decor:FindFirstChild("ForestEnhancement"))
assert(#enhancement:GetDescendants()>0)
assert(not game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("DinosaurPreviewControls"))
assert(not game:GetService("ServerScriptService"):FindFirstChild("DinosaurPreviewBridge"))
for _,x in game:GetDescendants() do
	if x:IsA("LuaSourceContainer") then luau.compile(x.Source);scripts+=1 end
end
for _,mapping in {
	{"EnvironmentClock","EnvironmentClock.luau"},
	{"HuntingMapRuntime","HuntingMapRuntime.server.luau"},
	{"DinosaurRouteController","DinosaurRouteController.luau"},
} do
	assert(normalized(game:GetService("ServerScriptService").HuntingRuntime[mapping[1]].Source)==normalized(fs.readFile("src/hunting/"..mapping[2])))
end
assert(normalized(game:GetService("StarterPlayer").StarterPlayerScripts.HuntingMapViewer.Source)==normalized(fs.readFile("src/hunting/HuntingMapViewer.client.luau")))
assert(normalized(game:GetService("ServerStorage").EnhanceHuntingForest.Source)==normalized(fs.readFile("src/hunting/EnhanceHuntingForest.luau")))
local report={savedPlace=path,bytes=#bytes,animalZones=8,camps=1,mainPaths=13,humanPaths=2,
	compiledScripts=scripts,dinosaur={parts=parts,meshes=meshes,motors=motors,welds=welds,anchors=anchors},
	terrainWriteMethod="Roblox Studio Save",validation="passed",routeAIReady=true,hubConnectionReady=false,
	forestEnhancement=enhancement:GetAttributes()}
fs.writeFile("assets/hunting/saved-place.json",serde.encode("json",report,true))
print(serde.encode("json",report,true))
