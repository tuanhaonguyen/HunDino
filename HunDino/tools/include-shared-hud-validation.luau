-- Apply after prepare-exploration-loot-install. Only edits the inspector text.
-- The concurrently installed HUD changes must be verified, never silently masked.
local fs=require("@lune/fs")
local luau=require("@lune/luau")
local path="tools/inspect-exploration-loot-saved.luau"
local source=fs.readFile(path)
assert(not source:find("local concurrentHUD",1,true),"Shared HUD checks already installed")
local function replace(old,new)
	local a,b=source:find(old,1,true);assert(a,"Missing inspector anchor")
	source=source:sub(1,a-1)..new..source:sub(b+1)
end
local marker="local reflection = roblox.getReflectionDatabase()"
replace(marker,[=[local concurrentHUD = {
	{"ReplicatedStorage.Shared.HubUI","src/dark-jungle/HubUI.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoTraining","studio-pet-integration/Training.client.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoHuntQuest","src/hunting/HuntQuest.client.luau"},
	{"StarterPlayer.StarterPlayerScripts.HunDinoProfileStatus","src/data/ProfileStatus.client.luau"},
}
local concurrentPaths={}
for _,row in concurrentHUD do allowedSourceChanges[row[1]]=true;concurrentPaths[row[1]]=true end
local concurrentBackup="ServerStorage.HUDCleanupBackup_20261021"
]=]..marker)
replace('return path == backupPath or path:sub(1, #backupPath + 1) == backupPath .. "."',
	'return path == backupPath or path:sub(1, #backupPath + 1) == backupPath .. "."\n\t\tor path==concurrentBackup or path:sub(1,#concurrentBackup+1)==concurrentBackup.."."')
replace('for path in allowedSourceChanges do\n\t\tlocal original = assert(at(before, path))',
	'for path in allowedSourceChanges do\n\t\tif concurrentPaths[path] then continue end\n\t\tlocal original = assert(at(before, path))')
replace('if not baselineMode then verifyBackups(saved, before) end',[=[if not baselineMode then
		verifyBackups(saved, before)
		local folder=assert(at(saved,concurrentBackup),"Shared HUD backup missing")
		check(folder:IsA("Folder") and #folder:GetChildren()==4,"Expected exactly four shared HUD backups")
		check(next(folder:GetAttributes())==nil and #folder:GetTags()==0,"Shared HUD backup metadata changed")
		local rows={}
		for _,binding in concurrentHUD do
			local original=assert(at(before,binding[1]))
			local current=assert(at(saved,binding[1]))
			local backup=assert(folder:FindFirstChild(original.Name))
			check(current.ClassName==original.ClassName,"Shared HUD class mismatch")
			check(normalized(current.Source)==normalized(fs.readFile(binding[2])),"Shared HUD source differs from canonical: "..binding[1])
			check(backup:IsA("StringValue") and normalized(backup.Value)==normalized(original.Source),"Shared HUD original backup mismatch")
			local attributes=backup:GetAttributes()
			check(#backup:GetDescendants()==0 and attributes.OriginalPath==binding[1] and #backup:GetTags()==0,"Shared HUD backup shape mismatch")
			for key in attributes do check(key=="OriginalPath","Unexpected shared HUD backup attribute") end
			table.insert(rows,{path=binding[1],source=binding[2],sha256=hash(normalized(current.Source)),originalBackupVerified=true})
		end
		report.concurrentHUDChanges={sources=rows,verifiedBackups=4,reason="HUD cleanup installed concurrently in the same Studio; verified independently and preserved"}
	end]=])
luau.compile(source);fs.writeFile(path,source)
print("Inspector now verifies four concurrent canonical HUD sources and their original backups")
