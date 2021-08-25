if iron_fist_energy == nil then iron_fist_energy = class({}) end

LinkLuaModifier ("modifier_iron_fist_energy", "abilities/iron_fist_energy.lua", LUA_MODIFIER_MOTION_NONE)

function iron_fist_energy:OnSpellStart()
    if IsServer() then
        local duration = self:GetSpecialValueFor( "duration" )
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_iron_fist_energy", { duration = duration })
    end
end

function iron_fist_energy:GetManaCost(iLevel)
    return self.BaseClass.GetManaCost (self, iLevel) + self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_damage") * 0.01
end

if modifier_iron_fist_energy == nil then modifier_iron_fist_energy = class({}) end

function modifier_iron_fist_energy:IsHidden ()
    return false
end

function modifier_iron_fist_energy:AllowIllusionDuplicate()
    return true
end

function modifier_iron_fist_energy:IsPurgable()
    return false
end

function modifier_iron_fist_energy:DeclareFunctions ()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }

    return funcs
end

function modifier_iron_fist_energy:OnCreated( kv )
    if IsServer() then

        local nFXIndex = ParticleManager:CreateParticle( "particles/stygian/fist/hero_iron_fist/ironfist_iron_strike_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_fist" , self:GetParent():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_fist" , self:GetParent():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_fist" , self:GetParent():GetOrigin(), true )
        ParticleManager:SetParticleControl( nFXIndex, 3, Vector(1, 0, 0) )
        ParticleManager:SetParticleControl( nFXIndex, 4, Vector(1, 0, 0) )
        ParticleManager:SetParticleControlEnt( nFXIndex, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_fist" , self:GetParent():GetOrigin(), true )
        ParticleManager:SetParticleControl( nFXIndex, 8, Vector(1, 0, 0) )
        self:AddParticle( nFXIndex, false, false, -1, false, true )
    end
end

function modifier_iron_fist_energy:GetModifierPreAttack_BonusDamage( params )
    local mana_damage = self:GetParent():GetMaxMana() * self:GetAbility():GetSpecialValueFor("mana_damage") * 0.01
    return self:GetAbility():GetSpecialValueFor("damage") + mana_damage
end

function iron_fist_energy:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end

