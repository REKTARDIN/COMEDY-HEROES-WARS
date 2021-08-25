outsider_soulbreak = class({})
LinkLuaModifier( "modifier_outsider_soulbreak", "abilities/outsider_soulbreak.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_outsider_soulbreak_debuff", "abilities/outsider_soulbreak.lua", LUA_MODIFIER_MOTION_NONE )

function outsider_soulbreak:GetIntrinsicModifierName()
     return "modifier_outsider_soulbreak"
end

function outsider_soulbreak:Debuff(hTarget)
    local mod = hTarget:FindModifierByName("modifier_outsider_soulbreak_debuff")
    
    if mod then
        mod:IncrementStackCount()

        return
    end

    mod = hTarget:AddNewModifier(self:GetCaster(), self, "modifier_outsider_soulbreak_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
    mod:IncrementStackCount()
end

if modifier_outsider_soulbreak == nil then modifier_outsider_soulbreak = class({}) end

function modifier_outsider_soulbreak:IsHidden() return true end
function modifier_outsider_soulbreak:IsPurgable() return false end

function modifier_outsider_soulbreak:DeclareFunctions ()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_outsider_soulbreak:OnAttackLanded (params)
    if IsServer () then
        if params.attacker == self:GetParent() and (not self:GetParent():PassivesDisabled()) and params.target:IsRealHero() and self:GetParent():IsRealHero() then
            ----self:GetAbility():Debuff(params.target)

            EmitSoundOn("Hero_Antimage.ManaBreak", params.target)
            
            local damage = params.target:GetTotalCooldowns(true) * (self:GetAbility():GetSpecialValueFor("percent_damage_per_burn") / 100) + self:GetAbility():GetAbilityDamage()
        
            ApplyDamage({attacker = self:GetCaster(), victim = params.target, damage = damage, ability = self:GetAbility(), damage_type = DAMAGE_TYPE_MAGICAL})
        end
    end
    return 0
end

function outsider_soulbreak:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 


if not modifier_outsider_soulbreak_debuff then modifier_outsider_soulbreak_debuff = class({}) end 

function modifier_outsider_soulbreak_debuff:IsDebuff() return true end
function modifier_outsider_soulbreak_debuff:IsHidden() return false end
function modifier_outsider_soulbreak_debuff:IsPurgable() return false end
function modifier_outsider_soulbreak_debuff:IsPurgeException() return true end

function modifier_outsider_soulbreak_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}

	return funcs
end

function modifier_outsider_soulbreak_debuff:GetEffectName ()
	return "particles/cosmos/cosmos_space_warp_debuff.vpcf"
end
  
function modifier_outsider_soulbreak_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_outsider_soulbreak_debuff:GetModifierPercentageCooldown( params )
	return self:GetAbility():GetSpecialValueFor("cooldown_per_hit") * self:GetStackCount() 
end