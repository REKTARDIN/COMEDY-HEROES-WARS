LinkLuaModifier ("special_bonus_damage_lvl_25", "talents/special_bonus_damage_lvl_25.lua", LUA_MODIFIER_MOTION_NONE)

if special_bonus_damage_lvl_25 == nil then special_bonus_damage_lvl_25 = class({}) end

function special_bonus_damage_lvl_25:IsHidden () return true end
function special_bonus_damage_lvl_25:IsPurgable() return false end
function special_bonus_damage_lvl_25:RemoveOnDeath() return false end
function special_bonus_damage_lvl_25:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE       
    }

    return funcs
end

function special_bonus_damage_lvl_25:GetModifierPreAttack_BonusDamage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_damage" )
end








