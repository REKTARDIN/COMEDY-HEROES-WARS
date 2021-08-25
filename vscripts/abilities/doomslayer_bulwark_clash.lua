-------------------------------------------------------------------------------
doomslayer_bulwark_clash = class({})

function doomslayer_bulwark_clash:Spawn()
    if IsServer() then
        self:SetThink( "OnIntervalThink", self, 0.25 )
    end
end

function doomslayer_bulwark_clash:OnIntervalThink()
    if IsServer() then
        self:SetHidden(not self:GetCaster():HasModifier("modifier_doomslayer_doom"))
    end

    return 0.25
end

--------------------------------------------------------------------------------
-- Ability Start
function doomslayer_bulwark_clash:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local radius = self:GetSpecialValueFor("radius")
	local angle = self:GetSpecialValueFor("angle")/2
	local duration = self:GetSpecialValueFor("knockback_duration")

	-- find units
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	-- precache
	local origin = caster:GetOrigin()
	local cast_direction = (point-origin):Normalized()
	local cast_angle = VectorToAngles( cast_direction ).y

	-- for each units
	local caught = false
	for _,enemy in pairs(enemies) do
		-- check within cast angle
		local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
		local enemy_angle = VectorToAngles( enemy_direction ).y
		local angle_diff = math.abs( AngleDiff( cast_angle, enemy_angle ) )
		if angle_diff<=angle then
			-- attack
            local damage = (self:GetCaster():GetMaxHealth() * self:GetSpecialValueFor("hp_damage") / 100) + self:GetAbilityDamage()

            ApplyDamage ({victim = enemy, attacker = self:GetCaster(), damage = damage, damage_type = self:GetAbilityDamageType(), ability = self, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION  + DOTA_DAMAGE_FLAG_HPLOSS })

			enemy:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "modifier_stunned", -- modifier name
                {
                    duration = duration,
                } -- kv
            )

            caught = true

            -- Create Particle
            local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", PATTACH_WORLDORIGIN, enemy )
            ParticleManager:SetParticleControl( effect_cast, 0, enemy:GetOrigin() )
            ParticleManager:SetParticleControl( effect_cast, 1, enemy:GetOrigin() )
            ParticleManager:SetParticleControlForward( effect_cast, 1, cast_direction )
            ParticleManager:ReleaseParticleIndex( effect_cast )

            -- Create Sound
            EmitSoundOn( "Hero_Mars.Shield.Crit", enemy )
		end
	end

	local sound_cast = "Hero_Mars.Shield.Cast"
    
    if not caught then
		sound_cast = "Hero_Mars.Shield.Cast.Small"
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_mars/mars_shield_bash.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, cast_direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), sound_cast, self:GetCaster() )
end
