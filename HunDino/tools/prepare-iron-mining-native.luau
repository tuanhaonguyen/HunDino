-- Patch the actual MerchantWeapons variant without importing older branch code.
local fs=require("@lune/fs")
local luau=require("@lune/luau")
local function read(path)return fs.readFile(path):gsub("\r\n","\n")end
local function original(path)return read("backups/iron-mining-20261026/"..path:gsub("%.","__")..".luau")end
local function once(s,old,new)
	local a,b=s:find(old,1,true);assert(a and not s:find(old,b+1,true),"Ambiguous native patch: "..old:sub(1,70))
	return s:sub(1,a-1)..new..s:sub(b+1)
end
local function write(path,s)luau.compile(s);fs.writeFile("assets/iron-mining/"..path..".luau",s)end
do
	local path="ServerScriptService.HuntingRuntime.HuntEconomyRules";local base=original(path);local source=read("src/hunting/HuntEconomyRules.luau")
	local a=assert(source:find("-- Mining is independent of a mission ledger.",1,true));local b=assert(source:find("function Rules.apply(profile, request)",a,true))
	base=once(base,"function Rules.apply(profile, request)",source:sub(a,b-1).."function Rules.apply(profile, request)")
	base=once(base,'if type(request) ~= "table" or type(request.Op) ~= "string" then return rejected("InvalidRequest") end',
		'if type(request) ~= "table" or type(request.Op) ~= "string" then return rejected("InvalidRequest") end\n\tif request.Op=="MineIron" then return miningTransaction(profile,request) end')
	write(path,base)
end
do
	local path="ServerScriptService.HuntingRuntime.HuntEconomyService";local base=original(path);local source=read("src/hunting/HuntEconomyService.luau")
	local a=assert(source:find("function Service:MineIron",1,true));local b=assert(source:find("function Service:Publish",a,true))
	write(path,once(base,"function Service:Publish",source:sub(a,b-1).."function Service:Publish"))
end
do
	local path="ServerScriptService.HuntingRuntime.HuntQuestService";local s=original(path)
	s=once(s,'local HarvestController = require(script.Parent.HuntHarvestController)',
		'local HarvestController = require(script.Parent.HuntHarvestController)\nlocal IronMining=require(script.Parent.IronMiningService)')
	s=once(s,'self.Active = nil\n',[[self.Active = nil
	self.Mining=IronMining.new({Forest=self.Forest,Session=self.Session,PetFolder=self.PetFolder,GetState=self.GetState,
		GetEconomy=function() return self.Economy end,Message=self.Message})
]])
	s=once(s,'Player=player,Run=run,Combat=self.Combat,Forest=self.Forest,PetFolder=self.PetFolder,',
		'Player=player,Run=run,Combat=self.Combat,Forest=self.Forest,PetFolder=self.PetFolder,SkipOre=true,')
	for _,pair in {
		{'function Service:CancelAction(player, reason)','\n\tself.Mining:CancelAction(player)'},
		{'function Service:HarvestAction(player,action)','\n\tif action=="CarveStart" then self.Mining:CancelAction(player) end'},
		{'function Service:ItemAction(player, action)','\n\tif action=="TrapPlaceStart" or action=="CaptureStart" then self.Mining:CancelAction(player) end'},
		{'function Service:_step(dt)','\n\tself.Mining:Step()'},
		{'function Service:RemovePlayer(player)','\n\tself.Mining:RemovePlayer(player)'},
		{'function Service:Destroy()','\n\tself.Mining:Destroy()'},
	}do s=once(s,pair[1],pair[1]..pair[2])end
	write(path,s)
end
do
	local path="StarterPlayer.StarterPlayerScripts.HunDinoHoldProgress";local s=original(path)
	s=once(s,'\treturn nil\nend\nconnect(RunService.RenderStepped',
		'\tif player:GetAttribute("MiningActive")==true then return "Mining","G","ĐÀO QUẶNG SẮT",player:GetAttribute("MiningDuration") or 2.2,player:GetAttribute("MiningEnds") end\n\treturn nil\nend\nconnect(RunService.RenderStepped')
	s=once(s,'caption.Text = string.format("%s · %.1fs", title, left)',
		'caption.Text = string.format("%s · %.1fs", title, left)\n\thint.Text=if action=="Mining" then "Di chuyển hoặc rút vũ khí để hủy" else "Thả phím / nút để hủy"')
	write(path,s)
end
print("PASS 4 native mining patches compiled; original main branch behavior retained")
