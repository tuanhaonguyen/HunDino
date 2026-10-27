local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("HunDinoTrainingAction")
local Config = require(ReplicatedStorage.Shared.TrainingConfig)
local Weapons = require(ReplicatedStorage.Shared.Weapons)
local Theme = require(ReplicatedStorage.Shared:WaitForChild("UITheme"))
local C = Theme.Colors
local gui = Instance.new("ScreenGui"); gui.Name = "HunDinoTrainingHUD"; gui.ResetOnSpawn = false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent = player:WaitForChild("PlayerGui")
local function text(name, pos, size, value, textSize)
	local t = Instance.new("TextLabel"); t.Name = name; t.Position = pos; t.Size = size
	t.BackgroundColor3 = C.Panel; t.BackgroundTransparency = 0.12
	t.TextColor3 = C.Text; t.Font = Enum.Font.GothamMedium
	t.TextSize = textSize or 16; t.TextWrapped = true; t.Text = value; t.Parent = gui
	Theme.panel(t)
	return t
end
local title = text("Title", UDim2.fromOffset(20, 14), UDim2.fromOffset(330, 55), "HUNDINO • TRẠI THỢ SĂN", 19)
title.TextColor3=C.Gold; title.Font=Enum.Font.GothamBold
local stats = text("Stats", UDim2.new(0, 20, 1, -136), UDim2.fromOffset(330, 64), "", 16)
local staminaBG = text("Stamina", UDim2.new(0, 20, 1, -60), UDim2.fromOffset(330, 26), "", 14)
local bar = Instance.new("Frame"); bar.BorderSizePixel = 0; bar.BackgroundColor3 = C.Stamina
bar.Size = UDim2.fromScale(1, 1); bar.Parent = staminaBG
Theme.round(bar,8);staminaBG.ClipsDescendants=true
local staminaText = Instance.new("TextLabel"); staminaText.Size = UDim2.fromScale(1, 1); staminaText.BackgroundTransparency = 1
staminaText.TextColor3 = C.Text; staminaText.TextStrokeTransparency=.45; staminaText.Font = Enum.Font.GothamBold; staminaText.TextSize = 14; staminaText.Parent = staminaBG
local help = text("Help", UDim2.new(1, -375, 1, -209), UDim2.fromOffset(355, 190), "", 15)
local notice = text("Notice", UDim2.new(0.5, -245, 0, 18), UDim2.fromOffset(490, 48), "Đến cổng tại sân đón, giữ G để vào bãi tập.", 17)
local center = text("Crosshair", UDim2.new(0.5, -10, 0.5, -10), UDim2.fromOffset(20, 20), "+", 21)
center.BackgroundTransparency = 1; center.Visible = false
local centerBorder=center:FindFirstChildOfClass("UIStroke");if centerBorder then centerBorder:Destroy() end
-- Match Camera.ViewportPointToRay, rather than the HUD's top-bar safe inset.
local reticleGui=Instance.new("ScreenGui"); reticleGui.Name="HunDinoReticle"; reticleGui.IgnoreGuiInset=true
reticleGui.ResetOnSpawn=false; reticleGui.Parent=player.PlayerGui; center.Parent=reticleGui
center.TextColor3=Color3.fromRGB(241,255,250); center.TextStrokeTransparency=.25
local locked, aiming, lastDirection = false, false, Vector3.new(0, 0, -1)
local appliedMouseLock = false
local bowView, bowBlend = nil, 0
local function setZoom(distance)
	player.CameraMaxZoomDistance=math.max(player.CameraMinZoomDistance,distance)
	player.CameraMinZoomDistance=distance; player.CameraMaxZoomDistance=distance
end
local function restoreBowView()
	if not bowView then return end
	if bowView.Humanoid.Parent then
		bowView.Humanoid.CameraOffset=bowView.Offset; bowView.Humanoid.AutoRotate=bowView.AutoRotate
	end
	bowView.Camera.FieldOfView=bowView.FOV
	player.CameraMaxZoomDistance=math.max(player.CameraMinZoomDistance,bowView.MaxZoom)
	player.CameraMinZoomDistance=bowView.MinZoom; player.CameraMaxZoomDistance=bowView.MaxZoom
	UIS.MouseDeltaSensitivity=bowView.Sensitivity; UIS.MouseIconEnabled=bowView.MouseIcon
	bowView=nil; bowBlend=0
