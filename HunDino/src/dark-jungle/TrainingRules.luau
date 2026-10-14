local Rules={}
local keys={Light="L",Heavy="H",Skill="S"}
function Rules.staminaCost(config,base) return base*config.StaminaCostScale end
function Rules.clearCombo(state)
 state.ComboChain=""; state.ComboStep=0; state.ComboUntil=0
end
function Rules.markCombat(config,state,now)
 state.CombatUntil=now+config.CombatGrace
end
function Rules.evadeProfile(config,weapons,state,now)
 if state.WeaponId=="Bow" and state.Drawn then return "BowSlide",config.Evades.BowSlide end
 local chain=if now<=state.ComboUntil then state.ComboChain or "" else ""
 if #chain>0 then
  for _,combo in weapons[state.WeaponId].Combos do
   if combo.Input:sub(1,#chain+1)==chain.."D" then return "Combo",config.Evades.Combo end
  end
 end
 local mode=if now<(state.CombatUntil or 0) then "Roll" else "Travel"
 return mode,config.Evades[mode]
end
function Rules.dodge(config,weapons,state,now)
 local cost=Rules.staminaCost(config,config.DodgeCost)
 if state.Charge or state.Blocking or now<state.BusyUntil or state.Stamina+1e-7<cost then return false end
 local mode,profile=Rules.evadeProfile(config,weapons,state,now)
 local chain=if now<=state.ComboUntil then state.ComboChain or "" else ""
 local nextChain=chain.."D"
 for _,combo in weapons[state.WeaponId].Combos do
  if #nextChain<#combo.Input and combo.Input:sub(1,#nextChain)==nextChain then chain=nextChain; break end
 end
 state.Stamina=math.max(0,state.Stamina-cost); state.BusyUntil=now+profile.Time
 state.DodgingUntil=state.BusyUntil; state.LastSpend=state.BusyUntil; state.Sprinting=false
 state.ComboChain=chain; state.ComboStep=#chain; state.ComboUntil=state.BusyUntil+config.ComboWindow
 return true,mode,profile
end
function Rules.attack(config,weapons,state,action,now,allowCharge)
 if not keys[action] then return nil end
 if state.Charge or not state.Drawn or now<state.BusyUntil or state.Sprinting or state.Blocking then return nil end
 local weapon=weapons[state.WeaponId]; if not weapon or not weapon.Attacks then return nil end
 local chain=(if now<=state.ComboUntil then state.ComboChain or "" else "")..keys[action]
 local kind=action
 for _,combo in weapon.Combos do
  if chain==combo.Input then kind=combo.Attack; break end
 end
 local spec=weapon.Attacks[kind]; local cost=Rules.staminaCost(config,spec.Cost)
 if spec.ChargeTime and not allowCharge then return nil end
 if state.Stamina+1e-7<cost then return nil end
 state.Stamina=math.max(0,state.Stamina-cost); state.BusyUntil=now+spec.Duration; state.LastSpend=state.BusyUntil
 -- Keep the longest suffix that starts a recipe; rejected inputs never advance it.
 local prefix=""
 if kind==action then
  for start=1,#chain do
   local suffix=chain:sub(start)
   for _,combo in weapon.Combos do
    if #suffix<#combo.Input and combo.Input:sub(1,#suffix)==suffix and #suffix>#prefix then prefix=suffix end
   end
  end
 end
 state.ComboChain=prefix; state.ComboStep=#prefix; state.ComboUntil=state.BusyUntil+config.ComboWindow
 return kind,spec
end
function Rules.beginCharge(config,weapons,state,action,now)
 local bow=state.WeaponId=="Bow" and action=="Light"
 local iai=state.WeaponId=="Katana" and action=="Skill" and now<=state.ComboUntil and state.ComboChain=="LHHD"
 if not bow and not iai then return nil end
 local kind,spec=Rules.attack(config,weapons,state,action,now,true)
 if not kind then return nil end
 local setting=weapons[state.WeaponId].Charge
 local charge={Kind=kind,Spec=spec,Started=now,Time=if bow then setting.Time else spec.ChargeTime,
  Multiplier=if bow then (if action=="Heavy" then setting.HeavyMultiplier else setting.Multiplier) else spec.ChargeMultiplier,
  MaxHold=if bow then setting.MaxHold else spec.ChargeTime,AutoFull=iai}
 state.Charge=charge; state.BusyUntil=math.huge
 return charge
end
function Rules.releaseCharge(config,state,now)
 local c=state.Charge; if not c then return nil end
 local alpha=math.clamp((now-c.Started)/c.Time,0,1)
 local spec=table.clone(c.Spec)
 spec.Damage=math.floor(spec.Damage*(1+(c.Multiplier-1)*alpha)+.5)
 state.Charge=nil; state.BusyUntil=now+spec.Duration; state.LastSpend=state.BusyUntil
 state.ComboUntil=state.BusyUntil+config.ComboWindow
 return c.Kind,spec,alpha
end
function Rules.cancelCharge(state,now)
 if not state.Charge then return false end
 state.Charge=nil; state.BusyUntil=now+.15; state.LastSpend=now
 Rules.clearCombo(state)
 return true
end
function Rules.canEquip(state,weapons,id,now)
 return typeof(id)=="string" and weapons[id]~=nil and id~="Order" and state.InTraining
  and not state.Drawn and not state.Blocking and not state.Sprinting and now>=state.BusyUntil
end
function Rules.regenerate(config,state,now,dt)
 if not state.Sprinting and not state.Blocking and now>=state.BusyUntil and now-state.LastSpend>=config.RegenDelay then
  state.Stamina=math.min(config.MaxStamina,state.Stamina+config.StaminaRegen*dt)
 end
end
return Rules
