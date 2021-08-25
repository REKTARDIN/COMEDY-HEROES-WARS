gambit_kinetic_earthquake = class({}) 

LinkLuaModifier ("modifier_gambit_earthquake_shield", "abilities/gambit_kinetic_earthquake.lua", LUA_MODIFIER_MOTION_NONE)


function gambit_kinetic_earthquake:RegisterParams()
    --- Load default effect
    self:SetEffect(1, "particles/stygian/gambit_kinetic_impact_gold_call.vpcf")
end


function gambit_kinetic_earthquake:OnSpellStart()
    if not IsServer() then return end

    local radius = self:GetSpecialValueFor("radius")
    local base_damage = self:GetSpecialValueFor("damage")

    local particle = ParticleManager:CreateParticle(self:GetEffect(1, "particles/stygian/gambit_kinetic_impact_gold_call.vpcf"), PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 2, Vector(radius, radius, 0))
    ParticleManager:SetParticleControl(particle, 5, self:GetCaster():GetAbsOrigin())

    ScreenShake( self:GetCaster():GetOrigin(), 100, 100, 1, 9999, 0, true)
    GridNav:DestroyTreesAroundPoint(self:GetCaster():GetAbsOrigin(), radius, false)

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, 0, false)

    for _, target in pairs(targets) do
        local center = self:GetCaster():GetAbsOrigin()
        local knockback_distance = self:GetSpecialValueFor("knockback_distance")
        local shield_duration = self:GetSpecialValueFor("shield_duration")
		local knockback_height = self:GetSpecialValueFor("knockback_height")
		local knockback_duration = 1

		local knockback = {
			should_stun = true,                                
			knockback_duration = knockback_duration,
			duration = knockback_duration,
			knockback_distance = knockback_distance,
			knockback_height = knockback_height,
			center_x = 0,
			center_y = 0,
            center_z = center.z + 200
        }

        target:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback)

        ApplyDamage({
            victim = target,
            attacker = self:GetCaster(),
            ability = self,
            damage = base_damage + (self:GetCaster():GetAgility()*2),
            damage_type = self:GetAbilityDamageType()
        })
    end

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gambit_earthquake_shield", {duration = shield_duration})

    EmitSoundOn("Gambit_Ulti.Cast", self:GetCaster())
end

modifier_gambit_earthquake_shield = class({})

function modifier_gambit_earthquake_shield:IsHidden() 
    return false
end

function modifier_gambit_earthquake_shield:RemoveOnDeath() 
    return true
end

function modifier_gambit_earthquake_shield:IsPurgable() 
    return false
end

function modifier_gambit_earthquake_shield:DeclareFunctions()
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_gambit_earthquake_shield:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("shield_block_damage") * (-1)
end

function gambit_kinetic_earthquake:GetAbilityTextureName() return GetAbilityIcon(self)  end 

