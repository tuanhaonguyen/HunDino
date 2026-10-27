-- Read-only verification. Never reserialize a place or decode/rebuild Terrain.
local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local serde=require("@lune/serde")
local luau=require("@lune/luau")
local redeem=table.find(require("@lune/process").args,"--redeem")~=nil
local afterPath=if redeem and not table.find(require("@lune/process").args,"--final") then "HunDino_SaveGame_redeem.rbxl" else "HunDino_SaveGame.rbxl"
local beforePath=if redeem then "backups/savegame-before-redeem-20261022/HunDino_SaveGame.rbxl" else "HunDino_DarkJungle_v2_4.rbxl"
local before=roblox.deserializePlace(fs.readFile(beforePath))
local after=roblox.deserializePlace(fs.readFile(afterPath))
local checks=0
local function check(ok,message) checks+=1;assert(ok,message) end
local function pathOf(object)
 local path={}
 while object and not object:IsA("DataModel") do table.insert(path,1,object.Name);object=object.Parent end
 return table.concat(path,".")
end
local function at(root,path)
 for name in path:gmatch("[^.]+") do root=root and root:FindFirstChild(name) end
 return root
end
local function normalize(source) return source:gsub("\r\n","\n"):gsub("%s+$","") end
local expected={
 ["ServerScriptService.AccountData.ProfileService"]="src/data/ProfileService.luau",
 ["ServerScriptService.AccountData.StudioLocalStore"]="src/data/StudioLocalStore.luau",
}
if redeem then
 for _,row in serde.decode("json",fs.readFile("assets/data/savegame-redeem-install.json")) do expected[row.Path]=row.File end
end
for path,file in expected do check(normalize(at(after,path).Source)==normalize(fs.readFile(file)),"Source differs: "..path) end
local config=at(after,"ServerScriptService.AccountData.ProfileConfig").Source
check(config:find("StudioLocalFileEnabled=true",1,true)~=nil,"Local file opt-in missing")
check(config:find("StudioMemoryTest=false",1,true)~=nil,"TestMemory must be disabled")
check(at(after,"ServerScriptService.AccountData"):GetAttribute("StudioMemoryTest")~=true,"Test override still enabled")
check(after:GetService("HttpService").HttpEnabled,"HTTP local bridge is disabled")
local allowed={
 ["ServerScriptService.AccountData.ProfileService"]=true,
 ["ServerScriptService.AccountData.ProfileConfig"]=true,
 ["ReplicatedStorage.Shared.HubUI"]=true,
}
if redeem then
 allowed={}
 for path in expected do allowed[path]=true end
 for path in allowed do
  if path~="ServerScriptService.AccountData.StudioLocalStore" and path~="ServerScriptService.HuntingRuntime.AdminRedeemPolicy" then
   local backup=at(after,"ServerStorage.SaveGameRedeemBackup_20261022."..path:gsub("%.","__"))
   check(backup and normalize(backup.Source)==normalize(at(before,path).Source),"Missing or changed backup: "..path)
  end
 end
end
local scripts=0
for _,object in after:GetDescendants() do
 if object:IsA("LuaSourceContainer") then
  scripts+=1
  check(pcall(luau.compile,object.Source),"Compile error: "..pathOf(object))
 end
end
local function scriptRows(root)
 local rows={}
 for _,object in root:GetDescendants() do
  local path=pathOf(object)
  if object:IsA("LuaSourceContainer") and not allowed[path] and path~="ServerScriptService.AccountData.StudioLocalStore"
   and not (redeem and path:sub(1,#"ServerStorage.SaveGameRedeemBackup_20261022.")=="ServerStorage.SaveGameRedeemBackup_20261022.") then
   table.insert(rows,path.."|"..serde.hash("sha256",normalize(object.Source)))
  end
 end
 table.sort(rows)
 return rows
end
local oldScripts,newScripts=scriptRows(before),scriptRows(after)
check(#oldScripts==#newScripts,"Unexpected script count")
for i,row in oldScripts do check(newScripts[i]==row,"Unexpected script change: "..row:match("^(.-)|")) end
local reflection=roblox.getReflectionDatabase()
local function terrain(root)
 local object=root:GetService("Workspace"):FindFirstChildOfClass("Terrain")
 check(object~=nil,"Terrain missing")
 local values,seen={},{}
 local class=reflection:GetClass("Terrain")
 while class do
  for name in class.Properties do
   if not seen[name] and name~="Parent" and name~="HistoryId" and name~="UniqueId" then
    seen[name]=true
    local ok,value=pcall(function() return object[name] end)
    if ok then
     values[name]=if type(value)=="string" then serde.hash("sha256",value) else tostring(value)
    end
   end
  end
  class=if class.Superclass then reflection:GetClass(class.Superclass) else nil
 end
 return values
end
local oldTerrain,newTerrain=terrain(before),terrain(after)
for name,value in oldTerrain do check(newTerrain[name]==value,"Terrain changed: "..name) end
local function scene(root)
 local rows,counts={},{}
 for _,object in root:GetService("Workspace"):GetDescendants() do
  counts[object.ClassName]=(counts[object.ClassName] or 0)+1
  if object:IsA("BasePart") and not object:IsA("Terrain") then
   local fields={pathOf(object),object.ClassName,tostring(object.CFrame),tostring(object.Size),tostring(object.Color),tostring(object.Material),tostring(object.Transparency),tostring(object.Anchored),tostring(object.CanCollide)}
   table.insert(rows,table.concat(fields,"|"))
  end
 end
 table.sort(rows)
 return serde.hash("sha256",table.concat(rows,"\n")),counts,#rows
end
local oldHash,oldCounts,oldParts=scene(before)
local newHash,newCounts,newParts=scene(after)
check(oldHash==newHash,"Workspace part properties changed")
for name,count in oldCounts do check(newCounts[name]==count,"Workspace class count changed: "..name) end
for name,count in newCounts do check(oldCounts[name]==count,"Unexpected Workspace class: "..name) end
local report={Checks=checks,ScriptsCompiled=scripts,WorkspaceParts=newParts,SceneHash=newHash,TerrainPropertiesCompared=0,
 Place=afterPath,SHA256=serde.hash("sha256",fs.readFile(afterPath))}
for _ in oldTerrain do report.TerrainPropertiesCompared+=1 end
fs.writeFile(if redeem then "assets/data/savegame-redeem-saved.json" else "assets/data/savegame-saved.json",serde.encode("json",report,true))
print(serde.encode("json",report,true))
