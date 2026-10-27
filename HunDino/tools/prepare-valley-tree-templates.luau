-- Run only in Edit after the documented free Creator Store models are inserted
-- under ServerStorage.GreyMistImportedAssets. Retain source credit attributes.
local ss=game:GetService("ServerStorage")
local templates=ss:FindFirstChild("ValleyTreeTemplates") or Instance.new("Folder",ss)
templates.Name="ValleyTreeTemplates"
templates:ClearAllChildren()
local function worldBounds(model)
	local low,high=Vector3.one*1e8,-Vector3.one*1e8
	for _,p in model:GetDescendants() do if p:IsA("BasePart") then
		for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
			local v=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)*.5)
			low=low:Min(v);high=high:Max(v)
		end end end
	end end
	return low,high
end
local report={}
for _,spec in {{"pine","PonderosaPinePack_Letaij",100,"130515502281374"},
	{"birch","BirchTreePack_Letaij",78,"11351912067"},
	{"oak","OakTreePack_Letaij",88,"98950444096614"},
	{"willow","WillowTree_Northportinator",80,"131598559195257"}} do
	local group=Instance.new("Folder",templates);group.Name=spec[1]
	local source=ss.GreyMistImportedAssets[spec[2]]:GetChildren()[1]
	if source:IsA("BasePart") then
		local wrapper=Instance.new("Model");source:Clone().Parent=wrapper
		local container=Instance.new("Folder");wrapper.Parent=container;source=container
	end
	for _,src in source:GetChildren() do if src:IsA("Model") and src:FindFirstChildWhichIsA("BasePart",true) then
		local c=src:Clone();c.PrimaryPart=nil
		for _,p in c:GetDescendants() do
			if p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
				if p:IsA("MeshPart") then p.RenderFidelity=Enum.RenderFidelity.Automatic end
			elseif p:IsA("LuaSourceContainer") or p:IsA("Camera") or p:IsA("Sound") then p:Destroy() end
		end
		local low,high=worldBounds(c);c.WorldPivot=CFrame.new((low+high)/2)
		c:ScaleTo(spec[3]/(high.Y-low.Y))
		low,high=worldBounds(c)
		local base=Vector3.new((low.X+high.X)/2,low.Y,(low.Z+high.Z)/2)
		c:PivotTo(c:GetPivot()-base);c.WorldPivot=CFrame.identity
		c.Name=string.format("%s_%02d",spec[1],#group:GetChildren()+1)
		c:SetAttribute("SourceAssetId",spec[4]);c:SetAttribute("SourceCreator",if spec[1]=="willow" then "NORTHPORTINATOR" else "Letaij")
		c.Parent=group
	end end
	report[spec[1]]=#group:GetChildren()
end
return report
