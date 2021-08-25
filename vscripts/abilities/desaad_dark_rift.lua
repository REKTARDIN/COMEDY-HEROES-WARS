desaad_dark_rift = class({})

LinkLuaModifier( "modifier_desaad_dark_rift", "abilities/desaad_dark_rift", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function desaad_dark_rift:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
    local point = self:GetCursorPosition()
    local pos 

	-- search for closest target if it is a point
	if not target then
		pos = point
    else 
        pos = target:GetAbsOrigin()
    end

	-- load data
	local duration = self:GetSpecialValueFor( "teleport_delay" ) - (IsHasTalent(caster:GetPlayerOwnerID(), "special_bonus_unique_desaad_4") or 0)

	-- add modifier to target
	self.modifier = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_desaad_dark_rift", -- modifier name
		{ duration = duration, x = pos.x, y = pos.y, z = pos.z } -- kv
    )
    
    if caster:HasAbility("desaad_dark_rift_cancel") then
        -- switch ability layout
        caster:SwapAbilities(
            self:GetAbilityName(),
            "desaad_dark_rift_cancel",
            false,
            true
        )
    end
end

--------------------------------------------------------------------------------
-- Sub Ability
--------------------------------------------------------------------------------
desaad_dark_rift_cancel = class({})

--------------------------------------------------------------------------------
-- Ability Start
function desaad_dark_rift_cancel:OnSpellStart()
    -- kill modifier
    local ability = self:GetCaster():FindAbilityByName("desaad_dark_rift")

    if ability and ability.modifier then
        ability.modifier:Cancel()
        ability.modifier = nil

        self:GetCaster():SwapAbilities(
            self:GetAbilityName(),
            "desaad_dark_rift_cancel",
            true,
            false
        )
    end
end

function desaad_dark_rift_cancel:Spawn()
    if IsServer() then
        self:SetLevel(1)
    end
end

--------------------------------------------------------------------------------

modifier_desaad_dark_rift = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_desaad_dark_rift:IsHidden() return false end
function modifier_desaad_dark_rift:IsDebuff() return false end
function modifier_desaad_dark_rift:IsPurgable() return false end
function modifier_desaad_dark_rift:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_desaad_dark_rift:GetEffectName() return "particles/econ/items/oracle/oracle_ti10_immortal/oracle_ti10_immortal_purifyingflames.vpcf" end 
function modifier_desaad_dark_rift:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
--------------------------------------------------------------------------------
-- Initializations
function modifier_desaad_dark_rift:OnCreated( kv )
	-- references
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
    self.pos = Vector(kv.x, kv.y, kv.z)

	if not IsServer() then return end

	self.success = true

	self.effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_necrolyte/necrolyte_spirit_ground_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, self:GetCaster():GetAbsOrigin() )
    self:AddParticle(self.effect_cast, false, false, -1, false, false)

	-- Create Sound
    EmitSoundOn( "Hero_AbyssalUnderlord.DarkRift.Cast", self:GetCaster()  )
    
    -- Create Particle
	self.effect_point = ParticleManager:CreateParticle( "particles/units/heroes/heroes_underlord/abyssal_underlord_darkrift_target.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl(
		self.effect_point,
		0,
		Vector(self.pos.x, self.pos.y, self.pos.z + 186.0)
    )
    ParticleManager:SetParticleControl(
		self.effect_point,
		6,
		Vector(self.pos.x, self.pos.y, self.pos.z)
	)

	-- buff particle
	self:AddParticle(
		self.effect_point,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
    )
    
    EmitSoundOnLocationWithCaster(self.pos, "Hero_AbyssalUnderlord.Pit.Target", self:GetCaster())
end

function modifier_desaad_dark_rift:OnRefresh( kv )
	
end

function modifier_desaad_dark_rift:OnRemoved()
	if not IsServer() then return end
	if not self.success then return end

	local caster = self:GetCaster()

	-- success teleporting
	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,target in pairs(targets) do
		-- disjoint
        ProjectileManager:ProjectileDodge( target )
        
        local effect_target = ParticleManager:CreateParticle( "particles/desaad/desaad_riftend.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( effect_target, 0, self:GetCaster():GetAbsOrigin() + Vector(0, 0, 96.0) )
        ParticleManager:ReleaseParticleIndex(effect_target)

        EmitSoundOn("Hero_AbyssalUnderlord.DarkRift.Target", caster)

		-- move to position
		FindClearSpaceForUnit( target, self.pos, true )
    end
    
    local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/heroes_underlord/au_darkrift_target_oh_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetAbsOrigin() + Vector(0, 0, 96.0) )
    ParticleManager:ReleaseParticleIndex(effect_cast)
    
	-- switch ability layout
	local ability = self:GetCaster():FindAbilityByName( "desaad_dark_rift_cancel" )
	if not ability then return end

	caster:SwapAbilities(
		self:GetAbility():GetAbilityName(),
		ability:GetAbilityName(),
		true,
		false
    )
    
    EmitSoundOn("Hero_AbyssalUnderlord.DarkRift.Complete", caster)
end

function modifier_desaad_dark_rift:OnDestroy()

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_desaad_dark_rift:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

function modifier_desaad_dark_rift:OnDeath( params )
	if not IsServer() then return end

	if params.unit~=self:GetCaster() and params.unit~=self:GetParent() then return end

	-- either caster or target dies, destroy
	self:Cancel()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_desaad_dark_rift:CheckState()
	local state = {
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Helper
function modifier_desaad_dark_rift:Cancel()
	-- cancel teleport
	self.success = false

	-- switch ability layout
	local ability = self:GetCaster():FindAbilityByName( "desaad_dark_rift_cancel" )
	if not ability then return end

	self:GetCaster():SwapAbilities(
		self:GetAbility():GetAbilityName(),
		ability:GetAbilityName(),
		true,
		false
	)

	-- destroy
    self:Destroy()
    
    EmitSoundOn("Hero_AbyssalUnderlord.DarkRift.Cancel", self:GetCaster())
end
