rocket_reinforced_ammo = class({})

LinkLuaModifier ("modifier_rocket_reinforced_ammo", "abilities/rocket_reinforced_ammo.lua", LUA_MODIFIER_MOTION_NONE)

function rocket_reinforced_ammo:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_rocket_reinforced_ammo", {duration = duration})

    EmitSoundOn("Ability.AssassinateLoad", caster)
end

---------------------------------------------------------------------------------------------------------------------

modifier_rocket_reinforced_ammo = class({})

function modifier_rocket_reinforced_ammo:IsHidden() 
    return false 
end

function modifier_rocket_reinforced_ammo:IsPurgable() 
    return false 
end

function modifier_rocket_reinforced_ammo:RemoveOnDeath() 
    return true 
end

function modifier_rocket_reinforced_ammo:DeclareFunctions()
    local func = {  
		MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, 
	}

    return func
end

function modifier_rocket_reinforced_ammo:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor( "bonus_attack_range" ) 
end

function modifier_rocket_reinforced_ammo:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_buff.vpcf"
end

function modifier_rocket_reinforced_ammo:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_rocket_reinforced_ammo:OnCreated(params)
    if IsServer() then
        self:SetStackCount(self:GetAbility():GetSpecialValueFor("bullets_count"))
        self:GetParent():SetRangedProjectileName("particles/units/heroes/hero_sniper/sniper_assassinate.vpcf")
    end
end

function modifier_rocket_reinforced_ammo:OnRefresh(params)
    if IsServer() then
        self:SetStackCount(self:GetAbility():GetSpecialValueFor("bullets_count"))
    end
end

function modifier_rocket_reinforced_ammo:OnAttack(params)
    if IsServer() then
        if params.attacker ~= self:GetParent() then
            return 
        end

		EmitSoundOn("Ability.Assassinate", self:GetParent())
        EmitSoundOn("Rocket_Reinforced_Ammo.Impact", params.target)

        self:DecrementStackCount()

        if self:GetStackCount() <= 0 then
			params.attacker:RemoveModifierByName("modifier_rocket_reinforced_ammo")
			return
        end
    end
end

function modifier_rocket_reinforced_ammo:OnAttackLanded(params)
    if IsServer() then
        if params.attacker ~= self:GetParent() then
            return 
        end
				
        local damage = self:GetAbility():GetSpecialValueFor("bullets_damage")

        local damage_table = {  
			victim = params.target,
			attacker = params.attacker,
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility() 
		}

		ApplyDamage(damage_table)
    end
end

function modifier_rocket_reinforced_ammo:OnRemoved(params)
    if IsServer() then
        self:GetParent():SetRangedProjectileName("particles/units/heroes/hero_sniper/sniper_base_attack.vpcf")
    end
end

