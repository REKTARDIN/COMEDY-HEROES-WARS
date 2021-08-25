LinkLuaModifier( "modifier_doomslayer_destiny_debuff", "abilities/doomslayer_destiny.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_doomslayer_destiny_stack", "abilities/doomslayer_destiny.lua", LUA_MODIFIER_MOTION_NONE )

doomslayer_destiny = class({})

function doomslayer_destiny:OnSpellStart()
    if IsServer() then
        local hTarget = self:GetCursorTarget()

        if hTarget ~= nil and not hTarget:TriggerSpellAbsorb (self) then
            local duration = self:GetSpecialValueFor( "active_duration" )

            hTarget:AddNewModifier( self:GetCaster(), self, "modifier_doomslayer_destiny_debuff", { duration = duration } )

            EmitSoundOn( "Hero_DoomBringer.DevourCast", hTarget )
        end
    end
end

function doomslayer_destiny:OnHeroDiedNearby( hVictim, hKiller, kv )
	if hVictim == nil or hKiller == nil then
		return
	end

	if hVictim:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and self:GetCaster():IsAlive() then
		if hKiller == self:GetCaster()  then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_doomslayer_destiny_stack", {duration = self:GetSpecialValueFor("passive_stack_duration")})

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster() )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
end


modifier_doomslayer_destiny_debuff = class({})

function modifier_doomslayer_destiny_debuff:IsHidden()
	return false
end

function modifier_doomslayer_destiny_debuff:IsBuff()
	return false
end

function modifier_doomslayer_destiny_debuff:IsPurgable()
	return false
end

function modifier_doomslayer_destiny_debuff:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_doomslayer_destiny_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_doomslayer_destiny_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_pangolier_gyroshell.vpcf"
end

function modifier_doomslayer_destiny_debuff:StatusEffectPriority()
	return 1000
end

function modifier_doomslayer_destiny_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}

	return funcs
end

function modifier_doomslayer_destiny_debuff:GetModifierDamageOutgoing_Percentage (params)
    return self:GetAbility():GetSpecialValueFor("active_dmg_reduction") * (-1)
end

modifier_doomslayer_destiny_stack = class ( {})

function modifier_doomslayer_destiny_stack:IsPurgable()
    return false
end

function modifier_doomslayer_destiny_stack:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS
    }

    return funcs
end

function modifier_doomslayer_destiny_stack:GetModifierExtraStrengthBonus( params )
    return self:GetAbility():GetSpecialValueFor("strenght_bonus_hero") 
end

function modifier_doomslayer_destiny_stack:GetModifierPreAttack_BonusDamage( params )
    return self:GetAbility():GetSpecialValueFor("attack_damage_bonus_hero") 
end

function modifier_doomslayer_destiny_stack:GetAttributes ()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end
