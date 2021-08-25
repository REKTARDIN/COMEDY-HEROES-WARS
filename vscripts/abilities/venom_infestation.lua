if not venom_infestation then venom_infestation = class({}) end

LinkLuaModifier( "modifier_venom_infestation", "abilities/venom_infestation.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_venom_infestation_debuff", "abilities/venom_infestation.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_venom_infestation_buff", "abilities/venom_infestation.lua", LUA_MODIFIER_MOTION_NONE )

function venom_infestation:GetIntrinsicModifierName()
	return "modifier_venom_infestation"
end

modifier_venom_infestation = class({})

function modifier_venom_infestation:IsHidden()
	return true
end

function modifier_venom_infestation:OnCreated()
	if IsServer() then
		
	end
end

function modifier_venom_infestation:IsPurgable()
	return false
end

function modifier_venom_infestation:RemoveOnDeath()
	return false
end

function modifier_venom_infestation:DeclareFunctions ()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_venom_infestation:OnAttackLanded (params)
	if IsServer() then
	    if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() then
            if params.target:HasModifier("modifier_venom_infestation_debuff") then
                if params.target:FindModifierByName("modifier_venom_infestation_debuff"):GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
                    params.target:FindModifierByName("modifier_venom_infestation_debuff"):IncrementStackCount()
                    params.target:FindModifierByName("modifier_venom_infestation_debuff"):SetDuration(self:GetAbility():GetSpecialValueFor("stack_duration"), false)
                else 
                    params.target:FindModifierByName("modifier_venom_infestation_debuff"):SetDuration(self:GetAbility():GetSpecialValueFor("stack_duration"), false)
                end
            else 
                params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_venom_infestation_debuff", {duration = self:GetAbility():GetSpecialValueFor("stack_duration")}):IncrementStackCount()
            end
        
            if self:GetParent():HasModifier("modifier_venom_infestation_buff") then
                if self:GetParent():FindModifierByName("modifier_venom_infestation_buff"):GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
                    self:GetParent():FindModifierByName("modifier_venom_infestation_buff"):IncrementStackCount()
                    self:GetParent():FindModifierByName("modifier_venom_infestation_buff"):SetDuration(self:GetAbility():GetSpecialValueFor("stack_duration"), false)
                else
                    self:GetParent():FindModifierByName("modifier_venom_infestation_buff"):SetDuration(self:GetAbility():GetSpecialValueFor("stack_duration"), false) 
                end
            else 
                self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_venom_infestation_buff", {duration = self:GetAbility():GetSpecialValueFor("stack_duration")}):IncrementStackCount()
            end

            self:GetAbility():UseResources(false, false, true)
	    end
	end
end

if modifier_venom_infestation_debuff == nil then modifier_venom_infestation_debuff = class({}) end 

function modifier_venom_infestation_debuff:IsPurgeException()
    return true
end

function modifier_venom_infestation_debuff:GetStatusEffectName()
    return "particles/units/heroes/hero_visage/status_effect_visage_chill_slow.vpcf"
end


function modifier_venom_infestation_debuff:StatusEffectPriority()
    return 1000
end

function modifier_venom_infestation_debuff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_venom_infestation_debuff:OnCreated( kv )
    if IsServer() then
        self:StartIntervalThink(1)
        self:OnIntervalThink()
    end
end


function modifier_venom_infestation_debuff:OnIntervalThink()
    if IsServer() then
        local damage = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self:GetAbility():GetSpecialValueFor("damage_per_stack") * self:GetStackCount(),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self:GetAbility()
        }

        local dmg = self:GetAbility():GetSpecialValueFor("damage_per_stack") * self:GetStackCount()
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), dmg, nil)
    
        ApplyDamage( damage )
    end
end


function modifier_venom_infestation_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_venom_infestation_debuff:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetAbility():GetSpecialValueFor("slowing_per_stack") * self:GetStackCount()
end

if modifier_venom_infestation_buff == nil then modifier_venom_infestation_buff = class({}) end 

function modifier_venom_infestation_buff:IsPurgeException()
    return true
end

function modifier_venom_infestation_buff:IsHidden()
    return true
end

function modifier_venom_infestation_buff:GetStatusEffectName()
    return "particles/units/heroes/hero_visage/status_effect_visage_chill_slow.vpcf"
end


function modifier_venom_infestation_buff:StatusEffectPriority()
    return 1000
end

function modifier_venom_infestation_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end


function modifier_venom_infestation_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_venom_infestation_buff:GetModifierHealAmplify_PercentageTarget( params )
	return self:GetAbility():GetSpecialValueFor("heal_per_stack") * self:GetStackCount()
end

function modifier_venom_infestation_buff:GetModifierHealAmplify_PercentageSource( params )
	return self:GetAbility():GetSpecialValueFor("heal_per_stack") * self:GetStackCount()
end