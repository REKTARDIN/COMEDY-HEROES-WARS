beast_crush = class({})

function beast_crush:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function beast_crush:GetPlaybackRateOverride()
    return 1.4
end

function beast_crush:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor( "knockup_duration" )
    local radius = self:GetSpecialValueFor( "radius" )
    local height = self:GetSpecialValueFor( "knockup_height" )
    local damage = self:GetSpecialValueFor( "damage" )

    local damageTable = {
        -- victim = target,
        attacker = caster,
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self, --Optional.
    }
    -- find enemies
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),	-- int, your team number
        caster:GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    local passiveproc = false

    local center = caster:GetAbsOrigin()

    for _,enemy in pairs(enemies) do
        -- knockup
        local knockback = {
			should_stun = true,                                
			knockback_duration = duration,
			duration = duration,
			knockback_distance = 0,
			knockback_height = height,
			center_x = center.x,
			center_y = center.y,
			center_z = center.z
		}
        enemy:RemoveModifierByName( "modifier_knockback" )
        enemy:AddNewModifier( caster, self, "modifier_knockback", knockback )

        damageTable.victim = enemy
        ApplyDamage(damageTable)
    end

  
    self:PlayEffects()

    caster:EmitSound( "Hero_EarthSpirit.BoulderSmash.Damage" )
end

function beast_crush:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_cookie_landing.vpcf"
    local sound_cast = "Hero_Leshrac.Split_Earth"

    local radius = self:GetSpecialValueFor( "radius" )

    -- -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
    ParticleManager:ReleaseParticleIndex( effect_cast )

    -- Create Sound
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast, self:GetCaster() )
end
