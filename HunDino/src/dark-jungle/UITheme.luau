-- Shared presentation tokens. This module never sends gameplay requests.
local TweenService = game:GetService("TweenService")
local Theme = {}
Theme.Colors = {
	Panel = Color3.fromRGB(16, 20, 26), Card = Color3.fromRGB(26, 32, 42),
	Border = Color3.fromRGB(165, 135, 65), Gold = Color3.fromRGB(235, 195, 95),
	Text = Color3.fromRGB(240, 242, 246), Muted = Color3.fromRGB(158, 170, 188),
	Health = Color3.fromRGB(46, 204, 113), Stamina = Color3.fromRGB(52, 172, 224),
	Warning = Color3.fromRGB(235, 95, 45),
}
function Theme.round(item, radius)
	local corner = item:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8); corner.Parent = item
	return corner
end
function Theme.panel(item)
	item.BackgroundColor3 = Theme.Colors.Panel; item.BackgroundTransparency = .12; item.BorderSizePixel = 0
	Theme.round(item, 14)
	local stroke = item:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Name = "HunterBorder"; stroke.Color = Theme.Colors.Border; stroke.Thickness = 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Transparency = .2; stroke.Parent = item
	local gradient = stroke:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(.5, Color3.fromRGB(106, 114, 134)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))})
	gradient.Rotation = 35; gradient.Parent = stroke
	return stroke
end
function Theme.button(item)
	item.BackgroundColor3 = Theme.Colors.Card; item.BorderSizePixel = 0; item.AutoButtonColor = false
	if item:IsA("TextButton") then item.TextColor3 = Theme.Colors.Text end
	Theme.round(item, 8)
	local stroke = item:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Color = Theme.Colors.Border; stroke.Thickness = 1; stroke.Transparency = .55
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Parent = item
	local tween
	local function highlight(active)
		if tween then tween:Cancel() end
		tween = TweenService:Create(stroke, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = if active then Theme.Colors.Gold else Theme.Colors.Border, Transparency = if active then 0 else .55})
		tween:Play()
	end
	item.MouseEnter:Connect(function() highlight(item.Active) end)
	item.MouseLeave:Connect(function() highlight(false) end)
	item.SelectionGained:Connect(function() highlight(true) end)
	item.SelectionLost:Connect(function() highlight(false) end)
	item.MouseButton1Down:Connect(function() if item.Active then item.BackgroundColor3 = Color3.fromRGB(53, 49, 39) end end)
	item.MouseButton1Up:Connect(function() item.BackgroundColor3 = Theme.Colors.Card end)
	return stroke
end
function Theme.Ring(parent, name, size, thickness, color)
	local frame = Instance.new("Frame")
	frame.Name = name; frame.Size = UDim2.fromOffset(size, size); frame.AnchorPoint = Vector2.new(.5, .5)
	frame.Position = UDim2.fromScale(.5, .5); frame.BackgroundTransparency = 1; frame.BorderSizePixel = 0
	frame.ZIndex = if parent:IsA("GuiObject") then parent.ZIndex + 1 else 2; frame.Parent = parent
	local segments = {}; local total = 72; local radius = (size - thickness) / 2
	for index = 1, total do
		local angle = (index - 1) / total * math.pi * 2
		local segment = Instance.new("Frame")
		segment.Name = string.format("Arc%02d", index); segment.AnchorPoint = Vector2.new(.5, .5)
		segment.Size = UDim2.fromOffset(thickness, math.max(2, radius * math.pi * 2 / total + .8))
		segment.Position = UDim2.fromOffset(size / 2 + math.sin(angle) * radius, size / 2 - math.cos(angle) * radius)
		segment.Rotation = math.deg(angle); segment.BorderSizePixel = 0; segment.BackgroundColor3 = Theme.Colors.Card
		segment.ZIndex = frame.ZIndex; segment.Parent = frame; Theme.round(segment, math.min(2, thickness / 2))
		segments[index] = segment
	end
	local lastCount, lastColor
	local api = {Frame = frame}
	function api:Set(progress, tint)
		progress = if type(progress) == "number" and progress == progress then math.clamp(progress, 0, 1) else 0
		local count = math.floor(progress * total + .5); tint = tint or color or Theme.Colors.Gold
		if count == lastCount and tint == lastColor then return end
		for index, segment in segments do
			segment.BackgroundColor3 = if index <= count then tint else Theme.Colors.Card
			segment.BackgroundTransparency = if index <= count then 0 else .15
		end
		lastCount, lastColor = count, tint
	end
	function api:Destroy() frame:Destroy() end
	api:Set(0); return api
end
return Theme
