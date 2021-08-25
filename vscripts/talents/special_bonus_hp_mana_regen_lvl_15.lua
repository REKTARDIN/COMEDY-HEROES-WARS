LinkLuaModifier ("special_bonus_hp_mana_regen_lvl_15", "talents/special_bonus_hp_mana_regen_lvl_15.lua", LUA_MODIFIER_MOTION_NONE)

if special_bonus_hp_mana_regen_lvl_15 == nil then special_bonus_hp_mana_regen_lvl_15 = class({}) end

function special_bonus_hp_mana_regen_lvl_15:IsHidden () return true end
function special_bonus_hp_mana_regen_lvl_15:IsPurgable() return false end
function special_bonus_hp_mana_regen_lvl_15:RemoveOnDeath() return false end
function special_bonus_hp_mana_regen_lvl_15:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }

    return funcs
end

function special_bonus_hp_mana_regen_lvl_15:GetModifierConstantManaRegen( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" )
end

function special_bonus_hp_mana_regen_lvl_15:GetModifierConstantHealthRegen( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_hp_regen" )
end







