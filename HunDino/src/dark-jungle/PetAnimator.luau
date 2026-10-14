-- Hoạt ảnh + vũ khí cho pet đứng (PetStanding.luau). ModuleScript độc lập, chưa gắn vào Training.server.luau.
-- Mọi góc dùng cùng công thức như bản xem mẫu trên web: tay xoay quanh trục X, góc dương = vung ra phía trước.
-- Dùng:
--   local model, rig = PetStanding.build(workspace)
--   local anim = PetAnimator.new(model, rig, game.ServerStorage.TrainingWeapons)
--   anim:SetWeapon("Hammer"); anim.OnHit = function(i) ... end
--   RunService.Heartbeat:Connect(function(dt) anim:Update(dt) end)
--   anim:SetMoving(true); anim:Attack()
local Animator = {}
Animator.__index = Animator

-- k = tỉ lệ thu nhỏ; o = dịch vũ khí dọc cán để tay nắm ở chỗ hợp lý; R/L = mô hình lấy từ TrainingWeapons.
-- leftPose = tư thế tay trái khi cầm đồ; style = kiểu đòn đánh.
local WEAPONS = {
	Hammer = { k = 0.7, o = 0.9, R = "Main", style = "Overhead" },
	SwordShield = { k = 0.8, o = 0, R = "Main", L = "Offhand", style = "Overhead", leftPose = { 0.8, 0.5 } },
	Katana = { k = 0.75, o = 0.3, R = "Main", style = "Overhead" },
	Glaive = { k = 0.55, o = 1.6, R = "Main", style = "Thrust" },
	DualDaggers = { k = 0.9, o = 0, R = "Main", L = "Offhand", style = "Dual", leftPose = { 0.8, 0.5 } },
	Bow = { k = 0.7, o = 0, ry = math.pi / 2, L = "Main", style = "Shoot", leftPose = { 1.1, 0.5 } },
	GreatAxe = { k = 0.7, o = 0.8, R = "Main", style = "Overhead" },
}

-- Bộ số {u vai, l khuỷu, tilt vũ khí, lean thân}. t1 = hết giai đoạn gồng, t2 = hết giai đoạn đánh.
-- marks = các mốc tiến độ (0..1) gọi OnHit.
local STYLES = {
	Overhead = { dur = 0.8, t1 = 0.35, t2 = 0.6, wind = { 2.6, 0.3, -0.5, -0.15 }, hit = { 0.6, 0.9, 1.8, 0.3 }, marks = { 0.45 } },
	Thrust = { dur = 0.65, t1 = 0.3, t2 = 0.5, wind = { 0.5, 1.0, 0.7, -0.12 }, hit = { 1.4, 0.2, 1.5, 0.25 }, marks = { 0.4 } },
	Shoot = { dur = 1.0, t1 = 0.6, t2 = 0.72, wind = { 1.2, 1.7, 0, -0.05 }, hit = { 1.1, 0.5, 0, 0.06 }, marks = { 0.65 } },
	Dual = {
		dur = 0.9, t1 = 0.35, t2 = 0.6, dual = true, marks = { 0.25, 0.65 },
		wind = { 2.0, 0.5, -0.3, -0.1 }, hit = { 0.7, 0.8, 1.5, 0.2 },
	},
}

local function ease(x: number): number
	return x * x * (3 - 2 * x)
end
local function lerpT(a, b, s: number)
	return { a[1] + (b[1] - a[1]) * s, a[2] + (b[2] - a[2]) * s, a[3] + (b[3] - a[3]) * s, a[4] + (b[4] - a[4]) * s }
end
-- rest -> wind -> hit -> rest
local function blend(rest, wind, hit, p: number, t1: number, t2: number)
	if p < t1 then
		return lerpT(rest, wind, ease(p / t1))
	elseif p < t2 then
		return lerpT(wind, hit, ease((p - t1) / (t2 - t1)))
	end
	return lerpT(hit, rest, ease((p - t2) / (1 - t2)))
end

local function attachWeapon(pet: Model, grip: BasePart, source: Model, cfg, name: string)
	assert(source and source:IsA("Model") and source.PrimaryPart, "Weapon template needs a PrimaryPart")
	local clone = source:Clone()
	clone.Name = name
	clone:ScaleTo(cfg.k)
	local handle = clone.PrimaryPart
	for _, d in clone:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = false
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
			d.Massless = true
		end
	end
	for _, d in clone:GetDescendants() do
		if d:IsA("BasePart") and d ~= handle and not d:FindFirstChild("KatanaWeld") and not d:FindFirstChild("WeaponProWeld") then
			local w = Instance.new("Weld")
			w.Part0 = handle
			w.Part1 = d
			w.C0 = handle.CFrame:ToObjectSpace(d.CFrame)
			w.Parent = d
		end
	end
	clone:PivotTo(grip.CFrame)
	local motor = Instance.new("Motor6D")
	motor.Name = name
	motor.Part0 = grip
	motor.Part1 = handle
	-- Keep the joint inside the clone so changing weapons destroys it too.
	motor.Parent = clone
	clone.Parent = pet
	return clone, motor
