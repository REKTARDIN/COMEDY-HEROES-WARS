apocalypse_curse_of_wisdom = class({})
LinkLuaModifier( "modifier_apocalypse_curse_of_wisdom", "abilities/apocalypse_curse_of_wisdom.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function apocalypse_curse_of_wisdom:GetIntrinsicModifierName()
	return "modifier_apocalypse_curse_of_wisdom"
end

modifier_apocalypse_curse_of_wisdom = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_apocalypse_curse_of_wisdom:IsHidden()
	return true
end

function modifier_apocalypse_curse_of_wisdom:IsPurgable()
	return false
end

function modifier_apocalypse_curse_of_wisdom:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_apocalypse_curse_of_wisdom:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL
	}

	return funcs
end

function modifier_apocalypse_curse_of_wisdom:GetModifierProcAttack_BonusDamage_Magical( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) and self:GetAbility():IsCooldownReady() then
        self:GetAbility():UseResources(false, false, true)
        
        local damage = self:GetParent():GetIntellect() * self:GetAbility():GetSpecialValueFor("intellect_ptc") / 100
        local debuff_duration = self:GetAbility():GetSpecialValueFor("silence_debuff_duration")

        params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = debuff_duration})

        self:CreateEffects(params.target)

        return damage
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_apocalypse_curse_of_wisdom:CreateEffects( target )
	-- play effect
	local effect_impact = ParticleManager:CreateParticle( "particles/stygian/apocalypse_ulti_buff_flash.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_impact,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		target:GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_impact )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( "particles/stygian/apocalypse_crit_main.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- play sound
	EmitSoundOn( "Hero_ChaosKnight.ChaosStrike", self:GetParent() )
	EmitSoundOn( "Hero_SkeletonKing.CriticalStrike", target )
end