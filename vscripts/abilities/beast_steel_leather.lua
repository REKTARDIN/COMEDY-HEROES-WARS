beast_steel_leather = class({})
LinkLuaModifier( "modifier_beast_steel_leather", "abilities/beast_steel_leather.lua", LUA_MODIFIER_MOTION_NONE )

function beast_steel_leather:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local duration = ability:GetSpecialValueFor("duration")

	if caster:HasScepter() then
		duration = ability:GetSpecialValueFor("scepter_duration")
	end
	
	caster:Purge(false, true, false, true, true)
	caster:RemoveModifierByName( "modifier_knockback" )
	caster:AddNewModifier(caster, ability, "modifier_beast_steel_leather", {duration = duration})
end

modifier_beast_steel_leather = class({})
function modifier_beast_steel_leather:AllowIllusionDuplicate() return false end
function modifier_beast_steel_leather:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end
function modifier_beast_steel_leather:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_beast_steel_leather:IsDebuff() return false end
function modifier_beast_steel_leather:IsHidden() return false end
function modifier_beast_steel_leather:IsPurgable() return false end
function modifier_beast_steel_leather:DeclareFunctions()		
	local decFuncs = {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	MODIFIER_PROPERTY_STATUS_RESISTANCE,
	MODIFIER_PROPERTY_MODEL_SCALE}					 
	return decFuncs		
end

function modifier_beast_steel_leather:GetModifierModelScale()
	return self:GetAbility():GetSpecialValueFor("model_scale")
end

function modifier_beast_steel_leather:GetModifierIncomingDamage_Percentage()
	local damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduce") * (-1)
	return damage_reduction
end