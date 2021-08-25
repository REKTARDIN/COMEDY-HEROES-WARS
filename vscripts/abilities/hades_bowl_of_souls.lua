hades_bowl_of_souls = class({})
LinkLuaModifier("modifier_hades_bowl_of_souls", "abilities/hades_bowl_of_souls.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_hades_bowl_of_souls_aura", "abilities/hades_bowl_of_souls.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_hades_bowl_of_souls_passive", "abilities/hades_bowl_of_souls.lua", LUA_MODIFIER_MOTION_NONE )

function hades_bowl_of_souls:GetIntrinsicModifierName()
    return "modifier_hades_bowl_of_souls_passive"
end

function hades_bowl_of_souls:GetBehavior()
    if self:GetLevel() >= 4 then return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE end 
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function hades_bowl_of_souls:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function hades_bowl_of_souls:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_hades_bowl_of_souls", {duration = duration})

end

modifier_hades_bowl_of_souls_passive = class({})
 
--------------------------------------------------------------------------------
 
function modifier_hades_bowl_of_souls_passive:IsHidden() return false end
function modifier_hades_bowl_of_souls_passive:IsDebuff() return false end
function modifier_hades_bowl_of_souls_passive:IsPurgable() return false end
function modifier_hades_bowl_of_souls_passive:RemoveOnDeath() return false end
 
modifier_hades_bowl_of_souls_passive.m_flCurrentSouls = 0 ---- поскольку стаки это Int, то есть целочисленное значение и прибавить к ним 0.5 нельзя, то мы просто будем записывать души сюда
 
--------------------------------------------------------------------------------
 
function modifier_hades_bowl_of_souls_passive:OnCreated( kv )
    -- get references
    self.soul_max = self:GetAbility():GetSpecialValueFor("soul_max")
    
    self.soul_release = self:GetAbility():GetSpecialValueFor("soul_release")
    self.soul_damage = self:GetAbility():GetSpecialValueFor("soul_damage")
 
    self.soul_creep_bonus = self:GetAbility():GetSpecialValueFor("soul_creep_bonus")
    self.soul_hero_bonus = self:GetAbility():GetSpecialValueFor("soul_hero_bonus")
 
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
 
    if IsServer() then
        self:SetStackCount(self.m_flCurrentSouls)
    end
end
 
function modifier_hades_bowl_of_souls_passive:OnRefresh( kv )
    -- get references
    self.soul_max = self:GetAbility():GetSpecialValueFor("soul_max")
    
    self.soul_release = self:GetAbility():GetSpecialValueFor("soul_release")
    self.soul_damage = self:GetAbility():GetSpecialValueFor("soul_damage")
 
    self.soul_creep_bonus = self:GetAbility():GetSpecialValueFor("soul_creep_bonus")
    self.soul_hero_bonus = self:GetAbility():GetSpecialValueFor("soul_hero_bonus")
    
    self.radius = self:GetAbility():GetSpecialValueFor("radius") * 2
end
 
--------------------------------------------------------------------------------
 
function modifier_hades_bowl_of_souls_passive:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
 
    return funcs
end
 
--------------------------------------------------------------------------------
-- soul release
function modifier_hades_bowl_of_souls_passive:OnDeath( params )
    if IsServer() then
        self:KillLogic( params )
    end
end
 
function modifier_hades_bowl_of_souls_passive:GetModifierPreAttack_BonusDamage( params )
    if not self:GetParent():IsIllusion() then
        local max_stack = self.soul_max
        if self:GetParent():HasScepter() then
            return self:GetStackCount() * self.soul_damage
        else
            return math.min(self.soul_max,self:GetStackCount()) * self.soul_damage
        end
    end
end
 
