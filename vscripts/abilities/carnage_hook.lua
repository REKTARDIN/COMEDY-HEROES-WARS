carnage_hook = class({})
LinkLuaModifier( "modifier_generic_knockback_lua", "abilities/carnage_hook.lua", LUA_MODIFIER_MOTION_BOTH )

function carnage_hook:OnAbilityPhaseStart()
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2 )
    return true
end

function carnage_hook:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2 )
    return true
end

function carnage_hook:GetCastRange(location, target)
    -- Get caster's cast range
    local caster = self:GetCaster()
    local cast_range = self.BaseClass.GetCastRange(self, location, target)
    return castrange
end

function carnage_hook:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    caster:EmitSound("Hero_Rattletrap.Hookshot.Fire")

    local duration = self:GetSpecialValueFor("stun_duration")
    local range = self:GetSpecialValueFor("range")

    -- Direction the hook is facing
    self.direction = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized()
    -- In case the z-axis shoots off to some weird alternate dimension
    self.direction.z = 0

    -- Accounts for total of travel time to and from the full distance
    local hookshot_duration	= (range + self:GetCaster():GetCastRangeBonus()) / self:GetSpecialValueFor("speed") * 2

    local hookshot_particle = ParticleManager:CreateParticle("particles/heroes/hero_venom/venom_hook.vpcf", PATTACH_CUSTOMORIGIN, nil)
    -- CP0 is the hook's starting point
    ParticleManager:SetParticleControlEnt(hookshot_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon", self:GetCaster():GetAbsOrigin(), true)
    -- CP1 is the farthest point the hook will travel
    ParticleManager:SetParticleControl(hookshot_particle, 1, self:GetCaster():GetAbsOrigin() + self.direction * (range + self:GetCaster():GetCastRangeBonus()))
    -- CP2 is the speed at which the hook travels
    ParticleManager:SetParticleControl(hookshot_particle, 2, Vector(self:GetSpecialValueFor("speed"), 0, 0))
    -- CP3 is the duration at which the hook will last for
    ParticleManager:SetParticleControl(hookshot_particle, 3, Vector(hookshot_duration, 0, 0))

    local linear_projectile = {
        Ability	= self,
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        fDistance = range + self:GetCaster():GetCastRangeBonus(),
        fStartRadius = self:GetSpecialValueFor("width"),
        fEndRadius = self:GetSpecialValueFor("width"),
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam	= DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("speed"),
        bProvidesVision	= false,

        ExtraData = {hookshot_particle = hookshot_particle}
    }
    self.projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)
end

function carnage_hook:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not IsServer() then return end

    if hTarget then
        local range = self:GetSpecialValueFor("range")

        if hTarget ~= self:GetCaster() and not hTarget:IsCourier() then
            self:GetCaster():StopSound("Hero_Rattletrap.Hookshot.Fire")
            hTarget:EmitSound("Hero_Rattletrap.Hookshot.Impact")

            -- Retract sound lingers if target is too close to caster at start so only make it play if they were farther to begin with
            if (self:GetCaster():GetAbsOrigin() - hTarget:GetAbsOrigin()):Length2D() > self:GetSpecialValueFor("width") then
                self:GetCaster():EmitSound("Hero_Rattletrap.Hookshot.Retract")
            end

            ParticleManager:SetParticleControlEnt(ExtraData.hookshot_particle, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
            -- "The pulling lasts a maximum of 0.5 seconds, so if the target moves away, Clockwerk may not fully reach it."
            hTarget:AddNewModifier(self:GetCaster(), self, "modifier_generic_knockback_lua",
                {
                    distance = (hTarget:GetOrigin() - self:GetCaster():GetOrigin()):Length2D() - 150,
                    height = 0,
                    duration = ((hTarget:GetOrigin() - self:GetCaster():GetOrigin()):Length2D() - 150) / self:GetSpecialValueFor("speed"),
                    direction_x = (self:GetCaster():GetOrigin() - hTarget:GetOrigin()):Normalized().x,
                    direction_y = (self:GetCaster():GetOrigin() - hTarget:GetOrigin()):Normalized().y,
                    IsStun = true,
                    IsFlail = true,
                })

            hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = (self:GetSpecialValueFor("duration") * (1-hTarget:GetStatusResistance())) + (range + self:GetCaster():GetCastRangeBonus()) / self:GetSpecialValueFor("speed")})
            damageTable = {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = self:GetSpecialValueFor("damage"),
                damage_type = self:GetAbilityDamageType(),
                ability = self, --Optional.
            }
            ApplyDamage( damageTable )

            -- This line is so Clockwerk doesn't pierce through everyone if there are multiple targets (although that would be pretty cool)
            -- It may interfere with previous projectiles if you're shooting multiple at once (aka WTF mode) but come on now, vanilla arguably handles this even worse with lingering particles so no bulli
            ProjectileManager:DestroyLinearProjectile(self.projectile)
        else
            hTarget:EmitSound("Hero_Rattletrap.Hookshot.Impact")

            if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
                hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("duration")}):SetDuration(self:GetSpecialValueFor("duration") * (1 - hTarget:GetStatusResistance()), true)
            end
        end

        return true
    end
