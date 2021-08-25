if not collector_soul_leak then collector_soul_leak = class({}) end

LinkLuaModifier ("modifier_collector_soul_leak", "abilities/collector_soul_leak.lua", LUA_MODIFIER_MOTION_NONE)

function collector_soul_leak:OnSpellStart()
    if IsServer() then
        local hTarget = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_collector_2") or 0)
        
        if hTarget ~= nil then
            if ( not hTarget:TriggerSpellAbsorb( self ) ) then
                EmitSoundOn("Hero_KeeperOfTheLight.ManaLeak.Cast", hTarget)

                hTarget:AddNewModifier(self:GetCaster(), self, "modifier_collector_soul_leak", {duration = duration})
            end
        end
    end
end

if modifier_collector_soul_leak == nil then modifier_collector_soul_leak = class({}) end


function modifier_collector_soul_leak:GetHeroEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_mana_leak.vpcf"
end

function modifier_collector_soul_leak:GetStatusEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf"
end

--------------------------------------------------------------------------------

function modifier_collector_soul_leak:StatusEffectPriority()
	return 1000
end

function modifier_collector_soul_leak:HeroEffectPriority()
	return 1000
end


function modifier_collector_soul_leak:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_UNIT_MOVED
    }

    return funcs
end

function modifier_collector_soul_leak:OnCreated(params)
    if IsServer() then 
        self._iDistance = 0
        self._vPosition = self:GetParent():GetAbsOrigin()
        self._flManaLeak = (self:GetAbility():GetSpecialValueFor("mana_leak_pct") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_collector_3") or 0)) / 100

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_keeper_of_the_light/keeper_mana_leak.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() );
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin());
		self:AddParticle(nFXIndex, false, false, -1, false, false)
    end 
end

function modifier_collector_soul_leak:OnUnitMoved(params)
	if IsServer() then 
        if params.unit == self:GetParent() then 
			if self._vPosition ~= self:GetParent():GetAbsOrigin() then 
				local distance = (self:GetParent():GetAbsOrigin() - self._vPosition):Length2D()

				self._vPosition = self:GetParent():GetAbsOrigin()

				self:OnPositionChanged(distance)
			end 			
		end
	end 
end

function modifier_collector_soul_leak:OnPositionChanged( distance )
    if IsServer() then 
        local mana_leak = distance * self._flManaLeak
        
        self:GetParent():SpendMana(mana_leak, self:GetAbility())

        if self:GetParent():GetMana() <= 0 then
            ApplyDamage({
                victim = self:GetParent(),
                attacker = self:GetCaster(),
                damage = self:GetAbility():GetAbilityDamage(),
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self:GetAbility()
            })

            self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = 0.5})
            self:Destroy()
        end
	end
end

function modifier_collector_soul_leak:IsHidden() return true end
function modifier_collector_soul_leak:IsPurgable() return false end
function modifier_collector_soul_leak:RemoveOnDeath() return true end