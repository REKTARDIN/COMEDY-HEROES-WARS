outsider_manavoid = class({})

--------------------------------------------------------------------------------
-- Ability Start
function outsider_manavoid:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	-- initial damage that was deprecated
	local damage = self:GetAbilityDamage()
	local mana_burn_ptc = self:GetSpecialValueFor("mana_burn_ptc")
    local mana_damage_ptc = self:GetSpecialValueFor("mana_damage_ptc")
	local range = self:GetSpecialValueFor("radius")

	-- find echoing units
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NONE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
    )

	for _,enemy in pairs(enemies) do
		-- initial damage (deprecated)
        if (not enemy:IsMagicImmune()) then
            local mana = enemy:GetMana() * (mana_burn_ptc / 100)
            local dmg = damage + (mana * (mana_damage_ptc / 100))

            enemy:SetMana(enemy:GetMana() - mana)

			ApplyDamage({
                victim = enemy,
                attacker = self:GetCaster(),
                damage = dmg,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self, --Optional.
            })
		end
    end
    
    -- Create Particle
	local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_echoslam_start_v2.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl( effect_cast, 0, caster:GetAbsOrigin() )
    ParticleManager:SetParticleControl( effect_cast, 1, Vector( range, range, 0 ) )
    ParticleManager:SetParticleControl( effect_cast, 10, Vector( 1, 0, 0 ) )
    ParticleManager:SetParticleControl( effect_cast, 11, Vector( 1, 1, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( "Hero_EarthShaker.EchoSlamEcho.Arcana", self:GetCaster() )
end