end
local noticeId = 0
local function announce(message)
	noticeId += 1; local id = noticeId
	notice.Text = message; notice.Visible = true
	task.delay(5, function() if noticeId == id then notice.Visible = false end end)
end
local hub
local readyAt=0; local inputSerial=0
local held={Light=false}
local chargeId=0;local activeCharge
local chargeHUD=text("Charge",UDim2.new(.5,-170,.65,0),UDim2.fromOffset(340,44),"",16)
chargeHUD.AnchorPoint=Vector2.new(.5,1);chargeHUD.Position=UDim2.new(.5,0,1,-200)
chargeHUD.Visible=false
local function cancelHeld(sendCancel: boolean?)
 for k in held do held[k]=false end
 activeCharge=nil;chargeHUD.Visible=false;if sendCancel~=false then remote:FireServer("ChargeCancel") end
 if readyAt==math.huge then readyAt=os.clock()+.15 end
end
local inventory=require(ReplicatedStorage.Shared:WaitForChild("EquipmentInventory")).create(player,gui,Weapons,remote)
local panel=inventory.Frame
local baseTransit=require(ReplicatedStorage.Shared:WaitForChild("BaseTransitMenu")).create(player,gui,function(id) remote:FireServer("BaseTransitSelect",id) end)
local function recipe(input)
 local key={L="Trái",H="Q",S="E",D="Space"};local parts={}
 for letter in input:gmatch(".") do table.insert(parts,key[letter]) end
 return table.concat(parts," → ")
end
local function recipes(weapon)
 local lines={}
 for _,combo in weapon.Combos do table.insert(lines,weapon.Attacks[combo.Attack].Name..": "..recipe(combo.Input)) end
 return table.concat(lines,"\n")
end
local comboHUD=text("ComboGuide",UDim2.new(0,20,.5,-90),UDim2.fromOffset(330,220),"",14)
comboHUD.Visible=false
local comboScale=Instance.new("UIScale");comboScale.Parent=comboHUD
local compactHUD=false
local refresh
local hudScales={}
for _,item in {title,stats,staminaBG,notice,chargeHUD} do local scale=Instance.new("UIScale");scale.Parent=item;hudScales[item]=scale end
local function resizeHUD()
 local camera=workspace.CurrentCamera;if not camera then return end
 local size=gui.AbsoluteSize
 if size.X<=0 or size.Y<=0 then size=camera.ViewportSize end
 compactHUD=size.X<1000 or size.Y<560
 local compact=compactHUD
 local factor=if compact then math.min(.65,(size.X-32)/650) else 1
 for _,scale in hudScales do scale.Scale=factor end
 title.Position=UDim2.fromOffset(if compact then 12 else 20,if compact then 8 else 14)
 stats.Position=UDim2.new(0,if compact then 12 else 20,1,if compact then -80 else -136)
 staminaBG.Position=UDim2.new(0,if compact then 12 else 20,1,if compact then -30 else -60)
 notice.AnchorPoint=if compact then Vector2.new(.5,1) else Vector2.zero
 notice.Size=UDim2.fromOffset(if compact then 400 else 490,48)
 notice.Position=if compact then UDim2.new(.5,0,1,-12) else UDim2.new(.5,-245,0,18)
 chargeHUD.Position=UDim2.new(.5,0,1,if compact then -64 else -200)
 comboHUD.AnchorPoint=Vector2.new(.5,1)
 comboHUD.Position=UDim2.new(.5,0,1,-24)
 comboHUD.Size=UDim2.fromOffset(360,164);comboHUD.TextSize=12
 comboScale.Scale=math.min(1,math.max(.5,(size.X-740)/360))
 if compact then comboHUD.Visible=false end
 local admin=player.PlayerGui:FindFirstChild("HunDinoAdminFlyHUD")
 local flight=admin and admin:FindFirstChild("FlightPanel")
 if flight then
  local scale=flight:FindFirstChild("UICompactScale") or Instance.new("UIScale")
  scale.Name="UICompactScale";scale.Scale=if compact then .62 else .8;scale.Parent=flight
  local inset=GuiService:GetGuiInset()
  flight.AnchorPoint=if compact then Vector2.new(.5,0) else Vector2.new(1,0)
  flight.Position=if compact then UDim2.new(.5,0,0,inset.Y+8) else UDim2.new(1,-184,0,inset.Y+14)
 end
 if refresh then refresh() end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeHUD);resizeHUD()
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeHUD)
player.PlayerGui.ChildAdded:Connect(function(child) if child.Name=="HunDinoAdminFlyHUD" then task.defer(resizeHUD) end end)
local function toggleMenu()
 baseTransit:Close()
	inputSerial+=1
	if hub then hub:Close() end
	cancelHeld(); inputSerial+=1
	if panel.Visible then panel.Visible=false; return end
	if player:GetAttribute("Drawn") then announce("Nhấn R cất vũ khí trước khi mở túi."); return end
	panel.Visible=true; aiming=false; locked=false; remote:FireServer("Sprint",false); remote:FireServer("Aim",false); remote:FireServer("Guard",false)
