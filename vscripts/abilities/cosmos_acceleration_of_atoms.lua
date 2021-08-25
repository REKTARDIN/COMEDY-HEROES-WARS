cosmos_acceleration_of_atoms = class({})
LinkLuaModifier( "modifier_cosmos_acceleration_of_atoms", "abilities/cosmos_acceleration_of_atoms.lua", LUA_MODIFIER_MOTION_NONE )

function cosmos_acceleration_of_atoms:OnSpellStart()
	
	local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor( "duration" )
    local target = self:GetCursorTarget()

	target:AddNewModifier(
		caster, 
		self, 
		"modifier_cosmos_acceleration_of_atoms", 
		{ duration = duration } 
	)
end

modifier_cosmos_acceleration_of_atoms = class({})

function modifier_cosmos_acceleration_of_atoms:IsHidden()
	return false
end

function modifier_cosmos_acceleration_of_atoms:IsDebuff()
	return false
end

function modifier_cosmos_acceleration_of_atoms:IsPurgable()
	return true
end

function modifier_cosmos_acceleration_of_atoms:OnCreated( kv )
    self.amp = self:GetAbility():GetSpecialValueFor( "spell_amp_boost" ) / 100
	self.speed_bonus = self:GetAbility():GetSpecialValueFor( "speed_boost" ) / 100
	self.mana_regen = self:GetAbility():GetSpecialValueFor( "mana_regen_boost" ) / 100
	
	if self:GetParent() ~= self:GetAbility():GetCaster() then
		self.amp = self.amp / 2
		self.speed_bonus = self.speed_bonus / 2
		self.mana_regen = self.mana_regen / 2
	end
	
	if not IsServer() then 
        return 
    end

    local sound_cast = "Hero_Dark_Seer.Surge"
    
	EmitSoundOn( sound_cast, self:GetParent() )
	
	self:SetStackCount(self:GetParent():GetManaRegen())
end

function modifier_cosmos_acceleration_of_atoms:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_cosmos_acceleration_of_atoms:OnRemoved()
end

function modifier_cosmos_acceleration_of_atoms:OnDestroy()
end

function modifier_cosmos_acceleration_of_atoms:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

	return funcs
end

function modifier_cosmos_acceleration_of_atoms:GetModifierMoveSpeedBonus_Constant()
	if IsServer() then --- GetManaRegen нету не клиенте
		self:SetStackCount(self:GetParent():GetManaRegen())
	end
	
	return self:GetStackCount() * self.speed_bonus 
end

function modifier_cosmos_acceleration_of_atoms:GetModifierConstantManaRegen()
	return self:GetParent():GetMana() * self.mana_regen
end

function modifier_cosmos_acceleration_of_atoms:GetModifierSpellAmplify_Percentage()
	if IsServer() then --- GetManaRegen нету не клиенте
		self:SetStackCount(self:GetParent():GetManaRegen())
	end

	return self:GetStackCount() * self.amp 
end

function modifier_cosmos_acceleration_of_atoms:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_cosmos_acceleration_of_atoms:GetActivityTranslationModifiers()
	return "haste"
end

function modifier_cosmos_acceleration_of_atoms:CheckState()
	local state = {
		[MODIFIER_STATE_UNSLOWABLE] = true,
	}

	return state
end

function modifier_cosmos_acceleration_of_atoms:GetEffectName()
	return "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf"
end

function modifier_cosmos_acceleration_of_atoms:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end