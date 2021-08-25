if item_unholy_shield == nil then item_unholy_shield = class({}) end

LinkLuaModifier( "modifier_item_unholy_shield_passive", "items/item_unholy_shield.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_unholy_shield_strength", "items/item_unholy_shield.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_unholy_shield_toggle_prevention", "items/item_unholy_shield.lua", LUA_MODIFIER_MOTION_NONE )

function item_unholy_shield:GetAbilityTextureName()
	return "custom/unholy_shield_passive"
end

function item_unholy_shield:GetIntrinsicModifierName()
	return "modifier_item_unholy_shield_passive"
end

function item_unholy_shield:OnSpellStart()
	if IsServer() then

		local caster = self:GetCaster()

		if caster:HasModifier("modifier_item_unholy_shield_toggle_prevention") then
			return nil
		end

		caster:AddNewModifier(caster, self, "modifier_item_unholy_shield_toggle_prevention", {duration = 0.05})

		if caster:HasModifier("modifier_item_unholy_shield_strength") then
			caster:EmitSound("Hero_OgreMagi.FireShield.Damage")
			caster:RemoveModifierByName("modifier_item_unholy_shield_strength")
		else
			caster:EmitSound("Hero_OgreMagi.FireShield.Target")
			caster:AddNewModifier(caster, self, "modifier_item_unholy_shield_strength", {})
		end
	end
end

function item_unholy_shield:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_unholy_shield_strength") then
		return "custom/unholy_shield_activ"
	else
		return "custom/unholy_shield_passive"
	end
end

if modifier_item_unholy_shield_passive == nil then modifier_item_unholy_shield_passive = class({}) end

function modifier_item_unholy_shield_passive:IsHidden()			return true end
function modifier_item_unholy_shield_passive:IsPurgable()		return false end
function modifier_item_unholy_shield_passive:RemoveOnDeath()	return false end
function modifier_item_unholy_shield_passive:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_unholy_shield_passive:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end
	
	if not IsServer() then return end

	if self:GetParent():IsIllusion() and self:GetParent():GetPlayerOwner():GetAssignedHero():HasModifier("modifier_item_unholy_shield_strength") then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_unholy_shield_strength", {})
	end
end

function modifier_item_unholy_shield_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

function modifier_item_unholy_shield_passive:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage") end

function modifier_item_unholy_shield_passive:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end

function modifier_item_unholy_shield_passive:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor") end

function modifier_item_unholy_shield_passive:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health") end

function modifier_item_unholy_shield_passive:GetModifierPhysical_ConstantBlock()
	if IsServer() then
		if RollPercentage(self:GetAbility():GetSpecialValueFor("block_chance")) then
			if not self:GetParent():IsRangedAttacker() then
				local caster = self:GetParent()
    			local str = caster:GetStrength()
   				local block_bonus = self:GetAbility():GetSpecialValueFor("block_per_str")
    			local block_amp = str * block_bonus
				return self:GetAbility():GetSpecialValueFor("damage_block_melee") + block_amp
			else
				return self:GetAbility():GetSpecialValueFor("damage_block_ranged") + block_amp
			end
		end
	end 
end	

function modifier_item_unholy_shield_passive:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end

if modifier_item_unholy_shield_strength == nil then modifier_item_unholy_shield_strength = class({}) end
function modifier_item_unholy_shield_strength:IsDebuff() return false end
function modifier_item_unholy_shield_strength:IsPurgable() return false end

function modifier_item_unholy_shield_strength:GetEffectName()
	return "particles/stygian/unholy_of_tsut_buff.vpcf"
end

function modifier_item_unholy_shield_strength:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.unholy_bonus_strength	= self:GetAbility():GetSpecialValueFor("unholy_bonus_strength")
	self.unholy_health_drain	= self:GetAbility():GetSpecialValueFor("unholy_health_drain")

	if IsServer() then
		
		local caster = self:GetCaster()
		local bonus_health = self:GetAbility():GetSpecialValueFor("unholy_bonus_strength") * 20
		local health_before_activation = caster:GetHealth()
		
		if not self:GetParent():IsIllusion() then
			Timers:CreateTimer(0.01, function()
				caster:SetHealth(health_before_activation + bonus_health)
			end)
		end

		
		self:StartIntervalThink(0.1)
	end
end

function modifier_item_unholy_shield_strength:OnIntervalThink()
	
	self:GetParent():SetHealth(math.max( self:GetParent():GetHealth() - self.unholy_health_drain * 0.1, 1))
end

function modifier_item_unholy_shield_strength:OnDestroy()
	if IsServer() then
		if self:GetCaster():IsAlive() then
	
			local caster = self:GetCaster()
			local bonus_health = self.unholy_bonus_strength * 20
			local health_before_deactivation = caster:GetHealthPercent() * (caster:GetMaxHealth() + bonus_health) * 0.01
			caster:SetHealth(math.max(health_before_deactivation - bonus_health, 1))
		end
	end
end

function modifier_item_unholy_shield_strength:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_item_unholy_shield_strength:GetModifierBonusStats_Strength()			
	return self:GetAbility():GetSpecialValueFor("unholy_bonus_strength")
end

function modifier_item_unholy_shield_strength:GetModifierPreAttack_BonusDamage()		
	return self:GetAbility():GetSpecialValueFor("unholy_bonus_damage") 
end

function modifier_item_unholy_shield_strength:GetModifierPhysicalArmorBonus()			
	return self:GetAbility():GetSpecialValueFor("unholy_bonus_armor")
end

function modifier_item_unholy_shield_strength:GetModifierAttackSpeedBonus_Constant()	
		return self:GetAbility():GetSpecialValueFor("unholy_bonus_attack_speed")
end

function modifier_item_unholy_shield_strength:OnTooltip()
	return self.unholy_health_drain
end

modifier_item_unholy_shield_toggle_prevention = modifier_item_unholy_shield_toggle_prevention or class({})

function modifier_item_unholy_shield_toggle_prevention:IsHidden() return true end
function modifier_item_unholy_shield_toggle_prevention:IsDebuff() return false end
function modifier_item_unholy_shield_toggle_prevention:IsPurgable() return false end