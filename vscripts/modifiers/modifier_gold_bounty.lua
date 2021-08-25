if modifier_gold_bounty == nil then modifier_gold_bounty = class({}) end
function modifier_gold_bounty:IsPurgable() return false end
function modifier_gold_bounty:IsHidden() return true end
function modifier_gold_bounty:RemoveOnDeath() return false end
function modifier_gold_bounty:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end

local CONST_BASE = 200
local STREAK = 50

function modifier_gold_bounty:OnCreated(params)
	if IsServer() then
		----self:StartIntervalThink(0.1)
	end
end

function modifier_gold_bounty:OnIntervalThink()
	if IsServer() then 

    end
end
