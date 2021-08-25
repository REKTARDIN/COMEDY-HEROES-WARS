LinkLuaModifier ("special_bonus_move_speed_lvl_10", "talents/special_bonus_move_speed_lvl_10.lua", LUA_MODIFIER_MOTION_NONE)

if special_bonus_move_speed_lvl_10 == nil then special_bonus_move_speed_lvl_10 = class({}) end

function special_bonus_move_speed_lvl_10:IsHidden () return true end
function special_bonus_move_speed_lvl_10:IsPurgable() return false end
function special_bonus_move_speed_lvl_10:RemoveOnDeath() return false end
function special_bonus_move_speed_lvl_10:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }

    return funcs
end

function special_bonus_move_speed_lvl_10:GetModifierMoveSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
end




