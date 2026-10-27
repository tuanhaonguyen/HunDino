local fs=require('@lune/fs')
local r=require('@lune/roblox')
local serde=require('@lune/serde')
local root=r.deserializePlace(fs.readFile('HunDino_MerchantWeapons_20261026.rbxl'))
local ws=root:GetService('Workspace')
local data=root:GetService('ServerScriptService').AccountData
local world=ws.SpecimenTubeDisplays
local report={Bytes=#fs.readFile('HunDino_MerchantWeapons_20261026.rbxl'),Version=world:GetAttribute('GeometryVersion'),
 Layout=world:GetAttribute('LayoutVersion'),TestMemory=data:GetAttribute('StudioMemoryTest'),
 OriginalTest=data:GetAttribute('BaseClearanceQAOriginalTest'),HasProbe=root:GetService('ServerScriptService'):FindFirstChild('BaseClearanceQA')~=nil,
 HasBackup=root:GetService('ServerStorage'):FindFirstChild('BaseClearanceBackup_20261027')~=nil,
 GeometryVersion=root:GetService('ServerScriptService').HuntingRuntime.BioTubeGeometry.Source:match('BioTubeGeometry%.%d+')}
print(serde.encode('json',report,true))
