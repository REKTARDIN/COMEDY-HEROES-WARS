godspeed_speed_stealing = class({})

LinkLuaModifier("modifier_godspeed_speed_stealing", "abilities/godspeed_speed_stealing.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_godspeed_speed_stealing_buff", "abilities/godspeed_speed_stealing.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_godspeed_speed_stealing_debuff", "abilities/godspeed_speed_stealing.lua", LUA_MODIFIER_MOTION_NONE)

function godspeed_speed_stealing:Spawn()
    if IsServer() then self:SetLevel(1) end
end

function godspeed_speed_stealing:GetIntrinsicModifierName()
    return "modifier_godspeed_speed_stealing"
end

modifier_godspeed_speed_stealing = class({})
function modifier_godspeed_speed_stealing:IsHidden() return true end
function modifier_godspeed_speed_stealing:IsDebuff() return false end
function modifier_godspeed_speed_stealing:IsPurgable() return false end
function modifier_godspeed_speed_stealing:IsPurgeException() return false end
function modifier_godspeed_speed_stealing:RemoveOnDeath() return false end
function modifier_godspeed_speed_stealing:DeclareFunctions()
    local func = {  MODIFIER_EVENT_ON_ATTACK_LANDED,}

    return func
end

function modifier_godspeed_speed_stealing:OnAttackLanded(params)
    if IsServer() then

        if params.attacker ~= self:GetParent() then
            return nil
        end

        if params.target == self:GetParent() then
            return nil
        end

        if params.target:IsBuilding() then
            return nil
        end

        if params.target:IsCreep() then
            return nil
        end

        local buff = params.attacker:FindModifierByName("modifier_godspeed_speed_stealing_buff")
        local debuff = params.target:FindModifierByName("modifier_godspeed_speed_stealing_debuff")

        if buff == nil and debuff == nil then

        params.attacker:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_godspeed_speed_stealing_buff", {duration = 30})
        params.target:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_godspeed_speed_stealing_debuff", {duration = 10})
        
        else
            buff:IncrementStackCount()
            buff:ForceRefresh()
            debuff:IncrementStackCount()
            debuff:ForceRefresh()
        end
    end
end

--------------------------------------------------------------------------------------------------------------
modifier_godspeed_speed_stealing_buff = class({})
function modifier_godspeed_speed_stealing_buff:IsHidden() return false end
function modifier_godspeed_speed_stealing_buff:IsPurgable() return false end
function modifier_godspeed_speed_stealing_buff:IsPurgeException() return false end
function modifier_godspeed_speed_stealing_buff:RemoveOnDeath() return true end
function modifier_godspeed_speed_stealing_buff:DeclareFunctions()
    local func = {  MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
    return func
end

function modifier_godspeed_speed_stealing_buff:GetModifierMoveSpeedBonus_Percentage()
    local stack_speed = self:GetStackCount() * 1
    return stack_speed
end

modifier_godspeed_speed_stealing_debuff = class({})
function modifier_godspeed_speed_stealing_debuff:IsHidden() return false end
function modifier_godspeed_speed_stealing_debuff:IsPurgable() return true end
function modifier_godspeed_speed_stealing_debuff:IsPurgeException() return true end
function modifier_godspeed_speed_stealing_debuff:RemoveOnDeath() return true end
function modifier_godspeed_speed_stealing_debuff:DeclareFunctions()
    local func = {  MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
    return func
end

function modifier_godspeed_speed_stealing_debuff:GetModifierMoveSpeedBonus_Percentage()
    local stack_speed = self:GetStackCount() * 1
    return stack_speed * (-1)
end
---(self:GetParent():GetIdealSpeed() * (self:GetAbility():GetSpecialValueFor("speed_steal_pct") / 100)) * 1
---(self:GetParent():GetIdealSpeed() * (self:GetAbility():GetSpecialValueFor("speed_steal_pct") / 100))



