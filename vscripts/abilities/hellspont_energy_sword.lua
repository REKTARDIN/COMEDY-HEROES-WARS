hellspont_energy_sword = class({})

LinkLuaModifier( "modifier_hellspont_energy_sword_active", "abilities/hellspont_energy_sword.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hellspont_energy_sword_chopping", "abilities/hellspont_energy_sword.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function hellspont_energy_sword:OnSpellStart()
    if IsServer() then

        local duration = self:GetSpecialValueFor(  "duration" )

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_hellspont_energy_sword_active", { duration = duration } )

        EmitSoundOn( "Hero_Sven.WarCry", self:GetCaster() )

    end
end

modifier_hellspont_energy_sword_active = class({})

function modifier_hellspont_energy_sword_active:IsHidden() 
    return false 
end

function modifier_hellspont_energy_sword_active:IsDebuff() 
    return false 
end

function modifier_hellspont_energy_sword_active:IsPurgable() 
    return false 
end

function modifier_hellspont_energy_sword_active:IsPurgeException() 
    return false 
end

function modifier_hellspont_energy_sword_active:RemoveOnDeath() 
    return true 
end

function modifier_hellspont_energy_sword_active:OnCreated( kv )
    if IsServer() then

    self.chance = self:GetAbility():GetSpecialValueFor("sword_chopping_chance")
    self.duration = self:GetAbility():GetSpecialValueFor("sword_chopping_duration")
    self.bonus_damage = self:GetAbility():GetSpecialValueFor("sword_bonus_damage")

    if self:GetParent():HasModifier("modifier_hellspont_sword_strike_extra_chop") then
        self.chance = self:GetAbility():GetSpecialValueFor("sword_chopping_extra_chance")
    end
end

function modifier_hellspont_energy_sword_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,

        MODIFIER_EVENT_ON_ATTACK_LANDED
    }

    return funcs
end

function modifier_hellspont_energy_sword_active:OnAttackLanded(params)
    if IsServer() then

        if params.attacker ~= self:GetParent() then
            return nil
        end

        if params.target == self:GetParent() then
            return nil
        end

        if params.target:IsBuilding() then
            return nil
        end

        if RollPercentage(self.chance) and self:GetAbility() then

            params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_hellspont_energy_sword_chopping", {duration = self.duration})

                EmitSoundOn("Hero_EmberSpirit.SleightOfFist.Cast", self:GetParent())
            end
        end
    end
end

function modifier_hellspont_energy_sword_active:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

modifier_hellspont_energy_sword_chopping = class({})

function modifier_hellspont_energy_sword_chopping:IsHidden() 
    return false 
end

function modifier_hellspont_energy_sword_chopping:IsDebuff() 
    return true 
end

function modifier_hellspont_energy_sword_chopping:IsPurgable() 
    return false 
end

function modifier_hellspont_energy_sword_chopping:IsPurgeException() 
    return true 
end

function modifier_hellspont_energy_sword_chopping:RemoveOnDeath() 
    return true 
end

function modifier_hellspont_energy_sword_chopping:GetEffectName ()
    return "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf"
end

function modifier_hellspont_energy_sword_chopping:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_hellspont_energy_sword_chopping:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end