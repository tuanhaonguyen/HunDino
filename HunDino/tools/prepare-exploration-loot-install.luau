-- Source plan and read-only native-save inspector only. Never serialize a Place.
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local serde=require('@lune/serde')
local roblox=require('@lune/roblox')
local baselineBytes=fs.readFile('backups/Hub_before_exploration_loot_20261021.rbxl')
assert(#baselineBytes==4285326,'Unexpected native exploration baseline size')
local baseline=roblox.deserializePlace(baselineBytes)
local function at(root,path)
	for name in path:gmatch('[^.]+') do root=root and root:FindFirstChild(name) end
	return root
end
local function normalized(source)
	return source:gsub('\r\n','\n'):gsub('^\239\187\191',''):gsub('%s+$','')
end
local trainingOriginal=fs.readFile('backups/exploration-loot-20261021/HunDinoTraining.luau')
luau.compile(trainingOriginal)
assert(normalized(assert(at(baseline,'ServerScriptService.HunDinoTraining')).Source)==normalized(trainingOriginal),
	'Read-only training server baseline source differs')
local bindings={
	{'ServerScriptService.HuntingRuntime.HuntQuestService','src/hunting/HuntQuestService.luau','HuntQuestService','QuestService','ModuleScript'},
	{'ServerScriptService.HuntingRuntime.HuntHarvestController','src/hunting/HuntHarvestController.luau','HuntHarvestController','HarvestController','ModuleScript'},
	{'ServerScriptService.HuntingRuntime.HuntEconomyRules','src/hunting/HuntEconomyRules.luau','HuntEconomyRules','EconomyRules','ModuleScript'},
	{'ServerScriptService.HuntingRuntime.HuntEconomyService','src/hunting/HuntEconomyService.luau','HuntEconomyService','EconomyService','ModuleScript'},
	{'ServerScriptService.AccountData.ProfileSchema','src/data/ProfileSchema.luau','ProfileSchema','ProfileSchema','ModuleScript'},
	{'StarterPlayer.StarterPlayerScripts.HunDinoEconomy','src/hunting/HuntEconomy.client.luau','HunDinoEconomy','HunDinoEconomy','LocalScript'},
	{'ServerScriptService.HuntingRuntime.ExplorationHarvestService','src/hunting/ExplorationHarvestService.luau',nil,'ExplorationHarvestService','ModuleScript'},
}
local plan={}
for _,binding in bindings do
	local source=fs.readFile(binding[2]);luau.compile(source)
	local original=if binding[3] then fs.readFile('backups/exploration-loot-20261021/'..binding[3]..'.luau') else nil
	local native=at(baseline,binding[1])
	if original then
		luau.compile(original)
		assert(native and native.ClassName==binding[5] and normalized(native.Source)==normalized(original),
			'Native original backup differs: '..binding[1]..' (native '..tostring(native and #native.Source)..' / file '..#original..' bytes)')
	else
		assert(native==nil,'New exploration service already exists in baseline')
	end
	table.insert(plan,{Path=binding[1],File=binding[2],Key=binding[4],Name=binding[1]:match('[^.]+$'),
		Source=source,Baseline=original,Class=binding[5],SHA256=serde.hash('sha256',source),
		BaselineSHA256=if original then serde.hash('sha256',original) else nil})
end
if not fs.isDir('assets/hunting') then fs.writeDir('assets/hunting') end
fs.writeFile('assets/hunting/exploration-loot-install.json',serde.encode('json',plan))

-- Reuse exact reflected property comparisons and opaque native Terrain hashes.
local source=fs.readFile('tools/inspect-admin-redeem-saved.luau')
local first=assert(source:find('local canonical = {',1,true))
local last=assert(source:find('local allowedSourceChanges',first,true))
local rows={'local canonical = {'}
for _,binding in bindings do
	table.insert(rows,string.format('\t{%q, %q, %s, %q},',binding[1],binding[2],tostring(binding[3]~=nil),binding[5]))
end
table.insert(rows,'}\n')
source=source:sub(1,first-1)..table.concat(rows,'\n')..source:sub(last)
local function replace(old,new)
	local start,finish=source:find(old,1,true)
	assert(start,'Missing inspector anchor: '..old)
	source=source:sub(1,start-1)..new..source:sub(finish+1)
end
replace('AdminRedeemSavedValidation.1','ExplorationLootSavedValidation.1')
replace('HunDino_AdminTest_20261021.rbxl','HunDino_ExplorationLoot_20261021.rbxl')
replace('backups/Hub_before_admin_redeem_20261021.rbxl','backups/Hub_before_exploration_loot_20261021.rbxl')
replace('ServerStorage.AdminCodeBackup_20261021','ServerStorage.ExplorationLootBackup_20261021')
replace('object.ClassName == (if file:find(".client.luau", 1, true) then "LocalScript" else "ModuleScript")',
	'object.ClassName == binding[4]')
replace('check(row.matchesLocal, "Saved source differs/missing: " .. path .. " <- " .. file)',[[check(row.matchesLocal, "Saved source differs/missing: " .. path .. " <- " .. file)
			if existing then
				check(original and source ~= normalized(original.Source), "Expected original source change missing: " .. path)
			else
				check(original == nil, "New exploration service was present in baseline")
			end]])
replace('check(counts.parts == oldCounts.parts and counts.joints == oldCounts.joints, "Part/Joint totals changed")',
	'check(counts.parts == oldCounts.parts and counts.joints == oldCounts.joints and counts.parts == 43775 and counts.joints == 845, "Part/Joint totals changed")')
replace('check(counts.workspaceParts == oldCounts.workspaceParts and counts.workspaceJoints == oldCounts.workspaceJoints, "Workspace Part/Joint totals changed")',
	'check(counts.workspaceParts == oldCounts.workspaceParts and counts.workspaceJoints == oldCounts.workspaceJoints and counts.workspaceParts == 35064 and counts.workspaceJoints == 723, "Workspace Part/Joint totals changed")')
replace('assets/redeem/admin-redeem-saved.json','assets/hunting/exploration-loot-saved.json')
replace('Admin redemption saved inspection failed','Exploration loot saved inspection failed')
replace('report.savedBytes, report.baselineBytes = #bytes, #beforeBytes',
	'report.savedBytes, report.baselineBytes = #bytes, #beforeBytes\n\tcheck(#beforeBytes == 4285326, "Unexpected native exploration baseline size")')
replace('report.compiledScripts, report.baselineScripts = compiled, originals',
	'report.compiledScripts, report.baselineScripts = compiled, originals\n\tcheck(originals == 129, "Unexpected baseline source container count")\n\tcheck(compiled == (if baselineMode then 129 else 130), "Unexpected saved source container count")')

local backupFirst=assert(source:find('local function verifyBackups(saved, before)',1,true))
local backupLast=assert(source:find('local function main()',backupFirst,true))
local backupVerifier=[=[local function verifyBackups(saved, before)
	local folder = at(saved, backupPath)
	check(folder and folder:IsA("Folder"), "Missing exploration source backup folder: " .. backupPath)
	check(next(folder:GetAttributes()) == nil and #folder:GetTags() == 0, "Unexpected backup folder metadata")
	local children, expectedNames = folder:GetChildren(), {}
	for path in allowedSourceChanges do
		local original = assert(at(before, path))
		expectedNames[original.Name] = original
	end
	check(#children == 6, "Expected six original source backup StringValues")
	local verified = 0
	for _, object in children do
		local original = expectedNames[object.Name]
		check(object:IsA("StringValue") and original ~= nil, "Unexpected or duplicate source backup: " .. object.Name)
		check(#object:GetDescendants() == 0 and next(object:GetAttributes()) == nil and #object:GetTags() == 0,
			"Unexpected source backup descendants or metadata: " .. object.Name)
		check(normalized(object.Value) == normalized(original.Source), "Original source backup differs: " .. object.Name)
		expectedNames[object.Name] = nil
		verified += 1
	end
	check(next(expectedNames) == nil, "Missing exploration source backup")
	report.verifiedSourceBackups = verified
	for path in expectedNewSources do
		local object = assert(at(saved, path), "New exploration service missing")
		check(object:IsA("ModuleScript") and #object:GetDescendants() == 0, "Unexpected new exploration service class/descendants")
		check(next(object:GetAttributes()) == nil and #object:GetTags() == 0 and object.Archivable,
			"Unexpected new exploration service metadata")
		check(at(before, path) == nil, "Exploration service already existed in baseline")
	end
end
]=]
source=source:sub(1,backupFirst-1)..backupVerifier..source:sub(backupLast)
-- The server training source is deliberately read-only in this installation.
replace('report.trainingCandidates = {}',[[report.trainingServerUnchanged = normalized(assert(at(saved, "ServerScriptService.HunDinoTraining")).Source)
		== normalized(assert(at(before, "ServerScriptService.HunDinoTraining")).Source)
	check(report.trainingServerUnchanged, "Original training server changed")
	report.trainingCandidates = {}]])
replace('-- --baseline compares the untouched v2.4 save and reports local binding drift.',
	'-- --baseline compares a separately saved copy of the untouched baseline; default verifies installation.')
replace('-- Default mode verifies the native Studio save, canonical sources and UI backups.',
	'-- Default verifies the native Studio save, seven canonical bindings and six original source backups.')
luau.compile(source)
fs.writeFile('tools/inspect-exploration-loot-saved.luau',source)
print('PASS 7 compiled exploration source bindings; source plan and strict read-only inspector ready')
