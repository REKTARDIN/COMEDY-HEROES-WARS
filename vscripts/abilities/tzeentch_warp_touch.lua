--------------------------------------------------------------------------------
tzeentch_warp_touch = class({})

--------------------------------------------------------------------------------
-- Init Abilities
function tzeentch_warp_touch:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context )
	PrecacheResource( "particle", "particles/econ/items/phoenix/phoenix_ti10_immortal/phoenix_ti10_fire_spirit_ground.vpcf", context )
end

LinkLuaModifier( "modifier_tzeentch_warp_touch_vacuum", "abilities/tzeentch_warp_touch", LUA_MODIFIER_MOTION_HORIZONTAL )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function tzeentch_warp_touch:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function tzeentch_warp_touch:GetCooldown( level )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "scepter_cooldown" )
	end

	return self.BaseClass.GetCooldown( self, level )
end

--------------------------------------------------------------------------------
-- Ability Start
function tzeentch_warp_touch:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local radius = self:GetSpecialValueFor( "radius" )
	local targets = self:GetSpecialValueFor( "targets" )
	local damage = self:GetSpecialValueFor( "damage" ) + (IsHasTalent(caster:GetPlayerOwnerID(), "special_bonus_unique_tzeentch_3") or 0)
    local root_duration = self:GetSpecialValueFor( "root_duration" ) + (IsHasTalent(caster:GetPlayerOwnerID(), "special_bonus_unique_tzeentch_2") or 0)

	-- find units
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
        -- add modifier
        if not enemy:IsMagicImmune() then     
            enemy:AddNewModifier(
                caster, -- player source
                self, -- ability source
                "modifier_rooted", -- modifier name
                {
                    duration = root_duration
                } -- kv
			)
			
			print(root_duration)

            if caster:HasScepter() then
                enemy:AddNewModifier(
                    caster, -- player source
                    self, -- ability source
                    "modifier_tzeentch_warp_touch_vacuum", -- modifier name
                    {
                        duration = 1,
                        x = point.x,
                        y = point.y,
                    } -- kv
                )
            end
            
            ApplyDamage({attacker = caster, victim = enemy, damage = damage, ability = self, damage_type = self:GetAbilityDamageType()})	
        end
	end

	-- destroy trees
	GridNav:DestroyTreesAroundPoint( point, 400, false )

	local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/silencer/silencer_ti10_immortal_shield/silencer_ti10_immortal_curse_aoe.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( point, "Hero_Dark_Seer.Ion_Shield_Start.TI8", self:GetCaster() )
end

--------------------------------------------------------------------------------

modifier_tzeentch_warp_touch_vacuum = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_tzeentch_warp_touch_vacuum:IsHidden()
	return false
end

function modifier_tzeentch_warp_touch_vacuum:IsDebuff()
	return true
end

function modifier_tzeentch_warp_touch_vacuum:IsStunDebuff()
	return true
end

function modifier_tzeentch_warp_touch_vacuum:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_tzeentch_warp_touch_vacuum:OnCreated( kv )
	-- references
	if not IsServer() then return end

	-- set direction and speed
	local center = Vector( kv.x, kv.y, 0 )
	self.direction = center - self:GetParent():GetOrigin()
	self.speed = self.direction:Length2D() / self:GetDuration()

	self.direction.z = 0
	self.direction = self.direction:Normalized()

	-- apply motion
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
end

function modifier_tzeentch_warp_touch_vacuum:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_tzeentch_warp_touch_vacuum:OnRemoved()
end

function modifier_tzeentch_warp_touch_vacuum:OnDestroy()
	if not IsServer() then return end
    
    self:GetParent():RemoveHorizontalMotionController( self )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_tzeentch_warp_touch_vacuum:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_tzeentch_warp_touch_vacuum:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_tzeentch_warp_touch_vacuum:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_tzeentch_warp_touch_vacuum:UpdateHorizontalMotion( me, dt )
	local target = me:GetOrigin() + self.direction * self.speed * dt
	me:SetOrigin( target )
end

function modifier_tzeentch_warp_touch_vacuum:OnHorizontalMotionInterrupted()
	self:Destroy()
end