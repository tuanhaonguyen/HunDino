-- Server-owned economy. Account storage commits before acknowledging mutations.
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Economy = require(script.Parent.HuntEconomyRules)
local Preview = require(script.Parent.SpecimenPreviewModel)
local Service = {}
Service.__index = Service
local NAMES = {Skin="da", Tooth="răng", Scale="vảy", Bone="xương", Iron="sắt"}
local ERRORS = {InsufficientCoins="Không đủ xu.", InsufficientMaterials="Không đủ nguyên liệu.",
	InsufficientItems="Không đủ vật dụng.", MaximumLevel="Búa đã đạt cấp 2 trong bản thử.", ActiveRun="Hãy kết thúc lượt săn trước."}
local function actor(s)
	return s and s.Character and s.Character.Parent and s.Root and s.Root.Parent and s.Humanoid and s.Humanoid.Health > 0
end
local function set(p, name, value) if p.Parent and p:GetAttribute(name) ~= value then p:SetAttribute(name, value) end end
function Service.new(options)
	local self = setmetatable({Profiles={}, Offers={}, LastRequest={}, Connections={}, Random=Random.new(), Stations={}}, Service)
	for key, value in options do self[key] = value end
	self.Remote = Instance.new("RemoteEvent"); self.Remote.Name="HunDinoEconomyAction"; self.Remote.Parent=ReplicatedStorage
	table.insert(self.Connections, self.Remote.OnServerEvent:Connect(function(p, action, token) self:Request(p, action, token) end))
	self:_stations()
	local visuals=Instance.new("Folder");visuals.Name="SpecimenVisuals"
	local template=Preview.build(workspace:WaitForChild("Dinosaur01_TRex_Visual"))
	template.Parent=visuals;visuals.Parent=ReplicatedStorage;self.Visuals=visuals
	return self
end
function Service:Profile(player)
 if self.Persistence then
  local data=self.Persistence:Data(player)
  return data and data.Economy
 end
	local profile=self.Profiles[player.UserId]
	if not profile then profile=Economy.new(); self.Profiles[player.UserId]=profile end
	return profile
end
function Service:Register(player)
 if not self:Profile(player) then return false end
 self:Publish(player);return true
end
function Service:IsReady(player)
 return not self.Persistence or self.Persistence:CanMutate(player)
end
function Service:_apply(player,request)
 if not self.Persistence then return Economy.apply(self:Profile(player),request) end
 return self.Persistence:CommitEconomy(player,function(profile,statistics)
  local abandoned=request.Op=="CloseRun" and profile.ActiveRun and profile.ActiveRun.State=="Hunting"
  local result=Economy.apply(profile,request)
  if result.Ok and not result.Replay and not result.Unchanged and request.Op=="Finish" then
   if request.Result=="Failed" then statistics.HuntsFailed+=1
   else statistics.HuntsCompleted+=1 end
   if request.Result=="Captured" then statistics.Captures+=1 end
  end
  if abandoned and result.Ok and not result.Replay then statistics.HuntsFailed+=1 end
  return result
 end)
end
function Service:_notice(player, message)
	set(player,"HuntLootText",message)
	if player.Parent then self.Remote:FireClient(player,"Notice",message); if self.Message then self.Message(player,message) end end
end
function Service:Publish(player, notice, openContext)
	local p=self:Profile(player); if not p or not player.Parent then return end
	set(player,"EconomyReady",true); set(player,"EconomyCoins",p.Coins); set(player,"HammerUpgradeLevel",p.HammerLevel)
	set(player,"HammerDamageMultiplier",Economy.damageMultiplier(p))
	local data=Economy.snapshot(p)
 data.StorageMode=if self.Persistence then self.Persistence.Mode else "ServerMemory"
 data.SaveState=player:GetAttribute("ProfileSaveState")
	set(player,"SpecimenCount",data.SpecimenCount);set(player,"SpecimenLimit",data.SpecimenLimit)
	set(player,"SpecimenFull",data.SpecimenCount>=data.SpecimenLimit)
	for key,value in p.Materials do set(player,"Material"..key,value) end
	for key,value in p.StoredConsumables do set(player,"Stored"..key,value) end
	local offer=self.Offers[player]
	if openContext or not offer or offer.Revision~=p.Revision then
		offer={Context=openContext or (offer and offer.Context) or "Inventory",Revision=p.Revision,Token=HttpService:GenerateGUID(false)}
		self.Offers[player]=offer
	end
	local snapshot=data
	snapshot.Stored=snapshot.StoredConsumables; snapshot.OperationToken=offer.Token; snapshot.Context=offer.Context; snapshot.Notice=notice
	if snapshot.ActiveRun then snapshot.ActiveRun.IronTraps=snapshot.ActiveRun.Traps end
	self.Remote:FireClient(player,if openContext then "Open" else "Snapshot",snapshot)
