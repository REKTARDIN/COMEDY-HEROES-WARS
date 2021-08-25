doomsday_toss = class({})

LinkLuaModifier( "modifier_doomsday_toss_leap", "abilities/doomsday_toss", LUA_MODIFIER_MOTION_BOTH )
--------------------------------------------------------------------------------

function doomsday_toss:OnAbilityPhaseStart()
	return true
end

--------------------------------------------------------------------------------

function doomsday_toss:OnAbilityPhaseInterrupted()

end

--------------------------------------------------------------------------------

function doomsday_toss:OnSpellStart()
    if IsServer() then
        local unit = Util:FindNearestTarget(self)
        local target = self:GetCursorTarget()

		if unit == nil then
			self:EndCooldown()
			self:RefundManaCost()

			return 
		end

        if target and IsValidEntity(unit) and not target:TriggerSpellAbsorb(self) then
            local kv =
            {
                target = target:entindex()
            }

            unit:AddNewModifier( self:GetCaster(), self, "modifier_doomsday_toss_leap", kv )

            EmitSoundOn( "Ability.TossThrow", self:GetCaster() )

            ApplyDamage({
                victim = unit,
                attacker = self:GetCaster(),
                ability = self,
                damage = self:GetSpecialValueFor("bonus_damage"),
                damage_type = DAMAGE_TYPE_MAGICAL,
            })
        end
	end
end

--------------------------------------------------------------------------------

function doomsday_toss:OnUnitLanded(vLocation, target)
	if IsServer() then
		local radius = self:GetSpecialValueFor( "radius" )
		local damage = self:GetCaster():GetStrength()
		local stun_duration = self:GetSpecialValueFor( "stun_duration" )

		if self:GetCaster():HasTalent("special_bonus_unique_doomsday_2") then
			stun_duration = stun_duration + self:GetCaster():FindTalentValue("special_bonus_unique_doomsday_2")
		end

        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), vLocation, self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, 0, false )
		if #enemies > 0 then
			for _, enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					enemy:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = stun_duration } )
                
                    local DamageInfo =
					{
						victim = enemy,
						attacker = self:GetCaster(),
						ability = self,
						damage = damage + self:GetCaster():GetStrength(),
						damage_type = DAMAGE_TYPE_MAGICAL,
                    }
                    
                    EmitSoundOn( "Hero_Tiny.Toss.Target", enemy )
        
					ApplyDamage( DamageInfo )
				end
			end
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_tiny/tiny_toss_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, vLocation )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( radius, radius, 1.0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

        EmitSoundOn( "Ability.TossImpact", target )
        
		GridNav:DestroyTreesAroundPoint( vLocation, radius, false )
	end
end

modifier_doomsday_toss_leap = class({})

modifier_doomsday_toss_leap.m_hTarget = nil

--------------------------------------------------------------------------------

local MINIMUM_HEIGHT_ABOVE_LOWEST = 500
local MINIMUM_HEIGHT_ABOVE_HIGHEST = 100
local ACCELERATION_Z = 4000
local MAX_HORIZONTAL_ACCELERATION = 3000

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:OnCreated( kv )
	if IsServer() then
		self.bHorizontalMotionInterrupted = false
		self.bDamageApplied = false
        self.bTargetTeleported = false
        
        self.m_hTarget = EntIndexToHScript(kv.target)

		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
		end

		self.vStartPosition = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
		self.flCurrentTimeHoriz = 0.0
		self.flCurrentTimeVert = 0.0

		self.vLoc = self.m_hTarget:GetAbsOrigin()
		self.vLastKnownTargetPos = self.vLoc

		local duration = self:GetAbility():GetSpecialValueFor( "duration" )
		local flDesiredHeight = MINIMUM_HEIGHT_ABOVE_LOWEST * duration * duration
		local flLowZ = math.min( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flHighZ = math.max( self.vLastKnownTargetPos.z, self.vStartPosition.z )
		local flArcTopZ = math.max( flLowZ + flDesiredHeight, flHighZ + MINIMUM_HEIGHT_ABOVE_HIGHEST )

		local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
		self.flInitialVelocityZ = math.sqrt( 2.0 * flArcDeltaZ * ACCELERATION_Z )

		local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
		local flSqrtDet = math.sqrt( math.max( 0, ( self.flInitialVelocityZ * self.flInitialVelocityZ ) - 2.0 * ACCELERATION_Z * flDeltaZ ) )
		self.flPredictedTotalTime = math.max( ( self.flInitialVelocityZ + flSqrtDet) / ACCELERATION_Z, ( self.flInitialVelocityZ - flSqrtDet) / ACCELERATION_Z )

		self.vHorizontalVelocity = ( self.vLastKnownTargetPos - self.vStartPosition ) / self.flPredictedTotalTime
		self.vHorizontalVelocity.z = 0.0

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
		self:AddParticle( nFXIndex, false, false, -1, false, false )
	end
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveVerticalMotionController( self )
	end
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:CheckState()
	local state =
	{
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:UpdateHorizontalMotion( me, dt )
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

function modifier_doomsday_toss_leap:UpdateVerticalMotion( me, dt )
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
				self:GetAbility():OnUnitLanded(vNewPos, self.m_hTarget)
			end

			self:GetParent():RemoveHorizontalMotionController( self )
			self:GetParent():RemoveVerticalMotionController( self )

			self:SetDuration( 0.1, false )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.bHorizontalMotionInterrupted = true
	end
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:OnVerticalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------

function modifier_doomsday_toss_leap:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end