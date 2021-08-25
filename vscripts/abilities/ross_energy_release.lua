ross_energy_release = class({})

LinkLuaModifier ("modifier_ross_energy_release", "abilities/ross_energy_release.lua", LUA_MODIFIER_MOTION_BOTH)

function ross_energy_release:Precache(context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", context )
end

function ross_energy_release:Explode( vLoc )
    if IsServer() then
        local radius = self:GetSpecialValueFor("radius") + self:GetCaster():RULK_GetUltimateStacks() 
		local damage = self:GetSpecialValueFor("damage") + (self:GetCaster():RULK_GetUltimateStacks() * 2)
		local vNewPos = vLoc + self:GetCaster():GetForwardVector() * 175
        
        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), vNewPos, self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		
        if #units > 0 then
            for _,unit in pairs(units) do
                unit:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = 0.2 } )

                ApplyDamage({
                    victim = unit,
                    attacker = self:GetCaster(),
                    damage = damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self
                })
            end
        end

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControl( nFXIndex, 0, vNewPos )
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius, radius, 1) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		
		local nFXIndex2 = ParticleManager:CreateParticle( "particles/hero_ursa/ursa_thunderclap.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControl( nFXIndex2, 0, vNewPos )
        ParticleManager:SetParticleControl( nFXIndex2, 1, Vector(radius, radius, 1) )
        ParticleManager:ReleaseParticleIndex( nFXIndex2 )

        EmitSoundOn( "Hero_Huskar.Life_Break.Impact", self:GetCaster() )
    end
end

function ross_energy_release:OnSpellStart()
    if IsServer() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ross_energy_release", nil)
		EmitSoundOn("Hero_Huskar.Life_Break", self:GetCaster())
	end
end
  
modifier_ross_energy_release = class({})

--------------------------------------------------------------------------------

local MINIMUM_HEIGHT_ABOVE_LOWEST = 500
local MINIMUM_HEIGHT_ABOVE_HIGHEST = 100
local ACCELERATION_Z = 4000
local MAX_HORIZONTAL_ACCELERATION = 3000

--------------------------------------------------------------------------------

function modifier_ross_energy_release:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:OnCreated( kv )
	if IsServer() then
		self.bHorizontalMotionInterrupted = false
		self.bDamageApplied = false
		self.bTargetTeleported = false

		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
		end

		self.vStartPosition = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
		self.flCurrentTimeHoriz = 0.0
		self.flCurrentTimeVert = 0.0

		self.vLoc = self.vStartPosition + self:GetParent():GetForwardVector() * self:GetAbility():GetSpecialValueFor( "jump_distance" )
		self.vLastKnownTargetPos = self.vLoc

		local duration = self:GetAbility():GetSpecialValueFor( "jump_duration" ) ---- желательно от 0.3 до 0.7
	
		local flDesiredHeight = MINIMUM_HEIGHT_ABOVE_LOWEST * duration * duration
		local flLowZ = math.min( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flHighZ = math.max( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flArcTopZ = math.max( flLowZ + flDesiredHeight, flHighZ + MINIMUM_HEIGHT_ABOVE_HIGHEST )

		local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
		self.flInitialVelocityZ = math.sqrt( 4.0 * flArcDeltaZ * ACCELERATION_Z )

		local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
		local flSqrtDet = math.sqrt( math.max( 0, ( self.flInitialVelocityZ * self.flInitialVelocityZ ) - 2.0 * ACCELERATION_Z * flDeltaZ ) )
		self.flPredictedTotalTime = math.max( ( self.flInitialVelocityZ + flSqrtDet) / ACCELERATION_Z, ( self.flInitialVelocityZ - flSqrtDet) / ACCELERATION_Z )

		self.vHorizontalVelocity = ( self.vLastKnownTargetPos - self.vStartPosition ) / self.flPredictedTotalTime
		self.vHorizontalVelocity.z = 0.0
	end
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:OnDestroy()
	if IsServer() then
		
	end
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:CheckState()
	local state =
	{
	    [MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		self.flCurrentTimeHoriz = math.min( self.flCurrentTimeHoriz + dt, self.flPredictedTotalTime )
		local t = self.flCurrentTimeHoriz / self.flPredictedTotalTime
		local vStartToTarget = self.vLastKnownTargetPos - self.vStartPosition
		local vDesiredPos = self.vStartPosition + t * vStartToTarget

		local vOldPos = me:GetOrigin()
		local vToDesired = vDesiredPos - vOldPos
		vToDesired.z = 0.0
		local vDesiredVel = vToDesired / dt
		local vVelDif = vDesiredVel - self.vHorizontalVelocity
		local flVelDif = vVelDif:Length2D()
		vVelDif = vVelDif:Normalized()
		local flVelDelta = math.min( flVelDif, MAX_HORIZONTAL_ACCELERATION )

		self.vHorizontalVelocity = self.vHorizontalVelocity + vVelDif * flVelDelta * dt
		local vNewPos = vOldPos + self.vHorizontalVelocity * dt
		me:SetOrigin( vNewPos )
	end
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:UpdateVerticalMotion( me, dt )
	if IsServer() then
		self.flCurrentTimeVert = self.flCurrentTimeVert + dt
		local bGoingDown = ( -ACCELERATION_Z * self.flCurrentTimeVert + self.flInitialVelocityZ ) < 0
		
		local vNewPos = me:GetOrigin()
		vNewPos.z = self.vStartPosition.z + ( -0.5 * ACCELERATION_Z * ( self.flCurrentTimeVert * self.flCurrentTimeVert ) + self.flInitialVelocityZ * self.flCurrentTimeVert )

		local flGroundHeight = GetGroundHeight( vNewPos, self:GetParent() )
		local bLanded = false
		if ( vNewPos.z < flGroundHeight and bGoingDown == true ) then
			vNewPos.z = flGroundHeight
			bLanded = true
		end

		me:SetOrigin( vNewPos )

		if bLanded == true then
			if self.bHorizontalMotionInterrupted == false then
				self:GetAbility():Explode(self:GetParent():GetAbsOrigin())
			end

			self:GetParent():RemoveHorizontalMotionController( self )
			self:GetParent():RemoveVerticalMotionController( self )

			self:SetDuration( 0.15, false )
		end
	end
end

--------------------------------------------------------------------------------


function modifier_ross_energy_release:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.bHorizontalMotionInterrupted = true
	end
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:OnVerticalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------

function modifier_ross_energy_release:GetOverrideAnimation( params )
	return ACT_DOTA_CAST_ABILITY_1
end