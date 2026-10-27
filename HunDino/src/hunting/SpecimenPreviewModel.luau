-- Static presentation only. Build before the live creature shrinks or fades.
local CollectionService=game:GetService("CollectionService")
local Preview={}
function Preview.build(source)
	assert(source and source:IsA("Model"),"Missing specimen visual source")
	local archivable=source.Archivable;source.Archivable=true
	local model=source:Clone();source.Archivable=archivable
	assert(model,"Could not clone specimen visual")
	model.Name="TRex"
	local hurtboxes=model:FindFirstChild("CombatHitboxes");if hurtboxes then hurtboxes:Destroy() end
	local function clear(object)
		for key in object:GetAttributes() do
			local ok,err=pcall(object.SetAttribute,object,key,nil)
			-- Roblox can attach protected provenance metadata to imported art.
			if not ok then assert(key:sub(1,4)=="RBX_" and tostring(err):find("permission",1,true),err) end
		end
		for _,tag in CollectionService:GetTags(object) do CollectionService:RemoveTag(object,tag) end
	end
	clear(model)
	for _,object in model:GetDescendants() do
		if not object.Parent then continue end
		if not (object:IsA("Model") or object:IsA("Folder") or object:IsA("BasePart")
			or object:IsA("DataModelMesh") or object:IsA("SurfaceAppearance") or object:IsA("Decal")
			or object:IsA("Texture") or object:IsA("Bone")) then object:Destroy();continue end
		clear(object)
		if object:IsA("BasePart") then
			object.Anchored=true;object.CanCollide=false;object.CanTouch=false;object.CanQuery=false
			object.AssemblyLinearVelocity=Vector3.zero;object.AssemblyAngularVelocity=Vector3.zero
		end
	end
	model:PivotTo(CFrame.new())
	model:SetAttribute("SpeciesId","TRex");model:SetAttribute("TemplateScale",model:GetScale())
	model:SetAttribute("SpecimenPreviewVersion",1)
	return model
end
return Preview
