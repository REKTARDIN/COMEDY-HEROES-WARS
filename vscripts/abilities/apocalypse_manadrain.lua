if not apocalypse_manadrain then apocalypse_manadrain = class({}) end 

LinkLuaModifier( "modifier_apocalypse_manadrain", "abilities/apocalypse_manadrain.lua", LUA_MODIFIER_MOTION_NONE )

function apocalypse_manadrain:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end

--------------------------------------------------------------------------------

function apocalypse_manadrain:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

--------------------------------------------------------------------------------

function apocalypse_manadrain:GetChannelTime()
	return self:GetSpecialValueFor("duration")
end

--------------------------------------------------------------------------------

function apocalypse_manadrain:OnAbilityPhaseStart()
	if IsServer() then
		self.hVictim = self:GetCursorTarget()
	end

	return true
end

apocalypse_manadrain.m_flDrainedMana = 0

--------------------------------------------------------------------------------
-- Ability Start
function apocalypse_manadrain:OnSpellStart()
    if IsServer() then
        -- unit identifier
        local caster = self:GetCaster()

        self.m_flDrainedMana = 0

        -- cancel if linken
        if not self.hVictim or not IsValidEntity(self.hVictim) or self.hVictim:TriggerSpellAbsorb( self ) then
            caster:Interrupt()
            return
        end

        -- load data
        local duration = self:GetChannelTime()

        -- register modifier (in case for multi-target)
        local modifier = self.hVictim:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_apocalypse_manadrain", -- modifier name
            { duration = duration } -- kv
        )
        -- play effects
        EmitSoundOn( "Hero_Lion.ManaDrain", caster )
    end
end

function apocalypse_manadrain:Explode( target, fullExplosion )
    if IsServer() then
        local radius = self:GetSpecialValueFor( "radius" ) 
        local damage = self:GetCaster():GetIntellect() + (target:GetMaxMana() - target:GetMana()) ----self.m_flDrainedMana
        
        if not fullExplosion then
            damage = damage / 2
        end 

        local unitd = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), target:GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        if #unitd > 0 then
            for _,unit in pairs(unitd) do
                ApplyDamage ({attacker = self:GetCaster(), victim = unit, ability = self, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

                EmitSoundOn( "Hero_Lion.FoD.Target.TI8_layer", self:GetCaster() )
            end
        end
    
        local nFXIndex = ParticleManager:CreateParticle( "particles/stygian/apocalypse_mana_drain_explode_ntimage_manavoid_ti_5.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
        ParticleManager:SetParticleControl( nFXIndex, 0, target:GetOrigin() )
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius, radius, 0) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
    
        EmitSoundOn( "Hero_Lion.FoD.Cast.TI8_layer", self:GetCaster() )
    end
end

function apocalypse_manadrain:OnChannelFinish( bInterrupted )
    if self.hVictim ~= nil then
		self.hVictim:RemoveModifierByName( "modifier_apocalypse_manadrain" )
    end
    
    self:Explode(self.hVictim, not bInterrupted)

	-- end sound
	StopSoundOn( "Hero_Lion.ManaDrain", self:GetCaster() )
end

--------------------------------------------------------------------------------
modifier_apocalypse_manadrain = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_apocalypse_manadrain:IsHidden()
	return false
end

function modifier_apocalypse_manadrain:IsDebuff()
	return true
end

function modifier_apocalypse_manadrain:IsStunDebuff()
	return false
end

function modifier_apocalypse_manadrain:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_apocalypse_manadrain:OnCreated( kv )
	-- references
    self.mana = self:GetAbility():GetSpecialValueFor( "mana_per_second" )
    self.damage = -self:GetAbility():GetSpecialValueFor( "damage_drain_per_second" )
	self.radius = self:GetAbility():GetSpecialValueFor( "break_distance" )
	self.slow = -self:GetAbility():GetSpecialValueFor( "movespeed_per_second" )

    self.interval = self:GetAbility():GetSpecialValueFor( "tick_interval" )

	if IsServer() then
		self.parent = self:GetParent()

        if self:GetCaster():HasTalent("special_bonus_unique_apocalypse_1") then
            self.mana = self.mana + self:GetCaster():FindTalentValue("special_bonus_unique_apocalypse_1")
        end

		-- Start interval
        self:StartIntervalThink( self.interval )
        
        -- Create Particle
        local effect_cast = ParticleManager:CreateParticle( "particles/stygian/apocalypse_mana_drain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
        ParticleManager:SetParticleControlEnt( effect_cast, 1, self:GetCaster(),  PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )

        -- buff particle
        self:AddParticle( effect_cast, false, false, -1, false, false )
    end
    
    self.mana = self.mana * self.interval
end

function modifier_apocalypse_manadrain:OnRefresh( kv )
	
end

function modifier_apocalypse_manadrain:OnRemoved()

end

function modifier_apocalypse_manadrain:OnDestroy()
	if not IsServer() then return end

    self:GetCaster():Interrupt()

	-- instantly kill illusion
	if self.parent:IsIllusion() then
		self.parent:Kill( self:GetAbility(), self:GetCaster() )
	end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_apocalypse_manadrain:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE
	}

	return funcs
end

function modifier_apocalypse_manadrain:GetModifierModelScale()
	return -self:GetStackCount()
end

function modifier_apocalypse_manadrain:GetModifierMoveSpeedBonus_Percentage()
	return self.slow * self.interval * self:GetStackCount()
end

function modifier_apocalypse_manadrain:GetModifierDamageOutgoing_Percentage()
	return self.damage * self.interval * self:GetStackCount()
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_apocalypse_manadrain:OnIntervalThink()
	-- check illusion, magic immune, or invulnerable
	if self.parent:IsMagicImmune() or self.parent:IsInvulnerable() or self.parent:IsIllusion() then
		self:Destroy()
		return
	end

	-- check distance
	if (self:GetParent():GetOrigin() - self:GetCaster():GetOrigin()):Length2D() > self.radius then
		self:Destroy()
		return
	end

    local empty = self:GetParent():GetMana() <= 0

	-- absorbmana
	self:GetParent():ReduceMana( self.mana)
    self:GetCaster():GiveMana( self.mana)
    
    self:GetAbility().m_flDrainedMana = (self:GetAbility().m_flDrainedMana or 0) + self.mana

	if empty then
		self:Destroy()
    end
    
    self:IncrementStackCount()
end
