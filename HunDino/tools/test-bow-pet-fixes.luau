local fs=require('@lune/fs')
local luau=require('@lune/luau')
local r=require('@lune/roblox')
local Bow=luau.load(fs.readFile('src/dark-jungle/BowBallistics.luau'),{environment={Vector3=r.Vector3},injectGlobals=true})()
local Rules=require('../studio-pet-integration/TrainingRules')
local Weapons=require('../studio-pet-integration/Weapons')
local Config=require('../src/shared/TrainingConfig')
local checks=0
local function check(ok,label) checks+=1;assert(ok,label) end
local function fresh() return {WeaponId='Bow',Drawn=true,InTraining=true,BusyUntil=0,Stamina=100,ComboUntil=0,LastSpend=0} end
for _,alpha in {0,.25,.5,.75,1,2} do
 local state=fresh()
 check(Rules.beginCharge(Config,Weapons,state,'Light',10)~=nil,'Charge starts')
 local _,spec=Rules.releaseCharge(Config,state,10+1.2*alpha)
 check(math.abs(spec.Range-Bow.range(alpha))<1e-6,'Server charge range interpolation')
end
check(Weapons.Bow.Attacks.Skill.Damage==24 and Weapons.Bow.Attacks.Skill.Shots==3,'Tam Tien is three 24-damage arrows')
check(Weapons.Bow.Attacks.Skill.Spread==0,'Tam Tien converges at same target')
for name,spec in Weapons.Bow.Attacks do check(spec.Range==40,'No uncharged range exception '..name) end
local target=r.Vector3.new(0,4,-100)
for x=-15,15,1 do
 local origin=Bow.origin(r.Vector3.new(x,3,0))
 local direction=Bow.direction(origin,target,r.Vector3.new(0,0,-1))
 check((origin+direction*(target-origin).Magnitude-target).Magnitude<1e-4,'Moving muzzle still converges on target')
end
local frame=r.CFrame.new(0,3,0)
local follow=Bow.followPoint(frame,true)-frame.Position
check(follow.X<=-6 and follow.Z>=6,'Aiming pet stays behind left shoulder: '..tostring(follow))
check(not Bow.validTarget(r.Vector3.new(0/0,0,0),r.Vector3.zero),'Reject NaN aim')
check(not Bow.validTarget(r.Vector3.new(0,0,math.huge),r.Vector3.zero),'Reject infinite aim')
check(not Bow.validTarget(r.Vector3.new(0,0,351),r.Vector3.zero),'Reject distant client aim')
print('PASS '..checks..' bow range/aim/volley contracts')
