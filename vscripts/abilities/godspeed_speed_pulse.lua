godspeed_speed_pulse = class ( {})

LinkLuaModifier ("modifier_godspeed_speed_pulse", "abilities/godspeed_speed_pulse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_godspeed_speed_pulse_lose_speed", "abilities/godspeed_speed_pulse.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_godspeed_speed_pulse_damage", "abilities/godspeed_speed_pulse.lua", LUA_MODIFIER_MOTION_NONE)

function godspeed_speed_pulse:OnSpellStart ()
    if IsServer() then 
        local radius = self:GetSpecialValueFor( "radius" ) 
        local buff_duration = self:GetSpecialValueFor(  "buff_duration" )
        local debuff_duration = self:GetSpecialValueFor(  "debuff_duration" )

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_godspeed_speed_pulse", { duration = duration })

        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), 
        self:GetCaster():GetOrigin(), 
        self:GetCaster(), 
        radius, 
        DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
        0, 
        0, 
        false )

        if #units > 0 then
            for _,unit in pairs(units) do
                unit:AddNewModifier( self:GetCaster(), self, "modifier_godspeed_speed_pulse_lose_speed", { debuff_duration = duration })
                unit:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = 0.5 } )

                local buff = self:GetCaster():FindModifierByName("modifier_godspeed_speed_pulse")

                if buff then 
                    buff:IncrementStackCount()
                end
            end
        end

        local explosion2 = ParticleManager:CreateParticle("particles/econ/items/axe/axe_ti9_immortal/axe_ti9_gold_call.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(explosion2, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl(explosion2, 2, Vector(radius, radius, 0))
        ParticleManager:SetParticleControl(explosion2, 5, self:GetCaster():GetAbsOrigin())

        EmitSoundOn( "n_creep_Ursa.Clap", self:GetCaster() )

    end
end

modifier_godspeed_speed_pulse = class ( {})

function modifier_godspeed_speed_pulse:IsHidden()
    return false
end

function modifier_godspeed_speed_pulse:IsBuff()
    return false
end

function modifier_godspeed_speed_pulse:IsPurgable()
    return false
end

function modifier_godspeed_speed_pulse:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_godspeed_speed_pulse:GetModifierMoveSpeedBonus_Percentage (params)
    local speed = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("movement_speed")
    return speed 
end

modifier_godspeed_speed_pulse_lose_speed = class ( {})

function modifier_godspeed_speed_pulse_lose_speed:IsHidden()
    return false
end

function modifier_godspeed_speed_pulse_lose_speed:IsBuff()
    return false
end

function modifier_godspeed_speed_pulse_lose_speed:IsPurgable()
    return false
end

function modifier_godspeed_speed_pulse_lose_speed:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_godspeed_speed_pulse_lose_speed:GetModifierMoveSpeedBonus_Percentage (params)
    local speed = self:GetAbility():GetSpecialValueFor("movement_speed")
    return speed 
end