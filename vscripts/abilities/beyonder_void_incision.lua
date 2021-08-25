beyonder_void_incision = class({})

LinkLuaModifier ("modifier_beyonder_void_incision_timer", "abilities/beyonder_void_incision.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_beyonder_void_incision_debuff", "abilities/beyonder_void_incision.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_beyonder_void_incision_debuff_silence", "abilities/beyonder_void_incision.lua", LUA_MODIFIER_MOTION_NONE)

function beyonder_void_incision:CastFilterResultTarget(hTarget)
    if hTarget == self:GetCaster() then
        return UF_FAIL_FRIENDLY
    end
	
	return self.BaseClass.CastFilterResultTarget(self, hTarget)
end

function beyonder_void_incision:OnSpellStart()
    if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local get_ata_damage = self:GetCaster():GetAverageTrueAttackDamage(target) * self:GetSpecialValueFor("critical_damage")/100
		local damage = get_ata_damage
		local duration = self:GetSpecialValueFor("duration")

		if target:TriggerSpellAbsorb(self) then
			return nil
		end

		ProjectileManager:ProjectileDodge(caster)
		
		local caster_pos = caster:GetOrigin()
		local target_pos = target:GetOrigin()

		FindClearSpaceForUnit(caster, target_pos, true)

		local particle_blink_start = ParticleManager:CreateParticle("particles/stygian/beyonder_9/blink_dagger_ti9_start_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_blink_start, 0, caster_pos)
		ParticleManager:SetParticleControl(particle_blink_start, 1, caster_pos)
		ParticleManager:ReleaseParticleIndex(particle_blink_start)

		local particle_blink_end = ParticleManager:CreateParticle("particles/stygian/beyonder_void_slash_end.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_blink_end, 0, target_pos)
		ParticleManager:SetParticleControl(particle_blink_end, 1, target_pos)
		ParticleManager:ReleaseParticleIndex(particle_blink_end)

		local particle_crit = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf" , PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:SetParticleControlEnt( particle_crit, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( particle_crit, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( particle_crit )

		local particle_trail = ParticleManager:CreateParticle( "particles/stygian/beyonder_void_slash_trail.vpcf", PATTACH_WORLDORIGIN, caster )
		ParticleManager:SetParticleControl( particle_trail, 0, target_pos )
		ParticleManager:SetParticleControl( particle_trail, 1, caster_pos )
		ParticleManager:ReleaseParticleIndex( particle_trail )

		if target and (not target:IsNull()) then
			SendOverheadEventMessage( target, OVERHEAD_ALERT_CRITICAL , target, math.floor( damage ), nil )

			target:AddNewModifier(caster, self, "modifier_beyonder_void_incision_timer", {duration = 0.5})
								 
			local damage = {   
				victim   = target,
				attacker = caster,
				damage   = damage,
				damage_type = self:GetAbilityDamageType(),
				ability  = self
			}

			ApplyDamage(damage)

			EmitSoundOn( "Hero_Antimage.ManaBreak", caster)
		end
	end
end

modifier_beyonder_void_incision_timer = class({})

function modifier_beyonder_void_incision_timer:IsHidden() 
    return true 
end

function modifier_beyonder_void_incision_timer:RemoveOnDeath() 
    return false 
end

function modifier_beyonder_void_incision_timer:IsPurgable() 
    return false 
end

function modifier_beyonder_void_incision_timer:OnCreated()
    if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local target = self:GetParent()

		local center = caster:GetAbsOrigin()
		local debuff_duration = ability:GetSpecialValueFor("debuff_duration")
		local knockback_distance = ability:GetSpecialValueFor("knockback_distance")
		local knockback_height = ability:GetSpecialValueFor("knockback_height")
		local knockback_duration = ability:GetSpecialValueFor("knockback_duration")

		local knockback = {
			should_stun = true,                                
			knockback_duration = knockback_duration,
			duration = knockback_duration,
			knockback_distance = knockback_distance,
			knockback_height = knockback_height,
			center_x = center.x,
			center_y = center.y,
			center_z = center.z
		}
		
		target:AddNewModifier(caster, ability, "modifier_knockback", knockback)
	end
end

function modifier_beyonder_void_incision_timer:OnDestroy()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_beyonder_void_incision_debuff", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")}) 
		
		if self:GetCaster():HasTalent("special_bonus_unique_beyonder_1") then 
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_beyonder_void_incision_debuff_silence", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
		end
	end
end

modifier_beyonder_void_incision_debuff = class({})

function modifier_beyonder_void_incision_debuff:IsHidden() 
    return false
end

function modifier_beyonder_void_incision_debuff:RemoveOnDeath() 
    return false 
end

function modifier_beyonder_void_incision_debuff:IsPurgable() 
    return true 
end

function modifier_beyonder_void_incision_debuff:GetEffectName()
    return "particles/stygian/beyonder_void_slash_debuff.vpcf"
end
          
function modifier_beyonder_void_incision_debuff:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function modifier_beyonder_void_incision_debuff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor( "debuff_armor_reduction" )*(-1)
end

function modifier_beyonder_void_incision_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor( "debuff_movespeed_reduction" )*(-1)
end
  
modifier_beyonder_void_incision_debuff_silence = class({})

function modifier_beyonder_void_incision_debuff_silence:IsHidden() 
    return true
end

function modifier_beyonder_void_incision_debuff_silence:RemoveOnDeath() 
    return false 
end

function modifier_beyonder_void_incision_debuff_silence:IsPurgable() 
    return true 
end

function modifier_beyonder_void_incision_debuff_silence:CheckState()
	local state = {
        [MODIFIER_STATE_SILENCED] = true,
	}

	return state
end