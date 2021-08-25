loki_trough_space = class({})

function loki_trough_space:OnAbilityPhaseStart()
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_illlmove.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl( nFXIndex, 1, self:GetCursorPosition())
        ParticleManager:ReleaseParticleIndex(nFXIndex)

        EmitSoundOn("Hero_PhantomLancer.Death", self:GetCaster())
    end

    return true
end

function loki_trough_space:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOn("Hero_PhantomLancer.PhantomEdge", self:GetCaster())

    FindClearSpaceForUnit(caster, point, true)

    local units = self:GetCaster():FindAllIllusions()
    if units ~= nil then
        if #units > 0 then
            for _, unit in pairs(units) do
                FindClearSpaceForUnit(unit, point, true)
                unit:MoveToPositionAggressive(point)
            end
        end
    end
end