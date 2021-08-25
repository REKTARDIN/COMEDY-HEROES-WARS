LinkLuaModifier( "modifier_item_dracula_gift", "items/item_dracula_gift.lua", LUA_MODIFIER_MOTION_NONE)				
LinkLuaModifier( "modifier_item_dracula_gift_aura", "items/item_dracula_gift.lua", LUA_MODIFIER_MOTION_NONE)
    
item_dracula_gift = class({}) 

function item_dracula_gift:GetAbilityTextureName()
    return "custom/vladmir_maw"
end

function item_dracula_gift:OnSpellStart()
	if IsServer() then 
		local caster = self:GetCaster()
		EmitSoundOn("DOTA_Item.Necronomicon.Activate", caster)

	    local summon_duration = self:GetSpecialValueFor("summon_duration")
	    local caster_loc = caster:GetAbsOrigin()
	    local caster_direction = caster:GetForwardVector()
	    local melee_summon_name = "npc_nosferatu_ghoul"
	    local ranged_summon_name = "npc_nosferatu_vampire"

	    local melee_loc = RotatePosition(caster_loc, QAngle(0, 30, 0), caster_loc + caster_direction * 180)
	    local ranged_loc = RotatePosition(caster_loc, QAngle(0, -30, 0), caster_loc + caster_direction * 180)

	    GridNav:DestroyTreesAroundPoint(caster_loc + caster_direction * 180, 180, false)

	    local melee_summon = CreateUnitByName(melee_summon_name, melee_loc, true, caster, caster, caster:GetTeam())
	    local ranged_summon = CreateUnitByName(ranged_summon_name, ranged_loc, true, caster, caster, caster:GetTeam())

	    melee_summon:SetControllableByPlayer(caster:GetPlayerID(), true)
	    melee_summon:AddNewModifier(caster, self, "modifier_kill", {duration = summon_duration})

	    ranged_summon:SetControllableByPlayer(caster:GetPlayerID(), true)
	    ranged_summon:AddNewModifier(caster, self, "modifier_kill", {duration = summon_duration})

	    local melee_ability_1 = melee_summon:FindAbilityByName("necronomicon_warrior_mana_burn")
	    local melee_ability_2 = melee_summon:FindAbilityByName("necronomicon_warrior_last_will")
	    local melee_ability_3 = melee_summon:FindAbilityByName("necronomicon_warrior_sight")
        local melee_ability_4 = melee_summon:FindAbilityByName("life_stealer_ghoul_frenzy")
        local melee_ability_5 = melee_summon:FindAbilityByName("night_stalker_hunter_in_the_night")

	    local ranged_ability_1 = ranged_summon:FindAbilityByName("necronomicon_archer_mana_burn")
	    local ranged_ability_2 = ranged_summon:FindAbilityByName("necronomicon_archer_aoe")
        local ranged_ability_3 = ranged_summon:FindAbilityByName("night_stalker_hunter_in_the_night")
        local ranged_ability_4 = ranged_summon:FindAbilityByName("nosferatu_dark_ascension")

	    melee_ability_1:SetLevel(3)
	    melee_ability_2:SetLevel(3)
	    melee_ability_3:SetLevel(1)
        melee_ability_4:SetLevel(4)
        melee_ability_5:SetLevel(4)

	    ranged_ability_1:SetLevel(3)
	    ranged_ability_2:SetLevel(3)
        ranged_ability_3:SetLevel(4)
        ranged_ability_4:SetLevel(1)
	end
end

function item_dracula_gift:GetIntrinsicModifierName()
    return "modifier_item_dracula_gift" 
end

modifier_item_dracula_gift = class({})

function modifier_item_dracula_gift:IsHidden()		
    return true 
end

function modifier_item_dracula_gift:IsPurgable()		
    return false 
end

function modifier_item_dracula_gift:RemoveOnDeath()	
    return false 
end

function modifier_item_dracula_gift:GetAttributes()	
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_dracula_gift:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end

function modifier_item_dracula_gift:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("strength_bonus")
end

function modifier_item_dracula_gift:IsAura()					
    return true 
end

function modifier_item_dracula_gift:IsAuraActiveOnDeath() 		
    return false 
end

function modifier_item_dracula_gift:GetAuraRadius()				
    return self:GetAbility():GetSpecialValueFor("aura_radius") 
end 

function modifier_item_dracula_gift:GetAuraSearchFlags()		
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE 
end

function modifier_item_dracula_gift:GetAuraSearchTeam()			
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end

function modifier_item_dracula_gift:GetAuraSearchType()			
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
end

function modifier_item_dracula_gift:GetModifierAura()				
    return "modifier_item_dracula_gift_aura" 
end

modifier_item_dracula_gift_aura = class({})

function modifier_item_dracula_gift_aura:IsPurgable() 
    return false 
end

function modifier_item_dracula_gift_aura:GetTexture()
    return "custom/vladmir_maw" end

function modifier_item_dracula_gift_aura:OnCreated(params)
   self.lifesteal_aura = self:GetAbility():GetSpecialValueFor("lifesteal_aura")
end

function modifier_item_dracula_gift_aura:OnDestroy()
    self.lifesteal_aura = self:GetAbility():GetSpecialValueFor("lifesteal_aura")
end


function modifier_item_dracula_gift_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS_UNIQUE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,

        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_item_dracula_gift_aura:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_aura")
end

function modifier_item_dracula_gift_aura:GetModifierPhysicalArmorBonusUnique()
    return self:GetAbility():GetSpecialValueFor("armor_aura")
end

function modifier_item_dracula_gift_aura:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("mana_regen_aura")
end

function modifier_item_dracula_gift_aura:OnTakeDamage( params )
    if params.attacker == self:GetParent() and not params.unit:IsBuilding() and params.unit:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
        if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then

            self.lifesteal_pfx = ParticleManager:CreateParticle("particles/stygian/bloodletter_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
            ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, params.attacker:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)

            params.attacker:Heal(params.damage * self.lifesteal_aura * 0.01, params.attacker)
        end
    end
end

