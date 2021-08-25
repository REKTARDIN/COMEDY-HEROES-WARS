item_dexterity_emerald = class({})

LinkLuaModifier ("modifier_item_dexterity_emerald", "items/item_dexterity_emerald.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_dexterity_emerald_active", "items/item_dexterity_emerald.lua", LUA_MODIFIER_MOTION_NONE)

function item_dexterity_emerald:GetIntrinsicModifierName()
    return "modifier_item_dexterity_emerald"
end

function item_dexterity_emerald:OnSpellStart()
	if IsServer() then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_dexterity_emerald_active", {duration = self:GetSpecialValueFor("active_duration")})

        EmitSoundOn( "DOTA_Item.EssenceRing.Cast", self:GetCaster() )
    end
end

modifier_item_dexterity_emerald = class({})

function modifier_item_dexterity_emerald:IsHidden ()
    return true 
end

function modifier_item_dexterity_emerald:IsPurgable()
    return false
end

function modifier_item_dexterity_emerald:IsPurgeException()
    return false
end

function modifier_item_dexterity_emerald:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_dexterity_emerald:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }

    return funcs
end

function modifier_item_dexterity_emerald:GetModifierBonusStats_Agility( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_agility" )
end

function modifier_item_dexterity_emerald:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
end

function modifier_item_dexterity_emerald:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

if modifier_item_dexterity_emerald_active == nil then modifier_item_dexterity_emerald_active = class({}) end

function modifier_item_dexterity_emerald_active:IsHidden() return false end
function modifier_item_dexterity_emerald_active:IsPurgable() return false end
function modifier_item_dexterity_emerald_active:GetEffectName() return "particles/items5_fx/essence_ring.vpcf" end
function modifier_item_dexterity_emerald_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_dexterity_emerald_active:StatusEffectPriority() return 1000 end
function modifier_item_dexterity_emerald_active:GetTexture () return self:GetAbility():GetAbilityTextureName() end

function modifier_item_dexterity_emerald_active:OnCreated(params)
    self.b_flAttackSpeed = self:GetParent():GetBaseAttackTime() * ((100 - self:GetAbility():GetSpecialValueFor("active_attack_speed")) / 100)
end

function modifier_item_dexterity_emerald_active:DeclareFunctions ()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_REDUCTION_PERCENTAGE,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
    }
end

function modifier_item_dexterity_emerald_active:GetModifierBaseAttackTimeConstant( params )
    return self.b_flAttackSpeed
end

function modifier_item_dexterity_emerald_active:GetModifierAttackSpeedReductionPercentage( params )
    return self:GetAbility():GetSpecialValueFor( "active_attack_speed" ) 
end

function item_dexterity_emerald:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

