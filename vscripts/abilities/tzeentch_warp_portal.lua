--------------------------------------------------------------------------------

tzeentch_warp_portal = class({})

--------------------------------------------------------------------------------
-- Init Abilities
function tzeentch_warp_portal:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_void_spirit.vsndevts", context )
    PrecacheResource( "particle", "particles/econ/events/ti10/portal/portal_open_good.vpcf", context )
    PrecacheResource( "particle", "particles/econ/events/ti10/portal/portal_open_good_parent.vpcf", context )
end

LinkLuaModifier( "modifier_tzeentch_warp_portal", "abilities/tzeentch_warp_portal", LUA_MODIFIER_MOTION_HORIZONTAL )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function tzeentch_warp_portal:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------

function tzeentch_warp_portal:Spawn()
    if IsServer() then
        self:SetLevel(1)
    end
end

--------------------------------------------------------------------------------
-- Ability Start
function tzeentch_warp_portal:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local phase = self:GetSpecialValueFor( "phase_duration" )
    
    caster:AddNewModifier(
        caster, -- player source
        self, -- ability source
        "modifier_tzeentch_warp_portal", -- modifier name
        {
            duration = phase,
            x = point.x,
            y = point.y,
            z = point.z
        } -- kv
    )
end

--------------------------------------------------------------------------------

modifier_tzeentch_warp_portal = class({})

--------------------------------------------------------------------------------
-- Classifications

function modifier_tzeentch_warp_portal:IsHidden() return true end
function modifier_tzeentch_warp_portal:IsPurgable() return false end

modifier_tzeentch_warp_portal.pos = nil

--------------------------------------------------------------------------------
-- Initializations
function modifier_tzeentch_warp_portal:OnCreated( kv )
	-- references
	if not IsServer() then return end

	-- set direction and speed
    self.pos = Vector( kv.x, kv.y, kv.z )
    
    local nFXIndex = ParticleManager:CreateParticle( "particles/econ/events/ti10/portal/portal_open_good.vpcf", PATTACH_CUSTOMORIGIN, nil );
    ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() + Vector( 0, 0, 16 ) );
    self:AddParticle(nFXIndex, false, false, -1, false, false)

    local nFXIndex1 = ParticleManager:CreateParticle( "particles/econ/events/ti10/portal/portal_open_good_parent.vpcf", PATTACH_CUSTOMORIGIN, nil );
    ParticleManager:SetParticleControl( nFXIndex1, 0, self.pos + Vector( 0, 0, 16 ) );
    self:AddParticle(nFXIndex1, false, false, -1, false, false)

    EmitSoundOnLocationWithCaster(self.pos, "Hero_VoidSpirit.Dissimilate.Cast", self:GetCaster())
    EmitSoundOnLocationWithCaster(self:GetCaster():GetOrigin(), "Hero_VoidSpirit.Dissimilate.Cast", self:GetCaster())

    self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 0.5)
end

function modifier_tzeentch_warp_portal:OnRefresh( kv )
	
end

function modifier_tzeentch_warp_portal:OnRemoved()
end

function modifier_tzeentch_warp_portal:OnDestroy()
	if not IsServer() then return end
    
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2_END)

    FindClearSpaceForUnit(self:GetCaster(), self.pos, true)
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_tzeentch_warp_portal:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end

