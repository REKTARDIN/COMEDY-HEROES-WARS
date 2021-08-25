atomic_samurai_focused_atomic_slash = class({})

LinkLuaModifier("modifier_atomic_samurai_focused_atomic_slash", "abilities/atomic_samurai_focused_atomic_slash.lua",LUA_MODIFIER_MOTION_NONE )


function atomic_samurai_focused_atomic_slash:GetAOERadius()
    return self:GetCaster():Script_GetAttackRange() + 50
end

function atomic_samurai_focused_atomic_slash:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb(self) then
        return nil
    end

    caster:AddNewModifier(caster, self, "modifier_atomic_samurai_focused_atomic_slash", {})
end
--------------------------------------------------------------------------------------------------------------
modifier_atomic_samurai_focused_atomic_slash = class({})

function modifier_atomic_samurai_focused_atomic_slash:IsHidden() 
    return false 
end

function modifier_atomic_samurai_focused_atomic_slash:IsPurgable() 
    return false 
end

function modifier_atomic_samurai_focused_atomic_slash:IsPurgeException()
    return false 
end

function modifier_atomic_samurai_focused_atomic_slash:RemoveOnDeath() 
    return true 
end

function modifier_atomic_samurai_focused_atomic_slash:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,}

    return state
end

function modifier_atomic_samurai_focused_atomic_slash:DeclareFunctions()
    local func = {  MODIFIER_PROPERTY_OVERRIDE_ANIMATION,}
    return func
end

function modifier_atomic_samurai_focused_atomic_slash:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_6
end

function modifier_atomic_samurai_focused_atomic_slash:OnCreated()
    if IsServer() then
        self.radius = self:GetAbility():GetAOERadius()

        self.target = self:GetAbility():GetCursorTarget()

        self.bonus_slashes = math.floor(self:GetParent():GetAttacksPerSecond())

        self.slashes = self:GetAbility():GetSpecialValueFor("slashes") + self.bonus_slashes

        self.base_damage = self:GetAbility():GetSpecialValueFor("base_damage")

        self.trail = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.trail, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.trail, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)

        self:AddParticle(self.trail, false, false, -1, false, false)

        self.trail2 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_slash_trail.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.trail2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.trail2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)

        self:AddParticle(self.trail2, false, false, -1, false, false)

        EmitSoundOn("", self:GetParent())

        FindClearSpaceForUnit(self:GetParent(), self.target:GetAbsOrigin(), true)

        self:StartIntervalThink(0.2)
    end
end

function modifier_atomic_samurai_focused_atomic_slash:OnDestroy()
    if IsServer() then

    end
end

function modifier_atomic_samurai_focused_atomic_slash:OnIntervalThink()
    if IsServer() then
        if self.slashes <= 0 then
            self:Destroy()
        end

        if not self.target then
            self:Destroy()
            return nil
        end

        if not self.target:IsAlive() then
            self:Destroy()
            return nil
        end

        if self.target:IsNull() then
            self:Destroy()
            return nil
        end

        FindClearSpaceForUnit(self:GetParent(), self.target:GetAbsOrigin(), true)

        local enemies = FindUnitsInRadius(  self:GetParent():GetTeamNumber(),
            self:GetParent():GetAbsOrigin(),
            nil,
            self.radius,
            self:GetAbility():GetAbilityTargetTeam(),
            self:GetAbility():GetAbilityTargetType(),
            self:GetAbility():GetAbilityTargetFlags(),
            FIND_ANY_ORDER,
            false)

        for _,enemy in pairs(enemies) do
            local damage_table = {  victim = enemy,
                attacker = self:GetParent(),
                damage = self.base_damage,
                damage_type = self:GetAbility():GetAbilityDamageType(),
                ability = self:GetAbility() }

            ApplyDamage(damage_table)

            self:GetParent():PerformAttack(enemy, true, false, true, true, false, false, true)
        end

        self.slashes = self.slashes - 1
    end
end