end

local refreshPreferences=function() end
hub=require(ReplicatedStorage.Shared.HubUI).create(player,gui,{
 Inventory=toggleMenu,
 BeforeOpen=function()
  baseTransit:Close()
  cancelHeld(); inputSerial+=1
  inputSerial+=1
  panel.Visible=false; aiming=false; locked=false
  remote:FireServer("Sprint",false); remote:FireServer("Aim",false); remote:FireServer("Guard",false)
 end,
 Travel=function(destination) remote:FireServer("TravelMenu",destination) end,
 Preferences=function() refreshPreferences() end,
})
local function menuOpen()
 local economyGUI=player.PlayerGui:FindFirstChild("HunDinoEconomy")
 local economyPanel=economyGUI and economyGUI:FindFirstChild("Panel")
 if economyPanel and economyPanel.Visible then return true end
 local questGUI=player.PlayerGui:FindFirstChild("HunDinoHuntQuest")
 if questGUI then
  for _,name in {"QuestBoard","ResultModal"} do
   local menu=questGUI:FindFirstChild(name);if menu and menu.Visible then return true end
  end
 end
 local forestGUI=player.PlayerGui:FindFirstChild("HuntingMapViewer")
 local picker=forestGUI and forestGUI:FindFirstChild("ZonePicker")
 return panel.Visible or hub:IsOpen() or baseTransit:IsOpen() or (forestGUI and forestGUI.Enabled and picker and picker.Visible) or false
end
local function aimDirection(ranged, dodge)
	local character = player.Character
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local dir = lastDirection
	if ranged and root then
		local camera=workspace.CurrentCamera; local size=camera.ViewportSize
		local ray=camera:ViewportPointToRay(size.X/2,size.Y/2)
		local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={character,workspace:FindFirstChild("TrainingPets")}
		local result=workspace:Raycast(ray.Origin,ray.Direction*250,params)
		local target=if result then result.Position else ray.Origin+ray.Direction*250
		local vector=target-(root.Position+Vector3.new(0,.8,0))
		return if vector.Magnitude>.01 then vector.Unit else camera.CFrame.LookVector
	end
	if (locked or aiming) and not dodge then dir = workspace.CurrentCamera.CFrame.LookVector
	elseif hum and hum.MoveDirection.Magnitude > 0.1 then dir = hum.MoveDirection
	elseif root then dir = lastDirection end
	dir = Vector3.new(dir.X, 0, dir.Z)
	return if dir.Magnitude > 0.01 then dir.Unit else Vector3.new(0, 0, -1)
