local Inventory={}
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local Armor=require(RS.Shared:WaitForChild("ArmorEquipment"))
local Builder=require(RS.Shared:WaitForChild("WeaponsPro"))
local gold=Color3.fromRGB(211,177,108)
local ink=Color3.fromRGB(238,229,205)
local dark=Color3.fromRGB(27,30,27)
local names={Hammer="Búa tạ",SwordShield="Kiếm & khiên",Katana="Kiếm Katana",Glaive="Thương cán dài",DualDaggers="Song dao",Bow="Cung",GreatAxe="Rìu đại hai lưỡi"}

local function frame(parent,name,x,y,w,h,color)
	local f=Instance.new("Frame");f.Name=name;f.Position=UDim2.fromOffset(x,y);f.Size=UDim2.fromOffset(w,h)
	f.BorderSizePixel=0;f.BackgroundColor3=color or dark;f.Parent=parent
	return f
end
local function line(parent,color)
	local s=Instance.new("UIStroke");s.Color=color or Color3.fromRGB(83,77,59);s.Thickness=1;s.Parent=parent;return s
end
local function label(parent,name,value,x,y,w,h,size)
	local t=Instance.new("TextLabel");t.Name=name;t.BackgroundTransparency=1;t.Text=value;t.TextColor3=ink
	t.Font=Enum.Font.GothamMedium;t.TextSize=size or 15;t.TextWrapped=true;t.Position=UDim2.fromOffset(x,y);t.Size=UDim2.fromOffset(w,h);t.Parent=parent;return t
end
local function button(parent,name,value,x,y,w,h)
	local b=Instance.new("TextButton");b.Name=name;b.Text=value;b.Font=Enum.Font.GothamMedium;b.TextSize=15;b.TextColor3=ink
	b.BorderSizePixel=0;b.BackgroundColor3=Color3.fromRGB(49,48,38);b.Position=UDim2.fromOffset(x,y);b.Size=UDim2.fromOffset(w,h);b.Parent=parent
	line(b);return b
end
local function viewport(parent,name,x,y,w,h)
	local v=Instance.new("ViewportFrame");v.Name=name;v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(w,h)
	v.BackgroundColor3=Color3.fromRGB(20,25,24);v.BorderSizePixel=0;v.Ambient=Color3.fromRGB(205,207,207)
	v.LightColor=Color3.fromRGB(255,238,205);v.LightDirection=Vector3.new(-1,-1,-1);v.Parent=parent
	local world=Instance.new("WorldModel");world.Name="PreviewWorld";world.Parent=v
	local camera=Instance.new("Camera");camera.FieldOfView=32;camera.Parent=v;v.CurrentCamera=camera
	return v
end
local function orbit(v,yaw,pitch)
	local center=v:GetAttribute("OrbitCenter");local distance=v:GetAttribute("OrbitDistance")
	if not center or not distance then return end
	local angle,elevation=math.rad(yaw),math.rad(pitch)
	local direction=Vector3.new(math.sin(angle)*math.cos(elevation),math.sin(elevation),-math.cos(angle)*math.cos(elevation))
	v.CurrentCamera.CFrame=CFrame.lookAt(center+direction*distance,center)
end
local function show(v,model,actor,yaw,pitch)
	v.PreviewWorld:ClearAllChildren()
	if not model then return end
	local n=0
	for _,p in model:GetDescendants() do
		if p:IsA("BasePart") then p.Anchored=true;p.CanCollide=false;n+=1
		elseif p:IsA("Trail") or p:IsA("ParticleEmitter") then p.Enabled=false end
	end
	if n==0 then model:Destroy();return end
	model.Parent=v.PreviewWorld
	local cf,size=model:GetBoundingBox()
	local span=math.max(size.Y,size.X/(v.Size.X.Offset/v.Size.Y.Offset),size.Z*.8,1)
	local distance=span/(2*math.tan(math.rad(16)))*1.18
	v:SetAttribute("OrbitCenter",cf.Position);v:SetAttribute("OrbitDistance",distance)
	orbit(v,yaw or 18,pitch or 5)
end
local function cleanClone(source)
	local archivable=source.Archivable;source.Archivable=true
	local clone=source:Clone();source.Archivable=archivable
	if not clone then return nil end
	for _,v in clone:GetDescendants() do
		if v:IsA("LuaSourceContainer") or v:IsA("JointInstance") or v:IsA("Animator") then v:Destroy()
		elseif v:IsA("BasePart") then v.Anchored=true
		elseif v:IsA("Trail") or v:IsA("ParticleEmitter") then v:Destroy() end
	end
	for _,name in {"EquipmentArmor","TrainingArmor","TrainingWeapon","WeaponR","WeaponL"} do
		local old=clone:FindFirstChild(name);if old then old:Destroy() end
	end
	clone:PivotTo(CFrame.new())
	return clone
