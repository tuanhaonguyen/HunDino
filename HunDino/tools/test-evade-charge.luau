local config=require('../src/shared/TrainingConfig')
local weapons=require('../src/dark-jungle/Weapons')
local rules=require('../src/dark-jungle/TrainingRules')
local function fresh(id)
 return {WeaponId=id,Drawn=true,InTraining=true,BusyUntil=0,Stamina=100,ComboUntil=0,LastSpend=0}
end
do
 local s=fresh("Hammer")
 assert(rules.evadeProfile(config,weapons,s,0)=="Travel")
 rules.markCombat(config,s,10)
 assert(rules.evadeProfile(config,weapons,s,12.99)=="Roll")
 assert(rules.evadeProfile(config,weapons,s,13)=="Travel")
 rules.markCombat(config,s,12)
 assert(rules.evadeProfile(config,weapons,s,14)=="Roll")
 s.ComboChain="L"; s.ComboUntil=20
 assert(rules.evadeProfile(config,weapons,s,14)=="Combo")
 s.WeaponId="Bow"
 assert(rules.evadeProfile(config,weapons,s,14)=="BowSlide")
 for mode,p in config.Evades do
  local distance=p.Time*(p.Speed+p.EndSpeed)/2
  assert(distance>8.8,mode)
 end
end
for _,action in {"Light"} do
 local last=0
 for _,duration in {0,.3,.6,1.2,5} do
  local s=fresh("Bow")
  local c=rules.beginCharge(config,weapons,s,action,0); assert(c)
  local stamina=s.Stamina
  assert(not rules.attack(config,weapons,s,"Skill",1))
  assert(not rules.beginCharge(config,weapons,s,action,1))
  assert(not rules.dodge(config,weapons,s,1))
  assert(not rules.canEquip(s,weapons,"Hammer",1))
  local kind,spec=rules.releaseCharge(config,s,duration)
  assert(kind==action and spec.Damage>=last)
  assert(spec.Damage<=math.floor(c.Spec.Damage*c.Multiplier+.5))
  assert(s.Stamina==stamina and not s.Charge)
  assert(not rules.releaseCharge(config,s,duration))
  last=spec.Damage
 end
end
do
 local s=fresh("Bow")
 assert(not rules.beginCharge(config,weapons,s,"Heavy",0),"Q cannot charge")
 local kind,spec=rules.attack(config,weapons,s,"Heavy",0)
 assert(kind=="Heavy" and spec.Damage==weapons.Bow.Attacks.Heavy.Damage)
end
do
 local s=fresh("Katana"); local now=0
 assert(not rules.beginCharge(config,weapons,s,"Skill",now))
 for _,a in {"Light","Heavy","Heavy"} do assert(rules.attack(config,weapons,s,a,now)); now=s.BusyUntil+.02 end
 assert(rules.dodge(config,weapons,s,now)); now=s.BusyUntil+.02
 assert(s.ComboChain=="LHHD")
 assert(not rules.attack(config,weapons,s,"Skill",now),"held finisher cannot bypass charging")
 local c=rules.beginCharge(config,weapons,s,"Skill",now); assert(c and c.AutoFull)
 local kind,spec=rules.releaseCharge(config,s,now+1.5)
 assert(kind=="Iai" and spec.Damage==351 and s.ComboChain=="")
end
for _,reason in {"Cancel","Menu","Hit","Death"} do
 local s=fresh("Bow"); assert(rules.beginCharge(config,weapons,s,"Light",0))
 local stamina=s.Stamina
 assert(rules.cancelCharge(s,.2)); assert(s.Stamina==stamina and s.ComboChain=="")
 assert(not rules.releaseCharge(config,s,5),reason)
 assert(not rules.cancelCharge(s,5))
end
print("PASS evade selection/expiry, charge scaling/cap/cancellation/exploit guards, held katana recipe")
print("THEORETICAL DPS (all hits, zero input gaps; not a full hunt balance test)")
for _,id in weapons.Order do
 for _,combo in weapons[id].Combos do
  local s=fresh(id); local now,damage=0,0
  for letter in combo.Input:gmatch(".") do
   if letter=="D" then assert(rules.dodge(config,weapons,s,now))
   else
    local a=({L="Light",H="Heavy",S="Skill"})[letter]
    local kind,spec
    if combo.Attack=="Iai" and letter=="S" then
     local c=rules.beginCharge(config,weapons,s,a,now); assert(c); now+=c.Time
     kind,spec=rules.releaseCharge(config,s,now)
    else kind,spec=rules.attack(config,weapons,s,a,now) end
    assert(kind); damage+=spec.Damage*(spec.Hits or spec.Shots or 1)
   end
   now=s.BusyUntil
  end
  print(id,combo.Input,damage,math.floor(damage/now*10+.5)/10)
 end
end
