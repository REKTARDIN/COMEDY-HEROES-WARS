--------------------------------------------------------------------------------

infinity_resonance_polarity = class({})
LinkLuaModifier( "modifier_infinity_resonance_polarity", "abilities/infinity_resonance_polarity", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function infinity_resonance_polarity:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- add modifier
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_infinity_resonance_polarity", -- modifier name
		{ duration = duration } -- kv
	)

	EmitSoundOn( "Hero_Phoenix.Attack", target )
end

--------------------------------------------------------------------------------

modifier_infinity_resonance_polarity = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_infinity_resonance_polarity:IsHidden()
	return false
end

function modifier_infinity_resonance_polarity:IsDebuff()
	return true
end

function modifier_infinity_resonance_polarity:IsStunDebuff()
	return false
end

function modifier_infinity_resonance_polarity:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_infinity_resonance_polarity:OnCreated( kv )
	-- references
    local tick_rate = self:GetAbility():GetSpecialValueFor( "tick_rate" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_infinity_2") or 0)
	
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_infinity_4") or 0)
    self.stun = self:GetAbility():GetSpecialValueFor( "stun_duration" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_infinity_3") or 0)
    self.radius = self:GetAbility():GetSpecialValueFor( "radius" )

	if IsServer() then
		-- precache damage
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}
		-- ApplyDamage(damageTable)

		-- Start interval
		self:StartIntervalThink( tick_rate )
		self:OnIntervalThink()
	end
end

function modifier_infinity_resonance_polarity:OnRefresh( kv )
	self:OnCreated( kv )
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_infinity_resonance_polarity:OnIntervalThink()
    -- stun
    
	if IsServer() then
		local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		local units_count = #units
		
		if units_count > 0 then
			self:GetParent():AddNewModifier(
				self:GetCaster(), -- player source
				self:GetAbility(), -- ability source
				"modifier_stunned", -- modifier name
				{ duration = self.stun } -- kv
			)

			self.damageTable.damage = self.damage * units_count

			-- damage
			ApplyDamage( self.damageTable )

			EmitSoundOn( "Hero_Phoenix.FireSpirits.Target", self:GetParent() )
			
			local nFXIndex = ParticleManager:CreateParticle( "particles/hero_infinity/infinity_resonant_explosion_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil );
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true );
			ParticleManager:ReleaseParticleIndex( nFXIndex );
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_infinity_resonance_polarity:GetEffectName()
	return "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6_knockback_debuff.vpcf"
end

function modifier_infinity_resonance_polarity:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_infinity_resonance_polarity:GetStatusEffectName()
	return "particles/status_fx/status_effect_enigma_malefice.vpcf"
end
