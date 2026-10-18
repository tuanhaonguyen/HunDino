-- Server-owned visits to the connected forest. Lighting is applied per client.
local Session = {}
Session.__index = Session

local ATTRIBUTES = {"HuntStartedAt", "HuntStartServerTime", "HuntEntryClockHours", "HuntTimeScale", "HuntDuration", "HuntRemainingSeconds"}

local function wallTime()
	return DateTime.now().UnixTimestampMillis / 1000
end

function Session.new(forest, config, dinosaur, routeController)
	return setmetatable({
		Forest = forest, Config = config, Dinosaur = dinosaur, Routes = routeController,
		Players = {}, Count = 0, Patrol = nil,
		Duration = math.max(30, config.HuntDurationSeconds or 40 * 60),
	}, Session)
end

function Session:Enter(player)
	-- A Studio zone jump keeps the current visit and its original entry clock.
	if self.Players[player] then return end
	if not self.Patrol then
		self.Patrol = self.Routes.new(self.Dinosaur, self.Forest, self.Config)
		self.Patrol:Start()
		if self.Combat then self.Combat:Reset() end
	end
	local started = wallTime()
	self.Players[player] = {StartedAt = started, Duration = self.Duration}
	self.Count += 1
	player:SetAttribute("HuntStartedAt", started)
	player:SetAttribute("HuntStartServerTime", workspace:GetServerTimeNow())
	player:SetAttribute("HuntEntryClockHours", ((started + (self.Config.TimezoneOffsetMinutes or 420) * 60) % 86400) / 3600)
	player:SetAttribute("HuntTimeScale", self.Config.TimeScale or 30)
	player:SetAttribute("HuntDuration", self.Duration)
	player:SetAttribute("HuntRemainingSeconds", self.Duration)
	player:SetAttribute("InHunting", true)
	self.Forest:SetAttribute("ActiveHunters", self.Count)
end

function Session:Exit(player)
	if self.Combat then self.Combat:PlayerExited(player) end
	player:SetAttribute("InHunting", false)
	for _, attribute in ATTRIBUTES do player:SetAttribute(attribute, nil) end
	if self.Players[player] then
		self.Players[player] = nil
		self.Count -= 1
	end
	self.Forest:SetAttribute("ActiveHunters", self.Count)
	if self.Count == 0 and self.Patrol then
		if self.Combat then self.Combat:Reset() end
		self.Patrol:Destroy(true)
		self.Patrol = nil
	end
end

function Session:Expired()
	local now, expired = wallTime(), {}
	for player, visit in self.Players do
		local remaining = math.max(0, math.ceil(visit.Duration - (now - visit.StartedAt)))
		if player:GetAttribute("HuntRemainingSeconds") ~= remaining then player:SetAttribute("HuntRemainingSeconds", remaining) end
		if remaining == 0 then table.insert(expired, player) end
	end
	return expired
end

function Session:IsOutside(position)
	local offset = self.Config.WorldOffset or self.Forest:GetAttribute("WorldOffset") or Vector3.new(0, 0, 6500)
	local localPosition = position - offset
	local limit = (self.Config.MapSize or 1620) / 2 + 105
	return localPosition.Y < (self.Config.TerrainMin or -48) - 20
		or math.abs(localPosition.X) > limit or math.abs(localPosition.Z) > limit
end

function Session:Destroy()
	local players = {}
	for player in self.Players do table.insert(players, player) end
	for _, player in players do self:Exit(player) end
end

return Session
