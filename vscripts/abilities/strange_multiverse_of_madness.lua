strange_multiverse_of_madness = class({})

LinkLuaModifier( "modifier_strange_multiverse_of_madness_shadow_clone", "abilities/strange_multiverse_of_madness", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_strange_multiverse_of_madness_debuff", "abilities/strange_multiverse_of_madness", LUA_MODIFIER_MOTION_BOTH )

--------------------------------------------------------------------------------

function strange_multiverse_of_madness:GetConceptRecipientType() return DOTA_SPEECH_USER_ALL end
function strange_multiverse_of_madness:SpeakTrigger() return DOTA_ABILITY_SPEAK_CAST end

--------------------------------------------------------------------------------

function strange_multiverse_of_madness:GetChannelTime()
	return self:GetSpecialValueFor("spell_channel_time")
end

--------------------------------------------------------------------------------

function strange_multiverse_of_madness:OnAbilityPhaseStart()
	if IsServer() then
		self.hVictim = self:GetCursorTarget()
	end

	return true
end

--------------------------------------------------------------------------------

function strange_multiverse_of_madness:OnSpellStart()
    if IsServer() then
        if self.hVictim == nil then
            return
        end

        if self.hVictim:TriggerSpellAbsorb( self ) then
            self.hVictim = nil
            self:GetCaster():Interrupt()
        else
            self:CreateShadowClones()   
            self.hVictim:AddNewModifier( self:GetCaster(), self, "modifier_strange_multiverse_of_madness_debuff", { duration = self:GetChannelTime() } )
            self.hVictim:Interrupt()

            EmitSoundOn("Hero_Bane.FiendsGrip.Cast", self.hVictim)
        end
    end
end

function strange_multiverse_of_madness:CreateShadowClones()
    if IsServer() then
        local pos = self.hVictim:GetAbsOrigin()
        
        local radius = 500

        for i = 0, 10 do
            local angle = i * 3.14159274 * 2 / 11
            local newPos = pos + Vector(math.cos(angle) * radius, math.sin(angle) * radius, pos.z)

            local clone = CreateUnitByName( "npc_dota_strange_shadow_clone_remnant", newPos, true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber())
            clone:AddNewModifier( self:GetCaster(), self, "modifier_strange_multiverse_of_madness_shadow_clone", { duration = self:GetChannelTime(), target = self.hVictim:entindex() } )
            clone:StartGesture(ACT_DOTA_CHANNEL_ABILITY_6)

            local direction = (pos - clone:GetAbsOrigin()):Normalized()
            
            clone:SetForwardVector(direction)
        end
    end
end

--------------------------------------------------------------------------------

function strange_multiverse_of_madness:OnChannelFinish( bInterrupted )
	if self.hVictim ~= nil then
        self.hVictim:RemoveModifierByName( "modifier_strange_multiverse_of_madness_debuff" )
	end
end

modifier_strange_multiverse_of_madness_debuff = class ( {})

function modifier_strange_multiverse_of_madness_debuff:IsHidden()
    return true
end

function modifier_strange_multiverse_of_madness_debuff:IsPurgable()
    return false
end

function modifier_strange_multiverse_of_madness_debuff:GetStatusEffectName()
    return "particles/econ/items/juggernaut/jugg_arcana/status_effect_jugg_arcana_omni.vpcf"
end

function modifier_strange_multiverse_of_madness_debuff:StatusEffectPriority()
    return 1000
end

function modifier_strange_multiverse_of_madness_debuff:OnCreated()
    if IsServer () then
        self:StartIntervalThink(1)
        self:OnIntervalThink()

        EmitSoundOn("Hero_Bane.FiendsGrip", self:GetParent())
    end
end

function modifier_strange_multiverse_of_madness_debuff:OnIntervalThink()
    if IsServer() then
        local ptc = self:GetAbility():GetSpecialValueFor("ptc_damage_per_second")

        if self:GetCaster():HasTalent("special_bonus_unique_strange_1") then
            ptc = ptc + self:GetCaster():FindTalentValue("special_bonus_unique_strange_1")
        end

        local damage = self:GetAbility():GetSpecialValueFor("damage") + (self:GetParent():GetMaxHealth() * (ptc / 100))
        ApplyDamage({victim = self:GetParent(), attacker = self:GetAbility():GetCaster(), ability = self:GetAbility(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
    end
end

function modifier_strange_multiverse_of_madness_debuff:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true,
    }
end

modifier_strange_multiverse_of_madness_shadow_clone = class({})

function modifier_strange_multiverse_of_madness_shadow_clone:IsHidden()  return true end
function modifier_strange_multiverse_of_madness_shadow_clone:IsPurgable()  return false end

function modifier_strange_multiverse_of_madness_shadow_clone:OnDestroy(  )
    if IsServer() then
        UTIL_Remove(self:GetParent())
    end
end

function modifier_strange_multiverse_of_madness_shadow_clone:OnCreated(params)
    if IsServer() then
        self:StartIntervalThink(0.1)

        local target = EntIndexToHScript(params.target)

        local nFXIndex = ParticleManager:CreateParticle( "particles/stygian/strange_multiverse_shackles.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )

        ParticleManager:SetParticleControlEnt( nFXIndex, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetOrigin(), true )
        self:AddParticle( nFXIndex, false, false, -1, false, true )
    end
end

function modifier_strange_multiverse_of_madness_shadow_clone:OnIntervalThink()
    if IsServer() then
        if not self:GetCaster():IsChanneling() then
            self:Destroy()
        end
    end
end

function modifier_strange_multiverse_of_madness_shadow_clone:GetEffectName()
    return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end

function modifier_strange_multiverse_of_madness_shadow_clone:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_strange_multiverse_of_madness_shadow_clone:GetStatusEffectName()
    return "particles/econ/items/effigies/status_fx_effigies/status_effect_vr_desat_stone.vpcf"
end

function modifier_strange_multiverse_of_madness_shadow_clone:StatusEffectPriority()
    return 1000
end

function modifier_strange_multiverse_of_madness_shadow_clone:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_DISARMED] = true
    }
end
