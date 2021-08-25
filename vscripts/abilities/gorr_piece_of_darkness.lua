gorr_piece_of_darkness = class({})
LinkLuaModifier ("modifier_gorr_piece_of_darkness", "abilities/gorr_piece_of_darkness.lua", LUA_MODIFIER_MOTION_NONE)

function gorr_piece_of_darkness:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function gorr_piece_of_darkness:GetCastRange( vLocation, hTarget )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "cast_range_scepter" )
	end

	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end

function gorr_piece_of_darkness:GetCooldown( level )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "cooldown_scepter" )
	end

	return self.BaseClass.GetCooldown( self, level )
end

function gorr_piece_of_darkness:GetManaCost( level )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "mana_cost_scepter" )
	end

	return self.BaseClass.GetManaCost( self, level )
end

--------------------------------------------------------------------------------
-- Ability Start
function gorr_piece_of_darkness:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	
	-- local projectile_name = "particles/units/heroes/hero_viper/viper_viper_strike.vpcf"
	local projectile_name = ""
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	-- Play Effects
	local effect = self:PlayEffects( target )

	-- create projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional

		ExtraData = {
			effect = effect,
		}
	}
	ProjectileManager:CreateTrackingProjectile(info)

end
--------------------------------------------------------------------------------
-- Projectile
function gorr_piece_of_darkness:OnProjectileHit_ExtraData( target, location, ExtraData )
	-- stop effects
	self:StopEffects( ExtraData.effect )

	if not target then return end

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- references
	local duration = self:GetSpecialValueFor( "duration" )

	-- add debuff
	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_gorr_piece_of_darkness", -- modifier name
		{ duration = duration } -- kv
	)

	-- play sound
	local sound_cast = "hero_viper.viperStrikeImpact"
	EmitSoundOn( sound_cast, target )
end

--------------------------------------------------------------------------------
function gorr_piece_of_darkness:PlayEffects( target )

	local particle_cast = "particles/gorr/gorr_piece_of_darkness_beam.vpcf"
	local sound_cast = "hero_viper.viperStrike"
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )


	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 6, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		4,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack2",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		5,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack3",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )

	-- return the particle index
	return effect_cast
end

function gorr_piece_of_darkness:StopEffects( effect_cast )
	ParticleManager:DestroyParticle( effect_cast, false )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_gorr_piece_of_darkness = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_gorr_piece_of_darkness:IsHidden()
	return false
end

function modifier_gorr_piece_of_darkness:IsDebuff()
	return true
end

function modifier_gorr_piece_of_darkness:IsStunDebuff()
	return false
end

function modifier_gorr_piece_of_darkness:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_gorr_piece_of_darkness:OnCreated( kv )
	-- references
	self.as_slow = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.ms_slow = self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" )
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )

	self.start_time = GameRules:GetGameTime()
	self.duration = kv.duration

	if not IsServer() then return end
	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}
	-- ApplyDamage(damageTable)

	-- Start interval
	self:StartIntervalThink( 1 )
	self:OnIntervalThink()
end

function modifier_gorr_piece_of_darkness:OnRefresh( kv )
	-- references
	self.as_slow = self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
	self.ms_slow = self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" )
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )

	self.start_time = GameRules:GetGameTime()
	self.duration = kv.duration
	
	if not IsServer() then return end
	-- update damage
	self.damageTable.damage = damage

	-- restart interval tick
	self:StartIntervalThink( 1 )
	self:OnIntervalThink()
end

function modifier_gorr_piece_of_darkness:OnRemoved()
end

function modifier_gorr_piece_of_darkness:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_gorr_piece_of_darkness:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_gorr_piece_of_darkness:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow * ( 1 - ( GameRules:GetGameTime()-self.start_time )/self.duration )
end
function modifier_gorr_piece_of_darkness:GetModifierAttackSpeedBonus_Constant()
	return self.as_slow * ( 1 - ( GameRules:GetGameTime()-self.start_time )/self.duration )
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_gorr_piece_of_darkness:OnIntervalThink()
	ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_gorr_piece_of_darkness:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_viper_strike_debuff.vpcf"
end

function modifier_gorr_piece_of_darkness:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_gorr_piece_of_darkness:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_viper.vpcf"
end

function modifier_gorr_piece_of_darkness:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end