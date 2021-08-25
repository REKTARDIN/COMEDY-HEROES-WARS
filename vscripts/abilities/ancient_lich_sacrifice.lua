ancient_lich_sacrifice = class({})

LinkLuaModifier( "modifier_ancient_lich_sacrifice_buff", "abilities/ancient_lich_sacrifice.lua", LUA_MODIFIER_MOTION_NONE )


function ancient_lich_sacrifice:GetCooldown(nLevel)
	return self.BaseClass.GetCooldown( self, nLevel ) - (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_ancient_lich_4") or 0)
end

function ancient_lich_sacrifice:Spawn()
    if IsServer() then self:SetLevel(1) end
end

function ancient_lich_sacrifice:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")

	-- load data
	local conv_pct = self:GetSpecialValueFor( "health_conversion" )

	-- get mana heal
	local mana = target:GetHealth() * (conv_pct/100)
    caster:GiveMana( mana )
    caster:AddNewModifier( self:GetCaster(), self, "modifier_ancient_lich_sacrifice_buff", { duration = duration } )
    

	-- kill target
	target:Kill( self, caster )

	-- Play effects
	self:PlayEffects( target )
end

modifier_ancient_lich_sacrifice_buff = class({})

function modifier_ancient_lich_sacrifice_buff:IsPurgable()
	return false
end

function modifier_ancient_lich_sacrifice_buff:GetEffectName() return "particles/stygian/ancient_lich_sacrifice_heal.vpcf" end
function modifier_ancient_lich_sacrifice_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_ancient_lich_sacrifice_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ancient_lich_sacrifice_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}

	return funcs
end

function modifier_ancient_lich_sacrifice_buff:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("buff_bonus_amp")
end

function modifier_ancient_lich_sacrifice_buff:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor("buff_bonus_health_regen")
end
--------------------------------------------------------------------------------
-- Effects
function ancient_lich_sacrifice:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_lich/lich_dark_ritual.vpcf"
	local sound_cast = "Hero_Nevermore.RequiemOfSouls.Damage"

	-- Get Data

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	-- ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		target:GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end

