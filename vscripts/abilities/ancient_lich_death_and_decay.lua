if ancient_lich_death_and_decay == nil then ancient_lich_death_and_decay = class({}) end
LinkLuaModifier( "modifier_ancient_lich_death_and_decay_thinker", "abilities/ancient_lich_death_and_decay.lua", LUA_MODIFIER_MOTION_NONE )

function ancient_lich_death_and_decay:GetAOERadius()
	return self:GetSpecialValueFor( "radius" ) + self:GetCaster():GetCastRangeBonus()
end

function ancient_lich_death_and_decay:OnSpellStart()
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
	vDirection = vDirection:Normalized()

	local particle = "particles/stygian/ancient_lich_death_and_decay_decay_proj_.vpcf"

	local info = {
        EffectName = particle,
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        fStartRadius = 100,
        fEndRadius = 100,
        vVelocity = vDirection * 1000,
        fDistance = self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() ) + self:GetCaster():GetCastRangeBonus(),
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


function ancient_lich_death_and_decay:OnProjectileHitHandle(hTarget, vLocation, handle, kv)
	if IsServer() and hTarget then
		local caster = self:GetCaster()
		local point = vLocation
		local duration = self:GetSpecialValueFor("duration") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_ancient_lich_3") or 0)


		CreateModifierThinker(
			caster, 
			self, 
			"modifier_ancient_lich_death_and_decay_thinker", 
			{ duration = duration }, 
			point,
			caster:GetTeamNumber(),
			false
		)

		local targets = FindUnitsInRadius( 
			self:GetCaster():GetTeamNumber(), 
			point, 
			self:GetCaster(), 
			self:GetAOERadius(), 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 
			0, 
			false 
		)

	    if #targets > 0 then
		    for _,target in pairs(targets) do
			 ApplyDamage({
				attacker = self:GetCaster(),
				victim = target, 
				damage = self:GetAbilityDamage(), 
				ability = self, 
				damage_type = DAMAGE_TYPE_MAGICAL
			})
		end
	end
		ProjectileManager:DestroyLinearProjectile(handle)		
	end
end

modifier_ancient_lich_death_and_decay_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_ancient_lich_death_and_decay_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_ancient_lich_death_and_decay_thinker:OnCreated( kv )
	-- references
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_ancient_lich_1") or 0)
	self.damage = self:GetAbility():GetSpecialValueFor( "damage_percent" )
	local interval = 0.5

	if IsServer() then
		-- destroy trees
		GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.radius, true )

		
		self.damageTable = {
			victim = target,
			attacker = self:GetCaster(),
		    ---damage = 500,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}

		-- Start interval
		self:StartIntervalThink( interval )
		-- self:OnIntervalThink()

		-- play effects
		self:PlayEffects()
	end
end

function modifier_ancient_lich_death_and_decay_thinker:OnDestroy()
	if IsServer() then
		
		StopSoundOn( self.sound_cast, self:GetParent())
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_ancient_lich_death_and_decay_thinker:OnIntervalThink()
	-- find units in radius
	local base_damage = self:GetAbility():GetSpecialValueFor( "base_damage" )
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- apply damage
		self.damageTable.victim = enemy
		self.damageTable.damage = enemy:GetMaxHealth()*self.damage/100 + base_damage
		ApplyDamage( self.damageTable )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ancient_lich_death_and_decay_thinker:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/stygian/ancient_lich_death_and_decay_new.vpcf"
	self.sound_cast = "Hero_Undying.Decay.Cast.PaleAugur"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 1, 1 ) )
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( self.sound_cast, self:GetParent() )
end