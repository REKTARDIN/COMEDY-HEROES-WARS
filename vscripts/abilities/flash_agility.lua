if flash_agility == nil then flash_agility = class({}) end 
LinkLuaModifier ("modifier_flash_agility", "abilities/flash_agility.lua" , LUA_MODIFIER_MOTION_NONE)

function flash_agility:GetIntrinsicModifierName ()
    return "modifier_flash_agility"
end

if modifier_flash_agility == nil then
    modifier_flash_agility = class ( {})
end

function modifier_flash_agility:IsHidden ()
    return true
end

function modifier_flash_agility:IsPurgable()
    return false
end

function modifier_flash_agility:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
    }

    return funcs
end

function modifier_flash_agility:GetModifierIgnoreMovespeedLimit()
    local max_speed = 10000
	return max_speed
end

function modifier_flash_agility:GetModifierMoveSpeedBonus_Constant(params)
    return self:GetAbility():GetSpecialValueFor( "bonus_move_speed" )
end

function modifier_flash_agility:GetModifierBonusStats_Agility(params)
    return self:GetAbility():GetSpecialValueFor( "bonus_agility" )
end
