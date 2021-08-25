if not doomsday_evolution then doomsday_evolution = class({}) end 

LinkLuaModifier("modifier_doomsday_evolution", "abilities/doomsday_evolution.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_doomsday_evolution_buff", "abilities/doomsday_evolution.lua", LUA_MODIFIER_MOTION_NONE)

local CONST_BASE_HP = 50
local CONST_HP_INC = 5

doomsday_evolution.m_iEvolutionCounter = 0

function doomsday_evolution:Spawn()
    if IsServer() then
        if (not self:GetCaster():HasModifier("modifier_doomsday_evolution")) then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doomsday_evolution", nil)
        end
    end
end

--------------------------------------------------------------------------------
-- Ability Start
function doomsday_evolution:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
    
    caster:AddNewModifier(caster, self, "modifier_doomsday_evolution_buff", {duration = self:GetSpecialValueFor("evolution_duration")})

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Mars.Shield.Cast", self:GetCaster() )
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

modifier_doomsday_evolution = class({})

modifier_doomsday_evolution.m_iRespPtcHP = 5.0
modifier_doomsday_evolution.m_iStr = 0

function modifier_doomsday_evolution:IsHidden() return false end
function modifier_doomsday_evolution:RemoveOnDeath() return false end
function modifier_doomsday_evolution:IsPurgable() return false end

function modifier_doomsday_evolution:DeclareFunctions()
    return { MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE }
end

function modifier_doomsday_evolution:GetStatusEffectName()
    return "particles/status_fx/status_effect_abaddon_borrowed_time.vpcf"
end

function modifier_doomsday_evolution:StatusEffectPriority()
    return 1000
end

function modifier_doomsday_evolution:OnDeath(params)
    if IsServer() then
        if params.attacker ~= nil and params.unit == self:GetParent() then
            if params.attacker:IsRealHero() then
                self:IncrementStackCount()
            end
        end
    end
end

function modifier_doomsday_evolution:Adapt(vLoc, attacker)
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_rage_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
    
        EmitSoundOn( "Hero_Sven.IronWill", self:GetCaster() )

        self:IncrementStackCount()
        
        ---- Update health
        self:GetCaster():SetHealth(self:GetCaster():GetMaxHealth() * ((CONST_BASE_HP + self.m_iRespPtcHP) / 100))

        self.m_iRespPtcHP = self.m_iRespPtcHP + CONST_HP_INC

        self:GetAbility().m_iEvolutionCounter = (self:GetAbility().m_iEvolutionCounter or 0) + 1
        self:GetAbility():UseResources(false, false, true)
    end
end

function modifier_doomsday_evolution:OnStackCountChanged(iStackCount)
    self.m_iStr = self:GetParent():GetStrength()
end

function modifier_doomsday_evolution:GetModifierExtraHealthPercentage(params)
    return self:GetAbility():GetSpecialValueFor("death_extra_hp") / 100 * self:GetStackCount() * (IsHasTalent(self:GetParent():GetPlayerOwnerID(), "special_bonus_unique_doomsday_5") or 1)
end

function modifier_doomsday_evolution:GetModifierExtraStrengthBonus(params)
    return self:GetAbility():GetSpecialValueFor("death_extra_strenght") * self:GetStackCount() * (IsHasTalent(self:GetParent():GetPlayerOwnerID(), "special_bonus_unique_doomsday_5") or 1)
end

function modifier_doomsday_evolution:GetModifierHPRegenAmplify_Percentage(params)
    return self:GetAbility():GetSpecialValueFor("death_extra_hp_regen") / 100 * self:GetStackCount() * (IsHasTalent(self:GetParent():GetPlayerOwnerID(), "special_bonus_unique_doomsday_5") or 1)
end

modifier_doomsday_evolution_buff = class({})

function modifier_doomsday_evolution_buff:IsHidden() return false end
function modifier_doomsday_evolution_buff:RemoveOnDeath() return false end
function modifier_doomsday_evolution_buff:IsPurgable() return false end

function modifier_doomsday_evolution_buff:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE}
end

----- Adapt to damage
function modifier_doomsday_evolution_buff:OnTakeDamage(params)
    if self:GetParent() == params.unit then 
        if IsServer() and self:GetCaster():IsRealHero() and params.attacker:IsRealHero() then 
            if self:GetParent():GetHealth() <= 0 then 
                self:GetParent():FindModifierByName("modifier_doomsday_evolution"):Adapt(self:GetParent():GetAbsOrigin(), params.attacker)
                self:Destroy()
            end
        end
    end
end
