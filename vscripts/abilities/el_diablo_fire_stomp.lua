el_diablo_fire_stomp = class ({})

function el_diablo_fire_stomp:OnSpellStart ()
    if IsServer() then
        local radius = self:GetSpecialValueFor( "radius" )

        local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        if #units > 0 then
            for _,unit in pairs(units) do
                unit:AddNewModifier(
                    self:GetCaster(),
                    self,
                    "modifier_stunned",
                    { duration = 0.5 })

                local damage = self:GetSpecialValueFor("base_damage")
                local damage_amp = self:GetSpecialValueFor("damage_amp_max")/100

                local missing_health_pct = ((unit:GetMaxHealth() - unit:GetHealth()) / unit:GetMaxHealth())

                local total_damage = damage + (damage * (missing_health_pct * damage_amp))

            ApplyDamage({
                attacker = self:GetCaster(),
                victim = unit,
                damage = total_damage,
                ability = self,
                damage_type = DAMAGE_TYPE_MAGICAL})
            end
        end
        
        local nFXIndex = ParticleManager:CreateParticle( "particles/stygian/diablo_fire_stomp.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
        ParticleManager:SetParticleControl( nFXIndex, 1, Vector(radius, radius, 1) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

        EmitSoundOn( "Hero_ChaosKnight.ChaosBolt.Impact", self:GetCaster() )

        self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_3 );
    end
end

