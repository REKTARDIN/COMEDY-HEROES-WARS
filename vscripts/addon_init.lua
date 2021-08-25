function IsHasTalent( pID, talent )
    local talents = CustomNetTables:GetTableValue("talents", "talents")
    if talents[tostring(pID)] then
        return talents[tostring(pID)][talent]
    end 
    return nil
end

function GetAbilityIcon(ability)
	local abilities = CustomNetTables:GetTableValue("players", "icons")
	local index = ability:entindex()

	if abilities ~= nil and abilities[tostring(index)] then 
		return "custom/" .. abilities[tostring(index)]
	end

    return ability.BaseClass.GetAbilityTextureName(ability)
end

function MergeTables( t1, t2 )
    for name,info in pairs(t2) do
		if type(info) == "table"  and type(t1[name]) == "table" then
			MergeTables(t1[name], info)
		else
			t1[name] = info
		end
	end
end

function HasBit(checker, value)
	return bit.band(checker, value) == value
end

function AddTableToTable( t1, t2)
	for k,v in pairs(t2) do
		table.insert(t1, v)
	end
end

if IsClient() then    
    function C_DOTA_BaseNPC:GetAttackRange()
        return self:Script_GetAttackRange()
	end
	function C_DOTA_BaseNPC:IsFriendly(target)
		return target:GetTeamNumber() == self:GetTeamNumber()
	end
	function C_DOTA_BaseNPC:HasTalent(talent)
        return IsHasTalent(self:GetPlayerOwnerID(), talent) ~= nil
	end
end

function TernaryOperator(value, bCheck, default)
	if bCheck then 
		return value 
	else 
		return default
	end
end

function GetTableLength(rndTable)
	local counter = 0
	for k,v in pairs(rndTable) do
		counter = counter + 1
	end
	return counter
end

function PrintAll(t)
	for k,v in pairs(t) do
		print(k,v)
	end
end
