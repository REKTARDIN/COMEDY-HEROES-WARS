gambit_kinetic_impact = class({})

LinkLuaModifier ("modifier_gambit_kinetic_impact", "abilities/gambit_kinetic_impact.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_gambit_kinetic_impact_slowing", "abilities/gambit_kinetic_impact.lua", LUA_MODIFIER_MOTION_NONE)

function gambit_kinetic_impact:Spawn()
    if IsServer() then self:SetLevel(1) end
end

function gambit_kinetic_impact:GetIntrinsicModifierName()
	return "modifier_gambit_kinetic_impact"
end
---------------------------------------------------------------------------------------------------------------------
modifier_gambit_kinetic_impact = class({})

function modifier_gambit_kinetic_impact:IsHidden() 
    return true 
end

function modifier_gambit_kinetic_impact:IsPurgable() 
    return false 
end

function modifier_gambit_kinetic_impact:RemoveOnDeath() 
    return false 
end

function modifier_gambit_kinetic_impact:OnCreated(params)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.chance = self.ability:GetSpecialValueFor("chance")
    self.slow_duration = self.ability:GetSpecialValueFor("slow_duration")
    self.radius = self.ability:GetSpecialValueFor("radius")
end


function modifier_gambit_kinetic_impact:OnRefresh(params)
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.chance = self.ability:GetSpecialValueFor("chance")
    self.slow_duration = self.ability:GetSpecialValueFor("slow_duration")
    self.radius = self.ability:GetSpecialValueFor("radius")
end

function modifier_gambit_kinetic_impact:DeclareFunctions()
    return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_gambit_kinetic_impact:OnTakeDamage(params)
    if IsServer() then 
         if params.attacker ~= self.parent 
            or (not self.parent:IsAlive())
            or self.parent:PassivesDisabled() 
            or self.parent:IsIllusion()  
            or (not self.ability:IsFullyCastable()) and (params.inflictor and params.inflictor:GetAbilityName() ~= "gambit_kinetic_earthquake")
            or params.damage_category ~= 0 
            or params.inflictor == self.ability
            or (params.inflictor and params.inflictor:IsItem()) then

            return nil
        end

        local duration = self.slow_duration
        
        if params.inflictor and params.inflictor:GetAbilityName() == "gambit_kinetic_earthquake" then    
            duration = duration + 1   
        end 
        
		if UnitFilter(  
			params.unit,
			self.ability:GetAbilityTargetTeam(),
			self.ability:GetAbilityTargetType(),
			self.ability:GetAbilityTargetFlags(),
			self.parent:GetTeamNumber()) == UF_SUCCESS then

			if RollPercentage(self.chance) then
				local enemies = FindUnitsInRadius(  
                self.parent:GetTeamNumber(),
                params.unit:GetAbsOrigin(), 
                nil, 
                self.radius, 
                self.ability:GetAbilityTargetTeam(), 
                self.ability:GetAbilityTargetType(), 
                self.ability:GetAbilityTargetFlags(), 
                FIND_ANY_ORDER, 
                false )

				for _,enemy in ipairs(enemies) do
					enemy:AddNewModifier(self.parent, self.ability, "modifier_gambit_kinetic_impact_slowing", {duration = duration})

					ApplyDamage({  
						victim = enemy,
						attacker = self.parent, 
						damage = self.damage,
						damage_type = self.ability:GetAbilityDamageType(),
						ability = self.ability
					})

                    EmitSoundOn("Gambit_Kinetic_Impact.Impact", enemy)
                    local impact_particle = ParticleManager:CreateParticle("particles/stygian/gambit_kinetic_impact.vpcf", PATTACH_WORLDORIGIN, nil)
                    ParticleManager:SetParticleControl(impact_particle, 0, params.unit:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(impact_particle)
                end

                if params.inflictor and params.inflictor:GetAbilityName() ~= "gambit_kinetic_earthquake" then
                    self.ability:UseResources(true, false, true)
                end
			end
        end
    end
end
---------------------------------------------------------------------------------------------------------------------
modifier_gambit_kinetic_impact_slowing = class({})

function modifier_gambit_kinetic_impact_slowing:IsHidden() 
    return false 
end

function modifier_gambit_kinetic_impact_slowing:IsPurgable() 
    return true 
end

function modifier_gambit_kinetic_impact_slowing:RemoveOnDeath() 
    return true 
end

function modifier_gambit_kinetic_impact_slowing:OnCreated(params)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.attack_speed_slow = self.ability:GetSpecialValueFor("attack_speed_slow")
    self.movespeed_slow = self.ability:GetSpecialValueFor("movespeed_slow")
end

function modifier_gambit_kinetic_impact_slowing:OnRefresh(params)
    self.attack_speed_slow = self.ability:GetSpecialValueFor("attack_speed_slow")
    self.movespeed_slow = self.ability:GetSpecialValueFor("movespeed_slow")
end

function modifier_gambit_kinetic_impact_slowing:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_gambit_kinetic_impact_slowing:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed_slow * -1
end

function modifier_gambit_kinetic_impact_slowing:GetModifierMoveSpeedBonus_Percentage()
    return self.movespeed_slow * -1
end

