joker_pinecake = class({})

LinkLuaModifier( "modifier_joker_pinecake_thinker", "abilities/joker_pinecake.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function joker_pinecake:IsStealable()
   return false
end

function joker_pinecake:GetAOERadius()
    return self:GetSpecialValueFor("impact_radius")
end

function joker_pinecake:OnSpellStart()
    if IsServer() then
        local target = CreateModifierThinker(self:GetCaster(), self, "modifier_joker_pinecake_thinker", nil, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)

        local info = {
			EffectName = "particles/hero_joker/joker_cake_projectile.vpcf",
			Ability = self,
			iMoveSpeed = self:GetSpecialValueFor( "projectile_speed" ),
			Source = self:GetCaster(),
			Target = target,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}

        ProjectileManager:CreateTrackingProjectile( info )

        EmitSoundOn( "Hero_Snapfire.FeedCookie.Cast", self:GetCaster() )
    end
end

--------------------------------------------------------------------------------

function joker_pinecake:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
        EmitSoundOn( "Hero_Techies.Suicide", hTarget )

        if IsServer() then
            local caster = self:GetCaster()
            local knockback_duration = self:GetSpecialValueFor("knockback_duration") + (IsHasTalent(caster:GetPlayerOwnerID(), "special_bonus_unique_joker_1") or 0)
            local stun = knockback_duration + 0.2
            local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil );
            ParticleManager:SetParticleControl( nFXIndex, 0, vLocation);
            ParticleManager:ReleaseParticleIndex( nFXIndex );
    
            local nearby_targets = FindUnitsInRadius(caster:GetTeam(), vLocation, nil, self:GetSpecialValueFor("impact_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    
            for i, target in pairs(nearby_targets) do
                local damage = {
                    victim = target,
                    attacker = caster,
                    damage = self:GetAbilityDamage(),
                    damage_type = self:GetAbilityDamageType(),
                    ability = self
                }

                local knockback = {
                    should_stun = 0,                                
                    knockback_duration = knockback_duration,
                    duration = stun,
                    knockback_distance = 275,
                    knockback_height = 50,
                    center_x = caster:GetAbsOrigin().x,
                    center_y = caster:GetAbsOrigin().y,
                    center_z = caster:GetAbsOrigin().z,
                }
                
                target:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback)
                EmitSoundOn( "", target )
                
                self:GetCaster():PerformAttack(target, false, false, true, true, false, false, true)

                ApplyDamage(damage)  
            end
        end

		UTIL_Remove(hTarget)
	end

	return true
end


modifier_joker_pinecake_thinker = class ({})

function modifier_joker_pinecake_thinker:CheckState()
    return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end
