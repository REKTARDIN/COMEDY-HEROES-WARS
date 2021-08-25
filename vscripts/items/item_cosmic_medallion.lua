item_cosmic_medallion = class({})

LinkLuaModifier ("modifier_item_cosmic_medallion", "items/item_cosmic_medallion.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_cosmic_medallion_active", "items/item_cosmic_medallion.lua", LUA_MODIFIER_MOTION_NONE)

function item_cosmic_medallion:GetIntrinsicModifierName()
    return "modifier_item_cosmic_medallion"
end

function item_cosmic_medallion:OnSpellStart()
    local caster = self:GetCaster() 
    local duration = self:GetSpecialValueFor( "cosmic_vision_duration" )

    caster:AddNewModifier( self:GetCaster(), self, "modifier_item_cosmic_medallion_active", {duration = duration} )
 
    EmitSoundOn( "Hero_Invoker.EMP.Discharge", self:GetCaster() )
end

modifier_item_cosmic_medallion = class({})

function modifier_item_cosmic_medallion:IsHidden ()
    return true 
end

function modifier_item_cosmic_medallion:IsPurgable()
    return false
end

function modifier_item_cosmic_medallion:IsPurgeException()
    return false
end

function modifier_item_cosmic_medallion:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_cosmic_medallion:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }

    return funcs
end

function modifier_item_cosmic_medallion:OnTakeDamageKillCredit( params )
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

function modifier_item_cosmic_medallion:GetModifierBonusStats_Intellect( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_intellect" )
end

function modifier_item_cosmic_medallion:GetModifierMPRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "mana_regen_amp" )
end

function modifier_item_cosmic_medallion:GetModifierSpellLifestealRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "spell_lifesteal_amp" )
end

function modifier_item_cosmic_medallion:GetModifierSpellAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor ("bonus_amp" )
end

function modifier_item_cosmic_medallion:GetModifierManaBonus( params ) 
    return self:GetAbility():GetSpecialValueFor( "mana_bonus" ) 
end

function modifier_item_cosmic_medallion:GetModifierConstantManaRegen( params ) 
    return self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" ) 
end

function modifier_item_cosmic_medallion:GetModifierCastRangeBonus( params ) 
    return self:GetAbility():GetSpecialValueFor( "cast_range_bonus" ) 
end

modifier_item_cosmic_medallion_active = class({})

function modifier_item_cosmic_medallion_active:IsHidden ()
    return false 
end

function modifier_item_cosmic_medallion_active:IsPurgable()
    return false
end

function modifier_item_cosmic_medallion_active:IsPurgeException()
    return false
end


function modifier_item_cosmic_medallion_active:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION
    }

    return funcs
end

function modifier_item_cosmic_medallion_active:GetModifierCastRangeBonusStacking( params ) 
    return self:GetAbility():GetSpecialValueFor( "cast_range_bonus_active" ) 
end

function modifier_item_cosmic_medallion_active:GetBonusDayVision( params ) 
    return self:GetAbility():GetSpecialValueFor( "vision_bonus_active" ) 
end

function modifier_item_cosmic_medallion_active:GetBonusNightVision( params ) 
    return self:GetAbility():GetSpecialValueFor( "vision_bonus_active" ) 
end

function item_cosmic_medallion:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

