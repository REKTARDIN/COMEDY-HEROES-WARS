LinkLuaModifier( "modifier_ross_fire_hell_thinker", "abilities/ross_fire_hell.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_ross_fire_hell_debuff", "abilities/ross_fire_hell.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

ross_fire_hell = class ( {})

function ross_fire_hell:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local team_id = caster:GetTeamNumber()

        local thinker = CreateModifierThinker(caster, self, "modifier_ross_fire_hell_thinker", {duration = self:GetSpecialValueFor("debuff_duration")}, point, team_id, false)
    end
end

modifier_ross_fire_hell_thinker = class ({})

function modifier_ross_fire_hell_thinker:OnCreated(event)
    if IsServer() then
        local thinker = self:GetParent()
        local ability = self:GetAbility()
        local target = self:GetAbility():GetCaster():GetCursorPosition()

        self.radius = ability:GetSpecialValueFor("radius") + (self:GetCaster():RULK_GetUltimateStacks())

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_doom_bringer/doom_scorched_earth.vpcf", PATTACH_CUSTOMORIGIN, thinker )
        ParticleManager:SetParticleControl( nFXIndex, 0, target)
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(self.radius, 1, 1))
        ParticleManager:SetParticleControl( nFXIndex, 2, Vector(self.radius, self.radius, 1))
        self:AddParticle( nFXIndex, false, false, -1, false, true )

        EmitSoundOn("Hero_DoomBringer.ScorchedEarthAura", thinker)
        AddFOWViewer( thinker:GetTeam(), target, 1500, 5, false)
        GridNav:DestroyTreesAroundPoint(target, 1500, false)
    end
end

function modifier_ross_fire_hell_thinker:CheckState()
    return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end

function modifier_ross_fire_hell_thinker:IsAura()
    return true
end

function modifier_ross_fire_hell_thinker:GetAuraDuration()
    return self:GetAbility():GetSpecialValueFor("debuff_duration")
end

function modifier_ross_fire_hell_thinker:GetAuraRadius()
    return self.radius
end

function modifier_ross_fire_hell_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ross_fire_hell_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_ross_fire_hell_thinker:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function modifier_ross_fire_hell_thinker:GetModifierAura()
    return "modifier_ross_fire_hell_debuff"
end

modifier_ross_fire_hell_debuff = class ( {})

function modifier_ross_fire_hell_debuff:IsDebuff ()
    return true
end

function modifier_ross_fire_hell_debuff:GetEffectName()
    return "particles/units/heroes/hero_doom_bringer/doom_bringer_scorched_earth_buff.vpcf"
end

function modifier_ross_fire_hell_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ross_fire_hell_debuff:OnCreated (event)
    local ability = self:GetAbility()

    if IsServer() then
        self.damage = self:GetAbility():GetSpecialValueFor("debuff_damage") + self:GetCaster():RULK_GetUltimateStacks()

        self:StartIntervalThink(0.1)
    end
end

function modifier_ross_fire_hell_debuff:OnIntervalThink()
    if IsServer() then
        ApplyDamage(
            {
                victim = self:GetParent(),
                attacker = self:GetAbility():GetCaster(),
                damage = self.damage / 10,
                damage_type = self:GetAbility():GetAbilityDamageType(),
                ability = self:GetAbility()
            }
        )
    end
end

