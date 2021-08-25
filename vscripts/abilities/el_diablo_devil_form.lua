el_diablo_devil_form = class({})

LinkLuaModifier ("modifier_el_diablo_devil_form", "abilities/el_diablo_devil_form.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_el_diablo_devil_form_aura", "abilities/el_diablo_devil_form.lua", LUA_MODIFIER_MOTION_NONE)

function el_diablo_devil_form:Precache( context )
	PrecacheModel( "models/heroes/hero_diablo/diablo_form.vmdl", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
	PrecacheResource( "particle", "particles/stygian/el_diablo_form_basedebuff.vpcf", context )
	PrecacheResource( "particle", "particles/stygian/diablo_transform.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_base_attack.vpcf", context )
end

--------------------------------------------------------------------------------
-- Ability Start
function el_diablo_devil_form:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_el_diablo_devil_form_aura", -- modifier name
		{ duration = duration } -- kv
	)
end

modifier_el_diablo_devil_form = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_el_diablo_devil_form:IsHidden()
	return false
end

function modifier_el_diablo_devil_form:IsDebuff()
	return false
end

function modifier_el_diablo_devil_form:IsStunDebuff()
	return false
end

function modifier_el_diablo_devil_form:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_el_diablo_devil_form:OnCreated( kv )
	-- references
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )
	self.range = self:GetAbility():GetSpecialValueFor( "bonus_range" )
	self.damage = self:GetAbility():GetSpecialValueFor( "bonus_damage_outgoing" )
	self.slow = self:GetAbility():GetSpecialValueFor( "speed_loss" )
	local delay = self:GetAbility():GetSpecialValueFor( "transformation_time" )

	self.projectile = 900

	if not IsServer() then return end

	self.attack = self:GetParent():GetAttackCapability()
	if self.attack == DOTA_UNIT_CAP_MELEE_ATTACK then
		self.range = 0
		self.projectile = 0
	end

	self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )

	-- gesture
	self:GetAbility():SetContextThink(DoUniqueString( "el_diablo_devil_form" ), function()
		self:GetParent():StartGesture( ACT_DOTA_CAST_ABILITY_3 )
	end, FrameTime())

	-- transform time
	self.stun = true
	self:StartIntervalThink( delay )

	-- play effects
	self:PlayEffects()
end

function modifier_el_diablo_devil_form:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_el_diablo_devil_form:OnRemoved()
end

function modifier_el_diablo_devil_form:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():SetAttackCapability( self.attack )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_el_diablo_devil_form:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,

		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,

		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
	}

	return funcs
end

function modifier_el_diablo_devil_form:GetModifierTotalDamageOutgoing_Percentage()
	return self.damage
end

function modifier_el_diablo_devil_form:GetModifierConstantHealthRegen( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_health_regen" )
end

function modifier_el_diablo_devil_form:GetModifierMoveSpeedBonus_Percentage( params )
    return -30
end

function modifier_el_diablo_devil_form:GetModifierPercentageCasttime( params ) 
    return self:GetAbility():GetSpecialValueFor( "bonus_cast_time" ) 
end

function modifier_el_diablo_devil_form:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function modifier_el_diablo_devil_form:GetModifierAttackRangeBonus()
	return -self.range
end

function modifier_el_diablo_devil_form:GetModifierModelChange()
	return "models/heroes/hero_diablo/diablo_form.vmdl"
end

function modifier_el_diablo_devil_form:GetModifierModelScale()
	return 25
end

function modifier_el_diablo_devil_form:GetAttackSound()
	return "Hero_Terrorblade_Morphed.Attack"
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_el_diablo_devil_form:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.stun,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_el_diablo_devil_form:OnIntervalThink()
	self.stun = false
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_el_diablo_devil_form:GetEffectName()
	return ""
end

function modifier_el_diablo_devil_form:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_el_diablo_devil_form:PlayEffects()
	-- Get Resources
	local particle_cast = ""
	local sound_cast = "Hero_Terrorblade.Metamorphosis"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end

modifier_el_diablo_devil_form_aura = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_el_diablo_devil_form_aura:IsHidden()
	return false
end

function modifier_el_diablo_devil_form_aura:IsDebuff()
	return false
end

function modifier_el_diablo_devil_form_aura:IsStunDebuff()
	return false
end

function modifier_el_diablo_devil_form_aura:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_el_diablo_devil_form_aura:OnCreated( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "metamorph_aura_tooltip" )

	if not IsServer() then return end
end

function modifier_el_diablo_devil_form_aura:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_el_diablo_devil_form_aura:OnRemoved()
end

function modifier_el_diablo_devil_form_aura:OnDestroy()
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_el_diablo_devil_form_aura:IsAura()
	return true
end

function modifier_el_diablo_devil_form_aura:GetModifierAura()
	return "modifier_el_diablo_devil_form"
end

function modifier_el_diablo_devil_form_aura:GetAuraRadius()
	return self.radius
end

function modifier_el_diablo_devil_form_aura:GetAuraDuration()
	return 1
end

function modifier_el_diablo_devil_form_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_el_diablo_devil_form_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function modifier_el_diablo_devil_form_aura:GetAuraSearchFlags()
	return 0
end

function modifier_el_diablo_devil_form_aura:GetAuraEntityReject( hEntity )
	if IsServer() then
		if hEntity:GetPlayerOwnerID()~=self:GetParent():GetPlayerOwnerID() then
			return true
		end
	end

	return false
end