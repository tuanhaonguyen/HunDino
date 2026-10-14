local Menu={}
local RunService=game:GetService("RunService")
function Menu.create(player,gui,onSelect)
	local api={}
	local shade=Instance.new("TextButton");shade.Name="BaseTransitShade";shade.Text="";shade.Size=UDim2.fromScale(1,1)
	shade.BackgroundColor3=Color3.new();shade.BackgroundTransparency=.4;shade.ZIndex=39;shade.Visible=false;shade.Parent=gui
	local panel=Instance.new("Frame");panel.Name="BaseTransitMenu";panel.Size=UDim2.fromOffset(660,560);panel.AnchorPoint=Vector2.new(.5,.5)
	panel.Position=UDim2.fromScale(.5,.5);panel.BackgroundColor3=Color3.fromRGB(27,38,31);panel.ZIndex=40;panel.Visible=false;panel.Parent=gui
	local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,12);corner.Parent=panel
	local scale=Instance.new("UIScale");scale.Parent=panel
	local function resize() local size=workspace.CurrentCamera.ViewportSize;scale.Scale=math.min(1,(size.X-32)/660,(size.Y-64)/560) end
	local resizeConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize);resize()
	local function label(value,x,y,w,h,size)
		local t=Instance.new("TextLabel");t.Text=value;t.BackgroundTransparency=1;t.TextColor3=Color3.fromRGB(241,230,203);t.Font=Enum.Font.GothamMedium
		t.TextSize=size;t.TextWrapped=true;t.Position=UDim2.fromOffset(x,y);t.Size=UDim2.fromOffset(w,h);t.Parent=panel;return t
	end
	label("ĐI TỚI BASE",24,16,570,40,24)
	label("Chọn điểm đến • Đi thăm base không đổi base sở hữu",24,60,612,36,14)
	local buttons={}
	for id=1,12 do
		local b=Instance.new("TextButton");b.Name="Base"..id;b.Position=UDim2.fromOffset(24+((id-1)%3)*208,110+math.floor((id-1)/3)*95)
		b.Size=UDim2.fromOffset(196,82);b.BackgroundColor3=Color3.fromRGB(42,67,54);b.TextColor3=Color3.fromRGB(241,230,203)
		b.Font=Enum.Font.GothamMedium;b.TextSize=16;b.TextWrapped=true;b.Parent=panel
		local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,8);c.Parent=b
		b.Activated:Connect(function() if panel.Visible then api:Close();onSelect(id) end end);buttons[id]=b
	end
	label("Đứng gần bệ dịch chuyển để chọn • Giữ G tại base để về sảnh",24,500,612,42,14)
	local close=Instance.new("TextButton");close.Name="Close";close.Text="×";close.TextSize=24;close.TextColor3=Color3.fromRGB(241,230,203)
	close.BackgroundTransparency=1;close.Position=UDim2.fromOffset(610,18);close.Size=UDim2.fromOffset(30,30);close.Parent=panel
	function api:Close() panel.Visible=false;shade.Visible=false end
	function api:IsOpen() return panel.Visible end
	local origin,expires
	function api:Open(data)
		origin=data.Origin;expires=os.clock()+60
		for id,b in buttons do
			local row=data.Bases[id];local own=id==player:GetAttribute("BaseId")
			b.Text=string.format("BASE %02d%s\n%s",id,if own then " • CỦA BẠN" else "",row and row.Owner or "Chưa có chủ")
			b.BackgroundColor3=if own then Color3.fromRGB(101,81,42) else Color3.fromRGB(42,67,54)
		end
		panel.Visible=true;shade.Visible=true
	end
	close.Activated:Connect(function() api:Close() end);shade.Activated:Connect(function() api:Close() end)
	local heartbeat=RunService.Heartbeat:Connect(function()
		if not panel.Visible then return end
		local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart");local hum=character and character:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health<=0 or os.clock()>expires or (root.Position-origin).Magnitude>14 then api:Close() end
	end)
	panel.Destroying:Connect(function() resizeConnection:Disconnect();heartbeat:Disconnect();shade:Destroy() end)
	return api
end
return Menu
