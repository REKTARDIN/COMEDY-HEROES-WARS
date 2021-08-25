LinkLuaModifier ("modifier_item_stygian_desolator", "items/item_stygian_desolator.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_stygian_desolator_corruption", "items/item_stygian_desolator.lua", LUA_MODIFIER_MOTION_NONE)

if item_stygian_desolator == nil then
    item_stygian_desolator = class ( {})
end

function item_stygian_desolator:GetBehavior ()
    local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
    return behav
end

function item_stygian_desolator:GetIntrinsicModifierName ()
    return "modifier_item_stygian_desolator"
end

if modifier_item_stygian_desolator == nil then
    modifier_item_stygian_desolator = class ( {})
end

function modifier_item_stygian_desolator:IsHidden()
    return true
end

function modifier_item_stygian_desolator:OnCreated(params)
    if IsServer() then
        if self:GetParent():IsRangedAttacker() then
            self.projectile = self:GetParent():GetRangedProjectileName()
            self:GetParent():SetRangedProjectileName("particles/stygian/stygian_desolator.vpcf")
        end
    end
end
            
function modifier_item_stygian_desolator:OnDestroy(params)
    if IsServer() then
        self:GetParent():SetRangedProjectileName(self.projectile)
    end
end

function modifier_item_stygian_desolator:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_item_stygian_desolator:GetModifierPreAttack_BonusDamage (params)
    local hAbility = self:GetAbility ()
    return hAbility:GetSpecialValueFor ("bonus_damage")
end

function modifier_item_stygian_desolator:OnAttackLanded (params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            params.target:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_item_stygian_desolator_corruption", {duration = 7})

            EmitSoundOn("Item_Desolator.Target", hTarget)
        end
    end
end

if modifier_item_stygian_desolator_corruption == nil then modifier_item_stygian_desolator_corruption = class({}) end

function modifier_item_stygian_desolator_corruption:IsHidden()
    return false
end

function modifier_item_stygian_desolator_corruption:IsPurgable() 
    return true 
end

function modifier_item_stygian_desolator_corruption:IsDebuff()
    return true
end

function modifier_item_stygian_desolator_corruption:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }

    return funcs
end

function modifier_item_stygian_desolator_corruption:OnCreated(table)
    if IsServer() then
        self:SetStackCount(self:GetAbility():GetSpecialValueFor("corruption_armor") + (self:GetParent():GetPhysicalArmorValue( false ) * (self:GetAbility():GetSpecialValueFor("corruption_pct") / 100)))
    end
end

function modifier_item_stygian_desolator_corruption:GetTexture()
    return "custom/stygian_desolator" 
end

function modifier_item_stygian_desolator_corruption:GetModifierPhysicalArmorBonus( params )
    return -self:GetStackCount()
end

function item_stygian_desolator:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