end

modifier_generic_knockback_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_knockback_lua:IsDebuff()
	return true
end
function modifier_generic_knockback_lua:IsHidden()
	return true
end
function modifier_generic_knockback_lua:IsPurgable()
	return false
end

function modifier_generic_knockback_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_knockback_lua:OnCreated( kv )
	if IsServer() then
		self.distance = kv.distance or 0
		self.height = kv.height or -1
		self.duration = kv.duration or 0
		if kv.direction_x and kv.direction_y then
			self.direction = Vector(kv.direction_x,kv.direction_y,0):Normalized()
		else
			self.direction = -(self:GetParent():GetForwardVector())
		end
		self.tree = kv.tree_destroy_radius or self:GetParent():GetHullRadius()

		if kv.IsStun then self.stun = kv.IsStun==1 else self.stun = true end
		if kv.IsFlail then self.flail = kv.IsFlail==1 else self.flail = true end

		-- check duration
		if self.duration == 0 then
			self:Destroy()
			return
		end

		-- load data
		self.parent = self:GetParent()
		self.origin = self.parent:GetOrigin()

		-- horizontal init
		self.hVelocity = self.distance/self.duration

		-- vertical init
		local half_duration = self.duration/2
		self.gravity = 2*self.height/(half_duration*half_duration)
		self.vVelocity = self.gravity*half_duration

		-- apply motion controllers
		if self.distance>0 then
			if self:ApplyHorizontalMotionController() == false then 
				self:Destroy()
				return
			end
		end
		if self.height>=0 then
			if self:ApplyVerticalMotionController() == false then 
				self:Destroy()
				return
			end
		end

		-- tell client of activity
		if self.flail then
			self:SetStackCount( 1 )
		elseif self.stun then
			self:SetStackCount( 2 )
		end
	else
		self.anim = self:GetStackCount()
		self:SetStackCount( 0 )
	end
end

function modifier_generic_knockback_lua:OnRefresh( kv )
	if not IsServer() then return end
end

function modifier_generic_knockback_lua:OnDestroy( kv )
	if not IsServer() then return end

	if not self.interrupted then
		-- destroy trees
		if self.tree>0 then
			GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.tree, true )
		end
	end

	if self.EndCallback then
		self.EndCallback()
	end

	self:GetParent():InterruptMotionControllers( true )
end

--------------------------------------------------------------------------------
-- Setter
function modifier_generic_knockback_lua:SetEndCallback( func ) 
	self.EndCallback = func
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_generic_knockback_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_generic_knockback_lua:GetOverrideAnimation( params )
	if self.anim==1 then
		return ACT_DOTA_FLAIL
	elseif self.anim==2 then
		return ACT_DOTA_DISABLED
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_generic_knockback_lua:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.stun,
	}

	return state
end

--------------------------------------------------------------------------------
-- Motion effects
function modifier_generic_knockback_lua:UpdateHorizontalMotion( me, dt )
	local parent = self:GetParent()
	
	-- set position
	local target = self.direction*self.distance*(dt/self.duration)

	-- change position
	parent:SetOrigin( parent:GetOrigin() + target )
end

function modifier_generic_knockback_lua:OnHorizontalMotionInterrupted()
	if IsServer() then
		self.interrupted = true
		self:Destroy()
	end
end

function modifier_generic_knockback_lua:UpdateVerticalMotion( me, dt )
	-- set time
	local time = dt/self.duration

	-- change height
	self.parent:SetOrigin( self.parent:GetOrigin() + Vector( 0, 0, self.vVelocity*dt ) )

	-- calculate vertical velocity
	self.vVelocity = self.vVelocity - self.gravity*dt
end

function modifier_generic_knockback_lua:OnVerticalMotionInterrupted()
	if IsServer() then
		self.interrupted = true
		self:Destroy()
	end
end