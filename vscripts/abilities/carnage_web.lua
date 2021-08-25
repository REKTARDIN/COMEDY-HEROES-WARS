carnage_web = class({})

LinkLuaModifier( "modifier_carnage_web_thinker", "abilities/carnage_web.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_carnage_web_debuff", "abilities/carnage_web.lua",LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
local PROJ_SPEED = 1200

function carnage_web:OnSpellStart()
    if IsServer() then
        local info = {
            EffectName = "particles/stygian/carnage_web_proj.vpcf",
            vSpawnOrigin = self:GetCaster():GetAttachmentOrigin(1),
            Ability = self,
            iMoveSpeed = PROJ_SPEED,
            Source = self:GetCaster(),
            Target = self:GetCursorTarget(),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
        }

        ProjectileManager:CreateTrackingProjectile( info )

        EmitSoundOn( "hero_viper.poisonAttack.Cast.ti7", self:GetCaster() )
    end
end

--------------------------------------------------------------------------------

function carnage_web:OnProjectileHit( hTarget, vLocation )
    if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) then
        EmitSoundOn( "hero_viper.PoisonAttack.Target.ti7", hTarget )

        local duration = self:GetSpecialValueFor( "duration" )
        local damage = self:GetSpecialValueFor( "damage_ptc" )

        ApplyDamage( {
            victim = hTarget,
            attacker = self:GetCaster(),
            damage = (damage / 100) * hTarget:GetMaxHealth(),
            damage_type = self:GetAbilityDamageType(),
            ability = self
        })

        local point = hTarget:GetAbsOrigin()
        local team_id = self:GetCaster():GetTeamNumber()
        local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_carnage_web_thinker", {duration = duration }, point, team_id, false)    
    end

    return true
end


modifier_carnage_web_thinker = class ( {})

function modifier_carnage_web_thinker:OnCreated (event)
    if IsServer() then
        local thinker = self:GetParent ()
        local ability = self:GetAbility ()
        local point = self:GetCaster():GetCursorPosition ()

        self.team_number = thinker:GetTeamNumber()
        self.radius = ability:GetSpecialValueFor("radius")

        local effect_cast = ParticleManager:CreateParticle( "particles/stygian/carnage_web.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
	    ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	    ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 1, 1 ) )
        
        self:AddParticle( effect_cast, false, false, -1, false, true )
    end
end

function modifier_carnage_web_thinker:IsAura ()
    return true
end

function modifier_carnage_web_thinker:GetAuraRadius ()
    return self.radius
end

function modifier_carnage_web_thinker:GetAuraSearchTeam ()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_carnage_web_thinker:GetAuraSearchType ()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_carnage_web_thinker:GetAuraSearchFlags ()
    return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_carnage_web_thinker:GetModifierAura ()
    return "modifier_carnage_web_debuff"
end

modifier_carnage_web_debuff = class ( {})

function modifier_carnage_web_debuff:IsBuff ()
    return false
end

function modifier_carnage_web_debuff:OnCreated(params)
    if IsServer() then 
        self:StartIntervalThink(1.0) 

        self:OnIntervalThink()
    end 
end

function modifier_carnage_web_debuff:OnIntervalThink()
    if IsServer() then 
        local flDamage = self:GetAbility():GetSpecialValueFor("damage_interval") + self:GetAbility():GetCaster():GetAgility()
 
        local damage = {
            victim = self:GetParent(),
            attacker = self:GetAbility():GetCaster(),
            damage = flDamage,
            damage_type = DAMAGE_TYPE_PURE,
            ability = self:GetAbility()
        } 
        
        ApplyDamage( damage )
    end 
end

