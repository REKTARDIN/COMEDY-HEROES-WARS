murlock_agility_steal = class({})
LinkLuaModifier( "modifier_murlock_agility_steal", "abilities/murlock_agility_steal.lua" ,LUA_MODIFIER_MOTION_NONE )

function murlock_agility_steal:GetIntrinsicModifierName()
	return "modifier_murlock_agility_steal"
end

function murlock_agility_steal:Spawn()
	if IsServer() then
		self:SetLevel(1)
	end
end
--------------------------------------------------------------------------------

function murlock_agility_steal:OnHeroDiedNearby( hVictim, hKiller, kv )
	if hVictim == nil or hKiller == nil then
		return
	end

	if hVictim:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and self:GetCaster():IsAlive() then
		self.flesh_heap_range = self:GetSpecialValueFor( "agility_steal_range" )
		local vToCaster = self:GetCaster():GetOrigin() - hVictim:GetOrigin()
		local flDistance = vToCaster:Length2D()
		if hKiller == self:GetCaster() or self.flesh_heap_range >= flDistance then
			if self.nKills == nil then
				self.nKills = 0
			end

			self.nKills = self.nKills + 1

			local hBuff = self:GetCaster():FindModifierByName( "modifier_murlock_agility_steal" )
			if hBuff ~= nil then
				hBuff:SetStackCount( self.nKills )
				self:GetCaster():CalculateStatBonus(true)
			end

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
end

--------------------------------------------------------------------------------

function murlock_agility_steal:GetFleshHeapKills()
	if self.nKills == nil then
		self.nKills = 0
	end
	return self.nKills
end

--------------------------------------------------------------------------------

modifier_murlock_agility_steal = class({})

--------------------------------------------------------------------------------

function modifier_murlock_agility_steal:OnCreated( kv )
	self.agility_steal_buff_amount = self:GetAbility():GetSpecialValueFor( "agility_steal_buff_amount" )
	self.hp_regen = self:GetAbility():GetSpecialValueFor( "health_regen" )

	if IsServer() then
		if self:GetParent():HasTalent("special_bonus_unique_murloc") then self.hp_regen = self.hp_regen * 2 end

		self:SetStackCount( self:GetAbility():GetFleshHeapKills() )
		self:GetParent():CalculateStatBonus(true)
	end
end

--------------------------------------------------------------------------------

function modifier_murlock_agility_steal:OnRefresh( kv )
	self.agility_steal_buff_amount = self:GetAbility():GetSpecialValueFor( "agility_steal_buff_amount" )
	self.hp_regen = self:GetAbility():GetSpecialValueFor( "health_regen" )

	if IsServer() then
		if self:GetParent():HasTalent("special_bonus_unique_murloc") then self.hp_regen = self.hp_regen * 2 end

		self:GetParent():CalculateStatBonus(true)
	end
end

--------------------------------------------------------------------------------

function modifier_murlock_agility_steal:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function modifier_murlock_agility_steal:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" )
end

function modifier_murlock_agility_steal:GetModifierHealthRegenPercentage( params )
	return self.hp_regen
end

--------------------------------------------------------------------------------

function modifier_murlock_agility_steal:GetModifierBonusStats_Agility( params )
	return self:GetStackCount() * self.agility_steal_buff_amount
end

--------------------------------------------------------------------------------

function murlock_agility_steal:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

