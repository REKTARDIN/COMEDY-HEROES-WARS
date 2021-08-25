iron_fist_iron_strike = class ( {})

LinkLuaModifier ("modifier_iron_fist_iron_strike", "abilities/iron_fist_iron_strike.lua", LUA_MODIFIER_MOTION_NONE)

function iron_fist_iron_strike:GetManaCost(iLevel)
    return self.BaseClass.GetManaCost (self, iLevel) + self:GetCaster():GetMana() * self:GetSpecialValueFor("mana_damage") * 0.01
end

function iron_fist_iron_strike:GetIntrinsicModifierName ()
    return "modifier_iron_fist_iron_strike"
end

function iron_fist_iron_strike:OnUpgrade()
    if IsServer() then
        if self and not self:IsNull() and self:GetLevel() <= 1 then
            self:SetActivated(false)
        end
    end
end

function iron_fist_iron_strike:OnSpellStart ()
    if IsServer() then
        local radius = self:GetSpecialValueFor( "radius" )
        local damage = self:GetCaster():GetMana() * self:GetSpecialValueFor("mana_damage") * 0.01

        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetOrigin(),
            self:GetCaster(),
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0,
            0,
            false )

        if #units > 0 then
            for _,unit in pairs(units) do
                unit:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = 1.4 } )

                self:GetCaster():PerformAttack(unit, true, true, true, false, false, false, true)

                ApplyDamage({attacker = self:GetCaster(),
                    victim = unit,
                    damage = damage,
                    ability = self,
                    damage_type = DAMAGE_TYPE_PHYSICAL})
            end
        end

        local nFXIndex = ParticleManager:CreateParticle( "particles/hero_ursa/ursa_thunderclap.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        local nFXIndex = ParticleManager:CreateParticle( "particles/stygian/fist/aoe_hero_iron_fist/ironfist_iron_strike_ground.vpcf", PATTACH_CUSTOMORIGIN,  self:GetCaster() );
        ParticleManager:SetParticleControl( nFXIndex, 0,  self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(1, 0, 0) )
        ParticleManager:SetParticleControl( nFXIndex, 2, Vector(0, radius, 0) )
        ParticleManager:SetParticleControl( nFXIndex, 3, Vector(0, 0.4, 0) )
        ParticleManager:SetParticleControl( nFXIndex, 11,  self:GetCaster():GetAbsOrigin())
        ParticleManager:SetParticleControl( nFXIndex, 12,  self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex( nFXIndex );

        EmitSoundOn( "Hero_EarthShaker.EchoSlam",  self:GetCaster() )
        EmitSoundOn( "Hero_EarthShaker.EchoSlamEcho",  self:GetCaster() )
        EmitSoundOn( "Hero_EarthShaker.EchoSlamSmall",  self:GetCaster() )
        EmitSoundOn( "PudgeWarsClassic.echo_slam",  self:GetCaster() )

        self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_4 );
    end
end

modifier_iron_fist_iron_strike = class ( {})

function modifier_iron_fist_iron_strike:IsHidden()
    return true
end

function modifier_iron_fist_iron_strike:IsPurgable()
    return false
end

function modifier_iron_fist_iron_strike:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_iron_fist_iron_strike:OnIntervalThink()
    if IsServer() then
        if self:GetParent():HasModifier("modifier_iron_fist_energy") then
            self:GetAbility():SetActivated(true)
        else
            self:GetAbility():SetActivated(false)
        end
    end
end
