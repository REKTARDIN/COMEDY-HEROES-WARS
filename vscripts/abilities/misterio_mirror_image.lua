misterio_mirror_image = class({})
LinkLuaModifier( "modifier_misterio_mirror_image", "abilities/misterio_mirror_image.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_summon_timer", "abilities/misterio_mirror_image.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
misterio_mirror_image.illusions = {}
function misterio_mirror_image:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local delay = self:GetSpecialValueFor( "invuln_duration" )

	-- stop, dodge & dispel
	caster:Stop()
	ProjectileManager:ProjectileDodge( caster )
	caster:Purge( false, true, false, false, false )

	-- add delay modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_misterio_mirror_image", -- modifier name
		{ duration = delay } -- kv
	)

	-- play effects
	local sound_cast = "Hero_NagaSiren.MirrorImage"
	EmitSoundOn( sound_cast, caster )
end

modifier_misterio_mirror_image = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_misterio_mirror_image:IsHidden()
	return true
end

function modifier_misterio_mirror_image:IsDebuff()
	return false
end

function modifier_misterio_mirror_image:IsStunDebuff()
	return false
end

function modifier_misterio_mirror_image:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_misterio_mirror_image:OnCreated( kv )
	-- load data
	self.count = self:GetAbility():GetSpecialValueFor( "images_count" )
	self.duration = self:GetAbility():GetSpecialValueFor( "illusion_duration" )
	self.outgoing = self:GetAbility():GetSpecialValueFor( "outgoing_damage" )
	self.incoming = self:GetAbility():GetSpecialValueFor( "incoming_damage" )
	self.distance = 72

	-- references
	if not IsServer() then return end
end

function modifier_misterio_mirror_image:OnRefresh( kv )
	
end

function modifier_misterio_mirror_image:OnRemoved()
end

function modifier_misterio_mirror_image:OnDestroy()
	if not IsServer() then return end

	--[[
		NOTE: Rather than kill previous illu and summon new,
		the original have set can_respawn = true and just respawn the illu.
		but then the illusion is outdated in level, items, and abilities.
		And set its respawn position manually.
		So, no thanks.
	]]

	for illusion,_ in pairs(self:GetAbility().illusions) do
		if not illusion:IsNull() then
			-- kill previous illusion
			illusion:ForceKill( false )
		end

		-- unregister
		self:GetAbility().illusions[ illusion ]	= nil	
	end

	-- create illusions
	-- this function seems unoptimizedly slow, but whatever. doing manually is bothersome
	-- for manual illusion, see CK's Phantasm
	local illusions = CreateIllusions(
		self:GetParent(), -- hOwner
		self:GetParent(), -- hHeroToCopy
		{
			outgoing_damage = self.outgoing,
			incoming_damage = self.incoming,
			duration = self.duration,
		}, -- hModiiferKeys
		self.count, -- nNumIllusions
		self.distance, -- nPadding
		true, -- bScramblePosition
		true -- bFindClearSpace
	)

	-- register illusions
	for _,illusion in pairs(illusions) do
		self:GetAbility().illusions[ illusion ] = true
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_misterio_mirror_image:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Helper
function modifier_misterio_mirror_image:CreateIllusion()
	self:GetAbility().illusions = {}


end

function modifier_misterio_mirror_image:SummonIllusion()

end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_misterio_mirror_image:GetEffectName()
	return "particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf"
end

function modifier_misterio_mirror_image:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_generic_summon_timer = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_summon_timer:IsDebuff()
	return true
end

function modifier_generic_summon_timer:IsHidden()
	return true
end

function modifier_generic_summon_timer:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_summon_timer:OnDestroy()
	if IsServer() then
		self:GetParent():ForceKill( false )
	end
end

--------------------------------------------------------------------------------
-- Declare Functions
function modifier_generic_summon_timer:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_LIFETIME_FRACTION
	}

	return funcs
end

function modifier_generic_summon_timer:GetUnitLifetimeFraction( params )
	return ( ( self:GetDieTime() - GameRules:GetGameTime() ) / self:GetDuration() )
end