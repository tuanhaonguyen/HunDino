-- Run in the dinosaur place's Edit datamodel, then install the two source files.
local model = assert(workspace:FindFirstChild("Dinosaur01_TRex_Visual"))
local head = model.head
local jawModel = head.LowerJaw
local skull = head.head_geom
local jaw = jawModel.jaw_geom
assert(not skull:FindFirstChild("JawMotor"), "Jaw is already rigged")

-- The original visually open pose was closed by another 12 degrees during fitting.
local original = jawModel:GetAttribute("PreviewOriginalPivot") or jawModel:GetPivot()
jawModel:PivotTo(original * CFrame.Angles(math.rad(12), 0, 0))
jawModel:SetAttribute("PreviewOriginalPivot", nil)
local hinge = skull.JawHinge.WorldCFrame
jaw.PivotOffset = jaw.CFrame:ToObjectSpace(hinge)
jaw.JawHinge.CFrame = jaw.PivotOffset
jawModel.PrimaryPart = jaw

local motor = Instance.new("Motor6D")
motor.Name = "JawMotor"
motor.Part0 = skull
motor.Part1 = jaw
motor.C0 = skull.CFrame:ToObjectSpace(hinge)
motor.C1 = jaw.CFrame:ToObjectSpace(hinge)
motor:SetAttribute("ClosedC0", motor.C0)
motor:SetAttribute("Axis", "Local X; negative opens down")
motor.Parent = skull

local teeth = 0
for _,part in jawModel:GetDescendants() do
	if part:IsA("BasePart") then
		part.CanCollide = false
		part.CanTouch = false
		part.Massless = true
		if part ~= jaw then
			local weld = Instance.new("WeldConstraint")
			weld.Name = "JawToothWeld"
			weld.Part0 = jaw
			weld.Part1 = part
			weld.Parent = part
			teeth += 1
		end
		part.Anchored = false
	end
end

local request = Instance.new("BindableEvent")
request.Name = "BiteRequest"
request.Parent = model

local preview = Instance.new("Attachment")
preview.Name = "BitePreview"
preview.Position = skull.CFrame:PointToObjectSpace(hinge.Position - hinge.ZVector * 7 - Vector3.new(0, 10, 0))
preview.Parent = skull
local prompt = Instance.new("ProximityPrompt")
prompt.Name = "BitePreviewPrompt"
prompt.ActionText = "Thử cắn"
prompt.ObjectText = "Hàm T-Rex"
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 60
prompt.RequiresLineOfSight = false
prompt.Parent = preview

model:SetAttribute("JawRigged", true)
model:SetAttribute("JawMaxOpenDegrees", 30)
model:SetAttribute("JawOpenDegrees", 0)
model:SetAttribute("JawOpenTime", 0.32)
model:SetAttribute("JawHoldTime", 0.12)
model:SetAttribute("JawCloseTime", 0.14)
model:SetAttribute("BiteCooldown", 1)
model:SetAttribute("BitePreviewEnabled", true)
model:SetAttribute("BitePhase", "Idle")
model:SetAttribute("BiteAnimationReady", true)
model:SetAttribute("Stage", "VisualModel_JawBiteRig")
model:SetAttribute("AttackReady", false)
return {joint = motor:GetFullName(), weldedLowerTeeth = teeth, maxOpenDegrees = 30}
