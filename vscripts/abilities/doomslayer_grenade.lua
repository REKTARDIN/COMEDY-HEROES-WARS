doomslayer_grenade = class({})

LinkLuaModifier( "modifier_doomslayer_grenade_thinker", "abilities/doomslayer_grenade.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function doomslayer_grenade:Spawn()
    if IsServer() then
        self:SetThink( "OnIntervalThink", self, 0.25 )
    end
end

function doomslayer_grenade:OnIntervalThink()
    if IsServer() then
        self:SetActivated(not self:GetCaster():HasModifier("modifier_doomslayer_doom"))
    end

    return 0.25
end

function doomslayer_grenade:IsStealable()
   return false
end

function doomslayer_grenade:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function doomslayer_grenade:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_AOE
end

function doomslayer_grenade:OnSpellStart()
    if IsServer() then
        local target = CreateModifierThinker(self:GetCaster(), self, "modifier_doomslayer_grenade_thinker", nil, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)

        local info = {
			EffectName = "particles/units/heroes/hero_demonartist/demonartist_unstable_concoction_projectile.vpcf",
			Ability = self,
			iMoveSpeed = self:GetSpecialValueFor( "movement_speed" ),
			Source = self:GetCaster(),
			Target = target,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
		}

        ProjectileManager:CreateTrackingProjectile( info )

        EmitSoundOn( "Hero_Alchemist.UnstableConcoction.Throw", self:GetCaster() )
    end
end

--------------------------------------------------------------------------------

function doomslayer_grenade:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
        EmitSoundOn( "Hero_Alchemist.UnstableConcoction.Stun", hTarget )

        if IsServer() then
            local caster = self:GetCaster()
  
            local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil );
            ParticleManager:SetParticleControl( nFXIndex, 0, vLocation);
            ParticleManager:ReleaseParticleIndex( nFXIndex );
    
            local nearby_targets = FindUnitsInRadius(caster:GetTeam(), vLocation, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    
            for i, target in pairs(nearby_targets) do
                local dist = (target:GetAbsOrigin() - vLocation):Length2D()
                local r = self:GetSpecialValueFor("max_damage") - dist + self:GetAbilityDamage()
    
                local damage = {
                    victim = target,
                    attacker = caster,
                    damage = r,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self
                }
                
                target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun")})
    
                ApplyDamage(damage)  
            end
        end

		UTIL_Remove(hTarget)
	end

	return true
end


modifier_doomslayer_grenade_thinker = class ({})

function modifier_doomslayer_grenade_thinker:CheckState()
    return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end
