-- Execute this whole chunk through Studio Server MCP after installing the code.
-- Real service methods, disposable fake players, and isolated UpdateAsync stores.
-- No real player, account DataStore, code claim, map or gameplay state is touched.
local SSS = game:GetService("ServerScriptService")
local Http = game:GetService("HttpService")
local source = assert(SSS:FindFirstChild("AccountData"), "Install AccountData before QA")
local folder = source:Clone()
folder.Name = "__AdminRedeemQA_" .. Http:GenerateGUID(false)
for _, object in folder:GetDescendants() do
 if object:IsA("BaseScript") then object.Enabled = false end
end
folder.Parent = SSS
local services, players = {}, {}
local report = {Groups=0, Checks=0, Passed={}, Backend="IsolatedFakeUpdateAsync", RealPlayerTouched=false}
local ADMIN, CODE, CODE_ID = 11605296816, "HUNDINO-ADMIN-500", "AdminTest20261021"
local MATERIALS = {"Skin", "Tooth", "Scale", "Bone", "Iron"}
local function check(condition, message) report.Checks += 1; assert(condition, message) end
local function clone(value)
 if type(value) ~= "table" then return value end
 local result = {}; for key, item in value do result[key] = clone(item) end; return result
end
local function same(a, b)
 if type(a) ~= type(b) then return false end
 if type(a) ~= "table" then return a == b end
 for key, value in a do if not same(value, b[key]) then return false end end
 for key in b do if a[key] == nil then return false end end
 return true
end
local function fakePlayer(id)
 local player = {UserId=id, Parent=true, Attributes={}, Signals={}}
 function player:GetAttribute(key) return self.Attributes[key] end
 function player:SetAttribute(key, value)
  if self.Attributes[key] == value then return end
  self.Attributes[key] = value
  if self.Signals[key] then self.Signals[key]:Fire() end
 end
 function player:GetAttributeChangedSignal(key)
  if not self.Signals[key] then self.Signals[key] = Instance.new("BindableEvent") end
  return self.Signals[key].Event
 end
 table.insert(players, player)
 return player
end
local function fakeStore()
 local backend = {Records={}, Calls=0, Writes=0, FailBefore=0, FailAfter=0}
 function backend:UpdateAsync(key, transform)
  self.Calls += 1
  if self.FailBefore > 0 then self.FailBefore -= 1; error("QA outage before write") end
  transform(clone(self.Records[key])) -- discarded callback proposal
  local result = transform(clone(self.Records[key]))
  if self.BeforeCommit then self.BeforeCommit(self, key, result) end
  if result ~= nil then self.Records[key] = clone(result); self.Writes += 1 end
  if self.FailAfter > 0 then self.FailAfter -= 1; error("QA response lost after write") end
  return clone(result)
 end
 return backend
end
local function cleanup()
 for _, service in services do
  service.Stopped = true
  for _, entry in service.Entries do
   for _, connection in entry.Connections or {} do connection:Disconnect() end
  end
  table.clear(service.Entries)
  for _, connection in service.Connections do connection:Disconnect() end
  if service.Remote then service.Remote:Destroy() end
 end
 for _, player in players do
  player.Parent = nil
  for _, signal in player.Signals do signal:Destroy() end
 end
 folder:Destroy()
end