end
local function send(action)
 local function dispatch()
  if player:GetAttribute("AdminFlying")==true or menuOpen() or GuiService.MenuIsOpen or UIS:GetFocusedTextBox() then return end
  local ranged=player:GetAttribute("WeaponId")=="Bow"
  local direction=aimDirection(ranged and (action=="Light" or action=="Heavy" or action=="Skill"),action=="Dodge")
  if ranged and action=="Light" then
   if activeCharge or not player:GetAttribute("Drawn") then return end
   chargeId+=1;local token=chargeId
   activeCharge={Id=token,Action=action,Started=os.clock(),Time=Weapons.Bow.Charge.Time}
   remote:FireServer("ChargeStart",{Id=token,Action=action,Direction=direction})
   if not held[action] then remote:FireServer("ChargeRelease",{Id=token,Direction=direction});activeCharge=nil end
  else remote:FireServer(action,direction) end
 end
 inputSerial+=1; local serial=inputSerial; local remaining=readyAt-os.clock()
 if remaining>0 and remaining<=.2 and action~="Jump" then
  task.delay(remaining+.03,function() if serial==inputSerial then dispatch() end end)
 elseif remaining<=0 then dispatch() end
end
-- Consume Space before Roblox's default jump binding. The server arbitrates
-- jump/dodge together, so simultaneous keys cannot combine their impulses.
local function movementAction(actionName, inputState)
	if player:GetAttribute("AdminFlying")==true then return Enum.ContextActionResult.Pass end
	if inputState == Enum.UserInputState.Begin and not menuOpen() and not UIS:GetFocusedTextBox() and not GuiService.MenuIsOpen then
		if actionName == "HunDinoJump" then send("Jump") else send("Dodge") end
	end
	return Enum.ContextActionResult.Sink
end
ContextActionService:BindActionAtPriority("HunDinoJump", movementAction, false, 3001, Enum.KeyCode.V)
ContextActionService:BindActionAtPriority("HunDinoDodge", movementAction, false, 3001, Enum.KeyCode.Space)
-- I also zooms Roblox's default camera; consume it when opening the armory.
ContextActionService:BindActionAtPriority("HunDinoArmory", function(_, inputState)
	if player:GetAttribute("AdminFlying")==true then return Enum.ContextActionResult.Sink end
	if inputState == Enum.UserInputState.Begin and not UIS:GetFocusedTextBox() and not GuiService.MenuIsOpen then toggleMenu() end
	return Enum.ContextActionResult.Sink
end, false, 3001, Enum.KeyCode.I)
script.Destroying:Connect(function()
	restoreBowView(); reticleGui:Destroy()
	if appliedMouseLock then UIS.MouseBehavior=Enum.MouseBehavior.Default end
	ContextActionService:UnbindAction("HunDinoJump")
	ContextActionService:UnbindAction("HunDinoDodge")
	ContextActionService:UnbindAction("HunDinoArmory")
	RunService:UnbindFromRenderStep("HunDinoTrainingCamera")
	RunService:UnbindFromRenderStep("HunDinoBowView")
end)
UIS.InputBegan:Connect(function(input, processed)
	if player:GetAttribute("AdminFlying")==true then return end
	if processed or UIS:GetFocusedTextBox() then return end
	if menuOpen() or GuiService.MenuIsOpen then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then held.Light=true; send("Light")
	elseif input.UserInputType==Enum.UserInputType.MouseButton2 and player:GetAttribute("WeaponId")=="Bow" and player:GetAttribute("Drawn") then aiming=true; remote:FireServer("Aim",true)
	elseif input.KeyCode==Enum.KeyCode.F then remote:FireServer("Guard",true)
	elseif input.KeyCode == Enum.KeyCode.Q then send("Heavy")
	elseif input.KeyCode == Enum.KeyCode.E then send("Skill")
	elseif input.KeyCode == Enum.KeyCode.R then
		cancelHeld(false); inputSerial+=1; aiming=false; remote:FireServer("Aim",false); remote:FireServer("Draw")
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		cancelHeld(); inputSerial+=1; aiming=false; remote:FireServer("Aim",false); remote:FireServer("Sprint", true)
	elseif input.KeyCode == Enum.KeyCode.LeftControl then locked = not locked; center.Visible = locked end
end)
UIS.InputEnded:Connect(function(input)
 local action=if input.UserInputType==Enum.UserInputType.MouseButton1 then "Light" else nil
 if action then
  held[action]=false
  if activeCharge and activeCharge.Action==action then
   remote:FireServer("ChargeRelease",{Id=activeCharge.Id,Direction=aimDirection(true,false)})
   activeCharge=nil;chargeHUD.Visible=false;readyAt=os.clock()+.12
  end
 end
	if input.KeyCode == Enum.KeyCode.LeftShift then remote:FireServer("Sprint", false) end
	if input.KeyCode==Enum.KeyCode.F then remote:FireServer("Guard",false) end
	if input.UserInputType==Enum.UserInputType.MouseButton2 then aiming=false; remote:FireServer("Aim",false) end
end)
UIS.WindowFocusReleased:Connect(function()
	cancelHeld(); inputSerial+=1
	remote:FireServer("Sprint", false); locked = false; center.Visible = false
	aiming=false; remote:FireServer("Aim",false); remote:FireServer("Guard",false)
end)
local function characterAdded(character)
 baseTransit:Close()
	cancelHeld(); readyAt=0; inputSerial+=1; hub:Close()
	restoreBowView()
	local hum = character:WaitForChild("Humanoid")
	-- Use the normal jump state/animation; Space is consumed by the binding above.
	hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	hum.AutoJumpEnabled = false
	hum.UseJumpPower = true; hum.JumpPower = 50
	lastDirection = Vector3.new(0, 0, -1); locked = false; aiming=false; panel.Visible=false; center.Visible = false
