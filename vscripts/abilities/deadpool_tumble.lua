deadpool_tumble = class({})

LinkLuaModifier( "modifier_deadpool_tumble", "abilities/deadpool_tumble.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

function deadpool_tumble:OnSpellStart()
	if IsServer() then
		
		local caster = self:GetCaster()
		local origin = caster:GetOrigin()
		local target = caster:GetCursorPosition()
		local point = target		
		local speed = self:GetSpecialValueFor("dash_speed") 
		
		self.endpoint = caster:GetCursorPosition()
		
		local direction = (point - caster:GetAbsOrigin()):Normalized()
		caster:SetForwardVector(direction)
		
		local maxrange = self:GetSpecialValueFor("dash_range") + caster:GetCastRangeBonus() 

		local distance = (target-origin):Length2D()

		if distance > maxrange then
			distance = maxrange
		end
	
		caster:AddNewModifier(caster, self, "modifier_deadpool_tumble", {})
    end
end

modifier_deadpool_tumble = class({})

function modifier_deadpool_tumble:IsHidden() 
	return true 
end

function modifier_deadpool_tumble:IsPurgable() 
	return false 
end

function modifier_deadpool_tumble:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_willow_shadow_realm.vpcf"
end

function modifier_deadpool_tumble:OnCreated()
	--Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	
	local target = self.caster:GetCursorPosition()
	local point = target
	local startpoint = self.caster:GetOrigin()

	local max_range = self.ability:GetSpecialValueFor("dash_range") + self.caster:GetCastRangeBonus()
	
	self.target = target 
	self.startpoint = startpoint 

	self.dash_speed = self.ability:GetSpecialValueFor("dash_speed") 

	if IsServer() then

		self.time_elapsed = 0

		self.distance = (self.caster:GetAbsOrigin() - point):Length2D()
		if self.distance > max_range then
			self.distance = max_range
		end
		self.dash_time = self.distance / self.dash_speed
		self.direction = (point - self.caster:GetAbsOrigin()):Normalized()
		
		self:ApplyHorizontalMotionController()
	end
end

function modifier_deadpool_tumble:UpdateHorizontalMotion( me, dt)
	if IsServer() then
		self.dash_time = self.distance / self.dash_speed
		
		self.time_elapsed = self.time_elapsed + dt
		if self.time_elapsed < self.dash_time then	
		local new_location = self.caster:GetAbsOrigin() + self.direction * self.dash_speed * dt
			self.caster:SetAbsOrigin(new_location)
		else
			self:Destroy()
		end
	end
end

function modifier_deadpool_tumble:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_deadpool_tumble:OnRemoved()
	if IsServer() then
		local caster = self:GetParent()
	
		caster:InterruptMotionControllers( true )
	end
end

