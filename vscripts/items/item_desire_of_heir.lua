item_desire_of_heir = class({})

LinkLuaModifier ("modifier_item_desire_of_heir", "items/item_desire_of_heir.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_desire_of_heir_debuff", "items/item_desire_of_heir.lua", LUA_MODIFIER_MOTION_NONE)

function item_desire_of_heir:GetIntrinsicModifierName()
    return "modifier_item_desire_of_heir"
end

function item_desire_of_heir:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()

        caster:AddNewModifier(
            self:GetCaster(),
            self,
            "modifier_item_eternal_shroud_barrier",
            {duration = self:GetSpecialValueFor("barrier_duration")}
        )
    end
end

modifier_item_desire_of_heir = class({})

function modifier_item_desire_of_heir:IsHidden ()
    return true
end

function modifier_item_desire_of_heir:IsPurgable()
    return false
end

function modifier_item_desire_of_heir:IsPurgeException()
    return false
end

function modifier_item_desire_of_heir:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_desire_of_heir:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
        MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,

        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

function modifier_item_desire_of_heir:OnTakeDamage( params )
	if params.attacker == self:GetParent() and not params.unit:IsBuilding() and not params.unit:IsOther() then		
	
		if self:GetParent():FindAllModifiersByName(self:GetName())[1] == self and params.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and params.inflictor and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
			
			self.lifesteal_pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
			ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, params.attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
		
			if params.unit:IsIllusion() then
				if params.damage_type == DAMAGE_TYPE_PHYSICAL and params.unit.GetPhysicalArmorValue and GetReductionFromArmor then
					params.damage = params.original_damage * (1 - GetReductionFromArmor(params.unit:GetPhysicalArmorValue(false)))
				elseif params.damage_type == DAMAGE_TYPE_MAGICAL and params.unit.GetMagicalArmorValue then
					params.damage = params.original_damage * (1 - GetReductionFromArmor(params.unit:GetMagicalArmorValue()))
				elseif params.damage_type == DAMAGE_TYPE_PURE then
					params.damage = params.original_damage
				end
			end
			
			if params.unit:IsCreep() then
				params.attacker:Heal(math.max(params.damage, 0) * self:GetAbility():GetSpecialValueFor("spell_lifesteal_creep") * 0.01, params.attacker)
			else
				params.attacker:Heal(math.max(params.damage, 0) * self:GetAbility():GetSpecialValueFor("spell_lifesteal_hero") * 0.01, params.attacker)
			end
		end
	end
end

function modifier_item_desire_of_heir:GetModifierBonusStats_Intellect( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

function modifier_item_desire_of_heir:GetModifierMagicalResistanceBonus( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_magical_resistance" )
end

function modifier_item_desire_of_heir:GetModifierConstantHealthRegen( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_health_regen" )
end

function modifier_item_desire_of_heir:GetModifierPreAttack_BonusDamage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_damage" )
end

function modifier_item_desire_of_heir:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

function modifier_item_desire_of_heir:GetModifierConstantManaRegen( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" )
end

function modifier_item_desire_of_heir:GetModifierManaBonus( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_mana" )
end

function modifier_item_desire_of_heir:GetModifierHealthBonus( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_health" )
end

function modifier_item_desire_of_heir:GetModifierPercentageCasttime( params ) 
    return self:GetAbility():GetSpecialValueFor( "bonus_cast_time" ) 
end

function modifier_item_desire_of_heir:GetModifierPercentageManacost( params ) 
    return self:GetAbility():GetSpecialValueFor( "bonus_mana_cost" ) 
end

function modifier_item_desire_of_heir:IsAura()
    return true
end

function modifier_item_desire_of_heir:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_desire_of_heir:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_desire_of_heir:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_desire_of_heir:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_desire_of_heir:GetModifierAura()
    return "modifier_item_desire_of_heir_debuff"
end

modifier_item_desire_of_heir_debuff = class({})

function modifier_item_desire_of_heir_debuff:IsHidden ()
    return false
end

function modifier_item_desire_of_heir_debuff:IsPurgable()
    return false
end

function modifier_item_desire_of_heir_debuff:IsPurgeException()
    return false
end

function modifier_item_desire_of_heir_debuff:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }

return funcs
end

function modifier_item_desire_of_heir_debuff:GetModifierMagicalResistanceBonus( params )

    local resistance = self:GetAbility():GetSpecialValueFor("aura_magical_resistance_enemies")

    return resistance
end

function modifier_item_desire_of_heir_debuff:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end


