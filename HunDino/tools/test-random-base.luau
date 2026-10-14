local fs=require("@lune/fs")
local luau=require("@lune/luau")
local src=fs.readFile("studio-pet-integration/Training.server.luau")
luau.compile(src);luau.compile(fs.readFile("src/dark-jungle/Training.server.luau"))
local first=assert(src:find("local baseRandom=Random.new()",1,true))
local last=assert(src:find("local function setup(player)",first,true))
local selector=src:sub(first,last-1).."return chooseFreeBase"
local function scenario(owners,pick)
	local calls=0
	local choose=luau.load(selector,{environment={owners=owners,Config={LobbyCapacity=12},Random={new=function() return {NextInteger=function(_,low,high) calls+=1;return pick(low,high,calls) end} end}},injectGlobals=true})()
	return choose,function() return calls end
end
-- Deliberately draw occupied 1 and 2 first; removed numbers cannot be drawn again.
local choose,calls=scenario({[1]=true,[2]=true},function(low) return low end)
assert(choose()==3 and calls()==3)
local occupied={};choose,calls=scenario(occupied,function(_,high) return high end)
for expected=12,1,-1 do local id=assert(choose());assert(id==expected and not occupied[id]);occupied[id]=true end
local before=calls();assert(choose()==nil and calls()-before==12,"full lobby must terminate")
for free=1,12 do
	local owners={};for i=1,12 do owners[i]=i~=free end
	choose,calls=scenario(owners,function(low) return low end)
	assert(choose()==free and calls()<=12,"last free base "..free)
end
local observed={}
for start=1,12 do
	choose=scenario({},function(_,_,call) return if call==1 then start else 1 end)
	observed[choose()]=true
end
for i=1,12 do assert(observed[i],"base cannot be drawn: "..i) end
print("PASS random base collision retries, all 12 selectable, unique assignment, each last-free-base case and full-lobby termination")
