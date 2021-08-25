item_magician_medallion = class({})

LinkLuaModifier ("modifier_item_magician_medallion", "items/item_magician_medallion.lua", LUA_MODIFIER_MOTION_NONE)

function item_magician_medallion:GetIntrinsicModifierName()
    return "modifier_item_magician_medallion"
end

modifier_item_magician_medallion = class({})

function modifier_item_magician_medallion:IsHidden ()
    return true 
end

function modifier_item_magician_medallion:IsPurgable()
    return false
end

function modifier_item_magician_medallion:IsPurgeException()
    return false
end

function modifier_item_magician_medallion:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_magician_medallion:DeclareFunctions() 
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    }

    return funcs
end

function modifier_item_magician_medallion:GetModifierBonusStats_Intellect( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

function modifier_item_magician_medallion:GetModifierPreAttack_BonusDamage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_damage" )
end

function modifier_item_magician_medallion:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

function modifier_item_magician_medallion:GetModifierConstantManaRegen( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" )
end

function modifier_item_magician_medallion:GetModifierManaBonus( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_mana" )
end

function modifier_item_magician_medallion:GetModifierHealthBonus( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_health" )
end

function modifier_item_magician_medallion:GetModifierPercentageCasttime( params ) 
    return self:GetAbility():GetSpecialValueFor( "bonus_cast_time" ) 
end

function modifier_item_magician_medallion:GetModifierPercentageManacost( params ) 
    return self:GetAbility():GetSpecialValueFor( "bonus_mana_cost" ) 
end

