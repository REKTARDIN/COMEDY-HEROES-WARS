green_arrow_crown_shot = class({})

function green_arrow_crown_shot:OnSpellStart()
	
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local sound_cast = "Ability.PowershotPull"
	EmitSoundOnLocationForAllies( caster:GetOrigin(), sound_cast, caster )
end

function green_arrow_crown_shot:OnChannelFinish( bInterrupted )

	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime())/self:GetChannelTime()

	local damage = self:GetSpecialValueFor( "crown_shot_damage" )
	local reduction = 1-self:GetSpecialValueFor( "damage_reduction" )
	local vision_radius = self:GetSpecialValueFor( "vision_radius" )
	
	local projectile_name = "particles/stygian/green_arrow_crown_shot.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "arrow_speed" )
	local projectile_distance = self:GetSpecialValueFor( "arrow_range" )
	local projectile_radius = self:GetSpecialValueFor( "arrow_width" )
	local projectile_direction = point-caster:GetOrigin()
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bProvidesVision = true,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}
	
	local projectile = ProjectileManager:CreateLinearProjectile(info)

	self.projectiles[projectile] = {}
	self.projectiles[projectile].damage = damage*channel_pct
	self.projectiles[projectile].reduction = reduction

	local sound_cast = "Ability.Powershot"
	EmitSoundOn( sound_cast, caster )
end

green_arrow_crown_shot.projectiles = {}

function green_arrow_crown_shot:OnProjectileHitHandle( target, location, handle )
	if not target then
		
		self.projectiles[handle] = nil

		local vision_radius = self:GetSpecialValueFor( "vision_radius" )
		local vision_duration = self:GetSpecialValueFor( "vision_duration" )
		AddFOWViewer( self:GetCaster():GetTeamNumber(), location, vision_radius, vision_duration, false )

		return
	end

	local data = self.projectiles[handle]
	local damage = data.damage

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, 
	}
	ApplyDamage(damageTable)

	data.damage = damage * data.reduction

	local sound_cast = "Hero_Windrunner.PowershotDamage"
	EmitSoundOn( sound_cast, target )
end

function green_arrow_crown_shot:OnProjectileThink( location )
	local tree_width = self:GetSpecialValueFor( "tree_width" )
	GridNav:DestroyTreesAroundPoint(location, tree_width, false)	
end