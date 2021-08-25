mercy_caduceus = class({})

LinkLuaModifier( "modifier_mercy_caduceus",   "abilities/mercy_caduceus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_mercy_caduceus_mode",   "abilities/mercy_caduceus.lua", LUA_MODIFIER_MOTION_NONE)

local STACKS_MODE_HEAL = 0
local STACKS_MODE_DAMAGE = 1

mercy_caduceus.m_hMod = nil

function mercy_caduceus:GetIntrinsicModifierName()
   return "modifier_mercy_caduceus_mode"
end

function mercy_caduceus:CastFilterResultTarget( hTarget )
	if self:GetCaster() == hTarget then
		return UF_FAIL_CUSTOM
    end
    
	local nResult = UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetCaster():GetTeamNumber() )
    
    if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end
function mercy_caduceus:Clean()
    local heroes = HeroList:GetAllHeroes()
    for i, hero in pairs(heroes) do
        if hero:HasModifier( "modifier_mercy_caduceus" ) then
            hero:FindModifierByName( "modifier_mercy_caduceus" ):Destroy()
        end
    end
end
function mercy_caduceus:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end
	return ""
end
function mercy_caduceus:GetAbilityToRetriveValues()
    if IsServer() then
        if self:GetCaster():HasModifier("modifier_mercy_valkyri") then
            return self:GetCaster():FindAbilityByName("mercy_valkyri")
        end
    end

    return self
end
function mercy_caduceus:GetBreakDistance()
    if IsServer() then
        if self:GetCaster():HasModifier("modifier_mercy_valkyri") then
            return self:GetSpecialValueFor("radius") * self:GetCaster():FindAbilityByName("mercy_valkyri"):GetSpecialValueFor("caduceus_radius_mult")
        end
    end

    return self:GetSpecialValueFor("radius")
end

function mercy_caduceus:IsStealable() return false end

function mercy_caduceus:Swap()
    local mod = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())

    if mod:GetStackCount() == STACKS_MODE_HEAL then
        mod:SetStackCount(STACKS_MODE_DAMAGE)
    else 
        mod:SetStackCount(STACKS_MODE_HEAL)
    end
end

function mercy_caduceus:OnSpellStart()
    if IsServer() then
        local hCaster = self:GetCaster()
        local hTarget = self:GetCursorTarget()

        self:Clean()

        self.m_hMod = hTarget:AddNewModifier( hCaster, self, "modifier_mercy_caduceus", nil)
    end
end

modifier_mercy_caduceus = class({})

function modifier_mercy_caduceus:GetEffectName() return "particles/hero_mercy/mercy_cadeus_buff.vpcf" end
function modifier_mercy_caduceus:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_mercy_caduceus:IsPurgable() return false end

modifier_mercy_caduceus.m_iStacks = 0

function modifier_mercy_caduceus:OnCreated(htable)
    self.m_iStacks = self:GetCaster():GetModifierStackCount( "modifier_mercy_caduceus_mode", self:GetCaster() ) 

    if IsServer() then
        self:StartIntervalThink(0.15)

        self:SetStackCount(self:GetCaster():GetHealthRegen())
        
        EmitSoundOn("Hero_Wisp.Tether", self:GetCaster())
        EmitSoundOn("Hero_Wisp.Tether.Target", self:GetParent())

        if self.m_iStacks == STACKS_MODE_HEAL then

        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/wisp/wisp_tether_ti7.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() );
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true );
        self:AddParticle(nFXIndex, false, false, -1, false, false)
    else    
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_wisp/wisp_tether_agh.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() );
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true );
        self:AddParticle(nFXIndex, false, false, -1, false, false)

        end
    end
end

function modifier_mercy_caduceus:OnRefresh(params)
    self.m_iStacks = self:GetCaster():GetModifierStackCount( "modifier_mercy_caduceus_mode", self:GetCaster() ) 
end

function modifier_mercy_caduceus:OnIntervalThink()
    self.m_iStacks = self:GetCaster():GetModifierStackCount( "modifier_mercy_caduceus_mode", self:GetCaster() ) 
    self:SetStackCount(self:GetCaster():GetHealthRegen())

    if IsServer() then
		if self:GetCaster():IsAlive() == false or (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() > self:GetAbility():GetBreakDistance() then
			self:Destroy()
        end
        
        self:ForceRefresh()
	end
end

function modifier_mercy_caduceus:OnDestroy()
	if IsServer() then
		EmitSoundOn("Hero_Wisp.Tether.Stun", self:GetCaster())
	end
end

function modifier_mercy_caduceus:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}

	return funcs
end

function modifier_mercy_caduceus:GetModifierConstantHealthRegen(params)
    if self.m_iStacks == STACKS_MODE_HEAL then
        return self:GetAbility():GetAbilityToRetriveValues():GetSpecialValueFor("heal_amp") + self:GetStackCount()
    end

    return 0
end

function modifier_mercy_caduceus:GetModifierHealthRegenPercentage(params)
    if self.m_iStacks == STACKS_MODE_HEAL then
        return self:GetAbility():GetAbilityToRetriveValues():GetSpecialValueFor("heal_ptc_amp")
    end

    return 0
end

function modifier_mercy_caduceus:GetModifierDamageOutgoing_Percentage(params)
    if self.m_iStacks == STACKS_MODE_DAMAGE then
        return self:GetAbility():GetAbilityToRetriveValues():GetSpecialValueFor("damage_amp") 
    end

    return 0
end


modifier_mercy_caduceus_mode = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_mercy_caduceus_mode:IsHidden() return false end
function modifier_mercy_caduceus_mode:IsPurgable() return false end
function modifier_mercy_caduceus_mode:RemoveOnDeath() return false end
function modifier_mercy_caduceus_mode:IsStealable() return false end


if not mercy_caduceus_type then mercy_caduceus_type = class({}) end 

mercy_caduceus_type.m_hPrimaryAbility = nil

function mercy_caduceus_type:Spawn()
    if IsServer() then
        self:SetLevel(1)

        self.m_hPrimaryAbility = self:GetCaster():FindAbilityByName("mercy_caduceus")

        self:SetThink( "OnIntervalThink", self, 0.25 )
    end
end

function mercy_caduceus_type:OnIntervalThink() 
    self:SetActivated(self.m_hPrimaryAbility.m_hMod ~= nil)

    return 0.25
end 


function mercy_caduceus_type:OnSpellStart() 
    if IsServer() then
        self.m_hPrimaryAbility:Swap()
    end 
end 

function mercy_caduceus_type:GetAbilityTextureName() 
    if self:GetCaster():HasModifier("modifier_mercy_caduceus_mode") then
        local stacks = self:GetCaster():GetModifierStackCount( "modifier_mercy_caduceus_mode", self:GetCaster() ) 

        if stacks == STACKS_MODE_HEAL then
            return "custom/mercy_caduceus_heal"
        else 
            return "custom/mercy_caduceus_damage"
        end
    end

    return self.BaseClass.GetAbilityTextureName(self)  
end 

