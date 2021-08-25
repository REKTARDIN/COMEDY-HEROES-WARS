LinkLuaModifier("modifier_venom_endless_swarm", "abilities/venom_endless_swarm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venom_endless_swarm_buff", "abilities/venom_endless_swarm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venom_endless_swarm_caster", "abilities/venom_endless_swarm.lua", LUA_MODIFIER_MOTION_NONE)

venom_endless_swarm = class({})

venom_endless_swarm.hTarget = nil

function venom_endless_swarm:GetCastTarget() return self.hTarget end
function venom_endless_swarm:IsStealable() return false end

function venom_endless_swarm:OnSpellStart()
    if IsServer() then
        self.hTarget = self:GetCursorTarget()
    
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_venom_endless_swarm_caster", {duration = self:GetSpecialValueFor("duration")})
        self.hTarget:AddNewModifier(self:GetCaster(), self, "modifier_venom_endless_swarm",  {duration = self:GetSpecialValueFor("duration")})

        self:GetCaster():SwapAbilities("venom_endless_swarm", "venom_endless_swarm_cancel", false, true)
    
        EmitSoundOn("Hero_LifeStealer.Infest",  self.hTarget)
    end
end

modifier_venom_endless_swarm_caster = class({})

function modifier_venom_endless_swarm_caster:RemoveOnDeath() return true end
function modifier_venom_endless_swarm_caster:IsPurgable() return false end
function modifier_venom_endless_swarm_caster:IsHidden() return true end

if IsServer() then
    function modifier_venom_endless_swarm_caster:OnCreated()
        self:GetParent():AddNoDraw()
        self:StartIntervalThink(FrameTime())

        self.target = self:GetAbility():GetCursorTarget()
    end

    function modifier_venom_endless_swarm_caster:OnIntervalThink()
        if (not self.target) or self.target:IsAlive() == false then
            self:Destroy()
        end

        self:GetParent():SetAbsOrigin(Vector(self.target:GetAbsOrigin().x, self.target:GetAbsOrigin().y, self.target:GetAbsOrigin().z + 128))
    end

    function modifier_venom_endless_swarm_caster:OnDestroy()
        self:GetParent():RemoveNoDraw()
       
        self:GetCaster():SwapAbilities("venom_endless_swarm_cancel", "venom_endless_swarm", false, true)
    
        if self.target then
            self.target:RemoveModifierByName("modifier_venom_endless_swarm")
        end

        self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_venom_endless_swarm_buff", nil)
    end
end

function modifier_venom_endless_swarm_caster:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED]	= true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP]	= true,
        [MODIFIER_STATE_UNSELECTABLE]	= true,
        [MODIFIER_STATE_OUT_OF_GAME]	= true,
        [MODIFIER_STATE_NO_HEALTH_BAR]	= true,
        [MODIFIER_STATE_INVULNERABLE]	= true,
        [MODIFIER_STATE_MUTED]	= true
    }
end

modifier_venom_endless_swarm = class({})

function modifier_venom_endless_swarm:IsHidden() return false end
function modifier_venom_endless_swarm:IsPurgable() return false end
function modifier_venom_endless_swarm:RemoveOnDeath() return true end

function modifier_venom_endless_swarm:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_venom_endless_swarm:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slowing")
end

function modifier_venom_endless_swarm:OnCreated(params)
    if IsServer() then
        self:StartIntervalThink(1)
        self:OnIntervalThink()
    end
end

function modifier_venom_endless_swarm:OnIntervalThink()
    if IsServer() then
        local damage = {
            victim = self:GetParent(),
            attacker = self:GetCaster(),
            damage = self:GetAbility():GetSpecialValueFor("damage") + (self:GetCaster():GetAllStats() * self:GetAbility():GetSpecialValueFor("stats_damage_ptc") / 100),
            damage_type = DAMAGE_TYPE_PURE,
            ability = self:GetAbility()
        }

        ApplyDamage( damage )
    end
end

function modifier_venom_endless_swarm:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

venom_endless_swarm_cancel = class({})

function venom_endless_swarm_cancel:IsStealable() return false end
function venom_endless_swarm_cancel:GetBehavior() return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE end

function venom_endless_swarm_cancel:Spawn()
    if IsServer() then
        self:SetLevel(1)
    end
end

function venom_endless_swarm_cancel:OnSpellStart()
    self:GetCaster():RemoveModifierByName("modifier_venom_endless_swarm_caster")
    EmitSoundOn("Hero_LifeStealer.Consume", self:GetCaster())
end

if modifier_venom_endless_swarm_buff == nil then modifier_venom_endless_swarm_buff = class ( {}) end

function modifier_venom_endless_swarm_buff:IsPurgable()
    return false
end

function modifier_venom_endless_swarm_buff:RemoveOnDeath()
    return false
end

function modifier_venom_endless_swarm_buff:IsPermanent()
    return true
end

function modifier_venom_endless_swarm_buff:IsHidden()
    return true
end

function modifier_venom_endless_swarm_buff:OnCreated(params)
    self.str = self:GetAbility():GetSpecialValueFor("str_gain")
    self.hp_reg = self:GetAbility():GetSpecialValueFor("hp_regen_gain")
end

function modifier_venom_endless_swarm_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_venom_endless_swarm_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }

    return funcs
end

function modifier_venom_endless_swarm_buff:GetModifierBonusStats_Strength (params)
    return self.str
end

function modifier_venom_endless_swarm_buff:GetModifierConstantHealthRegen (params)
    return self.hp_reg 
end

