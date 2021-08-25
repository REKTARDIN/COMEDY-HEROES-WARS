if not mercy_resurrection then mercy_resurrection = class({}) end

LinkLuaModifier ("modifier_mercy_resurrection", "abilities/mercy_resurrection.lua", LUA_MODIFIER_MOTION_NONE)

function mercy_resurrection:IsRefreshable() return false end
function mercy_resurrection:IsStealable() return false end

function mercy_resurrection:GetCooldown( nLevel )
    return self.BaseClass.GetCooldown( self, nLevel )
end

function mercy_resurrection:GetAOERadius()
    return 1500
end

function mercy_resurrection:GetChannelTime()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_mercy_valkyri") then
			return self:GetCaster():FindModifierByName("modifier_mercy_valkyri"):GetAbility():GetSpecialValueFor("resurrection_time")
		end
	end

	return self:GetSpecialValueFor( "time" )
end

function mercy_resurrection:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

mercy_resurrection.vPoint = Vector(0, 0, 0)

function mercy_resurrection:OnSpellStart()
    if IsServer() then
        self.vPoint = self:GetCursorPosition()
    end
end

function mercy_resurrection:OnChannelFinish(bInterrupted)
    if IsServer() then
        if not bInterrupted then
            local allies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self.vPoint, nil, 1500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_DEAD, FIND_CLOSEST, false )
            
            if allies ~= nil and #allies > 0 then
                local ally = allies[1]

                if ally ~= nil and not ally:IsNull() and ally:IsAlive() == false then
                    local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 2, ally, PATTACH_POINT_FOLLOW, "attach_head", ally:GetOrigin(), true )
                    ParticleManager:ReleaseParticleIndex( nFXIndex )
        
                    EmitSoundOn( "Hero_Wisp.Spirits.Cast", self:GetCaster() )

                    ally:RespawnHero(false, false)
                    ally:SetAbsOrigin(self.vPoint)
                    
                    FindClearSpaceForUnit(ally, self.vPoint, false)

                    self:GetCaster():AddNewModifier(ally, self, "modifier_mercy_resurrection", {duration = self:GetSpecialValueFor("duration")})
                end
            end
        end
    end
end

if modifier_mercy_resurrection == nil then modifier_mercy_resurrection = class({}) end

function modifier_mercy_resurrection:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_mercy_resurrection:OnCreated(params)
    if IsServer() then 
        if self:GetParent():HasTalent("special_bonus_unique_mercy_1") then
            self:SetStackCount(1)
        end
    end 
end

function modifier_mercy_resurrection:GetModifierMoveSpeedBonus_Percentage()
    if self:GetStackCount() == 1 then
        return self:GetAbility():GetSpecialValueFor("speed_buff")
    end
    return self:GetAbility():GetSpecialValueFor("speed_slow")
end

function modifier_mercy_resurrection:IsHidden()
	return true
end

function modifier_mercy_resurrection:IsPurgable()
	return false
end

function modifier_mercy_resurrection:RemoveOnDeath()
	return false
end