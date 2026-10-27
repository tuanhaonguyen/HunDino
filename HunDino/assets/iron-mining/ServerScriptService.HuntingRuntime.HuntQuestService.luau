-- Solo mission coordinator; P1-E uses a server-memory economy adapter.
local HttpService = game:GetService("HttpService")
local CaptureController = require(script.Parent.HuntCaptureController)
local HarvestController = require(script.Parent.HuntHarvestController)
local IronMining=require(script.Parent.IronMiningService)
local Service = {}
Service.__index = Service
local function now() return workspace:GetServerTimeNow() end
local function alive(s)
	return s and s.Character and s.Character.Parent and s.Root and s.Root.Parent
		and s.Humanoid and s.Humanoid.Health > 0
end
local function set(player, key, value)
	if player.Parent and player:GetAttribute(key) ~= value then player:SetAttribute(key, value) end
end
function Service.new(options)
	local self = setmetatable({}, Service)
	for key, value in options do self[key] = value end
	self.Active = nil
	self.Mining=IronMining.new({Forest=self.Forest,Session=self.Session,PetFolder=self.PetFolder,GetState=self.GetState,
		GetEconomy=function() return self.Economy end,Message=self.Message})
	self:_createBoard()
	return self
end
function Service:Run(player)
	return if self.Active and self.Active.Player == player then self.Active.Run else nil
end
function Service:OwnsVisit(player)
	local run = self:Run(player)
	return run ~= nil and not run.Closed
end
function Service:ShouldResume(player)
	local run = self:Run(player)
	return run ~= nil and (run.State == "Hunting" or run.State == "Harvest")
end
function Service:CanEnter(player)
	if self.Active and not self.Active.Run.Closed and self.Active.Player ~= player then
		return false, "Đang có lượt săn thử solo. Hãy đợi người săn trở về sảnh."
	end
	return true
end
function Service:_publish(entry)
	local player, run = entry.Player, entry.Run
	set(player, "QuestRunId", run.Id); set(player, "QuestMonsterId", run.MonsterId)
	set(player, "QuestTarget", "T-REX · Không hệ")
	set(player, "QuestState", run.State); set(player, "QuestResult", run.Result)
	set(player, "QuestDeaths", run.Deaths); set(player, "QuestDeadline", run.Deadline)
	set(player, "QuestHarvestUntil", run.HarvestUntil or 0)
	set(player, "QuestFailureReason", run.FailureReason)
	set(player, "HuntTraps", run.Traps); set(player, "HuntPotions", run.Potions)
	if not run.Action then set(player, "HuntCaptureActive", false) end
	if entry.LastState ~= run.State then
		entry.LastState = run.State
		self.Remote:FireClient(player, "QuestState", self.Rules.snapshot(run, now()))
	end
end
function Service:_lobbyReady(player)
	local s = self.GetState(player)
	if not alive(s) or s.InTraining or s.InHunting or s.Travelling
		or s.Drawn or s.ChangeDraw ~= nil or s.Charge or s.Blocking or s.Sprinting
		or os.clock() < s.BusyUntil or player:GetAttribute("AdminFlying") == true then
		return false, "Về sảnh, cất vũ khí và dừng động tác để nhận nhiệm vụ."
	end
	if (s.Root.Position - self.Map.Lobby.Arrival.Position).Magnitude > 160 then
		return false, "Đến bảng nhiệm vụ ở sảnh trung tâm."
	end
	return true
end
function Service:OpenBoard(player)
	local ready, reason = self:_lobbyReady(player)
	if not ready then self.Message(player, reason); return false end
	local available = not self.Active or self.Active.Run.Closed
	if not available then reason = "Đang có lượt săn solo; hãy kết thúc lượt hiện tại trước." end
	if self.Session.Count > 0 then available = false; reason = "Khu săn đang có người thám hiểm. Đợi khu săn trống để bắt đầu lượt solo." end
	if available and player:GetAttribute("SpecimenFull")==true then reason="Kho cá thể đã đầy. Bạn vẫn nhận săn tiêu diệt được; hiện không thể bắt thêm." end
	self.Remote:FireClient(player, "QuestBoard", {CanAccept = available, Reason = reason})
	return true
