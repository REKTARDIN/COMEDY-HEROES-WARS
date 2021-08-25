medivh_cancel_raven_form = class({})

function medivh_cancel_raven_form:Spawn()
    if IsServer() then self:SetLevel(1) end
end

function medivh_cancel_raven_form:GetAssociatedPrimaryAbilities()
	return "medivh_raven_form"
end

function medivh_cancel_raven_form:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        
        caster:RemoveModifierByName("modifier_medivh_raven_form_buff")

		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/silencer/silencer_ti6/silencer_last_word_dmg_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
        ParticleManager:ReleaseParticleIndex( nFXIndex )

        EmitSoundOn("Medivh_Raven_Form.Cancel", caster)
	end
end