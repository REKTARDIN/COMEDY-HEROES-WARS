--------------------------------------------------------------------------------
golden_gold_sun_beams = class({})
LinkLuaModifier( "modifier_golden_gold_sun_beams", "abilities/golden_gold_sun_beams", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function golden_gold_sun_beams:GetIntrinsicModifierName()
	return "modifier_golden_gold_sun_beams"
end

golden_gold_sun_beams.m_mayhem_ability = nil

function golden_gold_sun_beams:Spawn()
	if IsServer() then
		self.m_mayhem_ability = self:GetCaster():FindAbilityByName("golden_god_astral_mayhem")
	end
end

golden_gold_sun_beams.first_target_damage = 0

function golden_gold_sun_beams:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil then
		EmitSoundOn( "Hero_TemplarAssassin.Meld.Attack", hTarget )

		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.first_target_damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}	
		                
		ApplyDamage(damage)

		----- Talent parse
		if self:GetCaster():HasTalent("special_bonus_unique_goldengod_5") and IsValidEntity(self.m_mayhem_ability) and self.m_mayhem_ability:IsCooldownReady() then
			self.m_mayhem_ability:UseResources(true, false, true)
			self.m_mayhem_ability:DoDebuff(hTarget)
		end
	end

	return true
end

modifier_golden_gold_sun_beams = class({})

function modifier_golden_gold_sun_beams:IsHidden() return true end
function modifier_golden_gold_sun_beams:IsPurgable() return false end

function modifier_golden_gold_sun_beams:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }
	return funcs
end

function modifier_golden_gold_sun_beams:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and IsValidEntity(params.target) and (not self:GetCaster():PassivesDisabled()) then		
			EmitSoundOn("Hero_TemplarAssassin.PsiBlade", params.target)
            
            self:CheckAngles(params)
		end
	end
end

function modifier_golden_gold_sun_beams:CheckAngles(params)
    local caster = self:GetParent()
	local target = params.target
	local ability = self:GetAbility()
	
	-- Notes the origin of the first target to be the center of the findunits radius
	local first_target_origin = target:GetAbsOrigin()
	-- Notes the damage the first target takes to apply to the other targets
	ability.first_target_damage = params.damage
		
	-- Gets the caster's origin difference from the target
	local caster_origin_difference = caster:GetAbsOrigin() - first_target_origin 

	-- Get the radian of the origin difference between the attacker and TA. We use this to figure out at what angle the victim is at relative to the TA.
	local caster_origin_difference_radian = math.atan2(caster_origin_difference.y, caster_origin_difference.x)
	
	-- Convert the radian to degrees.
	caster_origin_difference_radian = caster_origin_difference_radian * 180
	local attacker_angle = caster_origin_difference_radian / math.pi
	-- Turns negative angles into positive ones and make the math simpler.
	attacker_angle = attacker_angle + 180.0
	
	local radius = ability:GetSpecialValueFor("attack_spill_range")
	local attack_spill_width = ability:GetSpecialValueFor("attack_spill_width")/2
	
	-- Units in radius
	local units = FindUnitsInRadius(caster:GetTeamNumber(), first_target_origin, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	
	-- Calculates the position of each found unit in relation to the last target
	for i,unit in ipairs(units) do
		if unit ~= target then
		
			local target_origin_difference = target:GetAbsOrigin() - unit:GetAbsOrigin()
			
			-- Get the radian of the origin difference between the last target and the unit. We use this to figure out at what angle the unit is at relative to the the target.
			local target_origin_difference_radian = math.atan2(target_origin_difference.y, target_origin_difference.x)
	
			-- Convert the radian to degrees.
			target_origin_difference_radian = target_origin_difference_radian * 180
			local victim_angle = target_origin_difference_radian / math.pi
			-- Turns negative angles into positive ones and make the math simpler.
			victim_angle = victim_angle + 180.0
	
			-- The difference between the world angle of the caster-target vector and the target-unit vector
			local angle_difference = math.abs(victim_angle - attacker_angle)			
			
			local new_target = false
			
			-- Ensures the angle difference is less than the allowed width
			if angle_difference <= attack_spill_width then
				local info = {
                    Target = unit,
                    Source = target,
                    Ability = ability,
                    EffectName = "particles/econ/items/templar_assassin/templar_assassin_focal/ta_focal_psi_blade.vpcf",
                    bDodgeable = false,
                    iMoveSpeed = self:GetCaster():GetProjectileSpeed(),
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
                }
                
                ProjectileManager:CreateTrackingProjectile( info )

				new_target = true
			end
		end
	end
end
