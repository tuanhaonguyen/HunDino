-- Hunting-map prototype clock. Start a new clock on mission entry; Stop on exit.
-- At the default 30x scale, 120 real seconds advance one in-world hour.
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local EnvironmentClock = {}
EnvironmentClock.__index = EnvironmentClock

local LIGHTING_PROPERTIES = {
	"ClockTime", "GeographicLatitude", "Brightness", "Ambient", "OutdoorAmbient",
	"ColorShift_Top", "ColorShift_Bottom", "ExposureCompensation", "FogStart", "FogEnd",
	"EnvironmentDiffuseScale", "EnvironmentSpecularScale", "GlobalShadows",
}
local ATMOSPHERE_PROPERTIES = { "Density", "Offset", "Color", "Decay", "Glare", "Haze" }
local READABILITY_PROPERTIES = { "Brightness", "Contrast", "Saturation", "TintColor", "Enabled" }

local function wallTime()
	return DateTime.now().UnixTimestampMillis / 1000
end

local function capture(instance, properties)
	local saved = {}
	for _, property in properties do
		saved[property] = instance[property]
	end
	return saved
end

local function restore(instance, properties)
	for property, value in properties do
		instance[property] = value
	end
end

local function mix(a, b, alpha)
	return a + (b - a) * alpha
end

local function smoothstep(low, high, value)
	local alpha = math.clamp((value - low) / (high - low), 0, 1)
	return alpha * alpha * (3 - 2 * alpha)
end

local function finiteNumber(value, default)
	if type(value) == "number" and value == value and math.abs(value) < math.huge then
		return value
	end
	return default
end

function EnvironmentClock.new(root, config)
	assert(typeof(root) == "Instance", "EnvironmentClock needs a map root Instance")
	config = config or {}
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	local readability = Lighting:FindFirstChild("HunDinoNightReadability")
	local self = setmetatable({
		Root = root,
		TimezoneOffsetMinutes = finiteNumber(config.TimezoneOffsetMinutes, 420),
		TimeScale = math.max(0.01, finiteNumber(config.TimeScale, 30)),
		Latitude = math.clamp(finiteNumber(config.ClockLatitude, -8), -90, 90),
		SavedLighting = capture(Lighting, LIGHTING_PROPERTIES),
		Atmosphere = atmosphere,
		SavedAtmosphere = if atmosphere then capture(atmosphere, ATMOSPHERE_PROPERTIES) else nil,
		OwnedAtmosphere = false,
		Readability = readability,
		SavedReadability = if readability then capture(readability, READABILITY_PROPERTIES) else nil,
		OwnedReadability = false,
		SavedClockHours = root:GetAttribute("GameClockHours"),
		SavedElapsedSeconds = root:GetAttribute("HuntElapsedSeconds"),
		Connection = nil,
		StartedAt = nil,
		EntryClockHours = nil,
		Destroyed = false,
	}, EnvironmentClock)
	return self
end

function EnvironmentClock:_ensureAtmosphere()
	if self.Atmosphere and self.Atmosphere.Parent == Lighting then
		return
	end
	-- A caller may construct the clock before setting up the rest of the scene.
	local existing = Lighting:FindFirstChildOfClass("Atmosphere")
	if existing then
		self.Atmosphere = existing
		self.SavedAtmosphere = capture(existing, ATMOSPHERE_PROPERTIES)
		self.OwnedAtmosphere = false
	else
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "HunDinoHuntingAtmosphere"
		atmosphere.Parent = Lighting
		self.Atmosphere = atmosphere
		self.SavedAtmosphere = nil
		self.OwnedAtmosphere = true
	end
end

