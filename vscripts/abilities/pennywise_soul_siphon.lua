pennywise_soul_siphon = class({})
LinkLuaModifier("modifier_pennywise_soul_siphon", "abilities/pennywise_soul_siphon.lua", LUA_MODIFIER_MOTION_NONE)

function pennywise_soul_siphon:GetChannelAnimation()
    return ACT_DOTA_CHANNEL_ABILITY_3
end

function pennywise_soul_siphon:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function pennywise_soul_siphon:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED

    return behavior
end

function pennywise_soul_siphon:GetChannelTime()
    local channel_time = self:GetSpecialValueFor("channel")

    return channel_time
end

function pennywise_soul_siphon:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("channel")

    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE ,
        FIND_ANY_ORDER,
        false
    )

    for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(caster, self, "modifier_pennywise_soul_siphon", {})
    end

    EmitSoundOn("Hero_Visage.GraveChill.Target", caster)
end

function pennywise_soul_siphon:OnChannelFinish( interrupt )
    self:EndSiphon( interrupt )
end

function pennywise_soul_siphon:EndSiphon( interrupt )
    local caster = self:GetCaster()
    if interrupt == false then
        local radius = self:GetSpecialValueFor("break_radius")
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE ,
            FIND_ANY_ORDER,
            false
        )

        for _,enemy in pairs(enemies) do
            if enemy:HasModifier("modifier_pennywise_soul_siphon") then
                local health_damage = self:GetSpecialValueFor("health_damage") / 100
                local hero_heal	= self:GetSpecialValueFor("hero_heal")
                local not_hero_heal = self:GetSpecialValueFor("creep_heal")
                local damage = (enemy:GetMaxHealth() - enemy:GetHealth()) * health_damage
                local damageTable = {victim = enemy,
                    attacker = caster,
                    damage = damage,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self
                }
				ApplyDamage(damageTable)
				
                EmitSoundOn("", enemy)

                if enemy:IsRealHero() then
                    caster:Heal( damage * (hero_heal/100), self )
                else
                    caster:Heal( damage * (not_hero_heal/100), self )
                end

                local damage_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf" , PATTACH_ABSORIGIN_FOLLOW, enemy )
		        ParticleManager:SetParticleControlEnt( damage_particle, 0, enemy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
		        ParticleManager:SetParticleControlEnt( damage_particle, 1, enemy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
		        ParticleManager:ReleaseParticleIndex( damage_particle )

                caster:StartGesture( ACT_DOTA_CAST_ABILITY_3 )
            end
        end

        local cooldown = self:GetCooldownTimeRemaining( )
        local reduce = self:GetSpecialValueFor("cd_refund")

        self:EndCooldown()
        self:StartCooldown( cooldown * (reduce / 100))
    else
        StopSoundOn("Hero_Visage.GraveChill.Target", caster)
    end

    local breakradius = self:GetSpecialValueFor("break_radius") * 2
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        breakradius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE ,
        FIND_ANY_ORDER,
        false
    )

    for _,enemy in pairs(enemies) do
        if enemy:HasModifier("modifier_pennywise_soul_siphon") then
            enemy:RemoveModifierByName("modifier_pennywise_soul_siphon")
        end
    end
end

modifier_pennywise_soul_siphon = class({})
function modifier_pennywise_soul_siphon:IsDebuff() 
    return true 
end

function modifier_pennywise_soul_siphon:IsHidden() 
    return false 
end

function modifier_pennywise_soul_siphon:IsPurgable() 
    return false 
end

function modifier_pennywise_soul_siphon:IsPurgeException() 
    return false 
end

function modifier_pennywise_soul_siphon:OnCreated()
    self:StartIntervalThink(0)
    if IsServer() then
        local particle = "particles/stygian/pennywise_siphon.vpcf"

        local nFXIndex = ParticleManager:CreateParticle( particle, PATTACH_CUSTOMORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin() + Vector( 0, 0, 96 ), true );
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true );
        
        self:AddParticle( nFXIndex, false, false, -1, false, true )
    end
end

function modifier_pennywise_soul_siphon:OnIntervalThink()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local parent = self:GetParent()
    local radius = ability:GetSpecialValueFor("break_radius")
    local base_damage = ability:GetSpecialValueFor("damage")
    local tick_rate = ability:GetSpecialValueFor("tick_rate")
    local channel = ability:GetSpecialValueFor("channel")
    local hero_heal	= ability:GetSpecialValueFor("hero_heal")
    local not_hero_heal = ability:GetSpecialValueFor("creep_heal")

    self:StartIntervalThink(tick_rate)

    if (caster:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() > radius then
        self:Destroy()
    end

    local damage = (tick_rate * base_damage) / channel
    
    local damageTable = {victim = parent,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability
    }

    if parent:IsRealHero() then
        caster:Heal( damage * (hero_heal/100), ability )
    else
        caster:Heal( damage * (not_hero_heal/100), ability )
    end

    ApplyDamage(damageTable)
end
