-- Source-only compilation and read-only baseline manifest.
local fs=require("@lune/fs")
local roblox=require("@lune/roblox")
local luau=require("@lune/luau")
local serde=require("@lune/serde")
local before=roblox.deserializePlace(fs.readFile("backups/Hub_v24_before_inventory_items_20261019.rbxl"))
local bindings={
 {key="EquipmentInventory",path="ReplicatedStorage.Shared.EquipmentInventory",file="src/dark-jungle/EquipmentInventory.luau"},
 {key="HuntEconomyService",path="ServerScriptService.HuntingRuntime.HuntEconomyService",file="src/hunting/HuntEconomyService.luau"},
 {key="HuntEconomyClient",path="StarterPlayer.StarterPlayerScripts.HunDinoEconomy",file="src/hunting/HuntEconomy.client.luau"},
}
local function hash(s)
 s=s:gsub("\r\n","\n"):gsub("%s+$","");local h=5381
 for _,cp in utf8.codes(s) do h=(h*33+cp)%4294967296 end;return h
end
for _,row in bindings do
 local s=fs.readFile(row.file);luau.compile(s);row.newHash=hash(s)
 local o=before;for n in row.path:gmatch("[^.]+") do o=assert(o:FindFirstChild(n)) end
 row.oldHash=hash(o.Source);row.className=o.ClassName
end
fs.writeFile("assets/hunting/inventory-items-install.json",serde.encode("json",bindings,true))
print("Inventory item sources compile;3 original bindings ready")
