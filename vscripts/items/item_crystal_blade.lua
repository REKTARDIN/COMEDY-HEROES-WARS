if not item_crystal_blade then item_crystal_blade = class({}) end 

LinkLuaModifier ("modifier_item_crystal_blade", "items/item_crystal_blade.lua", LUA_MODIFIER_MOTION_NONE)

if item_crystal_blade == nil then item_high_frequency_blade = class ( {}) end

function item_crystal_blade:GetBehavior ()
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function item_crystal_blade:GetIntrinsicModifierName ()
    return "modifier_item_crystal_blade"
end

if modifier_item_crystal_blade == nil then modifier_item_crystal_blade = class({}) end

function modifier_item_crystal_blade:IsHidden() return true end
function modifier_item_crystal_blade:IsPurgable() return false end
function modifier_item_crystal_blade:IsPermanent() return true end
function modifier_item_crystal_blade:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_crystal_blade:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE
    }

    return funcs
end

function modifier_item_crystal_blade:GetModifierPreAttack_BonusDamage(params)
    return self:GetAbility():GetSpecialValueFor ("bonus_damage")
end

function modifier_item_crystal_blade:GetModifierPreAttack_CriticalStrike(params)
    if IsServer() then
        local chance = self:GetAbility():GetSpecialValueFor("crit_chance")
        
        if RollPercentage(chance) then
            
        local hTarget = params.target
            
        return self:GetAbility():GetSpecialValueFor("crit_multiplier")
        end
    end
end

function modifier_item_crystal_blade:GetModifierProcAttack_BonusDamage_Pure(params)
    if IsServer() then
        if params.target and (not params.target:IsBuilding()) then
    		return params.original_damage * self:GetAbility():GetSpecialValueFor("damage_pure_ptc") / 100
    	end
    end 

	return
end