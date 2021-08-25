el_diablo_fire_wave = class({})

LinkLuaModifier ("modifier_el_diablo_fire_wave_debuff", "abilities/el_diablo_fire_wave.lua", LUA_MODIFIER_MOTION_NONE)

function el_diablo_fire_wave:OnSpellStart()
    if IsServer() then
        self.el_diablo_fire_wave_speed = self:GetSpecialValueFor( "wave_speed" )
        self.el_diablo_fire_wave_width_initial = self:GetSpecialValueFor( "wave_width_initial" )
        self.el_diablo_fire_wave_width_end = self:GetSpecialValueFor( "wave_width_end" )
        self.el_diablo_fire_wave_distance = self:GetSpecialValueFor( "wave_distance" )
        self.el_diablo_fire_wave_damage = self:GetSpecialValueFor( "wave_damage" ) 
        self.el_diablo_fire_wave_duration = self:GetSpecialValueFor( "wave_duration")

        EmitSoundOn( "Hero_NagaSiren.Riptide.Cast", self:GetCaster() )

        local vPos = nil
        if self:GetCursorTarget() then
            vPos = self:GetCursorTarget():GetOrigin()
        else
            vPos = self:GetCursorPosition()
        end

        local vDirection = vPos - self:GetCaster():GetOrigin()
        vDirection.z = 0.0
        vDirection = vDirection:Normalized()

        self.el_diablo_fire_wave_speed = self.el_diablo_fire_wave_speed * ( self.el_diablo_fire_wave_distance / ( self.el_diablo_fire_wave_distance - self.el_diablo_fire_wave_width_initial ) )

        local info = {
            EffectName = "particles/econ/items/jakiro/jakiro_ti8_immortal_head/jakiro_ti8_dual_breath_fire.vpcf",
            Ability = self,
            vSpawnOrigin = self:GetCaster():GetOrigin(), 
            fStartRadius = self.el_diablo_fire_wave_width_initial,
            fEndRadius = self.el_diablo_fire_wave_width_end,
            vVelocity = vDirection * self.el_diablo_fire_wave_speed,
            fDistance = self.el_diablo_fire_wave_distance + self:GetCaster():GetCastRangeBonus(),
            Source = self:GetCaster(),
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        }

        ProjectileManager:CreateLinearProjectile( info )
        EmitSoundOn( "Hero_AbyssalUnderlord.Firestorm.Start", self:GetCaster() )
    end
end

--------------------------------------------------------------------------------

function el_diablo_fire_wave:OnProjectileHit( hTarget, vLocation )
    if IsServer() then
        if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
            local damage = {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = self.el_diablo_fire_wave_damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self
            }
            EmitSoundOn( "Hero_AbyssalUnderlord.Firestorm.Cast" , hTarget)

            ApplyDamage( damage )

            local vDirection = vLocation - self:GetCaster():GetOrigin()
            vDirection.z = 0.0
            vDirection = vDirection:Normalized()
            
            local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_tidehunter/tidehunter_gush_splash_water3.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
            ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
            ParticleManager:ReleaseParticleIndex( nFXIndex )

            hTarget:AddNewModifier(self:GetCaster(), self, "modifier_el_diablo_fire_wave_debuff", {duration = self.el_diablo_fire_wave_duration})
        end
    end

	return false
end

modifier_el_diablo_fire_wave_debuff = class({})

function modifier_el_diablo_fire_wave_debuff:IsHidden()
	return false
end

function modifier_el_diablo_fire_wave_debuff:IsDebuff()
	return true
end

function modifier_el_diablo_fire_wave_debuff:IsStunDebuff()
	return false
end

function modifier_el_diablo_fire_wave_debuff:IsPurgable()
	return true
end

function modifier_el_diablo_fire_wave_debuff:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end

function modifier_el_diablo_fire_wave_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
    self:OnIntervalThink()
end

function modifier_el_diablo_fire_wave_debuff:OnIntervalThink()
    if not IsServer() then return end
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        ability = self:GetAbility(),
        damage = (self:GetAbility():GetSpecialValueFor("burn_damage") + 0.01 * self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("burn_damage_pct"))) / 2,
        damage_type = self:GetAbility():GetAbilityDamageType()
    })
end
