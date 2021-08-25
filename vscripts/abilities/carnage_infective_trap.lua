LinkLuaModifier("carnage_infective_trap_thinker", "abilities/carnage_infective_trap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_carnage_infective_trap_buff", "abilities/carnage_infective_trap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_carnage_infective_trap_debuff", "abilities/carnage_infective_trap.lua", LUA_MODIFIER_MOTION_NONE)

local INTERVAL = 0.5

carnage_infective_trap = class({})

function carnage_infective_trap:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", context )
    PrecacheResource( "model", "models/props_nature/desert/desert_thorns02.vmdl", context )
end

function carnage_infective_trap:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local team_id = caster:GetTeamNumber()

    local thinker = CreateModifierThinker(caster, self, "carnage_infective_trap_thinker", {duration = self:GetSpecialValueFor("duration")}, point, team_id, false)
    
    EmitSoundOn("Hero_Bristleback.ViscousGoo.Cast.Immortal", caster)
end

carnage_infective_trap_thinker = class({})

function carnage_infective_trap_thinker:OnCreated(event)
    if IsServer() then
        local thinker = self:GetParent()
        local ability = self:GetAbility()

        self.activated = false

        self.delay = self:GetAbility():GetSpecialValueFor("delay")
        self.radius = self:GetAbility():GetSpecialValueFor("radius")

        self.time_with_heroes = 0
        self.current_time = self.duration

        self:StartIntervalThink(INTERVAL)
        self:OnIntervalThink()
    
        self:GetParent():SetOriginalModel("models/props_nature/desert/desert_thorns02.vmdl")
        self:GetParent():SetModelScale(1.0)
    end
end

function carnage_infective_trap_thinker:OnIntervalThink()
    local thinker = self:GetParent()
    local thinker_pos = thinker:GetAbsOrigin()

    if not self.activated then
        local heroes = self:GetHeroesCountInRadius()

        if heroes > 0 then
            self.time_with_heroes = self.time_with_heroes + INTERVAL
        else 
            self.time_with_heroes = 0 
        end

        if self.time_with_heroes > self.delay then
            self.time_with_heroes = 0

            self.activated = true
        end
    else 
        local units = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false )
        local hero = units[1]

        if hero then
            EmitSoundOn("Hero_Bristleback.PistonProngs.QuillSpray.Cast", unit)
         
            hero:AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_carnage_infective_trap_debuff", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")})
            self:GetAbility():GetCaster():AddNewModifier(self:GetAbility():GetCaster(), self:GetAbility(), "modifier_carnage_infective_trap_buff", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")})
        end
       
        self:Destroy()

        UTIL_Remove(self:GetParent())
    end
end

function carnage_infective_trap_thinker:GetHeroesCountInRadius()
    local heroes = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetCaster(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false )

    return #heroes
end

function carnage_infective_trap_thinker:OnDestroy()
    
end

function carnage_infective_trap_thinker:CheckState()
    return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end

if modifier_carnage_infective_trap_debuff == nil then modifier_carnage_infective_trap_debuff = class({}) end 

function modifier_carnage_infective_trap_debuff:IsPurgeException()
    return true
end

function modifier_carnage_infective_trap_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_nullifier_slow.vpcf"
end


function modifier_carnage_infective_trap_debuff:StatusEffectPriority()
    return 1000
end


function modifier_carnage_infective_trap_debuff:GetEffectName()
    return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf"
end


function modifier_carnage_infective_trap_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_carnage_infective_trap_debuff:OnCreated( kv )
    if IsServer() then
        self:StartIntervalThink(1)
        self:OnIntervalThink()
    end
end


function modifier_carnage_infective_trap_debuff:OnIntervalThink()
    if IsServer() then
        local damage = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self:GetAbility():GetSpecialValueFor("damage"),
            damage_type = DAMAGE_TYPE_PURE,
            ability = self:GetAbility()
        }
    
        ApplyDamage( damage )
    end
end

function modifier_carnage_infective_trap_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end


if modifier_carnage_infective_trap_buff == nil then modifier_carnage_infective_trap_buff = class({}) end 

function modifier_carnage_infective_trap_buff:IsPurgeException()
    return true
end

function modifier_carnage_infective_trap_buff:GetStatusEffectName()
    return "particles/units/heroes/hero_visage/status_effect_visage_chill_slow.vpcf"
end


function modifier_carnage_infective_trap_buff:StatusEffectPriority()
    return 1000
end


function modifier_carnage_infective_trap_buff:GetEffectName()
    return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end


function modifier_carnage_infective_trap_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_carnage_infective_trap_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_carnage_infective_trap_buff:GetModifierMoveSpeedBonus_Percentage( params )
	return self:GetAbility():GetSpecialValueFor("movement_speed_bonus") 
end


function modifier_carnage_infective_trap_buff:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end
