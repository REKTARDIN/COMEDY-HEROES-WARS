gambit_kinetic_earth_split = class({})

function gambit_kinetic_earth_split:OnSpellStart()

    if not IsServer() then  
        return 
    end

	local caster = self:GetCaster()
	local caster_position = caster:GetAbsOrigin()
	local target_point = self:GetCursorPosition()
	local playerID = caster:GetPlayerID()
	local scepter = caster:HasScepter()

	-- Ability specials
	local radius = self:GetSpecialValueFor("radius")
	local slow_duration = self:GetSpecialValueFor("slow_duration")
	local effect_delay = self:GetSpecialValueFor("crack_time")
	local crack_width = self:GetSpecialValueFor("crack_width")
	local crack_distance = self:GetSpecialValueFor("crack_distance")
	local crack_damage = self:GetSpecialValueFor("damage_pct") / 2
	local caster_forward_vector = caster:GetForwardVector()
	local crack_ending = caster_position + caster_forward_vector * crack_distance

	EmitSoundOn("Hero_ElderTitan.EarthSplitter.Cast", caster)

	-- Add start particle effect
	local particle_start_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle_start_fx, 0, caster_position)
	ParticleManager:SetParticleControl(particle_start_fx, 1, crack_ending)
	ParticleManager:SetParticleControl(particle_start_fx, 3, Vector(0, effect_delay, 0))

	-- Destroy trees in the radius
	GridNav:DestroyTreesAroundPoint(target_point, radius, false)

	-- Wait for the effect delay
	Timers:CreateTimer(effect_delay, function()
		EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)

		local enemies = FindUnitsInLine(caster:GetTeamNumber(), caster_position, crack_ending, nil, crack_width, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags())
		for _, enemy in pairs(enemies) do
            enemy:Interrupt()

            local knockback = {
                should_stun = 1,
                knockback_duration = 1,
                duration = 1,
                knockback_distance = 0,
                knockback_height = 200,
                center_x = caster:GetAbsOrigin().x,
                center_y = caster:GetAbsOrigin().y,
                center_z = caster:GetAbsOrigin().z 
            }
            
			enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_knockback", knockback )
			
			ApplyDamage({victim = enemy, attacker = caster, damage = enemy:GetMaxHealth() * crack_damage * 0.01, damage_type = DAMAGE_TYPE_PHYSICAL, ability = self})
			ApplyDamage({victim = enemy, attacker = caster, damage = enemy:GetMaxHealth() * crack_damage * 0.01, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
		end

		ParticleManager:ReleaseParticleIndex(particle_start_fx)
	end)
end
