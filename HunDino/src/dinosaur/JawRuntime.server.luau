local model = script.Parent
local controller = require(model:WaitForChild("JawController")).new(model)
local request = model:WaitForChild("BiteRequest")
local prompt = model:FindFirstChild("BitePreviewPrompt", true)

request.Event:Connect(function()
	controller:Bite()
end)

if prompt then
	local function updatePreview()
		prompt.Enabled = model:GetAttribute("BitePreviewEnabled") == true
	end
	updatePreview()
	model:GetAttributeChangedSignal("BitePreviewEnabled"):Connect(updatePreview)
	prompt.Triggered:Connect(function()
		controller:Bite()
	end)
end

script.Destroying:Connect(function()
	controller:Destroy()
end)
