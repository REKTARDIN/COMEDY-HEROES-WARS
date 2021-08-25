collector_thunder_shock = class({})

LinkLuaModifier( "modifier_collector_thunder_shock", "abilities/collector_thunder_shock.lua", LUA_MODIFIER_MOTION_NONE )

function collector_thunder_shock:GetIntrinsicModifierName()
    return "modifier_collector_thunder_shock"
end

modifier_collector_thunder_shock = class({})

function modifier_collector_thunder_shock:IsHidden() return true end
function modifier_collector_thunder_shock:IsPermanent() return true end
function modifier_collector_thunder_shock:IsPurgable() return false end

function modifier_collector_thunder_shock:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

function modifier_collector_thunder_shock:OnTakeDamage( params )
    if IsServer() then
        if params.unit == self:GetParent() and self:GetAbility():IsCooldownReady() and RollPercentage(self:GetAbility():GetSpecialValueFor("chance")) then
            if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
                return 0
            end

            if params.damage_type ~= DAMAGE_TYPE_PHYSICAL then
                return 0 
            end

            local damage = self:GetAbility():GetAbilityDamage() + ((params.attacker:GetMaxMana() - params.attacker:GetMana()) * (self:GetAbility():GetSpecialValueFor("bonus_damage_mana_dfc") / 100))
            
            Util:DoAreaDamage(params.attacker, damage, self:GetParent():GetAbsOrigin(), self:GetAbility(), params.unit, DAMAGE_TYPE_PURE, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_DAMAGE_FLAG_REFLECTION)

            EmitSoundOn("Hero_KeeperOfTheLight.Wisp.Destroy", self:GetParent())

            local nFXIndex = ParticleManager:CreateParticle( "particles/heroes/hero_collector/collector_burst.vpcf", PATTACH_CUSTOMORIGIN, nil );
            ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin());
            ParticleManager:ReleaseParticleIndex( nFXIndex );

            self:GetAbility():UseResources(false, false, true)
        end
    end
end