atomic_samurai_atomic_slash = class({})

LinkLuaModifier("modifier_atomic_samurai_atomic_slash", "abilities/atomic_samurai_atomic_slash.lua",LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier("modifier_atomic_samurai_atomic_slash_damage", "abilities/atomic_samurai_atomic_slash.lua",LUA_MODIFIER_MOTION_NONE )

function atomic_samurai_atomic_slash:GetAOERadius()
    return self:GetSpecialValueFor("distance") + self:GetCaster():GetCastRangeBonus()
end

function atomic_samurai_atomic_slash:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    caster:AddNewModifier(caster, self, "modifier_atomic_samurai_atomic_slash", {})
end

modifier_atomic_samurai_atomic_slash = class({})

function modifier_atomic_samurai_atomic_slash:IsHidden() 
    return true 
end

function modifier_atomic_samurai_atomic_slash:IsDebuff() 
    return false 
end

function modifier_atomic_samurai_atomic_slash:IsPurgable() 
    return false 
end

function modifier_atomic_samurai_atomic_slash:IsPurgeException() 
    return false 
end

function modifier_atomic_samurai_atomic_slash:RemoveOnDeath() 
    return true 
end

function modifier_atomic_samurai_atomic_slash:GetPriority() 
    return MODIFIER_PRIORITY_HIGH 
end

function modifier_atomic_samurai_atomic_slash:GetMotionPriority() 
    return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH 
end

function modifier_atomic_samurai_atomic_slash:GetEffectName() 
    return "atomic_samurai_trail.vpcf" 
end

function modifier_atomic_samurai_atomic_slash:CheckState()
    local state =   {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }

    return state
end

function modifier_atomic_samurai_atomic_slash:DeclareFunctions()
    local func = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}

    return func
end

function modifier_atomic_samurai_atomic_slash:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_7
end

function modifier_atomic_samurai_atomic_slash:OnCreated(table)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    if IsServer() then
        self.speed = self.ability:GetSpecialValueFor("speed")
        self.distance = self.ability:GetAOERadius()
        self.damage = self.ability:GetSpecialValueFor("damage")

        self.crit = self.ability:GetSpecialValueFor("crit")
        self.delay_duration = self.ability:GetSpecialValueFor("delay_duration")

        self.second_targets_damage = self.ability:GetSpecialValueFor("second_targets_damage") * 0.01

        self.point = self.ability:GetCursorPosition() + RandomVector(1)
        self.direction = (self.point - self.parent:GetAbsOrigin()):Normalized()
        self.direction.z = 0
        self.point = self.parent:GetAbsOrigin() + self.direction * self.distance

        self.AttackedTargets = {}
        self.FirstTarget = nil

        self.trail = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_serrakura/juggernaut_omni_slash_flash_serrakura.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.parent)
        ParticleManager:SetParticleControlEnt(self.trail, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", self.parent:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.trail, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", self.parent:GetAbsOrigin(), true)

        self:AddParticle(self.trail, false, false, -1, false, false)

        EmitSoundOn("Hero_StormSpirit.ElectricVortexCast", self.parent)
        EmitSoundOn("Hero_StormSpirit.Orchid_BallLightning", self.parent)

        if self:ApplyHorizontalMotionController() == false then
            self:Destroy()
        end
    end
end

function modifier_atomic_samurai_atomic_slash:OnRefresh(table)
    self:OnCreated(table)
end

function modifier_atomic_samurai_atomic_slash:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() then
        if params.attacker == self.parent then
            local crit = (self.FirstTarget == params.target) and self.crit or (self.crit * self.second_targets_damage)

            return crit
        end
    end
end

function modifier_atomic_samurai_atomic_slash:GetModifierProcAttack_BonusDamage_Physical(params)
    if IsServer() then
        if params.attacker == self.parent then
            local damage =  (self.FirstTarget == params.target) and self.damage or (self.damage * self.second_targets_damage)

            return damage
        end
    end
end

function modifier_atomic_samurai_atomic_slash:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        if self.parent:IsStunned() then
            return nil
        end

        if self.distance >= 0 then
            local units_per_dt = self.speed * dt
            local parent_pos = self.parent:GetAbsOrigin()

            local next_pos = parent_pos + self.direction * units_per_dt
            local distance_will = self.distance - units_per_dt

            if distance_will < 0 then
                next_pos = self.point
            end

            self.parent:SetOrigin(next_pos)
            self.parent:FaceTowards(self.point)

            self:PlayEffects()

            self.distance = self.distance - units_per_dt
        else
            self:Destroy()
        end
    end
