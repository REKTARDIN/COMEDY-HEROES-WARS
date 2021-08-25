loki_souldown = class({})

LinkLuaModifier( "modifier_loki_souldown", "abilities/loki_souldown.lua" ,LUA_MODIFIER_MOTION_NONE )

function loki_souldown:OnSpellStart()
    local caster = self:GetCaster()
   
    EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), "Hero_PhantomLancer.Doppelganger.Cast", caster)
   
    local duration = self:GetSpecialValueFor("duration") 

    caster:AddNewModifier(caster, self, "modifier_loki_souldown", {duration = duration})

    local nFXIndex = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_phantom_lancer/phantom_lancer_dying.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetTeamNumber() );
    ParticleManager:ReleaseParticleIndex( nFXIndex );

    --[[Supported keys: outgoing_damage incoming_damage bounty_base bounty_growth outgoing_damage_structure outgoing_damage_roshan]]
    local illusions = CreateIllusions(caster, caster, {duraion = duration, outgoing_damage = self:GetSpecialValueFor("outgoing_damage"), incoming_damage = self:GetSpecialValueFor("incoming_damage")}, self:GetSpecialValueFor("illusions"), 0, false, false)
 
    Timers:CreateTimer(FrameTime(), function() 
        local illusion = illusions[1]

        local vDest = caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetSpecialValueFor("distance")

        illusion:SetForwardVector(caster:GetForwardVector())

        local order_caster =
        {
            UnitIndex = illusion:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = vDest
        }

        ExecuteOrderFromTable(order_caster)

        illusion:AddNewModifier(caster, self, "modifier_kill", {["duration"] = duration})
    end)
end

modifier_loki_souldown = class({})

function modifier_loki_souldown:OnCreated()
    self.speed = self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_loki_souldown:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ABILITY_START,
        MODIFIER_EVENT_ON_ATTACK_START
    }

    return funcs
end
function modifier_loki_souldown:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
    }

    return state
end

function modifier_loki_souldown:OnAbilityStart( params )
    if IsServer() then
        if params.unit == self:GetParent() then
            self:Destroy()
        end
    end
end

function modifier_loki_souldown:OnAttackStart( params )
    if IsServer() then
        if params.attacker == self:GetParent() then
            self:Destroy()
        end
    end
end

function modifier_loki_souldown:GetModifierInvisibilityLevel( params )
    return 1
end

function modifier_loki_souldown:GetModifierMoveSpeed_Max( params )
    return self.speed
end

function modifier_loki_souldown:GetModifierMoveSpeed_Limit( params )
    return self.speed
end

function modifier_loki_souldown:GetModifierMoveSpeed_Absolute( params )
    return self.speed
end

function modifier_loki_souldown:IsHidden()
    return true
end

function modifier_loki_souldown:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end

