if item_enchanted_cucumber == nil then
    item_enchanted_cucumber = class({})
end

function item_enchanted_cucumber:OnSpellStart()
    local caster = self:GetCaster()
    local hp_restore = self:GetSpecialValueFor("health_restore")

    local lifesteal_fx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(lifesteal_fx, 0, caster:GetAbsOrigin())
    
    EmitSoundOn("DOTA_Item.Mango.Activate", caster)
  
    if caster:IsRealHero() then
        caster:ModifyStrength(self:GetSpecialValueFor("extra_strenght"))
    end

    self:RemoveSelf()
end

function item_enchanted_cucumber:GetAbilityTextureName()
    return self.BaseClass.GetAbilityTextureName(self)
end
