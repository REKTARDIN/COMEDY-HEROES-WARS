medivh_dust_of_appearance = class({})

function medivh_dust_of_appearance:GetAssociatedSecondaryAbilities()
	return "medivh_fel_blast"
end

function medivh_dust_of_appearance:OnUpgrade()
     if IsServer() then
         local secondary_ability = self:GetCaster():FindAbilityByName("medivh_fel_blast")
 
         if secondary_ability and secondary_ability:GetLevel() ~= self:GetLevel() then
             secondary_ability:SetLevel(self:GetLevel())
          end
     end
end

function medivh_dust_of_appearance:OnSpellStart()
     if IsServer() then
          local radius = self:GetSpecialValueFor( "radius" ) 
          local duration = self:GetSpecialValueFor(  "duration" )
          local sound = "Medivh_DustofAppearance.Cast"
          local particle = "particles/items_fx/dust_of_appearance.vpcf"
          local pos = self:GetCursorPosition()
          local damage = 100
          
          if self:GetCaster():HasTalent("special_bonus_unique_medivh_3") then
               radius = radius + self:GetCaster():FindTalentValue("special_bonus_unique_medivh_3")
          end

          local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), pos, self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
          if #units > 0 then
               for _,unit in pairs(units) do
                    unit:AddNewModifier( self:GetCaster(), self, "modifier_item_dustofappearance", { duration = duration } )
               end
          end

          local nFXIndex = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, self:GetCaster())
          ParticleManager:SetParticleControl(nFXIndex, 0, pos)
          ParticleManager:SetParticleControl(nFXIndex, 2, Vector(radius, radius, 0))
          ParticleManager:SetParticleControl(nFXIndex, 5, pos)
        
          EmitSoundOn( sound, self:GetCaster() )
     end
end