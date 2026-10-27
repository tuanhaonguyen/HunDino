-- Exploration has corpse loot without creating a mission or reserving supplies.
local HttpService=game:GetService("HttpService")
local Harvest=require(script.Parent.HuntHarvestController)
local Service={};Service.__index=Service
local function now() return workspace:GetServerTimeNow() end
local function set(p,key,value) if p.Parent and p:GetAttribute(key)~=value then p:SetAttribute(key,value) end end
local function living(s)
	return s and s.Character and s.Character.Parent and s.Root and s.Root.Parent and s.Humanoid and s.Humanoid.Health>0
end
function Service.new(options)
	local self=setmetatable({Entries={}},Service)
	for key,value in options do self[key]=value end
	return self
end
function Service:_cycle()
	local patrol=self.Session.Patrol
	if not patrol then return nil end
	if not self.Encounter or self.Encounter.Patrol~=patrol then
		self.Encounter={Id=HttpService:GenerateGUID(false),Patrol=patrol,Participants={},Reserved={}}
	end
	return self.Encounter
end
function Service:ObserveDamage(player,beforeHP,afterHP)
	-- Called by validated player/Pet damage. Never yield inside the combat callback.
	if self.Stopped or self.IsMission() or type(beforeHP)~="number" or type(afterHP)~="number"
		or beforeHP<=0 or afterHP>=beforeHP then return end
	local visit=self.Session.Players[player];local state=self.GetState(player)
	if not visit or not living(state) or not state.InHunting then return end
	local encounter=self:_cycle();if not encounter or encounter.Dead then return end
	encounter.Participants[player]=visit
	if afterHP<=0 then encounter.Dead=true;encounter.Until=now()+120 end
end
function Service:_present(entry)
	return not self.Stopped and not entry.Closing and not self.IsMission() and entry.Player.Parent
		and self.Entries[entry.Player]==entry and self.Session.Patrol==entry.Encounter.Patrol
		and self.Session.Players[entry.Player]==entry.Visit and now()<=entry.Run.HarvestUntil
		and self.Combat:GetSnapshot().Health<=0
end
function Service:_canInteract(entry)
	local s=self.GetState(entry.Player);local economy=self.GetEconomy()
	return self:_present(entry) and economy and economy:IsReady(entry.Player) and living(s) and s.InHunting
		and not s.Travelling and not s.Drawn and s.ChangeDraw==nil and not s.Charge and not s.Blocking
		and not s.Sprinting and os.clock()>=s.BusyUntil and os.clock()>=(s.DodgingUntil or 0)
		and entry.Player:GetAttribute("AdminFlying")~=true
end
function Service:_clear(entry)
	if entry.Harvest then entry.Harvest:Destroy();entry.Harvest=nil end
	set(entry.Player,"HuntExplorationHarvest",false);set(entry.Player,"HuntLootRunId",nil)
	set(entry.Player,"HuntLootUntil",0)
end
function Service:_discardDeparted(entry)
	-- Profile release/recovery owns any unacknowledged durable claim. Do not
	-- retain a disconnected Player while retrying against a released profile.
	self:_clear(entry);entry.Run.Closed=true
	entry.Encounter.Participants[entry.Player]=nil
	if self.Entries[entry.Player]==entry then self.Entries[entry.Player]=nil end
end
function Service:_close(entry)
	entry.Closing=true
	if entry.Busy then return false end
	self:_clear(entry)
	local economy=self.GetEconomy();if not economy then return false end
	entry.Busy=true
	local ok,closed=pcall(economy.CloseExploration,economy,entry.Player,entry.Run)
	entry.Busy=false
	if ok and closed then
		entry.Run.Closed=true
		if self.Entries[entry.Player]==entry then self.Entries[entry.Player]=nil end
		return true
	end
	return false
