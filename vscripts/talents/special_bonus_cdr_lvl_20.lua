LinkLuaModifier ("special_bonus_cdr_lvl_20", "talents/special_bonus_cdr_lvl_20.lua", LUA_MODIFIER_MOTION_NONE)

if special_bonus_cdr_lvl_20 == nil then special_bonus_cdr_lvl_20 = class({}) end

function special_bonus_cdr_lvl_20:IsHidden () return true end
function special_bonus_cdr_lvl_20:IsPurgable() return false end
function special_bonus_cdr_lvl_20:RemoveOnDeath() return false end
function special_bonus_cdr_lvl_20:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE       
    }

    return funcs
end

function special_bonus_cdr_lvl_20:GetModifierPercentageCooldown( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_cooldown" )
end








