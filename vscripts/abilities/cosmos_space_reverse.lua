cosmos_space_reverse = class({})

--------------------------------------------------------------------------------

function cosmos_space_reverse:OnAbilityPhaseStart()
    if IsServer() then
        self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( self.nFXIndex, 3, self:GetCaster():GetOrigin() )
        ParticleManager:SetParticleControlForward(self.nFXIndex, 3, (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized())
        ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector(170, 1, 1) )
        ParticleManager:SetParticleControl( self.nFXIndex, 2, Vector(self:GetCastPoint(), 0, 0) )

        EmitSoundOn( "Hero_SkywrathMage.ChickenTauntClap", self:GetCaster() )

        return true
    end
end

function cosmos_space_reverse:OnAbilityPhaseInterrupted()
    if IsServer() then
        if self.nFXIndex then
            ParticleManager:DestroyParticle(self.nFXIndex, true)
        end
    end
end

function cosmos_space_reverse:OnSpellStart() 
    local dir = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized()
    local width = self:GetSpecialValueFor( "widgth" ) 
    local vDest = self:GetCaster():GetAbsOrigin() + dir * 128.0
    
	local duration = self:GetSpecialValueFor(  "hero_stun_duration" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_desaad_4") or 0)

    local vStartPos = self:GetCaster():GetOrigin()
    local vEndPos = vStartPos + dir * self:GetSpecialValueFor("range")

    local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
    local types = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
    local flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE

    local units = FindUnitsInLine(self:GetCaster():GetTeam(), vStartPos, vEndPos, nil, width, teams, types, flags)

    -- Make the found units move to (0, 0, 0)
    for _,unit in pairs(units) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = duration})

        local damage = {
            victim = unit,
            attacker = self:GetCaster(),
            damage = self:GetSpecialValueFor("polarity_damage"),
            damage_type = self:GetAbilityDamageType(),
            ability = self,
        }

        ApplyDamage( damage )

        EmitSoundOn("", unit)

        FindClearSpaceForUnit(unit, vDest, true)
    end

    EmitSoundOn("Hero_Enigma.Death", self:GetCaster())
end


function cosmos_space_reverse:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "scepter_cooldown" )
	end

	return self.BaseClass.GetCooldown( self, iLevel )
end
