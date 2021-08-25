item_bloodletter = class({})

LinkLuaModifier("modifier_item_bloodletter_passive", "items/item_bloodletter", LUA_MODIFIER_MOTION_NONE)

function item_bloodletter:GetIntrinsicModifierName()
    return "modifier_item_bloodletter_passive"
end

function item_bloodletter:OnSpellStart()

    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor ("berserk_duration")

    EmitSoundOn("DOTA_Item.MaskOfMadness.Activate", caster)
    caster:AddNewModifier(caster, self, "modifier_item_mask_of_madness_berserk", {duration = duration})
end
---------------------------------------------------------------------------------------------------------------------
modifier_item_bloodletter_passive = class({})

function modifier_item_bloodletter_passive:IsHidden() 
    return true 
end

function modifier_item_bloodletter_passive:IsPurgable() 
    return false 
end

function modifier_item_bloodletter_passive:IsPurgeException() 
    return false 
end

function modifier_item_bloodletter_passive:RemoveOnDeath() 
    return false 
end

function modifier_item_bloodletter_passive:GetAttributes() 
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_item_bloodletter_passive:DeclareFunctions()
    local func = 	{
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
    }
    return func
end

function modifier_item_bloodletter_passive:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_bloodletter_passive:GetModifierHealthBonus (params)
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_bloodletter_passive:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed_passive")
end

function modifier_item_bloodletter_passive:OnCreated(hTable)
    if IsServer() then 

    self.caster  = self:GetCaster()
    self.parent  = self:GetParent()
    self.ability = self:GetAbility()

    self.cleave_damage = self.parent:GetAverageTrueAttackDamage(self:GetParent()) * self.ability:GetSpecialValueFor("cleave_damage_percent") / 100
    self.cleave_radius = self.ability:GetSpecialValueFor("cleave_radius")

    self.lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal" )
    
    end
end

function modifier_item_bloodletter_passive:OnRefresh(hTable)
    self:OnCreated(hTable)
end

function modifier_item_bloodletter_passive:OnAttackLanded (params)
    if IsServer () then
        if params.attacker == self:GetParent() and not self.parent:IsRangedAttacker() then
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

function modifier_item_bloodletter_passive:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		-- filter
		local pass = false
		if params.target:GetTeamNumber()~=self:GetParent():GetTeamNumber() then
			if (not params.target:IsBuilding()) and (not params.target:IsOther()) then
				pass = true
			end
		end

		-- logic
		if pass then
			-- save attack record
			self.attack_record = params.record
		end
	end
end

function modifier_item_bloodletter_passive:OnTakeDamage( params )
	if IsServer() then
		-- filter
		local pass = false
		if self.attack_record and params.record == self.attack_record then
			pass = true
			self.attack_record = nil
		end

		-- logic
		if pass then
			-- get heal value
			local heal = params.damage * self.lifesteal/100
			self:GetParent():Heal( heal, self:GetAbility() )
			self:PlayEffects( self:GetParent() )
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_item_bloodletter_passive:PlayEffects( target )
	-- get resource
	local particle_cast = "particles/stygian/bloodletter_lifesteal.vpcf"

	-- play effects
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end