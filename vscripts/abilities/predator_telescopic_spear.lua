predator_telescopic_spear = class({})

--------------------------------------------------------------------------------

function predator_telescopic_spear:OnSpellStart()
    if IsServer() then
        local info = {
			EffectName = "particles/hero_predator/telescopic_spear.vpcf",
			Ability = self,
			iMoveSpeed = 900,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
		}

        ProjectileManager:CreateTrackingProjectile( info )

        EmitSoundOn( "Hero_Mars.Spear", self:GetCaster() )
    end
end

--------------------------------------------------------------------------------

function predator_telescopic_spear:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) and ( not hTarget:TriggerSpellAbsorb( self ) ) and ( not hTarget:IsMagicImmune() ) then
		EmitSoundOn( "Hero_Mars.Spear.Target", hTarget )
        
		local damage = self:GetAbilityDamage() + self:GetCaster():GetAverageTrueAttackDamage(hTarget)

        if self:GetCaster():HasTalent("special_bonus_unique_predator_1") then
            if RollPercentage(50) then
                damage = damage * 2
            end
        end

        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_silence", { duration = self:GetSpecialValueFor( "silence_duration" ) } )
        
        ApplyDamage( {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		})
	end

	return true
end
