predator_hunter_mode = class({})

--------------------------------------------------------------------------------

function predator_hunter_mode:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end

--------------------------------------------------------------------------------

function predator_hunter_mode:OnInventoryContentsChanged()
    self:SetHidden(not self:GetCaster():HasScepter())
    self:SetLevel(1)
end

--------------------------------------------------------------------------------

function predator_hunter_mode:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

--------------------------------------------------------------------------------

function predator_hunter_mode:GetChannelTime()
	return 3.66
end

--------------------------------------------------------------------------------

function predator_hunter_mode:OnAbilityPhaseStart()
	return not self:GetCaster():HasModifier("modifier_predator_tree_dance_tree")
end

--------------------------------------------------------------------------------

function predator_hunter_mode:OnChannelFinish( bInterrupted )
	if not bInterrupted then
		local radius = self:GetSpecialValueFor( "radius" )
        local damage = (self:GetSpecialValueFor( "damage" ) / 100) * self:GetCaster():GetMaxHealth()
        
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and not enemy:IsInvulnerable() then
					ApplyDamage({
						victim = enemy,
						attacker = self:GetCaster(),
						ability = self,
						damage = damage,
						damage_type = DAMAGE_TYPE_PHYSICAL
					})
				end
			end
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( radius, 0.0, 1.0 ) )
		ParticleManager:SetParticleControl( nFXIndex, 2, Vector( radius, 0.0, 1.0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

        EmitSoundOn( "Hero_Techies.Suicide", self:GetCaster() )
        
        GridNav:DestroyTreesAroundPoint( self:GetCaster():GetOrigin(), radius, false )
        
		if self:GetCaster():IsAlive() then
			ApplyDamage({
				victim = self:GetCaster(),
				attacker = self:GetCaster(),
				ability = self,
				damage = self:GetCaster():GetMaxHealth(),
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
            })
		end
	end
end