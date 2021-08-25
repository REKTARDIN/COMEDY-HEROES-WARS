scarlett_witch_dark_blast = class({})

LinkLuaModifier( "modifier_scarlett_witch_dark_blast_debuff", "abilities/savitar_quantum_tunnel.lua", 0 )

--------------------------------------------------------------------------------

scarlett_witch_dark_blast.count = 0

function scarlett_witch_dark_blast:OnSpellStart()
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection = vDirection:Normalized()

	self.count = 0

	self.speed = self:GetSpecialValueFor( "travel_speed" )
	self.duration = self:GetSpecialValueFor( "root_duration" )
	self.damage = self:GetSpecialValueFor( "damage" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_scarlett_witch_3") or 0)

	local info = {
		EffectName = "particles/units/heroes/hero_invoker/dark_blast.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self:GetSpecialValueFor( "radius_start" ),
		fEndRadius = self:GetSpecialValueFor( "radius_end" ),
		vVelocity = vDirection * self.speed,
		fDistance = self:GetSpecialValueFor( "travel_distance" ),
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	}

    ProjectileManager:CreateLinearProjectile( info )
    
	EmitSoundOn( "Hero_Grimstroke.InkCreature.Returned" , self:GetCaster() )
end

--------------------------------------------------------------------------------

function scarlett_witch_dark_blast:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		self.count = self.count + 1

		local damage = self.damage + (self.count * self:GetSpecialValueFor( "damage_increase" ))

		ApplyDamage({
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		})
		
		EmitSoundOn( "Hero_Grimstroke.InkCreature.Death" , self:GetCaster() )

		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/grimstroke/ti9_immortal/gs_ti9_artistry_dmg.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
		ParticleManager:SetParticleControl( nFXIndex, 0, hTarget:GetOrigin() )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

        ----hTarget:IncreaseCooldowns(self:GetSpecialValueFor( "cooldown_increase" ), true)
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_rooted", { duration = self.duration } )
	end

	return false
end
