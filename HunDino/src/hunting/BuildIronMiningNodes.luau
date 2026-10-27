-- Add only the mining folder. Terrain, paths, existing props and AI stay intact.
local Config=require(script.Parent.IronMiningConfig)
local Ore=require(script.Parent.IronOreVisual)
local Builder={}
function Builder.build(forest)
	assert(forest and (forest:IsA("Folder") or forest:IsA("Model")),"Expected hunting forest")
	assert(not forest:FindFirstChild(Config.FolderName),"Mining sites already exist; preserve edits")
	local folder=Instance.new("Folder");folder.Name=Config.FolderName;folder:SetAttribute("Version",Config.Version);folder.Parent=forest
	local ok,err=xpcall(function()
		for index,row in Config.Nodes do
			local model=Ore.build(row.Id,index);model.Name=row.Id
			model:SetAttribute("MiningNodeIndex",index);model:SetAttribute("LocationName",row.Name)
			model:PivotTo(CFrame.new(row.Position)*CFrame.Angles(0,math.rad(row.Yaw),0));model.Parent=folder
			if index%5==0 then task.wait() end
		end
	end,debug.traceback)
	if not ok then folder:Destroy();error(err,2) end
	return folder
end
return Builder