end
function Service:_canUseItems(entry)
 if self.Economy and not self.Economy:IsReady(entry.Player) then return false end
	local s = self.GetState(entry.Player)
	return self.Active == entry and entry.Run.State == "Hunting" and alive(s) and s.InHunting
		and not s.Travelling and not s.Drawn and s.ChangeDraw == nil and not s.Charge
		and not s.Blocking and not s.Sprinting and os.clock() >= s.BusyUntil
		and os.clock() >= (s.DodgingUntil or 0) and entry.Player:GetAttribute("AdminFlying") ~= true
end
function Service:_capture(entry)
	if self.Active ~= entry or entry.Run.Result ~= "Captured" then return end
	assert(self.Combat:Capture(entry.Run.Id, entry.Run.FinishedAt), "Capture result must match the locked server monster")
	self:_result(entry)
end
function Service:_result(entry)
	if entry.ResultPublished then return end
	if self.Economy and not self.Economy:Result(entry.Player,entry.Run) then return end
 if self.Active~=entry then return end
	entry.ResultPublished = true
	self.Session:FreezeClock(entry.Player)
	self.Combat.Model:SetAttribute("QuestCombatAllowed", false)
	self.Combat:PlayerExited(entry.Player)
	if entry.Capture then entry.Capture:Cancel("Result") end
	set(entry.Player, "HuntCaptureActive", false)
	if self.OnResult then self.OnResult(entry.Player) end
	if entry.Run.State == "Failed" then entry.ReturnAfter = now() + 5 end
	self:_publish(entry)
end
function Service:Accept(player)
	local ready, reason = self:_lobbyReady(player)
	if not ready then self.Message(player, reason); return false end
	if self.Active and not self.Active.Run.Closed then self.Message(player, "Chỉ có một lượt săn thử solo tại một thời điểm."); return false end
	if self.Session.Count ~= 0 then self.Message(player, "Khu săn cần trống trước khi nhận nhiệm vụ solo."); return false end
	local run = self.Rules.new(HttpService:GenerateGUID(false), HttpService:GenerateGUID(false), now())
	if self.Economy then
		local prepared, reason = self.Economy:Begin(player,run)
		if not prepared then self.Message(player,reason); return false end
	end
	local entry = {Player = player, Run = run}
	self.Active = entry
	self.Combat.Model:SetAttribute("QuestOwnerUserId", player.UserId)
	self.Combat.Model:SetAttribute("QuestCombatAllowed", true)
	self.Combat.Model:SetAttribute("MonsterInstanceId", run.MonsterId)
	self:_publish(entry)
	task.spawn(function()
		local moved = self.Travel(player, "Hunting", nil, "Hạ hoặc bắt T-REX. Quặng ở phía bắc trại; đồ nhặt được giữ cả khi thua.")
		task.wait(.55)
		if self.Active ~= entry or run.Closed then return end
		local s = self.GetState(player)
		if not moved or not alive(s) or not s.InHunting then
			self.Rules.fail(run, "EntryInterrupted", now()); self:_result(entry); return
		end
		if not self.Rules.start(run, now()) then return end
		if self.Economy and not self.Economy:Start(player,run) then
			self.Rules.fail(run,"EntryInterrupted",now()); self:_result(entry); return
		end
		self.Session:RestartClock(player, self.Rules.Config.Duration)
		entry.Capture = CaptureController.new({
			Player = player, Run = run, Rules = self.Rules, Combat = self.Combat,
			Forest = self.Forest, PetFolder = self.PetFolder,
			Character = function() local state = self.GetState(player); return state and state.Character end,
			CanUseItems = function() return self:_canUseItems(entry) end,
			CanCapture = function() return self.Economy:CanCapture(player,run) end,
   OnItemsChanged = function() return self.Economy:Sync(player,run) end,
			OnCapture = function() self:_capture(entry) end,
			OnMessage = function(text) self.Message(player, text) end,
		})
		local harvestReady,harvest=pcall(HarvestController.new,{
			Player=player,Run=run,Combat=self.Combat,Forest=self.Forest,PetFolder=self.PetFolder,SkipOre=true,
			Character=function() local s=self.GetState(player);return s and s.Character end,
			CanInteract=function() return self:_canHarvest(entry) end,
			Grant=function(kind,sourceId,index) return self.Economy:Grant(player,run,kind,sourceId,index) end,
			OnMessage=function(text) self.Message(player,text) end,
		})
		if not harvestReady then
			warn("[P1-E] Harvest preparation failed",harvest)
			self.Rules.fail(run,"EntryInterrupted",now());self:_result(entry);return
		end
		entry.Harvest=harvest
		self:_publish(entry)
	end)
	return true
