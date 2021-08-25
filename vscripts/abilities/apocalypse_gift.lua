LinkLuaModifier( "modifier_apocalypse_gift", "abilities/apocalypse_gift.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_apocalypse_gift_int", "abilities/apocalypse_gift.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_apocalypse_gift_str", "abilities/apocalypse_gift.lua", LUA_MODIFIER_MOTION_NONE )

local CONST_INTERVAL_THINK = 0.1
local CONST_INTERVAL_THINK_STOP = -1
local hBuff = nil

apocalypse_gift_int = class({})

function ClearToggleStates( unit )
    
end

function apocalypse_gift_int:IsStealable()
    return false
end

apocalypse_gift_int.m_hSecondaryAbility = nil

function apocalypse_gift_int:OnOwnerDied()
    if IsServer() and hBuff then
        hBuff:OnOwnerDied()
    end 
end

function apocalypse_gift_int:OnUpgrade()
    if IsServer() then
        local secondary_ability = self:GetCaster():FindAbilityByName("apocalypse_gift_str")

        if secondary_ability and secondary_ability:GetLevel() ~= self:GetLevel() then
            secondary_ability:SetLevel(self:GetLevel())
        end

        if hBuff == nil then
            hBuff = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_apocalypse_gift", nil )
        end
    end
end

--------------------------------------------------------------------------------

function apocalypse_gift_int:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function apocalypse_gift_int:OnToggle()
    if IsServer() then
        local secondary_ability = self:GetCaster():FindAbilityByName("apocalypse_gift_str")

        if secondary_ability and secondary_ability:GetToggleState() then
            secondary_ability:ToggleAbility()
        end

        if self:GetToggleState() and hBuff then
            hBuff:Start(DOTA_ATTRIBUTE_INTELLECT)

            self:StartCooldown(self:GetSpecialValueFor("morph_cooldown"))
        else
            if hBuff then
                hBuff:Stop()
            end
        end
    end
end

apocalypse_gift_str = class({})

--------------------------------------------------------------------------------

function apocalypse_gift_str:ProcsMagicStick()
	return false
end

function apocalypse_gift_str:OnUpgrade()
    if IsServer() then
        local secondary_ability = self:GetCaster():FindAbilityByName("apocalypse_gift_str")

        if secondary_ability and secondary_ability:GetLevel() ~= self:GetLevel() then
            secondary_ability:SetLevel(self:GetLevel())
        end

        if hBuff == nil then
            hBuff = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_apocalypse_gift", nil )
        end
    end
end

function apocalypse_gift_str:IsStealable()
    return false
end

--------------------------------------------------------------------------------

function apocalypse_gift_str:OnToggle()
    if IsServer() then   
        local secondary_ability = self:GetCaster():FindAbilityByName("apocalypse_gift_int")

        if secondary_ability and secondary_ability:GetToggleState() then
            secondary_ability:ToggleAbility()
        end

        if self:GetToggleState() and hBuff then
            hBuff:Start(DOTA_ATTRIBUTE_STRENGTH)

            self:StartCooldown(self:GetSpecialValueFor("morph_cooldown"))
        else
            if hBuff then
                hBuff:Stop()
            end
        end
    end
end

if not modifier_apocalypse_gift then modifier_apocalypse_gift = class({}) end

function modifier_apocalypse_gift:IsHidden() return true end
function modifier_apocalypse_gift:IsPurgable()	return false end
function modifier_apocalypse_gift:RemoveOnDeath() return false end
function modifier_apocalypse_gift:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end


function modifier_apocalypse_gift:OnOwnerDied()
    if IsServer() then
        if self.m_hStrModifier and self.m_hIntModifier then
            self.m_hStrModifier:Clear()
            self.m_hIntModifier:Clear()

            self:GetParent():CalculateStatBonus(true)
        end
    end 
end

modifier_apocalypse_gift.m_iAttributeType = -1
modifier_apocalypse_gift.m_bUp = true
modifier_apocalypse_gift.m_hStrModifier = nil
modifier_apocalypse_gift.m_hIntModifier = nil

modifier_apocalypse_gift.m_iInt = 0
modifier_apocalypse_gift.m_iStr = 0

function modifier_apocalypse_gift:Update()
    self.m_iInt = self:GetParent():GetIntellect()
    self.m_iStr = self:GetParent():GetStrength()
end

