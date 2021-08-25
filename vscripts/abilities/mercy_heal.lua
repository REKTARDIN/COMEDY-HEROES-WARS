if mercy_heal == nil then mercy_heal = class({}) end

LinkLuaModifier ("modifier_mercy_heal", "abilities/mercy_heal.lua", LUA_MODIFIER_MOTION_NONE)

function mercy_heal:GetIntrinsicModifierName ()
    return "modifier_mercy_heal"
end

function mercy_heal:GetBehavior ()
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function mercy_heal:GetCooldown(nLevel)
    return self.BaseClass.GetCooldown (self, nLevel)
end

function mercy_heal:Spawn()
    if IsServer() then
        self:SetLevel(1)
    end
end


if modifier_mercy_heal == nil then modifier_mercy_heal = class({}) end

function modifier_mercy_heal:DeclareFunctions ()
    return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_mercy_heal:IsHidden() return true end
function modifier_mercy_heal:IsPurgable() return false end

function modifier_mercy_heal:OnCreated(params)
    self.heal = self:GetAbility():GetSpecialValueFor("heal_base")
    self.heal_ptc = self:GetAbility():GetSpecialValueFor("ptc_hp_regen") / 100
end

function modifier_mercy_heal:OnRefresh(params)
    self.heal = self:GetAbility():GetSpecialValueFor("heal_base")
    self.heal_ptc = self:GetAbility():GetSpecialValueFor("ptc_hp_regen") / 100
end

function modifier_mercy_heal:GetModifierConstantHealthRegen ()
    if IsServer() then
        local regen = self:GetParent():GetMaxHealth () * self.heal_ptc + self.heal

        if self:GetAbility():IsCooldownReady() then
            self:SetStackCount(regen)
        else 
            self:SetStackCount(0)
        end
    end

    return self:GetStackCount()
end

function modifier_mercy_heal:OnTakeDamage (event)
    if event.unit == self:GetParent() and not self:GetParent() ~= event.attacker then
        if event.attacker:IsHero() and not self:GetCaster():HasModifier("modifier_mercy_valkyri") then
            if not self:GetCaster():HasScepter() then
                self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("damage_cooldown"))
            end
        end
    end
end

