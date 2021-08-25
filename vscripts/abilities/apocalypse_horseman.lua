if not apocalypse_horseman then apocalypse_horseman = class({}) end 

--------------------------------------------------------------------------------

LinkLuaModifier( "modifier_apocalypse_horseman", "abilities/apocalypse_horseman.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_apocalypse_horseman_passive", "abilities/apocalypse_horseman.lua",LUA_MODIFIER_MOTION_NONE )

local DMG_REDUCTION = 1

function apocalypse_horseman:GetIntrinsicModifierName ()
    return "modifier_apocalypse_horseman_passive"
end

--------------------------------------------------------------------------------

function apocalypse_horseman:OnSpellStart()
    if IsServer() then
        local hTarget = self:GetCursorTarget()

        if hTarget ~= nil then
            local duration = self:GetSpecialValueFor( "duration" )
            
            if self:GetCaster():HasTalent("special_bonus_unique_apocalypse_2") then
                duration = duration + self:GetCaster():FindTalentValue("special_bonus_unique_apocalypse_2")
            end

            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_apocalypse_horseman", { duration = duration } )
           
            EmitSoundOn( "Hero_Bane.Enfeeble.Cast", hTarget )
            EmitSoundOn( "Hero_Bane.Enfeeble", self:GetCaster() )
        end
    end
end

if not modifier_apocalypse_horseman then modifier_apocalypse_horseman = class({}) end 

function modifier_apocalypse_horseman:IsHidden() return false end
function modifier_apocalypse_horseman:IsPurgable() return false end

function modifier_apocalypse_horseman:CheckState()
	local state = {
  		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
	return state
end

function modifier_apocalypse_horseman:GetEffectName()
    return "particles/stygian/apocalypse_ulti_buff.vpcf"
end

function modifier_apocalypse_horseman:OnCreated(params)
    if IsServer() then
        self.int = self:GetCaster():GetIntellect() * (self:GetAbility():GetSpecialValueFor("all_stats_bonus") / 100)
        self.str = self:GetCaster():GetStrength() * (self:GetAbility():GetSpecialValueFor("all_stats_bonus") / 100)
        self.agi = self:GetCaster():GetAgility() * (self:GetAbility():GetSpecialValueFor("all_stats_bonus") / 100)
    end
end

function modifier_apocalypse_horseman:DeclareFunctions()
	return { MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_apocalypse_horseman:GetAbsoluteNoDamageMagical( params )
	return DMG_REDUCTION
end

function modifier_apocalypse_horseman:GetModifierBonusStats_Agility( params )
	return self.agi or 0
end

function modifier_apocalypse_horseman:GetModifierBonusStats_Intellect( params )
	return self.int or 0
end

function modifier_apocalypse_horseman:GetModifierBonusStats_Strength( params )
	return self.str or 0
end

function modifier_apocalypse_horseman:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetAbility():GetSpecialValueFor("movespeed_bonus")
end

if not modifier_apocalypse_horseman_passive then modifier_apocalypse_horseman_passive = class({}) end 

function modifier_apocalypse_horseman_passive:IsHidden()
    return true
end

function modifier_apocalypse_horseman_passive:RemoveOnDeath()
    return true
end

function modifier_apocalypse_horseman_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }

    return funcs
end

function modifier_apocalypse_horseman_passive:GetModifierMagicalResistanceBonus(params)
    return self:GetAbility():GetSpecialValueFor("magical_resist_per_str") * self:GetParent():GetStrength()
end

function modifier_apocalypse_horseman_passive:GetModifierSpellAmplify_Percentage(params)
    return self:GetAbility():GetSpecialValueFor("spell_amp_per_int") * self:GetParent():GetIntellect()
end

function modifier_apocalypse_horseman_passive:GetAttributes ()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end