tzeentch_magic_beam = class({})

--------------------------------------------------------------------------------

function tzeentch_magic_beam:GetConceptRecipientType() return DOTA_SPEECH_USER_ALL end

--------------------------------------------------------------------------------

function tzeentch_magic_beam:SpeakTrigger() return DOTA_ABILITY_SPEAK_CAST end

--------------------------------------------------------------------------------

function tzeentch_magic_beam:GetChannelTime()
	return self:GetSpecialValueFor( "channel_time" )
end

--------------------------------------------------------------------------------

function tzeentch_magic_beam:OnAbilityPhaseStart()
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        EmitSoundOn( "Hero_Tinker.March_of_the_Machines.Cast.Rollermawster", self:GetCaster() )
	end

	return true
end

--------------------------------------------------------------------------------

function tzeentch_magic_beam:Start()
	local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
    vDirection = vDirection:Normalized()
    
    local range = self:GetCastRange( self:GetCaster():GetOrigin(), self:GetCaster() )
    local vPoint = self:GetCaster():GetAbsOrigin() + vDirection * range

	self.speed = self:GetSpecialValueFor( "speed" )
    self.width = self:GetSpecialValueFor( "widgth" )
	self.damage = self:GetSpecialValueFor( "damage" ) + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_tzeentch_1") or 0)

    local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/tinker/tinker_ti10_immortal_laser/tinker_ti10_immortal_laser.vpcf", PATTACH_CUSTOMORIGIN, nil );
    ParticleManager:SetParticleControlEnt( nFXIndex, 9, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true );
    ParticleManager:SetParticleControl( nFXIndex, 1, vPoint + Vector(0, 0, 96) );
    ParticleManager:ReleaseParticleIndex( nFXIndex );

    local enemies = FindUnitsInLine(
        self:GetCaster():GetTeamNumber(),	-- int, your team number
        self:GetCaster():GetOrigin(),	-- point, start point
        vPoint,	-- point, end point
        nil,	-- handle, cacheUnit. (not known)
        self.width,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES	-- int, flag filter
    )

    for _,enemy in pairs(enemies) do      
        EmitSoundOn( "Hero_Tinker.LaserImpact" , self:GetCaster() )

        local damage = {
			victim = enemy,
			attacker = self:GetCaster(),
			damage = self.damage + (enemy:GetMana() * self:GetSpecialValueFor("current_mana_damage")),
			damage_type = self:GetAbilityDamageType(),
            ability = self,
            damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
		}

        ApplyDamage( damage )
    end

    for i = 10, range / 10 do
        GridNav:DestroyTreesAroundPoint(self:GetCaster():GetAbsOrigin() + vDirection * i * 10, self.width, false)
    end

    EmitSoundOn( "Ability.PreLightStrikeArray.ti7" , self:GetCaster() )
    EmitSoundOn( "Hero_Tinker.LaserAnim" , self:GetCaster() )
    EmitSoundOn( "Hero_Tinker.Laser " , self:GetCaster() )
end


--------------------------------------------------------------------------------

function tzeentch_magic_beam:OnChannelFinish( bInterrupted )
	if not bInterrupted then
		self:Start()
	end
end