end
function Service:_quiet(player)
	local s=self.GetState(player)
	return actor(s) and not s.Travelling and not s.Drawn and s.ChangeDraw==nil and not s.Charge and not s.Blocking
		and not s.Sprinting and os.clock()>=s.BusyUntil and player:GetAttribute("AdminFlying")~=true
end
function Service:_context(player, context)
	if not self:_quiet(player) then return false end
	local s=self.GetState(player)
	if s.InHunting or s.InTraining or self:Profile(player).ActiveRun then return false end
	local station
	if context=="Merchant" then station=self.Stations.Merchant
	elseif context=="Craft" then station=self.Stations[player:GetAttribute("BaseId")] end
	return station~=nil and (s.Root.Position-station.Position).Magnitude<=13
end
function Service:Open(player, context)
	if context~="Inventory" and not self:_context(player,context) then
		self:_notice(player,if context=="Craft" then "Đến bàn chế tạo tại base của bạn, cất vũ khí và dừng động tác." else "Đến quầy tiếp tế ở sảnh, cất vũ khí và dừng động tác."); return false
	end
	if context=="Inventory" and not actor(self.GetState(player)) then return false end
	local quest=self.GetQuest(); if quest then quest:CancelAction(player,"Menu") end
	self:Publish(player,nil,context); return true
end
function Service:Request(player, action, token)
	if type(action)~="string" or #action>40 then return end
 if not self:Profile(player) then return end
	local time=os.clock(); if time-(self.LastRequest[player] or -math.huge)<.12 and action~="CarveCancel" then return end
	self.LastRequest[player]=time
	if action=="GetInventory" then
		if actor(self.GetState(player)) then
			local quest=self.GetQuest();if quest then quest:CancelAction(player,"Menu") end
			self:Publish(player)
		end
		return
	end
	if action=="CarveStart" or action=="CarveCancel" then
		local quest=self.GetQuest(); if quest then quest:HarvestAction(player,action) end; return
	elseif action=="OpenInventory" then self:Open(player,"Inventory"); return
	elseif action=="OpenMerchant" then self:Open(player,"Merchant"); return
	elseif action=="OpenCraft" then self:Open(player,"Craft"); return end
	local operations={MerchantBuyTrap={"Merchant","Buy","RawTrap"},MerchantBuyPotion={"Merchant","Buy","SleepPotion"},
		CraftIronTrap={"Craft","CraftTrap"},UpgradeHammer={"Craft","UpgradeHammer"}}
	local op=operations[action]; if not op then return end
 if not self:IsReady(player) then self:_notice(player,"Đang chờ ghi tiến trình. Hãy thử lại khi trạng thái lưu sẵn sàng.");return end
	local profile=self:Profile(player); local offer=self.Offers[player]
	if type(token)~="string" or #token>64 or not offer or token~=offer.Token or offer.Revision~=profile.Revision then
		self:Publish(player,"Yêu cầu cũ đã hết hiệu lực; kho vừa được cập nhật."); return
	end
	if offer.Context~=op[1] or not self:_context(player,op[1]) then self:_notice(player,"Hãy đến đúng điểm giao dịch và cất vũ khí."); return end
	local receipt=self:_apply(player,{Op=op[2],Item=op[3],OperationSerial=profile.OperationSerial+1})
	local text=if receipt.Ok then (if op[2]=="UpgradeHammer" then "Búa cấp 2: sát thương của bạn tăng 15%." elseif op[2]=="CraftTrap" then "Đã chế tạo 1 bẫy sắt." else "Đã mua 1 vật dụng tiếp tế.") else (ERRORS[receipt.Code] or "Chưa thể giao dịch: "..tostring(receipt.Code))
	self:Publish(player,text); self:_notice(player,text)