end
player.CharacterAdded:Connect(characterAdded)
if player.Character then task.spawn(characterAdded, player.Character) end
-- Feed the shoulder offset/zoom to Roblox's camera before its collision solver.
-- Keeping CameraType.Custom retains normal mouse orbit and wall occlusion.
RunService:BindToRenderStep("HunDinoBowView", Enum.RenderPriority.Camera.Value-1, function(dt)
	local character=player.Character; local hum=character and character:FindFirstChildOfClass("Humanoid")
	local camera=workspace.CurrentCamera
	local want=aiming and hum and hum.Health>0 and player:GetAttribute("WeaponId")=="Bow"
		and player:GetAttribute("Drawn") and not menuOpen() and not GuiService.MenuIsOpen and not UIS:GetFocusedTextBox()
		and camera.CameraType==Enum.CameraType.Custom
	if bowView and (bowView.Humanoid~=hum or bowView.Camera~=camera or not hum or hum.Health<=0) then restoreBowView() end
	if want and not bowView then
		bowView={Humanoid=hum,Camera=camera,Offset=hum.CameraOffset,AutoRotate=hum.AutoRotate,FOV=camera.FieldOfView,
			MinZoom=player.CameraMinZoomDistance,MaxZoom=player.CameraMaxZoomDistance,
			Distance=math.clamp((camera.CFrame.Position-camera.Focus.Position).Magnitude,player.CameraMinZoomDistance,player.CameraMaxZoomDistance),
			Sensitivity=UIS.MouseDeltaSensitivity,MouseIcon=UIS.MouseIconEnabled}
	end
	if not bowView then return end
	bowBlend+=( (if want then 1 else 0)-bowBlend)*(1-math.exp(-12*dt))
	hum.CameraOffset=bowView.Offset+Vector3.new(2.6,.65,0)*bowBlend
	camera.FieldOfView=bowView.FOV+(58-bowView.FOV)*bowBlend
	setZoom(bowView.Distance+(8.5-bowView.Distance)*bowBlend)
	UIS.MouseDeltaSensitivity=bowView.Sensitivity*(1-.35*bowBlend)*(player:GetAttribute("AimSensitivity") or 1)
	UIS.MouseIconEnabled=if want then false else bowView.MouseIcon
	if not want and bowBlend<.001 then setZoom(bowView.Distance); restoreBowView() end
end)
RunService:BindToRenderStep("HunDinoTrainingCamera", Enum.RenderPriority.Camera.Value + 1, function()
	if player:GetAttribute("AdminFlying")==true then
		restoreBowView();aiming=false;locked=false;center.Visible=false
		if appliedMouseLock then UIS.MouseBehavior=Enum.MouseBehavior.Default;appliedMouseLock=false end
		return
	end
	local character = player.Character
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	if hum and hum.MoveDirection.Magnitude > 0.1 then lastDirection = hum.MoveDirection.Unit end
	if not player:GetAttribute("Drawn") or GuiService.MenuIsOpen or menuOpen() or not hum or hum.Health<=0 then
		if aiming then remote:FireServer("Aim",false) end
		aiming=false
	end
	if aiming and bowView and character.PrimaryPart then
		local root=character.PrimaryPart; local look=workspace.CurrentCamera.CFrame.LookVector
		local flat=Vector3.new(look.X,0,look.Z)
		if flat.Magnitude>.01 then hum.AutoRotate=false; root.CFrame=CFrame.lookAt(root.Position,root.Position+flat) end
	end
	local canControl=hum and hum.Health>0 and not GuiService.MenuIsOpen and not UIS:GetFocusedTextBox()
	center.Visible=canControl and not menuOpen() and (locked or (player:GetAttribute("WeaponId")=="Bow" and player:GetAttribute("Drawn"))) or false
	if canControl and (locked or aiming) and not menuOpen() then
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter; appliedMouseLock = true
	elseif appliedMouseLock then
		UIS.MouseBehavior = Enum.MouseBehavior.Default; appliedMouseLock = false
	end
end)
GuiService.MenuOpened:Connect(function() cancelHeld();inputSerial+=1 end)
local chargeClock=0
RunService.RenderStepped:Connect(function(dt)
 if not activeCharge then chargeHUD.Visible=false;return end
 local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health<=0 then cancelHeld();return end
 local alpha=math.clamp((os.clock()-activeCharge.Started)/activeCharge.Time,0,1)
 chargeHUD.Visible=not menuOpen()
 chargeHUD.Text=(if alpha>=1 then "ĐẦY LỰC" else "TỤ LỰC "..math.floor(alpha*100).."%").." • Nhả để bắn"
 chargeHUD.TextColor3=C.Stamina
 chargeClock+=dt
 if chargeClock>=.12 then chargeClock=0;remote:FireServer("ChargeAim",aimDirection(true,false)) end
end)
refresh=function()
	local inTraining = player:GetAttribute("InTraining")
 local inHunting = player:GetAttribute("InHunting")==true
	
	local id=player:GetAttribute("WeaponId") or "Hammer"; local weapon=Weapons[id]
	local chain=player:GetAttribute("ComboChain") or ""
	comboHUD.Visible=not compactHUD and (inTraining==true or inHunting) and player:GetAttribute("Drawn")==true and not menuOpen() and player:GetAttribute("ShowComboGuide")~=false
	local nextKeys={}
	for _,combo in weapon.Combos do
		if #chain>0 and combo.Input:sub(1,#chain)==chain then
			table.insert(nextKeys,recipe(combo.Input:sub(#chain+1)))
		end
	end
	comboHUD.Text="COMBO • "..weapon.Name.."\n"..recipes(weapon)
		.."\n"..(if #chain>0 then "Đã nối: "..recipe(chain).." | Tiếp: "..table.concat(nextKeys," / ") else "Nối sau mỗi đòn, trong 1,35 giây")
	
	title.Text = "HUNDINO • " .. (if inHunting then "THUNG LŨNG SƯƠNG XÁM" elseif inTraining then "BÃI LUYỆN TẬP" else "TRẠI THỢ SĂN")
		.. "\nBase " .. tostring(player:GetAttribute("BaseId") or "…") .. " / 12"
	if compactHUD then title.Text="HUNDINO · "..(if inHunting then "KHU SĂN" elseif inTraining then "BÃI TẬP" else "TRẠI THỢ SĂN").."\nBase "..tostring(player:GetAttribute("BaseId") or "…").." / 12" end
	stats.Visible=true
 local value = player:GetAttribute("Stamina") or Config.MaxStamina
	bar.Size = UDim2.fromScale(value / Config.MaxStamina, 1); staminaText.Text = "THỂ LỰC " .. value .. " / " .. Config.MaxStamina
	stats.Text = weapon.Name..(if player:GetAttribute("Drawn") then " • Đã rút" else " • Đang cất")
		.. " • " .. (if player:GetAttribute("TrainingArmor") then "Giáp tập" else "Chưa mặc giáp")
		.. "\nBạn: " .. (player:GetAttribute("TrainingDamage") or 0) .. "  |  Pet: " .. (player:GetAttribute("PetDamage") or 0)
	if inHunting then stats.Text=weapon.Name..(if player:GetAttribute("Drawn") then " • Đã rút" else " • Đang cất")
		.."\nSát thương săn: "..(player:GetAttribute("HuntingDamage") or 0) end
	help.Text="R: Rút / cất • I: Túi đồ\nChuột trái: Đánh thường • Q: Đánh mạnh\nE: "..weapon.Skill.."\nV: Nhảy • Space: Lướt\nShift: Chạy • Ctrl: Ghim tâm • G: Tương tác"
		..(if id=="Bow" then "\nPhải: Ngắm • Giữ Trái: Tụ lực"..(if player:GetAttribute("BowBoost") then " • MŨI TÊN CƯỜNG HÓA" else "") elseif id=="SwordShield" then "\nF: Giữ thế đỡ" else "")
	if inHunting then help.Text..="\nKhủng long sẽ phản công khi bị đánh." end
	help.Visible=not compactHUD and not inHunting and not menuOpen()
	if player:GetAttribute("AdminFlying")==true then help.Text="ADMIN • BAY XEM MAP\nWASD: Di chuyển • Space / E: Lên\nCtrl / Q: Xuống • Shift: Bay nhanh\nBấm Dừng bay hoặc chat /fly để đáp xuống." end
end
for _, attr in {"InTraining", "InHunting", "BaseId", "Stamina", "Drawn", "TrainingArmor", "TrainingDamage", "HuntingDamage", "PetDamage", "WeaponId", "Blocking", "BowBoost", "ComboChain", "AdminFlying"} do
	player:GetAttributeChangedSignal(attr):Connect(refresh)
end
player:GetAttributeChangedSignal("InHunting"):Connect(function()
 baseTransit:Close(); hub:Close(); panel.Visible=false
 cancelHeld(); inputSerial+=1; aiming=false; locked=false; center.Visible=false
 restoreBowView()
end)
player:GetAttributeChangedSignal("AdminFlying"):Connect(function()
 if player:GetAttribute("AdminFlying")~=true then return end
 baseTransit:Close();hub:Close();panel.Visible=false
 cancelHeld();inputSerial+=1;aiming=false;locked=false;center.Visible=false;restoreBowView()
end)
refreshPreferences=refresh
panel:GetPropertyChangedSignal("Visible"):Connect(refresh)
refresh()
remote.OnClientEvent:Connect(function(event, a, b, c)
	if event == "BaseTransitOpen" then
  cancelHeld();inputSerial+=1;hub:Close();panel.Visible=false;aiming=false;locked=false
  baseTransit:Open(a)
 elseif event == "Message" then announce(a)
	elseif event == "Jump" and player.Character == a then
		local hum = a:FindFirstChildOfClass("Humanoid")
		local root = a:FindFirstChild("HumanoidRootPart")
		if hum and root and hum.Health > 0 and not hum.Sit and not root.Anchored
			and hum.FloorMaterial ~= Enum.Material.Air then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	elseif event=="ChargeStart" then
  if activeCharge and activeCharge.Id==b then activeCharge.Time=a;readyAt=math.huge end
 elseif event=="ChargeStop" then activeCharge=nil;chargeHUD.Visible=false;readyAt=os.clock()
 elseif event=="ChargeRejected" then
  if activeCharge and activeCharge.Id==a then activeCharge=nil;chargeHUD.Visible=false;readyAt=os.clock() end
 elseif event == "Dodge" then
		readyAt=os.clock()+a
	elseif event == "Attack" then
		readyAt=os.clock()+(c or 0)
		if b then announce("COMBO • "..b) end
	elseif event == "ComboFX" then
		if player:GetAttribute("ShowComboFX")==false then return end
		-- Short local trails make the finisher readable without adding collision.
		local color=if b=="Slam" then Color3.fromRGB(255,191,89) else Color3.fromRGB(113,235,214)
		local count=if b=="Thrust" then 1 else 8
		for i=1,count do
			local effect=Instance.new("Part"); effect.Name="ComboTrail"; effect.Anchored=true
			effect.CanCollide=false; effect.CanQuery=false; effect.CanTouch=false; effect.Material=Enum.Material.Neon
			effect.Color=color; effect.Transparency=.25
			if count==1 then effect.Size=Vector3.new(.14,.14,c); effect.CFrame=a*CFrame.new(0,0,-c/2)
			else
				local full=b=="Spin" or b=="Slam"
				local angle=if full then i*math.pi/4 else -math.pi/2+(i-1)*math.pi/7
				effect.Size=Vector3.new(c*.45,.12,.16)
				effect.CFrame=a*CFrame.Angles(0,angle,0)*CFrame.new(0,if b=="Slam" then -2 else 0,-c*.7)
			end
			effect.Parent=workspace
			TweenService:Create(effect,TweenInfo.new(.22),{Transparency=1}):Play(); Debris:AddItem(effect,.24)
		end
	elseif event == "Shot" then
		local distance=(b-a).Magnitude; if distance<.01 then return end
		local arrow=Instance.new("Part"); arrow.Name="TrainingArrow"; arrow.Anchored=true; arrow.CanCollide=false; arrow.CanQuery=false; arrow.CanTouch=false
		arrow.Size=Vector3.new(.1,.1,2.6); arrow.Material=Enum.Material.Neon; arrow.Color=if c then Color3.fromRGB(255,208,91) else Color3.fromRGB(115,255,140)
		arrow.CFrame=CFrame.lookAt(a,b); arrow.Parent=workspace
		local flight=math.clamp(distance/260,.06,.8)
		TweenService:Create(arrow,TweenInfo.new(flight,Enum.EasingStyle.Linear),{CFrame=CFrame.lookAt(b,b+(b-a))}):Play(); Debris:AddItem(arrow,flight+.12)
	elseif event == "Hit" then
		if player:GetAttribute("ShowDamage")==false then return end
		local anchor = Instance.new("Part"); anchor.Size = Vector3.one; anchor.CFrame = CFrame.new(a + Vector3.new(0, 2, 0))
		anchor.Transparency = 1; anchor.Anchored = true; anchor.CanCollide = false; anchor.CanQuery = false; anchor.Parent = workspace
		local billboard = Instance.new("BillboardGui"); billboard.Size = UDim2.fromOffset(120, 50); billboard.AlwaysOnTop = true; billboard.Parent = anchor
		local number = Instance.new("TextLabel"); number.Size = UDim2.fromScale(1, 1); number.BackgroundTransparency = 1
		number.Font = Enum.Font.GothamBlack; number.TextSize = 28
		number.TextColor3 = if c then Color3.fromRGB(88, 230, 172) else Color3.fromRGB(255, 211, 104)
		number.Text = (if c then "Pet " else "") .. b; number.Parent = billboard
		TweenService:Create(anchor, TweenInfo.new(0.8), {Position = anchor.Position + Vector3.new(0, 3, 0)}):Play()
		TweenService:Create(number, TweenInfo.new(0.8), {TextTransparency = 1}):Play(); Debris:AddItem(anchor, 0.85)
	end
end)