LinkLuaModifier ("modifier_doomsday_leach", "abilities/doomsday_leach.lua", LUA_MODIFIER_MOTION_NONE)

doomsday_leach = class({})

function doomsday_leach:GetIntrinsicModifierName() return "modifier_doomsday_leach" end

modifier_doomsday_leach = class({})

function modifier_doomsday_leach:IsHidden()	return true end
function modifier_doomsday_leach:IsPurgable()	return false end
function modifier_doomsday_leach:DeclareFunctions() return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DIRECT_MODIFICATION} end

function modifier_doomsday_leach:OnCreated(params)
    if IsServer() then
        self.m_flDamage = self:GetAbility():GetSpecialValueFor("hp_leech_percent")

        if self:GetCaster():HasTalent("special_bonus_unique_doomsday_4") then
            self.m_flDamage = self.m_flDamage + self:GetCaster():FindTalentValue("special_bonus_unique_doomsday_4")
        end

        self.m_flDamage = self.m_flDamage / 100
    end
end

function modifier_doomsday_leach:OnRefresh(params)
    if IsServer() then
        self.m_flDamage = self:GetAbility():GetSpecialValueFor("hp_leech_percent")

        if self:GetCaster():HasTalent("special_bonus_unique_doomsday_4") then
            self.m_flDamage = self.m_flDamage + self:GetCaster():FindTalentValue("special_bonus_unique_doomsday_4")
        end

        self.m_flDamage = self.m_flDamage / 100
    end
end

function modifier_doomsday_leach:GetModifierProcAttack_BonusDamage_Physical(params)
	if params.attacker == self:GetParent() and (not params.target:IsBuilding()) and (not params.target:IsAncient()) then
		return self:GetParent():GetMaxHealth() * self.m_flDamage
	end
end

function modifier_doomsday_leach:GetModifierIncomingPhysicalDamage_Percentage(params)
	return -self:GetAbility():GetSpecialValueFor("physical_damage_block")
end

function modifier_doomsday_leach:GetModifierMagicalResistanceDirectModification(params)
	return self:GetAbility():GetSpecialValueFor("magical_damage_block") 
end
