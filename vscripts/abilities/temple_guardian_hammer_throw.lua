temple_guardian_hammer_throw = class({})
LinkLuaModifier( "modifier_temple_guardian_hammer_throw", "abilities/temple_guardian_hammer_throw.lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function temple_guardian_hammer_throw:OnAbilityPhaseStart()
	if IsServer() then
		self.nPreviewFX = ParticleManager:CreateParticle( "particles/econ/items/storm_spirit/strom_spirit_ti8/storm_sprit_ti8_overload_discharge_b.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true )
		ParticleManager:SetParticleControl( self.nPreviewFX, 15, Vector( 135, 192, 235 ) )
		ParticleManager:SetParticleControl( self.nPreviewFX, 16, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( self.nPreviewFX )

		EmitSoundOn( "TempleGuardian.PreAttack", self:GetCaster() )
	end

	return true
end

--------------------------------------------------------------------------------

function temple_guardian_hammer_throw:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, true )
	end 
end

--------------------------------------------------------------------------------

function temple_guardian_hammer_throw:GetPlaybackRateOverride()
	return 0.5
end

--------------------------------------------------------------------------

function temple_guardian_hammer_throw:OnSpellStart()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
		
		local vLocation = self:GetCursorPosition()

		local kv = 
		{
			x = vLocation.x,
			y = vLocation.y,
		}
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_temple_guardian_hammer_throw", kv )
	end
end

modifier_temple_guardian_hammer_throw = class({})

-------------------------------------------------------------------

function modifier_temple_guardian_hammer_throw:IsHidden()
	return true
end

-------------------------------------------------------------------

function modifier_temple_guardian_hammer_throw:IsPurgable()
	return false
end

-------------------------------------------------------------------

function modifier_temple_guardian_hammer_throw:RemoveOnDeath()
	return false
end

-------------------------------------------------------------------

function modifier_temple_guardian_hammer_throw:OnCreated( kv )
	if IsServer() then
		self.hammer_damage = self:GetAbility():GetSpecialValueFor( "hammer_damage" )
		self.throw_duration = self:GetAbility():GetSpecialValueFor( "throw_duration" )
		self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )
		self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

		self.hHitEntities = {}

		self.hHammer = CreateUnitByName( "npc_dota_beastmaster_axe", self:GetParent():GetOrigin(), false, nil, nil, self:GetParent():GetTeamNumber() )
		if self.hHammer == nil then
			self:Destroy()
			return		
		end

		self.hHammer:AddEffects( EF_NODRAW )
		self.hHammer:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_beastmaster_axe_invulnerable", kv )

		self.vSourceLoc = self:GetCaster():GetOrigin()
		self.vSourceLoc.z = self.vSourceLoc.z + 180
		self.vTargetLoc = Vector( kv["x"], kv["y"], self.vSourceLoc.z )
		self.vToTarget = self.vTargetLoc - self.vSourceLoc
		self.vDir = self.vToTarget:Normalized()
		self.flDist = self.vToTarget:Length2D()
	
		self.flDieTime = GameRules:GetGameTime() + self.throw_duration
		self.bReturning = false

		self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControlEnt( self.nFXIndex, 0, self.hHammer, PATTACH_ABSORIGIN_FOLLOW, nil, self.hHammer:GetOrigin(), true )

		EmitSoundOn( "TempleGuardian.HammerThrow", self:GetCaster() )

		self:StartIntervalThink( 0.05 )
	end
end

-------------------------------------------------------------------

function modifier_temple_guardian_hammer_throw:OnIntervalThink()
	if IsServer() then
		local flPct = ( self.flDieTime - GameRules:GetGameTime() ) / self.throw_duration
		local t = 1.0 - flPct 

		local vPos = self.vSourceLoc + ( self.vDir * self.flDist * t * 2 )
		if self.bReturning == true then
			vPos = self.vTargetLoc - ( self.vDir * self.flDist * ( t - 0.5 ) * 2 )
		end
		
		if FrameTime() > 0.0 then
			local vVel = vPos - self.hHammer:GetOrigin() / FrameTime()
			self.hHammer:SetVelocity( vVel )
		end
		
		self.hHammer:SetOrigin( vPos )

		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self.hHammer:GetOrigin(), self.hHammer, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		for _,enemy in pairs( enemies ) do
			if enemy ~= nil and enemy:IsInvulnerable() == false and self:HasHitTarget( enemy ) == false then
				self:AddHitTarget( enemy )
				local damageInfo =
				{
					victim = enemy,
					attacker = self:GetCaster(),
					damage = self.hammer_damage,
					damage_type = DAMAGE_TYPE_PURE,
					ability = self:GetAbility(),
				}
				ApplyDamage( damageInfo )
				enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_stunned", { duration = self.stun_duration } )
				EmitSoundOn( "TempleGuardian.HammerThrow.Damage", enemy )

				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_beastmaster/beastmaster_wildaxes_hit.vpcf", PATTACH_CUSTOMORIGIN, nil )
				ParticleManager:SetParticleControlEnt( nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
			end
		end	

		if t >= 0.5 then
			self.bReturning = true
		end

		if t >= 0.95 then	
			self:Destroy()
		end
	end
end

-------------------------------------------------------------------

function modifier_temple_guardian_hammer_throw:OnDestroy()
	if IsServer() then
		UTIL_Remove( self.hHammer )
		ParticleManager:DestroyParticle( self.nFXIndex, true )
	end
end

-------------------------------------------------------------------

function modifier_temple_guardian_hammer_throw:HasHitTarget( enemy )
	if IsServer() then
		for _,hitEnemy in pairs( self.hHitEntities ) do
			if hitEnemy == enemy then
				return true
			end
		end
		return false
	end
end

-------------------------------------------------------------------

function modifier_temple_guardian_hammer_throw:AddHitTarget( enemy )
	if IsServer() then
		table.insert( self.hHitEntities, enemy )
	end
end