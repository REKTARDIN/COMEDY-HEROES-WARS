if not cap_fury_rush then cap_fury_rush = class({}) end 

LinkLuaModifier( "modifier_cap_fury_rush_caster", "abilities/cap_fury_rush.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cap_fury_rush_target", "abilities/cap_fury_rush.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

local CONST_RADIUS = 250

function cap_fury_rush:GetAOERadius()
	return CONST_RADIUS
end

--------------------------------------------------------------------------------

function cap_fury_rush:GetCooldown( nLevel )
    if self:GetCaster():HasScepter() then return self:GetSpecialValueFor("cooldown_scepter") end  
    return self.BaseClass.GetCooldown( self, nLevel )
end

--------------------------------------------------------------------------------

function cap_fury_rush:OnSpellStart()
    EmitSoundOn("Cap_Running.Cast", self:GetCaster())
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_cap_fury_rush_caster", nil)

    if self:GetCaster():HasScepter() then
        local shield = self:GetCaster():FindAbilityByName("cap_rebuke")

        if shield then
            shield:OnSpellStart()
        end
    end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if modifier_cap_fury_rush_caster == nil then modifier_cap_fury_rush_caster = class({}) end

function modifier_cap_fury_rush_caster:IsDebuff () return false end
function modifier_cap_fury_rush_caster:IsHidden() return true end
function modifier_cap_fury_rush_caster:IsPurgable() return false end
function modifier_cap_fury_rush_caster:RemoveOnDeath () return true end


function modifier_cap_fury_rush_caster:OnCreated ()
    if IsServer() then
        self.target = self:GetAbility():GetCursorPosition()

        -- Ability variables
        self.direction = (self.target - self:GetParent():GetAbsOrigin()):Normalized()
        self.distance = self:GetAbility():GetSpecialValueFor("range") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_cap_3") or 0)
        self.elapsed = 0
        self.speed = self:GetAbility():GetSpecialValueFor("speed")

        self.caster = self:GetParent()
        self.ability = self:GetAbility()

        self:StartIntervalThink(0.03)
    end
end

function modifier_cap_fury_rush_caster:OnIntervalThink()
    if self.elapsed < self.distance then
        local pos = self.caster:GetAbsOrigin() + self.direction * self.speed * 0.03

        pos.z = GetGroundHeight(pos, self.caster)

        self.caster:SetAbsOrigin(pos)
        self.elapsed = self.elapsed + self.speed * 0.03
    else
        self:OnMotionInterrupted()
    end

    GridNav:DestroyTreesAroundPoint(self.caster:GetAbsOrigin(), 175, true)

	-- Units to be caught 
	local units = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), nil, CONST_RADIUS, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

	-- Loops through target
	for _, unit in pairs(units) do
		-- Checks if the target is already affected 
        -- If not, move it offset in front of the caster
        if IsValidEntity(unit) and (not unit:HasModifier("modifier_cap_fury_rush_target")) then
            unit:AddNewModifier(self.caster, self.ability, "modifier_cap_fury_rush_target", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})

            local damage = {
                victim = unit,
                attacker = self:GetCaster(),
                damage = self:GetAbility():GetAbilityDamage(),
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self:GetAbility()
            }
    
            ApplyDamage (damage)
        end
	end
end

function modifier_cap_fury_rush_caster:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_cap_fury_rush_caster:GetActivityTranslationModifiers( params )
	return "rush"
end


function modifier_cap_fury_rush_caster:GetOverrideAnimation(params)
    return ACT_DOTA_RUN
end


function modifier_cap_fury_rush_caster:CheckState ()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end


function modifier_cap_fury_rush_caster:OnMotionInterrupted()
    if IsServer () then
        EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_EarthShaker.Totem", self:GetCaster() )

        FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)

        self:Destroy ()
    end
end


if modifier_cap_fury_rush_target == nil then modifier_cap_fury_rush_target = class({}) end

--------------------------------------------------------------------------------

function modifier_cap_fury_rush_target:IsDebuff()
	return true
end

function modifier_cap_fury_rush_target:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_cap_fury_rush_target:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_cap_fury_rush_target:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

--------------------------------------------------------------------------------

function modifier_cap_fury_rush_target:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------

function modifier_cap_fury_rush_target:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_cap_fury_rush_target:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

function modifier_cap_fury_rush_target:CheckState()
	local state = {
	    [MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_cap_fury_rush_target:OnCreated(params)
    if IsServer() then
        local knockback = {
            should_stun = 1,                                
            knockback_duration = 0.75,
            duration = 0.75,
            knockback_distance = 350,
            knockback_height = 160,
            center_x = self:GetAbility():GetCaster():GetAbsOrigin().x,
            center_y = self:GetAbility():GetCaster():GetAbsOrigin().y,
            center_z = self:GetAbility():GetCaster():GetAbsOrigin().z,
        }

        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_knockback", knockback)     
    end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
