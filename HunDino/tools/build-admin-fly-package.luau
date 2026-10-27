-- Source-only native Studio import. Never serialize the place or its Terrain.
local fs=require("@lune/fs")
local r=require("@lune/roblox")
local luau=require("@lune/luau")
local baseline=r.deserializePlace(fs.readFile("backups/Hub_v24_before_admin_fly_20261019.rbxl"))
local package=r.Instance.new("Model");package.Name="AdminFlyInstall"
local sources=r.Instance.new("Folder");sources.Name="Sources";sources.Parent=package
local before=r.Instance.new("Folder");before.Name="Before";before.Parent=package
local files={Main="src/admin/AdminFly.server.luau",Client="src/admin/AdminFly.client.luau",
	AdminFlyPolicy="src/admin/AdminFlyPolicy.luau",TrainingServer="studio-pet-integration/Training.server.luau",
	TrainingClient="studio-pet-integration/Training.client.luau",DinosaurCombat="src/hunting/DinosaurCombat.luau"}
for name,file in files do
	local source=fs.readFile(file);luau.compile(source)
	local value=r.Instance.new("StringValue");value.Name=name;value.Value=source;value.Parent=sources
end
local sss=baseline:GetService("ServerScriptService")
local targets={TrainingServer=sss.HunDinoTraining,TrainingClient=baseline:GetService("StarterPlayer").StarterPlayerScripts.HunDinoTraining,
	DinosaurCombat=sss.HuntingRuntime.DinosaurCombat}
for name,target in targets do
	local v=r.Instance.new("StringValue");v.Name=name;v.Value=target.Source;v.Parent=before
end
local installer=r.Instance.new("ModuleScript");installer.Name="Installer"
installer.Source=[=[
return function(package)
	assert(not game:GetService("RunService"):IsRunning(),"Install in Edit")
	local sss=game:GetService("ServerScriptService")
	local sps=game:GetService("StarterPlayer").StarterPlayerScripts
	assert(not sss:FindFirstChild("AdminFly") and not sps:FindFirstChild("HunDinoAdminFly"),"Fly already installed")
	local targets={TrainingServer=sss.HunDinoTraining,TrainingClient=sps.HunDinoTraining,DinosaurCombat=sss.HuntingRuntime.DinosaurCombat}
	local function clean(s) return s:gsub("\r\n","\n"):gsub("\239\187\191",""):gsub("%s+$","") end
	for name,target in targets do assert(clean(target.Source)==clean(package.Before[name].Value),"Existing source changed: "..name) end
	local backup=Instance.new("Folder");backup.Name="AdminFlyBackup_20261019";backup.Parent=game:GetService("ServerStorage")
	for name,target in targets do local old=target:Clone();old.Name=name;old.Parent=backup;target.Source=package.Sources[name].Value end
	local folder=Instance.new("Folder");folder.Name="AdminFly"
	local policy=Instance.new("ModuleScript");policy.Name="AdminFlyPolicy";policy.Source=package.Sources.AdminFlyPolicy.Value;policy.Parent=folder
	local main=Instance.new("Script");main.Name="Main";main.Source=package.Sources.Main.Value;main.Parent=folder;folder.Parent=sss
	local client=Instance.new("LocalScript");client.Name="HunDinoAdminFly";client.Source=package.Sources.Client.Value;client.Parent=sps
	package:Destroy();print("ADMIN FLY INSTALLED: server policy + /fly + admin button")
end
]=]
luau.compile(installer.Source);installer.Parent=package
fs.writeDir("assets/admin")
fs.writeFile("assets/admin/AdminFlyInstall.rbxm",r.serializeModel({package}))
print("Source-only fly package compiled and written")