end

function Animator.new(model: Model, rig, templates: Instance)
	local self = setmetatable({}, Animator)
	self.Model, self.Rig, self.Templates = model, rig, templates
	self.t = 0
	self.walkBlend = 0
	self.moving = false
	self.speed = 1
	self.atk = nil
	self.fired = {}
	self.OnHit = nil -- function(markIndex: number)
	self.weaponModels = {}
	self.RenderPose = true
	self.destroyed = false
	return self
end

function Animator:GetHitCount(): number
	return if self.cfg then #STYLES[self.cfg.style].marks else 0
end

function Animator.profile(id: string)
	local cfg=WEAPONS[id]
	return if cfg then STYLES[cfg.style] else nil
end

function Animator:CancelAttack()
	self.atk = nil
	self.fired = {}
end

-- Client binds the server-created weapons; it never clones another copy.
function Animator:BindWeapon(id: string): boolean
	local cfg = WEAPONS[id]
	if not cfg then return false end
	local right = self.Model:FindFirstChild("WeaponR")
	local left = self.Model:FindFirstChild("WeaponL")
	local motorR = right and right:FindFirstChild("WeaponR")
	local motorL = left and left:FindFirstChild("WeaponL")
	if cfg.R and (not motorR or not motorR:IsA("Motor6D")) then return false end
	if cfg.L and (not motorL or not motorL:IsA("Motor6D")) then return false end
	self.id, self.cfg = id, cfg
	self.motorR, self.motorL = motorR, motorL
	self:CancelAttack()
	return true
end

function Animator:SyncAttack(elapsed: number)
	if self.cfg then
		self.atk = self.t - math.max(0, elapsed)
		self.fired = {}
	end
end

function Animator:SetWeapon(id: string?)
	local cfg = if id then WEAPONS[id] else nil
	local template = if id then self.Templates:FindFirstChild(id) else nil
	assert(not id or (cfg and template), "Không có vũ khí: " .. tostring(id))
	for _, m in self.weaponModels do
		m:Destroy()
	end
	self.weaponModels, self.motorR, self.motorL, self.id, self.cfg = {}, nil, nil, nil, nil
	self.atk = nil
	if not id then
		return
	end
	self.id, self.cfg = id, cfg
	if cfg.R then
		local m, motor = attachWeapon(self.Model, self.Rig.Grips.R, template[cfg.R], cfg, "WeaponR")
		table.insert(self.weaponModels, m)
		self.motorR = motor
	end
	if cfg.L then
		local m, motor = attachWeapon(self.Model, self.Rig.Grips.L, template[cfg.L], cfg, "WeaponL")
		table.insert(self.weaponModels, m)
		self.motorL = motor
	end
end

function Animator:SetMoving(on: boolean, speed: number?)
	self.moving = on
	self.speed = speed or 1
end

-- Bắt đầu đòn đánh. Trả về thời lượng (giây), hoặc nil nếu đang đánh hoặc chưa có vũ khí.
function Animator:Attack(): number?
	if self.destroyed or self.atk or not self.cfg then
		return nil
	end
	self.atk = self.t
	self.fired = {}
	return STYLES[self.cfg.style].dur
end

function Animator:IsAttacking(): boolean
	return self.atk ~= nil
end

