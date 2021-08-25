item_heaven_sword = class({})
LinkLuaModifier( "modifier_item_heaven_sword", "items/item_heaven_sword.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_heaven_sword_burn", "items/item_heaven_sword.lua", LUA_MODIFIER_MOTION_NONE )

function item_heaven_sword:GetIntrinsicModifierName()
    return "modifier_item_heaven_sword"
end

function item_heaven_sword:GetAOERadius()
    return self:GetSpecialValueFor("aura_radius")
end
---------------------------------------------------------------------------------------------------------------
modifier_item_heaven_sword = class({})
function modifier_item_heaven_sword:IsHidden() return true end
function modifier_item_heaven_sword:IsDebuff() return false end
function modifier_item_heaven_sword:IsPurgable() return false end
function modifier_item_heaven_sword:IsPurgeException() return false end
function modifier_item_heaven_sword:IsAura() return true end
function modifier_item_heaven_sword:IsAuraActiveOnDeath() return false end
function modifier_item_heaven_sword:RemoveOnDeath() return false end
function modifier_item_heaven_sword:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_heaven_sword:DeclareFunctions()
    local func = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_HEALTH_BONUS}
    return func
end

function modifier_item_heaven_sword:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_heaven_sword:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_heaven_sword:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_heaven_sword:GetAuraRadius()
    return self:GetAbility():GetAOERadius()
end

function modifier_item_heaven_sword:GetEffectName()
    return "particles/econ/events/ti10/radiance_owner_ti10.vpcf"
end

function modifier_item_heaven_sword:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end
function modifier_item_heaven_sword:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_item_heaven_sword:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_item_heaven_sword:GetModifierAura()
    return "modifier_item_heaven_sword_burn"
end

function modifier_item_heaven_sword:OnCreated(table)

end

function modifier_item_heaven_sword:OnRefresh(table)

end
function modifier_item_heaven_sword:OnDestroy()

end
---------------------------------------------------------------------------------------------------------------------
modifier_item_heaven_sword_burn = class({})
function modifier_item_heaven_sword_burn:IsHidden() return false end
function modifier_item_heaven_sword_burn:IsDebuff() return true end
function modifier_item_heaven_sword_burn:IsPurgable() return true end
function modifier_item_heaven_sword_burn:IsPurgeException() return true end
function modifier_item_heaven_sword_burn:RemoveOnDeath() return true end
function modifier_item_heaven_sword_burn:DeclareFunctions()
    local func = {	MODIFIER_PROPERTY_MISS_PERCENTAGE}

    return func
end

function modifier_item_heaven_sword_burn:GetModifierMiss_Percentage()
    return self:GetAbility():GetSpecialValueFor("miss_chance")
end

function modifier_item_heaven_sword_burn:OnCreated(table)

    self.pct_damage = self:GetParent():GetMaxHealth() * self:GetAbility():GetSpecialValueFor("burn_pct_damage") /100
    self.damage = self:GetAbility():GetSpecialValueFor("burn_damage") + self.pct_damage
    self.damage_illusion = self:GetAbility():GetSpecialValueFor("burn_damage") + self.pct_damage / 2

    self.time = 0

    self.damage_table = {victim = self:GetParent(),
        attacker = self:GetCaster(),
        ability = self:GetAbility(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_MAGICAL}

    if IsServer() then
        self.burn_particle = ParticleManager:CreateParticle("particles/econ/events/ti10/radiance_ti10.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.burn_particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.burn_particle, 1, self:GetCaster():GetAbsOrigin())

        self:AddParticle(self.burn_particle, true, false, -1, false, false)

        self:StartIntervalThink(FrameTime())
    end
end
function modifier_item_heaven_sword_burn:OnIntervalThink()
    if IsServer() then
        if not self:GetCaster() or self:GetCaster():IsNull() or not self:GetCaster():IsAlive() or not self:GetParent() or self:GetParent():IsNull() or not self:GetParent():IsAlive() then
            self:Destroy()

            return nil
        end

        ParticleManager:SetParticleControl(self.burn_particle, 1, self:GetCaster():GetAbsOrigin())

        self.time = self.time + FrameTime()
        if self.time >= 1 then
            self.time = 0

            if self:GetCaster():IsIllusion() then
                self.damage_table.damage = self.damage_illusion
            else
                self.damage_table.damage = self.damage
            end

            ApplyDamage(self.damage_table)
        end
    end
end

function modifier_item_heaven_sword_burn:OnRefresh(table)
    self:OnCreated(table)
end

