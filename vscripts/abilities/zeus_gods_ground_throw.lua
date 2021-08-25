zeus_gods_ground_throw = class({})

LinkLuaModifier( "modifier_zeus_gods_ground_throw_rush", "abilities/zeus_gods_ground_throw.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

function zeus_gods_ground_throw:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
	local origin = caster:GetOrigin()
    local target = self:GetCursorTarget()
	local point = target:GetOrigin()
	local rush_range = ability:GetSpecialValueFor("tooltip_range")
	local speed = ability:GetSpecialValueFor("rush_speed")
	
    if target:TriggerSpellAbsorb( self ) then 
        return 
    end
	
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
	
	local direction = (point - caster:GetAbsOrigin()):Normalized()
	caster:SetForwardVector(direction)
	
    caster:AddNewModifier(caster, ability, "modifier_zeus_gods_ground_throw_rush", {target = target:entindex()})
end

modifier_zeus_gods_ground_throw_rush = class({})

function modifier_zeus_gods_ground_throw_rush:OnCreated(params)	
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	local startpoint = self.caster:GetAbsOrigin()
	
	self.startpoint = startpoint 

	self.rush_speed = self.ability:GetSpecialValueFor("rush_speed")
	self.range = self.ability:GetSpecialValueFor("tooltip_range")

	local height = 300
	local duration = self.range / self.rush_speed

    if IsServer() then
		self.target = EntIndexToHScript(params.target) 
		local point = self.target:GetOrigin()
		
		self.time_elapsed = 0

		self.distance = (self.caster:GetAbsOrigin() - point):Length2D()
		self.rush_time = self.distance / self.rush_speed
		self.direction = (point - self.caster:GetAbsOrigin()):Normalized()
		
		local half_duration = duration/2
		self.gravity = 2*height/(half_duration*half_duration)
		self.vVelocity = self.gravity*half_duration
		
		self:ApplyHorizontalMotionController()
	end
end

function modifier_zeus_gods_ground_throw_rush:IsHidden() 
    return true 
end

function modifier_zeus_gods_ground_throw_rush:IsPurgable() 
    return false 
end

function modifier_zeus_gods_ground_throw_rush:GetMotionControllerPriority() 
    return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
 end

function modifier_zeus_gods_ground_throw_rush:UpdateHorizontalMotion( me, dt)
	if IsServer() then
		self.rush_time = self.distance / self.rush_speed
		
        self.time_elapsed = self.time_elapsed + dt
        
		if self.time_elapsed < self.rush_time then

		local new_location = self.caster:GetAbsOrigin() + self.direction * self.rush_speed * dt
			self.caster:SetAbsOrigin(new_location)
		else
			self:Destroy()
		end
	end
end

function modifier_zeus_gods_ground_throw_rush:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_zeus_gods_ground_throw_rush:OnRemoved()
	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local base_damage = ability:GetSpecialValueFor("base_damage")
		local critical_damage = caster:GetAverageTrueAttackDamage(target) * ability:GetSpecialValueFor("critical_damage")/100
		local total_damage = base_damage + critical_damage
		
		local knockback = {
			should_stun = 1,
			knockback_duration = 1.0,
			duration = 1.0,
			knockback_distance = 25,
			knockback_height = -100,
			center_x = self:GetCaster():GetAbsOrigin().x,
			center_y = self:GetCaster():GetAbsOrigin().y,
			center_z = self:GetCaster():GetAbsOrigin().z 
		}
		
		if self.target:GetTeamNumber() ~= caster:GetTeamNumber() then
		local damageTable = {victim = self.target,
			damage = total_damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			attacker = caster,
			ability = ability
        }

        EmitSoundOn("Hero_Zuus.Cloud.Cast", self.target)
        EmitSoundOn("Hero_Zeus.BlinkDagger.Arcana", self.target)
		EmitSoundOn("Hero_Zuus.LightningBolt.Cast.Righteous", self.target)
		EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Target", self.target)

		ApplyDamage(damageTable)
		self.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_knockback", knockback )
            
            local particle = ParticleManager:CreateParticle("particles/stygian/zeus_ground_throw_thundergods_wrath.vpcf", PATTACH_WORLDORIGIN, target)
            ParticleManager:SetParticleControl(particle, 0, Vector(self.target:GetAbsOrigin().x,self.target:GetAbsOrigin().y,self.target:GetAbsOrigin().z + self.target:GetBoundingMaxs().z ))
            ParticleManager:SetParticleControl(particle, 1, Vector(self.target:GetAbsOrigin().x,self.target:GetAbsOrigin().y,3000 ))
			ParticleManager:SetParticleControl(particle, 2, Vector(self.target:GetAbsOrigin().x,self.target:GetAbsOrigin().y,self.target:GetAbsOrigin().z + self.target:GetBoundingMaxs().z ))
			
			local particle2 = ParticleManager:CreateParticle( "particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_culling_blade_kill.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target )
			ParticleManager:SetParticleControl( particle2, 4, self.target:GetAbsOrigin() )
			ParticleManager:SetParticleControlForward( particle2, 3, self.target:GetAbsOrigin() )
			ParticleManager:SetParticleControlForward( particle2, 4, self.target:GetAbsOrigin() )
			ParticleManager:ReleaseParticleIndex( particle2 )
		end
		caster:InterruptMotionControllers( true )
	end
end


