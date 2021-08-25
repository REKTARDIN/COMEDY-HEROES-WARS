LinkLuaModifier ("special_bonus_armor_magical_resistance_lvl_15", "talents/special_bonus_armor_magical_resistance_lvl_15.lua", LUA_MODIFIER_MOTION_NONE)

if special_bonus_armor_magical_resistance_lvl_15 == nil then special_bonus_armor_magical_resistance_lvl_15 = class({}) end

function special_bonus_armor_magical_resistance_lvl_15:IsHidden () return true end
function special_bonus_armor_magical_resistance_lvl_15:IsPurgable() return false end
function special_bonus_armor_magical_resistance_lvl_15:RemoveOnDeath() return false end
function special_bonus_armor_magical_resistance_lvl_15:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

function special_bonus_armor_magical_resistance_lvl_15:GetModifierMagicalResistanceBonus( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_magical_resistance" )
end

function special_bonus_armor_magical_resistance_lvl_15:GetModifierPhysicalArmorBonus( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_armor" )
end







