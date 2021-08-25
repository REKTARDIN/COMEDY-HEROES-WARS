ancient_lich_dark_fissure = class({})
LinkLuaModifier( "ancient_lich_dark_fissure_thinker", "abilities/ancient_lich_dark_fissure.lua", LUA_MODIFIER_MOTION_NONE )

function ancient_lich_dark_fissure:IsStealable()
	return false
end

function ancient_lich_dark_fissure:GetAOERadius()
	return self:GetSpecialValueFor( "radius" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_ancient_lich_1") or 0)
end

function ancient_lich_dark_fissure:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	

	-- get values
	local delay = self:GetSpecialValueFor("delay")
	local vision_distance = self:GetSpecialValueFor("vision_distance")
	local vision_duration = self:GetSpecialValueFor("vision_duration")


	-- create modifier thinker
	CreateModifierThinker(
		caster,
		self,
		"ancient_lich_dark_fissure_thinker",
		{ duration = delay },
		point,
		caster:GetTeamNumber(),
		false
	)

    AddFOWViewer( caster:GetTeamNumber(), point, vision_distance, vision_duration, false )
end 


ancient_lich_dark_fissure_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function ancient_lich_dark_fissure_thinker:IsHidden()
	return true
end

function ancient_lich_dark_fissure_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function ancient_lich_dark_fissure_thinker:OnCreated( kv )
	if IsServer() then
		-- references
		self.damage = self:GetAbility():GetSpecialValueFor("fissure_damage") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_ancient_lich_2") or 0)
		self.radius = self:GetAbility():GetSpecialValueFor("radius") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_ancient_lich_1") or 0)
		-- Play effects
		self:PlayEffects1()
	end
end

function ancient_lich_dark_fissure_thinker:OnDestroy( kv )
	if IsServer() then
		
		local damageTable = {	
			attacker = self:GetCaster(),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
		}

		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	
			self:GetParent():GetOrigin(),	
			nil,	
			self.radius,	
			DOTA_UNIT_TARGET_TEAM_ENEMY,	
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	
			DOTA_UNIT_TARGET_FLAG_NONE,
			0,
			false
		)

		for _,enemy in pairs(enemies) do
			damageTable.victim = enemy
			damageTable.damage = self.damage
			ApplyDamage(damageTable)
		end


		
		self:PlayEffects2()
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function ancient_lich_dark_fissure_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/heroes_underlord/underlord_pitofmalice_pre.vpcf"
	local sound_cast = "Conquest.SpikeTrap.Plate"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
end

function ancient_lich_dark_fissure_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/stygian/ancient_lich_dark_fissure_strikeeshrac_split_earth.vpcf"
	local sound_cast = "Conquest.SpikeTrap.Activate"
	local sound_cast2 = "Hero_Lich.FrostBlast.Immortal"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast2, self:GetCaster() )
end