function modifier_apocalypse_gift:OnCreated(params)
    if IsServer() then
        self.m_hStrModifier = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_apocalypse_gift_str", nil )
        self.m_hIntModifier = self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_apocalypse_gift_int", nil )

        self:Update()
    end
end

function modifier_apocalypse_gift:OnRefresh(params)
    if IsServer() then
        self:Update()
    end
end


function modifier_apocalypse_gift:Start(att)
    if IsServer() then
        self.m_iAttributeType = att

        self:StartIntervalThink(CONST_INTERVAL_THINK)

        if self.particle then
            ParticleManager:DestroyParticle(self.particle, true)
        end

        self.particle = ParticleManager:CreateParticle ("particles/stygian/apocalypse_attribute_int.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())

        self:Update()
    end
end

function modifier_apocalypse_gift:Stop()
    if IsServer() then
        --- Stop timer
        self:StartIntervalThink(CONST_INTERVAL_THINK_STOP)

        if self.particle then
            ParticleManager:DestroyParticle(self.particle, true)
        end

        self:Update()
    end
end

function modifier_apocalypse_gift:OnIntervalThink()
    if IsServer() then
        if self.m_hStrModifier and self.m_hIntModifier then
            if self.m_iAttributeType == DOTA_ATTRIBUTE_INTELLECT and self.m_hIntModifier:GetStack() >= self:GetParent():GetBaseStrength() then
                self:Stop()
                return 
            end
    
            if self.m_iAttributeType == DOTA_ATTRIBUTE_STRENGTH and self.m_hStrModifier:GetStack() >= self:GetParent():GetBaseIntellect() then
                self:Stop()
                return 
            end
    
            if self.m_iAttributeType == DOTA_ATTRIBUTE_INTELLECT then
                self.m_hStrModifier:Decrement()
                self.m_hIntModifier:Increment()
            else 
                self.m_hIntModifier:Decrement()
                self.m_hStrModifier:Increment()
            end

            self:Update()
    
            self:GetParent():CalculateStatBonus(true)
        end
    end
end

function modifier_apocalypse_gift:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

function modifier_apocalypse_gift:GetModifierBonusStats_Intellect() 
    return self.m_iInt * (self:GetAbility():GetSpecialValueFor("bonus_attributes") / 100)
end

function modifier_apocalypse_gift:GetModifierBonusStats_Strength() 
    return self.m_iStr * (self:GetAbility():GetSpecialValueFor("bonus_attributes") / 100)
end

if not modifier_apocalypse_gift_int then modifier_apocalypse_gift_int = class({}) end

function modifier_apocalypse_gift_int:IsHidden() return true end
function modifier_apocalypse_gift_int:IsPurgable()	return false end
function modifier_apocalypse_gift_int:RemoveOnDeath() return false end
function modifier_apocalypse_gift_int:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

modifier_apocalypse_gift_int.m_iValue = 0 

function modifier_apocalypse_gift_int:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
end

-----------------------STATS--------------------------------------
function modifier_apocalypse_gift_int:GetModifierBonusStats_Intellect() 
    return self.m_iValue 
end


function modifier_apocalypse_gift_int:Increment()
    self.m_iValue = self.m_iValue + 1
end

function modifier_apocalypse_gift_int:Decrement()
    self.m_iValue = self.m_iValue - 1
end

function modifier_apocalypse_gift_int:GetStack()
    return self.m_iValue
end

function modifier_apocalypse_gift_int:Clear()
    self.m_iValue = 0
end

if not modifier_apocalypse_gift_str then modifier_apocalypse_gift_str = class({}) end

modifier_apocalypse_gift_str.m_iValue = 0 

function modifier_apocalypse_gift_str:IsHidden() return true end
function modifier_apocalypse_gift_str:IsPurgable()	return false end
function modifier_apocalypse_gift_str:RemoveOnDeath() return false end
function modifier_apocalypse_gift_str:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_apocalypse_gift_str:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

-----------------------STATS--------------------------------------
function modifier_apocalypse_gift_str:GetModifierBonusStats_Strength() 
    return self.m_iValue 
end

function modifier_apocalypse_gift_str:Increment()
    self.m_iValue = self.m_iValue + 1
end

function modifier_apocalypse_gift_str:Decrement()
    self.m_iValue = self.m_iValue - 1
end

function modifier_apocalypse_gift_str:GetStack()
    return self.m_iValue
end

function modifier_apocalypse_gift_str:Clear()
    self.m_iValue = 0
end