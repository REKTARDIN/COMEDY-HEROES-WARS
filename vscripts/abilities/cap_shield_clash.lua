if not cap_shield_clash then cap_shield_clash = class({}) end 

LinkLuaModifier( "modifier_cap_shield_clash", "abilities/cap_shield_clash.lua", LUA_MODIFIER_MOTION_NONE )

function cap_shield_clash:OnSpellStart()
    if IsServer() then 
        local info = {
            EffectName = "particles/cap_magic_missle.vpcf",
            Ability = self,
            iMoveSpeed = self:GetSpecialValueFor("bolt_speed"),
            Source = self:GetCaster (),
            Target = self:GetCursorTarget (),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
        }

        ProjectileManager:CreateTrackingProjectile(info)

        EmitSoundOn ("Cap_Shield_Throw.Cast", self:GetCaster () )
    end
end

function cap_shield_clash:OnProjectileHit (hTarget, vLocation)
    if hTarget ~= nil and ( not hTarget:IsInvulnerable () ) and ( not hTarget:TriggerSpellAbsorb (self) ) and ( not hTarget:IsMagicImmune () ) then
        local nFXIndex = ParticleManager:CreateParticle("particles/stygian/captain_america_shield_impact10/soccer_ball/soccer_ball_impact.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl (nFXIndex, 0, hTarget:GetOrigin () )
        ParticleManager:ReleaseParticleIndex (nFXIndex)

        EmitSoundOn ("Cap_Shield_Strike.Impact", hTarget)

        local duration = self:GetSpecialValueFor("stun_duration") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_cap_1") or 0)

        hTarget:AddNewModifier(self:GetCaster (), self, "modifier_stunned", { duration = duration} )
        self:GetCaster():AddNewModifier(self:GetCaster (), self, "modifier_cap_shield_clash", { duration = self:GetSpecialValueFor("buff_duration")} )

        local damage = {
            victim = hTarget,
            attacker = self:GetCaster (),
            damage = self:GetAbilityDamage(),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }

        ApplyDamage (damage)
    end

    return true
end

modifier_cap_shield_clash = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_cap_shield_clash:IsHidden()
	return false
end

function modifier_cap_shield_clash:IsDebuff()
	return false
end

function modifier_cap_shield_clash:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cap_shield_clash:OnCreated( kv )
	-- references
	self.bonus = self:GetAbility():GetSpecialValueFor( "buff_damage_amp" ) -- special value
end

function modifier_cap_shield_clash:OnRefresh( kv )
	-- references
	self.bonus = self:GetAbility():GetSpecialValueFor( "buff_damage_amp" ) -- special value
end

function modifier_cap_shield_clash:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_cap_shield_clash:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end
function modifier_cap_shield_clash:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus
end

function modifier_cap_shield_clash:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_cap_shield_clash:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}

	return state
end
