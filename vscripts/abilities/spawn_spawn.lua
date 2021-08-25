LinkLuaModifier ("modifier_spawn_spawn", "abilities/spawn_spawn.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_spawn_spawn_active", "abilities/spawn_spawn.lua", LUA_MODIFIER_MOTION_NONE)

spawn_spawn = class ( {})

--------------------------------------------------------------------------------

function spawn_spawn:GetIntrinsicModifierName()
    return "modifier_spawn_spawn"
end

function spawn_spawn:GetCooldown( nLevel )
    return self.BaseClass.GetCooldown( self, nLevel )
end

function spawn_spawn:OnSpellStart ()
    local duration = self:GetSpecialValueFor ("duration")

    if self:GetCaster():HasTalent("special_bonus_unique_spawn_3") then 
        duration = duration + self:GetCaster():FindTalentValue("special_bonus_unique_spawn_3")
    end

    self:GetCaster():AddNewModifier (self:GetCaster(), self, "modifier_spawn_spawn_active", { duration = duration } )

    local nFXIndex = ParticleManager:CreateParticle ("particles/units/heroes/hero_monkey_king/monkey_king_spring.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl(nFXIndex, 0, self:GetCaster ():GetOrigin ())
    ParticleManager:SetParticleControl(nFXIndex, 1, Vector(400, 400, 0))
    ParticleManager:SetParticleControl(nFXIndex, 2, Vector(400, 400, 0))
    ParticleManager:SetParticleControl(nFXIndex, 3, Vector(400, 0, 0))
    ParticleManager:ReleaseParticleIndex (nFXIndex)

    EmitSoundOn ("Hero_Invoker.EMP.Discharge", self:GetCaster() )

    self:GetCaster ():StartGesture (ACT_DOTA_OVERRIDE_ABILITY_3);
end

modifier_spawn_spawn_active = class({})

function modifier_spawn_spawn_active:IsHidden()
    return false
end

function modifier_spawn_spawn_active:IsPurgable()
    return false
end

function modifier_spawn_spawn_active:OnCreated(params)

end

function modifier_spawn_spawn_active:GetStatusEffectName()
    return "particles/status_fx/status_effect_faceless_chronosphere.vpcf"
end

function modifier_spawn_spawn_active:StatusEffectPriority()
    return 1000
end

function modifier_spawn_spawn_active:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_spawn_spawn_active:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end


function spawn_spawn:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

modifier_spawn_spawn = class({})

function modifier_spawn_spawn:IsHidden() return true end
function modifier_spawn_spawn:IsPurgable() return false end

function modifier_spawn_spawn:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_AVOID_DAMAGE
    }
    return funcs
end

function modifier_spawn_spawn:OnCreated(params)
    if IsServer() then
        self.mult = self:GetAbility():GetSpecialValueFor("active_mult") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_spawn_2") or 0)
        
        self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
        self.block_ammount = self:GetAbility():GetSpecialValueFor("block_ammount")
        self.block_chance = self:GetAbility():GetSpecialValueFor("block_chance")
    end
end

function modifier_spawn_spawn:OnRefresh(params)
    if IsServer() then
        self.mult = self:GetAbility():GetSpecialValueFor("active_mult") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_spawn_2") or 0)
        
        self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
        self.block_ammount = self:GetAbility():GetSpecialValueFor("block_ammount")
        self.block_chance = self:GetAbility():GetSpecialValueFor("block_chance")
    end
end

function modifier_spawn_spawn:GetModifierAvoidDamage( params )
    if IsServer() then
        if self:GetCaster():HasModifier("modifier_spawn_spawn_active") and RollPercentage(self.evasion  * self.mult) then
            return 1
        end
    end

    return 0
end

function modifier_spawn_spawn:GetModifierEvasion_Constant( params )
    if IsServer() then
        if not self:GetCaster():HasModifier("modifier_spawn_spawn_active") and params.attacker:IsRangedAttacker() then
            return self.evasion
        end
    end

    return 0
end


function modifier_spawn_spawn:GetModifierTotal_ConstantBlock( params )
    if IsServer() and params.attacker:IsRangedAttacker() == false and RollPercentage(self.block_chance) then
        if self:GetCaster():HasModifier("modifier_spawn_spawn_active") then
            return self.block_ammount * self.mult
        end

        return self.block_ammount
    end

    return 0
end