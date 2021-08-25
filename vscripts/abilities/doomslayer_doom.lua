doomslayer_doom = class({})
LinkLuaModifier( "modifier_doomslayer_doom", "abilities/doomslayer_doom.lua",LUA_MODIFIER_MOTION_NONE )

local FIXED_RANGE = 200

doomslayer_doom.weapons = {}
doomslayer_doom.weapons[0] = nil
doomslayer_doom.weapons[1] = nil
doomslayer_doom.weapons[2] = nil

function doomslayer_doom:IsStealable() return false end
function doomslayer_doom:IsRefreshable() return false end

function doomslayer_doom:GetManaCost(iLevel)
	return self:GetCaster():GetMana() * ((self:GetSpecialValueFor("mana_cost_ptc") - (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_doomslayer_1") or 0)) / 100) + 25
end

function doomslayer_doom:SwawAbils(onEnd)
	
end

function doomslayer_doom:SwitchShotgun()
	self.weapons[0]:AddEffects(EF_NODRAW)
	self.weapons[1]:AddEffects(EF_NODRAW)
	self.weapons[2]:AddEffects(EF_NODRAW)

	self.weapons[0]:RemoveEffects(EF_NODRAW)
end

function doomslayer_doom:SwitchSword()
	self.weapons[0]:AddEffects(EF_NODRAW)
	self.weapons[1]:AddEffects(EF_NODRAW)
	self.weapons[2]:AddEffects(EF_NODRAW)

	self.weapons[1]:RemoveEffects(EF_NODRAW)
	self.weapons[2]:RemoveEffects(EF_NODRAW)
end

function doomslayer_doom:OnSpawnedForFirstTime()
	if IsServer() then
		local shotgun = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_doomslayer/weapons/shotgun.vmdl"})
		shotgun:FollowEntity(self:GetCaster(), true)

		self.weapons[0] = shotgun

		local sword = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_doomslayer/weapons/sword/sword.vmdl"})
		sword:FollowEntity(self:GetCaster(), true)

		self.weapons[1] = sword

		local fxCore = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_doomslayer/weapons/sword/sword_core.vmdl"})
		fxCore:FollowEntity(self:GetCaster(), true)

		self.weapons[2] = fxCore

		self.weapons[1]:AddEffects(EF_NODRAW)
		self.weapons[2]:AddEffects(EF_NODRAW)
	end
end

--------------------------------------------------------------------------------
function doomslayer_doom:OnUpgrade()
	if IsServer() then
		self:GetCaster():GetAbilityByIndex(3):SetLevel(self:GetLevel())
		self:GetCaster():GetAbilityByIndex(4):SetLevel(self:GetLevel())
	end
end

function doomslayer_doom:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function doomslayer_doom:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_doomslayer_doom", nil )

		if not self:GetCaster():IsChanneling() then
			self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_6 )
		end

		EmitSoundOn("Doomslayer.Doom", self:GetCaster())
	else
		local hRotBuff = self:GetCaster():FindModifierByName( "modifier_doomslayer_doom" )
		if hRotBuff ~= nil then
			hRotBuff:Destroy()
		end
	end
end

if modifier_doomslayer_doom == nil then modifier_doomslayer_doom = class({}) end

modifier_doomslayer_doom.damage_ptc = 0

function modifier_doomslayer_doom:IsHidden() return true end
function modifier_doomslayer_doom:IsDebuff() return false end

function modifier_doomslayer_doom:OnCreated(params)
	if IsServer() then
		self:GetAbility():SwitchSword()

		self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		self:GetParent():SetRangedProjectileName("")

		self.damage_ptc = (self:GetAbility():GetSpecialValueFor("damage_ptc") + (IsHasTalent(self:GetCaster():GetPlayerOwnerID(), "special_bonus_unique_doomslayer_2") or 0)) / 100
		self.attack_range = self:GetParent():GetBaseAttackRange()

		self:StartIntervalThink(1)
		self:OnIntervalThink()

		self:GetAbility():SwawAbils(false)
	end
end

function modifier_doomslayer_doom:OnIntervalThink()
	if IsServer() then
		self:IncrementStackCount()

		self:GetAbility():PayManaCost()

		if not self:GetAbility():IsOwnersManaEnough() then
			self:GetAbility():ToggleAbility()
		end
	end
end

function modifier_doomslayer_doom:OnDestroy()
	if IsServer() then
		self:GetAbility():SwitchShotgun()

		self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

		local cooldown = self:GetAbility():GetSpecialValueFor("base_cooldown")

		if self:GetCaster():HasTalent("special_bonus_unique_doomslayer_3") then
			cooldown = self:GetCaster():FindTalentValue("special_bonus_unique_doomslayer_3")
		end

		self:GetParent():SetRangedProjectileName("particles/units/heroes/hero_sniper/sniper_assassinate.vpcf")

		cooldown = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("cooldown_mult")

		self:GetAbility():StartCooldown(cooldown)

		self:GetAbility():SwawAbils(true)
	end
end

function modifier_doomslayer_doom:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_EVENT_ON_MANA_GAINED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE
	}
	return funcs
end

function modifier_doomslayer_doom:GetEffectName()
	return "particles/ironman/iron_devil_ambient/nullifier_mute_debuff.vpcf"
end

function modifier_doomslayer_doom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_doomslayer_doom:GetActivityTranslationModifiers( params )
	return "melee"
end

function modifier_doomslayer_doom:GetAttackSound( params )
	return "Hero_Mars.Attack"
end

function modifier_doomslayer_doom:GetModifierAttackRangeOverride( params )
	return FIXED_RANGE
end

function modifier_doomslayer_doom:OnManaGained( params )
	if IsServer() and params.unit == self:GetParent() then
		self:GetParent():SpendMana(params.gain, self:GetAbility())
	end
end

function modifier_doomslayer_doom:GetModifierProcAttack_BonusDamage_Pure( params )
	if IsServer() and params.attacker == self:GetParent() and not (params.target:IsBuilding() or params.target:IsTower()) then
		self:IncrementStackCount() --- Атака произведена, увеличиваем стаки
		
		ParticleManager:CreateParticle( "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_manaburn_basher_ti_5_b_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )

		return self.damage_ptc * self:GetCaster():GetMaxHealth()
	end

	return 0
end


