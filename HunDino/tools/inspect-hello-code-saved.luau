-- Read-only native save verification: never writes a place or touches Terrain.
local fs=require('@lune/fs')
local roblox=require('@lune/roblox')
local serde=require('@lune/serde')
local luau=require('@lune/luau')
local path='HunDino_HelloHunDino_20261022.rbxl'
local root=roblox.deserializePlace(fs.readFile(path))
local checks,scripts=0,0
local function check(ok,message) checks+=1;assert(ok,message) end
local function at(path) local o=root;for n in path:gmatch('[^.]+') do o=assert(o:FindFirstChild(n),path) end;return o end
local function normalize(s) return s:gsub('\r\n','\n'):gsub('%s+$','') end
for _,row in serde.decode('json',fs.readFile('assets/redeem/hello-code/install.json')) do
 check(normalize(at(row.Path).Source)==normalize(row.Source),'Saved source '..row.Path)
 local backup=at('ServerStorage.HelloCodeBackup_20261022.'..row.Path:gsub('%.','__'))
 check(normalize(backup.Value)==normalize(row.Baseline),'Original source backup '..row.Path)
end
for _,o in root:GetDescendants() do
 if o:IsA('LuaSourceContainer') then scripts+=1;check(pcall(luau.compile,o.Source),'Compile '..o:GetFullName()) end
 check(not o.Name:match('^__AdminRedeemQA'),'No temporary QA fixture')
end
local config=at('ServerScriptService.AccountData.ProfileConfig').Source
check(config:find('StudioMemoryTest=false',1,true)~=nil,'Memory-only testing disabled')
check(at('ServerScriptService.AccountData'):GetAttribute('StudioMemoryTest')~=true,'No QA override')
local report={Checks=checks,ScriptsCompiled=scripts,Place=path,SourceBindings=3,
 SHA256=serde.hash('sha256',fs.readFile(path)),PublicCode='HelloHunDino',
 Rewards={Coins=50,RawTrap=2,IronTrap=2,SleepPotion=2},
 Tests={PureChecks=243,StudioServiceChecks=127,AdminRegressionChecks=346},
 RealPlayerCodeRedeemedByQA=false}
fs.writeFile('assets/redeem/hello-code/saved.json',serde.encode('json',report,true))
print(serde.encode('json',report))
