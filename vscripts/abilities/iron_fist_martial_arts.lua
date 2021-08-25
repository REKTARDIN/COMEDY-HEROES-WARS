iron_fist_martial_arts = class({})

LinkLuaModifier("modifier_iron_fist_martial_arts", "abilities/iron_fist_martial_arts.lua", LUA_MODIFIER_MOTION_NONE)

function iron_fist_martial_arts:GetIntrinsicModifierName()
    return "modifier_iron_fist_martial_arts"
end

function iron_fist_martial_arts:GetAbilityTextureName()
    local caster = self:GetCaster()
    local stacks = caster:GetModifierStackCount("modifier_iron_fist_martial_arts", caster)
    if stacks == 1 then
        return "custom/iron_fist_muay_thai"
    elseif stacks == 2 then
        return "custom/iron_fist_kung_fu"
    end

    return self.BaseClass.GetAbilityTextureName(self)
end

function iron_fist_martial_arts:OnSpellStart()
    local caster = self:GetCaster()

    local modifier = caster:FindModifierByNameAndCaster("modifier_iron_fist_martial_arts", caster)

    if modifier and not modifier:IsNull() then

        local stacks = modifier:GetStackCount()

        if stacks >= 2 then
            modifier:SetStackCount(0)
        else
            modifier:IncrementStackCount()
        end

        EmitSoundOn("", caster)
    end
end
---------------------------------------------------------------------------------------------------------------------
modifier_iron_fist_martial_arts = class({})
function modifier_iron_fist_martial_arts:IsHidden() return true end
function modifier_iron_fist_martial_arts:IsDebuff() return false end
function modifier_iron_fist_martial_arts:IsPurgable() return false end
function modifier_iron_fist_martial_arts:IsPurgeException() return false end
function modifier_iron_fist_martial_arts:RemoveOnDeath() return false end
function modifier_iron_fist_martial_arts:DeclareFunctions()
    local func = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,

        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,

        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,

        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return func
end

function modifier_iron_fist_martial_arts:OnCreated(table)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.agi = self.ability:GetSpecialValueFor("agi") ---karate
    self.str = self.ability:GetSpecialValueFor("str") ---muay thai
    self.int = self.ability:GetSpecialValueFor("int") ---kung fu

    self.ms = self.ability:GetSpecialValueFor("ms") ---karate
    self.as = self.ability:GetSpecialValueFor("as") ---muay thai
    self.evasion = self.ability:GetSpecialValueFor("evasion") ---kung fu

    if IsServer() then
        if not self.spawn then

            self.spawn = true

            self:SetStackCount(0)
        end
    end
end

function modifier_iron_fist_martial_arts:OnRefresh(table)
    self:OnCreated(table)
end

function modifier_iron_fist_martial_arts:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() then
        if self:GetStackCount() == 0  and self:GetStackCount() ~= 1 and self:GetStackCount() ~= 2 then


            if params.attacker ~= self:GetParent() then
                return nil
            end

            if params.target == self:GetParent() then
                return nil
            end

            if params.target:IsBuilding() then
                return nil
            end

            if RollPercentage(self:GetAbility():GetSpecialValueFor("karate_crit_chance")) and self:GetAbility() then

                return self:GetAbility():GetSpecialValueFor("karate_crit_multi")
            end
        end
    end
end

function modifier_iron_fist_martial_arts:OnAttackLanded(params)
    if IsServer() then
        if self:GetStackCount() == 1 and self:GetStackCount() ~= 0 and self:GetStackCount() ~= 2 then

            if params.attacker ~= self:GetParent() then
                return nil
            end

            if params.target == self:GetParent() then
                return nil
            end

            if params.target:IsBuilding() then
                return nil
            end

            if RollPercentage(self:GetAbility():GetSpecialValueFor("muay_thai_bash_chance")) and self:GetAbility() then

                params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_stunned", {duration = self:GetAbility():GetSpecialValueFor("muay_thai_bash_duration")})

                EmitSoundOn("Hero_EmberSpirit.SleightOfFist.Cast", self:GetParent())
            end
        end
    end
end

function modifier_iron_fist_martial_arts:GetModifierPhysical_ConstantBlock()
    if IsServer() then
        if self:GetStackCount() == 2 and self:GetStackCount() ~= 0 and self:GetStackCount() ~= 1 then
            
            if RollPercentage(self:GetAbility():GetSpecialValueFor("kung_fu_block_chance")) then

                return self:GetAbility():GetSpecialValueFor("kung_fu_block")
            end
        end
    end
end

function modifier_iron_fist_martial_arts:GetModifierBonusStats_Agility()
    if self:GetStackCount() ~= 0 then
        return nil
    end

    return self.agi
end

function modifier_iron_fist_martial_arts:GetModifierBonusStats_Strength()
    if self:GetStackCount() ~= 1 then
        return nil
    end

    return self.str
end

function modifier_iron_fist_martial_arts:GetModifierBonusStats_Intellect()
    if self:GetStackCount() ~= 2 then
        return nil
    end

    return self.int
end

function modifier_iron_fist_martial_arts:GetModifierMoveSpeedBonus_Constant()
    if self:GetStackCount() ~= 0 then
        return nil
    end

    return self.ms
end

function modifier_iron_fist_martial_arts:GetModifierAttackSpeedBonus_Constant()
    if self:GetStackCount() ~= 1 then
        return nil
    end

    return self.as
end

function modifier_iron_fist_martial_arts:GetModifierEvasion_Constant()
    if self:GetStackCount() ~= 2 then
        return nil
    end

    return self.evasion
end

function modifier_iron_fist_martial_arts:OnStackCountChanged(iStackCount)
    if IsServer() then
        self.parent:CalculateStatBonus(true)
        self:ForceRefresh()
    end
end
