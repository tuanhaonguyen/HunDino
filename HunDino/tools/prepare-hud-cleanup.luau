-- Compile presentation sources and prepare a read-only native-save inspector.
-- Never serializes a Place or Terrain.
local fs=require('@lune/fs')
local luau=require('@lune/luau')
local serde=require('@lune/serde')
local process=require('@lune/process')
local includeExploration=table.find(process.args,'--include-exploration')~=nil

-- EXPLORATION MANIFEST VALIDATION BEGIN
local function loadExplorationBindings()
	-- Exact concurrent-change allowlist; a manifest cannot add arbitrary paths.
	local expected={
		{'ServerScriptService.HuntingRuntime.HuntQuestService','src/hunting/HuntQuestService.luau','ModuleScript',true,'QuestService'},
		{'ServerScriptService.HuntingRuntime.HuntHarvestController','src/hunting/HuntHarvestController.luau','ModuleScript',true,'HarvestController'},
		{'ServerScriptService.HuntingRuntime.HuntEconomyRules','src/hunting/HuntEconomyRules.luau','ModuleScript',true,'EconomyRules'},
		{'ServerScriptService.HuntingRuntime.HuntEconomyService','src/hunting/HuntEconomyService.luau','ModuleScript',true,'EconomyService'},
		{'ServerScriptService.AccountData.ProfileSchema','src/data/ProfileSchema.luau','ModuleScript',true,'ProfileSchema'},
		{'StarterPlayer.StarterPlayerScripts.HunDinoEconomy','src/hunting/HuntEconomy.client.luau','LocalScript',true,'HunDinoEconomy'},
		{'ServerScriptService.HuntingRuntime.ExplorationHarvestService','src/hunting/ExplorationHarvestService.luau','ModuleScript',false,'ExplorationHarvestService'},
	}
	local manifest=serde.decode('json',fs.readFile('assets/hunting/exploration-loot-install.json'))
	assert(type(manifest)=='table' and #manifest==7,'Expected exactly seven concurrent exploration bindings')
	local byPath={}
	for _,row in manifest do
		assert(type(row)=='table' and type(row.Path)=='string' and byPath[row.Path]==nil,'Invalid/duplicate concurrent binding')
		byPath[row.Path]=row
	end
	local ordered={}
	for _,binding in expected do
		local row=assert(byPath[binding[1]],'Missing concurrent exploration binding: '..binding[1])
		assert(row.File==binding[2] and row.Class==binding[3] and row.Key==binding[5]
			and row.Name==binding[1]:match('[^.]+$'),'Unexpected concurrent binding metadata: '..binding[1])
		local source=fs.readFile(binding[2])
		assert(type(row.Source)=='string' and row.Source==source,'Concurrent manifest Source differs from local file: '..binding[2])
		assert(row.SHA256==serde.hash('sha256',source),'Concurrent source hash differs: '..binding[2])
		assert((type(row.Baseline)=='string')==binding[4],'Concurrent existing/new classification differs: '..binding[1])
		if binding[4] then
			assert(row.BaselineSHA256==serde.hash('sha256',row.Baseline),'Concurrent baseline hash differs: '..binding[1])
		else
			assert(row.Baseline==nil and row.BaselineSHA256==nil,'New exploration service has a baseline')
		end
		luau.compile(source)
		row.Existing=binding[4]
		table.insert(ordered,row);byPath[binding[1]]=nil
	end
	assert(next(byPath)==nil,'Unexpected concurrent exploration binding outside the seven-path allowlist')
	return ordered
end
-- EXPLORATION MANIFEST VALIDATION END
local bindings={
 {'ReplicatedStorage.Shared.HubUI','src/dark-jungle/HubUI.luau','HubUI'},
 {'StarterPlayer.StarterPlayerScripts.HunDinoProfileStatus','src/data/ProfileStatus.client.luau','HunDinoProfileStatus'},
 {'StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest','src/hunting/HuntQuest.client.luau','HunDinoHuntQuest'},
 {'StarterPlayer.StarterPlayerScripts.HunDinoTraining','studio-pet-integration/Training.client.luau','HunDinoTraining'},
}
local plan={}
for _,row in bindings do
 local source=fs.readFile(row[2]);luau.compile(source)
 table.insert(plan,{Path=row[1],File=row[2],Source=source,
  Baseline=fs.readFile('backups/hud-cleanup-20261021/'..row[3]..'.luau'),SHA256=serde.hash('sha256',source)})
end
local concurrent=if includeExploration then loadExplorationBindings() else {}
if includeExploration then
 local baseline=fs.readFile('backups/Hub_before_hud_cleanup_20261021.rbxl')
 assert(#baseline==4285326,'Unexpected native HUD cleanup baseline size')
 assert(baseline==fs.readFile('backups/Hub_before_exploration_loot_20261021.rbxl'),
  'HUD cleanup and concurrent exploration baselines differ')
end
if not fs.isDir('assets/ui/hud-cleanup') then fs.writeDir('assets/ui/hud-cleanup') end
fs.writeFile('assets/ui/hud-cleanup/install.json',serde.encode('json',plan))
local source=fs.readFile('tools/inspect-ui-modernization-saved.luau')
local first=assert(source:find('local canonical = {',1,true))
local last=assert(source:find('local allowedSourceChanges',first,true))
local ownSource=fs.readFile('tools/prepare-hud-cleanup.luau')
local helperFirst=assert(ownSource:find('-- EXPLORATION MANIFEST VALIDATION BEGIN',1,true))
local helperLast=assert(ownSource:find('-- EXPLORATION MANIFEST VALIDATION END',helperFirst,true))
local rows={ownSource:sub(helperFirst,helperLast-1),'local canonical = {'}
for _,row in bindings do
 local class=if row[2]:find('.client.luau',1,true) then 'LocalScript' else 'ModuleScript'
 table.insert(rows,string.format('\t{%q, %q, true, %q},',row[1],row[2],class))
end
table.insert(rows,[=[}
local uiSourceChanges={}
for _,binding in canonical do uiSourceChanges[binding[1]]=true end
local concurrentPlan=if includeExploration then loadExplorationBindings() else {}
local concurrentByPath={}
report.concurrentExploration={enabled=includeExploration,manifest="assets/hunting/exploration-loot-install.json",allowlist={}}
for _,row in concurrentPlan do
	table.insert(canonical,{row.Path,row.File,row.Existing,row.Class})
	concurrentByPath[row.Path]=row
	table.insert(report.concurrentExploration.allowlist,{path=row.Path,file=row.File,existing=row.Existing,
		className=row.Class,sourceSha256=row.SHA256})
end
report.concurrentExploration.allowedBindings=#concurrentPlan
]=])
source=source:sub(1,first-1)..table.concat(rows,'\n')..source:sub(last)
local function replace(old,new)
 local a,b=source:find(old,1,true)
 assert(a,'Missing inspector anchor: '..old)
 source=source:sub(1,a-1)..new..source:sub(b+1)
end
replace('local baselineMode = table.find(process.args, "--baseline") ~= nil',
 'local baselineMode = table.find(process.args, "--baseline") ~= nil\nlocal includeExploration = table.find(process.args, "--include-exploration") ~= nil\nlocal explorationBackupPath = "ServerStorage.ExplorationLootBackup_20261021"')
replace('UIModernizationSavedValidation.1','HUDCleanupSavedValidation.2')
replace('HunDino_DarkJungle_v2_4.rbxl','HunDino_HUDClean_20261021.rbxl')
replace('backups/Hub_v24_before_ui_modernization_20261020.rbxl','backups/Hub_before_hud_cleanup_20261021.rbxl')
replace('ServerStorage.UIBackup_20261020','ServerStorage.HUDCleanupBackup_20261021')
replace('return path == backupPath or path:sub(1, #backupPath + 1) == backupPath .. "."',
 'return path == backupPath or path:sub(1, #backupPath + 1) == backupPath .. "."\n\t\tor (includeExploration and (path == explorationBackupPath or path:sub(1, #explorationBackupPath + 1) == explorationBackupPath .. "."))')
replace('object.ClassName == (if file:find(".client.luau", 1, true) then "LocalScript" else "ModuleScript")',
 'object.ClassName == binding[4]')
replace('check(row.matchesLocal, "Saved source differs/missing: " .. path .. " <- " .. file)',[=[check(row.matchesLocal, "Saved source differs/missing: " .. path .. " <- " .. file)
			local concurrent=concurrentByPath[path]
			if concurrent then
				check(object.Source==concurrent.Source,"Concurrent saved Source differs from exact local/manifest bytes: "..path)
				if existing then
					check(original and normalized(original.Source)==normalized(concurrent.Baseline),"Concurrent original source differs from native baseline: "..path)
				else
					check(original==nil,"New exploration service was present in baseline")
				end
			end]=])
replace('for path in allowedSourceChanges do remaining[path] = hash(normalized(assert(at(before, path)).Source)) end',
 'for path in uiSourceChanges do remaining[path] = hash(normalized(assert(at(before, path)).Source)) end')
replace('report.verifiedSourceBackups = count',
 'check(count == 4, "Expected exactly four original UI source backups")\n\treport.verifiedSourceBackups = count')
local concurrentVerifier=[=[local function verifyConcurrentExploration(saved,before)
	if not includeExploration then return end
	local folder=at(saved,explorationBackupPath)
	check(folder and folder:IsA("Folder"),"Missing concurrent exploration source backup folder")
	check(next(folder:GetAttributes())==nil and #folder:GetTags()==0,"Unexpected concurrent backup folder metadata")
	local expectedNames={}
	for _,row in concurrentPlan do
		if row.Existing then
			local original=assert(at(before,row.Path),"Missing native concurrent original: "..row.Path)
			check(original.ClassName==row.Class,"Concurrent original class differs: "..row.Path)
			expectedNames[original.Name]=original
		else
			local object=assert(at(saved,row.Path),"New exploration service missing")
			check(object.ClassName==row.Class and object.Name==row.Name,"Unexpected new exploration service class/name")
			check(#object:GetDescendants()==0 and next(object:GetAttributes())==nil and #object:GetTags()==0
				and object.Archivable==true,"Unexpected new exploration service descendants/metadata")
			check(at(before,row.Path)==nil,"Exploration service already existed in baseline")
		end
	end
	local children=folder:GetChildren()
	check(#children==6,"Expected exactly six concurrent original source backup StringValues")
	local verified,rows=0,{}
	for _,object in children do
		local original=expectedNames[object.Name]
		check(object:IsA("StringValue") and original~=nil,"Unexpected/duplicate concurrent source backup: "..object.Name)
		check(#object:GetDescendants()==0 and next(object:GetAttributes())==nil and #object:GetTags()==0,
			"Unexpected concurrent source backup descendants/metadata: "..object.Name)
		check(normalized(object.Value)==normalized(original.Source),"Concurrent source backup differs from native baseline: "..object.Name)
		table.insert(rows,{name=object.Name,bytes=#object.Value,sha256=hash(object.Value),
			matchesNormalizedNativeBaseline=true,rawBytesIdentical=object.Value==original.Source})
		expectedNames[object.Name]=nil;verified+=1
	end
	check(next(expectedNames)==nil,"Missing concurrent original source backup")
	report.concurrentExploration.verifiedSourceBackups=verified
	report.concurrentExploration.sourceBackups=rows
	report.concurrentExploration.backupSourcePolicy="Existing normalized source policy: CRLF/BOM/trailing whitespace only; native Terrain and instance properties remain strict"
end
]=]
replace('local function main()',concurrentVerifier..'local function main()')
replace('report.savedBytes, report.baselineBytes = #bytes, #beforeBytes',
 'report.savedBytes, report.baselineBytes = #bytes, #beforeBytes\n\tcheck(#beforeBytes == 4285326, "Unexpected native HUD cleanup baseline size")\n\tif includeExploration then check(beforeBytes == fs.readFile("backups/Hub_before_exploration_loot_20261021.rbxl"), "Concurrent exploration baseline differs") end')
replace('report.compiledScripts, report.baselineScripts = compiled, originals',
 'report.compiledScripts, report.baselineScripts = compiled, originals\n\tcheck(originals == 129, "Unexpected baseline source container count")\n\tcheck(compiled == (if includeExploration and not baselineMode then 130 else 129), "Unexpected saved source container count")')
replace('check(counts.parts == 43775 and counts.joints == 845, "Unexpected v2.4 saved Part/Joint totals")',
 'check(counts.parts == oldCounts.parts and counts.joints == oldCounts.joints and counts.parts == 43775 and counts.joints == 845, "Part/Joint totals changed")')
replace('check(counts.workspaceParts == 35064 and counts.workspaceJoints == 723, "Unexpected v2.4 Workspace Part/Joint totals")',
 'check(counts.workspaceParts == oldCounts.workspaceParts and counts.workspaceJoints == oldCounts.workspaceJoints and counts.workspaceParts == 35064 and counts.workspaceJoints == 723, "Workspace Part/Joint totals changed")')
replace('if not baselineMode then verifyBackups(saved, before) end',
 'if not baselineMode then verifyBackups(saved, before); verifyConcurrentExploration(saved,before) end')
replace('assets/hunting/ui-modernization-saved.json','assets/ui/hud-cleanup/saved.json')
replace('UI modernization saved inspection failed','HUD cleanup saved inspection failed')
replace('-- --baseline compares the untouched v2.4 save and reports local binding drift.',
 '-- --include-exploration admits exactly seven concurrent sources and verifies six native originals separately.')
replace('-- Default mode verifies the native Studio save, canonical sources and UI backups.',
 '-- Default mode admits only four UI sources; existing properties and opaque Terrain stay strict in both modes.')
luau.compile(source);fs.writeFile('tools/inspect-hud-cleanup-saved.luau',source)
print('PASS four UI sources compiled; UI-only plan and strict read-only inspector ready; concurrent exploration bindings:',#concurrent)
