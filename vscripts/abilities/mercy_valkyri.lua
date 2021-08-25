mercy_valkyri = class({})

LinkLuaModifier( "modifier_mercy_valkyri", "abilities/mercy_valkyri", LUA_MODIFIER_MOTION_NONE )

function mercy_valkyri:GetBehavior()
    if not IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_mercy_2") then 
        return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end

    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function mercy_valkyri:GetIntrinsicModifierName()
    if not IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_mercy_2") then 
        return nil
    end

    return "modifier_mercy_valkyri"
end

function mercy_valkyri:OnSpellStart()
    if IsServer() then 
		self:GetCaster():AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_mercy_valkyri", -- modifier name
			{
				duration = self:GetSpecialValueFor("duration")
			}
		)
    end 
end

modifier_mercy_valkyri = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mercy_valkyri:IsHidden() return true end
function modifier_mercy_valkyri:IsPurgable() return false end

function modifier_mercy_valkyri:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/ambientfx_effigy_wm16_pedestal_fx_lvl3_c.vpcf"
end

function modifier_mercy_valkyri:StatusEffectPriority()
	return 1000
end

function modifier_mercy_valkyri:GetEffectName()
	return "particles/hero_mercy/mercy_ult_buff.vpcf"
end

function modifier_mercy_valkyri:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_mercy_valkyri:OnCreated(params)
    if IsServer() then
        EmitSoundOn("Hero_Wisp.Return", self:GetParent())
    end
end
