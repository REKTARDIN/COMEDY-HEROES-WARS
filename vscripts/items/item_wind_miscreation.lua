LinkLuaModifier( "modifier_item_wind_miscreation", "items/item_wind_miscreation.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_wind_miscreation_active", "items/item_wind_miscreation.lua", LUA_MODIFIER_MOTION_NONE )

if item_wind_miscreation == nil then item_wind_miscreation = class({}) end

function item_wind_miscreation:GetIntrinsicModifierName()
	return "modifier_item_wind_miscreation"
end

function item_wind_miscreation:OnSpellStart()
	if IsServer() then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_wind_miscreation_active", {duration = self:GetSpecialValueFor("active_duration")})

        EmitSoundOn( "DOTA_Item.EssenceRing.Cast", self:GetCaster() )
    end
end

if modifier_item_wind_miscreation == nil then modifier_item_wind_miscreation = class({}) end

function modifier_item_wind_miscreation:IsHidden() return true end
function modifier_item_wind_miscreation:IsPurgable() return false end
function modifier_item_wind_miscreation:IsPermanent() return true end
function modifier_item_wind_miscreation:RemoveOnDeath() return false end
function modifier_item_wind_miscreation:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_wind_miscreation:DeclareFunctions() 
local funcs = {
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_EVASION_CONSTANT
}

return funcs
end

modifier_item_wind_miscreation.b_hBuff = nil

function modifier_item_wind_miscreation:GetModifierEvasion_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_evasion" )
end

function modifier_item_wind_miscreation:GetModifierAttackSpeedBonus_Constant( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_speed" )
end

function modifier_item_wind_miscreation:GetModifierBonusStats_Agility( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_agility" )
end

function modifier_item_wind_miscreation:GetModifierPreAttack_BonusDamage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_damage" )
end

function modifier_item_wind_miscreation:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
end

function modifier_item_wind_miscreation:OnCreated(params)
    if IsServer() then
        
    end
end

function modifier_item_wind_miscreation:OnDestroy()
    if IsServer() then

    end
end


if modifier_item_wind_miscreation_active == nil then modifier_item_wind_miscreation_active = class({}) end

function modifier_item_wind_miscreation_active:IsHidden() return false end
function modifier_item_wind_miscreation_active:IsPurgable() return false end
function modifier_item_wind_miscreation_active:GetEffectName() return "particles/stygian/wind_miscreation_buff_debut_ambient.vpcf" end
function modifier_item_wind_miscreation_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_wind_miscreation_active:StatusEffectPriority() return 1000 end
function modifier_item_wind_miscreation_active:GetTexture()
    return "custom/The_Elder_Sword" 
end

function modifier_item_wind_miscreation_active:OnCreated(params)
    self.b_flAttackSpeed = self:GetParent():GetBaseAttackTime() * ((100 - self:GetAbility():GetSpecialValueFor("active_move_speed")) / 100)
end

function modifier_item_wind_miscreation_active:DeclareFunctions ()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_REDUCTION_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
    }
end

function modifier_item_wind_miscreation_active:OnAttackLanded (params)
    if IsServer () then
        if params.attacker == self:GetParent() and params.attacker:IsRealHero() then
            self:GetParent():Heal((params.damage * (self:GetAbility():GetSpecialValueFor("active_vampirism") / 100) ), self:GetAbility())
        end
    end
    return 0
end

function modifier_item_wind_miscreation_active:GetModifierBaseAttackTimeConstant( params )
    return self.b_flAttackSpeed
end

function modifier_item_wind_miscreation_active:GetModifierAttackSpeedReductionPercentage( params )
    return self:GetAbility():GetSpecialValueFor( "active_attack_speed" ) 
end

function modifier_item_wind_miscreation_active:GetModifierMoveSpeedBonus_Percentage( params )
    return self:GetAbility():GetSpecialValueFor( "active_move_speed" )
end

function item_wind_miscreation:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