end
function Service:CancelAction(player, reason)
	self.Mining:CancelAction(player)
	local entry = self.Active
	if entry and entry.Player == player and entry.Capture then entry.Capture:Cancel(reason) end
	if entry and entry.Player == player and entry.Harvest then entry.Harvest:Cancel(reason) end
end
function Service:_canHarvest(entry)
	local s=self.GetState(entry.Player);local run=entry.Run
	return self.Active==entry and (run.State=="Hunting" or run.State=="Harvest") and alive(s) and s.InHunting
		and not s.Travelling and not s.Drawn and s.ChangeDraw==nil and not s.Charge and not s.Blocking
		and not s.Sprinting and os.clock()>=s.BusyUntil and os.clock()>=(s.DodgingUntil or 0)
		and entry.Player:GetAttribute("AdminFlying")~=true and not run.Action
end
function Service:HarvestAction(player,action)
	if action=="CarveStart" then self.Mining:CancelAction(player) end
	local entry=self.Active;if not entry or entry.Player~=player or not entry.Harvest then return end
	if action=="CarveStart" then entry.Harvest:RequestCarve(now()) else entry.Harvest:Cancel() end
end
function Service:ObserveDamage(player,beforeHP,afterHP)
	local entry=self.Active
	if entry and entry.Player==player and entry.Harvest then entry.Harvest:ObserveDamage(beforeHP,afterHP) end
end
function Service:ItemAction(player, action)
	if action=="TrapPlaceStart" or action=="CaptureStart" then self.Mining:CancelAction(player) end
	local entry = self.Active
	if not entry or entry.Player ~= player or not entry.Capture then return end
	if action == "TrapPlaceStart" then entry.Capture:RequestPlace(now())
	elseif action == "CaptureStart" then entry.Capture:RequestCapture(now())
	elseif action == "QuestActionCancel" then entry.Capture:Cancel() end
	self:_publish(entry)
end
function Service:PlayerDied(player)
	local entry = self.Active
	if not entry or entry.Player ~= player then return false end
	self:CancelAction(player, "Dead")
	local result = self.Rules.death(entry.Run, now())
	if result == "Camp" then
		self.Combat:PlayerExited(player)
		set(player, "QuestRespawnAt", now() + self.Rules.Config.RespawnDelay)
	elseif result == "Failed" then self:_result(entry) end
	self:_publish(entry)
	return result == "Camp"
end
function Service:CharacterReady(player)
	set(player, "QuestRespawnAt", 0)
end
function Service:_close(entry)
	if entry.Run.EconomyStarted and entry.Run.Result and not entry.ResultPublished then
		self:_result(entry);if not entry.ResultPublished then return false end
	end
	if self.Economy and not self.Economy:Close(entry.Player,entry.Run) then return false end
 if self.Active~=entry then return false end
	if entry.Capture then entry.Capture:Destroy(); entry.Capture = nil end
	if entry.Harvest then entry.Harvest:Destroy();entry.Harvest=nil end
	self.Rules.close(entry.Run)
	self.Combat.Model:SetAttribute("QuestOwnerUserId", nil)
	self.Combat.Model:SetAttribute("QuestCombatAllowed", nil)
	self.Combat.Model:SetAttribute("MonsterInstanceId", nil)
	self:_publish(entry)
	if self.Active == entry then self.Active = nil end
	return true
end
function Service:Return(player, reason)
	local entry = self.Active
	if not entry or entry.Player ~= player or entry.Returning then return false end
	local s = self.GetState(player)
	if not alive(s) then entry.ReturnAfter = now(); return false end
	if entry.Run.State == "Hunting" or entry.Run.State == "Preparing" then
		self.Rules.fail(entry.Run, reason or "Abandoned", now()); self:_result(entry)
	end
	entry.Returning = true
	self:CancelAction(player, "Return")
	task.spawn(function()
		local moved = self.Travel(player, "Lobby", nil, "Đã về sảnh. Nguyên liệu và vật tư dư ở kho thử trong phiên máy chủ.")
		if self.Active ~= entry then return end
		if moved and self:_close(entry) then return end
		entry.Returning = false; entry.ReturnAfter = now() + 1
	end)
	return true
