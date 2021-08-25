deadpool_circular_blow = class({})

LinkLuaModifier("modifier_deadpool_circular_blow", "abilities/deadpool_circular_blow.lua", LUA_MODIFIER_MOTION_NONE)

function deadpool_circular_blow:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier( caster, self, "modifier_deadpool_circular_blow", { duration = self:GetSpecialValueFor("delay") } )
end

modifier_deadpool_circular_blow = class({})
function modifier_deadpool_circular_blow:IsDebuff() 
    return false 
end

function modifier_deadpool_circular_blow:IsHidden()
    return true 
end

function modifier_deadpool_circular_blow:IsPurgable() 
    return false 
end

function modifier_deadpool_circular_blow:IsPurgeException() 
    return false 
end

function modifier_deadpool_circular_blow:RemoveOnDeath() 
    return true 
end

function modifier_deadpool_circular_blow:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true
    }
    return state
end

function modifier_deadpool_circular_blow:OnCreated()
    
end

function modifier_deadpool_circular_blow:OnDestroy()
    if IsServer() then
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local damage = ability:GetSpecialValueFor("damage")
    local attack_damage = ability:GetSpecialValueFor("attack_damage")
    local radius = ability:GetSpecialValueFor("radius")

    damage = caster:GetAverageTrueAttackDamage( self:GetParent() ) * attack_damage / 100 

    caster:RemoveGesture( ACT_DOTA_CAST_ABILITY_2 )
    caster:StartGesture( ACT_DOTA_CAST_ABILITY_2 )

    if caster:IsAlive() then
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(),	
            caster:GetAbsOrigin(),
            nil,	
            radius,	
            DOTA_UNIT_TARGET_TEAM_ENEMY,	
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	
            DOTA_UNIT_TARGET_FLAG_NONE,	
            0,	
            false	
        )

        local damageTable = {
            attacker = caster,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            ability = ability, 
        }

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            damageTable.damage = damage
            ApplyDamage( damageTable )

            if not enemy:IsAlive() then
                self:GetAbility():EndCooldown()
            end    
        end

			EmitSoundOn("Hero_Axe.CounterHelix", caster)
			
            local particle_cast = "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf"
            local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster )
            ParticleManager:ReleaseParticleIndex( effect_cast )
        end
    end
end
