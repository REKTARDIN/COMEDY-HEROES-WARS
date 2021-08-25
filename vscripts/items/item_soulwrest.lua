item_soulwrest = class({})

LinkLuaModifier( "modifier_item_soulwrest_active", "items/item_soulwrest.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_soulwrest_slowing", "items/item_soulwrest.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_soulwrest", "items/item_soulwrest.lua", LUA_MODIFIER_MOTION_NONE )

function item_soulwrest:ProcsMagicStick()
	return false
end

function item_soulwrest:GetIntrinsicModifierName()
	return "modifier_item_soulwrest"
end

function item_soulwrest:OnSpellStart()
    if IsServer() then 
        local target = self:GetCursorTarget()

        if target ~= nil then
            EmitSoundOn("DOTA_Item.Sheepstick.Activate", target)
            EmitSoundOn("Item.StarEmblem.Enemy", target)
            
            target:AddNewModifier( self:GetCaster(), self, "modifier_item_soulwrest_active", {duration = self:GetSpecialValueFor("active_duration")} )
        end
    end
end

if modifier_item_soulwrest == nil then modifier_item_soulwrest = class({})  end
function modifier_item_soulwrest:IsHidden() return true end
function modifier_item_soulwrest:IsPurgable() return false end

function modifier_item_soulwrest:DeclareFunctions()
local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_item_soulwrest:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_item_soulwrest:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_item_soulwrest:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_item_soulwrest:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_item_soulwrest:GetModifierPreAttack_BonusDamage (params) return self:GetAbility():GetSpecialValueFor ("bonus_damage") end
function modifier_item_soulwrest:GetModifierPhysicalArmorBonus (params) return self:GetAbility():GetSpecialValueFor ("bonus_armor") end
function modifier_item_soulwrest:GetModifierAttackSpeedBonus_Constant (params) return self:GetAbility():GetSpecialValueFor ("bonus_attack_speed") end

function modifier_item_soulwrest:OnAttackLanded (params)
    if params.attacker == self:GetParent() and params.attacker:IsRealHero() then
        if params.target ~= nil and params.target:IsBuilding() == false and params.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
            params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_item_soulwrest_slowing", {duration = self:GetAbility():GetSpecialValueFor("passive_speed_duration")} )
        end
    end
end

function modifier_item_soulwrest:GetAttributes ()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end

if modifier_item_soulwrest_slowing == nil then modifier_item_soulwrest_slowing = class({}) end

function modifier_item_soulwrest_slowing:IsHidden() return true end
function modifier_item_soulwrest_slowing:IsPurgable() return false end

function modifier_item_soulwrest_slowing:GetEffectName()
    return "particles/econ/events/ti7/shivas_guard_slow.vpcf"
end

function modifier_item_soulwrest_slowing:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_soulwrest_slowing:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_item_soulwrest_slowing:GetModifierMoveSpeedBonus_Percentage( params )
    return -self:GetAbility():GetSpecialValueFor("passive_speed_slow")
end


if modifier_item_soulwrest_active == nil then modifier_item_soulwrest_active = class({}) end

function modifier_item_soulwrest_active:IsHidden() return true end
function modifier_item_soulwrest_active:IsPurgable() return false end

function modifier_item_soulwrest_active:GetEffectName()
    return "particles/econ/items/grimstroke/gs_fall20_immortal/gs_fall20_immortal_soul_debuff.vpcf"
end

function modifier_item_soulwrest_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_soulwrest_active:OnDestroy()
    if IsServer() then
        self:GetParent():RenderWearables(true)
    end
end

function modifier_item_soulwrest_active:OnCreated(params)
    if IsServer() then
        self:GetParent():RenderWearables(false)
    end
end

function modifier_item_soulwrest_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_CHANGE
    }

    return funcs
end

function modifier_item_soulwrest_active:GetModifierIncomingDamage_Percentage( params )
    return self:GetAbility():GetSpecialValueFor("active_incoming_damage")
end

function modifier_item_soulwrest_active:GetModifierModelChange( params )
    return "models/props_gameplay/pig_blue.vmdl"
end

function modifier_item_soulwrest_active:CheckState ()
    local state = {
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_SILENCED] = true,
    }

    return state
end


