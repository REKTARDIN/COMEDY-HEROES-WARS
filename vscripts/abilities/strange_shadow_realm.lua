strange_shadow_realm = class({})

local GLOBAL = 999999

LinkLuaModifier ("modifier_strange_shadow_realm", "abilities/strange_shadow_realm.lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function strange_shadow_realm:CastFilterResultTarget( hTarget )
	if IsServer() then

		if hTarget ~= nil and hTarget:IsMagicImmune() and ( not self:GetCaster():HasScepter() ) then
			return UF_FAIL_MAGIC_IMMUNE_ENEMY
		end

		local nResult = UnitFilter( hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber() )
		return nResult
	end

	return UF_SUCCESS
end

--------------------------------------------------------------------------------

function strange_shadow_realm:GetCastRange( vLocation, hTarget )
	if self:GetCaster():HasScepter() then
		return GLOBAL
	end

	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end

--------------------------------------------------------------------------------

function strange_shadow_realm:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	if hTarget ~= nil then
		if ( not hTarget:TriggerSpellAbsorb( self ) ) then
            local duration = self:GetSpecialValueFor( "duration" )
            
            if self:GetCaster():HasTalent("special_bonus_unique_strange_2") then
                duration = duration + self:GetCaster():FindTalentValue("special_bonus_unique_strange_2")
            end

			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_strange_shadow_realm", { duration = duration } )
            
            EmitSoundOn( "Hero_Bane.Nightmare.End", hTarget )
        end
        
		EmitSoundOn( "Hero_Bane.Nightmare", self:GetCaster() )
	end
end


modifier_strange_shadow_realm = class ( {})

function modifier_strange_shadow_realm:IsHidden()
    return false
end

function modifier_strange_shadow_realm:IsDebuff()
    return self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber()
end

function modifier_strange_shadow_realm:IsPurgable()
    return false
end

function modifier_strange_shadow_realm:GetEffectName()
    return "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf"
end

function modifier_strange_shadow_realm:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_strange_shadow_realm:GetStatusEffectName()
    return "particles/status_fx/status_effect_templar_slow.vpcf"
end

function modifier_strange_shadow_realm:StatusEffectPriority()
    return 1000
end

function modifier_strange_shadow_realm:OnCreated(params)
    if IsServer () then
        self:StartIntervalThink(1)

        self.damage = self:GetAbility():GetAbilityDamage()

        if self:GetCaster():HasTalent("special_bonus_unique_strange_3") then
            self.damage = self.damage + self:GetCaster():FindTalentValue("special_bonus_unique_strange_3")
        end

        self.damage = self.damage + ((self:GetAbility():GetSpecialValueFor("bonus_current_mana") / 100) * self:GetCaster():GetMana())

        self:OnIntervalThink()
    end
end

function modifier_strange_shadow_realm:OnIntervalThink()
    if IsServer() then
        if self:GetParent():IsFriendly(self:GetCaster()) then
            self:GetParent():Heal(self.damage, self:GetAbility())
            SendOverheadEventMessage(  self:GetParent(), OVERHEAD_ALERT_HEAL,  self:GetParent(), self.damage, nil )
        else 
            self:GetParent():ModifyHealth(self:GetParent():GetHealth() - self.damage, self:GetAbility(), true, 0)
            SendOverheadEventMessage(  self:GetParent(), OVERHEAD_ALERT_DAMAGE,  self:GetParent(), self.damage, nil )
        end
    end
end

