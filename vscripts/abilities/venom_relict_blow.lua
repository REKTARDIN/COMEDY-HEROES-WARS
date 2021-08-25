if not venom_relict_blow then venom_relict_blow = class({}) end

LinkLuaModifier( "modifier_venom_relict_blow", "abilities/venom_relict_blow.lua", LUA_MODIFIER_MOTION_NONE )

function venom_relict_blow:OnSpellStart()

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_venom_relict_blow", {duration = 4})
end

modifier_venom_relict_blow = class({})

function modifier_venom_relict_blow:IsHidden()
	return false
end

function modifier_venom_relict_blow:OnCreated()
	if IsServer() then
		
	end
end

function modifier_venom_relict_blow:IsPurgable()
	return false
end

function modifier_venom_relict_blow:RemoveOnDeath()
	return false
end

function modifier_venom_relict_blow:DeclareFunctions ()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_venom_relict_blow:OnAttackLanded (params)
	if IsServer() then
        if params.attacker == self:GetParent() and not params.target:IsBuilding() then

            local target = params.target
            
            local dmc = self:GetAbility():GetSpecialValueFor("damage") + (self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor("str_mult_damage") ) + (self:GetCaster():GetAverageTrueAttackDamage(params.target) * (self:GetAbility():GetSpecialValueFor("base_attack_reduction_ptc") / 100))
             
                local damage = {
                    victim = target,
                    attacker = self:GetParent(),
                    damage = dmc,
                    damage_type = self:GetAbility():GetAbilityDamageType(),
                    ability = self:GetAbility()
                }
            
            ApplyDamage( damage )

            SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, dmc, nil)

            self:GetParent():Heal(((self:GetAbility():GetSpecialValueFor("heal") / 100) * self:GetParent():GetMaxHealth()) + (dmc / 2), self:GetAbility())

            self:GetParent():RemoveModifierByName("modifier_venom_relict_blow")
	    end
	end
end
