tifus_unclean_mist = class({})
LinkLuaModifier("modifier_tifus_unclean_mist", "abilities/tifus_unclean_mist.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tifus_unclean_mist_thinker", "abilities/tifus_unclean_mist.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tifus_unclean_mist_debuff", "abilities/tifus_unclean_mist.lua", LUA_MODIFIER_MOTION_NONE)

function tifus_unclean_mist:ProcsMagicStick()
	if self:GetCaster():HasModifier("modifier_tifus_unclean_mist") then
		return false
	else
		return true
	end
end

function tifus_unclean_mist:OnToggle()
	-- unit identifier
	local caster = self:GetCaster()
	-- load data
	local toggle = self:GetToggleState()

	if toggle then
		-- add modifier
		caster:AddNewModifier(caster, self, "modifier_tifus_unclean_mist", {} )
	else
		caster:RemoveModifierByName("modifier_tifus_unclean_mist")
	end
end

modifier_tifus_unclean_mist = class({})
function modifier_tifus_unclean_mist:IsDebuff() return false end
function modifier_tifus_unclean_mist:IsHidden() return true end
function modifier_tifus_unclean_mist:IsPurgable() return false end
function modifier_tifus_unclean_mist:IsPurgeException() return false end
function modifier_tifus_unclean_mist:OnCreated()
	self:StartIntervalThink(0.3)
end

function modifier_tifus_unclean_mist:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local target_point = caster:GetOrigin()
		local ability = self:GetAbility()
		local manacost = ability:GetSpecialValueFor("manacost_per_sec")
		local tick_rate= ability:GetSpecialValueFor("tick_rate")
		local mana = self:GetParent():GetMana()
		if mana < manacost then
			-- turn off
			if ability:GetToggleState() then
				ability:ToggleAbility()
			end
			return
        end
        
		self:GetParent():SpendMana( manacost * tick_rate, ability )
		
		local poison_particle = "particles/stygian/tifus/tifus_mist.vpcf"
		
		local duration = ability:GetSpecialValueFor("cloud_duration")
		local radius = ability:GetSpecialValueFor("radius")
		local thinker = CreateModifierThinker(caster, ability, "modifier_tifus_unclean_mist_thinker", {duration = duration, target_point_x = target_point.x , target_point_y = target_point.y}, target_point, caster:GetTeamNumber(), false)
		
		local particle = ParticleManager:CreateParticle(poison_particle, PATTACH_WORLDORIGIN, thinker)
			ParticleManager:SetParticleControl(particle, 0, thinker:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, radius))
			
		Timers:CreateTimer(duration, function()
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)
		end)
	end
end

modifier_tifus_unclean_mist_thinker = class({})

function modifier_tifus_unclean_mist_thinker:OnCreated()
	self:StartIntervalThink( 0.1 )
end
function modifier_tifus_unclean_mist_thinker:OnDestroy()
	UTIL_Remove( self:GetParent() )
end

function modifier_tifus_unclean_mist_thinker:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local radius = ability:GetSpecialValueFor( "radius" )
	local poison_duration = ability:GetSpecialValueFor( "linger_duration" )
	
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, ability, "modifier_tifus_unclean_mist_debuff", {duration = poison_duration} )
	end
end

modifier_tifus_unclean_mist_debuff = class({})
function modifier_tifus_unclean_mist_debuff:IsDebuff() return true end
function modifier_tifus_unclean_mist_debuff:IsHidden() return false end
function modifier_tifus_unclean_mist_debuff:IsPurgable() return true end
function modifier_tifus_unclean_mist_debuff:OnCreated()
	self:StartIntervalThink( self:GetAbility():GetSpecialValueFor( "tick_rate" ) )
end

function modifier_tifus_unclean_mist_debuff:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local damage_per_second = ability:GetSpecialValueFor( "damage_per_second" )
	local tick_rate = ability:GetSpecialValueFor( "tick_rate" )
	local damage = damage_per_second * tick_rate
	
	ApplyDamage({victim = parent, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end