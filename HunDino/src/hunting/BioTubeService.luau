-- Server-authoritative slots; static scenery is authored in Edit and reused at runtime.
local Geometry = require(script.Parent.BioTubeGeometry)
local Specimen = require(script.Parent.BioTubeSpecimen)
local Service = {}
Service.__index = Service
local OFFSETS = {[1]=Vector3.new(-28,0,-10),[2]=Vector3.new(-15,0,0),
	[3]=Vector3.new(15,0,0),[4]=Vector3.new(28,0,-10),[5]=Vector3.new(0,0,5)}
local ANGLES = {[1]=22,[2]=11,[3]=-11,[4]=-22,[5]=0}

function Service.buildWorld()
	local existing=workspace:FindFirstChild("SpecimenTubeDisplays")
	if existing and existing:GetAttribute("GeometryVersion")==Geometry.Version then return existing end
	if existing then existing:Destroy() end
	local world=Instance.new("Folder");world.Name="SpecimenTubeDisplays"
	world:SetAttribute("GeometryVersion",Geometry.Version)
	world:SetAttribute("SystemVersion","P1-F.2")
	local bases=workspace:WaitForChild("DarkJungle"):WaitForChild("Bases")
	for id=1,12 do
		local base=assert(bases:FindFirstChild("Base"..id),"Missing base "..id)
		local spawn=assert(base:FindFirstChild("SpawnPad"),"Missing SpawnPad")
		local shelter=assert(base:FindFirstChild("ShelterFloor"),"Missing existing shelter")
		local origin=Geometry.clusterFrame(spawn.Position,shelter.Position,id)
		local cluster=Instance.new("Model");cluster.Name="Base"..id
		cluster:SetAttribute("BaseId",id);cluster:SetAttribute("ClusterOrigin",origin);cluster.Parent=world
		for slot=1,5 do
			local tube=Geometry.build(cluster,origin*CFrame.new(OFFSETS[slot])*CFrame.Angles(0,math.rad(ANGLES[slot]),0),slot)
			tube:SetAttribute("BaseId",id)
		end
	end
	world.Parent=workspace
	return world
end

function Service.new(economy,template)
	local self=setmetatable({Economy=economy,Template=template,World=Service.buildWorld(),Connections={},Players={}},Service)
	for _,cluster in self.World:GetChildren() do
		local id=cluster:GetAttribute("BaseId")
		-- Authored files never contain a player's specimen. Clear any stale local preview.
		for slot=1,5 do
			local tube=cluster:FindFirstChild("BioTube_"..slot)
			local old=tube:FindFirstChild("SpecimenAssembly");if old then old:Destroy() end
			tube:SetAttribute("SpecimenId",nil);tube:SetAttribute("OwnerUserId",nil)
			local prompt=tube.Interaction.SpecimenTubePrompt
			table.insert(self.Connections,prompt.Triggered:Connect(function(player)
				if player:GetAttribute("BaseId")~=id then economy:_notice(player,"Đây là ống nghiệm của base khác.");return end
				if not self:CanUse(player,slot) then economy:_notice(player,"Đến gần ống nghiệm của bạn, cất vũ khí bằng R và dừng động tác.");return end
				economy:Publish(player,nil,"Inventory")
				economy.Remote:FireClient(player,"OpenSpecimenTube",{Slot=slot})
			end))
		end
	end
	return self
end

function Service:CanUse(player,slot)
	if type(slot)~="number" or slot%1~=0 or slot<1 or slot>5 then return false end
	if not self.Economy:_quiet(player) then return false end
	local state=self.Economy.GetState(player)
	local profile=self.Economy:Profile(player)
	if state.InHunting or state.InTraining or not profile or profile.ActiveRun then return false end
	local cluster=self.World:FindFirstChild("Base"..tostring(player:GetAttribute("BaseId")))
	local tube=cluster and cluster:FindFirstChild("BioTube_"..slot)
	return tube~=nil and (state.Root.Position-tube.Interaction.Position).Magnitude<=13
end

function Service:Clear(player)
	local id=self.Players[player];self.Players[player]=nil
	local cluster=id and self.World:FindFirstChild("Base"..id)
	if not cluster or cluster:GetAttribute("OwnerUserId")~=player.UserId then return end
	cluster:SetAttribute("OwnerUserId",nil)
	for _,tube in cluster:GetChildren() do
		local assembly=tube:FindFirstChild("SpecimenAssembly");if assembly then assembly:Destroy() end
		tube:SetAttribute("SpecimenId",nil);tube:SetAttribute("OwnerUserId",nil)
	end
end

function Service:Sync(player,profile)
	local id=player:GetAttribute("BaseId")
	if self.Players[player] and self.Players[player]~=id then self:Clear(player) end
	local cluster=self.World:FindFirstChild("Base"..tostring(id));if not cluster then return end
	self.Players[player]=id;cluster:SetAttribute("OwnerUserId",player.UserId)
	for slot=1,5 do
		local tube=cluster:FindFirstChild("BioTube_"..slot)
		local specimenId=profile.DisplaySlots and profile.DisplaySlots[slot]
		if tube:GetAttribute("SpecimenId")==specimenId and tube:GetAttribute("OwnerUserId")==player.UserId then continue end
		local old=tube:FindFirstChild("SpecimenAssembly");if old then old:Destroy() end
		tube:SetAttribute("SpecimenId",nil);tube:SetAttribute("OwnerUserId",player.UserId)
		local record=specimenId and profile.OwnedSpecimens[specimenId]
		if record then
			local ok,result=pcall(Specimen.mount,tube,self.Template,record)
			if ok then tube:SetAttribute("SpecimenId",specimenId)
			else warn("[BioTubes] Could not mount specimen",id,slot,result) end
		end
	end
end

function Service:Destroy()
	for _,connection in self.Connections do connection:Disconnect() end
	for player in self.Players do self:Clear(player) end
	self.Connections={}
end
return Service
