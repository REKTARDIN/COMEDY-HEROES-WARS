if hades_rift_of_death == nil then hades_rift_of_death = class({}) end

local PEREOD = 0.25

function hades_rift_of_death:GetAOERadius()
	return self:GetSpecialValueFor( "radius" ) 
end

hades_rift_of_death.flTimer = 0

function hades_rift_of_death:OnSpellStart()
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection = vDirection:Normalized()

	local particle = "particles/stygian/hades_rift_of_death_projectile.vpcf"
	local speed = self:GetSpecialValueFor( "projectile_speed" ) 
	local range = self:GetSpecialValueFor( "projectile_distance" ) 
	
	self.flTimer = 0 

	local info = {
        EffectName = particle,
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        fStartRadius = 100,
        fEndRadius = 100,
        vVelocity = vDirection * speed,
        fDistance =  range + self:GetCaster():GetCastRangeBonus(),
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,
        bProvidesVision = true,
        iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        iVisionRadius = 100,
    }

	self.nProjID = ProjectileManager:CreateLinearProjectile( info )

	EmitSoundOn( "Hero_Undying.SoulRip.Cast" , self:GetCaster() )
end


function hades_rift_of_death:OnProjectileHitHandle(hTarget, vLocation, handle, kv)
	if IsServer() then 
		local caster = self:GetCaster()
		local hasTarget = IsValidEntity(hTarget)
		self.damage = self:GetSpecialValueFor( "damage" )
		self.souls_buff = self:GetCaster():FindModifierByName("modifier_hades_bowl_of_souls_passive")
		local soul_radius = 0
		local soul_range = 0
		if caster:HasModifier("modifier_hades_bowl_of_souls_passive") then
			local soul_radius = self.souls_buff:GetStackCount() * 10
		end
		self.radius = self:GetSpecialValueFor( "radius" ) + soul_radius
		
		if hasTarget then
			ApplyDamage({
				attacker = self:GetCaster(),
				victim = hTarget, 
				damage = self.damage, 
				ability = self, 
				damage_type = DAMAGE_TYPE_MAGICAL
			})
		else 
			local targets = FindUnitsInRadius( 
				self:GetCaster():GetTeamNumber(), 
				vLocation, 
				self:GetCaster(), 
				self.radius, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				0, 
				0, 
				false 
			)

			if #targets > 0 then
				for _,target in pairs(targets) do
					local aoe_damage = self.damage * 3
					ApplyDamage({
						attacker = self:GetCaster(),
						victim = target, 
						damage = aoe_damage, 
						ability = self, 
						damage_type = DAMAGE_TYPE_MAGICAL
					})
				end
			end

			local particle_cast = "particles/econ/items/pugna/pugna_ti9_immortal/pugna_ti9_immortal_netherblast.vpcf"
			local sound_cast = "Hero_Nevermore.Shadowraze"
			local point = vLocation

			local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
		    ParticleManager:SetParticleControl( effect_cast, 0, point )
			ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 1, 1 ) )
				
			EmitSoundOn(sound_cast, self:GetCaster())
		end
	end
end

