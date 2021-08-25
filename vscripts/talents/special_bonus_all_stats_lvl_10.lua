LinkLuaModifier ("special_bonus_all_stats_lvl_10", "talents/special_bonus_all_stats_lvl_10.lua", LUA_MODIFIER_MOTION_NONE)

if special_bonus_all_stats_lvl_10 == nil then special_bonus_all_stats_lvl_10 = class({}) end

function special_bonus_all_stats_lvl_10:IsHidden () return true end
function special_bonus_all_stats_lvl_10:IsPurgable() return false end
function special_bonus_all_stats_lvl_10:RemoveOnDeath() return false end
function special_bonus_all_stats_lvl_10:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }

    return funcs
end

function special_bonus_all_stats_lvl_10:GetModifierBonusStats_Strength( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
end

function special_bonus_all_stats_lvl_10:GetModifierBonusStats_Agility( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
end

function special_bonus_all_stats_lvl_10:GetModifierBonusStats_Intellect( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
end




