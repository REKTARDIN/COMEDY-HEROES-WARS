item_cursed_sight = class({})

LinkLuaModifier( "modifier_item_cursed_sight", "items/item_cursed_sight.lua", LUA_MODIFIER_MOTION_NONE )

function item_cursed_sight:GetIntrinsicModifierName()
	return "modifier_item_cursed_sight"
end

function item_cursed_sight:OnSpellStart()
    if IsServer() then 
        local target = self:GetCursorTarget()

        if target ~= nil then
            EmitSoundOn("Hero_Medusa.StoneGaze.Stun", target)
            
            target:AddNewModifier( self:GetCaster(), self, "modifier_medusa_stone_gaze_stone", {duration = self:GetSpecialValueFor("stone_duration")} )
        end
    end
end

if modifier_item_cursed_sight == nil then modifier_item_cursed_sight = class({})  end
function modifier_item_cursed_sight:IsHidden() return true end
function modifier_item_cursed_sight:IsPurgable() return false end

function modifier_item_cursed_sight:DeclareFunctions()
local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_item_cursed_sight:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_cursed_sight:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_cursed_sight:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_cursed_sight:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_cursed_sight:GetModifierMagicalResistanceBonus( params ) return self:GetAbility():GetSpecialValueFor( "bonus_magical_armor" ) end
function modifier_item_cursed_sight:GetModifierAttackSpeedBonus_Constant (params) return self:GetAbility():GetSpecialValueFor ("bonus_attack_speed") end

function modifier_item_cursed_sight:OnAttackLanded (params)
    if params.attacker == self:GetParent() and params.attacker:IsRealHero() then
        if params.target ~= nil and params.target:IsBuilding() == false and params.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
            params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_item_mage_slayer_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration")} )
        end
    end
end

function modifier_item_cursed_sight:GetAttributes ()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end




