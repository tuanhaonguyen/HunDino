-- Server-only durable profile repository. The UpdateAsync callback must not yield.
-- Token must be unique to this server/session; Now uses Unix seconds. Inject Store,
-- Sleep and Now in tests. Validate migrates/sanitizes memory data; Encode converts it
-- to DataStore-safe tables. No load error ever becomes a new/default profile.
local Store = {}
Store.__index = Store

local MAX_INTEGER = 9007199254740991
local RECEIPT_LIMIT = 32
local function integer(n)
	return type(n) == "number" and n == n and n >= 0 and n <= MAX_INTEGER and n % 1 == 0
end

local function copy(value, seen, depth)
	local kind = type(value)
	if kind == "nil" or kind == "string" or kind == "boolean" then return value end
	if kind == "number" then
		assert(value == value and value > -math.huge and value < math.huge, "Non-finite data")
		return value
	end
	assert(kind == "table" and (depth or 0) < 48, "Unsupported profile data/depth")
	seen = seen or {}
	assert(not seen[value], "Cyclic profile data")
	seen[value] = true
	local result = {}
	for key, item in value do
		assert(type(key) == "string" or (integer(key) and key > 0), "Invalid profile key")
		result[key] = copy(item, seen, (depth or 0) + 1)
	end
	seen[value] = nil
	return result
end

local function serializable(value)
	if type(value) ~= "table" then return end
	local strings, numbers, count, maximum = false, false, 0, 0
	for key, item in value do
		if type(key) == "string" then strings = true else numbers = true; maximum = math.max(maximum, key) end
		count += 1
		serializable(item)
	end
	assert(not (strings and numbers) and (not numbers or count == maximum), "Encode must return dictionaries or dense arrays")
end

