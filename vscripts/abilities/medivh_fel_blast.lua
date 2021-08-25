medivh_fel_blast = class({})

function medivh_fel_blast:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function medivh_fel_blast:GetAssociatedSecondaryAbilities()
	return "medivh_dust_of_appearance"
end

function medivh_fel_blast:OnSpellStart()
	local duration = 0.5
	local pos = self:GetCaster():GetCursorPosition()
	local radius = self:GetSpecialValueFor( "radius" )
	local buff = self:GetCaster():FindModifierByName("modifier_medivh_dark_magician")
    local magician_stack_damage = buff:GetStackCount() * 5
	local damage = self:GetSpecialValueFor("damage") + magician_stack_damage

	local targets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(),
		pos, 
		self:GetCaster(), 
		self:GetAOERadius(), 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 
		0, 
		false 
	)

	if #targets > 0 then
		for _,target in pairs(targets) do
			target:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = duration } )
			ApplyDamage({attacker = self:GetCaster(), victim = target, damage = damage, ability = self, damage_type = DAMAGE_TYPE_PURE})
		end
	end
	
	EmitSoundOn("Medivh_FelBlast.Cast", self:GetCaster())

	local nFXIndex = ParticleManager:CreateParticle("particles/stygian/medivh_sargeras_explosion/gold_call.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(nFXIndex, 0, pos)
    ParticleManager:SetParticleControl(nFXIndex, 2, Vector(radius, radius, 0))
    ParticleManager:SetParticleControl(nFXIndex, 5, pos)
end


