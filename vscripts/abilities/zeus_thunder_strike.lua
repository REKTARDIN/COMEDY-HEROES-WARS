zeus_thunder_strike = class({})
LinkLuaModifier(
    "modifier_zeus_thunder_strike_thinker",
    "abilities/zeus_thunder_strike.lua",
    LUA_MODIFIER_MOTION_HORIZONTAL
)
LinkLuaModifier("modifier_zeus_thunder_strike", "abilities/zeus_thunder_strike.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

function zeus_thunder_strike:OnSpellStart()
    if IsServer() then
        EmitSoundOn("Hero_Zuus.GodsWrath", self:GetCaster())
        CreateModifierThinker(
            caster,
            self,
            "modifier_zeus_thunder_strike_thinker",
            {duration = 3},
            self:GetCaster():GetAbsOrigin(),
            self:GetCaster():GetTeamNumber(),
            false
        )
    end
end

modifier_zeus_thunder_strike_thinker = class({})

function modifier_zeus_thunder_strike_thinker:OnCreated(event)
    if IsServer() then
        self.counter = self:GetAbility():GetSpecialValueFor("strikes_count")
        self.radius = self:GetAbility():GetSpecialValueFor("radius")
        self.damage = self:GetAbility():GetSpecialValueFor("base_damage")
        local caster = self:GetAbility():GetCaster()
        local armor = caster:GetPhysicalArmorValue(false)
        local armor_pct = self:GetAbility():GetSpecialValueFor("armor_pct")
        local armor_damage = armor * armor_pct / 100
        self.damage = self.damage + armor_damage
        self:StartIntervalThink(0.5)
        self:OnIntervalThink()
    end
end

function modifier_zeus_thunder_strike_thinker:OnIntervalThink()
    if IsServer() then
        if self.counter <= 0 then
            self:Destroy()
            return
        end

        --- Reduce strikes count
        self.counter = self.counter - 1

        local targets =
            FindUnitsInRadius(
            self:GetParent():GetTeamNumber(),
            self:GetParent():GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            0,
            FIND_ANY_ORDER,
            false
        )

        for i = 1, #targets do
            local target = targets[i]

            if IsValidEntity(target) and (not target:IsMagicImmune()) then
                EmitSoundOn("Hero_Zuus.GodsWrath.Target", target)

                ApplyDamage(
                    {
                        victim = target,
                        attacker = self:GetAbility():GetCaster(),
                        damage = self.damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = self:GetAbility(),
                        damage_flags = DOTA_DAMAGE_FLAG_NONE
                    }
                )

                local particle =
                    ParticleManager:CreateParticle(
                    "particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf",
                    PATTACH_WORLDORIGIN,
                    target
                )
                ParticleManager:SetParticleControl(
                    particle,
                    0,
                    Vector(
                        target:GetAbsOrigin().x,
                        target:GetAbsOrigin().y,
                        target:GetAbsOrigin().z + target:GetBoundingMaxs().z
                    )
                )
                ParticleManager:SetParticleControl(
                    particle,
                    1,
                    Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, 3000)
                )
                ParticleManager:SetParticleControl(
                    particle,
                    2,
                    Vector(
                        target:GetAbsOrigin().x,
                        target:GetAbsOrigin().y,
                        target:GetAbsOrigin().z + target:GetBoundingMaxs().z
                    )
                )
            end
        end
    end
end