local success, result = xpcall(function()
 local runtime = assert(SSS:FindFirstChild("HuntingRuntime"), "Install HuntingRuntime before QA")
 local Economy = require(runtime.HuntEconomyRules)
 local EconomyService = require(runtime.HuntEconomyService)
 local activeEconomy = EconomyService.current()
 local ProfileService = require(folder.ProfileService)
 local Repository = require(folder.ProfileStore)
 local Schema = require(folder.ProfileSchema).new(Economy)
 local now = 1792550000

 local function context(backend, player)
  backend, player = backend or fakeStore(), player or fakePlayer(ADMIN)
  local repository = Repository.new({Store=backend, Token="redeem-qa:" .. Http:GenerateGUID(false),
   Now=function() return now end, Sleep=function() end, Validate=Schema.Validate, Encode=Schema.Encode,
   LeaseSeconds=120, MaxAttempts=4})
  -- The clone has its own module singleton. Its temporary remote is renamed and
  -- destroyed; the live AccountData.ProfileService.Current is never replaced.
  local persistence = ProfileService.new({Repository=repository, Schema=Schema,
   Now=function() return now end, ServerNow=function() return now + .25 end,
   Stopped=true, Mode="IsolatedQAMemory"})
  persistence.Remote.Name = "__AdminRedeemQAProfileAction_" .. #services
  table.insert(services, persistence)
  local adapter = setmetatable({Persistence=persistence, LastCodeRequest={}, Events={}, Publications={}}, EconomyService)
  adapter.Remote = {}
  function adapter.Remote:FireClient(target, kind, payload)
   table.insert(adapter.Events, {Player=target, Kind=kind, Payload=clone(payload)})
   if kind == "CodeResult" and payload.Ok then
    local durable = backend.Records["player_" .. target.UserId]
    check(durable ~= nil and durable.Data.Economy.RedeemedCodes[CODE_ID] ~= nil,
     "A successful reply must follow a durable saved claim")
    check(durable.Data.Economy.Coins == 580, "Successful reply follows all saved coins")
    for _, material in MATERIALS do
     check(durable.Data.Economy.Materials[material] == 10, "Successful reply follows saved material " .. material)
    end
   end
  end
  function adapter:Publish(target, notice)
   table.insert(self.Publications, {Player=target, Notice=notice, Economy=clone(self:Profile(target))})
  end
  return {Persistence=persistence, Backend=backend, Player=player, Adapter=adapter, Repository=repository}
 end
 local function load(c)
  check(c.Persistence:Load(c.Player), "Fake account must load")
  return c.Persistence:Data(c.Player).Economy
 end
 local function last(c)
  for index = #c.Adapter.Events, 1, -1 do
   local event = c.Adapter.Events[index]
   if event.Kind == "CodeResult" then return event.Payload end
  end
  error("Expected CodeResult")
 end
 local function submit(c, code, retainRateLimit)
  if not retainRateLimit then c.Adapter.LastCodeRequest[c.Player] = nil end
  c.Adapter:Request(c.Player, "RedeemCode", code)
  return last(c)
 end
 local function noSuccess(c)
  for _, event in c.Adapter.Events do
   check(event.Kind ~= "CodeResult" or not event.Payload.Ok, "No early successful reply")
  end
 end
 local function balances(economy, coins, quantity)
  check(economy.Coins == coins, "Exact coin balance")
  for _, material in MATERIALS do check(economy.Materials[material] == quantity, "Exact balance: " .. material) end
 end
 local function test(name, body)
  body(); report.Groups += 1; table.insert(report.Passed, name)
 end

 test("Server rejects other accounts and malformed client payloads", function()
  local wrong = context(nil, fakePlayer(ADMIN + 1))
  load(wrong)
  local writes = wrong.Backend.Writes
  local response = submit(wrong, CODE)
  check(not response.Ok and response.Code == "NotEligible", "Only configured admin is eligible")
  check(wrong.Backend.Writes == writes and #wrong.Adapter.Publications == 0, "Denied identity makes no reward write or publication")
  local c = context(); local profile = load(c); writes = c.Backend.Writes
  response = submit(c, {Code=CODE, Coins=999999, Materials={Iron=999999}})
  check(not response.Ok and response.Code == "InvalidCode", "Client cannot supply reward fields")
  response = submit(c, string.rep("x", 4096))
  check(not response.Ok and response.Code == "InvalidCode", "Oversized code rejected")
  response = submit(c, "WRONG")
  check(not response.Ok and response.Code == "InvalidCode", "Wrong code rejected")
  check(c.Backend.Writes == writes and next(profile.RedeemedCodes) == nil, "Invalid payloads make no write or claim")
  balances(profile, 80, 0); noSuccess(c)
 end)

 test("Missing durable profile and rate limiting block reward requests", function()
  local c = context()
  local response = submit(c, CODE)
  check(not response.Ok and response.Code == "SavePending", "Unloaded account cannot redeem")
  check(c.Backend.Calls == 0, "Redeeming before load cannot open or default an account")
  response = submit(c, CODE, true)
  check(not response.Ok and response.Code == "RateLimited", "Second immediate attempt is limited")
  c.Adapter.Persistence = nil
  response = submit(c, CODE)
  check(not response.Ok and response.Code == "SavePending", "Memory-only fallback cannot grant one-time account reward")
  noSuccess(c)
 end)

 test("Reward reply follows durable commit; duplicate and rejoin cannot grant again", function()
  local c = context(); local profile = load(c)
  local canonical = profile
  c.Backend.BeforeCommit = function(_, _, proposal)
   balances(canonical, 80, 0); noSuccess(c)
   check(proposal.Data.Economy.Coins == 580, "Pending proposal contains requested coins")
   check(proposal.Data.Economy.RedeemedCodes[CODE_ID] ~= nil, "Pending proposal atomically contains claim")
  end
  local response = submit(c, CODE)
  c.Backend.BeforeCommit = nil
  check(response.Ok and response.Code == "CodeRedeemed", "Grant acknowledged after confirmed write")
  check(c.Persistence:Data(c.Player).Economy == canonical, "Canonical table identity preserved")
  balances(canonical, 580, 10)
  check(#c.Adapter.Publications == 1, "Success publishes updated inventory")
  local revision, writes = canonical.Revision, c.Backend.Writes
  response = submit(c, CODE)
  check(not response.Ok and response.Code == "AlreadyRedeemed", "Repeated code rejected")
  check(canonical.Revision == revision and c.Backend.Writes == writes, "Duplicate changes no revision or saved data")
  c.Persistence:Release(c.Player)
  check(c.Persistence.Entries[c.Player] == nil, "First fake session releases")
  local nextContext = context(c.Backend, fakePlayer(ADMIN))
  local restored = load(nextContext)
  balances(restored, 580, 10)
  response = submit(nextContext, CODE)
  check(not response.Ok and response.Code == "AlreadyRedeemed", "Fresh session retains one-time claim")
  balances(restored, 580, 10)
 end)

 test("Before-write outage never reports success; saved retry installs one reward", function()
  local c = context(); local profile = load(c)
  c.Backend.FailBefore = 4
  local response = submit(c, CODE)
  check(not response.Ok and response.Code == "SavePending", "Outage remains pending")
  balances(profile, 80, 0)
  balances(c.Backend.Records["player_" .. ADMIN].Data.Economy, 80, 0)
  check(c.Persistence.Entries[c.Player].Pending ~= nil and not c.Persistence:CanMutate(c.Player), "Pending candidate blocks additional economy changes")
  response = submit(c, CODE)
  check(not response.Ok and response.Code == "SavePending", "Repeat while pending cannot create a second candidate")
  noSuccess(c)
  check(c.Persistence:Save(c.Player), "Explicit retry durably installs the retained candidate")
  balances(profile, 580, 10)
  response = submit(c, CODE)
  check(not response.Ok and response.Code == "AlreadyRedeemed", "Post-retry request observes existing durable claim")
  balances(c.Backend.Records["player_" .. ADMIN].Data.Economy, 580, 10)
 end)

 test("Lost write response preserves uncertainty and resolves exactly one committed grant", function()
  local c = context(); local profile = load(c)
  c.Backend.FailAfter = 4
  local response = submit(c, CODE)
  check(not response.Ok and response.Code == "SavePending", "Lost acknowledgment is not reported successful")
  balances(profile, 80, 0)
  local durable = c.Backend.Records["player_" .. ADMIN]
  balances(durable.Data.Economy, 580, 10)
  check(durable.Revision == 1, "Retries with one commit receipt do not grant repeatedly")
  noSuccess(c)
  check(not c.Persistence:CanMutate(c.Player), "Uncertain candidate gates new writes")
  check(c.Persistence:Save(c.Player), "Retry confirms saved receipt")
  balances(profile, 580, 10)
  response = submit(c, CODE)
  check(not response.Ok and response.Code == "AlreadyRedeemed", "Confirmed claim cannot be repeated")
  balances(c.Backend.Records["player_" .. ADMIN].Data.Economy, 580, 10)
 end)

 test("Concurrent redemption is gated while the first commit is in flight", function()
  local c = context(); local profile = load(c)
  c.Backend.BeforeCommit = function()
   c.Backend.BeforeCommit = nil
   check(not c.Persistence:CanMutate(c.Player), "Saving gates concurrent economic requests")
   local response = submit(c, CODE)
   check(not response.Ok and response.Code == "SavePending", "Concurrent request cannot enter another transaction")
   balances(profile, 80, 0); noSuccess(c)
  end
  local response = submit(c, CODE)
  check(response.Ok and response.Code == "CodeRedeemed", "Original request completes after gated concurrent request")
  balances(profile, 580, 10)
  check(c.Backend.Records["player_" .. ADMIN].Revision == 1, "Only one durable reward commit")
  local count = 0
  for _, event in c.Adapter.Events do if event.Kind == "CodeResult" and event.Payload.Ok then count += 1 end end
  check(count == 1, "Only one successful response")
 end)

 check(EconomyService.current() == activeEconomy, "QA did not replace live economy singleton")
 return report
end, debug.traceback)
cleanup()
if not success then error(result) end
return Http:JSONEncode(result)
