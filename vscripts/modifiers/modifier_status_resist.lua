
if modifier_st_res == nil then modifier_st_res = class({}) end

function modifier_st_res:IsHidden() return false end
function modifier_st_res:IsPurgable() return false end
function modifier_st_res:RemoveOnDeath() return false end


function modifier_st_res:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING 
	}
	return funcs
end

function modifier_st_res:GetModifierStatusResistanceStacking()
	if IsServer() then
		return 40
	end

	return 0
end