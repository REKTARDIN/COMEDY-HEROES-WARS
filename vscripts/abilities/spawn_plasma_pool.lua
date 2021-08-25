if spawn_plasma_pool == nil then spawn_plasma_pool = class({}) end

LinkLuaModifier( "modifier_spawn_plasma_pool", "abilities/spawn_plasma_pool.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

function spawn_plasma_pool:OnSpellStart()
    if IsServer() then
        local radius = self:GetSpecialValueFor( "radius" )
        local duration = self:GetSpecialValueFor(  "duration" )

        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_spawn_plasma_pool", { duration = duration, radius = radius } )
      
        EmitSoundOn( "Hero_Oracle.FortunesEnd.Channel", self:GetCaster() )
    end
end

function spawn_plasma_pool:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end

modifier_spawn_plasma_pool = class ({})

function modifier_spawn_plasma_pool:OnCreated(event)
    self.dmg_amp = self:GetAbility():GetSpecialValueFor("damage_per_sec") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_spawn_1") or 0)
    self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_spawn_1") or 0)

    if IsServer() then
        self.radius = event.radius
        self.pos = self:GetParent():GetAbsOrigin()

        if self:GetCaster():HasModifier("modifier_spawn_spawn_active") then
            self.radius = self.radius + self.radius
        end
        
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_fairy/fairy_revive_aura.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( nFXIndex, 0, self.pos)
        ParticleManager:SetParticleControl( nFXIndex, 2, Vector(self.radius, self.radius, 1))

        self:AddParticle( nFXIndex, false, false, -1, false, true )

        self:StartIntervalThink(1)
        self:OnIntervalThink()
    end
end

function modifier_spawn_plasma_pool:IsDebuff () return false end
function modifier_spawn_plasma_pool:IsPurgable() return false end

function modifier_spawn_plasma_pool:OnIntervalThink()
    if IsServer() then
        self:IncrementStackCount()

        local dist = (self.pos - self:GetParent():GetAbsOrigin()):Length2D()

        if (dist > self.radius) then
            self:Destroy()
        end

        if self:GetCaster():HasModifier("modifier_spawn_spawn_active") then
			self:GetCaster():Heal(self:GetCaster():GetMaxHealth() * 0.03, self:GetCaster())
		end
    end
end

function modifier_spawn_plasma_pool:DeclareFunctions ()
    return { MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end

function modifier_spawn_plasma_pool:GetModifierBaseAttack_BonusDamage ()
    return self.dmg_amp * self:GetStackCount()
end

function modifier_spawn_plasma_pool:GetModifierSpellAmplify_Percentage ()
    return self.spell_amp * self:GetStackCount()
end


