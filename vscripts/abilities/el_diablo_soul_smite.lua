el_diablo_soul_smite = class({})

--------------------------------------------------------------------------------
-- Init Abilities
function el_diablo_soul_smite:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
	PrecacheResource( "particle", "particles/stygian/diablo_smite.vpcf", context )
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function el_diablo_soul_smite:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
	end

	local nResult = UnitFilter(
		hTarget,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO,
		0,
		self:GetCaster():GetTeamNumber()
	)
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end

function el_diablo_soul_smite:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	return ""
end

--------------------------------------------------------------------------------
-- Ability Start
function el_diablo_soul_smite:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
    local health = self:GetSpecialValueFor("health_damage")

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end
    
    local damage = {
        victim = target,
        attacker = self:GetCaster(),
        damage = (target:GetHealth() * health)/100,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_HPLOSS,
        ability = self
    }

	local heal = (target:GetHealth() * health)/100

    ApplyDamage( damage ) 

	
	caster:Heal(heal, self)

	-- play effects
	self:PlayEffects( target )
end

--------------------------------------------------------------------------------
-- Effects
function el_diablo_soul_smite:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/stygian/diablo_smite.vpcf"
	local sound_cast = "Hero_Terrorblade.Sunder.Cast"
	local sound_target = "Hero_Terrorblade.Sunder.Target"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	--ParticleManager:SetParticleControl( effect_cast, PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_target, target )
end