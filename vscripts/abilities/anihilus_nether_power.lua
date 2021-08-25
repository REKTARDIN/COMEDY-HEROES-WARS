anihilus_nether_power = class({})
LinkLuaModifier( "modifier_anihilus_nether_power", "abilities/anihilus_nether_power", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function anihilus_nether_power:GetIntrinsicModifierName()
	return "modifier_anihilus_nether_power"
end

modifier_anihilus_nether_power = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_anihilus_nether_power:IsHidden()
	return true
end

function modifier_anihilus_nether_power:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_anihilus_nether_power:OnCreated( kv )
	-- references
	if IsServer() then
		local damage = self:GetAbility():GetSpecialValueFor("damage") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_anihilus_4") or 0) 

		-- precache damage
		self.damageTable = {
			-- victim = target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility(), --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}
	end
end

function modifier_anihilus_nether_power:OnRefresh( kv )
	if IsServer() then
        local damage = self:GetAbility():GetSpecialValueFor("damage") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_anihilus_4") or 0) 

		self.damageTable.damage = damage
	end
end

function modifier_anihilus_nether_power:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_anihilus_nether_power:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}

	return funcs
end

function modifier_anihilus_nether_power:GetModifierAttackRangeBonus( params )
	return self:GetAbility():GetSpecialValueFor("attack_range")
end


function modifier_anihilus_nether_power:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetCaster():PassivesDisabled() then return end
			if params.target:IsOther() or params.target:IsBuilding() then return end

			self.damageTable.victim = params.target
			
			ApplyDamage( self.damageTable )
			
			self:GetCaster():Heal(params.damage * (self:GetAbility():GetSpecialValueFor("vampirism") / 100), self:GetAbility())
		end
	end
end
