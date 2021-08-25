hades_dark_slash = class({})
LinkLuaModifier( "modifier_hades_dark_slash_dash", "abilities/hades_dark_slash.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_hades_dark_slash", "abilities/hades_dark_slash.lua", LUA_MODIFIER_MOTION_NONE )

function hades_dark_slash:GetAOERadius()
	local radius = self:GetSpecialValueFor("radius")    
	
	return radius
end

function hades_dark_slash:OnSpellStart()
	if IsServer() then
		
		local caster = self:GetCaster()
		local origin = caster:GetOrigin()
		local target = caster:GetCursorPosition()
		local point = target

		self.souls_buff = self:GetCaster():FindModifierByName("modifier_hades_bowl_of_souls_passive")
		local soul_range = 0
		if caster:HasModifier("modifier_hades_bowl_of_souls_passive") then
			soul_range =  self.souls_buff:GetStackCount() * 25
		end
		
		local speed = self:GetSpecialValueFor("dash_speed") + soul_range
		
		self.endpoint = caster:GetCursorPosition()
		
		local direction = (point - caster:GetAbsOrigin()):Normalized()
		caster:SetForwardVector(direction)
		
		local maxrange = self:GetSpecialValueFor("dash_range") + caster:GetCastRangeBonus() + soul_range

		local distance = (target-origin):Length2D()

		if distance > maxrange then
			distance = maxrange
		end
	
		caster:AddNewModifier(caster, self, "modifier_hades_dark_slash_dash", {})
		
		local projectile_name = "particles/stygian/chaos_king_proj_dark_land.vpcf"
		local projectile_distance = distance 
		local projectile_start_radius = 200
		local projectile_end_radius = 200
		local projectile_speed = speed
		local projectile_direction = point - caster:GetOrigin()
		projectile_direction.z = 0
		projectile_direction = projectile_direction:Normalized()

		
		local info = {
			Source = caster,
			Ability = self,
			vSpawnOrigin = caster:GetAbsOrigin(),
			
			bDeleteOnHit = false,
			
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			
			EffectName = projectile_name,
			fDistance = projectile_distance,
			fStartRadius = projectile_start_radius,
			fEndRadius = projectile_end_radius,
			vVelocity = projectile_direction * projectile_speed,
			}
		ProjectileManager:CreateLinearProjectile(info)
	end
end

function hades_dark_slash:OnProjectileHit( target, location )
	if IsServer() then

		local damage = self:GetSpecialValueFor( "damage" )
		local caster = self:GetCaster()

		local damageTable = {
			victim = target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
		}

		caster:PerformAttack(target, false, true, true, false, false, false, true)

		ApplyDamage(damageTable)
	end
end

modifier_hades_dark_slash_dash = class({})

function modifier_hades_dark_slash_dash:IsHidden() 
	return true 
end

function modifier_hades_dark_slash_dash:IsPurgable() 
	return false 
end

function modifier_hades_dark_slash_dash:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_shadow_realm.vpcf"
end

function modifier_hades_dark_slash_dash:OnCreated()
	--Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	
	local target = self.caster:GetCursorPosition()
	local point = target
	local startpoint = self.caster:GetOrigin()
	self.souls_buff = self:GetCaster():FindModifierByName("modifier_hades_bowl_of_souls_passive")
	local soul_range = 0

	if self:GetParent():HasModifier("modifier_hades_bowl_of_souls_passive") then
		soul_range =  self.souls_buff:GetStackCount() * 25
	end

	local max_range = self.ability:GetSpecialValueFor("dash_range") + self.caster:GetCastRangeBonus() + soul_range
	
	self.target = target 
	self.startpoint = startpoint 

	self.dash_speed = self.ability:GetSpecialValueFor("dash_speed") + soul_range

	if IsServer() then

		self.time_elapsed = 0

		self.distance = (self.caster:GetAbsOrigin() - point):Length2D()
		if self.distance > max_range then
			self.distance = max_range
		end
		self.dash_time = self.distance / self.dash_speed
		self.direction = (point - self.caster:GetAbsOrigin()):Normalized()
		
		self:ApplyHorizontalMotionController()
	end
end

function modifier_hades_dark_slash_dash:UpdateHorizontalMotion( me, dt)
	if IsServer() then
		self.dash_time = self.distance / self.dash_speed
		
		self.time_elapsed = self.time_elapsed + dt
		if self.time_elapsed < self.dash_time then	
		local new_location = self.caster:GetAbsOrigin() + self.direction * self.dash_speed * dt
			self.caster:SetAbsOrigin(new_location)
		else
			self:Destroy()
		end
	end
end

function modifier_hades_dark_slash_dash:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_hades_dark_slash_dash:OnRemoved()
	if IsServer() then
		local caster = self:GetParent()

		caster:AddNewModifier(self.caster, self.ability, "modifier_hades_dark_slash", {duration = 0.2})

		if caster:HasScepter() then
			caster:AddNewModifier(self.caster, self.ability, "modifier_hades_dark_slash", {duration = 0.3})
		end
	
		caster:InterruptMotionControllers( true )
	end
end

function modifier_hades_dark_slash_dash:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

modifier_hades_dark_slash = class({})

function modifier_hades_dark_slash:IsHidden() 
	return true 
end

function modifier_hades_dark_slash:IsPurgable() 
	return false 
end

function modifier_hades_dark_slash:IsPurgeException() 
	return false 
end

function modifier_hades_dark_slash:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_shadow_realm.vpcf"
end

function modifier_hades_dark_slash:GetAttributes()	
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_hades_dark_slash:OnCreated()
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_6)
end

function modifier_hades_dark_slash:OnRefresh()
	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_6)
end

function modifier_hades_dark_slash:OnDestroy()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local radius = ability:GetSpecialValueFor( "radius" ) 
	local damage = ability:GetSpecialValueFor( "damage" )

	local damageTable = {
		-- victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = ability, --Optional.
	}
	
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	
		self:GetParent():GetOrigin(),	
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,	
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0,	
		0,
		false	
	)
	local knockback = {
		should_stun = 1,
		knockback_duration = 0.5,
		duration = 0.3,
		knockback_distance = 0,
		knockback_height = 200,
		center_x = self:GetCaster():GetAbsOrigin().x,
		center_y = self:GetCaster():GetAbsOrigin().y,
		center_z = self:GetCaster():GetAbsOrigin().z 
	}

	for _,enemy in pairs(enemies) do
		
		damageTable.victim = enemy
		
		ApplyDamage(damageTable)
		enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_knockback", knockback )
	end
	
	local slash_particle = "particles/stygian/hades_dark_slash_aoe.vpcf"
	local slash_pfx = ParticleManager:CreateParticle(slash_particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(slash_pfx, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl(slash_pfx, 1, Vector( radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex(slash_pfx)

	EmitSoundOn("Hero_NyxAssassin.Vendetta.Crit", caster)
end

function modifier_hades_dark_slash:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end