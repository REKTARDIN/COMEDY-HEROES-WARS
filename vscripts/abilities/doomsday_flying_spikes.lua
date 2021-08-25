--------------------------------------------------------------------------------

doomsday_flying_spikes = class({})

local PTC_DAMAGE = 0.8

--------------------------------------------------------------------------------
-- Ability Start
function doomsday_flying_spikes:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local origin = caster:GetOrigin()

	-- load data
	local projectile_name = "particles/stygian/doomsday_bone_spikes.vpcf"
	local projectile_distance = self:GetCastRange( point, nil )
	local projectile_start_radius = self:GetSpecialValueFor( "blast_width_initial" )/2
	local projectile_end_radius = self:GetSpecialValueFor( "blast_width_end" )/2
	local projectile_speed = self:GetSpecialValueFor( "blast_speed" )
	local projectile_direction = point-origin
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()	

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = self:GetAbilityTargetTeam(),
	    iUnitTargetFlags = self:GetAbilityTargetFlags(),
	    iUnitTargetType = self:GetAbilityTargetType(),
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_start_radius,
	    fEndRadius =projectile_end_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bProvidesVision = false,
		ExtraData = {
			pos_x = origin.x,
			pos_y = origin.y,
		}
    }
    
	ProjectileManager:CreateLinearProjectile(info)

	-- play sound
	EmitSoundOn( "Hero_Bristleback.PistonProngs.QuillSpray.Cast", caster )
end
--------------------------------------------------------------------------------
-- Projectile
function doomsday_flying_spikes:OnProjectileHit_ExtraData( target, location, extraData )
	if not target then return end

	-- load data
    local caster = self:GetCaster()
    
    local damage = self:GetSpecialValueFor("damage")

    if self:GetCaster():HasTalent("special_bonus_unique_doomsday_1") then
        damage = damage + self:GetCaster():FindTalentValue("special_bonus_unique_doomsday_1")
    end

    local counter = (self:GetCaster():GetAbilityByIndex(5).m_iEvolutionCounter or 0)

    if self:GetCaster():HasScepter() then
        damage = damage + (self:GetSpecialValueFor("evolution_damage") * counter)
    end

	local hp_damage = self:GetSpecialValueFor("damage_max_hp_ptc")

	damage = damage + (self:GetCaster():GetMaxHealth() * hp_damage / 100)
	
	local nFXIndex = ParticleManager:CreateParticle( "", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	-- damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}

    EmitSoundOn("Hero_Bristleback.QuillSpray.Target", target)

    ApplyDamage(damageTable)
end
