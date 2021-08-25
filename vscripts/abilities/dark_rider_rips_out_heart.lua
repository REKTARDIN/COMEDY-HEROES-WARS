if dark_rider_rips_out_heart == nil then dark_rider_rips_out_heart = class({}) end

LinkLuaModifier( "modifier_dark_rider_rips_out_heart", "abilities/dark_rider_rips_out_heart.lua", LUA_MODIFIER_MOTION_NONE )

function dark_rider_rips_out_heart:GetChannelTime()
    return self:GetSpecialValueFor("channel_time")
end

function dark_rider_rips_out_heart:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end
--------------------------------------------------------------------------------

function dark_rider_rips_out_heart:OnAbilityPhaseStart()
	if IsServer() then
		self.hVictim = self:GetCursorTarget()
	end

	return true
end

--------------------------------------------------------------------------------

function dark_rider_rips_out_heart:OnSpellStart()
	if self.hVictim == nil then
		return
	end
	if self.hVictim:TriggerSpellAbsorb( self ) then
		self.hVictim = nil
		self:GetCaster():Interrupt()
	else
		self.hVictim:AddNewModifier( self:GetCaster(), self, "modifier_dark_rider_rips_out_heart", { duration = self:GetChannelTime() } )
		self.hVictim:Interrupt()
	end

	local radius = 128

	local time_stop = ParticleManager:CreateParticle("particles/stygian/dark_rider_rips_heart_time_red_timedialate.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(time_stop, 0, self.hVictim, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hVictim:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(time_stop, 6, self.hVictim, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self.hVictim:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(time_stop)
	
	EmitSoundOn("Hero_FacelessVoid.TimeDilation.Cast.ti7", self.hVictim)
end


--------------------------------------------------------------------------------

function dark_rider_rips_out_heart:OnChannelFinish( bInterrupted )
	if self.hVictim ~= nil and (not bInterrupted) then
        local damage = self.hVictim:GetMaxHealth() * self:GetSpecialValueFor("max_health_damage") / 100
		damage = damage + self:GetCaster():GetIdealSpeed() * self:GetSpecialValueFor("movespeed_damage") / 100

		local stun =  self:GetSpecialValueFor("stun_duration")
		
		if self.hVictim:IsSpeedster() then 
			damage = damage * 2
			stun = stun + stun
		end
        
		ApplyDamage({
            victim = self.hVictim,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
		})

		self.hVictim:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = 0.3 } )

		local heart_rip_blood = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
		ParticleManager:SetParticleControlEnt(heart_rip_blood, 0, self.hVictim, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hVictim:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(heart_rip_blood, 1, self.hVictim, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self.hVictim:GetAbsOrigin(), true)
	    ParticleManager:ReleaseParticleIndex(heart_rip_blood)
		
		EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace", self.hVictim)
	end
end

modifier_dark_rider_rips_out_heart = class({})


function modifier_dark_rider_rips_out_heart:IsHidden()
	return true
end

function modifier_dark_rider_rips_out_heart:IsPurgable()
	return false
end

function modifier_dark_rider_rips_out_heart:OnCreated( kv )
	if IsServer() then
		self:GetParent():InterruptChannel()
	end
end

function modifier_dark_rider_rips_out_heart:OnDestroy()
	if self.hVictim ~= nil then
		self.hVictim:RemoveModifierByName( "modifier_dark_rider_rips_out_heart" )
	end
end

function modifier_dark_rider_rips_out_heart:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVISIBLE] = false,
        [MODIFIER_STATE_FROZEN] = true
	}

	return state
end


function modifier_dark_rider_rips_out_heart:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_dark_rider_rips_out_heart:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_dark_rider_rips_out_heart:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end
