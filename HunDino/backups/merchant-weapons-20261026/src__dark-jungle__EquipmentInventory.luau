local Inventory={}
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Armor=require(RS.Shared:WaitForChild("ArmorEquipment"))
local Builder=require(RS.Shared:WaitForChild("WeaponsPro"))
local Theme=require(script.Parent:WaitForChild("UITheme"))
local gold=Theme.Colors.Gold
local bronze=Theme.Colors.Border
local ink=Theme.Colors.Text
local muted=Theme.Colors.Muted
local dark=Theme.Colors.Panel
local cardColor=Theme.Colors.Card
local selectedColor=Color3.fromRGB(48,44,34)
local readyColor=Theme.Colors.Health
local hoverTween=TweenInfo.new(.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local round=Theme.round
local function setSelected(button,value)
	button:SetAttribute("UISelected",value==true)
end
local names={Hammer="Búa tạ",SwordShield="Kiếm & khiên",Katana="Kiếm Katana",Glaive="Thương cán dài",DualDaggers="Song dao",Bow="Cung",GreatAxe="Rìu đại hai lưỡi"}
local itemCatalog={
	{Id="Skin",Name="Da khủng long",Group="Materials",Color=Color3.fromRGB(145,102,66),Description="Nguyên liệu nhận từ mổ xác hoặc bắt sống."},
	{Id="Tooth",Name="Răng khủng long",Group="Materials",Color=Color3.fromRGB(232,223,188),Description="Nguyên liệu nhận từ mổ xác hoặc bắt sống."},
	{Id="Scale",Name="Vảy khủng long",Group="Materials",Color=Color3.fromRGB(117,159,121),Description="Nhặt vảy rơi, mổ xác hoặc bắt sống."},
	{Id="Bone",Name="Xương",Group="Materials",Color=Color3.fromRGB(219,210,180),Description="Nhận khi hoàn thành nhiệm vụ săn."},
	{Id="Iron",Name="Sắt",Group="Materials",Color=Color3.fromRGB(159,173,179),Description="Nhặt từ quặng sắt trong khu săn."},
	{Id="RawTrap",Name="Bẫy thô",Group="Stored",Color=Color3.fromRGB(158,126,83),Description="Vật tư mua từ thương nhân, dùng để chế bẫy sắt."},
	{Id="IronTrap",Name="Bẫy sắt",Group="Stored",Color=Color3.fromRGB(174,188,186),Description="Bẫy dùng trong cuộc săn; giữ B để đặt."},
	{Id="SleepPotion",Name="Thuốc ngủ",Group="Stored",Color=Color3.fromRGB(119,176,163),Description="Cho quái yếu đang mắc bẫy uống để bắt sống."},
}
local function count(value)
	return if type(value)=="number" and value==value and math.abs(value)<math.huge then math.max(0,math.floor(value)) else 0
end
local function specimenDate(value)
	local timestamp=count(value)
	if timestamp<=0 then return "Chưa có thời gian" end
	local ok,date=pcall(os.date,"!%d/%m/%Y · %H:%M (UTC+7)",timestamp+7*60*60)
	return if ok then date else "Chưa có thời gian"
end
local function specimenClone(template,record)
	local model=template:Clone()
	if not model then return nil end
	for _,name in {"CombatHitboxes","Runtime","HuntRuntime"} do
		local old=model:FindFirstChild(name);if old then old:Destroy() end
	end
	for _,v in model:GetDescendants() do
		if v:IsA("LuaSourceContainer") or v:IsA("JointInstance") or v:IsA("Constraint") or v:IsA("Humanoid") or v:IsA("Animator") or v:IsA("AnimationController")
			or v:IsA("LayerCollector") or v:IsA("ProximityPrompt") or v:IsA("ClickDetector") or v:IsA("Sound") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("ParticleEmitter") then v:Destroy()
		elseif v:IsA("BasePart") then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false end
	end
	for attr in model:GetAttributes() do
		local ok,err=pcall(model.SetAttribute,model,attr,nil)
		if not ok then assert(attr:sub(1,4)=="RBX_" and tostring(err):find("permission",1,true),err) end
	end
	local size=record.SizeScale
	if type(size)=="number" and size==size and size>0 and size<math.huge then model:ScaleTo(model:GetScale()*math.clamp(size,.1,10)) end
	model:PivotTo(CFrame.new())
	return model
end
local function itemModel(item)
	local model=Instance.new("Model");model.Name=item.Id
	local function part(name,size,cf,color,shape)
		local p=Instance.new(if shape=="Wedge" then "WedgePart" else "Part")
		p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or item.Color;p.Material=Enum.Material.SmoothPlastic
		p.Anchored=true;p.CanCollide=false;p.CanTouch=false
		if shape=="Ball" then p.Shape=Enum.PartType.Ball elseif shape=="Cylinder" then p.Shape=Enum.PartType.Cylinder end
		p.Parent=model;return p
	end
	if item.Id=="SleepPotion" then
		part("Bottle",Vector3.new(1.4,1.7,1.4),CFrame.new(),nil,"Ball")
		part("Neck",Vector3.new(.65,.75,.65),CFrame.new(0,1,0))
		part("Stopper",Vector3.new(.8,.3,.8),CFrame.new(0,1.5,0),Color3.fromRGB(121,85,51))
	elseif item.Id=="IronTrap" then
		for n=1,12 do local a=n*math.pi/6;part("Ring",Vector3.new(.6,.18,.23),CFrame.new(math.cos(a),0,math.sin(a))*CFrame.Angles(0,-a,0)) end
		part("Plate",Vector3.new(1.2,.18,1.2),CFrame.new())
	elseif item.Id=="RawTrap" then
		part("Frame",Vector3.new(2,.3,1.7),CFrame.new())
		for _,x in {-0.8,.8} do part("Spring",Vector3.new(.3,.7,1.4),CFrame.new(x,.4,0)) end
	elseif item.Id=="Bone" then
		part("Shaft",Vector3.new(2.2,.45,.45),CFrame.Angles(0,0,.4),nil,"Cylinder")
		for _,x in {-1.1,1.1} do part("End",Vector3.new(.75,.75,.75),CFrame.new(x,x*.4,0),nil,"Ball") end
	elseif item.Id=="Tooth" then
		part("Tooth",Vector3.new(.9,2.1,.8),CFrame.Angles(.15,0,-.3),nil,"Wedge")
	elseif item.Id=="Skin" then
		part("Hide",Vector3.new(2.2,.3,1.7),CFrame.Angles(0,.35,.08))
		part("Fold",Vector3.new(.6,.5,1.7),CFrame.new(-.8,.15,0)*CFrame.Angles(0,.35,.08))
	else
		part("Resource",Vector3.new(1.8,if item.Id=="Scale" then .45 else 1.25,1.6),CFrame.Angles(.15,.45,.15),nil,"Wedge")
	end
	return model
end

local function frame(parent,name,x,y,w,h,color)
	local f=Instance.new("Frame");f.Name=name;f.Position=UDim2.fromOffset(x,y);f.Size=UDim2.fromOffset(w,h)
	f.BorderSizePixel=0;f.BackgroundColor3=color or cardColor;f.Parent=parent;round(f)
	return f
end
local function line(parent,color)
	local s=Instance.new("UIStroke");s.Color=color or bronze;s.Thickness=1;s.Transparency=.48;s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Parent=parent;return s
end
local function label(parent,name,value,x,y,w,h,size)
	local t=Instance.new("TextLabel");t.Name=name;t.BackgroundTransparency=1;t.Text=value;t.TextColor3=ink
	t.Font=Enum.Font.GothamMedium;t.TextSize=size or 15;t.TextWrapped=true;t.Position=UDim2.fromOffset(x,y);t.Size=UDim2.fromOffset(w,h);t.Parent=parent;return t
end
local function button(parent,name,value,x,y,w,h)
	local b=Instance.new("TextButton");b.Name=name;b.Text=value;b.Font=Enum.Font.GothamMedium;b.TextSize=15;b.TextColor3=ink
	b.BorderSizePixel=0;b.BackgroundColor3=cardColor;b.Position=UDim2.fromOffset(x,y);b.Size=UDim2.fromOffset(w,h);b.Parent=parent;b.AutoButtonColor=false;round(b)
	local stroke=line(b)
	local hovered,pressed=false,false
	local function paint()
		local active=b:GetAttribute("UISelected")==true
		TweenService:Create(stroke,hoverTween,{Color=if active or hovered or pressed then gold else bronze,Transparency=if active or hovered or pressed then .03 else .52,Thickness=if pressed then 2.5 elseif active then 1.5 else 1}):Play()
		TweenService:Create(b,hoverTween,{BackgroundTransparency=if pressed then .02 elseif hovered then .06 else .14}):Play()
	end
	b.MouseEnter:Connect(function() hovered=true;paint() end)
	b.MouseLeave:Connect(function() hovered=false;pressed=false;paint() end)
	b.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then pressed=true;paint() end end)
	b.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then pressed=false;paint() end end)
	b:GetAttributeChangedSignal("UISelected"):Connect(paint)
	paint();return b
