-- Client presentation only. Injector yaw follows the specimen but its height
-- never bobs: Beam endpoints bend between a fixed ceiling and moving implants.
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TAG = "HunDinoBioSpecimen"
local MAX_DISTANCE = 240
local tracked = {}
local connections = {}
local running = true
local nextMembershipUpdate = 0
local nearby = {}

local function disconnectEntry(entry)
	if entry.changed then entry.changed:Disconnect() end
	if entry.added then entry.added:Disconnect() end
	if entry.removed then entry.removed:Disconnect() end
end

local function remove(model)
	local entry = tracked[model]
	if not entry then return end
	disconnectEntry(entry)
	tracked[model] = nil
end

local function register(model)
	if tracked[model] or not model:IsA("Model") then return end
	local entry = {model = model, dirty = true, valid = false, nextFrame = 0, distance = math.huge}
	local function dirty() entry.dirty = true end
	entry.changed = model.AttributeChanged:Connect(dirty)
	-- Tag replication may precede children and attributes; a partial clone is
	-- retried after every descendant arrives instead of being permanently skipped.
	entry.added = model.DescendantAdded:Connect(dirty)
	entry.removed = model.DescendantRemoving:Connect(dirty)
	tracked[model] = entry
end

local function hydrate(entry)
	entry.dirty = false
	entry.valid = false
	local assembly = entry.model
	if not assembly:IsDescendantOf(Workspace) or assembly:GetAttribute("Ready") ~= true then return end
	local specimen, injector = assembly:FindFirstChild("Specimen"), assembly:FindFirstChild("RotatingInjector")
	local origin = assembly:GetAttribute("StaticOrigin")
	local rest = assembly:GetAttribute("SpecimenRestPivot")
	local injectorRest = assembly:GetAttribute("InjectorRestPivot")
	local slot = assembly:GetAttribute("DisplaySlot")
	if not specimen or not specimen:IsA("Model") or not injector or not injector:IsA("Model")
		or typeof(origin) ~= "CFrame" or typeof(rest) ~= "CFrame" or typeof(injectorRest) ~= "CFrame"
		or type(slot) ~= "number" or slot < 1 or slot > 5 then return end
	-- The tube index is authoritative for presentation, including #5's exact
	-- zero yaw. Metadata cannot accidentally make the center exhibit rotate.
	entry.specimen, entry.injector = specimen, injector
	entry.origin, entry.rest, entry.injectorRest = origin, rest, injectorRest
	entry.speed = if slot == 5 then 0 else math.rad(10)
	entry.amplitude = .12
	entry.frequency = .22
	entry.valid = true
end

table.insert(connections, CollectionService:GetInstanceAddedSignal(TAG):Connect(register))
table.insert(connections, CollectionService:GetInstanceRemovedSignal(TAG):Connect(remove))
for _, model in CollectionService:GetTagged(TAG) do register(model) end

table.insert(connections, RunService.RenderStepped:Connect(function()
	if not running then return end
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local now = os.clock()
	if now >= nextMembershipUpdate then
		nextMembershipUpdate = now + .35
		table.clear(nearby)
		for model, entry in tracked do
			if not model.Parent then remove(model); continue end
			if entry.dirty or not entry.valid then hydrate(entry) end
			if entry.valid then
				entry.distance = (camera.CFrame.Position - entry.origin.Position).Magnitude
				if entry.distance <= MAX_DISTANCE then table.insert(nearby, entry) end
			end
		end
	end
	-- A shared server clock produces the same heading for all observers and
	-- catches a streamed-in tube up immediately without server per-frame traffic.
	local phase = Workspace:GetServerTimeNow()
	for _, entry in nearby do
		if tracked[entry.model] ~= entry or not entry.model.Parent then continue end
		if entry.dirty then hydrate(entry) end
		if not entry.valid or now < entry.nextFrame then continue end
		entry.nextFrame = now + (if entry.distance <= 95 then 1 / 30 else 1 / 15)
		local yaw = (phase * entry.speed) % (math.pi * 2)
		local bob = math.sin(phase * math.pi * 2 * entry.frequency) * entry.amplitude
		local rotation = entry.origin * CFrame.Angles(0, yaw, 0) * entry.origin:Inverse()
		entry.specimen:PivotTo(entry.origin * CFrame.new(0, bob, 0) * entry.origin:Inverse() * rotation * entry.rest)
		entry.injector:PivotTo(rotation * entry.injectorRest)
	end
end))

script.Destroying:Connect(function()
	running = false
	for _, connection in connections do connection:Disconnect() end
	for _, entry in tracked do disconnectEntry(entry) end
	table.clear(tracked)
	table.clear(nearby)
end)
