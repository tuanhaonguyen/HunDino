-- Read-only extraction of the two scripts being changed. Never serialize a place.
local fs=require('@lune/fs')
local r=require('@lune/roblox')
local serde=require('@lune/serde')
local root=r.deserializePlace(fs.readFile('HunDino_MerchantWeapons_20261026.rbxl'))
local rows={
 {Path='ReplicatedStorage.Shared.EquipmentInventory',File='src/dark-jungle/EquipmentInventory.luau'},
 {Path='ServerScriptService.HuntingRuntime.HuntEconomyService',File='src/hunting/HuntEconomyService.luau'},
}
for _,row in rows do
 local item=root
 for name in row.Path:gmatch('[^.]+') do item=assert(item:FindFirstChild(name),row.Path) end
 row.Source=item.Source
end
fs.writeFile('backups/inventory-crafting-20261026/saved-sources.json',serde.encode('json',rows))
print('Exported two saved sources; place untouched')