local function equal(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for key, item in a do if not equal(item, b[key]) then return false end end
	for key in b do if a[key] == nil then return false end end
	return true
end

function Store.new(options)
	assert(type(options) == "table" and options.Store ~= nil, "Store required")
	assert(type(options.Token) == "string" and #options.Token > 0 and #options.Token <= 160, "Unique session Token required")
	local self = setmetatable({}, Store)
	self._store, self._token = options.Store, options.Token
	self._now = options.Now or os.time
	self._sleep = options.Sleep or function(seconds) task.wait(seconds) end
	self._validate, self._encode = options.Validate, options.Encode
	self._lease = options.LeaseSeconds or 120
	self._attempts = options.MaxAttempts or 4
	self._baseDelay, self._maxDelay = options.BaseDelay or 0.5, options.MaxDelay or 4
	assert(type(self._lease) == "number" and self._lease >= 10 and self._lease <= 3600, "LeaseSeconds must be 10..3600")
	assert(integer(self._attempts) and self._attempts >= 1 and self._attempts <= 8, "MaxAttempts must be 1..8")
	assert(type(self._baseDelay) == "number" and self._baseDelay >= 0 and self._baseDelay <= 10
		and type(self._maxDelay) == "number" and self._maxDelay >= self._baseDelay and self._maxDelay <= 30, "Invalid retry delays")
	self._states, self._serial = {}, 0
	return self
end

function Store:_data(data)
	local ok, result, code = pcall(function()
		local candidate = copy(data)
		if type(candidate) ~= "table" then return nil, "InvalidData" end
		if self._validate then
			local normalized, reason = self._validate(candidate)
			if type(normalized) ~= "table" then return nil, reason or "InvalidData" end
			candidate = copy(normalized)
		end
		return candidate
	end)
	if not ok then return nil, "InvalidData" end
	return result, code
end

function Store:_encoded(data)
	local ok, encoded = pcall(function()
		local result = copy(if self._encode then self._encode(copy(data)) else data)
		assert(type(result) == "table", "Encode returned no data")
		serializable(result)
		return result
	end)
	return if ok then encoded else nil
end

function Store:_envelope(raw)
	if type(raw) ~= "table" then return nil, "InvalidEnvelope" end
	if integer(raw.FormatVersion) and raw.FormatVersion > 1 then return nil, "FutureFormat" end
	if raw.FormatVersion ~= 1 or not integer(raw.Revision) then return nil, "InvalidEnvelope" end
	if raw.Session ~= nil and (type(raw.Session) ~= "table" or type(raw.Session.Token) ~= "string"
		or #raw.Session.Token == 0 or not integer(raw.Session.ExpiresAt)) then return nil, "InvalidEnvelope" end
	local function validReceipt(mark)
		return type(mark) == "table" and type(mark.Id) == "string" and #mark.Id > 0
			and type(mark.Token) == "string" and #mark.Token > 0 and integer(mark.Revision)
			and mark.Revision <= raw.Revision and type(mark.Released) == "boolean"
	end
	if raw.LastCommit ~= nil and not validReceipt(raw.LastCommit) then return nil, "InvalidEnvelope" end
	if raw.RecentCommits ~= nil then
		if type(raw.RecentCommits) ~= "table" or #raw.RecentCommits > RECEIPT_LIMIT then return nil, "InvalidEnvelope" end
		local count = 0
		for key, mark in raw.RecentCommits do
			count += 1
			if not integer(key) or key < 1 or key > #raw.RecentCommits or not validReceipt(mark) then return nil, "InvalidEnvelope" end
		end
		if count ~= #raw.RecentCommits then return nil, "InvalidEnvelope" end
	end
	local data, reason = self:_data(raw.Data)
	if not data then return nil, reason end
	local ok, envelope = pcall(copy, raw)
	if not ok then return nil, "InvalidEnvelope" end
	return envelope, nil, data
end

function Store:_begin(key)
	assert(type(key) == "string" and #key > 0, "Profile key required")
	local state = self._states[key]
	if not state then state = {}; self._states[key] = state end
	if state.Busy then return nil, "Busy" end
	state.Busy = true
	return state
end

function Store:_retry(callback, failureCode)
	for attempt = 1, self._attempts do
		local ok, value, reason = pcall(callback)
		if ok then return value, reason end
		if attempt < self._attempts then
			self._sleep(math.min(self._maxDelay, self._baseDelay * 2 ^ (attempt - 1)))
		end
	end
	return nil, failureCode
end

local function receipt(envelope, id)
	if type(envelope.LastCommit) == "table" and envelope.LastCommit.Id == id then return envelope.LastCommit end
	if type(envelope.RecentCommits) == "table" then
		for _, item in envelope.RecentCommits do
			if type(item) == "table" and item.Id == id then return item end
		end
	end
	return nil
end

-- Explicit acquisition is the only operation allowed to take an expired lease.
function Store:Load(key, defaultData)
	local state, reason = self:_begin(key)
	if not state then return false, reason end
	if state.Loaded then state.Busy = nil; return true, "Loaded", copy(state.Data) end
	local default, invalid = self:_data(defaultData)
	local encoded = if default then self:_encoded(default) else nil
	if not encoded then state.Busy = nil; return false, invalid or "InvalidData" end
	local created = false
	local result, failure = self:_retry(function()
		local rejected
		local value = self._store:UpdateAsync(key, function(raw)
			local now = self._now()
			local envelope, why
			if raw == nil then
				created = true
				envelope = {FormatVersion = 1, Data = copy(encoded), Revision = 0}
			else envelope, why = self:_envelope(raw) end
			if not envelope then rejected = why; return nil end
			if envelope.Session and envelope.Session.Token ~= self._token and envelope.Session.ExpiresAt > now then
				rejected = "Locked"; return nil
			end
			-- Keep commit receipts when acquiring: a previous owner's lost release response
			-- can still be acknowledged without modifying this new owner's session.
			envelope.Session = {Token = self._token, ExpiresAt = now + self._lease}
			return envelope
		end)
		return value, rejected
	end, "LoadFailed")
	if result == nil then state.Busy = nil; return false, failure or "LoadFailed" end
	local envelope, why, normalized = self:_envelope(result)
	if not envelope or not envelope.Session or envelope.Session.Token ~= self._token then
		state.Busy = nil; return false, why or "SessionLost"
	end
	state.Loaded, state.Data, state.Revision = true, normalized, envelope.Revision
	state.Pending, state.Released, state.Busy = nil, nil, nil
	return true, if created then "Created" else "Loaded", copy(normalized)
end

function Store:_commit(key, state, pending)
	local result, failure = self:_retry(function()
		local rejected
		local value = self._store:UpdateAsync(key, function(raw)
			local envelope, why = self:_envelope(raw)
			if not envelope then rejected = why; return nil end
			if receipt(envelope, pending.Id) then return envelope end
			local now, session = self._now(), envelope.Session
			if not session or session.Token ~= self._token or session.ExpiresAt <= now then rejected = "SessionLost"; return nil end
			if envelope.Revision ~= pending.Revision then rejected = "RevisionConflict"; return nil end
			if pending.Revision >= MAX_INTEGER then rejected = "RevisionLimit"; return nil end
			envelope.Data, envelope.Revision = copy(pending.Encoded), pending.Revision + 1
			envelope.Session = if pending.Release then nil else {Token = self._token, ExpiresAt = now + self._lease}
			local mark = {Id = pending.Id, Token = self._token, Revision = envelope.Revision, Released = pending.Release}
			local history = if type(envelope.RecentCommits) == "table" then envelope.RecentCommits else {}
			table.insert(history, copy(mark))
			while #history > RECEIPT_LIMIT do table.remove(history, 1) end
			envelope.LastCommit, envelope.RecentCommits = mark, history
			return envelope
		end)
		return value, rejected
	end, "SaveFailed")
	if result == nil then
		if failure ~= "SaveFailed" then state.Loaded, state.Pending = false, nil end
		return false, failure or "SaveFailed"
	end
	local envelope, why = self:_envelope(result)
	local committed = if envelope then receipt(envelope, pending.Id) else nil
	if not committed then state.Loaded, state.Pending = false, nil; return false, why or "RevisionConflict" end
	state.Data, state.Revision, state.Pending = copy(pending.Data), committed.Revision, nil
	if pending.Release then state.Loaded, state.Released = false, true; return true, "Released", copy(state.Data) end
	if not envelope.Session or envelope.Session.Token ~= self._token or envelope.Session.ExpiresAt <= self._now() then
		state.Loaded = false; return false, "SessionLost"
	end
	return true, "Saved", copy(state.Data)
end

function Store:Save(key, data, release)
	local state, reason = self:_begin(key)
	if not state then return false, reason end
	-- Release is itself idempotent, even after the lock has been removed.
	if state.Released then state.Busy = nil; return true, "Released", copy(state.Data) end
	if not state.Loaded then state.Busy = nil; return false, "NotLoaded" end
	local normalized, invalid = self:_data(data)
	local encoded = if normalized then self:_encoded(normalized) else nil
	if not encoded then state.Busy = nil; return false, invalid or "InvalidData" end
	if state.Pending then
		local previous = state.Pending
		local ok, status, committed = self:_commit(key, state, previous)
		if not ok or previous.Release or (not release and equal(normalized, previous.Data)) then
			state.Busy = nil; return ok, status, committed
		end
	end
	self._serial += 1
	local pending = {Id = self._token .. ":" .. self._serial, Revision = state.Revision,
		Data = copy(normalized), Encoded = encoded, Release = release == true}
	state.Pending = pending
	local ok, status, committed = self:_commit(key, state, pending)
	state.Busy = nil
	return ok, status, committed
end

-- Renew at an interval comfortably below LeaseSeconds (for example every 30s).
-- A pending save is resolved by Save, so it cannot be silently replaced by Renew.
function Store:Renew(key)
	local state, reason = self:_begin(key)
	if not state then return false, reason end
	if not state.Loaded then state.Busy = nil; return false, "NotLoaded" end
	if state.Pending then state.Busy = nil; return false, "PendingSave" end
	local result, failure = self:_retry(function()
		local rejected
		local value = self._store:UpdateAsync(key, function(raw)
			local envelope, why = self:_envelope(raw)
			if not envelope then rejected = why; return nil end
			local now, session = self._now(), envelope.Session
			if not session or session.Token ~= self._token or session.ExpiresAt <= now then rejected = "SessionLost"; return nil end
			if envelope.Revision ~= state.Revision then rejected = "RevisionConflict"; return nil end
			envelope.Session.ExpiresAt = now + self._lease
			return envelope
		end)
		return value, rejected
	end, "RenewFailed")
	state.Busy = nil
	if result == nil then
		if failure ~= "RenewFailed" then state.Loaded = false end
		return false, failure or "RenewFailed"
	end
	return true, "Renewed", copy(state.Data)
end

return Store
