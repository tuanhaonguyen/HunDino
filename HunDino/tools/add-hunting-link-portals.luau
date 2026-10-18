-- Additive Edit-only portals. The existing hub, base and training geometry stays intact.
assert(not game:GetService("RunService"):IsRunning(), "Edit only")
local hub=assert(workspace:FindFirstChild("HunDinoL0"))
local forest=assert(workspace:FindFirstChild("HuntingRainforest"))
assert(not hub:FindFirstChild("HuntingTransit"), "Hunting portal already installed")
assert(not forest.Camp:FindFirstChild("ReturnToLobby"), "Return portal already installed")
local green=Color3.fromRGB(101,204,147)
local function part(parent,name,size,cf,color,material,collide)
	local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material
	p.Anchored=true;p.CanCollide=collide==true;p.CanQuery=collide==true;p.CanTouch=false
	p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function gate(parent,padName,ground,title,action)
	local center=CFrame.new(ground)
	local platform=part(parent,"HuntPlatform",Vector3.new(.5,16,16),center*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(67,80,64),Enum.Material.Slate,true)
	platform.Shape=Enum.PartType.Cylinder
	for _,side in {-1,1} do
		part(parent,"MossPillar",Vector3.new(3,18,4),center*CFrame.new(side*10,9,-4),Color3.fromRGB(77,95,72),Enum.Material.Rock,true)
		part(parent,"GateRune",Vector3.new(.4,10,.3),center*CFrame.new(side*10,10,-1.85),green,Enum.Material.Neon,false)
	end
	part(parent,"Lintel",Vector3.new(24,3,5),center*CFrame.new(0,19,-4),Color3.fromRGB(67,87,67),Enum.Material.Rock,true)
	for i=0,15 do local angle=i*math.pi/8
		part(parent,"TrailRune",Vector3.new(1,.12,.3),center*CFrame.new(math.sin(angle)*6.5,.3,math.cos(angle)*6.5)*CFrame.Angles(0,angle,0),green,Enum.Material.Neon,false)
	end
	local pad=part(parent,padName,Vector3.new(10,6,10),center*CFrame.new(0,3,0),green,Enum.Material.SmoothPlastic,false)
	pad.Transparency=1
	local prompt=Instance.new("ProximityPrompt");prompt.Name="HuntingTransitPrompt";prompt.KeyboardKeyCode=Enum.KeyCode.G
	prompt.HoldDuration=.6;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false
	prompt.ObjectText=title;prompt.ActionText=action;prompt.Parent=pad
	local sign=Instance.new("BillboardGui");sign.Name="HuntingTransitSign";sign.Size=UDim2.fromOffset(270,66)
	sign.StudsOffsetWorldSpace=Vector3.new(0,13,0);sign.MaxDistance=180;sign.AlwaysOnTop=true;sign.Parent=pad
	local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(20,42,31)
	text.BackgroundTransparency=.1;text.TextColor3=Color3.fromRGB(235,231,201);text.Font=Enum.Font.GothamBold
	text.TextSize=16;text.TextWrapped=true;text.Text=title.."\nGiữ G · "..action;text.Parent=sign
	local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=text
	return pad
end
local entry=Instance.new("Model");entry.Name="HuntingTransit";entry.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;entry.Parent=hub
entry.PrimaryPart=gate(entry,"ToHunting",Vector3.new(-58,19.25,142),"RỪNG CỔ","Vào khu săn")
local decor=Instance.new("Model");decor.Name="ReturnGate";decor.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;decor.Parent=forest.Camp
local offset=forest:GetAttribute("WorldOffset") or Vector3.new(0,0,6500)
local returnPad=gate(decor,"ReturnToLobby",Vector3.new(-38,12.9,592)+offset,"SẢNH TRUNG TÂM","Về sảnh")
returnPad.Parent=forest.Camp;decor.PrimaryPart=nil
forest.Camp.CampSpawn.Enabled=false
hub:SetAttribute("HuntingLinked",true)
return {entry=entry.PrimaryPart.Position,returnToLobby=returnPad.Position}
