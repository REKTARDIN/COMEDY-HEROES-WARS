LinkLuaModifier ("modifier_strange_ancient_magic", "abilities/strange_ancient_magic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_strange_ancient_magic_buff", "abilities/strange_ancient_magic.lua", LUA_MODIFIER_MOTION_NONE)

strange_ancient_magic = class({})

function strange_ancient_magic:OnSpellStart() 
    if IsServer() then 
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_strange_ancient_magic", {duration = self:GetSpecialValueFor("duration")}) 
        EmitSoundOn("Hero_Bane.BrainSap", self:GetCaster())
    end 
end

modifier_strange_ancient_magic = class({})

function modifier_strange_ancient_magic:IsAura() return true end
function modifier_strange_ancient_magic:IsHidden() return true end
function modifier_strange_ancient_magic:IsPurgable()	return true end
function modifier_strange_ancient_magic:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_strange_ancient_magic:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_strange_ancient_magic:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_strange_ancient_magic:GetAuraSearchFlags() return 0 end
function modifier_strange_ancient_magic:GetModifierAura() return "modifier_strange_ancient_magic_buff" end

function modifier_strange_ancient_magic:OnCreated(event)
    if IsServer() then
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
  
        local nFXIndex = ParticleManager:CreateParticle( "particles/items_fx/gem_truesight_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(self.radius, 0, 0))
        self:AddParticle( nFXIndex, false, false, -1, false, true )
    end
end

modifier_strange_ancient_magic_buff = class ( {})

function modifier_strange_ancient_magic_buff:IsHidden()
    return false
end

function modifier_strange_ancient_magic_buff:IsDebuff()
    return false
end

function modifier_strange_ancient_magic_buff:IsPurgable()
    return false
end

function modifier_strange_ancient_magic_buff:GetEffectName()
    return "particles/units/heroes/hero_oracle/oracle_purifyingflames_heal.vpcf"
end

function modifier_strange_ancient_magic_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_strange_ancient_magic_buff:OnCreated(params)
    if IsServer () then
        self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_rate"))

        self.heal = self:GetAbility():GetSpecialValueFor("heal_per_second") + ((self:GetAbility():GetSpecialValueFor("max_hp_heal_per_second") / 100) * self:GetParent():GetMaxHealth())
        self.mana = self:GetAbility():GetSpecialValueFor("mana_per_second")

        self:OnIntervalThink()
    end
end

function modifier_strange_ancient_magic_buff:OnIntervalThink()
    if IsServer() then
        self:GetParent():Heal(self.heal, self:GetAbility())
        self:GetParent():GiveMana(self.mana)

        SendOverheadEventMessage(  self:GetParent(), OVERHEAD_ALERT_HEAL,  self:GetParent(), self.heal, nil )
    end
end

