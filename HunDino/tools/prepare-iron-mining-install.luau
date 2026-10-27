-- Source plan only. Read native baseline; never serialize/write a Place or Terrain.
local fs=require("@lune/fs")
local r=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local process=require("@lune/process")
local baseline="backups/iron-mining-20261026/HunDino_MerchantWeapons_20261026.rbxl"
local output=process.args[1] or "assets/iron-mining/iron-mining-install.json"
local bytes=fs.readFile(baseline);assert(#bytes==4373461,"Unexpected iron mining baseline size")
local before=r.deserializePlace(bytes)
local function at(path) local o=before;for n in path:gmatch("[^.]+")do o=o and o:FindFirstChild(n)end;return o end
local function norm(s)return s:gsub("\r\n","\n"):gsub("%s+$","")end
local bindings={
	{"ServerScriptService.HuntingRuntime.HuntEconomyRules","assets/iron-mining/ServerScriptService.HuntingRuntime.HuntEconomyRules.luau","ModuleScript",true},
	{"ServerScriptService.HuntingRuntime.HuntEconomyService","assets/iron-mining/ServerScriptService.HuntingRuntime.HuntEconomyService.luau","ModuleScript",true},
	{"ServerScriptService.HuntingRuntime.HuntQuestService","assets/iron-mining/ServerScriptService.HuntingRuntime.HuntQuestService.luau","ModuleScript",true},
	{"StarterPlayer.StarterPlayerScripts.HunDinoHoldProgress","assets/iron-mining/StarterPlayer.StarterPlayerScripts.HunDinoHoldProgress.luau","LocalScript",true},
	{"ServerScriptService.HuntingRuntime.IronMiningConfig","src/hunting/IronMiningConfig.luau","ModuleScript",false},
	{"ServerScriptService.HuntingRuntime.BuildIronMiningNodes","src/hunting/BuildIronMiningNodes.luau","ModuleScript",false},
	{"ServerScriptService.HuntingRuntime.IronMiningService","src/hunting/IronMiningService.luau","ModuleScript",false},
	{"ServerScriptService.HuntingRuntime.IronOreVisual","src/hunting/IronOreVisual.luau","ModuleScript",false},
	{"ServerScriptService.HuntingRuntime.MiningPickaxeVisual","src/hunting/MiningPickaxeVisual.luau","ModuleScript",false},
	{"StarterPlayer.StarterPlayerScripts.HunDinoIronMining","src/hunting/IronMining.client.luau","LocalScript",false},
}
local plan={}
for _,b in bindings do
	local source=fs.readFile(b[2]);luau.compile(source)
	local original=at(b[1]);assert((original~=nil)==b[4],"Baseline binding mismatch: "..b[1])
	if original then
		assert(original.ClassName==b[3],"Baseline class mismatch")
		local text=fs.readFile("backups/iron-mining-20261026/"..b[1]:gsub("%.","__")..".luau")
		assert(norm(text)==norm(original.Source),"Captured original differs: "..b[1])
	end
	table.insert(plan,{Path=b[1],File=b[2],Class=b[3],Source=source,Before=if original then original.Source else nil,
		SHA256=serde.hash("sha256",norm(source)),BeforeSHA256=if original then serde.hash("sha256",norm(original.Source)) else nil})
end
if not fs.isDir("assets/iron-mining") then fs.writeDir("assets/iron-mining") end
fs.writeFile(output,serde.encode("json",plan,true))
print("PASS 10 compiled iron mining bindings; 4 changed originals, 6 new sources; plan",output)
