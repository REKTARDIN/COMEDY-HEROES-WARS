LinkLuaModifier("modifier_spectre_marksmanship", "abilities/spectre_marksmanship.lua", 0)
spectre_marksmanship = class({
    GetIntrinsicModifierName = function() return "modifier_spectre_marksmanship" end
})

modifier_spectre_marksmanship = class({
    IsHidden = function() return true end,
    IsPurgable = function() return false end,
    DeclareFunctions = function() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
})

function modifier_spectre_marksmanship:GetModifierIncomingDamage_Percentage(params)
    if IsServer() then
        if params.target == self:GetParent() and self:GetParent():PassivesDisabled() == false and self:GetParent():IsRealHero() and self:GetAbility():IsCooldownReady() then
            if RollPercentage(self:GetAbility():GetSpecialValueFor("dodge_chance")) then
                if params.attacker:IsRealHero() then
                    self:GetParent():ModifyAgility(self:GetAbility():GetSpecialValueFor("bonus_agility"))
                end
    
                self:GetAbility():UseResources(false, false, true)
    
                return -100
            end
        end
    end
 
    return 0
end
