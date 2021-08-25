ancient_lich_ice_split = class({})
LinkLuaModifier( "modifier_ancient_lich_ice_split", "abilities/ancient_lich_ice_split.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ancient_lich_ice_split_debuff", "abilities/ancient_lich_ice_split.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function ancient_lich_ice_split:GetAOERadius()
	return self:GetSpecialValueFor( "radius" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_ancient_lich_1") or 0)
end

--------------------------------------------------------------------------------
function ancient_lich_ice_split:OnSpellStart()
	
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local delay = self:GetSpecialValueFor("delay")

	CreateModifierThinker(
		caster, 
		self, 
		"modifier_ancient_lich_ice_split",
		{ duration = delay },
		point,
		caster:GetTeamNumber(),
		false
	)
end
----------------------------------------------------------------------------
modifier_ancient_lich_ice_split = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ancient_lich_ice_split:IsHidden()
	return true
end

function modifier_ancient_lich_ice_split:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_ancient_lich_ice_split:OnCreated( kv )
	if not IsServer() then return end

	
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_ancient_lich_1") or 0)
	local damage = self:GetAbility():GetAbilityDamage()

	
	self.damageTable = {
	    victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), 
	}
	 ApplyDamage(damageTable)

	 self:PlayEffects2()
end

function modifier_ancient_lich_ice_split:OnRefresh( kv )
	
end

function modifier_ancient_lich_ice_split:OnRemoved()
end

function modifier_ancient_lich_ice_split:OnDestroy()
	if not IsServer() then return end

	-- find enemies
	    local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- stun
		enemy:AddNewModifier(
			self:GetCaster(), -- player source
			self:GetAbility(), -- ability source
			"modifier_ancient_lich_ice_split_debuff", -- modifier name
			{ duration = self.duration } -- kv
		)
		if self:GetCaster():HasTalent("special_bonus_unique_ancient_lich_5") then
		enemy:AddNewModifier(
			self:GetCaster(), -- player source
			self:GetAbility(), -- ability source
			"modifier_stunned", -- modifier name
			{ duration = 0.5 } -- kv
		)
	end
		-- damage
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )
end

	-- play effects
	self:PlayEffects()

	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ancient_lich_ice_split:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/stygian/ancient_lich_split.vpcf"
	local sound_split = "Hero_Lich.FrostBlast.Immortal"
	local sound_cast = "Hero_Lich.IceAge"

	-- -- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	
	EmitSoundOn( sound_cast, self:GetCaster())

	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_split, self:GetCaster() )
end

function modifier_ancient_lich_ice_split:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/stygian/ancient_lich_dark_fissure_preanticipate.vpcf"
	local sound_split = "Hero_Lich.FrostBlast.Immortal"

	-- -- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_split, self:GetCaster() )
end

modifier_ancient_lich_ice_split_debuff = class({})

function modifier_ancient_lich_ice_split_debuff:IsHidden() 
    return false
end

function modifier_ancient_lich_ice_split_debuff:RemoveOnDeath() 
    return false 
end

function modifier_ancient_lich_ice_split_debuff:IsPurgable() 
    return true 
end

function modifier_ancient_lich_ice_split_debuff:GetEffectName()
    return ""
end
          
function modifier_ancient_lich_ice_split_debuff:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_ancient_lich_ice_split_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor( "debuff_slow" )*(-1)
end