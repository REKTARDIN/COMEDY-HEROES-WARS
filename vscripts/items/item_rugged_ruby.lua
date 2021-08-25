item_rugged_ruby = class({})

LinkLuaModifier ("modifier_item_rugged_ruby", "items/item_rugged_ruby.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_rugged_ruby_active", "items/item_rugged_ruby.lua", LUA_MODIFIER_MOTION_NONE)

function item_rugged_ruby:GetIntrinsicModifierName()
    return "modifier_item_rugged_ruby"
end

function item_rugged_ruby:OnSpellStart()
	if IsServer() then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_rugged_ruby_active", {duration = self:GetSpecialValueFor("active_duration")})

        EmitSoundOn( "DOTA_Item.SpiritVessel.Target.Enemy", self:GetCaster() )
    end
end

modifier_item_rugged_ruby = class({})

function modifier_item_rugged_ruby:IsHidden ()
    return true 
end

function modifier_item_rugged_ruby:IsPurgable()
    return false
end

function modifier_item_rugged_ruby:IsPurgeException()
    return false
end

function modifier_item_rugged_ruby:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_rugged_ruby:DeclareFunctions() 
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE  
    }

    return funcs
end

function modifier_item_rugged_ruby:GetModifierBonusStats_Strength( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_strength" )
end

function modifier_item_rugged_ruby:GetModifierStatusResistance( params )
    local status_resistance = self:GetAbility():GetSpecialValueFor( "bonus_status_resistance" )
    local status_active = self:GetAbility():GetSpecialValueFor( "bonus_status_resistance" ) * 2
        if self:GetParent():HasModifier("modifier_item_rugged_ruby_active") then 
            self.status_resistance = status_active
        else
            self.status_resistance = status_resistance
        end
            
    return self.status_resistance
end

function modifier_item_rugged_ruby:GetModifierLifestealRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_heal_amp" )
end

function modifier_item_rugged_ruby:GetModifierHPRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_heal_amp" )
end

modifier_item_rugged_ruby_active = class({})

function modifier_item_rugged_ruby_active:IsHidden ()
    return false 
end

function modifier_item_rugged_ruby_active:IsPurgable()
    return false
end

function modifier_item_rugged_ruby_active:IsPurgeException()
    return true
end

function modifier_item_rugged_ruby_active:DeclareFunctions() 
    local funcs = {
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE  
    }

    return funcs
end

function modifier_item_rugged_ruby_active:GetModifierLifestealRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_heal_amp" )
end

function modifier_item_rugged_ruby_active:GetModifierHPRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_heal_amp" )
end

function item_rugged_ruby:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

