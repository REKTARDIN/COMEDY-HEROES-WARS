desaad_apocaliptik_strike = class({})

--------------------------------------------------------------------------------

function desaad_apocaliptik_strike:OnSpellStart()
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection = vDirection:Normalized()

	self.wave_speed = self:GetSpecialValueFor( "speed" )
    self.wave_width = self:GetSpecialValueFor( "width" )
    self.targets = self:GetSpecialValueFor( "max_target" )

    if self:GetCaster():HasScepter() then
        self.targets = self:GetSpecialValueFor( "scepter_max_target" )
    end

    self.damage = ((self:GetSpecialValueFor( "mana_dmg" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_desaad_1") or 0)) / 100 * self:GetCaster():GetMana()) + self:GetAbilityDamage()

	local info = {
		EffectName = "particles/desaad/desaad_orb_aproset.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self.wave_width,
		fEndRadius = self.wave_width,
		vVelocity = vDirection * self.wave_speed,
		fDistance = self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster()) + self:GetCaster():GetCastRangeBonus(),
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		bProvidesVision = true,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iVisionRadius = self.wave_width,
	}

    self.nProjID = ProjectileManager:CreateLinearProjectile( info )
    
	EmitSoundOn( "Hero_ShadowDemon.Disruption.Cast" , self:GetCaster() )
end

--------------------------------------------------------------------------------

function desaad_apocaliptik_strike:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
		}

        ApplyDamage( damage )
        
		self.targets = self.targets - 1
		
		if self.targets <= 1 and self.nProjID then
            ProjectileManager:DestroyLinearProjectile(self.nProjID)

			self.nProjID = nil
			
			return
		end
	end

	return false
end
