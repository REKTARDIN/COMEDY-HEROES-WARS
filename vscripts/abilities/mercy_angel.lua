mercy_angel = class({})

local GLOBAL = 999999

function mercy_angel:GetCastRange( vLocation, hTarget )
	if self:GetCaster():HasModifier("modifier_mercy_valkyri") then
		return GLOBAL
	end

	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end

function mercy_angel:OnSpellStart()
    if IsServer() then
        local target = self:GetCursorTarget()

        EmitSoundOn( "Hero_Wisp.TeleportIn", self:GetCaster() )

        local victim_angle = target:GetAnglesAsVector()
        local victim_forward_vector = target:GetForwardVector()
        local victim_angle_rad = victim_angle.y*math.pi/180
        local victim_position = target:GetAbsOrigin()
        local attacker_new = Vector(victim_position.x - 100 * math.cos(victim_angle_rad), victim_position.y - 100 * math.sin(victim_angle_rad), 0)

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_CUSTOMORIGIN, nil );
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true );
        ParticleManager:ReleaseParticleIndex( nFXIndex );

        self:GetCaster():SetAbsOrigin(attacker_new)
        FindClearSpaceForUnit(self:GetCaster(), attacker_new, true)
        self:GetCaster():SetForwardVector(victim_forward_vector)

        EmitSoundOn("Hero_Wisp.Death", target)
        
        local heal = self:GetSpecialValueFor("heal_hp")

        if target:GetHealthPercent() <= self:GetSpecialValueFor("heal_cap") then
            heal = heal * 2
        end

        local val = target:GetMaxHealth() * (heal / 100)

        target:Heal(val, self)

        SendOverheadEventMessage(  target, OVERHEAD_ALERT_HEAL,  target, val, nil )
    end
end
