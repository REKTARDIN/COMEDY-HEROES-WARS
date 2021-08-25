if not collector_sanity_drain then collector_sanity_drain = class({}) end

LinkLuaModifier ("modifier_collector_sanity_drain", "abilities/collector_sanity_drain.lua", LUA_MODIFIER_MOTION_NONE)

function collector_sanity_drain:IsRefreshable() return true end

function collector_sanity_drain:GetCooldown( nLevel )
    if IsServer() then if self:GetCaster():HasScepter() then return self:GetSpecialValueFor("scepter_cooldown") end end 
    return self.BaseClass.GetCooldown( self, nLevel )
end

function collector_sanity_drain:GetAOERadius()
    if self:GetCaster():HasScepter() then 
        return self:GetSpecialValueFor("scepter_radius")
    end
    return
end

function collector_sanity_drain:GetBehavior()
    if self:GetCaster():HasScepter() then 
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
end

function collector_sanity_drain:OnSpellStart()
    if IsServer() then
        local hTarget = self:GetCursorTarget()
        local damage_delay = self:GetSpecialValueFor( "delay" )

        EmitSoundOn("Hero_VoidSpirit.Pulse.Destroy", self:GetCaster())

        if hTarget ~= nil then
            if ( not hTarget:TriggerSpellAbsorb( self ) ) then
                if self:GetCaster():HasScepter() then
                    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), hTarget, self:GetSpecialValueFor("radius_scepter"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
                    if #units > 0 then
                        for _,  unit in pairs(units) do
                            EmitSoundOn("Hero_VoidSpirit.AstralStep.MarkExplosionAOE", unit)

                            unit:AddNewModifier( self:GetCaster(), self, "modifier_collector_sanity_drain", { duration = damage_delay } )
                        end
                    end 
                else   
                    hTarget:AddNewModifier( self:GetCaster(), self, "modifier_collector_sanity_drain", { duration = damage_delay } )
                  
                    EmitSoundOn( "Hero_VoidSpirit.AstralStep.MarkExplosionAOE", hTarget )
                end
            end

            local nFXIndex = ParticleManager:CreateParticle( "particles/heroes/hero_collector/collector_sanity_drain.vpcf", PATTACH_CUSTOMORIGIN, nil );
            ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );
            ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true );
            ParticleManager:SetParticleControlEnt( nFXIndex, 2, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true );
            ParticleManager:ReleaseParticleIndex( nFXIndex );
        end
    end
end

if modifier_collector_sanity_drain == nil then modifier_collector_sanity_drain = class({}) end

function modifier_collector_sanity_drain:OnDestroy()
    if IsServer() then
        local damage = self:GetAbility():GetSpecialValueFor("damage_per_mana") * (self:GetParent():GetMaxMana() - self:GetParent():GetMana()) 

        ApplyDamage({
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = damage + self:GetAbility():GetAbilityDamage(),
            damage_type = self:GetAbility():GetAbilityDamageType(),
            ability = self:GetAbility()
        })
    end 
end


function modifier_collector_sanity_drain:IsHidden() return true end
function modifier_collector_sanity_drain:IsPurgable() return false end
function modifier_collector_sanity_drain:RemoveOnDeath() return true end