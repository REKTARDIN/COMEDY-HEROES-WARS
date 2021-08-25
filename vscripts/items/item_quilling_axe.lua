item_quilling_axe = class({})

LinkLuaModifier("modifier_item_quilling_axe", "items/item_quilling_axe", LUA_MODIFIER_MOTION_NONE)

function item_quilling_axe:GetIntrinsicModifierName()
    return "modifier_item_quilling_axe"
end

---------------------------------------------------------------------------------------------------------------------
modifier_item_quilling_axe = class({})

function modifier_item_quilling_axe:IsHidden() 
    return true 
end

function modifier_item_quilling_axe:IsPurgable() 
    return false 
end

function modifier_item_quilling_axe:IsPurgeException() 
    return false 
end

function modifier_item_quilling_axe:RemoveOnDeath() 
    return false 
end

function modifier_item_quilling_axe:GetAttributes() 
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_quilling_axe:DeclareFunctions()
    local func = 	{
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
        MODIFIER_EVENT_ON_ATTACK_LANDED   
    }
    return func
end

function modifier_item_quilling_axe:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_quilling_axe:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_quilling_axe:OnCreated(hTable)
    if IsServer() then 

    self.caster  = self:GetCaster()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    self.cleave_damage = self.parent:GetAverageTrueAttackDamage(self:GetParent()) * self.ability:GetSpecialValueFor("cleave_damage_percent") / 100
    self.cleave_radius = self.ability:GetSpecialValueFor("cleave_radius")

    self.MeleeBonusCreepDamage  = self.ability:GetSpecialValueFor("quelling_bonus")
    self.RangedBonusCreepDamage = self.ability:GetSpecialValueFor("quelling_bonus_ranged")
    
    end
end

function modifier_item_quilling_axe:OnRefresh(hTable)
    self:OnCreated(hTable)
end


function modifier_item_quilling_axe:GetModifierProcAttack_BonusDamage_Physical(params)
    if IsServer()
        and self.parent ~= nil 
        and self.parent:IsRealHero() then

        local hTarget = params.target

        if hTarget ~= nil and hTarget:IsCreep() then 

        return self.parent:IsRangedAttacker()
            and self.RangedBonusCreepDamage
        or self.MeleeBonusCreepDamage
        end
    end
end

function modifier_item_quilling_axe:OnAttackLanded (params)
    if IsServer () then
        if params.attacker == self:GetParent () then
            local hTarget = params.target

            local nFXIndex = ParticleManager:CreateParticle("particles/stygian/bloodletter_cleave.vpcf",PATTACH_ABSORIGIN_FOLLOW, hTarget)
			ParticleManager:SetParticleControl(nFXIndex,1,hTarget:GetAbsOrigin())
			ParticleManager:SetParticleControl(nFXIndex,2,Vector(self.cleave_radius*1.2,0,0))
			ParticleManager:ReleaseParticleIndex(nFXIndex)
           
            local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), 
            self:GetCaster():GetOrigin(), 
            hTarget, 
            self.cleave_radius, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
            0,
            0, 
            false)

            if #units > 0 then
                for _,unit in pairs(units) do
					if hTarget ~= unit then
						local damage = self.cleave_damage 

						ApplyDamage ( {
							victim = unit,
							attacker = self:GetCaster(),
							damage = damage,
							damage_type = DAMAGE_TYPE_PHYSICAL,
							ability = self:GetAbility()
						})
					end
                end
            end
        end
    end 
end
