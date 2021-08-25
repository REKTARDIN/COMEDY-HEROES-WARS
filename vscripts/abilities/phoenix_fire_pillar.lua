phoenix_fire_pillar = class({})
LinkLuaModifier( "modifier_phoenix_fire_pillar", "abilities/phoenix_fire_pillar.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phoenix_fire_pillar_thinker","abilities/phoenix_fire_pillar.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function phoenix_fire_pillar:GetAOERadius()
	return self:GetSpecialValueFor( "array_aoe" )
end

--------------------------------------------------------------------------------

function phoenix_fire_pillar:OnSpellStart()
	self.aoe = self:GetSpecialValueFor( "aoe" )
	self.delay_time = self:GetSpecialValueFor( "delay_time" )

	local kv = {}
	CreateModifierThinker( self:GetCaster(), self, "modifier_phoenix_fire_pillar_thinker", kv, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false )
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

modifier_phoenix_fire_pillar_thinker = class({})

--------------------------------------------------------------------------------

function modifier_phoenix_fire_pillar_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_phoenix_fire_pillar_thinker:OnCreated( kv )
	self.aoe = self:GetAbility():GetSpecialValueFor( "array_aoe" )
	self.stun_duration = self:GetAbility():GetSpecialValueFor( "stun_duration" )
    self.delay_time = self:GetAbility():GetSpecialValueFor( "delay_time" )
    
	if IsServer() then
		self:StartIntervalThink( self.delay_time )

		self.damage = self:GetAbility():GetAbilityDamage()
		
		EmitSoundOnLocationForAllies( self:GetParent():GetOrigin(), "Ability.PreLightStrikeArray", self:GetCaster() )
		
		local nFXIndex = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf", PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.aoe, 1, 1 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

--------------------------------------------------------------------------------

function modifier_phoenix_fire_pillar_thinker:OnIntervalThink()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.aoe, false )
		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), self.aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then

					local damage = {
						victim = enemy,
						attacker = self:GetCaster(),
						damage = self.damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = self:GetAbility()
					}

					ApplyDamage( damage )
					enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_stunned", { duration = self.stun_duration } )
				end
			end
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.aoe, 1, 1 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Ability.LightStrikeArray", self:GetCaster() )

		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------