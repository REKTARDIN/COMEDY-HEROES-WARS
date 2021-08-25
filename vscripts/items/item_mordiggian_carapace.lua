if item_mordiggian_carapace == nil then item_mordiggian_carapace = class ({}) end

LinkLuaModifier("modifier_item_mordiggian_carapace_active", "items/item_mordiggian_carapace.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mordiggian_carapace", "items/item_mordiggian_carapace.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mordiggian_carapace_aura", "items/item_mordiggian_carapace.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mordiggian_carapace_emitter", "items/item_mordiggian_carapace.lua", LUA_MODIFIER_MOTION_NONE)

function item_mordiggian_carapace:GetIntrinsicModifierName()
	return "modifier_item_mordiggian_carapace"
end

--Handle armlet toggle
function item_mordiggian_carapace:OnSpellStart()
	local checkActive = self:GetCaster():FindModifierByName("modifier_item_mordiggian_carapace_active")
	if checkActive == nil then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_mordiggian_carapace_active", nil)
	else
		checkActive:Destroy()
	end
end

if modifier_item_mordiggian_carapace == nil then modifier_item_mordiggian_carapace = class ({}) end

function modifier_item_mordiggian_carapace:OnCreated()
	if IsServer() then
		local checkAura = self:GetParent():FindModifierByName("modifier_item_mordiggian_carapace_emitter")
	
		if checkAura == nil then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_mordiggian_carapace_emitter", nil)
		end
	end
end

function modifier_item_mordiggian_carapace:IsHidden()
	return true
end

function modifier_item_mordiggian_carapace:IsPurgable()
	return false
end

function modifier_item_mordiggian_carapace:GetAttributes()	
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_mordiggian_carapace:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,		
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}

	return funcs
end

function modifier_item_mordiggian_carapace:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_mordiggian_carapace:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_mordiggian_carapace:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_mordiggian_carapace:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_mordiggian_carapace:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stats")
end

function modifier_item_mordiggian_carapace:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_mordiggian_carapace:OnDestroy()
	if IsServer() then
		local removeActive = self:GetParent():FindModifierByName("modifier_item_mordiggian_carapace_active")
		if removeActive ~= nil then
			removeActive:Destroy()
		end
		local removeAura = self:GetParent():FindModifierByName("modifier_item_mordiggian_carapace_emitter")
		if removeAura ~= nil then
			removeAura:Destroy()
		end
	end
end

if modifier_item_mordiggian_carapace_emitter == nil then modifier_item_mordiggian_carapace_emitter = class ({}) end

function modifier_item_mordiggian_carapace_emitter:IsHidden()
	return true
end

function modifier_item_mordiggian_carapace_emitter:IsPurgable()
	return false
end

function modifier_item_mordiggian_carapace_emitter:IsAura()
	return true
end

function modifier_item_mordiggian_carapace_emitter:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end

function modifier_item_mordiggian_carapace_emitter:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO 
end

function modifier_item_mordiggian_carapace_emitter:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_item_mordiggian_carapace_emitter:GetModifierAura()
	return "modifier_item_mordiggian_carapace_aura"
end

function modifier_item_mordiggian_carapace_emitter:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_mordiggian_carapace_emitter:IsAuraActiveOnDeath()
	return false
end

if modifier_item_mordiggian_carapace_aura == nil then modifier_item_mordiggian_carapace_aura = class ({}) end

function modifier_item_mordiggian_carapace_aura:IsHidden()
	return false
end

function modifier_item_mordiggian_carapace_aura:IsPurgable()
	return false
end

function modifier_item_mordiggian_carapace_aura:DeclareFunctions()
	local funcs = {	
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end

function modifier_item_mordiggian_carapace_aura:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("aura_attack_speed") 
end

function modifier_item_mordiggian_carapace_aura:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("aura_armor") 
end

function modifier_item_mordiggian_carapace_aura:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("aura_regen") 
end

if modifier_item_mordiggian_carapace_active == nil then modifier_item_mordiggian_carapace_active = class ({}) end

function modifier_item_mordiggian_carapace_active:IsHidden()
	return false
end

function modifier_item_mordiggian_carapace_active:IsPurgable()
	return false
end

function modifier_item_mordiggian_carapace_active:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_item_mordiggian_carapace_active:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("active_bonus_damage")
end

function modifier_item_mordiggian_carapace_active:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("active_bonus_armor")
end

function modifier_item_mordiggian_carapace_active:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("active_bonus_strength")
end

function modifier_item_mordiggian_carapace_active:OnTakeDamage(params)
	local attacker = params.attacker
	local target = params.unit
	local original_damage = params.original_damage
	local damage_type = params.damage_type
	local damage_flags = params.damage_flags

	if params.unit == self:GetParent() and not params.attacker:IsBuilding() and params.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		if not params.unit:IsOther() then
			local damageTable = {
				victim			= params.attacker,
				damage			= params.original_damage * 0.5,
				damage_type		= params.damage_type,
				damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				attacker		= self:GetParent(),
				ability			= self:GetAbility()
			}
			
			local reflectDamage = ApplyDamage(damageTable)
		end
	end
end	

function modifier_item_mordiggian_carapace_active:OnCreated(kv)
	if IsServer() then
		if not self:GetParent():IsIllusion() then
			local user = self:GetParent()
			local bonus_health = self:GetAbility():GetSpecialValueFor("active_bonus_strength") * 20
			local health_before_activation = user:GetHealth()
			Timers:CreateTimer(0.01, function()
				user:SetHealth(health_before_activation + bonus_health)
			end) --Need Timers library /// Freeman - why do you need to use it? 
			--user:SetHealth(health_before_activation + bonus_health)
		end
		self:StartIntervalThink(0.5)
	end
end

function modifier_item_mordiggian_carapace_active:OnDestroy()
	if IsServer() then
		if self:GetParent():IsAlive() then
			local user = self:GetParent()
			local bonus_health = self:GetAbility():GetSpecialValueFor("active_bonus_strength") * 20
			local health_before_deactivation = user:GetHealthPercent() * (user:GetMaxHealth() + bonus_health) * 0.01
		
			user:SetHealth(math.max((health_before_deactivation - bonus_health), 1))
		end
	end
end

function modifier_item_mordiggian_carapace_active:OnIntervalThink()
	local hpDrain = self:GetAbility():GetSpecialValueFor("active_health_drain") / 2
	local newHP = self:GetParent():GetHealth() - hpDrain
	if newHP < 1 then
		newHP = 1
	end
	self:GetParent():SetHealth(newHP)
end

