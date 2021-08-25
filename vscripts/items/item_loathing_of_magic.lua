LinkLuaModifier ("modifier_item_loathing_of_magic", "items/item_loathing_of_magic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_item_loathing_of_magic_active", "items/item_loathing_of_magic.lua", LUA_MODIFIER_MOTION_NONE)

if item_loathing_of_magic == nil then
    item_loathing_of_magic = class ( {})
end

local CONST_MAX_LEVEL = 1 -- СЮДА МАКСИМАЛЬНЫЙ УРОВЕНЬ ПРЕДМЕТА ИЗ КВ!!!

function item_loathing_of_magic:GetBehavior() return DOTA_ABILITY_BEHAVIOR_NO_TARGET end
function item_loathing_of_magic:GetIntrinsicModifierName() return "modifier_item_loathing_of_magic" end

function item_loathing_of_magic:Spawn()
	if IsServer() then
		self:SetLevel(CONST_MAX_LEVEL) ---- СПАВНИМ ИЗНАЧАЛЬНО С МАКС УРОВНЕМ
	end
end

function item_loathing_of_magic:OnSpellStart(  )
    if IsServer() then
        self:GetCaster():Purge(false, true, false, true, true) 

        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_loathing_of_magic_active", {duration = self:GetSpecialValueFor("duration")})
        
		EmitSoundOn("DOTA_Item.ArcaneRing.Cast", self:GetCaster())
        EmitSoundOn("Blink_Layer.Arcane", self:GetCaster())
		
		if self:GetLevel() >= 1 and self:GetLevel() ~= 6 then 
			self:SetLevel(self:GetLevel() + 1) ---- УСМТАНАВЛИВАЕМ ТЕКУЩИЙ УРОВЕНЬ - 1 если уровень уже не минимальный
		end
    end
end

if modifier_item_loathing_of_magic == nil then
    modifier_item_loathing_of_magic = class ( {})
end

function modifier_item_loathing_of_magic:IsHidden() return true end
function modifier_item_loathing_of_magic:IsPurgable() return false end

function modifier_item_loathing_of_magic:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }

    return funcs
end

function modifier_item_loathing_of_magic:GetModifierPreAttack_BonusDamage (params) return self:GetAbility():GetSpecialValueFor ("bonus_damage") end
function modifier_item_loathing_of_magic:GetModifierBonusStats_Strength (params) return self:GetAbility():GetSpecialValueFor("bonus_strength") end

modifier_item_loathing_of_magic_active = class({})

function modifier_item_loathing_of_magic_active:IsHidden() return false end
function modifier_item_loathing_of_magic_active:IsDebuff() return false end
function modifier_item_loathing_of_magic_active:IsPurgable() return false end
function modifier_item_loathing_of_magic_active:IsPurgeException() return false end
function modifier_item_loathing_of_magic_active:RemoveOnDeath() return true end
function modifier_item_loathing_of_magic_active:CheckState() return {[MODIFIER_STATE_MAGIC_IMMUNE] = true} end
function modifier_item_loathing_of_magic_active:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_SCALE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_item_loathing_of_magic_active:GetModifierModelScale() return self:GetAbility():GetSpecialValueFor("model_scale") end
function modifier_item_loathing_of_magic_active:GetModifierMagicalResistanceBonus() return self:GetAbility():GetSpecialValueFor("magical_resistance") end

function modifier_item_loathing_of_magic_active:OnCreated()

end

function modifier_item_loathing_of_magic_active:OnRefresh()
	self:OnCreated()
end

function modifier_item_loathing_of_magic_active:GetEffectName() return "particles/stygian/hells_glare_rage.vpcf" end
function modifier_item_loathing_of_magic_active:GetStatusEffectName() return "particles/stygian/loathing_status.vpcf" end
function modifier_item_loathing_of_magic_active:StatusEffectPriority() return 10 end
function modifier_item_loathing_of_magic_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end


