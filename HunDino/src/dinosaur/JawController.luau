-- Server-side jaw motion. This module only moves the mouth; it deals no damage.
local TweenService = game:GetService("TweenService")

local JawController = {}
JawController.__index = JawController
local controllers = setmetatable({}, { __mode = "k" })

local function setting(model, name, default, minimum, maximum)
	local value = model:GetAttribute(name)
	if typeof(value) ~= "number" or value ~= value or math.abs(value) == math.huge then
		value = default
	end
	return math.clamp(value, minimum, maximum)
end

function JawController.new(model)
	if controllers[model] then
		return controllers[model]
	end
	local motor = assert(model:FindFirstChild("JawMotor", true), "Missing JawMotor")
	assert(motor:IsA("Motor6D") and motor.Part0 and motor.Part1, "Invalid jaw rig")
	local closedC0 = assert(motor:GetAttribute("ClosedC0"), "Missing closed jaw pose")
	local self = setmetatable({
		Model = model,
		Motor = motor,
		ClosedC0 = closedC0,
		_angle = Instance.new("NumberValue"),
		_generation = 0,
		_busy = false,
		_destroyed = false,
		_lastBite = -math.huge,
	}, JawController)
	self._changed = self._angle.Changed:Connect(function(angle)
		-- The hinge's X axis crosses the skull. Negative rotation opens downward.
		motor.C0 = closedC0 * CFrame.Angles(-math.rad(angle), 0, 0)
		model:SetAttribute("JawOpenDegrees", angle)
	end)
	motor.C0 = closedC0
	model:SetAttribute("JawOpenDegrees", 0)
	model:SetAttribute("BitePhase", "Idle")
	controllers[model] = self
	return self
end

function JawController:_limit(angle)
	return math.clamp(angle, 0, setting(self.Model, "JawMaxOpenDegrees", 30, 0, 35))
end

-- Manual posing for previews; returns false while a bite is already running.
function JawController:SetOpenAngle(angle)
	if self._busy or self._destroyed then
		return false
	end
	assert(typeof(angle) == "number" and angle == angle, "Angle must be a number")
	self._angle.Value = self:_limit(angle)
	return true
end

function JawController:_move(angle, duration, style, direction, generation)
	if self._destroyed or generation ~= self._generation then
		return false
	end
	self._tween = TweenService:Create(self._angle, TweenInfo.new(duration, style, direction), {
		Value = self:_limit(angle),
	})
	self._tween:Play()
	local state = self._tween.Completed:Wait()
	return not self._destroyed and generation == self._generation
		and state == Enum.PlaybackState.Completed
end

-- Yields until the bite finishes. BindableEvent callbacks can call this directly.
function JawController:Bite()
	if self._destroyed or self._busy then
		return false, "Busy"
	end
	local model = self.Model
	local cooldown = setting(model, "BiteCooldown", 1, 0, 10)
	if os.clock() - self._lastBite < cooldown then
		return false, "Cooldown"
	end
	self._lastBite = os.clock()
	self._busy = true
	self._generation += 1
	local generation = self._generation
	model:SetAttribute("BitePhase", "Opening")
	if not self:_move(setting(model, "JawMaxOpenDegrees", 30, 0, 35),
		setting(model, "JawOpenTime", 0.32, 0.05, 3), Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out, generation) then
		return false, "Cancelled"
	end
	model:SetAttribute("BitePhase", "Holding")
	task.wait(setting(model, "JawHoldTime", 0.12, 0, 3))
	if self._destroyed or generation ~= self._generation then
		return false, "Cancelled"
	end
	model:SetAttribute("BitePhase", "Closing")
	if not self:_move(0, setting(model, "JawCloseTime", 0.14, 0.05, 3),
		Enum.EasingStyle.Quad, Enum.EasingDirection.In, generation) then
		return false, "Cancelled"
	end
	self._busy = false
	model:SetAttribute("BitePhase", "Idle")
	return true
end

function JawController:Cancel()
	self._generation += 1
	if self._tween then
		self._tween:Cancel()
	end
	self._angle.Value = 0
	self.Motor.C0 = self.ClosedC0
	self._busy = false
	self.Model:SetAttribute("JawOpenDegrees", 0)
	self.Model:SetAttribute("BitePhase", "Idle")
end

function JawController:Destroy()
	if self._destroyed then
		return
	end
	self:Cancel()
	self._destroyed = true
	self._changed:Disconnect()
	self._angle:Destroy()
	controllers[self.Model] = nil
end

return JawController