end
local function viewport(parent,name,x,y,w,h)
	local v=Instance.new("ViewportFrame");v.Name=name;v.Position=UDim2.fromOffset(x,y);v.Size=UDim2.fromOffset(w,h)
	v.BackgroundColor3=dark;v.BorderSizePixel=0;v.Ambient=Color3.fromRGB(205,217,232);round(v)
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
	local boundsSize,boundsCF=v:GetAttribute("OrbitBoundsSize"),v:GetAttribute("OrbitBoundsCFrame")
	if boundsSize and boundsCF then
		local orientation=CFrame.lookAt(center+direction,center).Rotation
		local pixels=v.AbsoluteSize
		local aspect=if pixels.X>0 and pixels.Y>0 then pixels.X/pixels.Y else v.Size.X.Offset/math.max(v.Size.Y.Offset,1)
		local tanV=math.tan(math.rad(v.CurrentCamera.FieldOfView*.5))
		local tanH=tanV*math.max(aspect,.1)
		local half=boundsSize*.5
		distance=1
		for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
			local corner=boundsCF:VectorToWorldSpace(Vector3.new(half.X*x,half.Y*y,half.Z*z))
			local q=orientation:VectorToObjectSpace(corner)
			distance=math.max(distance,q.Z+math.abs(q.X)/tanH,q.Z+math.abs(q.Y)/tanV)
		end end end
		distance*=1.15
	end
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
	if v:GetAttribute("FitBoundsOnOrbit") then v:SetAttribute("OrbitBoundsSize",size);v:SetAttribute("OrbitBoundsCFrame",cf) end
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
	local api={Target="Player",Category="Weapons",Section="Equipment",Selected=nil,Yaw=18,Pitch=5,SelectedSpecimenId=nil,SpecimenYaw=55,SpecimenPitch=12,SelectedDisplaySlot=1}
	local connections={}
	local economyRemote=RS:WaitForChild("HunDinoEconomyAction")
	local itemSnapshot,stopDrag,inventoryDisplayOrder
	local cover=frame(gui,"InventoryShade",0,0,0,0,Color3.new(0,0,0));cover.Size=UDim2.fromScale(1,1)
	cover.BackgroundTransparency=.4;cover.Visible=false;cover.Active=true;cover.ZIndex=20
	local panel=frame(gui,"WeaponSelection",0,0,1070,660,dark)
	panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Visible=false;panel.ZIndex=21;panel.BackgroundTransparency=.12
	Theme.panel(panel)
	local headerRule=frame(panel,"HeaderRule",24,68,1022,1,bronze);headerRule.BackgroundTransparency=.65
	api.Frame=panel
	local scale=Instance.new("UIScale");scale.Parent=panel
	local function resize()
		local size=workspace.CurrentCamera.ViewportSize;scale.Scale=math.min(1,(size.X-38)/1070,(size.Y-80)/660)
	end
	table.insert(connections,workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize));resize()
	local title=label(panel,"Heading","TÚI ĐỒ",24,13,220,32,23);title.Font=Enum.Font.GothamBold;title.TextXAlignment=Enum.TextXAlignment.Left
	local subtitle=label(panel,"Subtitle","H U N D I N O  /  T R A N G  B Ị",24,44,242,15,10);subtitle.TextXAlignment=Enum.TextXAlignment.Left;subtitle.TextColor3=muted
	local close=button(panel,"Close","×",1018,16,32,32)
	local playerTab=button(panel,"PlayerTab","NGƯỜI",275,18,132,40)
	local petTab=button(panel,"PetTab","PET",419,18,110,40)
	local itemsTab=button(panel,"ItemsTab","VẬT PHẨM",541,18,142,40)
	local specimensTab=button(panel,"SpecimensTab","KHỦNG LONG",695,18,154,40)
	local craftTab=button(panel,"CraftingTab","CHẾ TẠO",861,18,142,40)
	local weaponTab=button(panel,"WeaponsTab","VŨ KHÍ",330,79,205,42)
	local armorTab=button(panel,"ArmorTab","GIÁP",547,79,205,42)
	local actorName=label(panel,"ActorName","",24,75,280,38,20)
	local actorView=viewport(panel,"CharacterPreview",24,125,282,428);actorView.BackgroundTransparency=.25;line(actorView)
	actorView.Active=true;actorView:SetAttribute("FitBoundsOnOrbit",true)
	local resetView=button(panel,"ResetView","Đặt lại góc nhìn",62,566,206,30);resetView.TextSize=12
	local rotateHint=label(panel,"RotateHint","Kéo để xoay · Nghiêng ±65°",24,604,282,22,12);rotateHint.TextColor3=muted
	local previewCaption=label(panel,"PreviewCaption","XEM TRƯỚC TRANG BỊ",24,629,282,14,10);previewCaption.TextColor3=gold
	local list=frame(panel,"EquipmentList",330,136,422,443);list.BackgroundTransparency=1
	local weaponList=Instance.new("ScrollingFrame");weaponList.Name="WeaponList";weaponList.Position=UDim2.fromOffset(0,0);weaponList.Size=UDim2.fromScale(1,1)
	weaponList.BackgroundTransparency=1;weaponList.BorderSizePixel=0;weaponList.ScrollBarThickness=3;weaponList.CanvasSize=UDim2.fromOffset(0,370);weaponList.Parent=list
	local armorList=Instance.new("ScrollingFrame");armorList.Name="ArmorList";armorList.Position=UDim2.fromOffset(0,36);armorList.Size=UDim2.new(1,0,1,-36)
	armorList.BackgroundTransparency=1;armorList.BorderSizePixel=0;armorList.ScrollBarThickness=3;armorList.CanvasSize=UDim2.fromOffset(0,408);armorList.Parent=list
	local headers=frame(list,"SlotHeaders",0,0,410,30);headers.BackgroundTransparency=1
	for i,slot in Armor.Slots do label(headers,slot,Armor.SlotNames[slot],(i-1)*82,0,76,28,14) end
	local detail=frame(panel,"ItemDetails",774,136,272,443,cardColor);line(detail,bronze)
	local selectedName=label(detail,"SelectedName","",12,10,248,52,19);selectedName.Font=Enum.Font.GothamBold
	local itemView=viewport(detail,"ItemPreview",12,74,248,224);line(itemView)
	local info=label(detail,"SelectionInfo","",16,309,240,120,13);info.TextXAlignment=Enum.TextXAlignment.Left;info.TextYAlignment=Enum.TextYAlignment.Top
	local equip=button(panel,"EquipSelected","TRANG BỊ",786,595,158,42);equip.BackgroundColor3=selectedColor;equip.TextColor3=gold;equip.Font=Enum.Font.GothamBold
	local remove=button(panel,"RemoveSelected","THÁO",954,595,80,42);remove.TextColor3=muted;remove.TextSize=13
	local hint=label(panel,"EquipHint","Trang bị ở bãi tập hoặc khu săn khi đã cất vũ khí",330,595,422,42,13)
	local itemSummary=label(panel,"ItemSummary","",24,78,1022,42,16);itemSummary.TextXAlignment=Enum.TextXAlignment.Left
	itemSummary.Font=Enum.Font.GothamBold;itemSummary.TextSize=18;itemSummary.TextColor3=gold
	local itemPage=frame(panel,"ItemsPage",24,136,1022,485,dark);itemPage.BackgroundTransparency=.35;line(itemPage)
	local itemsHeading=label(itemPage,"Title","VẬT PHẨM SỞ HỮU",16,10,400,30,19);itemsHeading.TextXAlignment=Enum.TextXAlignment.Left
	local filters={};local filter="All"
	for i,row in {{"All","TẤT CẢ"},{"Materials","NGUYÊN LIỆU"},{"Stored","VẬT TƯ SĂN"}} do filters[row[1]]=button(itemPage,row[1],row[2],484+(i-1)*174,10,162,32) end
	local itemScroll=Instance.new("ScrollingFrame");itemScroll.Name="ItemGrid";itemScroll.Position=UDim2.fromOffset(8,58);itemScroll.Size=UDim2.fromOffset(1006,380)
	itemScroll.BackgroundTransparency=1;itemScroll.BorderSizePixel=0;itemScroll.ScrollBarThickness=4;itemScroll.CanvasSize=UDim2.fromOffset(0,364);itemScroll.Parent=itemPage
	local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(239,170);grid.CellPadding=UDim2.fromOffset(12,12);grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=itemScroll
	local itemHint=label(itemPage,"Hint","",16,447,990,28,12);itemHint.TextXAlignment=Enum.TextXAlignment.Left;itemHint.TextColor3=gold
	local itemCards={}
	for index,item in itemCatalog do
		local card=frame(itemScroll,item.Id,0,0,239,170,cardColor);card.LayoutOrder=index;line(card)
		card.MouseEnter:Connect(function() TweenService:Create(card.UIStroke,hoverTween,{Color=gold,Transparency=.05}):Play() end)
		card.MouseLeave:Connect(function() TweenService:Create(card.UIStroke,hoverTween,{Color=bronze,Transparency=.48}):Play() end)
		local icon=viewport(card,"Icon",10,10,74,72);icon.BackgroundTransparency=1;show(icon,itemModel(item),false,20,12)
		local name=label(card,"Name",item.Name,94,10,133,40,15);name.TextXAlignment=Enum.TextXAlignment.Left
		local quantity=label(card,"Quantity","…",94,51,133,30,23);quantity.TextXAlignment=Enum.TextXAlignment.Left;quantity.TextColor3=gold
		local description=label(card,"Description",item.Description,12,91,215,45,12);description.TextXAlignment=Enum.TextXAlignment.Left
		local location=label(card,"Location","",10,137,219,26,10);location.TextXAlignment=Enum.TextXAlignment.Left;location.TextColor3=muted
		local stock=frame(card,"StockBreakdown",8,136,223,28,dark);stock.BackgroundTransparency=.18;stock.ZIndex=location.ZIndex;location.Parent=stock;location.Position=UDim2.fromOffset(4,0)
		itemCards[item.Id]={Frame=card,Quantity=quantity,Location=location}
	end
	local specimenPage=frame(panel,"SpecimensPage",24,136,1022,485,dark);specimenPage.BackgroundTransparency=.35;line(specimenPage)
	local specimenHeading=label(specimenPage,"Title","CÁ THỂ ĐÃ BẮT SỐNG",16,10,740,30,19);specimenHeading.TextXAlignment=Enum.TextXAlignment.Left
	local specimenCount=label(specimenPage,"CountBadge","… / 100",822,10,184,30,17);specimenCount.TextColor3=gold;specimenCount.TextXAlignment=Enum.TextXAlignment.Right
	local specimenScroll=Instance.new("ScrollingFrame");specimenScroll.Name="SpecimenList";specimenScroll.Position=UDim2.fromOffset(16,54);specimenScroll.Size=UDim2.fromOffset(358,374)
	specimenScroll.BackgroundTransparency=1;specimenScroll.BorderSizePixel=0;specimenScroll.ScrollBarThickness=4;specimenScroll.CanvasSize=UDim2.fromOffset(0,0);specimenScroll.Parent=specimenPage
	local specimenDetails=frame(specimenPage,"SpecimenDetails",392,54,614,374,cardColor);line(specimenDetails,bronze)
	local specimenName=label(specimenDetails,"SelectedName","",14,10,586,34,21);specimenName.Font=Enum.Font.GothamBold;specimenName.TextXAlignment=Enum.TextXAlignment.Left
	local specimenView=viewport(specimenDetails,"SpecimenPreview",14,56,350,250);specimenView.Active=true;specimenView:SetAttribute("FitBoundsOnOrbit",true);line(specimenView)
	local resetSpecimenView=button(specimenDetails,"ResetView","Đặt lại góc nhìn",92,312,194,22);resetSpecimenView.TextSize=11
	local specimenUnavailable=label(specimenDetails,"PreviewUnavailable","Chưa có hình xem trước cho loài này.",32,126,314,104,16)
	local specimenMetadata=label(specimenDetails,"Metadata","",380,56,220,264,13);specimenMetadata.TextXAlignment=Enum.TextXAlignment.Left;specimenMetadata.TextYAlignment=Enum.TextYAlignment.Top
	local specimenIdentity=label(specimenDetails,"Identity","",14,340,586,26,10);specimenIdentity.TextXAlignment=Enum.TextXAlignment.Left;specimenIdentity.TextColor3=muted
	local specimenEmpty=label(specimenPage,"EmptyState","Đang tải bộ sưu tập…",96,162,830,110,20)
	local specimenHint=label(specimenPage,"Hint","Tự xoay 12°/giây · Kéo để xoay / nghiêng ±65° · Tháo hoặc đổi ống luôn giữ cá thể trong kho.",16,469,990,14,10);specimenHint.TextXAlignment=Enum.TextXAlignment.Left;specimenHint.TextColor3=gold
	local displayButtons={}
	for slot=1,5 do
		local b=button(specimenPage,"DisplaySlot_"..slot,"ỐNG #"..slot,16+(slot-1)*70,433,62,30);b.TextSize=11
		displayButtons[slot]=b
	end
	local displayTarget=label(specimenPage,"DisplayTarget","",392,433,210,30,12);displayTarget.TextXAlignment=Enum.TextXAlignment.Left
	local assignSpecimen=button(specimenPage,"AssignDisplaySlot","ĐẶT VÀO ỐNG #1",614,433,226,30);assignSpecimen.TextSize=12;assignSpecimen.TextColor3=gold
	local clearSpecimen=button(specimenPage,"ClearDisplaySlot","THÁO KHỎI ỐNG",850,433,156,30);clearSpecimen.TextSize=11
	local specimenCards,displayedSpecimenKey={}
	local specimenAutoResumeAt=0
	local function displaySlots() return if itemSnapshot and type(itemSnapshot.DisplaySlots)=="table" then itemSnapshot.DisplaySlots else {} end
	local function displayedAt(specimenId)
		for slot=1,5 do if displaySlots()[slot]==specimenId then return slot end end
		return nil
	end
	local refreshSpecimens
	refreshSpecimens=function()
		local ready=itemSnapshot~=nil and type(itemSnapshot.OwnedSpecimens)=="table"
		local records={}
		if ready then
			for _,record in itemSnapshot.OwnedSpecimens do
				if type(record)=="table" and type(record.Id)=="string" and record.Id~="" then table.insert(records,record) end
			end
		end
		table.sort(records,function(a,b)
			local aSerial,bSerial=count(a.Serial),count(b.Serial)
			if aSerial~=bSerial then return aSerial>bSerial end
			local aDate,bDate=count(a.CapturedAt),count(b.CapturedAt)
			if aDate~=bDate then return aDate>bDate end
			return a.Id<b.Id
		end)
		local limit=if ready then math.max(1,count(itemSnapshot.SpecimenLimit or 100)) else 100
		local total=if ready and type(itemSnapshot.SpecimenCount)=="number" then count(itemSnapshot.SpecimenCount) else #records
		specimenCount.Text=(if ready then tostring(total) else "…").." / "..limit
		itemSummary.Text=if ready then "Bộ sưu tập khủng long · "..total.." cá thể · Nhận cá thể khi bắt sống thành công" else "Đang tải bộ sưu tập khủng long…"
		local current,retained={}
		for _,record in records do if record.Id==api.SelectedSpecimenId then retained=record;break end end
		local selected=retained or records[1]
		api.SelectedSpecimenId=if selected then selected.Id else nil
		local targetId=displaySlots()[api.SelectedDisplaySlot]
		local sourceSlot=selected and displayedAt(selected.Id)
		for slot,b in displayButtons do
			setSelected(b,api.SelectedDisplaySlot==slot)
			b.TextColor3=if displaySlots()[slot] then gold else muted
		end
		displayTarget.Text="ỐNG #"..api.SelectedDisplaySlot..(if targetId then " · ĐANG CÓ CÁ THỂ" else " · TRỐNG")
		assignSpecimen.Active=ready and selected~=nil and sourceSlot~=api.SelectedDisplaySlot
		assignSpecimen.Text=if sourceSlot==api.SelectedDisplaySlot then "ĐÃ Ở ỐNG #"..api.SelectedDisplaySlot elseif sourceSlot then "CHUYỂN SANG ỐNG #"..api.SelectedDisplaySlot else "ĐẶT VÀO ỐNG #"..api.SelectedDisplaySlot
		assignSpecimen.TextTransparency=if assignSpecimen.Active then 0 else .5
		clearSpecimen.Active=ready and targetId~=nil;clearSpecimen.TextTransparency=if clearSpecimen.Active then 0 else .5
		for index,record in records do
			current[record.Id]=true
			local card=specimenCards[record.Id]
			if not card then
				local b=button(specimenScroll,"Specimen_"..record.Id,"",0,0,344,124)
				local name=label(b,"Name","",12,8,320,28,17);name.Font=Enum.Font.GothamBold;name.TextXAlignment=Enum.TextXAlignment.Left
				local identity=label(b,"Summary","",12,42,320,22,12);identity.TextXAlignment=Enum.TextXAlignment.Left;identity.TextColor3=muted
				local captured=label(b,"CapturedAt","",12,70,320,22,11);captured.TextXAlignment=Enum.TextXAlignment.Left;captured.TextColor3=muted
				local displayBadge=label(b,"DisplayStatus","",12,98,320,17,10);displayBadge.TextXAlignment=Enum.TextXAlignment.Left;displayBadge.TextColor3=gold
				card={Button=b,Name=name,Summary=identity,Date=captured,Display=displayBadge};specimenCards[record.Id]=card
				local id=record.Id
				b.Activated:Connect(function()
					if stopDrag then stopDrag() end
					if api.SelectedSpecimenId~=id then api.SpecimenYaw=55;api.SpecimenPitch=12 end
					api.SelectedSpecimenId=id;refreshSpecimens()
				end)
			end
			card.Button.Position=UDim2.fromOffset(0,(index-1)*136)
			card.Button.BackgroundColor3=if selected and selected.Id==record.Id then selectedColor else cardColor
			setSelected(card.Button,selected~=nil and selected.Id==record.Id)
			card.Name.Text=(if type(record.Name)=="string" then record.Name else "Khủng long").."  #"..string.format("%03d",count(record.Serial))
			local scale=if type(record.SizeScale)=="number" and record.SizeScale==record.SizeScale and record.SizeScale>0 and record.SizeScale<math.huge then record.SizeScale else 1
			card.Summary.Text=(if record.Element=="None" then "Không hệ" else tostring(record.Element or "Không hệ")).."  ·  "..(if record.Variant=="Normal" then "Thường" else tostring(record.Variant or "Thường")).."  ·  "..math.floor(scale*100+.5).."%"
			card.Date.Text=specimenDate(record.CapturedAt)
			local slot=displayedAt(record.Id)
			card.Display.Text=if slot then "ĐANG TRƯNG BÀY · ỐNG #"..slot else "CÁ THỂ  "..string.sub(record.Id,1,8)
			card.Display.TextColor3=if slot then gold else muted
		end
		for id,card in specimenCards do if not current[id] then card.Button:Destroy();specimenCards[id]=nil end end
		specimenScroll.CanvasSize=UDim2.fromOffset(0,math.max(0,#records*136-12))
		specimenScroll.Visible=selected~=nil;specimenDetails.Visible=selected~=nil;specimenEmpty.Visible=selected==nil
		specimenEmpty.Text=if ready then "Chưa có cá thể nào trong bộ sưu tập.\nBắt sống khủng long để nhận cá thể đầu tiên." else "Đang tải bộ sưu tập…"
		if not selected then specimenView.PreviewWorld:ClearAllChildren();displayedSpecimenKey=nil;return end
		specimenName.Text=(if type(selected.Name)=="string" then selected.Name else "Khủng long").."  #"..string.format("%03d",count(selected.Serial))
		local size=if type(selected.SizeScale)=="number" and selected.SizeScale==selected.SizeScale and selected.SizeScale>0 and selected.SizeScale<math.huge then selected.SizeScale else 1
		specimenMetadata.Text="Loài: "..(if selected.SpeciesId=="TRex" then "T-Rex" else tostring(selected.SpeciesId or "Chưa rõ"))
			.."\nBiến thể: "..(if selected.Variant=="Normal" then "Thường" else tostring(selected.Variant or "Thường"))
			.."\nNguyên tố: "..(if selected.Element=="None" then "Không hệ" else tostring(selected.Element or "Không hệ"))
			.."\nKích thước: "..math.floor(size*100+.5).."%"
			.."\n\nBắt lúc:\n"..specimenDate(selected.CapturedAt)
			.."\n\nNguồn lượt săn:\n"..tostring(selected.SourceRunId or "Chưa có thông tin")
			.."\n\nTrưng bày: "..(if sourceSlot then "Ống #"..sourceSlot else "Đang trong kho")
		specimenIdentity.Text="GUID  "..selected.Id
		local templates=RS:FindFirstChild("SpecimenVisuals")
		local template=templates and templates:FindFirstChild(selected.SpeciesId or "TRex")
		local key=selected.Id..":"..tostring(selected.SpeciesId)..":"..tostring(size)
		specimenUnavailable.Visible=not (template and template:IsA("Model"))
		if specimenUnavailable.Visible then specimenView.PreviewWorld:ClearAllChildren();displayedSpecimenKey=nil
		elseif displayedSpecimenKey~=key or #specimenView.PreviewWorld:GetChildren()==0 then
			show(specimenView,specimenClone(template,selected),true,api.SpecimenYaw,api.SpecimenPitch);displayedSpecimenKey=key
		end
	end
	for slot,b in displayButtons do b.Activated:Connect(function() api.SelectedDisplaySlot=slot;refreshSpecimens() end) end
	local lastDisplayRequest=-math.huge
	local function requestDisplay(specimenId)
		if not itemSnapshot or os.clock()-lastDisplayRequest<.3 then return end
		lastDisplayRequest=os.clock()
		economyRemote:FireServer("SetDisplaySlot",{Slot=api.SelectedDisplaySlot,SpecimenId=specimenId,
			OperationToken=itemSnapshot.OperationToken,OperationSerial=count(itemSnapshot.OperationSerial)+1})
	end
	assignSpecimen.Activated:Connect(function() if assignSpecimen.Active and api.SelectedSpecimenId then requestDisplay(api.SelectedSpecimenId) end end)
	clearSpecimen.Activated:Connect(function() if clearSpecimen.Active then requestDisplay(false) end end)
	local craftPage=frame(panel,"CraftingPage",24,136,1022,485,dark);craftPage.BackgroundTransparency=.35;line(craftPage)
	label(craftPage,"Title","CHẾ TẠO",24,24,974,42,24).TextColor3=gold
	label(craftPage,"Status","CHƯA TRIỂN KHAI",190,150,642,46,22)
	label(craftPage,"Description","Công thức và thao tác chế tạo trong Inventory sẽ được bổ sung sau.\nHiện tại, xem toàn bộ vật phẩm đang có ở mục Vật phẩm.",190,208,642,88,17)
	local equipmentViews={weaponTab,armorTab,actorName,actorView,resetView,rotateHint,previewCaption,list,detail,equip,remove,hint}
	local function refreshItems()
		local ready=itemSnapshot~=nil
		itemSummary.Text=if ready then "XU  "..count(itemSnapshot.Coins).."      /      BÚA CẤP "..math.max(1,count(itemSnapshot.HammerLevel)) else "Đang cập nhật vật phẩm…"
		local active=ready and itemSnapshot.ActiveRun
		local materials=ready and itemSnapshot.Materials or {}
		local stored=ready and (itemSnapshot.Stored or itemSnapshot.StoredConsumables) or {}
		local visible=0
		for _,item in itemCatalog do
			local card=itemCards[item.Id];card.Frame.Visible=filter=="All" or filter==item.Group
			if card.Frame.Visible then visible+=1 end
			local saved=count((if item.Group=="Materials" then materials else stored)[item.Id])
			local carried=if type(active)=="table" and item.Id=="IronTrap" then count(active.IronTraps or active.Traps) elseif type(active)=="table" and item.Id=="SleepPotion" then count(active.Potions) else 0
			local total=saved+carried
			card.Quantity.Text=if ready then "×"..total else "…"
			card.Frame.BackgroundColor3=cardColor
			card.Quantity.TextColor3=if total>0 then gold else muted
			card.Location.Text=if not ready then "Đang cập nhật…" elseif item.Id=="IronTrap" or item.Id=="SleepPotion" then "Trong kho: "..saved.."  |  Đi săn: "..carried.."/3" else "Trong kho: "..saved
		end
		for id,b in filters do b.BackgroundColor3=if filter==id then selectedColor else cardColor;setSelected(b,filter==id) end
		itemScroll.CanvasSize=UDim2.fromOffset(0,math.ceil(visible/4)*182)
		itemHint.Text="Cập nhật trực tiếp · Bẫy/thuốc tính cả phần đang mang đi săn · Dữ liệu hiện chỉ giữ trong máy chủ."
	end
	for id,b in filters do b.Activated:Connect(function() filter=id;itemScroll.CanvasPosition=Vector2.zero;refreshItems() end) end
	local cells,weaponButtons,weaponLevels,setProgress={},{},{},{}
	local function hammerLevel()
		return if itemSnapshot then math.max(1,count(itemSnapshot.HammerLevel)) else nil
	end
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
		local bounds,size=clone:GetBoundingBox()
		local diameter=math.max(size.X,size.Z,2)*1.2
		local pedestal=Instance.new("Part");pedestal.Name="PreviewPedestal";pedestal.Shape=Enum.PartType.Cylinder
		pedestal.Size=Vector3.new(.32,diameter,diameter);pedestal.CFrame=CFrame.new(bounds.Position.X,bounds.Position.Y-size.Y*.5-.18,bounds.Position.Z)*CFrame.Angles(0,0,math.pi*.5)
		pedestal.Color=Color3.fromRGB(29,34,44);pedestal.Material=Enum.Material.Slate;pedestal.Anchored=true;pedestal.CanCollide=false;pedestal.CanTouch=false;pedestal.CanQuery=false;pedestal.Parent=clone
		if api.Category=="Weapons" then addWeapon(clone,api.Target,if api.Selected then api.Selected.Id else equippedWeapon()) end
		show(actorView,clone,true,api.Yaw,api.Pitch)
	end
	local function select(id,slot)
		api.Selected={Id=id,Slot=slot}
		api:Refresh()
	end
	for i,id in weapons.Order do
		local b=button(weaponList,id,"",((i-1)%2)*213,math.floor((i-1)/2)*186,199,174)
		local title=label(b,"WeaponName",names[id] or weapons[id].Name,12,8,175,34,16);title.Font=Enum.Font.GothamBold;title.TextXAlignment=Enum.TextXAlignment.Left
		local level=label(b,"Level","",12,44,175,20,11);level.TextColor3=gold;level.TextXAlignment=Enum.TextXAlignment.Left;weaponLevels[id]=level
		local keyNames={L="Trái",H="Q",S="E",D="Space"}
		for index,combo in weapons[id].Combos or {} do
			if index>4 then break end
			local x=12
			for keyIndex=1,#combo.Input do
				local key=combo.Input:sub(keyIndex,keyIndex)
				local width=if key=="D" then 39 elseif key=="L" then 27 else 18
				local badge=label(b,"Combo"..index.."Key"..keyIndex,keyNames[key] or key,x,69+(index-1)*23,width,18,9)
				badge.BackgroundColor3=dark;badge.BackgroundTransparency=.12;badge.TextColor3=if key=="H" then gold elseif key=="S" then Theme.Colors.Stamina else ink;round(badge,4)
				x+=width
				if keyIndex<#combo.Input then label(b,"Arrow"..index.."_"..keyIndex,"›",x,69+(index-1)*23,9,18,11).TextColor3=muted;x+=9 end
			end
		end
		weaponButtons[id]=b
		b.Activated:Connect(function() select(id,nil) end)
	end
	weaponList.CanvasSize=UDim2.fromOffset(0,math.ceil(#weapons.Order/2)*186-12)
	for row,id in Armor.Order do
		local group=frame(armorList,id,0,(row-1)*99,410,92);group.BackgroundTransparency=1
		local name=label(group,"SetName","Giáp "..Armor.Sets[id].Name,0,0,408,24,15);name.TextXAlignment=Enum.TextXAlignment.Left
		setProgress[id]=label(group,"SetProgress","0/5",340,0,68,24,13);setProgress[id].TextColor3=gold;setProgress[id].TextXAlignment=Enum.TextXAlignment.Right
		cells[id]={}
		for i,slot in Armor.Slots do
			local cell=button(group,slot,"",(i-1)*82,28,74,59)
			local v=viewport(cell,"Icon",2,2,70,53);v.BackgroundTransparency=1;v.Active=false
			local tick=label(cell,"Equipped","ĐANG MẶC",2,42,70,16,10);tick.TextColor3=gold;tick.Visible=false;tick.BackgroundColor3=dark;tick.BackgroundTransparency=.05;round(tick,4)
			cells[id][slot]={Button=cell,Viewport=v,Tick=tick}
			cell.Activated:Connect(function() select(id,slot) end)
		end
	end
	function api:Refresh()
		if not panel.Visible then return end
		local equipment=self.Section=="Equipment"
		for _,v in equipmentViews do v.Visible=equipment end
		itemPage.Visible=self.Section=="Items";specimenPage.Visible=self.Section=="Specimens";craftPage.Visible=self.Section=="Crafting";itemSummary.Visible=not equipment
		local tabStates={{itemsTab,self.Section=="Items"},{specimensTab,self.Section=="Specimens"},{craftTab,self.Section=="Crafting"},{playerTab,equipment and self.Target=="Player"},{petTab,equipment and self.Target=="Pet"}}
		for _,state in tabStates do state[1].BackgroundColor3=if state[2] then selectedColor else cardColor;state[1].TextColor3=if state[2] then gold else muted;setSelected(state[1],state[2]) end
		if not equipment then
			if stopDrag then stopDrag() end
			actorView.PreviewWorld:ClearAllChildren();itemView.PreviewWorld:ClearAllChildren()
			if self.Section=="Specimens" then refreshSpecimens()
			else specimenView.PreviewWorld:ClearAllChildren();displayedSpecimenKey=nil;refreshItems() end
			return
		end
		specimenView.PreviewWorld:ClearAllChildren();displayedSpecimenKey=nil
		actorName.Text=if self.Target=="Pet" then "PET ĐỒNG HÀNH" else player.DisplayName
		weaponTab.BackgroundColor3=if self.Category=="Weapons" then selectedColor else cardColor;setSelected(weaponTab,self.Category=="Weapons")
		armorTab.BackgroundColor3=if self.Category=="Armor" then selectedColor else cardColor;setSelected(armorTab,self.Category=="Armor")
		weaponList.Visible=self.Category=="Weapons";armorList.Visible=self.Category=="Armor";headers.Visible=armorList.Visible;remove.Visible=armorList.Visible
		if not self.Selected then
			self.Selected=if self.Category=="Weapons" then {Id=equippedWeapon()} else {Id=Armor.read(player,self.Target).Head,Slot="Head"}
		end
		local selection=self.Selected
		for id,b in weaponButtons do
			b.BackgroundColor3=if selection.Id==id then selectedColor else cardColor;setSelected(b,selection.Id==id and self.Category=="Weapons")
			local level=if id=="Hammer" and self.Target=="Player" then hammerLevel() else 1
			weaponLevels[id].Text=if level==nil then "Cấp độ: đang cập nhật…" elseif id=="Hammer" and self.Target=="Player" and level>=2 then "CẤP 2  ·  +15% sát thương" else "CẤP "..level..(if equippedWeapon()==id then "  ·  ĐANG DÙNG" else "  ·  SỞ HỮU")
		end
		if self.Category=="Weapons" then
			equip.Size=UDim2.fromOffset(248,42)
			selectedName.Text=names[selection.Id] or weapons[selection.Id].Name
			local item=Builder.build(selection.Id)
			local offhand=item:FindFirstChild("Offhand")
			if offhand then offhand:PivotTo(CFrame.new(if selection.Id=="DualDaggers" then .85 else 1.7,0,0)) end
			show(itemView,item,false)
			local level=if selection.Id=="Hammer" and self.Target=="Player" then hammerLevel() else 1
			info.Text=(if selection.Id==equippedWeapon() then "ĐANG TRANG BỊ" else "ĐÃ SỞ HỮU · CÓ THỂ TRANG BỊ")
				.."\n"..(if level==nil then "Đang cập nhật cấp độ…" else "Cấp "..level)..(if selection.Id=="Hammer" and self.Target=="Player" and level and level>=2 then " · +15% sát thương" else "")
				.."\n\n"..tostring(weapons[selection.Id].Description or "Vũ khí thợ săn")
			remove.Visible=false
		else
			equip.Size=UDim2.fromOffset(158,42)
			local current=Armor.read(player,self.Target)
			for id,row in cells do
				local worn=0
				for slot,data in row do
					show(data.Viewport,Armor.icon(self.Target,slot,id),false)
					data.Tick.Visible=current[slot]==id;if data.Tick.Visible then worn+=1 end
					local active=id==selection.Id and slot==selection.Slot
					data.Button.BackgroundColor3=if active then selectedColor else cardColor;setSelected(data.Button,active)
				end
				setProgress[id].Text=worn.."/5";setProgress[id].TextColor3=if worn==5 then readyColor else gold
			end
			selectedName.Text=(Armor.ItemNames[selection.Slot] or "Giáp").." • "..(Armor.Sets[selection.Id] and Armor.Sets[selection.Id].Name or "Không mặc")
			show(itemView,Armor.icon(self.Target,selection.Slot,selection.Id),false)
			info.Text=(if selection.Id=="None" then "Ô TRANG BỊ TRỐNG" elseif current[selection.Slot]==selection.Id then "ĐANG MẶC" else "ĐÃ SỞ HỮU · ĐANG XEM TRƯỚC").."\nVị trí: "..Armor.SlotNames[selection.Slot].."\n\nGiáp ngoại hình · Chưa có chỉ số phòng thủ.\nTrang bị riêng cho "..(if self.Target=="Pet" then "Pet." else "Người.")
		end
		drawActor()
	end
	local function chooseTarget(target)
		if stopDrag then stopDrag() end
		api.Section="Equipment";api.Target=target;api.Selected=nil;api:Refresh()
	end
	itemsTab.Activated:Connect(function() api.Section="Items";api:Refresh() end)
	specimensTab.Activated:Connect(function() api.Section="Specimens";api:Refresh() end)
	craftTab.Activated:Connect(function() api.Section="Crafting";api:Refresh() end)
	playerTab.Activated:Connect(function() chooseTarget("Player") end)
	petTab.Activated:Connect(function() chooseTarget("Pet") end)
	weaponTab.Activated:Connect(function() api.Category="Weapons";api.Selected=nil;api:Refresh() end)
	armorTab.Activated:Connect(function() api.Category="Armor";api.Selected=nil;api:Refresh() end)
	local dragInput,lastPointer,dragCamera,dragView
	stopDrag=function()
		if dragView==specimenView then specimenAutoResumeAt=os.clock()+1.5 end
		dragInput=nil;lastPointer=nil;dragView=nil
		if dragCamera then
			if dragCamera.Camera.CameraType==Enum.CameraType.Scriptable then dragCamera.Camera.CameraType=dragCamera.Type end
			dragCamera=nil
		end
	end
	for _,v in {actorView,specimenView} do
		table.insert(connections,v.InputBegan:Connect(function(input)
			if panel.Visible and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
				if dragInput then return end
				local camera=workspace.CurrentCamera
				dragCamera={Camera=camera,Type=camera.CameraType};camera.CameraType=Enum.CameraType.Scriptable
				dragInput=input;dragView=v;lastPointer=Vector2.new(input.Position.X,input.Position.Y)
			end
		end))
	end
	table.insert(connections,UIS.InputChanged:Connect(function(input)
		if not dragInput or not panel.Visible then return end
		if not (dragInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement) and input~=dragInput then return end
		local position=Vector2.new(input.Position.X,input.Position.Y)
		local delta=(position-lastPointer)/math.max(scale.Scale,.1);lastPointer=position
		if dragView==specimenView then
			api.SpecimenYaw=(api.SpecimenYaw-delta.X*.45)%360
			api.SpecimenPitch=math.clamp(api.SpecimenPitch+delta.Y*.35,-65,65)
			orbit(specimenView,api.SpecimenYaw,api.SpecimenPitch)
		else
			api.Yaw=(api.Yaw-delta.X*.45)%360
			api.Pitch=math.clamp(api.Pitch+delta.Y*.35,-65,65)
			orbit(actorView,api.Yaw,api.Pitch)
		end
	end))
	table.insert(connections,UIS.InputEnded:Connect(function(input)
		if input==dragInput or input.UserInputType==Enum.UserInputType.MouseButton1 then stopDrag() end
	end))
	table.insert(connections,UIS.WindowFocusReleased:Connect(stopDrag))
	table.insert(connections,RunService.RenderStepped:Connect(function(delta)
		if panel.Visible and api.Section=="Specimens" and displayedSpecimenKey and dragView~=specimenView and os.clock()>=specimenAutoResumeAt then
			api.SpecimenYaw=(api.SpecimenYaw+delta*12)%360
			orbit(specimenView,api.SpecimenYaw,api.SpecimenPitch)
		end
	end))
	resetView.Activated:Connect(function() stopDrag();api.Yaw=18;api.Pitch=5;orbit(actorView,api.Yaw,api.Pitch) end)
	resetSpecimenView.Activated:Connect(function() stopDrag();api.SpecimenYaw=55;api.SpecimenPitch=12;orbit(specimenView,api.SpecimenYaw,api.SpecimenPitch) end)
	close.Activated:Connect(function() panel.Visible=false end)
	equip.Activated:Connect(function()
		if api.Section~="Equipment" then return end
		local s=api.Selected;if s then remote:FireServer("EquipInventory",{Target=api.Target,Kind=api.Category,Id=s.Id,Slot=s.Slot}) end
	end)
	remove.Activated:Connect(function()
		local s=api.Selected;if api.Section=="Equipment" and s and api.Category=="Armor" then
			remote:FireServer("EquipInventory",{Target=api.Target,Kind="Armor",Id="None",Slot=s.Slot})
			api.Selected={Id="None",Slot=s.Slot};api:Refresh()
		end
	end)
	table.insert(connections,panel:GetPropertyChangedSignal("Visible"):Connect(function()
		stopDrag()
		cover.Visible=panel.Visible
		if panel.Visible then
			if inventoryDisplayOrder==nil then inventoryDisplayOrder=gui.DisplayOrder end
			gui.DisplayOrder=math.max(100,inventoryDisplayOrder+1)
		elseif inventoryDisplayOrder~=nil then gui.DisplayOrder=inventoryDisplayOrder;inventoryDisplayOrder=nil end
		if panel.Visible then api.Selected=nil;api:Refresh();economyRemote:FireServer("GetInventory") else actorView.PreviewWorld:ClearAllChildren();itemView.PreviewWorld:ClearAllChildren();specimenView.PreviewWorld:ClearAllChildren();displayedSpecimenKey=nil end
	end))
	table.insert(connections,economyRemote.OnClientEvent:Connect(function(event,dto)
		if event=="OpenSpecimenTube" then
			local slot=if type(dto)=="table" then dto.Slot else nil
			if type(slot)~="number" or slot%1~=0 or slot<1 or slot>5 or player:GetAttribute("Drawn")==true then return end
			stopDrag();api.Section="Specimens";api.SelectedDisplaySlot=slot
			local currentId=displaySlots()[slot];if currentId then api.SelectedSpecimenId=currentId end
			panel.Visible=true;api:Refresh();economyRemote:FireServer("GetInventory")
			return
		end
		if (event~="Snapshot" and event~="Open") or type(dto)~="table" then return end
		local revision=dto.Revision
		if type(revision)~="number" or revision~=revision or math.abs(revision)==math.huge or (itemSnapshot and revision<itemSnapshot.Revision) then return end
		itemSnapshot=dto
		if panel.Visible then api:Refresh() end
	end))
	local attributes={"WeaponId","PetWeaponId"}
	for _,target in {"Player","Pet"} do for _,slot in Armor.Slots do table.insert(attributes,target.."Armor_"..slot) end end
	for _,attr in attributes do table.insert(connections,player:GetAttributeChangedSignal(attr):Connect(function() api:Refresh() end)) end
	table.insert(connections,player.CharacterAdded:Connect(function() task.delay(.5,function() if panel.Parent then api:Refresh() end end) end))
	panel.Destroying:Connect(function() stopDrag();if inventoryDisplayOrder~=nil then gui.DisplayOrder=inventoryDisplayOrder end;for _,c in connections do c:Disconnect() end;cover:Destroy() end)
	return api
end
return Inventory
