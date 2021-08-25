
--------------------------------------------------------------------------------
cap_rebuke = class({})

LinkLuaModifier ("modifier_cap_rebuke", "abilities/cap_rebuke.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_cap_rebuke_aura", "abilities/cap_rebuke.lua", LUA_MODIFIER_MOTION_NONE)

function cap_rebuke:GetIntrinsicModifierName()
    return "modifier_cap_rebuke_aura"
end

function cap_rebuke:GetSpeed()
    local result = 0

	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, self:GetSpecialValueFor( "aura_radius" ) , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	if #units > 0 then
		for _,unit in pairs(units) do
            if unit:IsHero() then
                result = result + self:GetSpecialValueFor("bonus_speed_per_hero")
            else 
                result = result + self:GetSpecialValueFor("bonus_speed_per_unit")
            end
		end
    end
    
    self:UpdateOwner(result)

    return result
end

function cap_rebuke:UpdateOwner(result)
    if self:GetCaster():FindModifierByName("modifier_cap_rebuke") then
        self:GetCaster():FindModifierByName("modifier_cap_rebuke"):SetStackCount(result)
    end
end

--------------------------------------------------------------------------------
-- Ability Start
function cap_rebuke:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local radius = self:GetSpecialValueFor("radius")
	local angle = self:GetSpecialValueFor("angle")/2
	local duration = self:GetSpecialValueFor("knockback_duration")
	local distance = self:GetSpecialValueFor("knockback_distance")

    local crit = self:GetSpecialValueFor("crit_mult") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_cap_2") or 0)

	-- find units
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- precache
	local origin = caster:GetOrigin()
	local cast_direction = (point-origin):Normalized()
	local cast_angle = VectorToAngles( cast_direction ).y

	-- for each units
	local caught = false
	for _,enemy in pairs(enemies) do
		-- check within cast angle
		local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
		local enemy_angle = VectorToAngles( enemy_direction ).y
		local angle_diff = math.abs( AngleDiff( cast_angle, enemy_angle ) )
		if angle_diff<=angle then
			-- attack
			self:GetCaster():DoCrit(enemy, crit)

            if IsValidEntity(enemy) then
                local knockback = {
                    should_stun = 1,                                
                    knockback_duration = 0.75,
                    duration = duration,
                    knockback_distance = distance,
                    knockback_height = 125,
                    center_x = self:GetCaster():GetAbsOrigin().x,
                    center_y = self:GetCaster():GetAbsOrigin().y,
                    center_z = self:GetCaster():GetAbsOrigin().z,
                }

                enemy:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback)     

                local effect_cast = ParticleManager:CreateParticle( "particles/stygian/captain_america_rebuke.vpcf", PATTACH_WORLDORIGIN, enemy )
                ParticleManager:SetParticleControl( effect_cast, 0, enemy:GetOrigin() )
                ParticleManager:SetParticleControl( effect_cast, 1, enemy:GetOrigin() )
                ParticleManager:SetParticleControlForward( effect_cast, 1, enemy_direction )
                ParticleManager:ReleaseParticleIndex( effect_cast )

                -- Create Sound
                EmitSoundOn(  "Cap_Shield_Strike.Impact", enemy )
            end
		end
	end

    local direction = (point-origin):Normalized()
	
	if self:GetCaster():HasModifier("modifier_cap_shield_clash") then self:GetCaster():RemoveModifierByName("modifier_cap_shield_clash") end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( "particles/stygian/captain_america_rebuke_bash.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Cap_Shield_Strike.Cast", self:GetCaster() )
end

modifier_cap_rebuke_aura = class({})

function modifier_cap_rebuke_aura:IsAura() return true end
function modifier_cap_rebuke_aura:IsHidden() return true end
function modifier_cap_rebuke_aura:IsPurgable()	return false end
function modifier_cap_rebuke_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_cap_rebuke_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_cap_rebuke_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_cap_rebuke_aura:GetAuraSearchFlags()	return 0 end
function modifier_cap_rebuke_aura:GetModifierAura() return "modifier_cap_rebuke" end

modifier_cap_rebuke = class({})

function modifier_cap_rebuke:IsPurgable() return false end
function modifier_cap_rebuke:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end

function modifier_cap_rebuke:OnCreated(params)
    if IsServer() then
        self:SetStackCount(self:GetAbility():GetSpeed())
    end
end

function modifier_cap_rebuke:OnDestroy()
    if IsServer() then
        --- Update speed
        self:GetAbility():GetSpeed()
    end
end

function modifier_cap_rebuke:GetModifierMoveSpeedBonus_Percentage(params)
	return self:GetStackCount()
end
