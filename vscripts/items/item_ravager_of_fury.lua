item_ravager_of_fury = class({})

LinkLuaModifier("modifier_item_ravager_of_fury", "items/item_ravager_of_fury", LUA_MODIFIER_MOTION_NONE)

function item_ravager_of_fury:GetIntrinsicModifierName()
    return "modifier_item_ravager_of_fury"
end

function item_ravager_of_fury:GetCastRange(vLocation, hTarget)
    return self.BaseClass.GetCastRange(self, vLocation, hTarget)
end

function item_ravager_of_fury:OnSpellStart()
    local target = self:GetCursorTarget()

    if target.CutDown then
        target:CutDown(self:GetCaster():GetTeam())
    else
        UTIL_Remove(target)
    end
end
---------------------------------------------------------------------------------------------------------------------
modifier_item_ravager_of_fury = class({})

function modifier_item_ravager_of_fury:IsHidden() 
    return true 
end

function modifier_item_ravager_of_fury:IsPurgable() 
    return false 
end

function modifier_item_ravager_of_fury:IsPurgeException() 
    return false 
end

function modifier_item_ravager_of_fury:RemoveOnDeath() 
    return false 
end

function modifier_item_ravager_of_fury:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_ravager_of_fury:DeclareFunctions()
    local func = 	{
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
    }
    return func
end

function modifier_item_ravager_of_fury:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_ravager_of_fury:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_ravager_of_fury:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_ravager_of_fury:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_ravager_of_fury:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() then
        local chance = self:GetAbility():GetSpecialValueFor("crit_chance")
        
        if RollPercentage(chance) then
            
        local hTarget = params.target
            
        return self:GetAbility():GetSpecialValueFor("crit_multiplier")
        end
    end
end

function modifier_item_ravager_of_fury:OnCreated(hTable)

    self.caster  = self:GetCaster()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    self.MeleeBonusCreepDamage  = self.ability:GetSpecialValueFor("quelling_bonus")
    self.RangedBonusCreepDamage = self.ability:GetSpecialValueFor("quelling_bonus_ranged")

    self.cleave_damage 	= self.ability:GetSpecialValueFor("cleave_damage_percent") / 100
    self.cleave_width_start = self.ability:GetSpecialValueFor("cleave_starting_width")
    self.cleave_width_end = self.ability:GetSpecialValueFor("cleave_ending_width")
    self.cleave_distance = self.ability:GetSpecialValueFor("cleave_distance")
end

function modifier_item_ravager_of_fury:OnRefresh(hTable)
    self:OnCreated(hTable)
end

function modifier_item_ravager_of_fury:GetModifierProcAttack_BonusDamage_Physical(params)
    if IsServer()
        and self.parent ~= nil 
        and self.parent:IsRealHero() then

        local hTarget = params.target

        if hTarget ~= nil and hTarget:IsCreep() then 

        return self.parent:IsRangedAttacker()
            and self.RangedBonusCreepDamage
        or self.MeleeBonusCreepDamage
        end
    end
end

function modifier_item_ravager_of_fury:GetModifierProcAttack_Feedback(params)

    if IsServer() and self.parent:IsRealHero() and not self.parent:IsRangedAttacker() then

        local hTarget = params.target

            local UFilter = UnitFilter(	hTarget,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
                self.parent:GetTeamNumber())
                
            if UFilter == UF_SUCCESS then
                DoCleaveAttack(self.parent,
                    hTarget, 
                    self.ability, 
                    (params.original_damage * self.cleave_damage), 
                    self.cleave_width_start, 
                    self.cleave_width_end, 
                    self.cleave_distance, 
                    "particles/stygian/ravager_cleave.vpcf")

            EmitSoundOn("Hero_Sven.Layer.GodsStrength", self.parent)
            EmitSoundOn("Hero_Sven.Layer.GodsStrength", self.parent)
            EmitSoundOn("Hero_Sven.Layer.GodsStrength", self.parent)
        end
    end
end
