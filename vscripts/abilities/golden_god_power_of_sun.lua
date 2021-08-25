LinkLuaModifier( "modifier_golden_god_power_of_sun", "abilities/golden_god_power_of_sun.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_golden_god_power_of_sun_aura", "abilities/golden_god_power_of_sun.lua", LUA_MODIFIER_MOTION_NONE )

golden_god_power_of_sun = class({})

function golden_god_power_of_sun:GetIntrinsicModifierName()
    return "modifier_golden_god_power_of_sun_aura"
end


if modifier_golden_god_power_of_sun_aura == nil then modifier_golden_god_power_of_sun_aura = class({}) end

function modifier_golden_god_power_of_sun_aura:IsAura() return true end
function modifier_golden_god_power_of_sun_aura:IsHidden() return true end
function modifier_golden_god_power_of_sun_aura:IsPurgable() return false end
function modifier_golden_god_power_of_sun_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_golden_god_power_of_sun_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_golden_god_power_of_sun_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_golden_god_power_of_sun_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_golden_god_power_of_sun_aura:GetModifierAura() return "modifier_golden_god_power_of_sun" end
function modifier_golden_god_power_of_sun_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
    }

    return funcs
end

function modifier_golden_god_power_of_sun_aura:GetModifierExtraHealthBonus( params )
    return self:GetAbility():GetSpecialValueFor("bonus_extra_health")
end


if modifier_golden_god_power_of_sun == nil then modifier_golden_god_power_of_sun = class({}) end

function modifier_golden_god_power_of_sun:IsPurgable() return false end
function modifier_golden_god_power_of_sun:RemoveOnDeath() return true end
function modifier_golden_god_power_of_sun:IsHidden() return false end
function modifier_golden_god_power_of_sun:IsDebuff() return not self:GetCaster():IsFriendly(self:GetParent()) end

function modifier_golden_god_power_of_sun:OnCreated(params)
    self.health = self:GetAbility():GetSpecialValueFor("health_ptc") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_goldengod_4") or 0)

    if (not self:GetCaster():IsFriendly(self:GetParent())) then
        self.health = -self.health
    end
end

function modifier_golden_god_power_of_sun:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE
    }

    return funcs
end

function modifier_golden_god_power_of_sun:GetModifierExtraHealthPercentage( params )
    return self.health
end
