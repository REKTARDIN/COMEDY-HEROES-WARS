zeus_lightning_attacks = class({})
LinkLuaModifier(
    "modifier_zeus_lightning_attacks_passive",
    "abilities/zeus_lightning_attacks.lua",
    LUA_MODIFIER_MOTION_NONE
)
LinkLuaModifier(
    "modifier_zeus_lightning_attacks_stacks",
    "abilities/zeus_lightning_attacks.lua",
    LUA_MODIFIER_MOTION_NONE
)

function zeus_lightning_attacks:GetIntrinsicModifierName()
    return "modifier_zeus_lightning_attacks_passive"
end

modifier_zeus_lightning_attacks_passive = class({})

function modifier_zeus_lightning_attacks_passive:IsHidden()
    return true
end

function modifier_zeus_lightning_attacks_passive:IsPurgable()
    return false
end

function modifier_zeus_lightning_attacks_passive:IsPurgeException()
    return false
end

function modifier_zeus_lightning_attacks_passive:RemoveOnDeath()
    return false
end

function modifier_zeus_lightning_attacks_passive:DeclareFunctions()
    local decFuns = {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE
    }
    return decFuns
end

function modifier_zeus_lightning_attacks_passive:GetModifierProcAttack_BonusDamage_Magical(params)
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local bonus_damage = 0

        local maxstacks = ability:GetSpecialValueFor("max_stacks")
        local duration = ability:GetSpecialValueFor("stack_duration")

        if caster:HasModifier("modifier_zeus_lightning_attacks_stacks") then
            local stacks = caster:GetModifierStackCount("modifier_zeus_lightning_attacks_stacks", caster)
        else
            local stacks = 0
        end

        local target = params.target
        if target == nil then
            target = params.unit
        end

        if target:GetTeamNumber() == self:GetParent():GetTeamNumber() then
            return 0
        end

        if not self:GetParent():PassivesDisabled() and params.attacker == caster and not target:IsBuilding() then
            modifier =
                caster:AddNewModifier(caster, ability, "modifier_zeus_lightning_attacks_stacks", {duration = duration})

            if caster:GetModifierStackCount("modifier_zeus_lightning_attacks_stacks", caster) < maxstacks then
                modifier:IncrementStackCount()
            end

            if caster:GetModifierStackCount("modifier_zeus_lightning_attacks_stacks", caster) == maxstacks then
                bonus_damage = ability:GetSpecialValueFor("bonus_damage")
                caster:RemoveModifierByName("modifier_zeus_lightning_attacks_stacks")

                EmitSoundOn("Hero_Zeus.BlinkDagger.Arcana", target)

                local effect_cast =
                    ParticleManager:CreateParticle(
                    "particles/econ/items/storm_spirit/strom_spirit_ti8/storm_spirit_ti8_overload_active_e.vpcf",
                    PATTACH_ABSORIGIN_FOLLOW,
                    target
                )
                ParticleManager:SetParticleControl(effect_cast, 4, target:GetOrigin())
                ParticleManager:SetParticleControlForward(effect_cast, 3, target:GetOrigin())
                ParticleManager:SetParticleControlForward(effect_cast, 4, target:GetOrigin())
                ParticleManager:ReleaseParticleIndex(effect_cast)

                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, bonus_damage, nil)
            end
        end

        return bonus_damage
    end
end

function modifier_zeus_lightning_attacks_passive:GetModifierPreAttack_BonusDamage()
    local caster = self:GetParent()
    local armor = caster:GetPhysicalArmorValue(false)
    local armor_bonuses = self:GetAbility():GetSpecialValueFor("damage_bonus_per_armor")
    local armor_damage = armor * armor_bonuses

    return armor_damage
end

function modifier_zeus_lightning_attacks_passive:GetModifierSpellAmplify_Percentage()
    local caster = self:GetParent()
    local armor = caster:GetPhysicalArmorValue(false)
    local armor_bonuses = self:GetAbility():GetSpecialValueFor("amp_bonus_per_armor")
    local armor_amplification = armor * armor_bonuses

    return armor_amplification
end

function modifier_zeus_lightning_attacks_passive:GetModifierModelScale()
    local caster = self:GetParent()
    local armor = caster:GetPhysicalArmorValue(false)
    local armor_bonuses = 0.25
    local armor_model_scale = armor * armor_bonuses

    return armor_model_scale
end

function modifier_zeus_lightning_attacks_passive:GetActivityTranslationModifiers()
    if self:GetCaster():GetModifierStackCount("modifier_zeus_lightning_attacks_stacks", self:GetCaster()) == 3 then
        return
    else
        return nil
    end
end

modifier_zeus_lightning_attacks_stacks = class({})

function modifier_zeus_lightning_attacks_stacks:IsHidden()
    return false
end

function modifier_zeus_lightning_attacks_stacks:IsDebuff()
    return false
end

function modifier_zeus_lightning_attacks_stacks:IsPurgable()
    return false
end

function modifier_zeus_lightning_attacks_stacks:IsPurgeException()
    return false
end
