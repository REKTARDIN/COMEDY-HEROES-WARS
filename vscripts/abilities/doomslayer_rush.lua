--------------------------------------------------------------------------------

doomslayer_rush = class({})

--------------------------------------------------------------------------------
-- Ability Start

function doomslayer_rush:Spawn()
    if IsServer() then
        self:SetThink( "OnIntervalThink", self, 0.25 )
    end
end

function doomslayer_rush:OnIntervalThink()
    if IsServer() then
        self:SetHidden(not self:GetCaster():HasModifier("modifier_doomslayer_doom"))
    end

    return 0.25
end

function doomslayer_rush:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()

	-- load data
	local min_dist = self:GetSpecialValueFor( "min_travel_distance" )
	local max_dist = self:GetSpecialValueFor( "max_travel_distance" )

	-- find destination
	local direction = (point-origin)
	local dist = math.max( math.min( max_dist, direction:Length2D() ), min_dist )
	direction.z = 0
	direction = direction:Normalized()

	local target = GetGroundPosition( origin + direction*dist, nil )

	-- teleport
    FindClearSpaceForUnit( caster, target, true )
    
    local sound_start = "Hero_VoidSpirit.AstralStep.Start"
	local sound_end = "Hero_VoidSpirit.AstralStep.End"

	-- Create Sound
	EmitSoundOnLocationWithCaster( origin, sound_start, self:GetCaster() )
	EmitSoundOnLocationWithCaster( target, sound_end, self:GetCaster() )
end
