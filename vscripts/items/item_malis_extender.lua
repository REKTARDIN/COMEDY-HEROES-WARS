item_malis_extender = class({})

LinkLuaModifier ("modifier_item_malis_extender", "items/item_malis_extender.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_malis_extender_active", "items/item_malis_extender.lua", LUA_MODIFIER_MOTION_NONE)

function item_malis_extender:GetIntrinsicModifierName()
    return "modifier_item_malis_extender"
end

function item_malis_extender:OnSpellStart()
    if IsServer() then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_malis_extender_active", {duration = self:GetSpecialValueFor("active_duration")})

        EmitSoundOn( "DOTA_Item.SpiritVessel.Target.Enemy", self:GetCaster() )
    end
end

modifier_item_malis_extender = class({})

function modifier_item_malis_extender:IsHidden ()
    return true
end

function modifier_item_malis_extender:IsPurgable()
    return false
end

function modifier_item_malis_extender:IsPurgeException()
    return false
end

function modifier_item_malis_extender:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_malis_extender:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT,
    }

    return funcs
end

function modifier_item_malis_extender:OnTakeDamageKillCredit( params )
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

function modifier_item_malis_extender:GetModifierBonusStats_Strength( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
end

function modifier_item_malis_extender:GetModifierBonusStats_Agility( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
end

function modifier_item_malis_extender:GetModifierBonusStats_Intellect( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
end

function modifier_item_malis_extender:GetModifierMPRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "mana_regen_amp" )
end

function modifier_item_malis_extender:GetModifierSpellLifestealRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "spell_lifesteal_amp" )
end

function modifier_item_malis_extender:GetModifierSpellAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor ("bonus_amp" )
end

function modifier_item_malis_extender:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
end

function modifier_item_malis_extender:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

function modifier_item_malis_extender:GetModifierStatusResistance( params )
    local status_resistance = self:GetAbility():GetSpecialValueFor( "bonus_status_resistance" )
    local status_active = self:GetAbility():GetSpecialValueFor( "bonus_status_resistance" ) * 2
    if self:GetParent():HasModifier("modifier_item_malis_extender_active") then
        self.status_resistance = status_active
    else
        self.status_resistance = status_resistance
    end

    return self.status_resistance
end

function modifier_item_malis_extender:GetModifierLifestealRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_heal_amp" )
end

function modifier_item_malis_extender:GetModifierHPRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_heal_amp" )
end

modifier_item_malis_extender_active = class({})

function modifier_item_malis_extender_active:IsHidden ()
    return false
end

function modifier_item_malis_extender_active:IsPurgable()
    return false
end

function modifier_item_malis_extender_active:IsPurgeException()
    return true
end

function modifier_item_malis_extender_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATUS_RESISTANCE,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_REDUCTION_PERCENTAGE,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
    }

    return funcs
end

function modifier_item_malis_extender_active:OnCreated(params)
    self.b_flAttackSpeed = self:GetParent():GetBaseAttackTime() * ((100 - self:GetAbility():GetSpecialValueFor("active_attack_speed")) / 100)
end

function modifier_item_malis_extender_active:GetModifierBaseAttackTimeConstant( params )
    return self.b_flAttackSpeed
end

function modifier_item_malis_extender_active:GetModifierAttackSpeedReductionPercentage( params )
    return self:GetAbility():GetSpecialValueFor( "active_attack_speed" )
end

function modifier_item_malis_extender_active:GetModifierStatusResistance( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_status_resistance" )
end

function modifier_item_malis_extender_active:GetModifierLifestealRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_heal_amp" )
end

function modifier_item_malis_extender_active:GetModifierHPRegenAmplify_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_heal_amp" )
end

function item_malis_extender:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end

