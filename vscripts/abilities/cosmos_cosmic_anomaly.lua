cosmos_cosmic_anomaly = class({})
LinkLuaModifier( "modifier_cosmos_cosmic_anomaly_thinker", "abilities/cosmos_cosmic_anomaly", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cosmos_cosmic_anomaly_recurrence_thinker", "abilities/cosmos_cosmic_anomaly", LUA_MODIFIER_MOTION_NONE )

function cosmos_cosmic_anomaly:GetAOERadius()
	local radius = self:GetSpecialValueFor("radius")

	return radius
end

function cosmos_cosmic_anomaly:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local point = self:GetCursorPosition()

	local damage = ability:GetSpecialValueFor("anomaly_damage")
	local duration = ability:GetSpecialValueFor("anomaly_delay")
	local recurrence_count = ability:GetSpecialValueFor("recurrence_count")
	local recurrence  = ability:GetSpecialValueFor("recurrence_damage")

	if IsServer() then
		local thinker = CreateModifierThinker(caster, self, "modifier_cosmos_cosmic_anomaly_thinker", 
		{duration = duration, 
		recurrence_count = recurrence_count, 
		damage = damage, 
		recurrence = recurrence}, 
		point, 
		caster:GetTeamNumber(), 
		false)
	end
end

modifier_cosmos_cosmic_anomaly_thinker = class({})

function modifier_cosmos_cosmic_anomaly_thinker:OnCreated(params)
	if IsServer() then
		self.recurrence_count = params.recurrence_count
		self.damage = params.damage
		self.recurrence = params.recurrence
	end
end

function modifier_cosmos_cosmic_anomaly_thinker:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local point = self:GetParent():GetAbsOrigin()
		local ability = self:GetAbility()
		local damage = self.damage
		local radius = ability:GetSpecialValueFor("radius")
		local duration = ability:GetSpecialValueFor("recurrence_delay")
		local recurrence = false
		
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false
		)

		for _,enemy in pairs(enemies) do
			if not enemy:IsMagicImmune() then
				local damageTable = {victim = enemy,
					attacker = caster,
					damage = damage,
					damage_type = ability:GetAbilityDamageType(),
					ability = ability
				}
				ApplyDamage(damageTable)
			end

			if enemy:IsRealHero() or not enemy:IsAlive() then
				if self.recurrence_count > 0 then
					recurrence = true
				end
			end
		end
		
		local particle_cast = "particles/econ/items/oracle/oracle_ti10_immortal/oracle_ti10_immortal_purifyingflames_hit.vpcf"
		local sound_cast = "Hero_Dark_Seer.Wall_of_Replica_Start"

		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		
		EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
		
		if recurrence == true then
			local create_thinker = CreateModifierThinker(caster, ability, "modifier_cosmos_cosmic_anomaly_recurrence_thinker", {
			duration = duration, 
			recurrence_count = self.recurrence_count-1, 
			recurrence = self.recurrence}, 
			point, 
			caster:GetTeamNumber(),
			false)
		end
		
		UTIL_Remove( self:GetParent() )
	end
end

modifier_cosmos_cosmic_anomaly_recurrence_thinker = class({})

function modifier_cosmos_cosmic_anomaly_recurrence_thinker:OnCreated(params)
	if IsServer() then
		self.recurrence_count = params.recurrence_count
		self.recurrence = params.recurrence
	end
end
function modifier_cosmos_cosmic_anomaly_recurrence_thinker:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local point = self:GetParent():GetAbsOrigin()
		local ability = self:GetAbility()
		local damage = self.recurrence
		local radius = ability:GetSpecialValueFor("radius")
		local duration = ability:GetSpecialValueFor("recurrence_delay")
		local recurrence = false
		
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			self:GetParent():GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false
		)

		for _,enemy in pairs(enemies) do
			if not enemy:IsMagicImmune() then
				local damageTable = {victim = enemy,
					attacker = caster,
					damage = damage,
					damage_type = ability:GetAbilityDamageType(),
					ability = ability
				}
				ApplyDamage(damageTable)
			end
			if enemy:IsRealHero() or not enemy:IsAlive() then
				if self.recurrence_count > 0 then
					recurrence = true
				end
			end
		end
		
		local particle_cast = "particles/econ/items/oracle/oracle_ti10_immortal/oracle_ti10_immortal_purifyingflames_hit.vpcf"
		local sound_cast = "Hero_Dark_Seer.Ion_Shield_Start.TI8"

		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( radius, radius, radius ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
		
		EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
		
		if recurrence == true then
			local thinker = CreateModifierThinker(caster, ability, "modifier_cosmos_cosmic_anomaly_recurrence_thinker", 
			{duration = duration, 
			recurrence_count = self.recurrence_count-1, 
			recurrence = self.recurrence}, 
			point, 
			caster:GetTeamNumber(), 
			false)
		end
		
		UTIL_Remove( self:GetParent() )
	end
end