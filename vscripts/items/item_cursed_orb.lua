LinkLuaModifier ("modifier_item_cursed_orb", "items/item_cursed_orb.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_cursed_orb_corruption", "items/item_cursed_orb.lua", LUA_MODIFIER_MOTION_NONE)

if item_cursed_orb == nil then
    item_cursed_orb = class ( {})
end

function item_cursed_orb:GetBehavior ()
    local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
    return behav
end

function item_cursed_orb:GetIntrinsicModifierName ()
    return "modifier_item_cursed_orb"
end

if modifier_item_cursed_orb == nil then
    modifier_item_cursed_orb = class ( {})
end

function modifier_item_cursed_orb:IsHidden()
    return true
end

function modifier_item_cursed_orb:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_item_cursed_orb:GetModifierPreAttack_BonusDamage (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_damage")
end

function modifier_item_cursed_orb:OnAttackLanded (params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            params.target:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_item_cursed_orb_corruption", {duration = 7})

        end
    end
end

if modifier_item_cursed_orb_corruption == nil then modifier_item_cursed_orb_corruption = class({}) end

function modifier_item_cursed_orb_corruption:IsHidden()
    return false
end

function modifier_item_cursed_orb_corruption:IsPurgable() 
    return true 
end

function modifier_item_cursed_orb_corruption:IsDebuff()
    return true
end

function modifier_item_cursed_orb_corruption:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

function modifier_item_cursed_orb_corruption:OnCreated(table)
    if IsServer() then
        self:SetStackCount(self:GetAbility():GetSpecialValueFor("corruption_armor") + (self:GetParent():GetPhysicalArmorValue( false ) * (self:GetAbility():GetSpecialValueFor("corruption_pct") / 100)))
    end
end

function modifier_item_cursed_orb_corruption:GetTexture()
    return "custom/cursed_orb" 
end

function modifier_item_cursed_orb_corruption:GetModifierPhysicalArmorBonus( params )
    return -self:GetStackCount()
end

function item_cursed_orb:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

