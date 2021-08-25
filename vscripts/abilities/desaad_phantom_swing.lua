--------------------------------------------------------------------------------
desaad_phantom_swing = class({})
LinkLuaModifier( "modifier_desaad_phantom_swing_debuff", "abilities/desaad_phantom_swing", LUA_MODIFIER_MOTION_NONE )

local NONE = 0
local SPEED = 1600

--------------------------------------------------------------------------------

function desaad_phantom_swing:OnSpellStart()
	self.vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	self.vDirection = self.vDirection:Normalized()

    EmitSoundOn("Hero_ShadowDemon.ShadowPoison.Release", self:GetCaster() )

	local info = {
		EffectName = "particles/desaad/desaad_sphere.vpcf",
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = NONE,
		fEndRadius = NONE,
		vVelocity = self.vDirection * SPEED,
		fDistance = (self:GetCursorPosition() - self:GetCaster():GetOrigin()):Length2D(),
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
    }
    
    self.nProjID = ProjectileManager:CreateLinearProjectile( info )
    
	EmitSoundOn( "Hero_VengefulSpirit.WaveOfTerror" , self:GetCaster() )
end

function desaad_phantom_swing:OnProjectileHit( hTarget, vLocation )
    if hTarget == nil then
        local caster = self:GetCaster()

        local radius = self:GetSpecialValueFor("radius")
        local angle = self:GetSpecialValueFor("angle")/2
        local duration = self:GetSpecialValueFor("debuff_duration")

        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), vLocation, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false )
        if #units > 0 then
            for _,enemy in pairs(units) do
                -- attack
                local damage = {
                    victim = enemy,
                    attacker = self:GetCaster(),
                    damage = self:GetAbilityDamage() + (caster:GetMana() * ((self:GetSpecialValueFor("mana_damage") + (IsHasTalent(caster:GetPlayerOwnerID(), "special_bonus_unique_desaad_3") or 0)) / 100)),
                    damage_type = self:GetAbilityDamageType(),
                    ability = self,
                }

                ApplyDamage( damage )

                if not enemy:HasModifier( "modifier_desaad_phantom_swing_debuff" ) then
                    enemy:AddNewModifier(
                        caster, -- player source
                        self, -- ability source
                        "modifier_desaad_phantom_swing_debuff", -- modifier name
                        {
                            duration = duration
                        } -- kv
                    )
                else 
                    local mod = enemy:FindModifierByName("modifier_desaad_phantom_swing_debuff")

                    if mod:GetStackCount() < self:GetSpecialValueFor("max_stacks") then
                        mod:IncrementStackCount()

                        mod:SetDuration(duration, true)
                    end
                end 

                -- Create Particle
                local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_shadow_demon/shadow_demon_purge_v2_finale03.vpcf", PATTACH_WORLDORIGIN, enemy )
                ParticleManager:SetParticleControl( effect_cast, 0, enemy:GetOrigin() )
                ParticleManager:SetParticleControl( effect_cast, 1, enemy:GetOrigin() )
                ParticleManager:SetParticleControlForward( effect_cast, 5, self.vDirection )
                ParticleManager:ReleaseParticleIndex( effect_cast )

                -- Create Sound
                EmitSoundOn( "Hero_ShadowDemon.DemonicPurge.Damage", enemy )
            end
        end

        -- Create Particle
        local effect_cast = ParticleManager:CreateParticle( "particles/desaad/desaad_sphere_explodes.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( effect_cast, 0, vLocation )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector(radius, radius, 0) )
        ParticleManager:ReleaseParticleIndex( effect_cast )
	end

	return false
end


modifier_desaad_phantom_swing_debuff =
    class(
    {
        IsPurgable = function()
            return true
        end,
        IsHidden = function()
            return false
        end,
        GetEffectName = function()
            return "particles/units/heroes/hero_demonartist/demonartist_engulf_disarm/items2_fx/heavens_halberd_debuff.vpcf"
        end,
        GetEffectAttachType = function()
            return PATTACH_ABSORIGIN_FOLLOW
        end,
        GetAttributes = function()
            return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
        end,
        DeclareFunctions = function()
            return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
        end
    }
)

function modifier_desaad_phantom_swing_debuff:GetModifierMagicalResistanceBonus(params)
   return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("magical_resust_red")
end
