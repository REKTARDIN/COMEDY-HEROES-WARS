iron_fist_meditate = class({})

LinkLuaModifier("modifier_iron_fist_meditate_heal", "abilities/iron_fist_meditate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_iron_fist_meditate_stacks", "abilities/iron_fist_meditate.lua", LUA_MODIFIER_MOTION_NONE)

function iron_fist_meditate:GetIntrinsicModifierName ()
    return "modifier_iron_fist_meditate_stacks"
end

function iron_fist_meditate:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier( caster, self, "modifier_iron_fist_meditate_heal", {} )
    caster:StartGesture( ACT_DOTA_CAST_ABILITY_6 )
end

function iron_fist_meditate:OnChannelFinish( bInterrupted )
    if not bInterrupted then
        self.modifier = self:GetCaster():FindModifierByName("modifier_iron_fist_meditate_stacks")
        self.modifier:IncrementStackCount()

        self:GetCaster():RemoveModifierByName( "modifier_iron_fist_meditate_heal" )
        self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_6 )
    else
        self:GetCaster():RemoveModifierByName( "modifier_iron_fist_meditate_heal" )
        self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_6 )
    end
end

modifier_iron_fist_meditate_heal = class({})
function modifier_iron_fist_meditate_heal:IsDebuff() return false end
function modifier_iron_fist_meditate_heal:IsHidden() return false end
function modifier_iron_fist_meditate_heal:IsPurgable() return false end
function modifier_iron_fist_meditate_heal:IsPurgeException() return false end
function modifier_iron_fist_meditate_heal:GetEffectName() return "particles/units/heroes/hero_huskar/huskar_inner_vitality.vpcf" end
function modifier_iron_fist_meditate_heal:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_iron_fist_meditate_heal:OnCreated()
    self:StartIntervalThink( self:GetAbility():GetSpecialValueFor( "interval" ) )
end

function modifier_iron_fist_meditate_heal:OnIntervalThink()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local pct_heal = ability:GetSpecialValueFor("pct_heal") * caster:GetMaxHealth() * 0.01
        local heal = (pct_heal + ability:GetSpecialValueFor( "heal" )) * self:GetAbility():GetSpecialValueFor( "interval" )

        caster:Heal( heal, ability )

        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal, nil)
    end
end


function modifier_iron_fist_meditate_heal:DeclareFunctions()
    local func =
        {
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
        }
    return func
end
function modifier_iron_fist_meditate_heal:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor( "damage_reduction" ) * (-1)
end

modifier_iron_fist_meditate_stacks = class({})
function modifier_iron_fist_meditate_stacks:IsHidden() return true end
function modifier_iron_fist_meditate_stacks:IsDebuff() return false end
function modifier_iron_fist_meditate_stacks:IsPurgable() return false end
function modifier_iron_fist_meditate_stacks:IsPurgeException() return false end
function modifier_iron_fist_meditate_stacks:RemoveOnDeath() return false end
function modifier_iron_fist_meditate_stacks:DeclareFunctions()
    local func = { MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_PROPERTY_HEALTH_BONUS}

    return func
end

function modifier_iron_fist_meditate_stacks:GetModifierManaBonus()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("bonus_mana_stack"))
end

function modifier_iron_fist_meditate_stacks:GetModifierHealthBonus()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("bonus_health_stack"))
end
