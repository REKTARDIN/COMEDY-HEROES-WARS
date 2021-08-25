--------------------------------------------------------------------------------
infinity_gravity_aura = class({})
LinkLuaModifier( "modifier_infinity_gravity_aura", "abilities/infinity_gravity_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_infinity_gravity_aura_debuff", "abilities/infinity_gravity_aura", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Passive Modifier
function infinity_gravity_aura:GetIntrinsicModifierName()
	return "modifier_infinity_gravity_aura"
end

--------------------------------------------------------------------------------
modifier_infinity_gravity_aura = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_infinity_gravity_aura:IsHidden()
	return false
end

function modifier_infinity_gravity_aura:IsDebuff()
	return false
end

function modifier_infinity_gravity_aura:IsStunDebuff()
	return false
end

function modifier_infinity_gravity_aura:IsPurgable()
	return false
end

function modifier_infinity_gravity_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_infinity_gravity_aura:RemoveOnDeath()
	return false
end

function modifier_infinity_gravity_aura:DestroyOnExpire()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_infinity_gravity_aura:OnCreated( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_infinity_5") or 0)
end

function modifier_infinity_gravity_aura:OnRefresh( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_infinity_5") or 0)
end

function modifier_infinity_gravity_aura:OnRemoved()
end

function modifier_infinity_gravity_aura:OnDestroy()
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_infinity_gravity_aura:IsAura()
	return (not self:GetCaster():PassivesDisabled())
end

function modifier_infinity_gravity_aura:GetModifierAura()
	return "modifier_infinity_gravity_aura_debuff"
end

function modifier_infinity_gravity_aura:GetAuraRadius()
	return self.radius
end

function modifier_infinity_gravity_aura:GetAuraDuration()
	return 0.5
end

function modifier_infinity_gravity_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_infinity_gravity_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_infinity_gravity_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_infinity_gravity_aura:IsAuraActiveOnDeath()
	return false
end

--------------------------------------------------------------------------------

modifier_infinity_gravity_aura_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_infinity_gravity_aura_debuff:IsHidden()
	return false
end

function modifier_infinity_gravity_aura_debuff:IsDebuff()
	return false
end

function modifier_infinity_gravity_aura_debuff:IsPurgable()
	return false
end

function modifier_infinity_gravity_aura_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_infinity_gravity_aura_debuff:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_infinity_gravity_aura_debuff:OnCreated( kv )
	if IsServer() then
		self.projectile_reduction = self:GetParent():GetProjectileSpeed() * (self:GetAbility():GetSpecialValueFor("projectile_speed_ptc") / 100)
		self.attack_speed = self:GetParent():GetAttackSpeed() * (self:GetAbility():GetSpecialValueFor("attack_speed_ptc") / 100)
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_infinity_gravity_aura_debuff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT 
	}

	return funcs
end

function modifier_infinity_gravity_aura_debuff:GetModifierProjectileSpeedBonus()
	if IsServer() then
		if self:GetParent():IsRangedAttacker() then
			return -(self.projectile_reduction or 0)
		end
	
		return 0
	end
end


function modifier_infinity_gravity_aura_debuff:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return -(self.attack_speedor or 0)
	end
end

