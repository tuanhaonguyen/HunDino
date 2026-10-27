-- Pure code-reward, migration and durable repository tests. Every account and
-- backend here is disposable memory; this never redeems a real account's code.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local serde = require("@lune/serde")
local saveGame = table.find(require("@lune/process").args,"--savegame") ~= nil
local Economy = if saveGame then require("../assets/data/ServerScriptService__HuntingRuntime__HuntEconomyRules") else require("../src/hunting/HuntEconomyRules")
local Policy = require("../src/hunting/AdminRedeemPolicy")
local SchemaModule = if saveGame then require("../backups/savegame-before-redeem-20261022/ProfileSchema.original") else require("../src/data/ProfileSchema")
local Schema = SchemaModule.new(Economy)
local ProfileStore = require("../src/data/ProfileStore")
local ADMIN, CODE, CODE_ID = 11605296816, "HUNDINO-ADMIN-500", "AdminTest20261021"
local NOW = 1792550000
local MATERIALS = {"Skin", "Tooth", "Scale", "Bone", "Iron"}
local checks, groups = 0, 0
local function check(condition, message) checks += 1; assert(condition, message) end
local function same(a, b)
 if type(a) ~= type(b) then return false end
 if type(a) ~= "table" then return a == b end
 for key, value in a do if not same(value, b[key]) then return false end end
 for key in b do if a[key] == nil then return false end end
 return true
end
local function clone(value)
 if type(value) ~= "table" then return value end
 local result = {}; for key, child in value do result[key] = clone(child) end; return result
end
local function json(value)
 return if value == nil then nil else serde.decode("json", serde.encode("json", value))
end
local function test(name, body) body(); groups += 1; print("PASS", name) end
local function grant()
 local request = assert(Policy.Resolve(ADMIN, CODE))
 request.RedeemedAt = NOW
 return request
end
local function rejectUnchanged(profile, request, expected)
 local before = clone(profile)
 local result = Economy.apply(profile, request)
 check(not result.Ok, "Invalid/repeated redemption must reject")
 if expected then check(result.Code == expected, "Expected " .. expected .. ", got " .. tostring(result.Code)) end
 check(same(profile, before), "Rejected redemption must leave all profile fields unchanged")
end
local function packageAt(profile, coins, quantity)
 check(profile.Coins == coins, "Exact coin total")
 for _, key in MATERIALS do check(profile.Materials[key] == quantity, "Exact material total: " .. key) end
end

local function fake()
 local ds = {Values = {}, Calls = 0, Writes = 0, FailBefore = 0, FailAfter = 0}
 function ds:UpdateAsync(key, transform)
  self.Calls += 1
  if self.FailBefore > 0 then self.FailBefore -= 1; error("Injected outage before write") end
  -- Discarded callback results must not grant the package multiple times.
  transform(json(self.Values[key]))
  local result = transform(json(self.Values[key]))
  if self.BeforeCommit then self.BeforeCommit(result) end
  if result ~= nil then self.Values[key] = json(result); self.Writes += 1 end
  if self.FailAfter > 0 then self.FailAfter -= 1; error("Injected response lost after write") end
  return json(result)
 end
 return ds
end
local function repository(ds, token)
 return ProfileStore.new({Store = ds, Token = token, Now = function() return NOW end,
  Sleep = function() end, MaxAttempts = 3, LeaseSeconds = 120,
  Validate = Schema.Validate, Encode = Schema.Encode})
end
local function load(repo)
 local ok, reason, data = repo:Load("redeem-test-account", Schema.Default(NOW))
 check(ok, "Load must succeed: " .. tostring(reason))
 return data
end
local function save(repo, data, release)
 local ok, reason, stored = repo:Save("redeem-test-account", data, release)
 check(ok, "Save must succeed: " .. tostring(reason))
 check(same(data, stored), "Acknowledged snapshot matches whole account")
 return stored
end