function EnvironmentClock:Step(unixSeconds)
	assert(not self.Destroyed, "EnvironmentClock has been destroyed")
	if self.StartedAt == nil then
		return nil
	end
	local now = finiteNumber(unixSeconds, wallTime())
	local elapsed = math.max(0, now - self.StartedAt)
	local hours = (self.EntryClockHours + elapsed * self.TimeScale / 3600) % 24
	local sun = math.sin((hours - 6) / 24 * math.pi * 2)
	local daylight = smoothstep(-0.16, 0.42, sun)
	local dusk = math.exp(-((hours - 18) / 1.25) ^ 2)
	local dawn = math.exp(-((hours - 6) / 1.25) ^ 2)
	local warmth = math.clamp(dusk + dawn * 0.65, 0, 1)

	Lighting.ClockTime = hours
	Lighting.GeographicLatitude = self.Latitude
	Lighting.GlobalShadows = true
	-- A bright ambient floor keeps routes and dinosaur silhouettes legible at night.
	Lighting.Brightness = mix(2.15, 2.8, daylight)
	Lighting.Ambient = Color3.fromRGB(105, 130, 150):Lerp(Color3.fromRGB(121, 127, 113), daylight)
	Lighting.OutdoorAmbient = Color3.fromRGB(135, 153, 172):Lerp(Color3.fromRGB(151, 157, 139), daylight)
	Lighting.ColorShift_Top = Color3.fromRGB(8, 14, 26):Lerp(Color3.fromRGB(0, 0, 0), daylight)
		:Lerp(Color3.fromRGB(52, 24, 9), warmth * 0.68)
	Lighting.ColorShift_Bottom = Color3.fromRGB(5, 10, 18):Lerp(Color3.fromRGB(0, 0, 0), daylight)
	Lighting.ExposureCompensation = mix(0.45, 0.03, daylight)
	Lighting.EnvironmentDiffuseScale = 0.72
	Lighting.EnvironmentSpecularScale = mix(0.40, 0.55, daylight)
	Lighting.FogStart = 700
	Lighting.FogEnd = 6000

	self:_ensureAtmosphere()
	local atmosphere = self.Atmosphere
	-- Gentle distance haze; combat spaces remain clear in this outdoor jungle.
	atmosphere.Density = mix(0.18, 0.14, daylight)
	atmosphere.Offset = 0.12
	atmosphere.Color = Color3.fromRGB(152, 177, 204):Lerp(Color3.fromRGB(199, 215, 197), daylight)
		:Lerp(Color3.fromRGB(225, 194, 151), warmth * 0.38)
	atmosphere.Decay = Color3.fromRGB(90, 112, 143):Lerp(Color3.fromRGB(118, 139, 113), daylight)
	atmosphere.Glare = daylight * 0.08
	atmosphere.Haze = mix(1.15, 0.85, daylight)
	-- Lift the darkest shadows instead of turning night into daytime.
	if not self.Readability or self.Readability.Parent ~= Lighting then
		self.Readability=Lighting:FindFirstChild("HunDinoNightReadability")
		if not self.Readability then
			self.Readability=Instance.new("ColorCorrectionEffect")
			self.Readability.Name="HunDinoNightReadability";self.Readability.Parent=Lighting
			self.OwnedReadability=true
		else self.SavedReadability=capture(self.Readability,READABILITY_PROPERTIES) end
	end
	self.Readability.Enabled=true
	self.Readability.Brightness=0.055*(1-daylight)
	self.Readability.Contrast=-0.04*(1-daylight)
	self.Readability.Saturation=-0.04*(1-daylight)
	self.Readability.TintColor=Color3.new(1,1,1)

	self.Root:SetAttribute("GameClockHours", hours)
	self.Root:SetAttribute("HuntElapsedSeconds", elapsed)
	return hours, elapsed
end

function EnvironmentClock:Start(unixSeconds)
	assert(not self.Destroyed, "EnvironmentClock has been destroyed")
	self:Stop()
	local now = finiteNumber(unixSeconds, wallTime())
	self.StartedAt = now
	self.EntryClockHours = ((now + self.TimezoneOffsetMinutes * 60) % 86400) / 3600
	self:Step(now)
	self.Connection = RunService.Heartbeat:Connect(function()
		self:Step()
	end)
	return self
end

function EnvironmentClock:Stop()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
	return self
end

function EnvironmentClock:Destroy(restoreOriginal)
	if self.Destroyed then
		return
	end
	self:Stop()
	if restoreOriginal ~= false then
		restore(Lighting, self.SavedLighting)
		if self.OwnedAtmosphere and self.Atmosphere then
			self.Atmosphere:Destroy()
		elseif self.Atmosphere and self.Atmosphere.Parent == Lighting and self.SavedAtmosphere then
			restore(self.Atmosphere, self.SavedAtmosphere)
		end
		if self.OwnedReadability and self.Readability then self.Readability:Destroy()
		elseif self.Readability and self.Readability.Parent==Lighting and self.SavedReadability then
			restore(self.Readability,self.SavedReadability)
		end
		self.Root:SetAttribute("GameClockHours", self.SavedClockHours)
		self.Root:SetAttribute("HuntElapsedSeconds", self.SavedElapsedSeconds)
	end
	self.Destroyed = true
end

return EnvironmentClock
