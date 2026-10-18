-- A slow procedural walk for the current segmented dinosaur mesh.
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MotionController = {}
MotionController.__index = MotionController
local controllers = setmetatable({}, { __mode = "k" })

function MotionController.new(model)
	if controllers[model] then return controllers[model] end
	local root = assert(model.PrimaryPart, "Missing dinosaur root")
	local motors = {}
	for _, part in model:GetDescendants() do
		if part:IsA("Motor6D") and part.Name ~= "JawMotor" then
			motors[part.Name] = { joint = part, rest = part:GetAttribute("RestC0") }
			local encoded = part:GetAttribute("FootSamples")
			if encoded then motors[part.Name].foot = HttpService:JSONDecode(encoded) end
		end
	end
	local forward = root.CFrame:VectorToWorldSpace(model:GetAttribute("ForwardInRoot"))
	forward = Vector3.new(forward.X, 0, forward.Z).Unit
	local heading = CFrame.lookAt(root.Position, root.Position + forward)
	local self = setmetatable({ Model = model, Root = root, Motors = motors,
		Home = root.CFrame, Heading = heading, Offset = heading:ToObjectSpace(root.CFrame),
		_phase = 0, _pathAngle = 0, _blend = 0, _walking = false,
		_nod = 0, _elapsed = 0, _accumulator = 0 }, MotionController)
	self._center = root.Position - heading.RightVector * 50
	self._connection = RunService.Heartbeat:Connect(function(dt) self:_step(dt) end)
	controllers[model] = self
	model:SetAttribute("PreviewWalking", false)
	return self
end

local function footOffset(data, angle, lift, bob)
	local restMinimum, minimum = math.huge, math.huge
	for _, point in data.foot do
		restMinimum = math.min(restMinimum, point[2])
		minimum = math.min(minimum, point[2] * math.cos(angle) - point[3] * math.sin(angle))
	end
	return restMinimum - minimum + lift - bob
end

function MotionController:_step(dt)
	self._accumulator += dt
	if self._accumulator < 1 / 30 then return end
	dt = math.min(self._accumulator, .12)
	self._accumulator = 0
	self._elapsed += dt
	local target = self._walking and 1 or 0
	self._blend += (target - self._blend) * math.min(1, dt * 6)
	if self._blend < .0001 then self._blend = 0 end
	local blend = self._blend
	self._phase += dt * math.pi * 2 * .66 * blend
	local phase = self._phase
	local bob = .18 * (1 - math.cos(phase * 2)) * .5 * blend
	if blend > 0 then
		local speed = math.clamp(self.Model:GetAttribute("WalkSpeed") or 6, 0, 12)
		self._pathAngle += dt * speed * blend / 50
		local angle = self._pathAngle
		local side, forward = self.Heading.RightVector, self.Heading.LookVector
		local position = self._center + (side * math.cos(angle) + forward * math.sin(angle)) * 50
		local direction = -side * math.sin(angle) + forward * math.cos(angle)
		self.Root.CFrame = CFrame.lookAt(position + Vector3.new(0, bob, 0), position + direction + Vector3.new(0, bob, 0))
			* CFrame.Angles(0, 0, math.sin(phase) * .006 * blend) * self.Offset
	end
	for name, sign in { LeftHip = 1, RightHip = -1 } do
		local data = self.Motors[name]
		local angle = math.sin(phase) * sign * math.rad(11) * blend
		local lift = math.max(0, math.cos(phase) * sign) * .8 * blend
		local offset = footOffset(data, angle, lift, bob)
		data.joint.C0 = data.rest * CFrame.new(0, offset, 0) * CFrame.Angles(angle, 0, 0)
	end
	for name, sign in { LeftShoulder = -1, RightShoulder = 1 } do
		local data = self.Motors[name]
		data.joint.C0 = data.rest * CFrame.Angles(math.sin(phase) * sign * .065 * blend, 0, 0)
	end
	local tail = self.Motors.Tail
	tail.joint.C0 = tail.rest * CFrame.Angles(0, math.sin(phase - .4) * .035 * blend, 0)
	local bite = self.Model:GetAttribute("BitePhase")
	local nodTarget = bite == "Closing" and -math.rad(5)
		or ((bite == "Opening" or bite == "Holding") and math.rad(1.5) or 0)
	self._nod += (nodTarget - self._nod) * math.min(1, dt * 15)
	local neck = self.Motors.Neck
	neck.joint.C0 = neck.rest * CFrame.Angles(self._nod + math.sin(phase * 2) * .012 * blend, 0, 0)
end

function MotionController:SetWalking(enabled)
	self._walking = enabled == true
	self.Model:SetAttribute("PreviewWalking", self._walking)
end

function MotionController:Reset()
	self:SetWalking(false)
	self._blend, self._phase, self._pathAngle, self._nod = 0, 0, 0, 0
	self.Root.CFrame = self.Home
	for _, data in self.Motors do data.joint.C0 = data.rest end
end

function MotionController:Destroy()
	if self._connection then self._connection:Disconnect() end
	self:Reset()
	controllers[self.Model] = nil
end

return MotionController
