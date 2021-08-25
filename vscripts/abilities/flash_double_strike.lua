flash_double_strike = class({})

LinkLuaModifier( "modifier_flash_double_strike_attack_speed_chance", "abilities/flash_double_strike.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_flash_double_strike_attack_speed", "abilities/flash_double_strike.lua", LUA_MODIFIER_MOTION_NONE )

function flash_double_strike:GetIntrinsicModifierName()
	return "modifier_flash_double_strike_attack_speed_chance"
end

modifier_flash_double_strike_attack_speed_chance = class({})

--------------------------------------------------------------------------------

function modifier_flash_double_strike_attack_speed_chance:IsDebuff() return false end
function modifier_flash_double_strike_attack_speed_chance:IsHidden() return false end
function modifier_flash_double_strike_attack_speed_chance:IsPurgable() return false end
function modifier_flash_double_strike_attack_speed_chance:RemoveOnDeath() return false end
function modifier_flash_double_strike_attack_speed_chance:DeclareFunctions () return { MODIFIER_EVENT_ON_ATTACK_LANDED } end

function modifier_flash_double_strike_attack_speed_chance:OnAttackLanded (params)
    if IsServer () then
        if params.attacker == self:GetParent() then
            if self:GetAbility():IsCooldownReady() and RollPercentage(self:GetAbility():GetSpecialValueFor("chance")) then

              local hTarget = params.target
              local caster = params.attacker 

              EmitSoundOn( "Hero_FacelessVoid.TimeDilation.Target", caster )

              local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash_glow.vpcf", PATTACH_CUSTOMORIGIN, nil );
              ParticleManager:SetParticleControlEnt(nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
              ParticleManager:ReleaseParticleIndex( nFXIndex );

              caster:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_flash_double_strike_attack_speed", {duration = self:GetAbility():GetSpecialValueFor("duration")})
              
              self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
            end
        end
    end
    return 0
end

modifier_flash_double_strike_attack_speed = class({})

--------------------------------------------------------------------------------

function modifier_flash_double_strike_attack_speed:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_flash_double_strike_attack_speed:OnCreated( kv )
	-- get reference
	self.bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
	self.max_attacks = self:GetAbility():GetSpecialValueFor("max_attacks")

	-- Increase stack

	if IsServer() then
		self:SetStackCount(self.max_attacks)

		self:AddEffects()
	end
end

function modifier_flash_double_strike_attack_speed:OnRefresh( kv )
	-- get reference
	self.bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
	self.max_attacks = self:GetAbility():GetSpecialValueFor("max_attacks")

	-- Increase stack
	if IsServer() then
		self:SetStackCount(self.max_attacks)
	end
end

function modifier_flash_double_strike_attack_speed:OnDestroy( kv )
    if IsServer() then
        
	end
end
--------------------------------------------------------------------------------

function modifier_flash_double_strike_attack_speed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_flash_double_strike_attack_speed:GetModifierAttackSpeedBonus_Constant()
	return self.bonus
end

function modifier_flash_double_strike_attack_speed:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		-- decrement stack
		self:DecrementStackCount()

		-- destroy if reach zero
		if self:GetStackCount() < 1 then
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_flash_double_strike_attack_speed:AddEffects()
	-- get resources
	local particle_buff = "particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf"

	-- Create particle
	self.effect_cast = ParticleManager:CreateParticle( particle_buff, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt( self.effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetOrigin(), true)
	ParticleManager:SetParticleControlEnt( self.effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
	
	-- Apply particle
	self:AddParticle(
		self.effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end

function modifier_flash_double_strike_attack_speed:RemoveEffects()
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end
