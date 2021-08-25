flash_scaner = class({})

LinkLuaModifier("modifier_flash_scaner", "abilities/flash_scaner.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flash_scaner_debuff", "abilities/flash_scaner.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flash_scaner_speed", "abilities/flash_scaner.lua", LUA_MODIFIER_MOTION_NONE)

function flash_scaner:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function flash_scaner:GetIntrinsicModifierName()
    return "modifier_flash_scaner_speed"
end

function flash_scaner:OnOwnerDied()
    if IsServer() then
        local buff = self:GetCaster():FindModifierByName("modifier_flash_scaner_speed")
        buff:SetStackCount(0)
	end
end

function flash_scaner:Spawn()
    if IsServer() then self:SetLevel(1) end
end

function flash_scaner:OnSpellStart()
	local hTarget = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor( "duration" )
        
        hTarget:AddNewModifier( self:GetCaster(), self, "modifier_flash_scaner", { duration = duration } )

        local nFXIndex = ParticleManager:CreateParticle( "particles/items_fx/dust_of_appearance_true_sight.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
        ParticleManager:SetParticleControl( nFXIndex, 0, hTarget:GetOrigin() )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
        
	EmitSoundOn( "minimap_radar.target", hTarget )
end
---------------------------------------------------------------------------------------------------------------------
modifier_flash_scaner = class({})
function modifier_flash_scaner:IsHidden() return false end
function modifier_flash_scaner:IsDebuff() return false end
function modifier_flash_scaner:IsPurgable() return false end
function modifier_flash_scaner:IsPurgeException() return false end
function modifier_flash_scaner:RemoveOnDeath() return false end
function modifier_flash_scaner:IsAura() return true end
function modifier_flash_scaner:IsAuraActiveOnDeath() return false end

function modifier_flash_scaner:GetAuraRadius()
    return self.radius
end

function modifier_flash_scaner:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_flash_scaner:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_flash_scaner:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_flash_scaner:GetModifierAura()
    return "modifier_flash_scaner_debuff"
end

function modifier_flash_scaner:OnCreated()
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.radius = self.ability:GetSpecialValueFor( "radius" )
    self.radius_invisibility = self.ability:GetSpecialValueFor("radius_invisibility") * self.radius * 0.01

    if IsServer() then
    end
end
function modifier_flash_scaner:OnRefresh(table)
    self:OnCreated(table)
end
function modifier_flash_scaner:OnIntervalThink()
    if IsServer() then

    end
end
---------------------------------------------------------------------------------------------------------------------
modifier_flash_scaner_debuff = class({})
function modifier_flash_scaner_debuff:IsHidden() return false end
function modifier_flash_scaner_debuff:IsDebuff() return true end
function modifier_flash_scaner_debuff:IsPurgable() return true end
function modifier_flash_scaner_debuff:IsPurgeException() return true end
function modifier_flash_scaner_debuff:RemoveOnDeath() return true end
function modifier_flash_scaner_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_flash_scaner_debuff:DeclareFunctions()
    local func = {  MODIFIER_PROPERTY_PROVIDES_FOW_POSITION, }
    return func
end
function modifier_flash_scaner_debuff:GetModifierProvidesFOWVision(params)
    if self.caster:GetTeamNumber() == params.target:GetTeamNumber() then
        return 1
    end
end
function modifier_flash_scaner_debuff:OnCreated(table)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    if IsServer() then
    end
end
function modifier_flash_scaner_debuff:OnRefresh(table)
    self:OnCreated(table)
end
function modifier_flash_scaner_debuff:OnIntervalThink()
    if IsServer() then
    end
end

modifier_flash_scaner_speed= class({})

function modifier_flash_scaner_speed:IsPurgable()	return false end
function modifier_flash_scaner_speed:IsHidden()	return false end
function modifier_flash_scaner_speed:RemoveOnDeath() return false end
function modifier_flash_scaner_speed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end


function modifier_flash_scaner_speed:GetModifierMoveSpeedBonus_Constant() return self:GetStackCount() * 1 end

function modifier_flash_scaner_speed:OnCreated()
    if IsServer() and self:GetParent():IsAlive() then
    self:StartIntervalThink(3.0) 
end
    
function modifier_flash_scaner_speed:OnIntervalThink()
    if IsServer() and self:GetParent():IsAlive() then
			self:SetStackCount(self:GetStackCount() + 1)
		end
	end
end