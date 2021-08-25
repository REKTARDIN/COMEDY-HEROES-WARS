ronan_universal_weapon = class({})
LinkLuaModifier("modifier_ronan_universal_weapon", "abilities/ronan_universal_weapon.lua", LUA_MODIFIER_MOTION_NONE)

function ronan_universal_weapon:GetIntrinsicModifierName()
	return "modifier_ronan_universal_weapon"
end

modifier_ronan_universal_weapon = class({})

function modifier_ronan_universal_weapon:IsHidden()
    return true
end

function modifier_ronan_universal_weapon:IsPurgable()
    return false
end

function modifier_ronan_universal_weapon:IsPurgeException()
    return false
end

function modifier_ronan_universal_weapon:RemoveOnDeath()
    return false
end

function modifier_ronan_universal_weapon:OnCreated( kv )
    -- references
    self.base_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.str_damage = self:GetAbility():GetSpecialValueFor("strength_damage")
    self.chance = self:GetAbility():GetSpecialValueFor( "crush_chance" )
end

function modifier_ronan_universal_weapon:OnRefresh( kv )
    -- references
    self.base_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.str_damage = self:GetAbility():GetSpecialValueFor("strength_damage")
    self.chance = self:GetAbility():GetSpecialValueFor( "crush_chance" )
end

function modifier_ronan_universal_weapon:OnDestroy( kv )

end

function modifier_ronan_universal_weapon:DeclareFunctions()
    local func = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }

    return func
end

function modifier_ronan_universal_weapon:GetModifierProcAttack_BonusDamage_Physical( params )

    if IsServer() and (not self:GetParent():PassivesDisabled()) and RollPercentage(100) then
        
		local caster = self:GetCaster()
		
		local damage = self.base_damage + self.str_damage 
        local alert = caster:GetAverageTrueAttackDamage(caster) + damage
        
        local target = params.target

        local strike_effect = ParticleManager:CreateParticle( "particles/econ/items/chaos_knight/chaos_knight_ti9_weapon/chaos_knight_ti9_weapon_blur_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:ReleaseParticleIndex( strike_effect )
		
		local impact_effect = ParticleManager:CreateParticle( "particles/econ/items/chaos_knight/chaos_knight_ti9_weapon/chaos_knight_ti9_weapon_crit_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:SetParticleControl( impact_effect, 1, target:GetOrigin() )
		ParticleManager:ReleaseParticleIndex( impact_effect )
		
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, alert, nil)
        
		return damage
	end
end