strange_crystal_spear = class({})

function strange_crystal_spear:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local projectile_name = "particles/hero_strange/glass_spear_proj.vpcf"
	local projectile_distance = self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()
	local projectile_speed = self:GetSpecialValueFor("speed")
	local projectile_radius = 250
	local projectile_vision = 5

	-- calculate direction
	local direction = point - caster:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetOrigin(),
		
	    bDeleteOnHit = true,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius =projectile_radius,
		vVelocity = direction * projectile_speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		-- fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		fVisionDuration = 10,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
    }
    
	ProjectileManager:CreateLinearProjectile(info)

	-- play effects
	local sound_cast = "Hero_Bane.Enfeeble.Cast"
	EmitSoundOn( sound_cast, caster )
	local sound_cast = "Hero_Bane.Enfeeble"
	EmitSoundOn( sound_cast, caster )
end

function strange_crystal_spear:OnProjectileHit( target, location )
    if IsServer() and target then
        local damage = self:GetSpecialValueFor("damage")
    
        -- apply damage
        local damageTable = {
            victim = target,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self, --Optional.
            damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
        }
        
        ApplyDamage(damageTable)
        
        target:AddNewModifier(self:GetCaster(), self, "modifier_orchid_malevolence_debuff", {duration = self:GetSpecialValueFor("active_duration")} )

        -- play effects
        local sound_cast = "Hero_Bane.ProjectileImpact"
        EmitSoundOn( sound_cast, target )
    end
end
