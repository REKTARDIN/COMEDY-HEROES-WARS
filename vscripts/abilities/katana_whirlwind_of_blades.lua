katana_whirlwind_of_blades = class({})
LinkLuaModifier( "modifier_katana_whirlwind_of_blades", "abilities/katana_whirlwind_of_blades.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function katana_whirlwind_of_blades:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local bDuration = self:GetSpecialValueFor("duration")

	-- Add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_katana_whirlwind_of_blades", -- modifier name
		{ duration = bDuration } -- kv
	)
end

modifier_katana_whirlwind_of_blades = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_katana_whirlwind_of_blades:IsHidden()
	return false
end

function modifier_katana_whirlwind_of_blades:IsDebuff()
	return false
end

function modifier_katana_whirlwind_of_blades:IsPurgable()
	return false
end

function modifier_katana_whirlwind_of_blades:DestroyOnExpire()
	return false
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_katana_whirlwind_of_blades:OnCreated( kv )
	-- references
	self.tick = self:GetAbility():GetSpecialValueFor( "blade_fury_damage_tick" ) -- special value
	self.radius = self:GetAbility():GetSpecialValueFor( "blade_fury_radius" ) -- special value
	self.dps = self:GetAbility():GetSpecialValueFor( "blade_fury_damage" ) -- special value
	
	self.max_count = kv.duration/self.tick
	self.count = 0

	-- Start interval
	if IsServer() then
		-- precache damagetable
		self.damageTable = {
			-- victim = target,
			attacker = self:GetParent(),
			damage = self.dps * self.tick,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
		}

		self:StartIntervalThink( self.tick )
	end

	-- PlayEffects
	self:PlayEffects()
end

function modifier_katana_whirlwind_of_blades:OnRefresh( kv )
	-- references
	self.tick = self:GetAbility():GetSpecialValueFor( "blade_fury_damage_tick" ) -- special value
	self.radius = self:GetAbility():GetSpecialValueFor( "blade_fury_radius" ) -- special value
	self.dps = self:GetAbility():GetSpecialValueFor( "blade_fury_damage" ) -- special value 
	self.count = 0

	if IsServer() then
		self.damageTable.damage = self.dps * self.tick
	end
end

function modifier_katana_whirlwind_of_blades:OnDestroy( kv )
	-- Stop effects
	local sound_cast = "Hero_Juggernaut.BladeFuryStart"
	StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_katana_whirlwind_of_blades:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_katana_whirlwind_of_blades:OnIntervalThink()
    
    if IsServer() then

    local speed = self:GetAbility():GetSpecialValueFor( "speed" )
	local width = self:GetAbility():GetSpecialValueFor( "width" )
	local direction = RandomVector(1) * RandomFloat(900, 2250)

    local info = {
        EffectName = "particles/stygian/katana_whirlwind_soul_of_terror.vpcf",
        Ability = self,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
     	fStartRadius = width,
        fEndRadius = width,
   		vVelocity = direction + self:GetCaster():GetForwardVector(),
        fDistance = self:GetAbility():GetSpecialValueFor( "distance" ),
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        bProvidesVision = false
    }

	ProjectileManager:CreateLinearProjectile( info ) 
	EmitSoundOn( "n_creep_fellbeast.Death" , self:GetCaster() )
	
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- damage enemies
	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )

		-- Play effects
		self:PlayEffects2( enemy )
	end

	-- counter
	self.count = self.count+1
	if self.count>= self.max_count then
		self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_katana_whirlwind_of_blades:PlayEffects()
		-- Get Resources
	local particle_cast = "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal.vpcf"
	local sound_cast = "Hero_Juggernaut.BladeFuryStart"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 5, Vector( self.radius, 0, 0 ) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)

	-- Emit sound
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_katana_whirlwind_of_blades:PlayEffects2( target )
	local particle_cast = "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_crimson_blade_fury_abyssal_tgt.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end