end
function Service:BeforeTravel(player, destination)
	self:CancelAction(player, "Travel")
	local entry = self.Active
	if entry and entry.Player == player and destination ~= "Hunting" and not entry.Returning then
		self:Return(player, "Abandoned"); return false
	end
	return true
end
function Service:Step(dt)
 if self._stepping then return end
 self._stepping=true
 local ok,err=xpcall(function() self:_step(dt) end,debug.traceback)
 self._stepping=false
 if not ok then warn("[HunDino Quest]",err) end
end
function Service:_step(dt)
	self.Mining:Step()
	local entry = self.Active
	if not entry then return end
	local run, time = entry.Run, now()
	if not entry.Player.Parent then self:RemovePlayer(entry.Player); return end
	if run.State == "Hunting" and self.Combat:GetSnapshot().Health <= 0 then
		if self.Rules.finish(run, "Defeated", time) then self:_result(entry) end
	end
	self.Rules.tick(run, time)
	if entry.Capture then entry.Capture:Step(time, dt) end
	if entry.Harvest then entry.Harvest:Step(time,dt) end
	if self.Economy then self.Economy:Sync(entry.Player,run) end
	if run.Result and not entry.ResultPublished then self:_result(entry) end
	if run.State == "Returning" or (run.State == "Failed" and time >= (entry.ReturnAfter or math.huge)) then
		self:Return(entry.Player)
	end
	self:_publish(entry)
end
function Service:RemovePlayer(player)
	self.Mining:RemovePlayer(player)
	local entry = self.Active
 if entry and entry.Player==player and not self:_close(entry) and self.Active==entry then
  -- Disk recovery owns the reserved items if a last write is still pending.
  -- Release runtime ownership so a departed player cannot block everyone else.
  if entry.Capture then entry.Capture:Destroy();entry.Capture=nil end
  if entry.Harvest then entry.Harvest:Destroy();entry.Harvest=nil end
  self.Combat.Model:SetAttribute("QuestOwnerUserId",nil)
  self.Combat.Model:SetAttribute("QuestCombatAllowed",nil)
  self.Combat.Model:SetAttribute("MonsterInstanceId",nil)
  self.Active=nil
 end
end
function Service:_createBoard()
	local model = Instance.new("Model"); model.Name = "HuntQuestBoard"
	local origin = self.Map.Lobby.Arrival.CFrame * CFrame.new(-25, 0, -10)
	local function boardPart(name, size, offset, color)
		local p = Instance.new("Part"); p.Name = name; p.Size = size; p.Anchored = true
		p.CFrame = origin * CFrame.new(offset); p.Color = color; p.Material = Enum.Material.Wood
		p.Parent = model; return p
	end
	boardPart("PostL", Vector3.new(.7, 7, .7), Vector3.new(-3.5, 0, 0), Color3.fromRGB(64, 49, 34))
	boardPart("PostR", Vector3.new(.7, 7, .7), Vector3.new(3.5, 0, 0), Color3.fromRGB(64, 49, 34))
	local panel = boardPart("Board", Vector3.new(8, 4.2, .6), Vector3.new(0, 2, 0), Color3.fromRGB(60, 74, 51))
	local surface = Instance.new("SurfaceGui"); surface.Face = Enum.NormalId.Back; surface.CanvasSize = Vector2.new(600, 300); surface.Parent = panel
	local label = Instance.new("TextLabel"); label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold; label.TextSize = 36; label.TextWrapped = true
	label.TextColor3 = Color3.fromRGB(239, 229, 199); label.Text = "BẢNG NHIỆM VỤ\nSăn T-REX\nHạ hoặc bắt sống"; label.Parent = surface
	local prompt = Instance.new("ProximityPrompt"); prompt.ActionText = "Xem nhiệm vụ"; prompt.ObjectText = "Hội thợ săn"
	prompt.KeyboardKeyCode = Enum.KeyCode.G; prompt.MaxActivationDistance = 12; prompt.RequiresLineOfSight = false; prompt.Parent = panel
	self._boardConnection = prompt.Triggered:Connect(function(player)
		local s = self.GetState(player)
		if alive(s) and (s.Root.Position - panel.Position).Magnitude <= 13 then self:OpenBoard(player) end
	end)
	model.Parent = workspace; self._board = model
end
function Service:Destroy()
	self.Mining:Destroy()
	if self.Active then self:_close(self.Active) end
	if self._boardConnection then self._boardConnection:Disconnect() end
	if self._board then self._board:Destroy() end
end
return Service
