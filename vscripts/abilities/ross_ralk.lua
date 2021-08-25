ross_ralk = class({})

LinkLuaModifier( "modifier_ross_ralk", "abilities/ross_ralk.lua" ,LUA_MODIFIER_MOTION_NONE )

function ross_ralk:GetIntrinsicModifierName()
	return "modifier_ross_ralk"
end

modifier_ross_ralk = class({})

--------------------------------------------------------------------------------

function modifier_ross_ralk:IsPurgable()
	return false
end

function modifier_ross_ralk:RemoveOnDeath()
	return false
end

function modifier_ross_ralk:IsPermanent()
	return true
end

function modifier_ross_ralk:IsHidden()
	return self:GetStackCount() <= 1
end

function modifier_ross_ralk:DestroyOnExpire()
	return false
end

function modifier_ross_ralk:OnCreated(params)
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_ross_ralk:OnIntervalThink()
    if self:GetRemainingTime() <= 0 then
        self:SetStackCount(0)
    end
end

function modifier_ross_ralk:OnRemoved()
    if IsServer() then
        self:SetStackCount(0)
    end
end

function modifier_ross_ralk:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function modifier_ross_ralk:GetModifierHealthRegenPercentage( params )
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("heal_ptc_per_stack") 
end

function modifier_ross_ralk:OnAttack( params )
    if IsServer() then
        if self:GetParent() == params.attacker then
            if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
                self:IncrementStackCount()
            end

            self:SetDuration(self:GetAbility():GetSpecialValueFor("stack_duration"), true)
        end
    end
end

function modifier_ross_ralk:OnTakeDamage( params )
    if IsServer() then
        if self:GetParent() == params.unit and self:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
            if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
                self:IncrementStackCount()
            end

            self:SetDuration(self:GetAbility():GetSpecialValueFor("stack_duration"), true)
        end
    end
end
