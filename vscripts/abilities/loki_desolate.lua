loki_desolate = class ( {})

function loki_desolate:Spawn()
    if IsServer() then self:SetLevel(1) end
end

function loki_desolate:GetIntrinsicModifierName () return "modifier_phantom_lancer_juxtapose" end
function loki_desolate:GetBehavior () return DOTA_ABILITY_BEHAVIOR_PASSIVE end