function Animator:Update(dt: number)
	if self.destroyed then return end
	self.t += dt
	local t = self.t
	local cfg = self.cfg
	local m = self.Rig.Motors

	self.walkBlend += ((if self.moving then 1 else 0) - self.walkBlend) * (1 - math.exp(-10 * dt))
	local sw = math.sin(t * 6 * self.speed) * self.walkBlend

	-- Tư thế nghỉ của hai tay: {u, l, tilt, lean}
	local restR = if cfg and cfg.R then { 0.7, 0.8, 0.25, 0 } else { 0.15, 0.25, 0.25, 0 }
	local restL = if cfg and cfg.leftPose then { cfg.leftPose[1], cfg.leftPose[2], 0, 0 } else { 0.15, 0.25, 0, 0 }
	local R, L = restR, restL

	if self.atk and cfg then
		local style = STYLES[cfg.style]
		local p = (t - self.atk) / style.dur
		-- Process crossed marks even when this frame reaches/passes recovery.
		for i, mark in style.marks do
			if p >= mark and not self.fired[i] then
				self.fired[i] = true
				if self.OnHit then self.OnHit(i) end
			end
		end
		if self.destroyed then return end
		if p >= 1 then
			self.atk = nil
		else
			if style.dual then
				R = blend(restR, style.wind, style.hit, math.clamp(p / 0.55, 0, 1), style.t1, style.t2)
				L = blend(restL, style.wind, style.hit, math.clamp((p - 0.35) / 0.65, 0, 1), style.t1, style.t2)
				R = { R[1], R[2], R[3], (R[4] + L[4]) / 2 }
			else
				R = blend(restR, style.wind, style.hit, p, style.t1, style.t2)
			end
		end
	end

	-- Server advances hit timing; clients apply the visual pose in PreSimulation.
	if not self.RenderPose then return end
	local uR, lR, uL, lL = R[1], R[2], L[1], L[2]
	if not self.atk then
		uR -= sw * 0.12
		uL += sw * 0.12
	end

	m.Torso.Transform = CFrame.new(0, (if self.moving then math.abs(sw) * 0.1 else math.sin(t * 2) * 0.025), 0)
		* CFrame.Angles(R[4], 0, 0)
	m.ArmR.Transform = CFrame.Angles(uR, 0, 0)
	m.ForeR.Transform = CFrame.Angles(lR, 0, 0)
	m.ArmL.Transform = CFrame.Angles(uL, 0, 0)
	m.ForeL.Transform = CFrame.Angles(lL, 0, 0)
	m.LegR.Transform = CFrame.Angles(sw * 0.6, 0, 0)
	m.LegL.Transform = CFrame.Angles(-sw * 0.6, 0, 0)
	m.Head.Transform = CFrame.Angles(math.sin(t * 3) * 0.04, if self.atk then 0 else math.sin(t * 0.8) * 0.25, 0)
	m.Tail1.Transform = CFrame.Angles(0, math.sin(t * 3) * 0.18, 0)
	m.Tail2.Transform = CFrame.Angles(0, math.sin(t * 3 - 0.9) * 0.28, 0)

	-- Weapon-specific pose overrides from the full weapons reference.
	if cfg and self.atk then
		local p = math.clamp((t - self.atk) / STYLES[cfg.style].dur, 0, 1)
		if self.id=="Katana" or self.id=="SwordShield" then
			local recovery=math.clamp((1-p)/0.2,0,1)
			m.Torso.Transform *= CFrame.Angles(0,math.cos(p*math.pi)*-0.4*recovery,0)
			m.ArmR.Transform *= CFrame.Angles(0,0,-0.3*math.sin(p*math.pi))
		elseif self.id=="Glaive" then
			m.Torso.Transform *= CFrame.Angles(0,math.sin(p*math.pi)*0.45,0)
		elseif self.id=="Hammer" or self.id=="GreatAxe" then
			local jumpY=if p<0.45 then math.sin((p/0.45)*math.pi)*0.35 else 0
			m.Torso.Transform *= CFrame.new(0,jumpY,0)
		elseif self.id=="Bow" then
			m.Torso.Transform *= CFrame.Angles(0,-0.35*math.sin(p*math.pi),0)
		end
	end

	-- Vũ khí luôn bù góc để giữ hướng: xoay X (bù tay + tilt), rồi dịch dọc cán, rồi xoay Y.
	if cfg then
		local shift = CFrame.new(0, cfg.o * cfg.k, 0) * CFrame.Angles(0, cfg.ry or 0, 0)
		if self.motorR then
			self.motorR.Transform = CFrame.Angles(-(uR + lR) - R[3], 0, 0) * shift
		end
		if self.motorL then
			self.motorL.Transform = CFrame.Angles(-(uL + lL) - L[3], 0, 0) * shift
		end
	end
end

function Animator:Destroy()
	if self.destroyed then return end
	self.destroyed = true
	self:CancelAttack()
	self.OnHit = nil
	for _, w in self.weaponModels do
		w:Destroy()
	end
	table.clear(self.weaponModels)
	self.motorR, self.motorL, self.cfg = nil, nil, nil
end

return Animator

--[[ Thử trong Studio: tạo một Script TẠM trong ServerScriptService, dán đoạn này, nhấn Play (F5):
local RS, SS = game:GetService("RunService"), game:GetService("ServerStorage")
local Pet = require(SS.PetStanding)
local Anim = require(SS.PetAnimator)
local model, rig = Pet.build(workspace)
model:PivotTo(CFrame.new(0, 0.1, -20) * CFrame.Angles(0, math.pi, 0))
local a = Anim.new(model, rig, SS.TrainingWeapons)
a:SetWeapon("Hammer")          -- đổi thành SwordShield, Katana, Glaive, DualDaggers, Bow, GreatAxe để thử
a.OnHit = function(i) print("trúng đòn", i) end
RS.Heartbeat:Connect(function(dt) a:Update(dt) end)
task.spawn(function()
	while true do
		task.wait(1.5); a:Attack()
		task.wait(1.5); a:SetMoving(true); task.wait(2); a:SetMoving(false)
	end
end)
]]
