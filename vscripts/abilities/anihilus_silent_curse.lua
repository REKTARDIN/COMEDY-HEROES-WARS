anihilus_silent_curse = class({})

LinkLuaModifier("modifier_anihilus_silent_curse_buff", "abilities/anihilus_silent_curse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(
    "modifier_anihilus_silent_curse_debuff",
    "abilities/anihilus_silent_curse.lua",
    LUA_MODIFIER_MOTION_NONE
)

function anihilus_silent_curse:GetIntrinsicModifierName()
    return "modifier_anihilus_silent_curse_buff"
end

function anihilus_silent_curse:CreateProjectile(hTarget)
    local info = {
        EffectName = self:GetCaster():GetRangedProjectileName(),
        Ability = self,
        iMoveSpeed = self:GetCaster():GetProjectileSpeed(),
        Source = self:GetCaster(),
        Target = hTarget,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
        bDodgeable = false, -- Optional
        bIsAttack = true, -- Optional
        bVisibleToEnemies = true -- Optional
    }

    ProjectileManager:CreateTrackingProjectile(info)

    EmitSoundOn("Hero_ArcWarden.Flux.Target", self:GetCaster())
end

function anihilus_silent_curse:OnSpellStart()
    local hTarget = self:GetCursorTarget()
    if hTarget ~= nil then
        if (not hTarget:TriggerSpellAbsorb(self)) then
            self:CreateProjectile(hTarget)
        end
    end
end

function anihilus_silent_curse:OnProjectileHit(hTarget, vLocation)
    if hTarget ~= nil and (not hTarget:IsInvulnerable()) and (not hTarget:IsMagicImmune()) then
        EmitSoundOn("Hero_ArcWarden.SparkWraith.Damage", hTarget)

        local debuff_duration = self:GetSpecialValueFor("debuff_duration")
        local damage = self:GetSpecialValueFor("damage")

        local damage = {
            victim = hTarget,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }

        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_anihilus_silent_curse_debuff", {duration = debuff_duration})

        print(debuff_duration)

        ApplyDamage(damage)
    end

    return true
end

modifier_anihilus_silent_curse_buff =
    class(
    {
        IsHidden = function()
            return true
        end,
        IsPurgable = function()
            return false
        end,
        DeclareFunctions = function()
            return {MODIFIER_EVENT_ON_ATTACK_LANDED}
        end
    }
)

function modifier_anihilus_silent_curse_buff:OnAttackLanded(params)
    if not IsServer() then
        return
    end
    if params.attacker:IsRealHero() and params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() and
        self:GetAbility():IsOwnersManaEnough() and
        self:GetAbility():GetAutoCastState() and
        (not (params.target:IsMagicImmune() or params.target:IsAncient() or params.target:IsBuilding()))
    then
        self:GetAbility():UseResources(true, false, true)
        self:GetAbility():CreateProjectile(params.target)
    end
end

modifier_anihilus_silent_curse_debuff =
    class(
    {
        IsPurgable = function()
            return true
        end,
        IsHidden = function()
            return false
        end,
        GetEffectName = function()
            return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
        end,
        GetEffectAttachType = function()
            return PATTACH_ABSORIGIN_FOLLOW
        end,
        GetAttributes = function()
            return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
        end,
        DeclareFunctions = function()
            return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
        end
    }
)

function modifier_anihilus_silent_curse_debuff:OnAbilityFullyCast(params)
    if (not IsServer()) or (not params.unit == self:GetParent()) then
        return
    end

    if self.applied then
        return
    end

    self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_silenced", {duration = self:GetAbility():GetSpecialValueFor("silence_duration")})

    local nFXIndex =
        ParticleManager:CreateParticle(
        "particles/econ/items/oracle/oracle_ti10_immortal/oracle_ti10_immortal_purifyingflames_hit.vpcf",
        PATTACH_CUSTOMORIGIN,
        nil
    )

    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self:GetAbility():GetSpecialValueFor("damage"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self
    })

    ParticleManager:SetParticleControl(
        nFXIndex,
        0,
        self:GetParent():GetOrigin()
    )

    ParticleManager:ReleaseParticleIndex(nFXIndex)

    EmitSoundOn("Hero_ArcWarden.SparkWraith.Activate", self:GetCaster())

    self.applied = true
end
