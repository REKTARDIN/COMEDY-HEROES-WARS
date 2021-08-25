scarlett_witch_energy_burst = class({})

LinkLuaModifier( "modifier_scarlett_witch_energy_burst_thinker", "abilities/scarlett_witch_energy_burst", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function scarlett_witch_energy_burst:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function scarlett_witch_energy_burst:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- logic
	CreateModifierThinker(
		caster,
		self,
		"modifier_scarlett_witch_energy_burst_thinker",
		{duration = self:GetSpecialValueFor("delay")},
		point,
		caster:GetTeamNumber(),
		false
	)
end

modifier_scarlett_witch_energy_burst_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_scarlett_witch_energy_burst_thinker:IsHidden()
	return true
end

function modifier_scarlett_witch_energy_burst_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_scarlett_witch_energy_burst_thinker:OnDestroy()
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) -- special value
	self.damage = self:GetAbility():GetSpecialValueFor( "blast_damage" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_scarlett_witch_1") or 0)

	if IsServer() then
        EmitSoundOn( "Hero_Grimstroke.DarkArtistry.Cast", self:GetParent() )	
        
        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        if #units > 0 then
            for _,unit in pairs(units) do
                EmitSoundOn( "Hero_Grimstroke.DarkArtistry.Damage", self:GetParent() )	

				print(self.damage)
                ApplyDamage( {
                    victim = unit,
                    attacker = self:GetAbility():GetCaster(),
                    damage = self.damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self:GetAbility()
                })
            end
        end

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 2, Vector(self.radius, self.radius, self.radius) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end
