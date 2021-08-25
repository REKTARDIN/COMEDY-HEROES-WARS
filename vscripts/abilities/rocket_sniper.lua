LinkLuaModifier ("modifier_rocket_sniper", "abilities/rocket_sniper.lua", LUA_MODIFIER_MOTION_NONE)

rocket_sniper = class({})

function rocket_sniper:GetIntrinsicModifierName()
	return "modifier_rocket_sniper"
end
------------------------------------------------------------------------------------------------------------------------
modifier_rocket_sniper = class({})

function modifier_rocket_sniper:IsHidden() 
	return true 
end

function modifier_rocket_sniper:IsPurgable() 
	return false 
end

function modifier_rocket_sniper:RemoveOnDeath() 
	return false 
end

function modifier_rocket_sniper:OnCreated()
	if IsServer() then
		self.parent = self:GetParent()
		self.ability = self:GetAbility()

		self.damage = self.ability:GetSpecialValueFor("range_damage")
	end
end

function modifier_rocket_sniper:OnRefresh()
	if IsServer() then
		self:OnCreated()
	end
end

function modifier_rocket_sniper:DeclareFunctions()
	local func = {
	MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL}

	return func
end

function modifier_rocket_sniper:GetModifierProcAttack_BonusDamage_Magical(params)
	if IsServer() then
		
		if self.parent:PassivesDisabled() then
			return nil
		end

		if keys.target:IsBuilding() then
			return nil
		end

		self.ability:UseResources(true, false, true)

		local distance = CalcDistanceBetweenEntityOBB(self.parent, params.target)

		local damage = distance * self.damage_pct/100
	
		return damage
	end
end