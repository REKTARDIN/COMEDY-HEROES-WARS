dark_rider_death_rush = class({})
LinkLuaModifier( "modifier_dark_rider_death_rush", "abilities/dark_rider_death_rush.lua", LUA_MODIFIER_MOTION_NONE )

function dark_rider_death_rush:GetAOERadius()
	return 256
end

function dark_rider_death_rush:OnSpellStart()
	local caster = self:GetCaster()
	local target_point = self:GetCursorPosition()
    
    ProjectileManager:ProjectileDodge(caster)

	caster:FaceTowards(target_point)
	
	EmitSoundOn("", caster)

	caster:AddNewModifier(caster, self, "modifier_dark_rider_death_rush", {})
end
----------------------------------------------------------------------------------------------------------------------
modifier_dark_rider_death_rush = class({})

function modifier_dark_rider_death_rush:IsHidden() 
    return true 
end
function modifier_dark_rider_death_rush:IsPurgable() 
    return false 
end

function modifier_dark_rider_death_rush:DeclareFunctions ()
    local funcs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
    return funcs
end

function modifier_dark_rider_death_rush:CheckState()
	local state = {[MODIFIER_STATE_STUNNED] = true}
	return state
end

function modifier_dark_rider_death_rush:GetOverrideAnimation()
    return ACT_DOTA_RUN
end

function modifier_dark_rider_death_rush:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	local ms_damage = self.caster:GetIdealSpeed() * self.ability:GetSpecialValueFor("ms_damage") / 100
	self.damage = self.ability:GetSpecialValueFor("damage") + ms_damage
	self.rush_speed = self.ability:GetSpecialValueFor("speed") + self.caster:GetIdealSpeedNoSlows()
	self.duration = self.ability:GetSpecialValueFor("duration")

	if IsServer() then
		self.target_point = self.ability:GetCursorPosition()

		self.time_elapsed = 0
		self.rush_z = 0

			self.distance = (self.caster:GetAbsOrigin() - self.target_point):Length2D()
			self.rush_time = self.distance / self.rush_speed

			self.direction = (self.target_point - self.caster:GetAbsOrigin()):Normalized()

			self.frametime = FrameTime()

		self:StartIntervalThink(self.frametime)
	end
end

function modifier_dark_rider_death_rush:OnIntervalThink()

	self:HorizontalMotion(self.caster, self.frametime)
end

function modifier_dark_rider_death_rush:GetMotionControllerPriority() 
    return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM 
end

function modifier_dark_rider_death_rush:VerticalMotion(me, dt)
	if IsServer() then	
		if self.time_elapsed < self.rush_time then
			if self.time_elapsed <= self.rush_time / 2 then			
				self.rush_z = self.rush_z - 20
				self.caster:SetAbsOrigin(GetGroundPosition(self.caster:GetAbsOrigin(), self.caster) + Vector(0,0,self.rush_z))
			else
				self.rush_z = self.rush_z - 20
				if self.rush_z > 0 then
					self.caster:SetAbsOrigin(GetGroundPosition(self.caster:GetAbsOrigin(), self.caster) + Vector(0,0,self.rush_z))
				end
			end
		end
	end
end

function modifier_dark_rider_death_rush:HorizontalMotion(me, dt)
	if IsServer() then
		self.time_elapsed = self.time_elapsed + dt
		if self.time_elapsed < self.rush_time then
			local rush_end_location = self.caster:GetAbsOrigin() + self.direction * self.rush_speed * dt
			self.caster:SetAbsOrigin(rush_end_location)
		else
			self:Destroy()
		end
	end
end

function modifier_dark_rider_death_rush:OnDestroy()
	if IsServer() then
		local enemies = FindUnitsInRadius(	
			self.caster:GetTeam(), 
			self.target_point, 
			nil, 
			256, 
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, 
			FIND_ANY_ORDER, 
			false
		)
		for _,enemy in pairs(enemies) do
				if enemy and not enemy:IsNull() and enemy:IsAlive() then
					local damage_table = {	
					victim = enemy,
					damage = self.damage,
					damage_type = self.ability:GetAbilityDamageType(),
					attacker = self.caster,
					ability = self.ability 
				}
				local knockback = {
                    should_stun = 1,
					knockback_duration = self.duration,
					duration = self.duration,
					knockback_distance = 0,
					knockback_height = 200,
					center_x = self:GetCaster():GetAbsOrigin().x,
					center_y = self:GetCaster():GetAbsOrigin().y,
                    center_z = self:GetCaster():GetAbsOrigin().z 
                }

				ApplyDamage(damage_table)
				
				enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_knockback", knockback )
			end
		end
		
		FindClearSpaceForUnit(self:GetCaster(), self:GetCaster():GetOrigin(), false)
		
		local nFXIndex = ParticleManager:CreateParticle( "particles/stygian/fluster_blast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 2, Vector(256, 256, 0) )
		ParticleManager:SetParticleControl( nFXIndex, 4, self:GetCaster():GetAbsOrigin() )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
				
		EmitSoundOn("Dark_Rider_Death_Rush.Impact", self:GetCaster())
	end
end

