hellspont_telekinesis_pull = class({})

LinkLuaModifier("modifier_hellspont_telekinesis_pull_slowing", "abilities/hellspont_telekinesis_pull.lua", LUA_MODIFIER_MOTION_NONE)

function hellspont_telekinesis_pull:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_5
end

function hellspont_telekinesis_pull:OnSpellStart()

    local caster = self:GetCaster()
    local origin = caster:GetOrigin()
    local point = self:GetCursorPosition()
    local direction = (point-origin):Normalized()
    local cast_angle = VectorToAngles( direction ).y

    local radius =  self:GetSpecialValueFor("range")
    local duration =  self:GetSpecialValueFor("slow_duration" )
    local angle =  self:GetSpecialValueFor("angle") / 2

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetOrigin(),
        nil,
        radius + caster:GetCastRangeBonus(),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        0,
        false
    )

    for _,enemy in pairs(enemies) do

        local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
        local enemy_angle = VectorToAngles( enemy_direction ).y
        local angle_diff = math.abs( AngleDiff( cast_angle, enemy_angle ) )
        
        if angle_diff<=angle then
            enemy:AddNewModifier(caster, self, "modifier_hellspont_telekinesis_pull_slowing", {duration = duration})

            enemy:AddNewModifier(
                caster,
                self,
                "modifier_knockback",
                {
                    center_x = caster:GetAbsOrigin().x,
                    center_y = caster:GetAbsOrigin().y,
                    center_z = caster:GetAbsOrigin().z,
                    should_stun = false,
                    duration = 0.25,
                    knockback_duration = 0.25,
                    knockback_distance = - ( caster:GetAbsOrigin() - enemy:GetAbsOrigin() ):Length2D() + 100,
                    knockback_height = 0
                })
        end
    end
end

modifier_hellspont_telekinesis_pull_slowing = class({})

function modifier_hellspont_telekinesis_pull_slowing:IsDebuff() 
    return true 
end

function modifier_hellspont_telekinesis_pull_slowing:IsHidden() 
    return false 
end

function modifier_hellspont_telekinesis_pull_slowing:IsPurgable() 
    return false 
end

function modifier_hellspont_telekinesis_pull_slowing:IsPurgeException() 
    return true 
end

function modifier_hellspont_telekinesis_pull_slowing:DeclareFunctions()
    local func =
        {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
        
    return func
end

function modifier_hellspont_telekinesis_pull_slowing:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow") * (-1)
end
