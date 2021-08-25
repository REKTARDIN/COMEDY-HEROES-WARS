if savitar_speedster == nil then savitar_speedster = class({}) end
LinkLuaModifier( "modifier_savitar_speedster",	"abilities/savitar_speedster.lua", LUA_MODIFIER_MOTION_NONE )

function savitar_speedster:GetIntrinsicModifierName()
	return "modifier_savitar_speedster"
end

if modifier_savitar_speedster == nil then
	modifier_savitar_speedster = class ( {})
end

function modifier_savitar_speedster:IsHidden ()
	return true
end

function modifier_savitar_speedster:IsPurgable()
	return false
end

function modifier_savitar_speedster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
	}

	return funcs
end

function modifier_savitar_speedster:GetModifierMoveSpeedBonus_Constant()
    local agility = self:GetParent():GetAgility()
    local speed = agility * self:GetAbility():GetSpecialValueFor("speed_bonus")/ 100

    return speed
end

function modifier_savitar_speedster:GetModifierIgnoreMovespeedLimit()
	local MAX_SPEED = self:GetAbility():GetSpecialValueFor("max_speed")
	
	if self:GetParent():HasModifier("modifier_savitar_speedforce_rage") then
		MAX_SPEED = 10000
	end

	return MAX_SPEED
end