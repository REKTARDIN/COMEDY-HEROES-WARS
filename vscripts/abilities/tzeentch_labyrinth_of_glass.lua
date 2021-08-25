tzeentch_labyrinth_of_glass = class({})

LinkLuaModifier( "modifier_tzeentch_labyrinth_of_glass", "abilities/tzeentch_labyrinth_of_glass", LUA_MODIFIER_MOTION_NONE )

-- Init Abilities
function tzeentch_labyrinth_of_glass:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_chen/chen_divine_favor_buff.vpcf", context )
end

--------------------------------------------------------------------------------
-- Ability Start
function tzeentch_labyrinth_of_glass:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then
		return
	end

	-- logic
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_tzeentch_labyrinth_of_glass", -- modifier name
		{ duration = duration } -- kv
	)

	EmitSoundOn( "Hero_VoidSpirit.AetherRemnant.Destroy", self:GetCaster() )
	EmitSoundOn( "Hero_VoidSpirit.AetherRemnant.Target", target )
end

modifier_tzeentch_labyrinth_of_glass = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_tzeentch_labyrinth_of_glass:IsHidden()
	return false
end

function modifier_tzeentch_labyrinth_of_glass:IsDebuff()
	return true
end

function modifier_tzeentch_labyrinth_of_glass:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_tzeentch_labyrinth_of_glass:OnCreated( kv )
	-- references
    self.spell_amp = self:GetAbility():GetSpecialValueFor( "spell_damage_increase" )
    self.manacost_reduction = self:GetAbility():GetSpecialValueFor( "manacost_reduction" )
    self.cooldown_reduction = self:GetAbility():GetSpecialValueFor( "cooldown_reduction" )

    if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
        self.spell_amp = -self.spell_amp
        self.manacost_reduction = -self.manacost_reduction
        self.cooldown_reduction = -self.cooldown_reduction
    end
end

function modifier_tzeentch_labyrinth_of_glass:OnRefresh( kv )
	-- references
	self:OnCreated(kv)
end

function modifier_tzeentch_labyrinth_of_glass:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_tzeentch_labyrinth_of_glass:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}

	return funcs
end

function modifier_tzeentch_labyrinth_of_glass:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_tzeentch_labyrinth_of_glass:GetModifierPercentageManacostStacking()
	return self.manacost_reduction
end

function modifier_tzeentch_labyrinth_of_glass:GetModifierPercentageCooldown()
	return self.cooldown_reduction
end

function modifier_tzeentch_labyrinth_of_glass:OnAbilityFullyCast(params)
    if IsServer() then
        if params.unit == self:GetParent() and params.ability ~= self:GetAbility() then
            self:Destroy()
        end
    end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_tzeentch_labyrinth_of_glass:GetEffectName()
	return "particles/units/heroes/hero_chen/chen_divine_favor_buff.vpcf"
end

function modifier_tzeentch_labyrinth_of_glass:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
