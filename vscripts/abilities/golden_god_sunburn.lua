golden_god_sunburn = class({})

--------------------------------------------------------------------------------

LinkLuaModifier( "modifier_golden_god_sunburn_aura", "abilities/golden_god_sunburn.lua", LUA_MODIFIER_MOTION_NONE )

local PTC_PER_SECOND = 15
local TICK_TIME = 0.1

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function golden_god_sunburn:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------

function golden_god_sunburn:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end

--------------------------------------------------------------------------------

function golden_god_sunburn:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

--------------------------------------------------------------------------------

function golden_god_sunburn:GetChannelTime()
	return self:GetSpecialValueFor( "duration" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_goldengod_3") or 0)
end

--------------------------------------------------------------------------------
-- Ability Start
function golden_god_sunburn:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")

	-- load data
    local duration = self:GetSpecialValueFor( "duration" )

    if caster:HasTalent("special_bonus_unique_goldengod_3") then duration = duration + caster:FindTalentValue("special_bonus_unique_goldengod_3") end

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/centaur/centaur_ti6_gold/centaur_ti6_warstomp_gold.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( "Hero_TemplarAssassin.Trap.Trigger", self:GetCaster() )
	EmitSoundOnLocationWithCaster( point, "Hero_TemplarAssassin.Trap", self:GetCaster() )

	self:GetCaster():SetAbsOrigin(point)
	FindClearSpaceForUnit(self:GetCaster(), point, true)

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_golden_god_sunburn_aura", {duration = duration})
end

--------------------------------------------------------------------------------

function golden_god_sunburn:OnChannelFinish( bInterrupted )
	if bInterrupted then
		self:GetCaster():RemoveModifierByName( "modifier_golden_god_sunburn_aura" )
	else 
		self:GetCaster():SetHealth(self:GetCaster():GetMaxHealth())
	end
end

modifier_golden_god_sunburn_aura = class ({})

function modifier_golden_god_sunburn_aura:IsHidden() return true end
function modifier_golden_god_sunburn_aura:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_golden_god_sunburn_aura:IsPurgable() return false end

function modifier_golden_god_sunburn_aura:OnCreated(event)
    if IsServer() then
        local target = self:GetAbility():GetCaster():GetCursorPosition()

        self.damage = self:GetAbility():GetAbilityDamage()
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.caster = self:GetCaster()
  
        self:StartIntervalThink(TICK_TIME)

        local nFXIndex = ParticleManager:CreateParticle( "particles/thanos/thanos_supernova.vpcf", PATTACH_CUSTOMORIGIN, self.caster )
        ParticleManager:SetParticleControl( nFXIndex, 0, target)
        ParticleManager:SetParticleControl( nFXIndex, 1, target)
        ParticleManager:SetParticleControl( nFXIndex, 3, target)

        self:AddParticle( nFXIndex, false, false, -1, false, true )

        EmitSoundOn("Hero_Phoenix.SuperNova.Cast", self.caster)

        AddFOWViewer( self.caster:GetTeam(), target, 1500, 5, false)
        GridNav:DestroyTreesAroundPoint(target, 1500, false)
    end
end

function modifier_golden_god_sunburn_aura:OnIntervalThink()
	if IsServer() then
		local damage = self.damage + (self.caster:GetHealth() * (PTC_PER_SECOND / 100)) * TICK_TIME
    
		local nearby_targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		for i, target in ipairs(nearby_targets) do
			ApplyDamage( {
				victim = target,
				attacker = self.caster,
				damage = damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
				ability = self:GetAbility(),
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
			})
		end

		self.caster:ModifyHealth(self.caster:GetHealth() - damage, self:GetAbility(), false, 0)

		if self.caster:GetHealthPercent() <= self:GetAbility():GetSpecialValueFor("hp_threshold") then
			self.caster:Interrupt()
		end
	end
end

function modifier_golden_god_sunburn_aura:OnDestroy()
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/thanos/thanos_supernova_explode_a.vpcf", PATTACH_CUSTOMORIGIN, nil );
        ParticleManager:SetParticleControl( nFXIndex, 0, self.caster:GetAbsOrigin());
        ParticleManager:SetParticleControl( nFXIndex, 1, self.caster:GetAbsOrigin());
        ParticleManager:SetParticleControl( nFXIndex, 3, self.caster:GetAbsOrigin());
        ParticleManager:SetParticleControl( nFXIndex, 5, Vector(self.radius, self.radius, 0));
        ParticleManager:ReleaseParticleIndex( nFXIndex );

        EmitSoundOn( "Hero_EarthShaker.EchoSlam", self.caster )
        EmitSoundOn( "PudgeWarsClassic.echo_slam", self.caster )

        local nearby_targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

        for _, target in ipairs(nearby_targets) do
            target:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
        end
    end
end


function modifier_golden_god_sunburn_aura:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true
	}

	return state
end