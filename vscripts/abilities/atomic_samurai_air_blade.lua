LinkLuaModifier ("modifier_atomic_samurai_air_blade", "abilities/atomic_samurai_air_blade.lua", LUA_MODIFIER_MOTION_NONE)

atomic_samurai_air_blade = class({})

function atomic_samurai_air_blade:GetIntrinsicModifierName()
    return "modifier_atomic_samurai_air_blade"
end

function atomic_samurai_air_blade:CreateShockwave(hTarget)
    if IsServer() then
        self.damage = (self:GetCaster():GetAverageTrueAttackDamage(hTarget) * self:GetSpecialValueFor("shockwave_damage") * 0.01) + self:GetSpecialValueFor("shockwave_base_damage")

        local vDirection = hTarget:GetAbsOrigin() - self:GetCaster():GetOrigin()
        vDirection = vDirection:Normalized()

        local info = {
            EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
            Ability = self,
            vSpawnOrigin = self:GetCaster():GetOrigin(),
            fStartRadius = self:GetSpecialValueFor( "shock_width" ),
            fEndRadius = self:GetSpecialValueFor( "shock_width" ),
            vVelocity = vDirection *  self:GetSpecialValueFor( "shock_speed" ),
            fDistance = self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() ),
            Source = self:GetCaster(),
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            bProvidesVision = false
        }

        ProjectileManager:CreateLinearProjectile( info )

        EmitSoundOn( "Hero_Magnataur.ShockWave.Cast.Anvil" , self:GetCaster() )

        self:UseResources(false, false, true)
    end
end

--------------------------------------------------------------------------------

function atomic_samurai_air_blade:OnProjectileHit( hTarget, vLocation )
    if hTarget ~= nil then
        local damage = {
            victim = hTarget,
            attacker = self:GetCaster(),
            damage = self.damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = this,
        }

        ApplyDamage( damage )
    end

    return false
end

--------------------------------------------------------------------------------

modifier_atomic_samurai_air_blade = class({})

function modifier_atomic_samurai_air_blade:IsHidden() return true end
function modifier_atomic_samurai_air_blade:IsPurgable() return false end

function modifier_atomic_samurai_air_blade:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_atomic_samurai_air_blade:OnCreated(params)
    if IsServer() then

        self.chance = self:GetAbility():GetSpecialValueFor("shockwave_chance")

        if self:GetParent():HasModifier("modifier_atomic_samurai_atomic_slash") then
            self.chance = self.chance * 2
        end
    end
end

function modifier_atomic_samurai_air_blade:OnRefresh(params)
    if IsServer() then

        self.chance = self:GetAbility():GetSpecialValueFor("shockwave_chance")

        if self:GetParent():HasModifier("modifier_atomic_samurai_atomic_slash") then
            self.chance = self.chance * 2
        end
    end
end

function modifier_atomic_samurai_air_blade:OnAttackLanded(params)
    if IsServer() then

        if params.attacker ~= self:GetParent() then
            return nil
        end

        if params.target == self:GetParent() then
            return nil
        end

        if params.target:IsBuilding() then
            return nil
        end

        if RollPercentage(self.chance) and self:GetAbility() then

            self:GetAbility():CreateShockwave(params.target)

            EmitSoundOn("Hero_EmberSpirit.SleightOfFist.Cast", self:GetParent())
        end
    end
end
