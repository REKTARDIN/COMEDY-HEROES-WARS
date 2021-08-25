infinity_energy_wave = class({})

--------------------------------------------------------------------------------
-- Ability Start
function infinity_energy_wave:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local max_duration = self:GetSpecialValueFor("debuff_max_time")
    local max_damage = self:GetSpecialValueFor("max_damage")
    local mana_damage = self:GetSpecialValueFor("mana_damage_ptc") / 100 * self:GetCaster():GetMana()
    local radius = self:GetSpecialValueFor("radius")

    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	if #units > 0 then
        for _,unit in pairs(units) do
            local mult = 1 - ((self:GetCaster():GetOrigin() - unit:GetOrigin()):Length2D() / radius)
            local duration = max_duration * mult
            local damage = max_damage * mult

            ApplyDamage({
                victim = unit,
                attacker = self:GetCaster(),
                damage = damage + mana_damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self, --Optional.
            })

			unit:AddNewModifier( self:GetCaster(), self, "modifier_silence", { duration = duration } )
		end
    end

    print( MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS_PERCENTAGE )
    
    local nFXIndex = ParticleManager:CreateParticle( "particles/hero_infinity/infinity_energy_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
    ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius, radius, 0) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "Hero_Phoenix.IcarusDive.Stop", caster )
end