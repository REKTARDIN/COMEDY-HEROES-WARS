spawn_blaze_of_glory = class({})

function spawn_blaze_of_glory:GetChannelTime()
	return self:GetSpecialValueFor( "count" ) * self:GetSpecialValueFor( "rate" )
end

function spawn_blaze_of_glory:OnSpellStart()	
	self.duration = self:GetSpecialValueFor( "duration" )
	self.speed = self:GetSpecialValueFor( "speed" )
	self.offset = self:GetSpecialValueFor( "offset" )
	self.count = self:GetSpecialValueFor( "count" )
	self.rate = self:GetSpecialValueFor( "rate" )
	self.range = self:GetSpecialValueFor( "range" )

	self.vTargetLocation = self:GetCursorPosition()
	self.flAccumulatedTime = 0.0
	self.vDirection = self.vTargetLocation - self:GetCaster():GetOrigin() 
	self.nDaggersThrown = 0

	local vDirection = self.vTargetLocation  - self:GetCaster():GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()
	
	self:ThrowDagger( vDirection )
end

--------------------------------------------------------------------------------

function spawn_blaze_of_glory:OnChannelThink( flInterval )
	self.flAccumulatedTime = self.flAccumulatedTime + flInterval 
	if self.flAccumulatedTime >= self.rate then
		self.flAccumulatedTime = self.flAccumulatedTime - self.rate

		local vOffset = RandomVector( self.offset )
		vOffset.z = 0.0
		
		local vDirection = ( self.vTargetLocation + vOffset ) - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		self:ThrowDagger( vDirection )
	end
end

--------------------------------------------------------------------------------

function spawn_blaze_of_glory:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) then

        EmitSoundOn( "Hero_Sniper.MKG_impact", hTarget )
		
		local d = self:GetSpecialValueFor("base_damage")

		if self:GetCaster():HasModifier("modifier_spawn_spawn_active") then
			d = d + (self:GetCaster():GetAverageTrueAttackDamage(hTarget) * (self:GetSpecialValueFor("ulti_damage_ptc") / 100))
		end

        local damage = {
            victim = hTarget,
            attacker = self:GetCaster(),
            damage = d,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }

        ApplyDamage( damage )
	end

	return true
end

--------------------------------------------------------------------------------

function spawn_blaze_of_glory:ThrowDagger( vDirection )
    local info = 
	{
		EffectName = "particles/hero_spawn/spawn_glory_weapon_attack.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetAttachmentOrigin(3), 
		fStartRadius = 50.0,
		fEndRadius = 50.0,
		vVelocity = vDirection * self.speed,
		fDistance = self.range,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}
	
    ProjectileManager:CreateLinearProjectile( info )
    
	EmitSoundOn( "Hero_Sniper.MKG_attack", self:GetCaster() )

    self.nDaggersThrown = self.nDaggersThrown + 1
    
	if self.nDaggersThrown >= self.count then
		self:EndChannel( false )
	end
end

--------------------------------------------------------------------------------