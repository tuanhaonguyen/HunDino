-- Source text only. This tool never writes or serializes a Roblox Place.
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local serde=require('@lune/serde')
local bindings={
	{'ReplicatedStorage.Shared.HubUI','src/dark-jungle/HubUI.luau','HubUI'},
	{'ServerScriptService.HuntingRuntime.HuntEconomyRules','src/hunting/HuntEconomyRules.luau','HuntEconomyRules'},
	{'ServerScriptService.HuntingRuntime.HuntEconomyService','src/hunting/HuntEconomyService.luau','HuntEconomyService'},
	{'ServerScriptService.HuntingRuntime.AdminRedeemPolicy','src/hunting/AdminRedeemPolicy.luau'},
	-- These dependencies were absent in the reopened cloud Place although its
	-- original economy service already required BioTubeService at startup.
	{'ServerScriptService.HuntingRuntime.BioTubeGeometry','src/hunting/BioTubeGeometry.luau'},
	{'ServerScriptService.HuntingRuntime.BioTubeSpecimen','src/hunting/BioTubeSpecimen.luau'},
	{'ServerScriptService.HuntingRuntime.BioTubeService','src/hunting/BioTubeService.luau'},
}
local plan={}
for _,binding in bindings do
	local source=fs.readFile(binding[2]);luau.compile(source)
	local original=if binding[3] then fs.readFile('backups/redeem-admin-20261021/'..binding[3]..'.luau') else nil
	table.insert(plan,{Path=binding[1],File=binding[2],Source=source,Baseline=original,
		SHA256=serde.hash('sha256',source),Class='ModuleScript'})
end
if not fs.isDir('assets/redeem') then fs.writeDir('assets/redeem') end
fs.writeFile('assets/redeem/admin-redeem-install.json',serde.encode('json',plan))
-- Reuse the read-only strict native property/Terrain inspector with these bindings.
local source=fs.readFile('tools/inspect-ui-modernization-saved.luau')
local first=assert(source:find('local canonical = {',1,true))
local last=assert(source:find('local allowedSourceChanges',first,true))
local rows={'local canonical = {'}
for _,binding in bindings do table.insert(rows,string.format('\t{%q, %q, %s},',binding[1],binding[2],tostring(binding[3]~=nil))) end
table.insert(rows,'}\n')
source=source:sub(1,first-1)..table.concat(rows,'\n')..source:sub(last)
local function replace(old,new)
	local start,finish=assert(source:find(old,1,true))
	source=source:sub(1,start-1)..new..source:sub(finish+1)
end
replace('UIModernizationSavedValidation.1','AdminRedeemSavedValidation.1')
replace('HunDino_DarkJungle_v2_4.rbxl','HunDino_AdminTest_20261021.rbxl')
replace('backups/Hub_v24_before_ui_modernization_20261020.rbxl','backups/Hub_before_admin_redeem_20261021.rbxl')
replace('ServerStorage.UIBackup_20261020','ServerStorage.AdminCodeBackup_20261021')
replace('check(counts.parts == 43775 and counts.joints == 845, "Unexpected v2.4 saved Part/Joint totals")',
	'check(counts.parts == oldCounts.parts and counts.joints == oldCounts.joints, "Part/Joint totals changed")')
replace('check(counts.workspaceParts == 35064 and counts.workspaceJoints == 723, "Unexpected v2.4 Workspace Part/Joint totals")',
	'check(counts.workspaceParts == oldCounts.workspaceParts and counts.workspaceJoints == oldCounts.workspaceJoints, "Workspace Part/Joint totals changed")')
replace('assets/hunting/ui-modernization-saved.json','assets/redeem/admin-redeem-saved.json')
replace('UI modernization saved inspection failed','Admin redemption saved inspection failed')
luau.compile(source)
fs.writeFile('tools/inspect-admin-redeem-saved.luau',source)
print('PASS 7 compiled source bindings; generated source plan and read-only inspector')
