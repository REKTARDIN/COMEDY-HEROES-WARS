spawn_raising_hell = class({})

--------------------------------------------------------------------------------
-- Ability Start
function spawn_raising_hell:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
    local point = self:GetCursorPosition()

	local projectile_name = "particles/econ/items/lion/lion_ti9/lion_spell_impale_ti9.vpcf"
	local projectile_radius = self:GetSpecialValueFor( "width" )
	local projectile_speed = self:GetSpecialValueFor( "speed" )
	local projectile_direction = self:GetCaster():GetForwardVector()
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = self:GetSpecialValueFor("length_buffer"),
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
    }
    
	ProjectileManager:CreateLinearProjectile(info)

	-- play effects
	local sound_cast = "Hero_Lion.Impale"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Projectile
function spawn_raising_hell:OnProjectileHit( target, location )
    if not target then return end

	local stun = self:GetSpecialValueFor( "duration" )
	local damage = self:GetAbilityDamage()

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}

    if not target:IsMagicImmune() then
        -- stun
        target:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_stunned", -- modifier name
            { duration = stun } -- kv
        )
    end
	
	-- -- Create Particle
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
    EmitSoundOn( "Hero_Lion.ImpaleHitTarget", target )
    
    ApplyDamage(damageTable)
end
