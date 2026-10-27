-- Read the native place without writing it. Merge only redemption into its economy.
local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local place=roblox.deserializePlace(fs.readFile("backups/savegame-before-redeem-20261022/HunDino_SaveGame.rbxl"))
local function at(path)
 local object=place
 for name in path:gmatch("[^.]+") do object=assert(object:FindFirstChild(name),path) end
 return object
end
local function source(path) return at(path).Source:gsub("\r\n","\n") end
local function read(path) return fs.readFile(path):gsub("\r\n","\n") end
local function replaceOnce(text,old,new)
 local a,b=text:find(old,1,true);assert(a,"Missing source anchor: "..old)
 assert(not text:find(old,b+1,true),"Ambiguous source anchor")
 return text:sub(1,a-1)..new..text:sub(b+1)
end
local function section(text,first,last)
 local a=assert(text:find(first,1,true));local b=assert(text:find(last,a+#first,true))
 return text:sub(a,b-1)
end
local rules=source("ServerScriptService.HuntingRuntime.HuntEconomyRules")
fs.writeFile("backups/savegame-before-redeem-20261022/HuntEconomyRules.original.luau",rules)
fs.writeFile("backups/savegame-before-redeem-20261022/HuntEconomyService.original.luau",source("ServerScriptService.HuntingRuntime.HuntEconomyService"))
fs.writeFile("backups/savegame-before-redeem-20261022/ProfileSchema.original.luau",source("ServerScriptService.AccountData.ProfileSchema"))
local canonical=read("src/hunting/HuntEconomyRules.luau")
-- The newer validProfile only adds permanent code receipts to the collection schema.
rules=replaceOnce(rules,section(rules,"local function validProfile(profile)","function Rules.new("),section(canonical,"local function validProfile(profile)","function Rules.new("))
rules=replaceOnce(rules,"migrated.DisplaySlots = {}", "migrated.DisplaySlots = {}\n\t\t\tif migrated.RedeemedCodes == nil then migrated.RedeemedCodes = {} end\n\t\t\tif not validProfile(migrated) then return nil, \"InvalidProfile\" end")
rules=replaceOnce(rules,"if normalized.DisplaySlots == nil then normalized.DisplaySlots = {} end", "if normalized.DisplaySlots == nil then normalized.DisplaySlots = {} end\n\t\tif normalized.RedeemedCodes == nil then normalized.RedeemedCodes = {} end")
rules=replaceOnce(rules,"SpecimenSerial = 0, DisplaySlots = {},", "SpecimenSerial = 0, DisplaySlots = {}, RedeemedCodes = {},")
local grant=section(canonical,'\tif request.Op == "RedeemCode" then','\tif request.Op == "OpenRun" then')
rules=replaceOnce(rules,'\tif request.Op == "OpenRun" then',grant..'\tif request.Op == "OpenRun" then')
local service=source("ServerScriptService.HuntingRuntime.HuntEconomyService")
service=replaceOnce(service,"local Service = {}", "local AdminRedeem = require(script.Parent.AdminRedeemPolicy)\nlocal Service = {}")
service=replaceOnce(service,"LastRequest={},", "LastRequest={}, LastCodeRequest={},")
local canonService=read("src/hunting/HuntEconomyService.luau")
local redeem=section(canonService,"function Service:RedeemCode(player, rawCode)","function Service:Request(player, action, token)")
-- Saved local progress is durable too; label the target store accurately.
redeem=replaceOnce(redeem,'local message = "Đã nhận 500 xu và 10 mỗi loại: da, răng, vảy, xương, sắt. Đã lưu vào tài khoản."',
 'local destination=if self.Persistence.Mode=="LocalFile" then "trên máy" else "vào tài khoản"\n\t\tlocal message = "Đã nhận 500 xu và 10 mỗi loại: da, răng, vảy, xương, sắt. Đã lưu "..destination.."."')
service=replaceOnce(service,"function Service:Request(player, action, token)",redeem.."function Service:Request(player, action, token)")
service=replaceOnce(service,'if type(action)~="string" or #action>40 then return end',
 'if type(action)~="string" or #action>40 then return end\n\tif action=="RedeemCode" then self:RedeemCode(player,token);return end')
service=replaceOnce(service,"self.Offers[player]=nil; self.LastRequest[player]=nil", "self.Offers[player]=nil; self.LastRequest[player]=nil\n\tself.LastCodeRequest[player]=nil")
local profile=read("src/data/ProfileService.luau")
local rows={
 {Path="ReplicatedStorage.Shared.HubUI",Source=read("src/dark-jungle/HubUI.luau")},
 {Path="ServerScriptService.HuntingRuntime.HuntEconomyRules",Source=rules},
 {Path="ServerScriptService.HuntingRuntime.HuntEconomyService",Source=service},
 {Path="ServerScriptService.HuntingRuntime.AdminRedeemPolicy",Source=read("src/hunting/AdminRedeemPolicy.luau")},
 {Path="ServerScriptService.AccountData.ProfileService",Source=profile},
}
for _,row in rows do
 luau.compile(row.Source)
 local file=row.Path:gsub("%.","__")..".luau"
 local old=if row.Path:find("AdminRedeemPolicy",1,true) then nil else source(row.Path)
 if old then fs.writeFile("backups/savegame-before-redeem-20261022/"..file,old) end
 fs.writeFile("assets/data/"..file,row.Source)
 row.File="assets/data/"..file
end
fs.writeFile("assets/data/savegame-redeem-install.json",serde.encode("json",rows))
print("PASS 5 compiled sources; minimal redemption merge prepared")
