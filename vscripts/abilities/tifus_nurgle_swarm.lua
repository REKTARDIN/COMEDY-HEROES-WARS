tifus_unclean_mist = class({})
LinkLuaModifier( "modifier_tifus_unclean_mist", "lua_abilities/generic/modifier_generic_silenced_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function tifus_unclean_mist:OnSpellStart()

	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local speed = self:GetSpecialValueFor( "wave_speed" )
	local width = self:GetSpecialValueFor( "wave_width" )
	local projectile_name = "particles/units/heroes/hero_drow/drow_silence_wave.vpcf"
	local projectile_distance = self:GetCastRange( point, nil )
    local projectile_direction = point-caster:GetOrigin()
    
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = width,
	    fEndRadius = width,
		vVelocity = projectile_direction * speed,
		
		ExtraData = {
			x = caster:GetOrigin().x,
			y = caster:GetOrigin().y,
		}
    }
    
	ProjectileManager:CreateLinearProjectile(info)

	local sound_cast = "Hero_DrowRanger.Silence"
	EmitSoundOn( sound_cast, caster )
end

function tifus_unclean_mist:OnProjectileHit_ExtraData( target, location, data )

	if not target then return end

	local silence = self:GetSpecialValueFor( "silence_duration" )

	target:AddNewModifier(
		self:GetCaster(), 
		self, 
		"modifier_generic_knockback_lua", 
		{
			duration = duration,
			distance = distance,
			direction_x = vec.x,
			direction_y = vec.y,
		} 
	)

	
	target:AddNewModifier(
		self:GetCaster(), 
		self, 
		"modifier_generic_silenced_lua", 
		{ duration = silence } 
	)

	-- play effects
	self:PlayEffects( target )
end

--------------------------------------------------------------------------------
function tifus_unclean_mist:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_drow/drow_hero_silence.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end