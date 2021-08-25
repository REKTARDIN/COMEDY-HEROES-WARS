LinkLuaModifier ("modifier_rocket_explosive_shell", "abilities/rocket_explosive_shell.lua", 0)

if rocket_explosive_shell == nil then rocket_explosive_shell = class({}) end

function rocket_explosive_shell:OnAbilityPhaseStart()
	if IsServer() then
		local aim_duration = self:GetSpecialValueFor( "aim_duration" )
		local hTarget = self:GetCursorTarget()
        
        if hTarget ~= nil then
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_sniper_assassinate", { duration = aim_duration } )			
        end
        
		EmitSoundOn( "Ability.AssassinateLoad", self:GetCaster() )
	end

	return true
end

--------------------------------------------------------------------------------

function rocket_explosive_shell:OnAbilityPhaseInterrupted()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		if hTarget ~= nil then
			hTarget:RemoveModifierByName( "modifier_sniper_assassinate" )
		end
	end
end

--------------------------------------------------------------------------------

function rocket_explosive_shell:OnSpellStart()
	if IsServer() then
        self.bInBuckshot = false
        
        local hTarget = self:GetCursorTarget()
        
		if IsValidEntity(hTarget) and (not hTarget:TriggerSpellAbsorb(self)) then
            if self:GetCaster():HasModifier("modifier_rocket_reinforced_ammo") then
                self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_rocket_explosive_shell", {target = hTarget:entindex()})

                return
            end

            self:CreateProjectile(hTarget)
		end
	end
end

--------------------------------------------------------------------------------

function rocket_explosive_shell:CreateProjectile(target)
    ProjectileManager:CreateTrackingProjectile({
        EffectName = "particles/econ/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf";
        Target = target,
        Source = self:GetCaster(),
        Ability = self,
        iMoveSpeed = self:GetSpecialValueFor( "projectile_speed" )
    })

    EmitSoundOn( "Ability.Assassinate", self:GetCaster() )
    EmitSoundOn( "Hero_Sniper.AssassinateProjectile", self:GetCaster() )
end

--------------------------------------------------------------------------------

function rocket_explosive_shell:OnProjectileHit( hTarget, vLocation )
	if IsServer() then
		if hTarget ~= nil then
			hTarget:RemoveModifierByName( "modifier_sniper_assassinate" )
            if not hTarget:IsInvulnerable() then
                local damage_agi = self:GetCaster():GetAgility() * self:GetSpecialValueFor("agility_damage") / 100
                local shot_damage = self:GetSpecialValueFor( "assassinate_damage") + damage_agi
	
					local damage =
					{
						victim = hTarget,
						attacker = self:GetCaster(),
						ability = self,
						damage = shot_damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
					}

				ApplyDamage( damage )
				EmitSoundOn( "Hero_Sniper.AssassinateDamage_Scatter", hTarget )
			end
		end
	end
end

function rocket_explosive_shell:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end

if not modifier_rocket_explosive_shell then modifier_rocket_explosive_shell = class({}) end 

modifier_rocket_explosive_shell.m_iCounter = 3
modifier_rocket_explosive_shell.m_hTarget = nil

function modifier_rocket_explosive_shell:OnCreated(event)
    if IsServer() then
        self.m_iCounter = 3
        self.m_hTarget = EntIndexToHScript(event.target)

        self:StartIntervalThink(0.25)
        self:OnIntervalThink()
    end
end

function modifier_rocket_explosive_shell:OnIntervalThink()
    if IsServer() then
        self.m_iCounter = self.m_iCounter - 1

        if IsValidEntity(self.m_hTarget) then
            self:GetAbility():CreateProjectile(self.m_hTarget)
        end

        if self.m_iCounter <= 0 then
            self:Destroy()
            return
        end
    end
end
