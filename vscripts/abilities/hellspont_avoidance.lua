hellspont_avoidance = class({})

LinkLuaModifier( "modifier_hellspont_avoidance", "abilities/hellspont_avoidance.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hellspont_avoidance_dummy", "abilities/hellspont_avoidance.lua", LUA_MODIFIER_MOTION_NONE )

function hellspont_avoidance:GetIntrinsicModifierName()
    return "modifier_hellspont_avoidance"
end

modifier_hellspont_avoidance = class({})

function modifier_hellspont_avoidance:IsHidden() 
    return true 
end
function modifier_hellspont_avoidance:IsDebuff() 
    return true 
end

function modifier_hellspont_avoidance:IsPurgable() 
    return false 
end

function modifier_hellspont_avoidance:IsPurgeException() 
    return false 
end

function modifier_hellspont_avoidance:RemoveOnDeath() 
    return true 
end

function modifier_hellspont_avoidance:IsAura() 
    return true 
end

function modifier_hellspont_avoidance:GetAuraRadius()
    return self:GetParent():Script_GetAttackRange() + 35
end

function modifier_hellspont_avoidance:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end
function modifier_hellspont_avoidance:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_hellspont_avoidance:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_hellspont_avoidance:GetModifierAura()
    return "modifier_hellspont_avoidance_dummy"
end

function modifier_hellspont_avoidance:DeclareFunctions()
    local func = { MODIFIER_PROPERTY_AVOID_DAMAGE}

    return func
end

function modifier_hellspont_avoidance:OnCreated( kv )
    if IsServer() then
        self.chance = self:GetAbility():GetSpecialValueFor("avoidance_chance")
        self.damage_physical = self.damage_physical or 0
        self.damage_magical = self.damage_magical or 0
        self.damage_pure = self.damage_pure or 0
    end
end


function modifier_hellspont_avoidance:GetModifierAvoidDamage(params)
    if IsServer() then
        if RollPercentage(self.chance) and self:GetAbility() then
            if params.target == self:GetParent() then
                if params.damage_type == DAMAGE_TYPE_PHYSICAL then
                    self.damage_physical = self.damage_physical + params.original_damage
                    self.physical_attacker = params.target
                    self.physical_victim = params.attacker
                elseif params.damage_type == DAMAGE_TYPE_MAGICAL then
                    self.damage_magical = self.damage_magical + params.original_damage
                    self.magical_attacker = params.target
                    self.magical_victim = params.attacker
                else
                    self.damage_pure = self.damage_pure + params.original_damage
                    self.pure_attacker = params.target
                    self.pure_victim = params.attacker
                end
            end

            self.damage = self:GetParent():GetAverageTrueAttackDamage(params.attacker)
            self.ability = self:GetAbility()

            if params.attacker:HasModifier("modifier_hellspont_avoidance_dummy") then
                if self.damage_physical and self.damage_physical > 0 and self.physical_attacker then
                    local damage_table_physical = {
                        victim = self.physical_victim,
                        attacker = self.physical_attacker,
                        damage = self.damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
                        ability = self.ability }

                    ApplyDamage(damage_table_physical)
                end

                if self.damage_magical and self.damage_magical > 0 and self.magical_attacker then
                    local damage_table_magical =  {
                        victim = self.magical_victim,
                        attacker = self.magical_attacker,
                        damage = self.damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
                        ability = self.ability }

                    ApplyDamage(damage_table_magical)
                end

                if self.damage_pure and self.damage_pure > 0 and self.pure_attacker then
                    local damage_table_pure = {
                        victim = self.pure_victim,
                        attacker = self.pure_attacker,
                        damage = self.damage,
                        damage_type = DAMAGE_TYPE_PURE,
                        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
                        ability = self.ability }

                    ApplyDamage(damage_table_pure)

                    return 1
                end
            end
        end
    end
end

modifier_hellspont_avoidance_dummy = class({})
function modifier_hellspont_avoidance_dummy:IsHidden() return true end
function modifier_hellspont_avoidance_dummy:IsDebuff() return true end
function modifier_hellspont_avoidance_dummy:IsPurgable() return true end
function modifier_hellspont_avoidance_dummy:IsPurgeException() return true end
function modifier_hellspont_avoidance_dummy:RemoveOnDeath() return true end