function modifier_hades_bowl_of_souls_passive:KillLogic( params )
    -- filter
    local target = params.unit
    local attacker = params.attacker
 
    local vToCaster = self:GetCaster():GetOrigin() - target:GetOrigin()
    local flDistance = vToCaster:Length2D()
 
    if target~=self:GetParent() and (not target:IsIllusion()) and (not target:IsBuilding()) and (not self:GetParent():PassivesDisabled()) then
        if attacker == self:GetParent() then ---- убили мы
            if target:IsRealHero() then
                ---- цель герой
                self:AddStack(true, true)
            else 
                ---- цель крип
                self:AddStack(false, true)
            end
        end
    end
end
 
function modifier_hades_bowl_of_souls_passive:AddStack( isHero, killedByParent )
    if self:GetCaster():HasScepter() then
        self.soul_max = self:GetAbility():GetSpecialValueFor("soul_max_scepter") 
    end
    local add = self.soul_creep_bonus
 
    if isHero then
        add = self.soul_hero_bonus
    end
 
    if not killedByParent then ---- если убили не мы, то делим пополам
        add = add / 2
    end    
 
    self.m_flCurrentSouls = self.m_flCurrentSouls + add
 
    if self.m_flCurrentSouls > self.soul_max then
        self.m_flCurrentSouls = self.soul_max
    end
 
    self:SetStackCount( self.m_flCurrentSouls )
end
---------------------------------------------------------------------------------------------------------------------
modifier_hades_bowl_of_souls = class({})
function modifier_hades_bowl_of_souls:IsHidden() return false end
function modifier_hades_bowl_of_souls:IsDebuff() return false end
function modifier_hades_bowl_of_souls:IsPurgable() return false end
function modifier_hades_bowl_of_souls:IsPurgeException() return false end
function modifier_hades_bowl_of_souls:RemoveOnDeath() return true end
function modifier_hades_bowl_of_souls:IsAura() return true end
function modifier_hades_bowl_of_souls:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_hades_bowl_of_souls:OnCreated()
    if IsServer() then
        local radius = self:GetAbility():GetSpecialValueFor("radius")
        local caster = self:GetCaster()

        self.souls_buff = self:GetCaster():FindModifierByName("modifier_hades_bowl_of_souls_passive")
        
		aura_particle = ParticleManager:CreateParticle("particles/stygian/hades_bowl_of_souls_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(aura_particle, 0, (caster:GetAbsOrigin()))
		ParticleManager:SetParticleControl(aura_particle, 1, (Vector(radius, 1, 1)))
		ParticleManager:SetParticleControl(aura_particle, 15, (Vector(radius, 150, 50)))
        ParticleManager:SetParticleControl(aura_particle, 16, (Vector(0, 0, 0)))

        self:AddParticle( aura_particle, false, false, -1, false, true )
        self:StartIntervalThink(1.0)
    end
    EmitSoundOn("", self:GetParent())
end

function modifier_hades_bowl_of_souls:DeclareFunctions()
    local func = {	MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_MODEL_SCALE}
    return func
end

function modifier_hades_bowl_of_souls:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health") * self.souls_buff:GetStackCount()
end

function modifier_hades_bowl_of_souls:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength") * self.souls_buff:GetStackCount()
end

function modifier_hades_bowl_of_souls:GetModifierModelScale()
    return self:GetAbility():GetSpecialValueFor("model_scale") * self.souls_buff:GetStackCount()
end

function modifier_hades_bowl_of_souls:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local radius = ability:GetSpecialValueFor("radius")
    local damage = ability:GetSpecialValueFor("damage") * self.souls_buff:GetStackCount()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

    for _,enemy in pairs(enemies) do
        local damage_aura = damage
		local damageTable = {victim = enemy,
			attacker = caster,
			damage = damage_aura,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability
		}
		ApplyDamage(damageTable)
    end
end
---------------------------------------------------------------------------------------------------------------------
modifier_hades_bowl_of_souls_aura = class({})
function modifier_hades_bowl_of_souls_aura:IsHidden() return false end
function modifier_hades_bowl_of_souls_aura:IsPurgable() return true end
