-- Run once in Studio Edit. Adds portals without rebuilding the existing map.
local map=workspace:WaitForChild("HunDinoL0")
assert(not map:FindFirstChild("BaseTransit"),"BaseTransit already exists")
local root=Instance.new("Folder");root.Name="BaseTransit"
local bases=Instance.new("Folder");bases.Name="Bases";bases.Parent=root
local teal=Color3.fromRGB(84,220,191)
local gold=Color3.fromRGB(222,183,102)
local function part(model,name,size,cf,color,material,collide)
	local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material
	p.Anchored=true;p.CanCollide=collide or false;p.CanQuery=collide or false;p.CanTouch=false;p.Parent=model;return p
end
local function portal(parent,name,point,look,title,action)
	local m=Instance.new("Model");m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;m.Parent=parent
	local cf=CFrame.lookAt(point,point+look)
	local floor=part(m,"Platform",Vector3.new(.45,10,10),cf*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(52,65,58),Enum.Material.Slate,true)
	floor.Shape=Enum.PartType.Cylinder
	for i=0,15 do
		local a=i*math.pi/8
		part(m,"Rune",Vector3.new(1.35,.12,.25),cf*CFrame.new(math.sin(a)*4.25,.3,math.cos(a)*4.25)*CFrame.Angles(0,a,0),teal,Enum.Material.Neon)
	end
	local diamond=part(m,"Core",Vector3.new(1.25,.15,1.25),cf*CFrame.new(0,.3,0)*CFrame.Angles(0,math.pi/4,0),gold,Enum.Material.Neon)
	local pad=part(m,"Pad",Vector3.new(8,4,8),cf*CFrame.new(0,2,0),teal,Enum.Material.SmoothPlastic);pad.Transparency=1
	local prompt=Instance.new("ProximityPrompt");prompt.Name="TransitPrompt";prompt.ActionText=action;prompt.ObjectText=title
	prompt.KeyboardKeyCode=Enum.KeyCode.G;prompt.HoldDuration=.6;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=pad
	local arrival=part(m,"Arrival",Vector3.one,cf*CFrame.new(0,3.8,0),teal,Enum.Material.SmoothPlastic);arrival.Transparency=1;arrival.CanQuery=false
	local sign=Instance.new("BillboardGui");sign.Name="TransitSign";sign.Size=UDim2.fromOffset(250,60);sign.StudsOffset=Vector3.new(0,4.5,0);sign.MaxDistance=95;sign.AlwaysOnTop=true;sign.Parent=diamond
	local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(17,35,30);text.BackgroundTransparency=.15
	text.Text=title.."\nGiữ G • "..action;text.Font=Enum.Font.GothamBold;text.TextSize=15;text.TextColor3=Color3.fromRGB(238,231,204);text.TextWrapped=true;text.Parent=sign
	local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=text
	m.PrimaryPart=pad;return m
end
portal(root,"Center",Vector3.new(-23,19.25,193),Vector3.new(1,0,0),"DỊCH CHUYỂN BASE","Chọn base 1–12")
for id=1,12 do
	local base=workspace.DarkJungle.Bases:FindFirstChild("Base"..id)
	local spawn=assert(base and base:FindFirstChild("SpawnPad"),"Missing base "..id)
	local toward=Vector3.new(-spawn.Position.X,0,-spawn.Position.Z).Unit
	local point=spawn.Position+toward*26-Vector3.new(0,.05,0)
	local m=portal(bases,"Base"..id,point,toward,string.format("BASE %02d → SẢNH TRUNG TÂM",id),"Về sảnh")
	m:SetAttribute("BaseId",id)
end
root.Parent=map
return "Created 12 base portals and central base selector"
