zeus_god_taunt = class({})
LinkLuaModifier( "modifier_zeus_god_taunt", "abilities/zeus_god_taunt.lua", LUA_MODIFIER_MOTION_NONE)

function zeus_god_taunt:GetManaCost( level )
	if self:GetCaster():HasModifier("modifier_zeus_god_taunt") then
		return 0
	else
		return self.BaseClass.GetManaCost(self, level)
	end
end
function zeus_god_taunt:ProcsMagicStick()
	if self:GetCaster():HasModifier("modifier_zeus_god_taunt") then
		return false
	else
		return true
	end
end
function zeus_god_taunt:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
	local duration = ability:GetSpecialValueFor("buff_duration")
	
	if caster:HasModifier("modifier_zeus_god_taunt") then
		caster:RemoveModifierByName("modifier_zeus_god_taunt")
	else
		caster:AddNewModifier(caster, ability, "modifier_zeus_god_taunt", {duration = duration})
		self:EndCooldown()
		
		local sound_cast = "Zeus_Taunt.Laugh"

		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), sound_cast, caster)
		
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
	end
end

modifier_zeus_god_taunt = class({})

function modifier_zeus_god_taunt:IsHidden() 
	return false 
end

function modifier_zeus_god_taunt:IsPurgable() 
	return false
end

function modifier_zeus_god_taunt:IsPurgeException() 
	return false 
end

function modifier_zeus_god_taunt:CheckState()
	local state = {[MODIFIER_STATE_DISARMED] = true}
	
    return state
end

function modifier_zeus_god_taunt:GetStatusEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun_slow.vpcf"
end

function modifier_zeus_god_taunt:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_zeus_god_taunt:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK,
	}
	return funcs
end
function modifier_zeus_god_taunt:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_magicresist")
end

function modifier_zeus_god_taunt:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_zeus_god_taunt:GetModifierEvasion_Constant()
	return 100
end

function modifier_zeus_god_taunt:OnAttack( params )
	if IsServer() then
		local caster = self:GetCaster()
		local modifier = self
		local ability = self:GetAbility()
		local max_stacks = ability:GetSpecialValueFor("max_stacks")
		
		if params.target == caster then
			if modifier:GetStackCount() < max_stacks then
				modifier:IncrementStackCount()
			end
		end
	end
end

function modifier_zeus_god_taunt:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local modifier = self
		local ability = self:GetAbility()
		local attack_damage = self:GetParent():GetAverageTrueAttackDamage(hTarget)
		local base_damage = ability:GetSpecialValueFor("damage")
		local stun = ability:GetSpecialValueFor("stun_duration")
		local radius = ability:GetSpecialValueFor("radius")
		local stacks = modifier:GetStackCount()
		local real_damage = base_damage + (attack_damage * stacks)
		
		caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_6)
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
		ability:UseResources( false, false, true )
		
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	
			caster:GetOrigin(),	
			nil,
			radius,	
			DOTA_UNIT_TARGET_TEAM_ENEMY,	
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	
			0,	
			0,	
			false	
		)
		
		for _,enemy in pairs(enemies) do
			
			local damageTable = {victim = enemy,
				damage = real_damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				attacker = caster,
				ability = ability
			}
			ApplyDamage(damageTable)
			enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun })
		end 
		
		self:PlayEffects()
	end
end

function modifier_zeus_god_taunt:PlayEffects()

	local particle_cast = "particles/econ/items/sven/sven_ti10_helmet/sven_ti10_helmet_gods_strength.vpcf"
	local sound_cast = "Hero_Sven.SignetLayer"
	local radius = self:GetAbility():GetSpecialValueFor("radius")

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOn( sound_cast, self:GetParent() )
end