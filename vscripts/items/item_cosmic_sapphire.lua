item_cosmic_sapphire = class({})

LinkLuaModifier ("modifier_item_cosmic_sapphire", "items/item_cosmic_sapphire.lua", LUA_MODIFIER_MOTION_NONE)

function item_cosmic_sapphire:GetIntrinsicModifierName()
    return "modifier_item_cosmic_sapphire"
end

modifier_item_cosmic_sapphire = class({})

function modifier_item_cosmic_sapphire:IsHidden ()
    return true 
end

function modifier_item_cosmic_sapphire:IsPurgable()
    return false
end

function modifier_item_cosmic_sapphire:IsPurgeException()
    return false
end

function modifier_item_cosmic_sapphire:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_cosmic_sapphire:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }

    return funcs
end

function modifier_item_cosmic_sapphire:OnTakeDamageKillCredit( params )
    if IsServer() then
        if params.inflictor and params.attacker == self:GetParent() and params.inflictor:IsItem() == false then 
            if RollPercentage(self:GetAbility():GetSpecialValueFor("critical_chance")) then 
                local damage = (params.damage * (self:GetAbility():GetSpecialValueFor("critical_strike") / 100))

                if params.target == self:GetParent() then return end 
                
                pcall(function()
                    if params.target and not params.target:IsNull() then
                        SendOverheadEventMessage( params.target, OVERHEAD_ALERT_BONUS_POISON_DAMAGE , params.target, math.floor( damage ), nil )

                        ApplyDamage ( {
                            victim = params.target,
                            attacker = self:GetParent(),
                            damage = damage,
                            damage_type = params.damage_type,
                            damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
                        })
                    end
                end)
            end 
        end 
    end 
end

function modifier_item_cosmic_sapphire:GetModifierBonusStats_Intellect( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

function modifier_item_cosmic_sapphire:GetModifierMPRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "mana_regen_amp" )
end

function modifier_item_cosmic_sapphire:GetModifierSpellLifestealRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "spell_lifesteal_amp" )
end

function modifier_item_cosmic_sapphire:GetModifierSpellAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor ("bonus_amp" )
end

function item_cosmic_sapphire:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

