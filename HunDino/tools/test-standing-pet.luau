local fs = require("@lune/fs")
local luau = require("@lune/luau")
local r = require("@lune/roblox")
luau.compile(fs.readFile("src/dark-jungle/KatanaPro.luau"))
luau.compile(fs.readFile("src/dark-jungle/KatanaEffects.client.luau"))
luau.compile(fs.readFile("src/dark-jungle/WeaponsPro.luau"))
luau.compile(fs.readFile("src/dark-jungle/WeaponVFX.luau"))
luau.compile(fs.readFile("src/dark-jungle/WeaponEffects.client.luau"))
for _,path in {"src/dark-jungle/PetStanding.luau", "src/dark-jungle/PetAnimator.luau", "src/dark-jungle/PetPlacement.luau", "src/dark-jungle/PetAnimation.client.luau", "src/dark-jungle/Training.server.luau", "src/dark-jungle/Traversal.server.luau", "studio-pet-integration/Training.server.luau", "studio-pet-integration/Traversal.server.luau"} do
	luau.compile(fs.readFile(path))
end
local env = {Color3=r.Color3, Vector3=r.Vector3, CFrame=r.CFrame, Instance=r.Instance, Enum=r.Enum}
local Standing=luau.load(fs.readFile("src/dark-jungle/PetStanding.luau"), {environment=env,injectGlobals=true})()
local Animator=luau.load(fs.readFile("src/dark-jungle/PetAnimator.luau"), {environment=env,injectGlobals=true})()
local model, rig=Standing.build()
local bound=assert(Standing.bind(model))
assert(bound.Motors.ArmR==rig.Motors.ArmR and bound.Grips.L==rig.Grips.L)
model.Head:Destroy()
assert(Standing.bind(model)==nil, "partially streamed rigs must wait")
for _,style in {"Overhead", "Thrust", "Shoot", "Dual"} do
	for _,longFrame in {false,true} do
		local pet, skeleton=Standing.build()
		local anim=Animator.new(pet,skeleton,nil)
		anim.cfg={R="Main",style=style,k=1,o=0}
		anim.RenderPose=false
		local hits={}
		anim.OnHit=function(index) table.insert(hits,index) end
		local duration=assert(anim:Attack())
		assert(anim:Attack()==nil)
		if longFrame then anim:Update(duration+0.1)
		else for _=1,120 do anim:Update(1/60) end end
		assert(#hits==(if style=="Dual" then 2 else 1), style.." missing hits")
		assert(not anim:IsAttacking())
		anim:Update(10); assert(#hits==anim:GetHitCount(), "duplicate hit")
		assert(anim:Attack()); anim:CancelAttack(); anim:Update(10)
		assert(#hits==anim:GetHitCount(), "cancelled attack hit")
		anim:Destroy(); assert(anim:Attack()==nil)
		pet:Destroy()
	end
end
print("PASS compile, replicated rig binding, four attack styles, long frames, once-only hits, cancellation and destroy")
