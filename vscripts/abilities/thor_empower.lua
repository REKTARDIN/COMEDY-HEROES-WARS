thor_empower = class({})

LinkLuaModifier("modifier_thor_empower_passive", "abilities/thor_empower.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thor_empower_active", "abilities/thor_empower.lua", LUA_MODIFIER_MOTION_NONE)

function thor_empower:GetIntrinsicModifierName()
    return "modifier_thor_empower_passive"
end

function thor_empower:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function thor_empower:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local target = self:GetCursorTarget()
    local  duration = ability:GetSpecialValueFor("duration")
    local targetab = target:GetAbsOrigin()
    if not target:TriggerSpellAbsorb(ability) then
        local casterOrigin = caster:GetAbsOrigin()
        local direction = targetab - casterOrigin
        direction = direction / direction:Length2D()
        FindClearSpaceForUnit(caster, targetab + direction * -100, false)
        caster:AddNewModifier(caster, self, "modifier_thor_empower_active", {duration = self:GetSpecialValueFor("duration")})
        self:GetCaster():EmitSound("Hero_Zuus.LightningBolt")
    end
end

modifier_thor_empower_passive = class({
    IsHidden = function() return false end,
    IsPurgable = function() return false end,
    GetAttributes = function() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
})

function modifier_thor_empower_passive:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_thor_empower_passive:OnAttackLanded(params)
    if params.attacker == self:GetParent() then
        local stack = self:GetStackCount()
        local max = self:GetAbility():GetSpecialValueFor("attack_limit")
        self:SetStackCount(stack + 1)
        if self:GetStackCount() >= max then
            self:SetStackCount(0)
            self:GetCaster():EmitSound("Hero_Zuus.LightningBolt")
            local caster = self:GetCaster()
            local ability = self:GetAbility()
            local target = params.target
            if caster:IsRangedAttacker() then
                local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius") + ability:GetSpecialValueFor("ranged_radius_bonus"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/storm_spirit/strom_spirit_ti8/storm_spirit_ti8_overload_active.vpcf", PATTACH_CUSTOMORIGIN, caster)
                ParticleManager:SetParticleControl( nFXIndex, 0, target:GetAbsOrigin())
                ParticleManager:SetParticleControl( nFXIndex, 2, target:GetAbsOrigin())
                ParticleManager:SetParticleControl( nFXIndex, 5, target:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(nFXIndex)
                for i,unit in ipairs(units) do
                    local start = ParticleManager:CreateParticle( "particles/econ/events/ti7/maelstorm_ti7.vpcf", PATTACH_CUSTOMORIGIN, nil );
                    ParticleManager:SetParticleControlEnt( start, 0, target, PATTACH_POINT_FOLLOW, "attach_attack", target:GetOrigin(), true );
                    ParticleManager:SetParticleControlEnt( start, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true );
                    ParticleManager:ReleaseParticleIndex( start );
                    local hpercent = ability:GetSpecialValueFor("damage_hp_percent") /100
                    if caster:HasTalent("special_bonus_unique_thor_2") then
                        hpercent = hpercent + (caster:FindTalentValue("special_bonus_unique_thor_1") / 100)
                    end
                    local damageta = {
                        ability = ability,
                        victim = unit,
                        attacker = caster,
                        damage = ability:GetSpecialValueFor("base_damage") + (unit:GetMaxHealth() * hpercent),
                        damage_type = ability:GetAbilityDamageType()
                    }

                    ApplyDamage(damageta)
                    SendOverheadEventMessage( self:GetCaster(), OVERHEAD_ALERT_BONUS_SPELL_DAMAGE , unit, math.floor( ability:GetSpecialValueFor("base_damage") + (unit:GetMaxHealth() * hpercent) ), nil )
                    unit:AddNewModifier(self:GetCaster(), ability, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun_duration") - (ability:GetSpecialValueFor("stun_duration") * unit:GetStatusResistance())})
                end
            else
                local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/storm_spirit/strom_spirit_ti8/storm_spirit_ti8_overload_active.vpcf", PATTACH_CUSTOMORIGIN, caster)
                ParticleManager:SetParticleControl( nFXIndex, 0, caster:GetAbsOrigin())
                ParticleManager:SetParticleControl( nFXIndex, 2, caster:GetAbsOrigin())
                ParticleManager:SetParticleControl( nFXIndex, 5, caster:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(nFXIndex)
                for i,unit in ipairs(units) do
                    local start = ParticleManager:CreateParticle( "particles/econ/events/ti7/maelstorm_ti7.vpcf", PATTACH_CUSTOMORIGIN, nil );
                    ParticleManager:SetParticleControlEnt( start, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack", self:GetParent():GetOrigin(), true );
                    ParticleManager:SetParticleControlEnt( start, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true );
                    ParticleManager:ReleaseParticleIndex( start );
                    local hpercent = ability:GetSpecialValueFor("damage_hp_percent") /100
                    if caster:HasTalent("special_bonus_unique_thor_2") then
                        hpercent = hpercent + (caster:FindTalentValue("special_bonus_unique_thor_1") / 100)
                    end
                    local damageta = {
                        ability = ability,
                        victim = unit,
                        attacker = caster,
                        damage = ability:GetSpecialValueFor("base_damage") + (unit:GetMaxHealth() * hpercent),
                        damage_type = ability:GetAbilityDamageType()
                    }

                    ApplyDamage(damageta)
                    SendOverheadEventMessage( self:GetCaster(), OVERHEAD_ALERT_BONUS_SPELL_DAMAGE , unit, math.floor( ability:GetSpecialValueFor("base_damage") + (unit:GetMaxHealth() * hpercent) ), nil )
                    unit:AddNewModifier(self:GetCaster(), ability, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun_duration") - (ability:GetSpecialValueFor("stun_duration") * unit:GetStatusResistance())})
                end
            end
        end
    end
end


modifier_thor_empower_active = class({
    IsHidden = function() return false end,
    IsPurgable = function() return false end,
    GetAttributes = function() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
})

function modifier_thor_empower_active:OnCreated()
    self:StartIntervalThink(1)
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    if not IsServer() then return end
    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/storm_spirit/strom_spirit_ti8/storm_spirit_ti8_overload_active.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl( nFXIndex, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( nFXIndex, 2, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( nFXIndex, 5, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(nFXIndex)
    self:GetCaster():EmitSound("Hero_Zuus.LightningBolt")
    for i,unit in ipairs(units) do
        local start = ParticleManager:CreateParticle( "particles/econ/events/ti7/maelstorm_ti7.vpcf", PATTACH_CUSTOMORIGIN, nil );
        ParticleManager:SetParticleControlEnt( start, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack", self:GetParent():GetOrigin(), true );
        ParticleManager:SetParticleControlEnt( start, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true );
        ParticleManager:ReleaseParticleIndex( start );
        local hpercent = ability:GetSpecialValueFor("damage_hp_percent") /100
        if caster:HasTalent("special_bonus_unique_thor_1") then
            hpercent = hpercent + (caster:FindTalentValue("special_bonus_unique_thor_1") / 100)
        end
        local damageta = {
            ability = ability,
            victim = unit,
            attacker = caster,
            damage = ability:GetSpecialValueFor("base_damage") + (unit:GetMaxHealth() * hpercent),
            damage_type = ability:GetAbilityDamageType()
        }
        ApplyDamage(damageta)
        unit:AddNewModifier(self:GetCaster(), ability, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun_duration") - (ability:GetSpecialValueFor("stun_duration") * unit:GetStatusResistance())})
    end
    GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), ability:GetSpecialValueFor("radius"), false)
end

function modifier_thor_empower_active:OnIntervalThink()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    if not IsServer() then return end
    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/storm_spirit/strom_spirit_ti8/storm_spirit_ti8_overload_active.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl( nFXIndex, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( nFXIndex, 2, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( nFXIndex, 5, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(nFXIndex)
    self:GetCaster():EmitSound("Hero_Zuus.LightningBolt")
    for i,unit in ipairs(units) do
        local start = ParticleManager:CreateParticle( "particles/econ/events/ti7/maelstorm_ti7.vpcf", PATTACH_CUSTOMORIGIN, nil );
        ParticleManager:SetParticleControlEnt( start, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack", self:GetParent():GetOrigin(), true );
        ParticleManager:SetParticleControlEnt( start, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true );
        ParticleManager:ReleaseParticleIndex( start );
        local hpercent = ability:GetSpecialValueFor("damage_hp_percent") /100
        if caster:HasTalent("special_bonus_unique_thor_1") then
            hpercent = hpercent + (caster:FindTalentValue("special_bonus_unique_thor_1") / 100)
        end
        local damageta = {
            ability = ability,
            victim = unit,
            attacker = caster,
            damage = ability:GetSpecialValueFor("base_damage") + (unit:GetMaxHealth() * hpercent),
            damage_type = ability:GetAbilityDamageType()
        }

        ApplyDamage(damageta)
        unit:AddNewModifier(self:GetCaster(), ability, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun_duration") - (ability:GetSpecialValueFor("stun_duration") * unit:GetStatusResistance())})
    end
    GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), ability:GetSpecialValueFor("radius"), false)
end