end
local function addWeapon(actor,target,id)
	local model=Builder.build(id);model.Name="PreviewWeapon"
	local root=actor.PrimaryPart or actor:FindFirstChild("HumanoidRootPart") or actor:FindFirstChild("Root")
	if not root then model:Destroy();return end
	local sizes={Hammer=.7,SwordShield=.8,Katana=.75,Glaive=.55,DualDaggers=.9,Bow=.7,GreatAxe=.7}
	for _,assembly in model:GetChildren() do
		local left=assembly.Name=="Offhand" or id=="Bow"
		local bone=if target=="Pet" then actor:FindFirstChild(if left then "GripL" else "GripR")
			else actor:FindFirstChild(if left then "LeftHand" else "RightHand") or actor:FindFirstChild(if left then "Left Arm" else "Right Arm")
		if bone then
			assembly:ScaleTo(if target=="Pet" then sizes[id] else .9)
			local position=bone.Position+(if target=="Pet" then Vector3.zero else Vector3.new(0,-bone.Size.Y*.35,0))
			assembly:PivotTo(CFrame.new(position)*root.CFrame.Rotation*CFrame.Angles(-.25,if id=="Bow" then math.pi/2 else 0,0))
		end
	end
	model.Parent=actor
end

function Inventory.create(player,gui,weapons,remote)
	local api={Target="Player",Category="Weapons",Selected=nil,Yaw=18,Pitch=5}
	local connections={}
	local cover=frame(gui,"InventoryShade",0,0,0,0,Color3.new(0,0,0));cover.Size=UDim2.fromScale(1,1)
	cover.BackgroundTransparency=.4;cover.Visible=false;cover.Active=true;cover.ZIndex=20
	local panel=frame(gui,"WeaponSelection",0,0,1070,660,Color3.fromRGB(34,36,29))
	panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Visible=false;panel.ZIndex=21;line(panel,gold)
	api.Frame=panel
	local scale=Instance.new("UIScale");scale.Parent=panel
	local function resize()
		local size=workspace.CurrentCamera.ViewportSize;scale.Scale=math.min(1,(size.X-38)/1070,(size.Y-80)/660)
	end
	table.insert(connections,workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize));resize()
	local title=label(panel,"Heading","TÚI ĐỒ",24,16,220,36,24);title.Font=Enum.Font.GothamBold;title.TextXAlignment=Enum.TextXAlignment.Left
	local close=button(panel,"Close","×",1018,16,32,32)
	local playerTab=button(panel,"PlayerTab","NGƯỜI",330,18,145,40)
	local petTab=button(panel,"PetTab","PET",487,18,145,40)
	local weaponTab=button(panel,"WeaponsTab","VŨ KHÍ",330,79,205,42)
	local armorTab=button(panel,"ArmorTab","GIÁP",547,79,205,42)
	local actorName=label(panel,"ActorName","",24,75,280,38,20)
	local actorView=viewport(panel,"CharacterPreview",24,125,282,428);actorView.BackgroundTransparency=.25;line(actorView)
	actorView.Active=true
	label(panel,"RotateHint","Giữ chuột trái và kéo để xoay\nTrái / phải • Lên / xuống",24,566,282,42,13)
	label(panel,"PreviewCaption","Xem trước trang bị",24,608,282,26,13)
	local list=frame(panel,"EquipmentList",330,136,422,443);list.BackgroundTransparency=1
	local weaponList=Instance.new("ScrollingFrame");weaponList.Name="WeaponList";weaponList.Position=UDim2.fromOffset(0,0);weaponList.Size=UDim2.fromScale(1,1)
	weaponList.BackgroundTransparency=1;weaponList.BorderSizePixel=0;weaponList.ScrollBarThickness=3;weaponList.CanvasSize=UDim2.fromOffset(0,370);weaponList.Parent=list
	local armorList=Instance.new("ScrollingFrame");armorList.Name="ArmorList";armorList.Position=UDim2.fromOffset(0,36);armorList.Size=UDim2.new(1,0,1,-36)
	armorList.BackgroundTransparency=1;armorList.BorderSizePixel=0;armorList.ScrollBarThickness=3;armorList.CanvasSize=UDim2.fromOffset(0,408);armorList.Parent=list
	local headers=frame(list,"SlotHeaders",0,0,410,30);headers.BackgroundTransparency=1
	for i,slot in Armor.Slots do label(headers,slot,Armor.SlotNames[slot],(i-1)*82,0,76,28,14) end
	local detail=frame(panel,"ItemDetails",774,136,272,443,Color3.fromRGB(29,34,29));line(detail,gold)
	local selectedName=label(detail,"SelectedName","",12,10,248,52,19);selectedName.Font=Enum.Font.GothamBold
	local itemView=viewport(detail,"ItemPreview",12,74,248,228);line(itemView)
	local info=label(detail,"SelectionInfo","",12,311,248,74,14)
	local equip=button(panel,"EquipSelected","TRANG BỊ",786,595,248,42);equip.BackgroundColor3=Color3.fromRGB(98,80,43)
	local remove=button(panel,"RemoveSelected","Tháo món đang mặc",786,544,248,34)
	local hint=label(panel,"EquipHint","Trang bị ở bãi tập hoặc khu săn khi đã cất vũ khí",330,595,422,42,13)
	local cells,weaponButtons={},{ }
	local function equippedWeapon()
		return player:GetAttribute(if api.Target=="Pet" then "PetWeaponId" else "WeaponId") or "Hammer"
	end
	local function drawActor()
		local source=if api.Target=="Player" then player.Character else workspace:FindFirstChild("TrainingPets") and workspace.TrainingPets:FindFirstChild("Pet_"..player.UserId)
		actorView.PreviewWorld:ClearAllChildren()
		if not source then return end
		local clone=cleanClone(source);if not clone then return end
		local equipment=Armor.read(player,api.Target)
		if api.Category=="Armor" and api.Selected then equipment[api.Selected.Slot]=api.Selected.Id end
		Armor.apply(clone,api.Target,equipment)
		if api.Category=="Weapons" then addWeapon(clone,api.Target,if api.Selected then api.Selected.Id else equippedWeapon()) end
		show(actorView,clone,true,api.Yaw,api.Pitch)
	end
	local function select(id,slot)
		api.Selected={Id=id,Slot=slot}
		api:Refresh()
	end
	for i,id in weapons.Order do
		local b=button(weaponList,id,names[id] or weapons[id].Name,((i-1)%2)*213,math.floor((i-1)/2)*90,199,74)
		b.TextSize=17;weaponButtons[id]=b
		b.Activated:Connect(function() select(id,nil) end)
	end
	for row,id in Armor.Order do
		local group=frame(armorList,id,0,(row-1)*99,410,92);group.BackgroundTransparency=1
		local name=label(group,"SetName","Giáp "..Armor.Sets[id].Name,0,0,408,24,15);name.TextXAlignment=Enum.TextXAlignment.Left
		cells[id]={}
		for i,slot in Armor.Slots do
			local cell=button(group,slot,"",(i-1)*82,28,74,59)
			local v=viewport(cell,"Icon",2,2,70,53);v.BackgroundTransparency=1;v.Active=false
			local tick=label(cell,"Equipped","✓",52,0,20,22,17);tick.TextColor3=Color3.fromRGB(137,215,155);tick.Visible=false
			cells[id][slot]={Button=cell,Viewport=v,Tick=tick}
			cell.Activated:Connect(function() select(id,slot) end)
		end
	end
	function api:Refresh()
		if not panel.Visible then return end
		actorName.Text=if self.Target=="Pet" then "PET ĐỒNG HÀNH" else player.DisplayName
		playerTab.BackgroundColor3=if self.Target=="Player" then Color3.fromRGB(101,83,44) else dark
		petTab.BackgroundColor3=if self.Target=="Pet" then Color3.fromRGB(101,83,44) else dark
		weaponTab.BackgroundColor3=if self.Category=="Weapons" then Color3.fromRGB(75,77,55) else dark
		armorTab.BackgroundColor3=if self.Category=="Armor" then Color3.fromRGB(75,77,55) else dark
		weaponList.Visible=self.Category=="Weapons";armorList.Visible=self.Category=="Armor";headers.Visible=armorList.Visible;remove.Visible=armorList.Visible
		if not self.Selected then
			self.Selected=if self.Category=="Weapons" then {Id=equippedWeapon()} else {Id=Armor.read(player,self.Target).Head,Slot="Head"}
		end
		local selection=self.Selected
		for id,b in weaponButtons do b.BackgroundColor3=if selection.Id==id then Color3.fromRGB(106,86,43) elseif equippedWeapon()==id then Color3.fromRGB(47,76,59) else Color3.fromRGB(49,48,38) end
		if self.Category=="Weapons" then
			selectedName.Text=names[selection.Id] or weapons[selection.Id].Name
			local item=Builder.build(selection.Id)
			local offhand=item:FindFirstChild("Offhand")
			if offhand then offhand:PivotTo(CFrame.new(if selection.Id=="DualDaggers" then .85 else 1.7,0,0)) end
			show(itemView,item,false)
			info.Text=if selection.Id==equippedWeapon() then "Đang trang bị" else "Chọn để trang bị"
			remove.Visible=false
		else
			local current=Armor.read(player,self.Target)
			for id,row in cells do for slot,data in row do
				show(data.Viewport,Armor.icon(self.Target,slot,id),false)
				data.Tick.Visible=current[slot]==id
				data.Button.BackgroundColor3=if id==selection.Id and slot==selection.Slot then Color3.fromRGB(104,84,43) else dark
			end end
			selectedName.Text=(Armor.ItemNames[selection.Slot] or "Giáp").." • "..(Armor.Sets[selection.Id] and Armor.Sets[selection.Id].Name or "Không mặc")
			show(itemView,Armor.icon(self.Target,selection.Slot,selection.Id),false)
			info.Text="Vị trí: "..Armor.SlotNames[selection.Slot].."\n"..(if current[selection.Slot]==selection.Id then "Đang mặc" else "Đang xem trước")
		end
		drawActor()
	end
	local function chooseTarget(target)
		api.Target=target;api.Selected=nil;api:Refresh()
	end
	playerTab.Activated:Connect(function() chooseTarget("Player") end)
	petTab.Activated:Connect(function() chooseTarget("Pet") end)
	weaponTab.Activated:Connect(function() api.Category="Weapons";api.Selected=nil;api:Refresh() end)
	armorTab.Activated:Connect(function() api.Category="Armor";api.Selected=nil;api:Refresh() end)
	local dragInput,lastPointer,dragCamera
	local function stopDrag()
		dragInput=nil;lastPointer=nil
		if dragCamera then
			if dragCamera.Camera.CameraType==Enum.CameraType.Scriptable then dragCamera.Camera.CameraType=dragCamera.Type end
			dragCamera=nil
		end
	end
	table.insert(connections,actorView.InputBegan:Connect(function(input)
		if panel.Visible and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
			if dragInput then return end
			local camera=workspace.CurrentCamera
			dragCamera={Camera=camera,Type=camera.CameraType};camera.CameraType=Enum.CameraType.Scriptable
			dragInput=input;lastPointer=Vector2.new(input.Position.X,input.Position.Y)
		end
	end))
	table.insert(connections,UIS.InputChanged:Connect(function(input)
		if not dragInput or not panel.Visible then return end
		if not (dragInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement) and input~=dragInput then return end
		local position=Vector2.new(input.Position.X,input.Position.Y)
		local delta=(position-lastPointer)/math.max(scale.Scale,.1);lastPointer=position
		api.Yaw=(api.Yaw-delta.X*.45)%360
		api.Pitch=math.clamp(api.Pitch+delta.Y*.35,-65,65)
		orbit(actorView,api.Yaw,api.Pitch)
	end))
	table.insert(connections,UIS.InputEnded:Connect(function(input)
		if input==dragInput or input.UserInputType==Enum.UserInputType.MouseButton1 then stopDrag() end
	end))
	table.insert(connections,UIS.WindowFocusReleased:Connect(stopDrag))
	close.Activated:Connect(function() panel.Visible=false end)
	equip.Activated:Connect(function()
		local s=api.Selected;if s then remote:FireServer("EquipInventory",{Target=api.Target,Kind=api.Category,Id=s.Id,Slot=s.Slot}) end
	end)
	remove.Activated:Connect(function()
		local s=api.Selected;if s and api.Category=="Armor" then
			remote:FireServer("EquipInventory",{Target=api.Target,Kind="Armor",Id="None",Slot=s.Slot})
			api.Selected={Id="None",Slot=s.Slot};api:Refresh()
		end
	end)
	table.insert(connections,panel:GetPropertyChangedSignal("Visible"):Connect(function()
		stopDrag()
		cover.Visible=panel.Visible
		if panel.Visible then api.Selected=nil;api:Refresh() else actorView.PreviewWorld:ClearAllChildren();itemView.PreviewWorld:ClearAllChildren() end
	end))
	local attributes={"WeaponId","PetWeaponId"}
	for _,target in {"Player","Pet"} do for _,slot in Armor.Slots do table.insert(attributes,target.."Armor_"..slot) end end
	for _,attr in attributes do table.insert(connections,player:GetAttributeChangedSignal(attr):Connect(function() api:Refresh() end)) end
	table.insert(connections,player.CharacterAdded:Connect(function() task.delay(.5,function() if panel.Parent then api:Refresh() end end) end))
	panel.Destroying:Connect(function() stopDrag();for _,c in connections do c:Disconnect() end;cover:Destroy() end)
	return api
end
return Inventory
