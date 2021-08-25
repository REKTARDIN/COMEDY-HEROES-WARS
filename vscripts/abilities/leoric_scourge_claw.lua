scourge_claw = class({})

--------------------------------------------------------------------------------

function scourge_claw:OnSpellStart()
	local vDirection = self:GetCaster():GetOrigin() - self:GetCursorPosition() 
    vDirection = vDirection:Normalized()
    
    local range = self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() )
    local spawn_origin = self:GetCaster():GetAbsOrigin() + (self:GetCursorPosition() - self:GetCaster():GetOrigin()):Normalized() * range 

	self.wave_speed = self:GetSpecialValueFor( "wave_speed" )
	self.wave_width = self:GetSpecialValueFor( "wave_width" )
	self.vision_aoe = self:GetSpecialValueFor( "vision_aoe" )
	self.vision_duration = self:GetSpecialValueFor( "vision_duration" )
	self.tooltip_duration = self:GetSpecialValueFor( "tooltip_duration" )
	self.wave_damage = self:GetSpecialValueFor( "wave_damage" )

	local info = {
		EffectName = "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf",
		Ability = self,
		vSpawnOrigin = spawn_origin, 
		fStartRadius = self.wave_width,
		fEndRadius = self.wave_width,
		vVelocity = vDirection * self.wave_speed,
		fDistance = range,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		bProvidesVision = true,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iVisionRadius = self.vision_aoe,
	}

	self.flVisionTimer = self.wave_width / self.wave_speed
	self.flLastThinkTime = GameRules:GetGameTime()
	self.nProjID = ProjectileManager:CreateLinearProjectile( info )
	EmitSoundOn( "Hero_VengefulSpirit.WaveOfTerror" , self:GetCaster() )
end

--------------------------------------------------------------------------------

function scourge_claw:OnProjectileThink( vLocation )
	self.flVisionTimer = self.flVisionTimer - ( GameRules:GetGameTime() - self.flLastThinkTime )

	if self.flVisionTimer <= 0.0 then
		local vVelocity = ProjectileManager:GetLinearProjectileVelocity( self.nProjID )
		AddFOWViewer( self:GetCaster():GetTeamNumber(), vLocation + vVelocity * ( self.wave_width / self.wave_speed ), self.vision_aoe, self.vision_duration, false )
		self.flVisionTimer = self.wave_width / self.wave_speed
	end
end


--------------------------------------------------------------------------------

function scourge_claw:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.wave_damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = this,
		}

		ApplyDamage( damage )
	end

	return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------