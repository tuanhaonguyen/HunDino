-- Pure economy/persistence adapter tests. No account, Studio world or network IO.
local fs=require("@lune/fs")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local E=require("../src/hunting/HuntEconomyRules")
local Schema=require("../src/data/ProfileSchema").new(E)
local servicePath="src/hunting/HuntEconomyService.luau"
if table.find(require('@lune/process').args,'--profile-compat') then
 E=luau.load(fs.readFile('assets/profile-compat/HuntEconomyRules.luau'))()
 Schema=require('../backups/profile-compat-20261027/ProfileSchema').new(E)
 servicePath='assets/profile-compat/HuntEconomyService.luau'
end
local checks,groups=0,0
local function check(v,m) checks+=1;assert(v,m) end
local function clone(v) if type(v)~="table" then return v end local t={} for k,x in v do t[k]=clone(x) end return t end
local function same(a,b)
	if type(a)~=type(b) then return false end
	if type(a)~="table" then return a==b end
	for k,v in a do if not same(v,b[k]) then return false end end
	for k in b do if a[k]==nil then return false end end
	return true
end
local function test(name,fn) fn();groups+=1;print("PASS",name) end
local function request(p,node,hit,sample,serial)
	return {Op="MineIron",OperationSerial=serial or p.OperationSerial+1,
		SourceId="2afe6b27-01c4-4ef9-bba2-6a266d477099:"..tostring(node or 1)..":"..tostring(hit or 1),
		NodeId=node or 1,HitIndex=hit or 1,QuantityRoll=sample or 0}
end
local function apply(p,r)
	local receipt=E.apply(p,r);check(receipt.Ok,"Expected success: "..tostring(receipt.Code));return receipt
end
local function reject(p,r,code)
	local before=clone(p);local receipt=E.apply(p,r)
	check(not receipt.Ok and receipt.Code==code,"Expected "..code..", got "..tostring(receipt.Code))
	check(same(before,p),"Rejected transaction cannot mutate profile")
end

test("Strict 20 percent boundary gives one or two existing Iron materials",function()
	for _,row in {{0,2},{.199999999,2},{.2,1},{.200000001,1},{.99999999,1}} do
		local p=E.new();local r=request(p,1,1,row[1]);local before=clone(p);local receipt=apply(p,r)
		check(receipt.Code=="IronMined" and receipt.Quantity==row[2] and receipt.Material=="Iron","Correct drop quantity")
		check(receipt.SourceId==r.SourceId and receipt.NodeId==1 and receipt.HitIndex==1 and receipt.OperationSerial==1,"Receipt binds physical claim")
		check(p.Materials.Iron==row[2] and p.Revision==1 and p.OperationSerial==1,"Iron and receipt serial commit together")
		before.Materials.Iron=row[2];before.Revision=1;before.OperationSerial=1
		before.OperationOrder={1};before.OperationReceipts[1]=clone(receipt)
		check(same(before,p),"No coins, other materials, supplies, levels, specimens or run changes")
	end
end)