end
function Service:_prepare(entry)
	entry.Busy=true;entry.NextTry=now()+2
	task.spawn(function()
		local ok,ready=pcall(function() return self.GetEconomy():PrepareExploration(entry.Player,entry.Run) end)
		entry.Busy=false
		if not ok then warn("[Exploration loot] Preparation failed",ready) end
		if not self:_present(entry) then entry.Closing=true;return end
		if not ok or not ready then return end
		local made,controller=pcall(Harvest.new,{
			Player=entry.Player,Run=entry.Run,Combat=self.Combat,Forest=self.Forest,PetFolder=self.PetFolder,SkipOre=true,
			Character=function() local s=self.GetState(entry.Player);return s and s.Character end,
			CanInteract=function() return self:_canInteract(entry) end,
			Grant=function(kind,sourceId,index)
				if kind~="Carve" or entry.Busy or not self:_present(entry) then return false end
				entry.Busy=true
				local called,granted,receipt=pcall(function() return self.GetEconomy():Grant(entry.Player,entry.Run,kind,sourceId,index) end)
				entry.Busy=false
				return called and granted==true,receipt
			end,
			OnMessage=function(text) self.Message(entry.Player,text) end,
		})
		if not made then warn("[Exploration loot] Corpse preparation failed",controller);entry.Closing=true;return end
		entry.Harvest=controller
		set(entry.Player,"HuntLootRunId",entry.Run.Id);set(entry.Player,"HuntLootUntil",entry.Run.HarvestUntil)
		set(entry.Player,"HuntExplorationHarvest",true)
		self.Message(entry.Player,"Đã hạ T-Rex khi khám phá. Đến gần xác, nhấn R cất vũ khí và giữ G 1,5 giây để mổ; tối đa 3 lượt. Nguyên liệu vào Inventory → Vật phẩm.")
	end)
end
function Service:Step(dt)
	local encounter=self:_cycle()
	if encounter and encounter.Dead and now()<=encounter.Until and not self.IsMission() then
		for player,visit in encounter.Participants do
			if not encounter.Reserved[player.UserId] and player.Parent and self.Session.Players[player]==visit then
				encounter.Reserved[player.UserId]=true
				local entry={Player=player,Visit=visit,Encounter=encounter,Run={Id=HttpService:GenerateGUID(false),
					MonsterId=encounter.Id,Mode="Exploration",State="Harvest",Result="Defeated",Traps=0,Potions=0,
					HarvestUntil=encounter.Until}}
				self.Entries[player]=entry
			end
		end
	end
	for _,entry in self.Entries do
		if not entry.Busy then
			if entry.Departed then self:_discardDeparted(entry)
			elseif not self:_present(entry) then
				if now()>=(entry.NextClose or 0) then entry.NextClose=now()+2;self:_close(entry) end
			elseif entry.Harvest then entry.Harvest:Step(now(),dt)
			elseif now()>=(entry.NextTry or 0) then self:_prepare(entry) end
		end
	end
end
function Service:CancelAction(player,reason)
	local entry=self.Entries[player];if entry and entry.Harvest then entry.Harvest:Cancel(reason) end
end
function Service:HarvestAction(player,action)
	local entry=self.Entries[player]
	if not entry or not entry.Harvest or not self:_present(entry) then return end
	if action=="CarveStart" then entry.Harvest:RequestCarve(now()) else entry.Harvest:Cancel() end
end
function Service:BeforeTravel(player,destination)
	local entry=self.Entries[player]
	if not entry or (destination=="Hunting" and self:_present(entry)) then return true end
	if self:_close(entry) then return true end
	self.Message(player,"Đang ghi nguyên liệu khám phá. Hãy chờ lưu xong rồi thử di chuyển lại.")
	return false
end
function Service:RemovePlayer(player)
	local entry=self.Entries[player]
	if entry then
		entry.Departed=true;self:_close(entry)
		if not entry.Busy then self:_discardDeparted(entry) end
	end
end
function Service:Destroy()
	self.Stopped=true
	for _,entry in self.Entries do self:_close(entry) end
end
return Service