test("Policy accepts only the designated admin and owns the reward payload", function()
 local a = assert(Policy.Resolve(ADMIN, CODE))
 check(a.Op == "RedeemCode" and a.CodeId == CODE_ID and a.Coins == 500, "Server policy chooses grant and fixed claim ID")
 for _, key in MATERIALS do check(a.Materials[key] == 10, "Server policy chooses each material") end
 a.Coins, a.Materials.Skin = 999999, 999999
 local b = assert(Policy.Resolve(ADMIN, CODE))
 check(b.Coins == 500 and b.Materials.Skin == 10, "Returned requests cannot mutate policy configuration")
 check(Policy.Resolve(ADMIN, "  hundino-admin-500  ") ~= nil, "Surrounding spaces and lowercase input normalize")
 for _, userId in {0, -1, ADMIN + 1, tostring(ADMIN), false, {}, 0/0, math.huge} do
  local request, reason = Policy.Resolve(userId, CODE)
  check(request == nil and type(reason) == "string", "Other and malformed identities reject")
 end
 for _, raw in {"", "WRONG", string.rep("x", 4096), false, {}, 123, "HUNDINO-ADMIN-500\nINJECT"} do
  local request, reason = Policy.Resolve(ADMIN, raw)
  check(request == nil and type(reason) == "string", "Wrong/malformed code rejects without a grant")
 end
 check(Policy.Resolve(ADMIN, nil) == nil, "Missing code rejects")
end)

