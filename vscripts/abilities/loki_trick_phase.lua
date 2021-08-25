LinkLuaModifier( "modifier_loki_trick_phase_thinker", "abilities/loki_trick_phase.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_loki_loki_trick_phase", "abilities/thanos_dying_star.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

loki_trick_phase = class({})

function loki_trick_phase:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local team_id = caster:GetTeamNumber()

        local thinker = CreateModifierThinker(caster, self, "modifier_loki_trick_phase_thinker", {duration = self:GetSpecialValueFor("fade_time")}, point, team_id, false)
        caster:AddNewModifier(caster, self, "modifier_manta_phase", {duration = self:GetSpecialValueFor("fade_time")})
    end
end


function loki_trick_phase:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function loki_trick_phase:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
end

modifier_loki_trick_phase_thinker = class ({})

function modifier_loki_trick_phase_thinker:OnCreated(event)
    if IsServer() then
        local thinker = self:GetParent()
        local ability = self:GetAbility()

        self.radius = ability:GetSpecialValueFor("radius")
        self.duration = ability:GetSpecialValueFor("duration")

        self.count = ability:GetSpecialValueFor("units") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_loki_3") or 0)

        for i = 1, self.count do
            local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_illlmove.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetAbsOrigin())
            ParticleManager:SetParticleControl( nFXIndex, 1, thinker:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end

        EmitSoundOn("Hero_PhantomLancer.PhantomEdge", thinker)

        GridNav:DestroyTreesAroundPoint(thinker:GetAbsOrigin(), self.radius, false)
    end
end

function modifier_loki_trick_phase_thinker:OnDestroy()
    if IsServer() then
        local caster = self:GetCaster()

        caster:RemoveModifierByName("modifier_phantomlancer_dopplewalk_phase")
        
        FindClearSpaceForUnit(caster, self:GetParent():GetAbsOrigin(), true)
        
        local illusions = CreateIllusions(caster, caster, {duraion = self.duration, outgoing_damage = self:GetAbility():GetSpecialValueFor("outgoing_damage"), incoming_damage = self:GetAbility():GetSpecialValueFor("incoming_damage")}, self.count, 0, true, true)

        Timers:CreateTimer(FrameTime(), function() 
            for _, illusion in pairs(illusions) do 
                illusion:MoveToPositionAggressive(caster:GetAbsOrigin())
                illusion:AddNewModifier(caster, self, "modifier_kill", {["duration"] = self.duration})
            end
        end)

        UTIL_Remove(self:GetParent())
    end
end