end

function modifier_atomic_samurai_atomic_slash:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end

function modifier_atomic_samurai_atomic_slash:OnDestroy()
    if IsServer() then
        self.parent:InterruptMotionControllers(true)
    end
end

function modifier_atomic_samurai_atomic_slash:PlayEffects()
    local enemies = FindUnitsInRadius(  
        self.parent:GetTeamNumber(),
        self.parent:GetAbsOrigin(),
        nil,
        self.parent:Script_GetAttackRange(),
        self.ability:GetAbilityTargetTeam(),
        self.ability:GetAbilityTargetType(),
        self.ability:GetAbilityTargetFlags(),
        FIND_CLOSEST,
        false)

    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() and IsValidEntity(enemy) and enemy ~= self.parent and not self.AttackedTargets[enemy:entindex()] then
            self.AttackedTargets[enemy:entindex()] = true

            if not self.FirstTarget then
                enemy:AddNewModifier(self.parent, self.ability, "modifier_stunned", {duration = self.delay_duration})
                enemy:AddNewModifier(self.parent, self.ability, "modifier_atomic_samurai_atomic_slash_damage", {duration = self.delay_duration})

                self.FirstTarget = enemy
            end

            self.parent:PerformAttack(enemy, true, true, true, true, false, false, true)
        end
    end
end
---------------------------------------------------------------------------------------------------------------------
modifier_atomic_samurai_atomic_slash_damage = class({})

function modifier_atomic_samurai_atomic_slash_damage:IsHidden()
    return true
end

function modifier_atomic_samurai_atomic_slash_damage:IsDebuff()
    return true
end

function modifier_atomic_samurai_atomic_slash_damage:IsPurgable()
    return false
end

function modifier_atomic_samurai_atomic_slash_damage:IsPurgeException()
    return false
end

function modifier_atomic_samurai_atomic_slash_damage:RemoveOnDeath()
    return true
end

function modifier_atomic_samurai_atomic_slash_damage:DeclareFunctions()
    local func = {MODIFIER_PROPERTY_AVOID_DAMAGE}

    return func
end

function modifier_atomic_samurai_atomic_slash_damage:GetModifierAvoidDamage(params)
    if IsServer() then
        if params.attacker == self.caster then
            if params.damage_type == DAMAGE_TYPE_PHYSICAL then
                self.damage_physical = self.damage_physical + params.original_damage
                self.physical_attacker = params.attacker or self.caster
            elseif params.damage_type == DAMAGE_TYPE_MAGICAL then
                self.damage_magical = self.damage_magical + params.original_damage
                self.magical_attacker = params.attacker or self.caster
            else
                self.damage_pure = self.damage_pure + params.original_damage
                self.pure_attacker = params.attacker or self.caster
            end
        end

        return 1
    end
end

function modifier_atomic_samurai_atomic_slash_damage:OnCreated(table)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.damage_physical = self.damage_physical or 0
    self.damage_magical = self.damage_magical or 0
    self.damage_pure = self.damage_pure or 0
end

function modifier_atomic_samurai_atomic_slash_damage:OnRefresh(table)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.damage_physical = self.damage_physical or 0
    self.damage_magical = self.damage_magical or 0
    self.damage_pure = self.damage_pure or 0
end

function modifier_atomic_samurai_atomic_slash_damage:OnDestroy()
    if IsServer() then
        if self.damage_physical and self.damage_physical > 0 and self.physical_attacker then
            local damage_table_physical =  {
                victim = self.parent,
                attacker = self.physical_attacker,
                damage = self.damage_physical,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
                ability = self.ability }

            ApplyDamage(damage_table_physical)
        end

        if self.damage_magical and self.damage_magical > 0 and self.magical_attacker then
            local damage_table_magical = {
                victim = self.parent,
                attacker = self.magical_attacker,
                damage = self.damage_magical,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
                ability = self.ability }

            ApplyDamage(damage_table_magical)
        end

        if self.damage_pure and self.damage_pure > 0 and self.pure_attacker then
            local damage_table_pure = {
                victim = self.parent,
                attacker = self.pure_attacker,
                damage = self.damage_pure,
                damage_type = DAMAGE_TYPE_PURE,
                damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
                ability = self.ability }

            ApplyDamage(damage_table_pure)
        end
    end
end