end
function Service:_runRequest(player,run,op,extra)
 if not self:IsReady(player) then return {Ok=false,Code="SavePending",Replay=false} end
	local p=self:Profile(player); local request={Op=op,RunId=run.Id,RunSerial=run.EconomySerial}
	for key,value in extra or {} do request[key]=value end
	local receipt=self:_apply(player,request)
	if receipt.Ok then self:Publish(player)
	else warn("[P1-E] Transaction rejected",op,receipt.Code); self:_notice(player,"Kho chưa ghi nhận được thao tác: "..tostring(receipt.Code)) end
	return receipt
end
function Service:Begin(player,run)
 if not self:IsReady(player) then return false,"Tiến trình chưa tải/lưu xong. Hãy chờ trạng thái lưu sẵn sàng." end
	local p=self:Profile(player)
	if p.ActiveRun then return false,"Lượt trước chưa trả xong vật dụng." end
	run.EconomySerial=p.RunSerial+1
	run.SpecimenId=HttpService:GenerateGUID(false)
	local receipt=self:_runRequest(player,run,"OpenRun",{MonsterId=run.MonsterId})
	if not receipt.Ok then return false,"Chưa chuẩn bị được kho cho lượt săn." end
	run.Traps=p.ActiveRun.Traps; run.Potions=p.ActiveRun.Potions
	set(player,"QuestRewardText",""); return true
end
function Service:Start(player,run)
	local receipt=self:_runRequest(player,run,"StartRun")
	if receipt.Ok then run.EconomyStarted=true end
	return receipt.Ok
end
function Service:Sync(player,run)
	local p=self:Profile(player); if not p then return false end; local active=p.ActiveRun
	if not run.EconomyStarted or not active or active.State~="Hunting" then return true end
	if active.Traps==run.Traps and active.Potions==run.Potions then return true end
	return self:_runRequest(player,run,"SyncItems",{Traps=run.Traps,Potions=run.Potions}).Ok
end
function Service:Result(player,run)
	if not run.EconomyStarted then return true end
	local extra={Result=run.Result,Traps=run.Traps,Potions=run.Potions}
	if run.Result=="Captured" then
		if not run.SpecimenRecord then
			run.SpecimenRecord={Id=run.SpecimenId,SpeciesId="TRex",Name="T-Rex",Variant="Normal",Element="None",
				SizeScale=1,CapturedAt=DateTime.now().UnixTimestamp,SourceRunId=run.Id,SourceMonsterId=run.MonsterId}
		end
		extra.Specimen=run.SpecimenRecord
		if not run.EconomyCaptureRolls then
			run.EconomyCaptureRolls={}; for i=1,3 do run.EconomyCaptureRolls[i]={TypeRoll=self.Random:NextNumber(),QuantityRoll=self.Random:NextNumber()} end
		end
		extra.Rolls=run.EconomyCaptureRolls
	end
	local receipt=self:_runRequest(player,run,"Finish",extra)
	if receipt.Ok then
		local text=if run.Result=="Captured" then "Đã thêm T-Rex vào Inventory → Khủng long, cùng nguyên liệu, 1 xương và 40 xu." elseif run.Result=="Defeated" then "Đã nhận 1 xương và 40 xu. Đến xác giữ G để mổ tối đa 3 lượt." else "Đã giữ đồ nhặt; nhiệm vụ thất bại không có gói thưởng."
		set(player,"QuestRewardText",text); self:_notice(player,text)
	end
	return receipt.Ok
end
function Service:CanCapture(player,run)
 if not self:IsReady(player) then return false,"ItemsBlocked" end
	return Economy.canCapture(self:Profile(player),run.Id,run.EconomySerial)
end
function Service:Close(player,run)
	return self:_runRequest(player,run,"CloseRun",{Traps=run.Traps,Potions=run.Potions,EntryFailed=not run.EconomyStarted}).Ok
