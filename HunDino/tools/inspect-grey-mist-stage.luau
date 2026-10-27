local fs=require("@lune/fs")
local r=require("@lune/roblox")
local j=require("@lune/serde")
local p=r.deserializePlace(fs.readFile("HunDino_DarkJungle_v2_3.rbxl"))
local rs=p:GetService("ReplicatedStorage")
local ss=p:GetService("ServerStorage")
local f=p:GetService("Workspace"):FindFirstChild("HuntingRainforest")
local function normalized(s) return s:gsub("\r\n","\n"):gsub("\239\187\191",""):gsub("%s+$","") end
local source=rs.HuntingBaseConfig.Source
local canonical=fs.readFile("src/hunting/GreyMistValleyConfig.luau")
local difference
local a,b=normalized(source),normalized(canonical)
for i=1,math.max(#a,#b) do if a:sub(i,i)~=b:sub(i,i) then difference={at=i,saved=a:sub(math.max(1,i-70),i+90),canonical=b:sub(math.max(1,i-70),i+90)};break end end
print(j.encode("json",{trees=f.Decor.Forest and #f.Decor.Forest:GetChildren(),
	dressing=f.Decor:FindFirstChild("FinalDressing")~=nil,baseLength=#source,sourceDifference=difference,
	gradePresent=source:find("C.applyRoadJunctionGrade",1,true)~=nil,
	upperCleanup=ss.GreyMistBuild.BuildGreyMistValley.Source:find("Clear its old upper volume",1,true)~=nil},true))