test("One accepted grant adds exact rewards and a cloned permanent claim", function()
 local profile, request = Economy.new(), grant()
 local receipt = Economy.apply(profile, request)
 check(receipt.Ok and receipt.Code == "CodeRedeemed" and receipt.Replay == false, "Accepted receipt")
 packageAt(profile, 580, 10)
 check(profile.Revision == 1 and profile.OperationSerial == 0, "One economy revision without an ordinary operation")
 check(#profile.OperationOrder == 0 and next(profile.OperationReceipts) == nil, "Claim is outside bounded recent-operation ledger")
 check(same(profile.RedeemedCodes[CODE_ID], receipt), "Permanent claim stores complete accepted receipt")
 check(receipt.CodeId == CODE_ID and receipt.RedeemedAt == NOW and receipt.Coins == 500, "Receipt records stable ID, timestamp and coins")
 request.Materials.Skin = 200
 receipt.Materials.Skin = 300
 check(profile.Materials.Skin == 10 and profile.RedeemedCodes[CODE_ID].Materials.Skin == 10, "Input/returned receipt cannot mutate canonical reward or claim")
 rejectUnchanged(profile, grant(), "AlreadyRedeemed")
 local changedTextGrant = grant(); changedTextGrant.Coins = 700
 rejectUnchanged(profile, changedTextGrant, "AlreadyRedeemed")
end)

test("Old v1/v2 accounts gain only a missing empty claim ledger", function()
 for _, version in {1, 2} do
  local profile = Economy.new()
  profile.Coins, profile.Materials.Iron = 27, 8
  profile.RedeemedCodes = nil
  if version == 1 then
   profile.DataVersion, profile.OwnedSpecimens, profile.SpecimenSerial = 1, nil, nil
  end
  local original = clone(profile)
  local migrated = assert(Economy.new(profile))
  check(type(migrated.RedeemedCodes) == "table" and next(migrated.RedeemedCodes) == nil, "Missing ledger migrates empty")
  check(migrated.Coins == 27 and migrated.Materials.Iron == 8, "Migration preserves money and materials")
  check(same(profile, original), "Migration never mutates source")
  local wrapped = Schema.Default(NOW); wrapped.Economy = profile
  check(Schema.Validate(wrapped) ~= nil, "Account wrapper supports migration")
  check(Economy.apply(migrated, grant()).Ok, "Legacy account can redeem once after migration")
  rejectUnchanged(migrated, grant(), "AlreadyRedeemed")
 end
end)

test("Malformed grant payloads never add partial money or mark a claim", function()
 local corruptions = {
  function(x) x.CodeId = "" end,
  function(x) x.CodeId = false end,
  function(x) x.CodeId = "bad\ncode" end,
  function(x) x.RedeemedAt = nil end,
  function(x) x.RedeemedAt = -1 end,
  function(x) x.RedeemedAt = 1.5 end,
  function(x) x.RedeemedAt = math.huge end,
  function(x) x.RedeemedAt = 253402300800 end,
  function(x) x.Coins = 0 end,
  function(x) x.Coins = -1 end,
  function(x) x.Coins = 1.5 end,
  function(x) x.Coins = 0/0 end,
  function(x) x.Coins = math.huge end,
  function(x) x.Coins = Economy.Config.MaximumCount + 1 end,
  function(x) x.Materials = nil end,
  function(x) x.Materials = false end,
  function(x) x.Materials.Skin = nil end,
  function(x) x.Materials.Skin = 0 end,
  function(x) x.Materials.Tooth = -1 end,
  function(x) x.Materials.Scale = 0.5 end,
  function(x) x.Materials.Bone = 0/0 end,
  function(x) x.Materials.Iron = math.huge end,
  function(x) x.Materials.Iron = Economy.Config.MaximumCount + 1 end,
  function(x) x.Materials.Unknown = 10 end,
 }
 for _, corrupt in corruptions do
  local request = grant(); corrupt(request)
  rejectUnchanged(Economy.new(), request)
 end
end)

test("Capacity limits are atomic across all six balances and permanent claims", function()
 local profile = Economy.new(); profile.Coins = Economy.Config.MaximumCount - 499
 rejectUnchanged(profile, grant())
 check(profile.RedeemedCodes[CODE_ID] == nil, "Coin overflow cannot consume claim")
 for _, key in MATERIALS do
  profile = Economy.new(); profile.Materials[key] = Economy.Config.MaximumCount - 9
  rejectUnchanged(profile, grant())
  check(profile.RedeemedCodes[CODE_ID] == nil, "Material overflow cannot consume claim: " .. key)
 end
 profile = Economy.new(); profile.Coins = Economy.Config.MaximumCount - 500
 for _, key in MATERIALS do profile.Materials[key] = Economy.Config.MaximumCount - 10 end
 check(Economy.apply(profile, grant()).Ok, "Exact maximum still accepts whole package")
 packageAt(profile, Economy.Config.MaximumCount, Economy.Config.MaximumCount)
 profile = Economy.new(); profile.Revision = Economy.Config.MaximumCount
 rejectUnchanged(profile, grant())
end)

test("Malformed saved claim ledgers fail closed rather than reopening redemption", function()
 local account = Schema.Default(NOW)
 check(Economy.apply(account.Economy, grant()).Ok, "Seed one saved claim")
 local corruptions = {
  function(x) x.Economy.RedeemedCodes = false end,
  function(x) x.Economy.RedeemedCodes = "used" end,
  function(x) x.Economy.RedeemedCodes[1] = x.Economy.RedeemedCodes[CODE_ID] end,
  function(x) x.Economy.RedeemedCodes[CODE_ID] = true end,
  function(x) x.Economy.RedeemedCodes[CODE_ID].CodeId = "different-id" end,
  function(x) x.Economy.RedeemedCodes[CODE_ID].Code = "Purchased" end,
  function(x) x.Economy.RedeemedCodes[CODE_ID].Ok = false end,
  function(x) x.Economy.RedeemedCodes[CODE_ID].Replay = true end,
  function(x) x.Economy.RedeemedCodes[CODE_ID].RedeemedAt = -1 end,
  function(x) x.Economy.RedeemedCodes[CODE_ID].Materials.Iron = nil end,
  function(x) x.Economy.RedeemedCodes[CODE_ID].Materials.Skin = 0 end,
  function(x) x.Economy.RedeemedCodes[CODE_ID].Coins = -500 end,
 }
 for _, corrupt in corruptions do
  local bad = clone(account); corrupt(bad)
  check(Economy.new(bad.Economy) == nil, "Malformed existing ledger cannot become fresh")
  check(Schema.Validate(bad) == nil and Schema.Encode(bad) == nil, "Malformed account cannot load or save")
  bad.Economy.DataVersion, bad.Economy.OwnedSpecimens, bad.Economy.SpecimenSerial = 1, nil, nil
  check(Economy.new(bad.Economy) == nil and Schema.Validate(bad) == nil, "Legacy v1 migration also preserves the malformed-ledger rejection")
 end
 local historical = clone(account)
 historical.Economy.RedeemedCodes.RetiredAdminReward = clone(historical.Economy.RedeemedCodes[CODE_ID])
 historical.Economy.RedeemedCodes.RetiredAdminReward.CodeId = "RetiredAdminReward"
 check(Schema.Validate(historical) ~= nil, "Historical claim IDs need not remain active in code configuration")
end)

test("Claim survives JSON, operation receipt eviction, release and a fresh session", function()
 local ds = fake(); local first = repository(ds, "redeem-session-a")
 local profile = load(first)
 profile.Economy.Coins = 10000 -- Controlled fixture to afford 70 ordinary purchases.
 check(Economy.apply(profile.Economy, grant()).Ok, "Grant candidate")
 for _ = 1, 70 do
  local economy = profile.Economy
  check(Economy.apply(economy, {Op="Buy", Item="SleepPotion", OperationSerial=economy.OperationSerial+1}).Ok, "Ordinary operation")
 end
 check(#profile.Economy.OperationOrder == 64 and profile.Economy.OperationReceipts[1] == nil, "Recent ledger actually evicted entries")
 save(first, profile, true)
 check(ds.Values["redeem-test-account"].Session == nil, "Lease released")
 local second = repository(ds, "redeem-session-b")
 local restored = load(second)
 check(same(restored, profile), "Whole profile survives actual JSON and fresh repository")
 check(restored.Economy.RedeemedCodes[CODE_ID] ~= nil, "Permanent claim retained past eviction")
 rejectUnchanged(restored.Economy, grant(), "AlreadyRedeemed")
 check(restored.Economy.Coins == 9800, "Exactly one package and 70 purchases")
 for _, key in MATERIALS do check(restored.Economy.Materials[key] == 10, "Materials persisted exactly once") end
end)

test("Before-write outages keep the candidate pending and save once on retry", function()
 local ds = fake(); local repo = repository(ds, "redeem-outage")
 local canonical = load(repo); local candidate = clone(canonical)
 check(Economy.apply(candidate.Economy, grant()).Ok, "Prepare isolated candidate")
 ds.FailBefore = 3
 local ok, reason = repo:Save("redeem-test-account", candidate)
 check(not ok and reason == "SaveFailed", "Unconfirmed grant cannot be acknowledged")
 packageAt(canonical.Economy, 80, 0)
 packageAt(ds.Values["redeem-test-account"].Data.Economy, 80, 0)
 check(repo._states["redeem-test-account"].Pending ~= nil, "Failed candidate retained for retry")
 local stored = save(repo, candidate)
 packageAt(stored.Economy, 580, 10)
 check(ds.Values["redeem-test-account"].Revision == 1, "One durable reward commit")
 rejectUnchanged(stored.Economy, grant(), "AlreadyRedeemed")
end)

test("An in-flight save rejects a concurrent account save", function()
 local ds = fake(); local repo = repository(ds, "redeem-concurrent")
 local canonical = load(repo); local candidate = clone(canonical)
 check(Economy.apply(candidate.Economy, grant()).Ok, "Prepare candidate")
 ds.BeforeCommit = function()
  ds.BeforeCommit = nil
  local ok, reason = repo:Save("redeem-test-account", candidate)
  check(not ok and reason == "Busy", "Concurrent save cannot enter the in-flight transaction")
  packageAt(canonical.Economy, 80, 0)
 end
 local stored = save(repo, candidate)
 packageAt(stored.Economy, 580, 10)
 check(ds.Values["redeem-test-account"].Revision == 1, "Concurrency still yields one reward commit")
end)

test("Lost write responses resolve one receipt and never duplicate a committed reward", function()
 local ds = fake(); local repo = repository(ds, "redeem-lost-response")
 local canonical = load(repo); local candidate = clone(canonical)
 check(Economy.apply(candidate.Economy, grant()).Ok, "Prepare candidate")
 ds.FailAfter = 3
 local ok, reason = repo:Save("redeem-test-account", candidate)
 check(not ok and reason == "SaveFailed", "Unknown outcome reported pending")
 packageAt(canonical.Economy, 80, 0)
 packageAt(ds.Values["redeem-test-account"].Data.Economy, 580, 10)
 check(ds.Values["redeem-test-account"].Revision == 1, "Repeated backend callbacks/retries produced only one commit")
 local stored = save(repo, candidate)
 check(ds.Values["redeem-test-account"].Revision == 1, "Resolving pending candidate does not make another grant commit")
 packageAt(stored.Economy, 580, 10)
 save(repo, stored, true)
 local fresh = load(repository(ds, "redeem-lost-response-next"))
 rejectUnchanged(fresh.Economy, grant(), "AlreadyRedeemed")
 packageAt(fresh.Economy, 580, 10)
end)

test("Rules, policy and runtime services compile", function()
 for _, path in {"src/hunting/HuntEconomyRules.luau", "src/hunting/AdminRedeemPolicy.luau",
  "src/hunting/HuntEconomyService.luau", "src/data/ProfileService.luau"} do
  check(pcall(luau.compile, fs.readFile(path)), "Compile: " .. path)
 end
end)

print("Admin redemption:", checks, "checks /", groups, "groups PASS")
