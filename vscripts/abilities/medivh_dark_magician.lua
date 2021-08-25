medivh_dark_magician = class({})
LinkLuaModifier("modifier_medivh_dark_magician", "abilities/medivh_dark_magician.lua", LUA_MODIFIER_MOTION_NONE)

function medivh_dark_magician:Spawn()
    if IsServer() then self:SetLevel(1) end
end

function medivh_dark_magician:GetIntrinsicModifierName() 
    return "modifier_medivh_dark_magician"
end

modifier_medivh_dark_magician  = class({})

function modifier_medivh_dark_magician:IsHidden() 
    return false
end

function modifier_medivh_dark_magician:RemoveOnDeath() 
    return false 
end

function modifier_medivh_dark_magician:IsPurgable() 
    return false 
end