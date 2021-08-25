beyonder_void_break = class({})
LinkLuaModifier ("modifier_beyonder_void_break", "abilities/beyonder_void_break.lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
function beyonder_void_break:GetIntrinsicModifierName()
	return "modifier_beyonder_void_break"
end

modifier_beyonder_void_break = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_beyonder_void_break:IsHidden()
	return true
end

function modifier_beyonder_void_break:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_beyonder_void_break:OnCreated( kv )
	-- references
	self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" ) -- special value
    self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" ) -- special value
    self.mana_burn_pct = self:GetAbility():GetSpecialValueFor( "mana_burn_pct" )
    self.chance = self:GetAbility():GetSpecialValueFor( "void_break_chance" )
end

function modifier_beyonder_void_break:OnRefresh( kv )
	-- references
	self.mana_break = self:GetAbility():GetSpecialValueFor( "mana_per_hit" ) -- special value
    self.mana_damage_pct = self:GetAbility():GetSpecialValueFor( "damage_per_burn" ) -- special value
    self.mana_burn_pct = self:GetAbility():GetSpecialValueFor( "mana_burn_pct" )
    self.chance = self:GetAbility():GetSpecialValueFor( "void_break_chance" )
end

function modifier_beyonder_void_break:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_beyonder_void_break:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}

	return funcs
end

function modifier_beyonder_void_break:GetModifierProcAttack_BonusDamage_Physical( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) and RollPercentage(self.chance) then
		local target = params.target
		local result = UnitFilter(
			target,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_MANA_ONLY,	-- Unit Flag
			self:GetParent():GetTeamNumber()	-- Team reference
		)
	
		if result == UF_SUCCESS then
            local mana_burn =  math.min( target:GetMana(), self.mana_break )
			local mana_burn_pct = target:GetMaxMana()/100 * self.mana_burn_pct
			
			if (not self:GetCaster():IsRealHero()) then 
				burn = mana_burn + mana_burn_pct/2
			end

			local burn = mana_burn + mana_burn_pct
			target:ReduceMana( burn )

			self:PlayEffects( target )

			return burn * self.mana_damage_pct
		end

	end
end

function modifier_beyonder_void_break:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/generic_gameplay/generic_manaburn.vpcf"
	local sound_cast = "Hero_Antimage.ManaBreak"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
	-- ParticleManager:SetParticleControl( effect_cast, 0, vControlVector )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end