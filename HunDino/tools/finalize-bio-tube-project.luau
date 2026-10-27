-- Prepare the selective final Rojo reconciliation. No Place serialization/write.
-- Enumerate the native save so strict deletion is limited to the two QA scripts.
local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local serde=require("@lune/serde")
local PLACE="HunDino_DarkJungle_v2_4.rbxl"
local PROJECT="bio-tubes.project.json"
local placeBytes=fs.readFile(PLACE)
local originalProject=fs.readFile(PROJECT)
local place=roblox.deserializePlace(placeBytes)
local project=serde.decode("json",originalProject)
assert(type(project.tree)=="table","Missing project tree")
local serverNode=assert(project.tree.ServerScriptService,"Missing selective ServerScriptService mapping")
local starterNode=assert(project.tree.StarterPlayer and project.tree.StarterPlayer.StarterPlayerScripts,
	"Missing selective StarterPlayerScripts mapping")
local scopes={
	{instance=place:GetService("ServerScriptService"),node=serverNode,remove="BioTubeQA"},
	{instance=place:GetService("StarterPlayer").StarterPlayerScripts,node=starterNode,remove="BioTubeClientQA"},
}
local report={version="BioTubeFinalProject.1",source=PLACE,project=PROJECT,retained={},removed={},stubs={},nativePlaceWrites=0}
for _,scope in scopes do
	local seen={}
	for _,object in scope.instance:GetChildren() do
		assert(not seen[object.Name],"Ambiguous duplicate direct-child name: "..scope.instance:GetFullName().."."..object.Name)
		seen[object.Name]=true
		if object.Name==scope.remove then
			table.insert(report.removed,scope.instance:GetFullName().."."..object.Name)
			continue
		end
		local existing=scope.node[object.Name]
		if existing then
			assert(type(existing)=="table","Unexpected project child mapping type")
			assert(existing["$className"]==nil or existing["$className"]==object.ClassName,
				"Refuse class-changing existing mapping: "..object.Name)
		else
			scope.node[object.Name]={["$className"]=object.ClassName,["$ignoreUnknownInstances"]=true}
			table.insert(report.stubs,scope.instance:GetFullName().."."..object.Name)
		end
		table.insert(report.retained,scope.instance:GetFullName().."."..object.Name)
	end
	scope.node[scope.remove]=nil
	scope.node["$ignoreUnknownInstances"]=false
end
-- Restore the production setting through the existing module, without adding a
-- stub property or leaving a required $path pointing at a removed QA file.
serverNode.AccountData=assert(serverNode.AccountData,"AccountData mapping missing")
serverNode.AccountData.ProfileConfig={["$path"]="src/data/ProfileConfig.luau"}
for _,scope in scopes do
	for name,node in scope.node do
		if name:sub(1,1)~="$" then
			assert(type(node)=="table","Invalid selective project node "..name)
			assert(node["$path"]~="tools/qa-bio-tubes.server.luau" and node["$path"]~="tools/qa-bio-tubes.client.luau",
				"Retained temporary QA mapping")
		end
	end
end
assert(fs.readFile(PLACE)==placeBytes,"Native place changed while preparing cleanup; rerun helper before reconnecting")
local backup="backups/specimen_tubes_20261021/bio-tubes.project.before-final-cleanup.json"
if not fs.isFile(backup) then fs.writeFile(backup,originalProject) end
table.sort(report.retained);table.sort(report.removed);table.sort(report.stubs)
fs.writeFile(PROJECT,serde.encode("json",project,true))
assert(fs.readFile(PLACE)==placeBytes,"Helper modified native place")
print(serde.encode("json",report,true))
