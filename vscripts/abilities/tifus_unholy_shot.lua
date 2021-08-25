tifus_unholy_shot = class({})
LinkLuaModifier("modifier_tifus_unholy_shot_gift_stack", "abilities/tifus_unholy_shot.lua", LUA_MODIFIER_MOTION_NONE)

function tifus_unholy_shot:GetIntrinsicModifierName()
    return "modifier_tifus_unholy_shot_gift_stack"
end

function tifus_unholy_shot:GetCastRange(Location, Target)

    local caster = self:GetCaster()
    local range = self:GetSpecialValueFor( "bonus_range" )
    return caster:GetBaseAttackRange() + range
end 

function tifus_unholy_shot:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function tifus_unholy_shot:OnSpellStart()

    local info = {
        EffectName = "particles/stygian/tifus/tifus_shot.vpcf",
        Ability = self,
        iMoveSpeed = 2100,
        vSpawnOrigin = self:GetCaster():GetAttachmentOrigin(1),
        Source = self:GetCaster(),
        Target = self:GetCursorTarget(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }

    ProjectileManager:CreateTrackingProjectile( info )

    EmitSoundOn( "Hero_Snapfire.Shotgun.Fire", self:GetCaster() )
end

--------------------------------------------------------------------------------

function tifus_unholy_shot:OnProjectileHit( hTarget, vLocation )
    if IsServer() then 
        if hTarget ~= nil and (not hTarget:IsInvulnerable()) and ( not hTarget:TriggerSpellAbsorb( self ) ) and (not hTarget:IsMagicImmune()) then
        local caster = self:GetCaster()
        local target = hTarget

        local stacks = caster:GetModifierStackCount("modifier_tifus_unholy_shot_gift_stack", caster)
        local creep_stacks = self:GetSpecialValueFor( "creep_stack" )
        local heroes_stacks = self:GetSpecialValueFor( "hero_stack" )
        local damage = self:GetSpecialValueFor( "base_shot_damage" )

            local damage = {
                victim = target,
                attacker = self:GetCaster(),
                damage = damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self
            }

        caster:PerformAttack(target, false, true, true, false, false, false, true)

        ApplyDamage(damage)
        
        if not target:IsAlive() then
            if target:IsRealHero() then
                caster:SetModifierStackCount("modifier_tifus_unholy_shot_gift_stack", caster, stacks + heroes_stacks)
            else
                caster:SetModifierStackCount("modifier_tifus_unholy_shot_gift_stack", caster, stacks + creep_stacks)
            end
        end        
    end
        return true
    end
end

modifier_tifus_unholy_shot_gift_stack = class({})
function modifier_tifus_unholy_shot_gift_stack:IsHidden() return false end
function modifier_tifus_unholy_shot_gift_stack:IsDebuff() return false end
function modifier_tifus_unholy_shot_gift_stack:IsPurgable() return false end
function modifier_tifus_unholy_shot_gift_stack:IsPurgeException() return false end
function modifier_tifus_unholy_shot_gift_stack:RemoveOnDeath() return false end
