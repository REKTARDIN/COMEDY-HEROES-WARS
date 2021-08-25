medivh_raven_form = class({})
LinkLuaModifier( "modifier_medivh_raven_form_buff", "abilities/medivh_raven_form.lua", LUA_MODIFIER_MOTION_NONE )

function medivh_raven_form:GetAssociatedSecondaryAbilities()
	return "medivh_cancel_raven_form"
end

function medivh_raven_form:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")

		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/silencer/silencer_ti6/silencer_last_word_dmg_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
		
		ProjectileManager:ProjectileDodge(caster)

		caster:AddNewModifier(caster, self, "modifier_medivh_raven_form_buff", {duration = duration})
		
		caster:SwapAbilities("medivh_raven_form", "medivh_cancel_raven_form", false, true)

		EmitSoundOn("Medivh_Raven_Form.Cast", caster)
	end
end

modifier_medivh_raven_form_buff = class({})

function modifier_medivh_raven_form_buff:IsHidden() 
    return false
end

function modifier_medivh_raven_form_buff:RemoveOnDeath() 
    return true 
end

function modifier_medivh_raven_form_buff:IsPurgable() 
    return false 
end

modifier_medivh_raven_form_buff.m_hAbils = {}

function modifier_medivh_raven_form_buff:OnCreated()
	if IsServer() then
		self.parent = self:GetParent()
		self.ability = self:GetAbility()

		self:SetStackCount(self:GetCaster():FindModifierByName("modifier_medivh_dark_magician"):GetStackCount())

		--- Disable abils

		table.insert( self.m_hAbils, self:GetCaster():FindAbilityByName("medivh_dark_blast"))
		table.insert( self.m_hAbils, self:GetCaster():FindAbilityByName("medivh_fel_blast"))
		table.insert( self.m_hAbils, self:GetCaster():FindAbilityByName("medivh_dust_of_appearance"))
		table.insert( self.m_hAbils, self:GetCaster():FindAbilityByName("medivh_sargeras_presence"))

		for _, ability in pairs(self.m_hAbils) do 
			if IsValidEntity(ability) then
				ability:SetActivated(false)
			end
		end
    end
end

function modifier_medivh_raven_form_buff:OnRemoved()
	if IsServer() then
		self:GetCaster():SwapAbilities("medivh_cancel_raven_form", "medivh_raven_form", false, true)

		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/silencer/silencer_ti6/silencer_last_word_dmg_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		
		for _, ability in pairs(self.m_hAbils) do 
			if IsValidEntity(ability) then
				ability:SetActivated(true)
			end
		end

		self.m_hAbils = nil
		self.m_hAbils = {}
	end
end

function modifier_medivh_raven_form_buff:CheckState()
	local state = {
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_DISARMED] = true,
    }

	return state
end

function modifier_medivh_raven_form_buff:DeclareFunctions()
	local func = {  
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
	    MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,                   
    }

	return func
end

function modifier_medivh_raven_form_buff:GetModifierModelScale() 
	return 20 
end

function modifier_medivh_raven_form_buff:GetModifierModelChange()
	return "models/items/beastmaster/hawk/beast_heart_marauder_beast_heart_marauder_raven/beast_heart_marauder_beast_heart_marauder_raven.vmdl"
end

function modifier_medivh_raven_form_buff:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mana_regen") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_medivh_2") or 0)
end

function modifier_medivh_raven_form_buff:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_medivh_2") or 0)
end

function modifier_medivh_raven_form_buff:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("bonus_movespeed") + self:GetStackCount()
end

function modifier_medivh_raven_form_buff:GetModifierMoveSpeed_Max()
	return self:GetAbility():GetSpecialValueFor("max_movespeed") + self:GetStackCount()
end

	