test("Three claims at each of thirty nodes can grant at most 180 in this allocation",function()
	local p=E.new();local first,last
	for node=1,30 do for hit=1,3 do
		local r=request(p,node,hit,.1);local receipt=apply(p,r)
		first=first or clone(r);last=clone(r)
		check(receipt.Quantity==2,"Maximum drop is exactly two")
	end end
	check(p.Materials.Iron==180 and p.OperationSerial==90,"Ninety physical claims yield exactly 180 at maximum roll")
	check(#p.OperationOrder==E.Config.RecentOperations and p.OperationReceipts[1]==nil,"Shared receipt history stays bounded")
	reject(p,first,"StaleOperation")
	local before=clone(p);local replay=apply(p,last)
	check(replay.Replay and same(before,p),"Most recent physical claim replays without multiplying rewards")
end)

test("Mining works during a mission and exploration without modifying either run",function()
	for _,mode in {false,"Exploration"} do
		local p=E.new();p.StoredConsumables.IronTrap=3;p.StoredConsumables.SleepPotion=3
		apply(p,{Op="OpenRun",RunId="active-run",MonsterId="active-monster",RunSerial=1,Mode=mode or nil})
		apply(p,{Op="StartRun",RunId="active-run",RunSerial=1})
		local run,supplies=clone(p.ActiveRun),clone(p.StoredConsumables)
		for hit=1,3 do apply(p,request(p,30,hit,.5)) end
		check(same(run,p.ActiveRun) and same(supplies,p.StoredConsumables),"Mining does not reserve or consume carried supplies/run claims")
		check(p.Materials.Iron==3 and p.Coins==80 and p.Materials.Bone==0,"No mission completion package")
	end
end)

test("Cached serial binds source node and hit while replay never rerolls",function()
	local p=E.new();local r=request(p,7,3,.1);local receipt=apply(p,r);local before=clone(p)
	local changedRoll=clone(r);changedRoll.QuantityRoll=.999
	local replay=apply(p,changedRoll)
	check(replay.Replay and replay.Quantity==receipt.Quantity and same(p,before),"A retry cannot reroll two Iron into another result")
	for _,field in {"SourceId","NodeId","HitIndex"} do
		local bad=clone(r);bad[field]=if field=="SourceId" then "another-source" elseif field=="NodeId" then 8 else 2
		reject(p,bad,"MiningClaimMismatch")
	end
	receipt.Quantity=999;replay.Quantity=999
	check(p.OperationReceipts[1].Quantity==2,"Returned receipts do not expose canonical references")
end)

test("Malformed metadata and arbitrary grant payloads reject atomically",function()
	local p=E.new()
	local invalid={
		{"SourceId",""},{"SourceId",string.rep("x",129)},{"SourceId","bad\nsource"},{"SourceId",{}},
		{"NodeId",0},{"NodeId",31},{"NodeId",1.5},{"NodeId",math.huge},{"NodeId",0/0},
		{"HitIndex",0},{"HitIndex",4},{"HitIndex",1.5},{"HitIndex","1"},
		{"QuantityRoll",-.001},{"QuantityRoll",1},{"QuantityRoll",math.huge},{"QuantityRoll",0/0},{"QuantityRoll",".1"},
		{"Quantity",99},{"Material","Bone"},{"Coins",99},{"RunId","untrusted-run"},
	}
	for _,row in invalid do local bad=request(p);bad[row[1]]=row[2];reject(p,bad,"InvalidMiningRequest") end
	for _,value in {0,-1,1.5,"1",math.huge,E.Config.MaximumSerial+1} do
		local bad=request(p);bad.OperationSerial=value;reject(p,bad,"InvalidSerial")
	end
	local missing=request(p);missing.SourceId=nil;reject(p,missing,"InvalidMiningRequest")
	reject(p,request(p,1,1,.5,2),"StaleOperation")
end)

test("Overflow and revision limits cannot spend a claim or partially grant",function()
	for _,quantity in {1,2} do
		local p=E.new();p.Materials.Iron=E.Config.MaximumCount-quantity+1
		reject(p,request(p,1,1,if quantity==2 then .1 else .5),"Capacity")
		p.Materials.Iron=0;local retry=apply(p,request(p,1,1,if quantity==2 then .1 else .5))
		check(retry.Quantity==quantity and p.Materials.Iron==quantity,"A rejected claim remains available with its original serial")
	end
	local p=E.new();p.Revision=E.Config.MaximumCount;reject(p,request(p),"Capacity")
end)

test("Shop serials cannot be claimed as mining and the shared ledger survives eviction",function()
	local p=E.new();apply(p,{Op="Buy",Item="RawTrap",OperationSerial=1})
	reject(p,request(p,1,1,.1,1),"MiningClaimMismatch")
	apply(p,request(p,1,1,.5,2))
	for i=3,70 do apply(p,request(p,(i-1)%30+1,(i-1)%3+1,.5,i)) end
	check(#p.OperationOrder==64 and p.OperationSerial==70,"Mining and store claims use one monotonic bounded ledger")
	reject(p,request(p,1,1,.1,1),"StaleOperation")
	check(p.StoredConsumables.RawTrap==1 and p.Coins==70,"Mining cannot alter old purchase outcome")
end)

test("JSON roundtrip preserves rewards code receipts loadout levels supplies and specimens",function()
	local p=E.new()
	apply(p,{Op="RedeemCode",CodeId="FixtureExistingCode",RedeemedAt=1792400000,Coins=50,
		Materials={Skin=2,Tooth=3,Scale=4,Bone=5,Iron=6},Consumables={RawTrap=2,IronTrap=2,SleepPotion=2}})
	p.HammerLevel=2;p.WeaponLevels.Hammer=2;p.WeaponLevels.Bow=2
	apply(p,{Op="OpenRun",RunId="capture-run",MonsterId="capture-monster",RunSerial=1})
	apply(p,{Op="StartRun",RunId="capture-run",RunSerial=1})
	apply(p,{Op="Finish",RunId="capture-run",RunSerial=1,Result="Captured",Traps=1,Potions=1,
		Rolls={{TypeRoll=.1,QuantityRoll=.1},{TypeRoll=.6,QuantityRoll=.1},{TypeRoll=.9,QuantityRoll=.1}},
		Specimen={Id="014e26f5-e829-45bc-9414-326893f808ad",SpeciesId="TRex",Name="T-Rex",Variant="Normal",Element="None",
			SizeScale=1,CapturedAt=1792400000,SourceRunId="capture-run",SourceMonsterId="capture-monster"}})
	apply(p,{Op="CloseRun",RunId="capture-run",RunSerial=1,Traps=1,Potions=1})
	local r=request(p,30,3,.1);apply(p,r)
	local data=Schema.Default(1792400000);data.Economy=p
	local encoded=assert(Schema.Encode(data));local decoded=assert(Schema.Validate(serde.decode("json",serde.encode("json",encoded))))
	check(same(data,decoded),"The entire account survives JSON with new receipt and all preexisting economy")
	local before=clone(decoded);local replay=apply(decoded.Economy,r)
	check(replay.Replay and replay.Quantity==2 and same(before,decoded),"Reloaded mining receipt still replays exactly once")
end)

local Service=luau.load(fs.readFile(servicePath),{
	environment={game={GetService=function() return {} end},
		script={Parent={HuntEconomyRules="Economy",SpecimenPreviewModel="Preview",BioTubeService="Bio",AdminRedeemPolicy="Admin"}},
		require=function(module) return if module=="Economy" then E else {} end},injectGlobals=true,
})()
test("Service commits through persistence and retries pending outcomes with the same claim",function()
	local data=Schema.Default(1792400000);data.Statistics={HuntsCompleted=17,HuntsFailed=3,Captures=7}
	local store={DataValue=data,Writes=0,Blocked=false}
	function store:Data() return self.DataValue end
	function store:CanMutate() return not self.Blocked and not self.Pending end
	function store:CommitEconomy(_,mutate)
		local candidate=clone(self.DataValue);local receipt=mutate(candidate.Economy,candidate.Statistics)
		if not receipt.Ok or receipt.Replay then return receipt end
		self.Writes+=1
		if self.Fail then self.Pending=candidate;return {Ok=false,Code="SavePending",Replay=false} end
		self.DataValue=candidate;return receipt
	end
	local service=setmetatable({Persistence=store,Published=0,Notices={}},Service)
	function service:Publish() self.Published+=1 end
	function service:_notice(_,message) table.insert(self.Notices,message) end
	local r=request(data.Economy,4,2,.1);local original=clone(r);store.Fail=true
	local first=service:MineIron({},r)
	check(not first.Ok and first.Code=="SavePending" and store.Pending.Economy.Materials.Iron==2,"Candidate includes reward and receipt before acknowledgement")
	check(store.DataValue.Economy.Materials.Iron==0 and service.Published==0 and #service.Notices==0,"No success publication before durable confirmation")
	check(not service:MineIron({},r).Ok and store.Writes==1 and same(original,r),"Waiting retry cannot draw another roll serial or write")
	store.DataValue=store.Pending;store.Pending=nil;store.Fail=false
	local replay=service:MineIron({},r)
	check(replay.Ok and replay.Replay and replay.Quantity==2 and store.Writes==1,"Acknowledged pending receipt replays instead of regranting")
	check(service.Published==1 and #service.Notices==1 and service.Notices[1]:find("2",1,true),"Confirmed quantity reaches inventory snapshot and notice")
	check(same(store.DataValue.Statistics,data.Statistics) and same(original,r),"Mining changes neither hunt statistics nor caller request")
	local nextRequest=request(store.DataValue.Economy,4,3,.5);check(service:MineIron({},nextRequest).Ok,"Next physical claim commits normally")
	check(store.DataValue.Economy.Materials.Iron==3 and store.Writes==2,"One more strike adds exactly one")
	store.Blocked=true;local count=#service.Notices
	check(service:MineIron({},request(store.DataValue.Economy)).Code=="SavePending" and #service.Notices==count,"Unavailable persistence does not spam success notices")
	check(service:MineIron({},{}).Code=="InvalidRequest","Helper cannot be used to send another economy operation")
end)

for _,path in {"src/hunting/HuntEconomyRules.luau","src/hunting/HuntEconomyService.luau"} do luau.compile(fs.readFile(path));check(true,"Source compiles") end
print(string.format("Iron mining economy: %d checks / %d groups PASS",checks,groups))