end
function Service:Grant(player,run,kind,sourceId,index)
	if kind=="Ore" and sourceId~=run.Id..":Ore:"..tostring(index) then return false end
	if kind=="Drop" and sourceId~=run.MonsterId..":ScaleDrop" then return false end
	if kind=="Carve" and sourceId~=run.MonsterId then return false end
	local extra={Index=index}
	if kind=="Carve" then
		run.EconomyCarveRolls=run.EconomyCarveRolls or {}
		run.EconomyCarveRolls[index]=run.EconomyCarveRolls[index] or self.Random:NextNumber()
		extra.TypeRoll=run.EconomyCarveRolls[index]
	end
	local before=table.clone(self:Profile(player).Materials)
	local receipt=self:_runRequest(player,run,kind,extra)
	if receipt.Ok then
		local gained={}; for key,value in self:Profile(player).Materials do local count=value-before[key]; if count>0 then table.insert(gained,tostring(count).." "..NAMES[key]) end end
		self:_notice(player,if #gained>0 then "Đã nhận "..table.concat(gained,", ").." vào kho thử." else "Nguồn này đã được ghi nhận trước đó.")
	end
	return receipt.Ok,receipt
end
function Service:DamageMultiplier(player)
 local profile=self:Profile(player);return if profile then Economy.damageMultiplier(profile) else 1
end
function Service:RemovePlayer(player) self.Offers[player]=nil; self.LastRequest[player]=nil end
function Service:_stations()
	local root=Instance.new("Folder"); root.Name="HuntEconomyStations"; root.Parent=workspace; self.World=root
	local function station(name,cf,title,context,baseId)
		local m=Instance.new("Model"); m.Name=name; m.Parent=root
		local function part(n,size,offset,color,material)
			local p=Instance.new("Part"); p.Name=n;p.Size=size;p.CFrame=cf*CFrame.new(offset);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Color=color;p.Material=material or Enum.Material.WoodPlanks;p.Parent=m;return p
		end
		local wood=Color3.fromRGB(84,64,43);local metal=Color3.fromRGB(71,83,80)
		part("Counter",Vector3.new(8,.7,3.4),Vector3.new(0,2.2,0),wood)
		for _,x in {-3.2,3.2} do for _,z in {-1.1,1.1} do part("Leg",Vector3.new(.6,2.3,.6),Vector3.new(x,1,z),wood) end end
		part("Supplies",Vector3.new(2.2,1.2,1.5),Vector3.new(-1.7,3.1,0),metal,Enum.Material.Metal)
		local sign=part("Sign",Vector3.new(8,2,.35),Vector3.new(0,5,1.3),Color3.fromRGB(38,65,46))
		local ui=Instance.new("SurfaceGui");ui.Face=Enum.NormalId.Front;ui.CanvasSize=Vector2.new(600,160);ui.Parent=sign
		local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBold;label.TextColor3=Color3.fromRGB(240,228,196);label.TextSize=29;label.TextWrapped=true;label.Text=title;label.Parent=ui
		local prompt=Instance.new("ProximityPrompt");prompt.ActionText=if context=="Merchant" then "Mua tiếp tế" else "Chế tạo / Nâng búa";prompt.ObjectText=title;prompt.KeyboardKeyCode=Enum.KeyCode.G;prompt.RequiresLineOfSight=false;prompt.MaxActivationDistance=12;prompt.Parent=sign
		table.insert(self.Connections,prompt.Triggered:Connect(function(p) if baseId and p:GetAttribute("BaseId")~=baseId then self:_notice(p,"Đây là bàn của base khác.");return end;self:Open(p,context) end))
		return sign
	end
	self.Stations.Merchant=station("Merchant",self.Map.Lobby.Arrival.CFrame*CFrame.new(25,-3,-10),"QUẦY TIẾP TẾ\nTrap · Thuốc ngủ: 10 xu","Merchant")
	for id=1,12 do
		local base=self.Map.BaseTransit.Bases:FindFirstChild("Base"..id)
		if base then self.Stations[id]=station("CraftBase"..id,base.Arrival.CFrame*CFrame.new(13,-3,0),"BASE "..id.." · CHẾ TẠO\nBẫy sắt · Búa cấp 2","Craft",id) end
	end
end
function Service:Destroy()
	for _,c in self.Connections do c:Disconnect() end; self.Connections={}
	if self.World then self.World:Destroy() end; self.Remote:Destroy()
	if self.Visuals then self.Visuals:Destroy() end
end
return Service

