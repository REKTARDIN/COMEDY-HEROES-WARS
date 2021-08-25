medivh_sargeras_presence = class({})
LinkLuaModifier("modifier_medivh_sargeras_presence", "abilities/medivh_sargeras_presence.lua", LUA_MODIFIER_MOTION_NONE)

function medivh_sargeras_presence:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local sound = "Medivh_Ulti.Laugh"

	if self:GetCaster():HasTalent("DOTA_Tooltip_ability_special_bonus_unique_medivh_3") then 
        duration = duration + self:GetCaster():FindTalentValue("DOTA_Tooltip_ability_special_bonus_unique_medivh_3")
    end

	caster:SwapAbilities("medivh_dust_of_appearance", "medivh_fel_blast", false, true)

	-- add modifier
	caster:AddNewModifier(
		caster, 
		self, 
		"modifier_medivh_sargeras_presence", 
		{ duration = duration } 
	)
	EmitSoundOn(sound, caster)
end

modifier_medivh_sargeras_presence  = class({})

function modifier_medivh_sargeras_presence:IsHidden() 
    return false
end

function modifier_medivh_sargeras_presence:RemoveOnDeath() 
    return false 
end

function modifier_medivh_sargeras_presence:IsPurgable() 
    return false 
end

function modifier_medivh_sargeras_presence:OnRemoved()
	if IsServer() then
		self:GetCaster():SwapAbilities("medivh_fel_blast", "medivh_dust_of_appearance", false, true)
	end
end

function modifier_medivh_sargeras_presence:GetEffectName()
    return "particles/stygian/medivh_sargeras_presence_basedebuff.vpcf"
end

function modifier_medivh_sargeras_presence:StatusEffectPriority() 
	return 10 
end

function modifier_medivh_sargeras_presence:GetEffectAttachType() 
	return PATTACH_ABSORIGIN_FOLLOW 
end

function modifier_medivh_sargeras_presence:DeclareFunctions() 
    return { 
        MODIFIER_PROPERTY_MODEL_SCALE       
    } 
end

function modifier_medivh_sargeras_presence:GetModifierModelScale() 
	return 25 
end
