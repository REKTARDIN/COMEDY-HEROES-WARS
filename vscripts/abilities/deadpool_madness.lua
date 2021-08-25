deadpool_madness = class({})
LinkLuaModifier("modifier_deadpool_madness", "abilities/deadpool_madness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_deadpool_madness_attack_speed", "abilities/deadpool_madness.lua", LUA_MODIFIER_MOTION_NONE)

function deadpool_madness:GetCastRange(vLocation, hTarget)
    return self:GetCaster():Script_GetAttackRange()
end

function deadpool_madness:GetIntrinsicModifierName()
    return "modifier_deadpool_madness_attack_speed"
end

function deadpool_madness:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function deadpool_madness:OnUpgrade()
    if IsServer() then
        if self and not self:IsNull() and self:GetLevel() <= 1 then
            self:SetActivated(false)
        end
    end
end

function deadpool_madness:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local damage = self:GetSpecialValueFor("damage")
    local threshold = self:GetSpecialValueFor("health_threshold")
    local duration = self:GetSpecialValueFor("duration")

    if target:TriggerSpellAbsorb(self) then
        return nil
    end

    if target:GetHealth() <= threshold and target:IsHero() then
        target:Kill(self, caster)

        caster:AddNewModifier(caster, self, "modifier_deadpool_madness", {duration = duration})

        self:EndCooldown()

        EmitSoundOn("hero_bloodseeker.bloodRite.silence", caster)
        EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace ", caster)
    else
        local damage = {  victim = target,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self }

        ApplyDamage(damage)

        EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace ", caster)
    end

    local modifier = caster:FindModifierByName("modifier_deadpool_madness_attack_speed")

    if modifier then
        modifier:SetStackCount(1)
    end

    local execute_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControlEnt(execute_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(execute_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(execute_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(execute_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(execute_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(execute_particle)

    local blood_particle = ParticleManager:CreateParticle ("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_CUSTOMORIGIN, caster);
    ParticleManager:SetParticleControlEnt (blood_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin (), true);
    ParticleManager:ReleaseParticleIndex (blood_particle);
end
--------------------------------------------------------------------------------------------------------------
modifier_deadpool_madness = class({})
function modifier_deadpool_madness:IsHidden() return false end
function modifier_deadpool_madness:IsPurgable() return true end
function modifier_deadpool_madness:IsPurgeException() return true end
function modifier_deadpool_madness:RemoveOnDeath() return true end
function modifier_deadpool_madness:DeclareFunctions()
    local func = {  MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
    return func
end

function modifier_deadpool_madness:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_deadpool_madness:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_deadpool_madness_attack_speed = class({})
function modifier_deadpool_madness_attack_speed:IsHidden() return false end
function modifier_deadpool_madness_attack_speed:IsDebuff() return false end
function modifier_deadpool_madness_attack_speed:IsPurgable() return false end
function modifier_deadpool_madness_attack_speed:IsPurgeException() return false end
function modifier_deadpool_madness_attack_speed:RemoveOnDeath() return false end
function modifier_deadpool_madness_attack_speed:DeclareFunctions()
    local func = {  MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    return func
end
function modifier_deadpool_madness_attack_speed:OnAttackLanded(params)
    if not IsServer() then
        return nil
    end

    if params.attacker ~= self:GetParent() then
        return nil
    end

    if params.target == self:GetParent() then
        return nil
    end

    if not self.old_target then
        self.old_target = params.target
    end

    if self.old_target == params.target then
        if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
            self:IncrementStackCount()
        end
    else
        self:SetStackCount(0)
    end

    self.old_target = params.target

end

function modifier_deadpool_madness_attack_speed:GetModifierAttackSpeedBonus_Constant()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("as"))
end

function modifier_deadpool_madness_attack_speed:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_deadpool_madness_attack_speed:OnIntervalThink()
    if IsServer() then
        if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("need_stacks") then
            self:GetAbility():SetActivated(true)
        else
            self:GetAbility():SetActivated(false)
        end
    end
end
