hades_realm_of_death_scythe = class({})
LinkLuaModifier("modifier_hades_realm_of_death_scythe", "abilities/hades_realm_of_death_scythe.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_hades_realm_of_death_scythe_dash", "abilities/hades_realm_of_death_scythe.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

function hades_realm_of_death_scythe:GetBehavior()
    local behav = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    
	if self:GetCaster():HasModifier("modifier_hades_realm_of_death_scythe") then
		behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    
	return behav
end

function hades_realm_of_death_scythe:CastFilterResultTarget( hTarget )
	return UnitFilter(hTarget,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
        self:GetCaster():GetTeamNumber() )
end

function hades_realm_of_death_scythe:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function hades_realm_of_death_scythe:OnSpellStart()
    local target = self:GetCursorTarget()

    if self:GetCaster():HasModifier("modifier_hades_realm_of_death_scythe") then
		local disappear = self:GetCaster():FindModifierByName("modifier_hades_realm_of_death_scythe")
		disappear:Terminate(nil)
    else
        
    if target:TriggerSpellAbsorb( self ) then return end
    EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Bane.Nightmare", self:GetCaster() )
    local disappear = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_hades_realm_of_death_scythe", {duration = self:GetSpecialValueFor("max_duration")} )
    disappear:SetHost(target)
    
    self:EndCooldown()
    self:StartCooldown(0.5)

    for i = 0, 4 do
        local ability_slot = self:GetCaster():GetAbilityByIndex(i)
        ability_slot:SetActivated(false)
        end
    end
end

modifier_hades_realm_of_death_scythe = class({})
function modifier_hades_realm_of_death_scythe:OnCreated( params )
    if IsServer() then
        self:StartIntervalThink(0.03)
        self.scale = self:GetParent():GetModelScale()
        self:GetParent():SetModelScale(0.001)
    end
end

function modifier_hades_realm_of_death_scythe:SetHost (hTarget)
    self.hHost = hTarget
end

function modifier_hades_realm_of_death_scythe:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_EVENT_ON_SET_LOCATION,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
    return funcs
end

function modifier_hades_realm_of_death_scythe:IsHidden()
    return false
end
function modifier_hades_realm_of_death_scythe:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_hades_realm_of_death_scythe:AllowIllusionDuplicate()
    return false
end

function modifier_hades_realm_of_death_scythe:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
    return state
end

function modifier_hades_realm_of_death_scythe:OnDeath (params)
    if IsServer() then
        if params.unit ~= self:GetParent() then return end
        self:Destroy()
    end
end
function modifier_hades_realm_of_death_scythe:OnSetLocation (params)
    if IsServer() then
        if params.unit ~= self:GetParent() then return end
        local nCasterID = self:GetCaster():GetPlayerOwnerID()
        local nTargetID = self:GetParent():GetPlayerOwnerID()
        if PlayerResource:IsDisableHelpSetForPlayerID(nTargetID,nCasterID) then
            if self:GetAbility():IsCooldownReady() then
                self:Terminate(nil)
            end
        else
            if self.hHost ~= nil then
                ProjectileManager:ProjectileDodge(self.hHost)
                FindClearSpaceForUnit(self.hHost,self:GetParent():GetOrigin(),true)
            end
        end
    end
end

function modifier_hades_realm_of_death_scythe:Terminate (attacker)
    self:Destroy()
end
function modifier_hades_realm_of_death_scythe:OnDestroy()
    if IsServer() then
        self:GetParent():SetModelScale(self.scale)
        --self:GetParent():SetParent(nil,"symbiotic_attachment")
        EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_PhantomAssassin.CoupDeGrace", self:GetParent() )

        local coup_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
        ParticleManager:SetParticleControlEnt(coup_pfx, 0, self.hHost, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hHost:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(coup_pfx, 1, self.hHost, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self.hHost:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(coup_pfx)

        local scythe_pfx = ParticleManager:CreateParticle("particles/econ/items/necrolyte/necronub_scythe/necrolyte_scythe_ka_start.vpcff", PATTACH_CUSTOMORIGIN, self:GetCaster())
        ParticleManager:SetParticleControlEnt(scythe_pfx, 0, self.hHost, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hHost:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(scythe_pfx, 1, self.hHost, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self.hHost:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(scythe_pfx)

        local caster = self:GetCaster()
        local ability = self:GetAbility()

        local damage = self:GetAbility():GetSpecialValueFor("damage")

        self:GetParent():Heal(damage, self:GetAbility())

        local damageTable = {
            victim = self.hHost,
            attacker = self:GetCaster(),
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            ability = ability, --Optional.
        }

        ApplyDamage(damageTable)
        caster:AddNewModifier(caster, ability, "modifier_hades_realm_of_death_scythe_dash", {})
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

        for i = 0, 4 do
            local ability_slot = self:GetCaster():GetAbilityByIndex(i)
            ability_slot:SetActivated(true)
        end
        ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1))
    end
end

function modifier_hades_realm_of_death_scythe:OnIntervalThink()
    if IsServer() then
        if not self:GetParent():IsAlive() then self:Terminate(nil) end
        if self.hHost == nil then return end
        local hParent = self:GetParent()
        local pos = self.hHost:GetAbsOrigin()
        local up = Vector(0,0,300)
        hParent:SetAbsOrigin(pos+up)
        if not self.hHost:IsAlive() then
            self:Terminate(nil)
        end
    end
end

function modifier_hades_realm_of_death_scythe:GetModifierInvisibilityLevel()
    return 1
end

modifier_hades_realm_of_death_scythe_dash = class({})

function modifier_hades_realm_of_death_scythe_dash:IsHidden() 
    return true 
end

function modifier_hades_realm_of_death_scythe_dash:IsPurgable() 
    return false 
end

function modifier_hades_realm_of_death_scythe_dash:OnCreated()
    --Ability properties
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

    local startpoint = self.caster:GetAbsOrigin()
    local range = self.ability:GetSpecialValueFor("dash_range") + self.caster:GetCastRangeBonus()

    --Ability specials
    self.dash_speed = 1600

    if IsServer() then

        --variables
        self.time_elapsed = 0

        --calculate distance
        self.distance = range
        self.dash_time = self.distance / self.dash_speed
        self.direction = self.caster:GetForwardVector():Normalized()

        self:ApplyHorizontalMotionController()
    end
end

function modifier_hades_realm_of_death_scythe_dash:UpdateHorizontalMotion( me, dt)
    if IsServer() then
        self.dash_time = self.distance / self.dash_speed
        self.time_elapsed = self.time_elapsed + dt
        if self.time_elapsed < self.dash_time then

            -- Go forward
            local new_location = self.caster:GetAbsOrigin() + self.direction * self.dash_speed * dt
            self.caster:SetAbsOrigin(new_location)
        else
            self:Destroy()
        end
    end
end

function modifier_hades_realm_of_death_scythe_dash:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end

function modifier_hades_realm_of_death_scythe_dash:OnRemoved()
    if IsServer() then
        local caster = self:GetParent()

        if self.FinishDash then
            self.FinishDash()
        end

        caster:InterruptMotionControllers( true )
    end
end

function modifier_hades_realm_of_death_scythe_dash:SetFinishDash( func )
    self.FinishDash = func
end

function modifier_hades_realm_of_death_scythe_dash:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }

    return state
end
