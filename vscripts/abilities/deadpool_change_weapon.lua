deadpool_change_weapon = class({})
LinkLuaModifier("modifier_deadpool_change_weapon_melee", "abilities/deadpool_change_weapon.lua", LUA_MODIFIER_MOTION_NONE)

deadpool_change_weapon.gun = nil
deadpool_change_weapon.katana1 = nil
deadpool_change_weapon.katana2 = nil

function deadpool_change_weapon:GetAbilityTextureName()
    if IsServer() then
        if self:GetCaster():HasModifier("modifier_deadpool_change_weapon_melee") then
            return ""
        else
            return ""
        end
    end
end 

function deadpool_change_weapon:SwitchGun()
	self.gun:AddEffects(EF_NODRAW)
	self.katana1:AddEffects(EF_NODRAW)
	self.katana2:AddEffects(EF_NODRAW)

	self.gun:RemoveEffects(EF_NODRAW)
end

function deadpool_change_weapon:SwitchKatana()
	self.gun:AddEffects(EF_NODRAW)
	self.katana1:AddEffects(EF_NODRAW)
	self.katana2:AddEffects(EF_NODRAW)

	self.katana1:RemoveEffects(EF_NODRAW)
	self.katana2:RemoveEffects(EF_NODRAW)
end

function deadpool_change_weapon:OnSpawnedForFirstTime()
	if IsServer() then

        self.gun = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/deadppol/deagle2.vmdl"})
		self.gun:FollowEntity(self:GetCaster(), true)

		self.katana1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/deadppol/katana1.vmdl"})
		self.katana1:FollowEntity(self:GetCaster(), true)

        self.katana2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/deadppol/katana2.vmdl"})
		self.katana2:FollowEntity(self:GetCaster(), true)

		self.katana1:AddEffects(EF_NODRAW)
		self.katana2:AddEffects(EF_NODRAW)
	end
end

function deadpool_change_weapon:OnSpellStart()
    local caster = self:GetCaster()

    if not caster:HasModifier("modifier_deadpool_change_weapon_melee") then
        caster:AddNewModifier(caster, self, "modifier_deadpool_change_weapon_melee", {})
        caster:SwapAbilities("deadpool_tumble", "deadpool_circular_blow", false, true)
    else
        caster:RemoveModifierByName("modifier_deadpool_change_weapon_melee")
        caster:SwapAbilities("deadpool_tumble", "deadpool_circular_blow", true, false)
    end
end

modifier_deadpool_change_weapon_melee = class({})

function modifier_deadpool_change_weapon_melee:IsHidden() 
    return true 
end

function modifier_deadpool_change_weapon_melee:IsPurgable() 
    return false 
end

function modifier_deadpool_change_weapon_melee:IsPurgeException() 
    return false 
end

function modifier_deadpool_change_weapon_melee:RemoveOnDeath() 
    return false 
end

function modifier_deadpool_change_weapon_melee:AllowIllusionDuplicate() 
    return true 
end

function modifier_deadpool_change_weapon_melee:DeclareFunctions()
    local func = {  MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT ,                    
                    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
                    MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
                    MODIFIER_EVENT_ON_ATTACK_LANDED, }
                    
    return func
end

function modifier_deadpool_change_weapon_melee:GetModifierAttackRangeBonus()
    return -350
end

function modifier_deadpool_change_weapon_melee:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("attack_time")
end

function modifier_deadpool_change_weapon_melee:GetActivityTranslationModifiers()
	return "melee"
end

function modifier_deadpool_change_weapon_melee:OnCreated()
    if IsServer() then
        self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

        self:GetAbility():SwitchKatana()
        
        self:GetParent():SwapAbilities("deadpool_shot", "deadpool_madness", false, true)
    end
end

function modifier_deadpool_change_weapon_melee:OnDestroy()
    if IsServer() then
        self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

        self:GetAbility():SwitchGun()

        self:GetParent():SwapAbilities("deadpool_shot", "deadpool_madness", true, false)
    end
end
