if modifier_z_delta == nil then
	modifier_z_delta = class({})
end

function modifier_z_delta:DeclareFunctions()
	local funcs = {
	    MODIFIER_PROPERTY_VISUAL_Z_DELTA
	}
	return funcs
end

function modifier_z_delta:GetVisualZDelta() return 90 end
function modifier_z_delta:IsHidden() return true end
function modifier_z_delta:IsPermanent() return true end
function modifier_z_delta:IsPurgable() return false end
function modifier_z_delta:RemoveOnDeath() return false end