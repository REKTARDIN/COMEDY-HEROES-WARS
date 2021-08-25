item_orb_of_desire = class({})

LinkLuaModifier ("modifier_item_orb_of_desire", "items/item_orb_of_desire.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_orb_of_desire_debuff", "items/item_orb_of_desire.lua", LUA_MODIFIER_MOTION_NONE)

function item_orb_of_desire:GetIntrinsicModifierName()
    return "modifier_item_orb_of_desire"
end

modifier_item_orb_of_desire = class({})

function modifier_item_orb_of_desire:IsHidden ()
    return true
end

function modifier_item_orb_of_desire:IsPurgable()
    return false
end

function modifier_item_orb_of_desire:IsPurgeException()
    return false
end

function modifier_item_orb_of_desire:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_orb_of_desire:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

return funcs
end

function modifier_item_orb_of_desire:GetModifierBonusStats_Intellect( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

function modifier_item_orb_of_desire:IsAura()
    return true
end

function modifier_item_orb_of_desire:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_orb_of_desire:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_orb_of_desire:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_orb_of_desire:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_orb_of_desire:GetModifierAura()
    return "modifier_item_orb_of_desire_debuff"
end

modifier_item_orb_of_desire_debuff = class({})

function modifier_item_orb_of_desire_debuff:IsHidden ()
    return false
end

function modifier_item_orb_of_desire_debuff:IsPurgable()
    return false
end

function modifier_item_orb_of_desire_debuff:IsPurgeException()
    return false
end

function modifier_item_orb_of_desire_debuff:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

return funcs
end

function modifier_item_orb_of_desire_debuff:GetModifierMagicalResistanceBonus( params )
 
    local resistance = self:GetAbility():GetSpecialValueFor("aura_magical_resistance_enemies")
    
    return resistance
end

function modifier_item_orb_of_desire_debuff:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end

