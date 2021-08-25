medivh_dark_blast = class({})

function medivh_dark_blast:GetCooldown( nLevel )
	if self:GetCaster():HasScepter() then return self:GetSpecialValueFor("cooldown_scepter") end return self.BaseClass.GetCooldown( self, nLevel )
end

function medivh_dark_blast:OnSpellStart()

    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local projectile_distance = self:GetSpecialValueFor("blast_range") + caster:GetCastRangeBonus()
    local projectile_speed = self:GetSpecialValueFor("blast_speed")
    local projectile_radius = self:GetSpecialValueFor("blast_radius")
    local projectile_vision = self:GetSpecialValueFor("blast_vision_radius")
    local sound = "Medivh_Dark_Blast.Cast"
    local blast_effect = "particles/stygian/medivh_arcane_blast.vpcf"

    local direction = point - caster:GetOrigin()
    direction.z = 0
    direction = direction:Normalized()

    local info = {  
        Source  = caster,
        Ability = self,
        vSpawnOrigin = caster:GetOrigin(),
        iUnitTargetTeam  = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType  = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName   = blast_effect,
        fDistance    = projectile_distance,
        fStartRadius = projectile_radius,
        fEndRadius   = projectile_radius,
        vVelocity    = direction * projectile_speed,                  
        bProvidesVision = true,
        iVisionRadius = projectile_vision,
        fVisionDuration = 3,
        iVisionTeamNumber = caster:GetTeamNumber() 
    }

    ProjectileManager:CreateLinearProjectile(info)

    EmitSoundOn(sound, caster)
end

function medivh_dark_blast:OnProjectileHit(hTarget, vLocation)

    local base_damage = self:GetSpecialValueFor("base_damage")
    local sound = "Medivh_Dark_Blast.Hit"
    local damage = base_damage 
    local damage_type = DAMAGE_TYPE_MAGICAL
    

    local damage_table = {  
        victim = hTarget,                     
        attacker = self:GetCaster(), 
        damage = damage,
        damage_type = damage_type,
        ability = self 
    }
            
    ApplyDamage(damage_table)

    EmitSoundOn(sound, hTarget)
end