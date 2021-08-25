scarlett_witch_devil_within = class({})

LinkLuaModifier( "modifier_scarlett_witch_devil_within", "abilities/scarlett_witch_devil_within.lua", LUA_MODIFIER_MOTION_NONE )

function scarlett_witch_devil_within:GetCooldown( nLevel )
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_cooldown")
    end
    return self.BaseClass.GetCooldown( self, nLevel )
end


function scarlett_witch_devil_within:OnSpellStart()
    if IsServer() then
        local target = self:GetCursorTarget()

        if not target:TriggerSpellAbsorb(self) then
            target:AddNewModifier(self:GetCaster(), self, "modifier_scarlett_witch_devil_within", {duration = self:GetSpecialValueFor("duration")})

            EmitSoundOn("Hero_Bane.BrainSap.Target", target)
            EmitSoundOn("Hero_Bane.Enfeeble", self:GetCaster())
        end
    end
end

modifier_scarlett_witch_devil_within = class({})

function modifier_scarlett_witch_devil_within:IsPurgable() return false end
function modifier_scarlett_witch_devil_within:OnCreated(params)
    if IsServer() then 
        self.radius = self:GetAbility():GetSpecialValueFor("radius")

        local nFXIndex = ParticleManager:CreateParticle( "particles/witch/witch_devil_within.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(self.radius, self.radius, 0) )
        ParticleManager:SetParticleControl( nFXIndex, 2, Vector(self.radius, self.radius, 0) )
        ParticleManager:SetParticleControl( nFXIndex, 3, self:GetParent():GetOrigin() )
        ParticleManager:SetParticleControl( nFXIndex, 4, self:GetParent():GetOrigin() )

        self:StartIntervalThink(1)
        self:OnIntervalThink()

        self:AddParticle(nFXIndex, false, false, -1, false, false)
    end
end

function modifier_scarlett_witch_devil_within:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

function modifier_scarlett_witch_devil_within:OnIntervalThink(  )
    if IsServer() then
        ApplyDamage({
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self:GetAbility():GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility()
		})
    end
end

function modifier_scarlett_witch_devil_within:OnTakeDamage( params )
    if IsServer() then
        if params.attacker == self:GetParent() then
            if params.unit == self:GetParent() then
                return
            end

            if bit.band( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
                return 0
            end

            local untis = #Util:GetHeroesInRadius(self:GetParent():GetAbsOrigin(), DOTA_UNIT_TARGET_TEAM_ENEMY, self.radius, params.unit:GetTeamNumber())
            
            print(self.radius)
           
            Util:DoAreaDamage(self:GetParent(), params.damage * self:GetAbility():GetSpecialValueFor("damage_sharing") / untis, self:GetParent():GetAbsOrigin(), self:GetAbility(), params.unit, DAMAGE_TYPE_PURE, self.radius, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_HPLOSS)

            EmitSoundOn("Hero_Bane.Enfeeble.Cast", self:GetParent())
        end
    end
end