--Class definition
if Util == nil then
  Util = {}
  Util.__index = Util
end

Util.abilities = nil
__wearables = nil

Util.econs = nil
Util.heroes_ids = nil

Util.Heroes = {
    npc_dota_hero_death_eater = 2,
    npc_dota_hero_stormspirit = 4,
    npc_dota_hero_medusa = 8,
    npc_dota_hero_io = 16
}

EF_GLOBAL = 99999
EF_MAX_LEVEL_CONST = 30

function Util:OnInit(args)
    CustomNetTables:SetTableValue( "heroes", "heroes", Util:GetHeroList())

    PlayerTables:CreateTable("heroes_abilities", {abilities = Util:GetHeroAbilityList()}, true)

    CustomGameEventManager:RegisterListener("debug_console_input", Dynamic_Wrap(Util, 'OnDebugConsoleInput'))
    CustomGameEventManager:RegisterListener("on_item_deleted", Dynamic_Wrap(Util, 'DeleteEconItem'))
    CustomGameEventManager:RegisterListener("set_compendium_user", Dynamic_Wrap(Util, 'OnCompendiumLoaded'))
    CustomGameEventManager:RegisterListener("quest_selected", Dynamic_Wrap(Util, 'OnQuestSelected'))
    CustomGameEventManager:RegisterListener("quest_ended", Dynamic_Wrap(Util, 'OnQuestEnded'))
    CustomGameEventManager:RegisterListener("on_cosmetic_item_changed", Dynamic_Wrap(Util, 'OnCosmeticItemUpdated'))
    CustomGameEventManager:RegisterListener("chat_wheel_sound", Dynamic_Wrap(Util, 'OnPlayerUsedChatWheel'))

    ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( Util, "OnItemPickUp"), self )
    ListenToGameEvent( "dota_player_gained_level", Dynamic_Wrap( Util, "OnPlayerLeveledUp"), self )
    ListenToGameEvent( "entity_killed", Dynamic_Wrap( Util, "OnEntityKilled"), self )

    Convars:RegisterCommand( "try_get_data", Dynamic_Wrap(Util, 'GetNetworkStatsData'), "Test", FCVAR_CHEAT )
    Convars:RegisterCommand( "try_set_data", Dynamic_Wrap(Util, 'SetNetworkStatsData'), "Test", FCVAR_CHEAT )

    local qualities = LoadKeyValues('scripts/items/qualities.kv')
    local rarities = LoadKeyValues('scripts/items/rarities.kv')
    local econ = LoadKeyValues('scripts/items/items.kv')

    Util.econs = LoadKeyValues('scripts/items/items.kv')
    Util.abilities = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
    Util.items = LoadKeyValues('scripts/npc/npc_items_custom.txt')
    Util.heroes_ids = FillHeroesIDs()
    Util.portraits = {}
    Util.ability_icons = {}
    
    __wearables = LoadKeyValues('scripts/items/wearables.kv')

    CustomNetTables:SetTableValue( "globals", "rarities", rarities )
    CustomNetTables:SetTableValue( "globals", "qualities", qualities )
   
    PlayerTables:CreateTable("globals", {econs = econ}, true)
    PlayerTables:CreateTable("heroes_data", {heroes = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')}, true)
    PlayerTables:CreateTable("heroes_ids", {ids = Util.heroes_ids}, true)

    LinkLuaModifier("modifier_arcana", "modifiers/modifier_arcana.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_pet_model", "modifiers/modifier_pet_model.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_fountain", "modifiers/modifier_fountain.lua", LUA_MODIFIER_MOTION_NONE)

    CustomGameEventManager:RegisterListener("on_chat_recived", Dynamic_Wrap(Util, 'OnChatUpdated'))
    CustomGameEventManager:RegisterListener("on_gauntlet_ability_selected", Dynamic_Wrap(Util, 'OnGauntletAbilitySelected'))

    Util:SetupConsole()
end

function Util:OnChatUpdated( data )
  CustomGameEventManager:Send_ServerToAllClients("on_chat_new_mess", data)
end

function Util:GetNetworkStatsData()
	stats.test()
end

function Util:SetNetworkStatsData()
	stats.set_data()
end

function Util:DeleteEconItem(data)
    stats.delete_item(data)
end

function Util:GetHeroID( hero_name )
    return tonumber(Util.heroes_ids[hero_name])
end

--- For econs effects dynamic loading
function Util:RegisterAbilities( unit )
    if IsValidEntity(unit) and unit:GetAbilityCount() > 0 then
        for i=0, 15, 1 do  
            local current_ability = unit:GetAbilityByIndex(i)

            if current_ability ~= nil then
                current_ability.effects_params = {}
                current_ability.sound_params = {}
                current_ability:RegisterParams()
            end
        end
    end
end

function Util:OnPlayerUsedChatWheel( event )
    local sound = event.sound
    local player = event.playerID
    local name = event.name

    local playerName = tostring(PlayerResource:GetPlayerName(tonumber(player)))
    local res = playerName .." shout: " .. name

    GameRules:SendCustomMessage(res, 0, 0)

    EmitAnnouncerSound(sound)
end

function Util:OnEntityKilled( event )
   --[[
       vgame_event_name	entity_killed
damagebits	0
game_event_listener	503316488
entindex_attacker	1014
entindex_killed	590
splitscreenplayer	-1
   ]]
    --[[local attacker = EntIndexToHScript(event.entindex_attacker)
    local victim = EntIndexToHScript(event.entindex_killed)

    if attacker:IsHero() and victim:IsRealHero() then
        local streak = victim:GetStreak()
        local level = victim:GetLevel()

        local mult = victim:GetLevel() / attacker:GetLevel()

        local bounty = (150 + (level * level) + (3 * (GameRules:GetGameTime() / 60)) + 150 * streak) * mult

        local res = PlayerResource:GetPlayerName(attacker:GetPlayerOwnerID()).." killed " .. PlayerResource:GetPlayerName(victim:GetPlayerOwnerID()) .. " for " .. tostring(math.floor( bounty )) .. " gold."
        GameRules:SendCustomMessage(res, 0, 0)

        attacker:ModifyGold(bounty, true, DOTA_ModifyGold_CreepKill)
    end]]--
end

function Util:OnItemPickUp( event )
    pcall(function()
        local item = EntIndexToHScript( event.ItemEntityIndex )
        local owner = EntIndexToHScript( event.HeroEntityIndex )
        r = RandomInt(200, 400)
        if event.itemname == "item_bag_of_gold" then
            PlayerResource:ModifyGold( owner:GetPlayerID(), r, true, 0 )
            SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, r, nil )
            UTIL_Remove( item )
        end
    end)
end

function Util:OnPlayerLeveledUp(params)
    local hero = EntIndexToHScript(params.hero_entindex)

    if params.level >= EF_MAX_LEVEL_CONST then
        hero:SetAbilityPoints(hero:GetAbilityPoints() + EF_MAX_LEVEL_CONST)
    end
end

function Util:GetAbilityBehavior(name)
    local path = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
    if path[name] then
        if path[name]["AbilityBehavior"] then
            return path[name]["AbilityBehavior"]
        end
    end
end

function Util:GetAllHeroesCMMode()
    local heroes = {}
    local path = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')

    for k,v in pairs(path) do
        local hero = v["override_hero"] or k
        if hero then
            if v["CMDisabled"] == nil and v["HeroDisabled"] == nil then
                table.insert( heroes, hero )
            end
        end
    end

    return heroes
end

function FillHeroesIDs()
    local heroes = {}

    local path = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')

    for k,v in pairs(path) do
        local hero = v["override_hero"] or k
        if hero then
            heroes[hero] = v["HeroID"]
        end
    end

    return heroes
end

function Util:GetAllHeroesCMModeDisabled()
    local heroes = {}
    local path = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')

    for k,v in pairs(path) do
        local hero = v["override_hero"] or k
        if hero then
            if v["CMDisabled"] or v["HeroDisabled"] then
                table.insert( heroes, hero )
            end
        end
    end

    return heroes
end

function Util:GetHeroes()
    local path = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
    local heroes = CustomNetTables:GetTableValue("players", "heroes")

    local result = {}

    for k,v in pairs(path) do
        local hero = v["override_hero"] or k
        if hero and v["HeroDisabled"] == nil then
            table.insert( result, hero )
        end
    end

    return result
end

function Util:GetHeroList()
    local path = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
    local heroes = CustomNetTables:GetTableValue("players", "heroes")

    local result = {}

    for k,v in pairs(path) do
        local hero = v["override_hero"] or k
        if hero and v["HeroDisabled"] == nil then
            result[hero] = v["AttributePrimary"]
        end
    end

    return result
end

function Util:GetHeroAbilityList()
    local Abilities = {}

    local path = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
    local herolist = LoadKeyValues('scripts/npc/herolist.txt')

    for k,v in pairs(path) do
        local hero = v["override_hero"] or k
        Abilities[hero] = {v["Ability1"], v["Ability2"], v["Ability3"], v["Ability4"], v["Ability5"], v["Ability6"]}
    end

    return Abilities
end

function Util:GetItemID(string)
    local id = -1
    local array = {}
    local econs = PlayerTables:GetTableValue("globals", "econs")
    for _, item in pairs(econs) do
        if item['item'] == string then
            table.insert(array, item['def_id'])
        end
    end
    return array
end

function Util:PlayerEquipedItem(pID, string)
    local steam_id = PlayerResource:GetSteamAccountID(pID)
    steam_id = tostring(steam_id)
    local items = Util:GetItemID(string)
    if GameRules.Globals.Inventories then
        if GameRules.Globals.Inventories[steam_id] then
            local array = GameRules.Globals.Inventories[steam_id]
            for _, item in pairs(array) do
                for _, def_id in pairs(items) do
                    if tonumber(item['steam_id']) == tonumber(steam_id) and tonumber(item['def_id']) == tonumber(def_id) and item['state'] == 1 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function Util:PlayerHasItem(pID, string)
    local steam_id = PlayerResource:GetSteamAccountID(pID)
    steam_id = tostring(steam_id)
    if GameRules.Globals.Inventories then
        if GameRules.Globals.Inventories[steam_id] then
            local array = GameRules.Globals.Inventories[steam_id]
            for _, item in pairs(array) do
                if item['steam_id'] == steam_id and item['def_id'] == Util:GetItemID(string) then
                    return true
                end
            end
        end
    end
    return false
end


function Util:GetItemForHero(def_id)
    for k, v in pairs(Util.econs) do
        if(tostring(v["def_id"])) == tostring(def_id) then
            return v["hero"]
        end
    end

    return nil
end

function Util:GetItemName(def_id)
    for k, v in pairs(Util.econs) do
        if(tostring(v["def_id"])) == tostring(def_id) then
            return v["item"]
        end
    end

    return nil
end

function Util:PlayerHasAdminRules(pID)
    local data = CustomNetTables:GetTableValue("players", "stats")
    if data and data[tostring(pID)] then
        return data[tostring(pID)].status == 2
    end

    return false
end

function Util:UpdateWearables(hero, playerID)
    local items = {}
    local name = hero:GetUnitName()
    local steam_id = PlayerResource:GetSteamAccountID(playerID)
    if GameRules.Globals.Inventories then
        if GameRules.Globals.Inventories[tostring(steam_id)] then
            for id, _econ in pairs(GameRules.Globals.Inventories[tostring(steam_id)]) do
                if _econ["state"] == 1 and Util:GetItemForHero(_econ["def_id"]) == name then
                    local econ_name = Util:GetItemName(_econ["def_id"])
                    table.insert( items, econ_name )
                end
            end
        end
    end
    Util:_EquipItem(hero, items)
end


function Util:_EquipItem(hero, items)
    if __wearables == nil then __wearables = LoadKeyValues("scripts/items/wearables.kv") end

    local used_slots = {}
    hero.wearables = {}
    hero.modifiers = {}
    hero.particles = {}
    local hero_slots = __wearables[hero:GetUnitName()]
    if hero_slots then
        for _slot, slot in pairs(hero_slots) do
            used_slots[_slot] = false
            for __index, user_item in pairs(items) do
                if slot[user_item] ~= nil then
                    Util:EquipItemData(hero, slot[user_item], _slot)
                    used_slots[_slot] = true
                    break
                end
            end
        end
        for _i, _bool in pairs(used_slots) do
            if not _bool then
                if hero_slots[_i]["__default"] then
                    Util:EquipItemData(hero, hero_slots[_i]["__default"], _i)
                end
            end
        end
        if not items then
            for _slot, slot in pairs(hero_slots) do
                if slot["__default"] then
                    Util:EquipItemData(hero, slot["__default"], _slot)
                end
            end
        end
    end
end

function Util:CreateWearable(hero, modelName)
    local hWearable = Entities:CreateByClassname( "wearable_item" )
    if hWearable ~= nil then
        hWearable:SetModel( modelName )
        hWearable:SetTeam( hero:GetTeamNumber() )
        hWearable:SetOwner( hero )
        hWearable:FollowEntity( hero, true )
    end

    return hWearable
end

function Util:ParseRenderColor( color, hero )
    if color == "black" then hero:SetRenderColor(0, 0, 0) end
    if color == "gold" then hero:SetRenderColor(255, 215, 0) end
    if color == "red" then hero:SetRenderColor(255, 0, 0) end
end

function Util:EquipItemData(hero, item_data, slot)
    local econ_params = item_data
    if econ_params["model"] then
        hero:SetOriginalModel(econ_params["model"])
    end
    if econ_params["model_scale"] then
        hero:SetModelScale(tonumber(econ_params["model_scale"]))
    end
    if econ_params["models"] ~= nil then
        for _, model in pairs(econ_params["models"]) do
            local _econ = Util:CreateWearable(hero, model["model"])
            hero.wearables[slot] = _econ
            if model["material"] then
                _econ:SetMaterialGroup(tostring(model["material"]))
            end
            if model["model_scale"] then
                _econ:SetModelScale(tonumber(model["model_scale"]))
            end
            if model["render"] then Util:ParseRenderColor(model["render"], _econ) end
            if model["particles"] ~= nil then
                for __index, particle in pairs(model["particles"]) do
                    local _particle = ParticleManager:CreateParticle( particle["particle"], PATTACH_ABSORIGIN_FOLLOW, _econ )
                    table.insert( hero.particles, _particle )
                    if particle["ControlPoints"] ~= nil then
                        for _point, point_params in pairs(particle["ControlPoints"]) do
                            ParticleManager:SetParticleControlEnt( _particle, tonumber(_point), _econ, PATTACH_POINT_FOLLOW, point_params, _econ:GetOrigin(), true )
                        end
                    end
                end
            end
        end
    end

    if econ_params["render"] then Util:ParseRenderColor(econ_params["render"], hero) end

    if econ_params["projectile"] ~= nil then
        hero:SetRangedProjectileName(econ_params["projectile"]["particle"])
    end

    if econ_params["skillset"] ~= nil then
        hero:SetSkillBuild(econ_params["skillset"])
    end

    if econ_params["particles"] ~= nil then
        for __, particle in pairs(econ_params["particles"]) do
            local _particle = ParticleManager:CreateParticle( particle["particle"], PATTACH_ABSORIGIN_FOLLOW, hero )
            table.insert( hero.particles , _particle )
            ----print("we want create".. particle["particle"])
            if particle["ControlPoints"] ~= nil then
                for _point, point_params in pairs(particle["ControlPoints"]) do
                    ----print("Control point is: " .. _point .. " param: " .. point_params["attach_point"])
                    ParticleManager:SetParticleControlEnt( _particle, tonumber(_point), hero, PATTACH_POINT_FOLLOW, point_params["attach_point"], hero:GetOrigin(), true )
                end
            end
        end
    end
    if econ_params["modifiers"] ~= nil then
        for __id, modifier in pairs(econ_params["modifiers"]) do
            LinkLuaModifier(modifier["modifier"], modifier["modifier_path"], LUA_MODIFIER_MOTION_NONE)
            
            local params = nil

            if modifier["params"] ~= nil then
                params = {}
                
                for k,v in pairs(modifier["params"]) do
                    params[k] = v
                end
            end

            local mod = hero:AddNewModifier(hero, nil, modifier["modifier"], params)
            hero.modifiers[slot] = mod
        end
    end
    if econ_params["material"] then
        hero:SetMaterialGroup(tostring(econ_params["material"]))
    end
    if econ_params["portrait"] then
        Util:SetUnitPortrait(hero:GetPlayerOwnerID(), hero:GetUnitName(), econ_params["portrait"])
    end
    if econ_params["ambient"] then
        StartSoundEvent(econ_params["ambient"], hero)
    end
    ----- effects and mods

    if econ_params["econ_modifiers"] ~= nil then
        for ability_name, data in pairs(econ_params["econ_modifiers"]) do
            if hero:HasAbility(ability_name) then
                local ability = hero:FindAbilityByName(ability_name)

                if IsValidEntity(ability) then 
                    if data["effects"] ~= nil then
                        for id, effect in pairs(data["effects"]) do
                            ability:SetEffect(tonumber(id), effect)
                        end
                    end
                    if data["sounds"] ~= nil then
                        for id, sound in pairs(data["sounds"]) do
                            ability:SetSound(tonumber(id), sound)
                        end
                    end

                    if data["icon"] ~= nil then
                        ability:SetAbilityTexture(data["icon"])
                    end
                end
            end
        end
    end
end

function Util:SetUnitPortrait(pID, hero, portrait)
    Util.portraits[pID] = (Util.portraits[pID] or {})
    Util.portraits[pID][hero] = portrait

    CustomNetTables:SetTableValue("players", "portraits", Util.portraits)
end

function Util:OnHeroInGame(hero)
    LinkLuaModifier("modifier_hero_selection", "modifiers/modifier_hero_selection.lua", LUA_MODIFIER_MOTION_NONE)
    ----LinkLuaModifier("modifier_gold_bounty", "modifiers/modifier_gold_bounty.lua", LUA_MODIFIER_MOTION_NONE)

    if hero:GetUnitName() == "npc_dota_hero_wisp" then
      hero:SetModelScale(0.001)
      hero:AddNewModifier(hero, nil, "modifier_hero_selection", nil)
      hero:SetOriginalModel("models/development/invisiblebox.vmdl")

      hero:ModifyGold(-600, false, DOTA_ModifyGold_Unspecified)
      return nil
    end

    hero.attachments = {}

    if hero:GetPrimaryAttribute() == 2 and hero:GetUnitName() ~= "npc_dota_hero_silencer" then hero:AddNewModifier(hero, hero:GetAbilityByIndex(0), "modifier_silencer_int_steal", nil) end

    if not hero:HasModifier("modifier_kill") and not hero:IsIllusion() and not hero:IsTempestDouble() then
        -----hero:AddNewModifier(hero, hero:GetAbilityByIndex(0), "modifier_gold_bounty", nil)
      
        --[[ParticleManager:CreateParticleForPlayer("particles/rain_fx/econ_moonlight.vpcf", PATTACH_EYES_FOLLOW, hero, hero:GetPlayerOwner())
        ParticleManager:CreateParticleForPlayer("particles/rain_fx/econ_rain.vpcf", PATTACH_EYES_FOLLOW, hero, hero:GetPlayerOwner())]]
      
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "drodo_duffin") == true then
            PrecacheUnitByNameAsync("npc_dota_companion", function()
                local unit = CreateUnitByName( "npc_dota_companion", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                unit:AddNewModifier(hero, nil, "modifier_pet", {id = hero:GetPlayerID()})
                unit:AddNewModifier(hero, nil, "modifier_pet_model", {model = "models/pets/drodo/drodo.vmdl"})
            
                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/pets/pet_drodo_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true )
                ParticleManager:ReleaseParticleIndex(nFXIndex)
            end)
        end
      
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "star_emblem") == true then
            local nFXIndex = ParticleManager:CreateParticle( "particles/star_emblem/star_emblem_hero_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "star_emblem_4") == true then
            local nFXIndex = ParticleManager:CreateParticle( "particles/yellow_water_effect/yellow_water.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "ocean_emblem") == true then
            local nFXIndex = ParticleManager:CreateParticle( "particles/red_regen_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "platinum_emblem") == true then
            local nFXIndex = ParticleManager:CreateParticle( "particles/platinum_emblem/platinum_emblem.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "star_emblem_green") == true then
            local nFXIndex = ParticleManager:CreateParticle( "particles/red_emblem/red_emblem.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "red_emblem") == true then
            local nFXIndex = ParticleManager:CreateParticle( "particles/red_wateryellow_water_effect/red_water.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "star_emblem_2") == true then
            local nFXIndex = ParticleManager:CreateParticle( "particles/star_emblem_3/star_emblem_3_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "star_emblem_3") == true then
            local nFXIndex = ParticleManager:CreateParticle( "particles/econ/events/ti9/ti9_emblem_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "dark_emblem_2") == true then
            local nFXIndex = ParticleManager:CreateParticle( "particles/hero_effects/green_hero_effect_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:ReleaseParticleIndex(nFXIndex)
        end
      
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "icewrack_wolf") == true then
            PrecacheUnitByNameAsync("npc_dota_companion", function()
                local unit = CreateUnitByName( "npc_dota_companion", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                unit:AddNewModifier(hero, nil, "modifier_pet", {id = hero:GetPlayerID()})
                unit:AddNewModifier(hero, nil, "modifier_pet_model", {model = "models/pets/icewrack_wolf/icewrack_wolf.vmdl"})
            
                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/puck/puck_snowflake/puck_snowflake_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true )
                ParticleManager:SetParticleControlEnt( nFXIndex, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true )
                ParticleManager:ReleaseParticleIndex(nFXIndex)
            end)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "arsen") == true then
            PrecacheUnitByNameAsync("npc_dota_companion", function()
                local unit = CreateUnitByName( "npc_dota_companion", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                unit:AddNewModifier(hero, nil, "modifier_pet", {id = hero:GetPlayerID()})
                unit:AddNewModifier(hero, nil, "modifier_pet_model", {model = "models/pets/per_jopka/arsene.vmdl"})
            
                SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/pets/per_jopka/attachments.vmdl"}):FollowEntity(unit, true)
            end)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "nezuko") == true then
            PrecacheUnitByNameAsync("npc_dota_companion", function()
                local unit = CreateUnitByName( "npc_dota_companion", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                unit:AddNewModifier(hero, nil, "modifier_pet", {id = hero:GetPlayerID()})
                unit:AddNewModifier(hero, nil, "modifier_pet_model", {model = "models/pets/nezuko_pet/nezuko.vmdl"})

                SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/pets/nezuko_pet/hair.vmdl"}):FollowEntity(unit, true)
            end)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "kawaii") == true then
            PrecacheUnitByNameAsync("npc_dota_companion", function()
                local unit = CreateUnitByName( "npc_dota_companion", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                unit:AddNewModifier(hero, nil, "modifier_pet", {id = hero:GetPlayerID()})
                unit:AddNewModifier(hero, nil, "modifier_pet_model", {model = "models/pets/kawaii_pet/kawaii.vmdl"})
            
                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_trail_orbit/courier_trail_orbit.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
                ParticleManager:SetParticleControl( nFXIndex, 15, Vector(255, 105, 180) )
                ParticleManager:SetParticleControl( nFXIndex, 16, Vector(255, 105, 180) )
                ParticleManager:ReleaseParticleIndex(nFXIndex)

                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6_knockback_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
                ParticleManager:ReleaseParticleIndex(nFXIndex)
            end)
        end
      
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "otto_dragon") == true then
            PrecacheUnitByNameAsync("npc_dota_companion", function()
                local unit = CreateUnitByName( "npc_dota_companion", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                unit:AddNewModifier(hero, nil, "modifier_pet", {id = hero:GetPlayerID()})
                unit:AddNewModifier(hero, nil, "modifier_pet_model", {model = "models/pets/osky/osky.vmdl"})
            
                local nFXIndex = ParticleManager:CreateParticle( "particles/econ/pets/otto_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit )
                ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_eye_l", unit:GetOrigin(), true )
                ParticleManager:SetParticleControlEnt( nFXIndex, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetOrigin(), true )
                ParticleManager:SetParticleControlEnt( nFXIndex, 2, unit, PATTACH_POINT_FOLLOW, "attach_eye_l", unit:GetOrigin(), true )
            
                ParticleManager:SetParticleControl( nFXIndex, 15, Vector(79, 216, 11) )
                ParticleManager:SetParticleControl( nFXIndex, 16, Vector(1, 0, 0) )
                ParticleManager:ReleaseParticleIndex(nFXIndex)
            end)
        end
      
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "argentum_swoedsmith") == true then
            PrecacheUnitByNameAsync("npc_dota_companion", function()
                local unit = CreateUnitByName( "npc_dota_companion", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                unit:AddNewModifier(hero, nil, "modifier_pet", {id = hero:GetPlayerID()})
                unit:AddNewModifier(hero, nil, "modifier_pet_model", {model = "models/heroes/hero_elsa/elsa.vmdl"})
            end)
        end
      
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "celty") == true then
            PrecacheUnitByNameAsync("npc_dota_companion", function()
                local unit = CreateUnitByName( "npc_dota_companion", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                unit:AddNewModifier(hero, nil, "modifier_pet", {id = hero:GetPlayerID()})
                unit:AddNewModifier(hero, nil, "modifier_pet_model", {model = "models/pets/celty_pet/celty.vmdl"})
            end)
        end
      
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "acolyte_of_lost_arts") == true then
            PrecacheUnitByNameAsync("npc_dota_companion", function()
                local unit = CreateUnitByName( "npc_dota_companion", hero:GetAbsOrigin(), true, hero, hero, hero:GetTeamNumber())
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                unit:AddNewModifier(hero, nil, "modifier_pet", {id = hero:GetPlayerID()})
                unit:AddNewModifier(hero, nil, "modifier_pet_model", {model = "models/heroes/invoker_kid/invoker_kid.vmdl"})
            
                SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/invoker_kid/invoker_kid_cape.vmdl"}):FollowEntity(unit, true)
                SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/invoker_kid/invoker_kid_hair.vmdl"}):FollowEntity(unit, true)
            end)
        end
      end
      
    --[[local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
           
        end
        model = model:NextMovePeer()
    end--]]

    Util:UpdateWearables(hero, hero:GetPlayerOwnerID())

    ----if stats.has_plus(hero:GetPlayerOwnerID()) then stats.request_hero_data(hero:GetUnitName()) end

    if PlayerResource:GetSteamAccountID(hero:GetPlayerOwnerID()) == 902551462 then
        LinkLuaModifier("modifier_st_res" , "modifiers/modifier_status_resist.lua", LUA_MODIFIER_MOTION_NONE)

        hero:AddNewModifier(hero, nil, "modifier_st_res", nil)
    end

    for i = 0, 15, 1 do  
        local current_ability = hero:GetAbilityByIndex(i)
        if current_ability ~= nil then
            current_ability:OnSpawnedForFirstTime()
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_pudge" then
        if hero:HasAbility("pudge_flesh_heap_lua") then
            hero:FindAbilityByName("pudge_flesh_heap_lua"):SetLevel(1)
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_invoker" then
        if hero:HasAbility("collector_collect") then
            hero:FindAbilityByName("collector_collect"):SetLevel(1)
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_ezekyle" then
        if hero:HasAbility("ezekyle_dark_gods_bless") then
            hero:FindAbilityByName("ezekyle_dark_gods_bless"):SetLevel(1)
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_furion" then
        if hero:HasAbility("dimm_demons_power") then
            hero:FindAbilityByName("dimm_demons_power"):SetLevel(1)
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_faceless_void" then
        if hero:HasAbility("beyonder_void_explosion") then
            hero:FindAbilityByName("beyonder_void_explosion"):SetLevel(1)
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_pangolier" then
        Attachments:AttachProp(hero, "attach_attack2", "models/heroes/hero_celebrimbor/bow.vmdl", 1)
    end
    if hero:GetUnitName() == "npc_dota_hero_chaos_knight" then
        LinkLuaModifier("modifier_ghost_rider", "modifiers/modifier_ghost_rider.lua", LUA_MODIFIER_MOTION_NONE)

        hero:AddNewModifier(hero, nil, "modifier_ghost_rider", nil)
    end
    if hero:GetUnitName() == "npc_dota_hero_morphling" then
        ParticleManager:CreateParticle( "particles/units/heroes/hero_bloodseeker/bloodseeker_thirst_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
    end
    if hero:GetUnitName() == "npc_dota_hero_ogre" then
        hero:FindAbilityByName("ogre_mage_passive"):SetLevel(1)
    end
    if hero:GetUnitName() == "npc_dota_hero_jetstream_sam" then
        hero:FindAbilityByName("sam_zandatsu"):SetLevel(1)
    end
    if hero:GetUnitName() == "npc_dota_hero_enchantress" then
        hero:FindAbilityByName("tracer_pulse_bomb"):SetLevel(1)
    end
    if hero:GetUnitName() == "dota_fountain" then
        hero:FindAbilityByName("fountain_protection"):SetLevel(1)
    end
    if hero:GetUnitName() == "npc_dota_hero_drow_ranger" then
        Attachments:AttachProp(hero, "attach_attack1", "models/items/windrunner/rainmaker_bow/rainmaker_bow.vmdl", 1)
        if PlayerResource:GetSteamAccountID(hero:GetPlayerOwnerID()) == 77291876 then hero:SetMaterialGroup("blue") end
    end
    if hero:GetUnitName() == "npc_dota_hero_bristleback" then
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "whispers_of_the_dead") == true then
            local mask1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/vengeful_ghost_captain_head/vengeful_ghost_captain_head.vmdl"})
            mask1:FollowEntity(hero, true)
        else
            local mask1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_davy_jones/javy_jones_head.vmdl"})
            mask1:FollowEntity(hero, true)
            mask1:SetRenderColor(119, 136, 153)
        end

        local mask2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/claddish_gloves/claddish_gloves.vmdl"})
        mask2:FollowEntity(hero, true)

        local mask3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/claddish_legs/claddish_legs.vmdl"})
        mask3:FollowEntity(hero, true)

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "neptunes_faith") == true then
            local mask4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/kunkka_immortal/kunkka_shoulder_immortal.vmdl"})
            mask4:FollowEntity(hero, true)

            ParticleManager:CreateParticle( "particles/econ/items/kunkka/kunkka_immortal/kunkka_immortal_ambient_alt.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask4 )
        else
            local mask4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/claddish_shoulder/claddish_shoulder.vmdl"})
            mask4:FollowEntity(hero, true)
        end


        local mask5 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/inquisitor_tide_belt/inquisitor_tide_belt.vmdl"})
        mask5:FollowEntity(hero, true)

        local mask6 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/inquisitor_tide_back/inquisitor_tide_back.vmdl"})
        mask6:FollowEntity(hero, true)

        local mask7 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/inquisitor_tide_shoulder/inquisitor_tide_shoulder.vmdl"})
        mask7:FollowEntity(hero, true)

        local mask8 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/inquisitor_tide_misc/inquisitor_tide_misc.vmdl"})
        mask8:FollowEntity(hero, true)

        local mask9 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/kunkka/arm_lev_neptunian_sabre/arm_lev_neptunian_sabre.vmdl"})
        mask9:FollowEntity(hero, true)
    end

    if hero:GetUnitName() == "npc_dota_hero_disruptor" then
        LinkLuaModifier("modifier_z_delta", "modifiers/modifier_z_delta.lua", LUA_MODIFIER_MOTION_NONE)

        hero:AddNewModifier(hero, nil, "modifier_z_delta", nil)
    end

    if hero:GetUnitName() == "npc_dota_hero_antimage" then
        LinkLuaModifier("modifier_daredevil", "modifiers/modifier_daredevil.lua", LUA_MODIFIER_MOTION_NONE)

        hero:AddNewModifier(hero, nil, "modifier_daredevil", nil)
    end
    if hero:GetUnitName() == "npc_dota_hero_ogre_magi" then
        LinkLuaModifier("modifier_spell_amp", "modifiers/modifier_spell_amp.lua", LUA_MODIFIER_MOTION_NONE)

        hero:AddNewModifier(hero, nil, "modifier_spell_amp", nil)
    end
    if hero:GetUnitName() == "npc_dota_hero_night_stalker" then
        local hasItem = false

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "bolt_arcana") == true and not hasItem then
            hasItem = true

            LinkLuaModifier("modifier_bolt_arcana" , "modifiers/modifier_bolt_arcana.lua", LUA_MODIFIER_MOTION_NONE)
            hero:AddNewModifier(hero, nil, "modifier_bolt_arcana", nil)

            hero:SetOriginalModel("models/black_bolt/black_bolt_arcana/black_bolt_arcana.vmdl")

            local HeroPFX = ParticleManager:CreateParticle( "particles/hero_black_bolt/arcana/black_bolt_arcana_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:SetParticleControl( HeroPFX, 15, Vector(0, 199, 255) )
            ParticleManager:SetParticleControl( HeroPFX, 16, Vector(1, 0, 0) )

            local weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/black_bolt/black_bolt_arcana/abysm_outworld_staff.vmdl"})
            weapon:FollowEntity(hero, true)
            local weaponPFX = ParticleManager:CreateParticle( "particles/hero_black_bolt/arcana/black_bolt_arcana_weapon_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, weapon )
            ParticleManager:SetParticleControlEnt( weaponPFX, 0, weapon, PATTACH_POINT_FOLLOW, "attach_weapon" , weapon:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( weaponPFX, 1, weapon, PATTACH_POINT_FOLLOW, "attach_weapon2" , weapon:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( weaponPFX, 4, weapon, PATTACH_POINT_FOLLOW, "attach_weapon2" , weapon:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( weaponPFX, 8, weapon, PATTACH_POINT_FOLLOW, "attach_cornerL" , weapon:GetOrigin(), true )

            local weaponPFX2 = ParticleManager:CreateParticle( "particles/hero_black_bolt/arcana/black_bolt_arcana_weapon_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, weapon )
            ParticleManager:SetParticleControlEnt( weaponPFX2, 0, weapon, PATTACH_POINT_FOLLOW, "attach_weapon" , weapon:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( weaponPFX2, 1, weapon, PATTACH_POINT_FOLLOW, "attach_weapon2" , weapon:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( weaponPFX2, 4, weapon, PATTACH_POINT_FOLLOW, "attach_weapon2" , weapon:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( weaponPFX2, 8, weapon, PATTACH_POINT_FOLLOW, "attach_cornerR" , weapon:GetOrigin(), true )

            local head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/black_bolt/black_bolt_arcana/abysm_outworld_helmet.vmdl"})
            head:FollowEntity(hero, true)

            local mask24 = ParticleManager:CreateParticle( "particles/hero_black_bolt/arcana/black_bolt_arcana_eyes.vpcf", PATTACH_ABSORIGIN_FOLLOW, head )
            ParticleManager:SetParticleControlEnt( mask24, 0, head, PATTACH_POINT_FOLLOW, "attach_eye_l" , head:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask24, 1, head, PATTACH_POINT_FOLLOW, "attach_eye_r" , head:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask24, 2, head, PATTACH_POINT_FOLLOW, "attach_eye_l" , head:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask24, 3, head, PATTACH_POINT_FOLLOW, "attach_eye_r" , head:GetOrigin(), true )
        end
    end
    if hero:GetUnitName() == "npc_dota_hero_troll_warlord" then
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "ronan_weapon_shadowmorne") == true then
            local mask2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_ronan/econs/ronan_shadowmourne.vmdl"})
            mask2:FollowEntity(hero, true)
        elseif Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "ronan_eternity_hammer") == true then
            LinkLuaModifier("modifier_ronan_hammer" , "modifiers/modifier_ronan_hammer.lua", LUA_MODIFIER_MOTION_NONE)
            hero:AddNewModifier(hero, nil, "modifier_ronan_hammer", nil)

            local mask2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_ronan/econs/ronan_ethernal_hammer.vmdl"})
            mask2:FollowEntity(hero, true)

            local mask222 = ParticleManager:CreateParticle( "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_hammer_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask2 )
            ParticleManager:SetParticleControlEnt( mask222, 0, mask2, PATTACH_POINT_FOLLOW, "attach_corner" , mask2:GetOrigin(), true )
        else SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_ronan/econs/ronan_weapon.vmdl"}):FollowEntity(hero, true) end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "ronan_armor_mail") == true then
            local ronan_armor_mail = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_ronan/econs/ronan_moltenclaw.vmdl"})
            ronan_armor_mail:FollowEntity(hero, true)
            local ronan_armor_mailPFX = ParticleManager:CreateParticle( "particles/econ/items/axe/axe_armor_molten_claw/axe_molten_claw_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ronan_armor_mail )
        end
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "ronan_vanguard") == true then
            local ronan_vanguard = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_ronan/econs/ronan_vanguard.vmdl"})
            ronan_vanguard:FollowEntity(hero, true)
        end
    end
    if hero:GetUnitName() == "npc_dota_hero_warlock" then
        local pudge_donat = ParticleManager:CreateParticle( "particles/units/heroes/hero_zeus/zeus_ambient_eyes.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( pudge_donat, 0, hero, PATTACH_POINT_FOLLOW, "attach_eye_l" , hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( pudge_donat, 1, hero, PATTACH_POINT_FOLLOW, "attach_eye_l" , hero:GetOrigin(), true )

        local pudge_donat2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_zeus/zeus_ambient_eyes.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( pudge_donat2, 0, hero, PATTACH_POINT_FOLLOW, "attach_eye_r" , hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( pudge_donat2, 1, hero, PATTACH_POINT_FOLLOW, "attach_eye_r" , hero:GetOrigin(), true )

        local pudge_donat3 = ParticleManager:CreateParticle( "particles/units/heroes/hero_zeus/zeus_ambient_hands.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( pudge_donat3, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1" , hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( pudge_donat3, 1, hero, PATTACH_POINT_FOLLOW, "attach_attack2" , hero:GetOrigin(), true )

        local cloud2 = ParticleManager:CreateParticle( "particles/world_shrine/radiant_shrine_regen.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( cloud2, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetOrigin(), true )
    end
    if hero:GetUnitName() == "npc_dota_hero_batrider" then
        LinkLuaModifier ("modifier_godspeed_tempest_double_scepter", "abilities/godspeed_tempest_double.lua", LUA_MODIFIER_MOTION_NONE)
        hero:AddNewModifier(hero, nil, "modifier_godspeed_tempest_double_scepter", nil)

        hero:FindAbilityByName("godspeed_tempest_double"):SetLevel(1)

        local pudge_donat = ParticleManager:CreateParticle( "particles/econ/items/bounty_hunter/bounty_hunter_ursine/bounty_hunter_usrine_eyes_base_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( pudge_donat, 0, hero, PATTACH_POINT_FOLLOW, "attach_eye_l" , hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( pudge_donat, 1, hero, PATTACH_POINT_FOLLOW, "attach_eye_l" , hero:GetOrigin(), true )

        local pudge_donat2 = ParticleManager:CreateParticle( "particles/econ/items/bounty_hunter/bounty_hunter_ursine/bounty_hunter_usrine_eyes_base_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( pudge_donat2, 0, hero, PATTACH_POINT_FOLLOW, "attach_eye_r" , hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( pudge_donat2, 1, hero, PATTACH_POINT_FOLLOW, "attach_eye_r" , hero:GetOrigin(), true )

        local pudge_donat3 = ParticleManager:CreateParticle( "particles/units/heroes/hero_zeus/zeus_ambient_hands.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( pudge_donat3, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1" , hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( pudge_donat3, 1, hero, PATTACH_POINT_FOLLOW, "attach_attack2" , hero:GetOrigin(), true )

        local cloud2 = ParticleManager:CreateParticle( "particles/hero_godspeed/godspeed_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( cloud2, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetOrigin(), true )
    end

    if hero:GetUnitName() == "npc_dota_hero_centaur" then
        hero:SetRenderColor(0, 0 ,0)
        local mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/black_flash/black_flash_head_final.vmdl"})
        mask:FollowEntity(hero, true)
        mask:SetRenderColor(255, 69, 0)

        local mask1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/silencer/bts_final_utterance_shoulder/bts_final_utterance_shoulder.vmdl"})
        mask1:FollowEntity(hero, true)
        mask1:SetRenderColor(255, 69, 0)
    end
    if hero:GetUnitName() == "npc_dota_hero_shadow_shaman" then
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "iron_fist_golden_ways_of_faith") == true then
            local cape = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_ironfist/econs/waiths_of_faith.vmdl"})
            cape:FollowEntity(hero, true)
            cape:SetMaterialGroup("gold")

            ParticleManager:CreateParticle( "particles/econ/ironfist_golden_item.vpcf", PATTACH_ABSORIGIN_FOLLOW, cape )
            ParticleManager:CreateParticle( "particles/hero_iron_fist/iron_fist_iron_strike_immortal_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        elseif Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "iron_fist_ways_of_faith") == true then
            local cape = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_ironfist/econs/waiths_of_faith.vmdl"})
            cape:FollowEntity(hero, true)

            ParticleManager:CreateParticle( "particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, cape )
        end
    end
    if hero:GetUnitName() == "npc_dota_hero_bane" then
        local pudge_donat = ParticleManager:CreateParticle( "particles/econ/items/pugna/pugna_ward_ti5/pugna_ambient_eyes_ti_5.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( pudge_donat, 0, hero, PATTACH_POINT_FOLLOW, "attach_eye_l" , hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( pudge_donat, 1, hero, PATTACH_POINT_FOLLOW, "attach_eye_l" , hero:GetOrigin(), true )

        local pudge_donat2 = ParticleManager:CreateParticle( "particles/econ/items/pugna/pugna_ward_ti5/pugna_ambient_eyes_ti_5.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( pudge_donat2, 0, hero, PATTACH_POINT_FOLLOW, "attach_eye_r" , hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( pudge_donat2, 1, hero, PATTACH_POINT_FOLLOW, "attach_eye_r" , hero:GetOrigin(), true )
    end
    if hero:GetUnitName() == "npc_dota_hero_death_prophet" then
        local oracle_false_promise_planet = ParticleManager:CreateParticle( "particles/units/heroes/hero_oracle/oracle_ambient_ball.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( oracle_false_promise_planet, 0, hero, PATTACH_POINT_FOLLOW, "attach_orb" , hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( oracle_false_promise_planet, 2, hero, PATTACH_POINT_FOLLOW, "attach_orb" , hero:GetOrigin(), true )
    end
    if hero:GetUnitName() == "npc_dota_hero_omniknight" then
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "thor_helmet") then
            local mask4 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_thor/helmet_of_the_thundergod.vmdl"})
            mask4:FollowEntity(hero, true)
        elseif Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "deus_vult") then
            SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_thor/econs/source/thor_helmet.vmdl"}):FollowEntity(hero, true)
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "thor_sulfuras") then
            LinkLuaModifier("modifier_thor_sulfuras", "modifiers/modifier_thor_sulfuras.lua", LUA_MODIFIER_MOTION_NONE)
            hero:AddNewModifier(hero, nil, "modifier_thor_sulfuras", nil)
            local mask1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_thor/sulfuras/thor_sulfuras.vmdl"})
            mask1:FollowEntity(hero, true)

            local sulfuras = ParticleManager:CreateParticle( "particles/econ/courier/courier_greevil_red/courier_greevil_red_ambient_3.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask1 )
            ParticleManager:SetParticleControlEnt( sulfuras, 0, mask1, PATTACH_POINT_FOLLOW, "attach_weapon" , mask1:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( sulfuras, 1, mask1, PATTACH_POINT_FOLLOW, "attach_weapon" , mask1:GetOrigin(), true )
            ParticleManager:SetParticleControl( sulfuras, 8, Vector(1, 0, 0))
        elseif Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "mjollnir") then
            SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_thor/econs/source/thor_mjollnir.vmdl"}):FollowEntity(hero, true)
        elseif Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "dawnbreaker") then
            local mask1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_thor/econs/source/thor_dawnbreaker.vmdl"})
            mask1:FollowEntity(hero, true)
            local pfx = ParticleManager:CreateParticle( "particles/econ/dawnbreaker.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask1 )
            ParticleManager:SetParticleControlEnt( pfx, 0, mask1, PATTACH_POINT_FOLLOW, "attach_sword" , mask1:GetOrigin(), true )
        else
            SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_thor/thor_weapon.vmdl"}):FollowEntity(hero, true)
        end
    end
    if hero:GetUnitName() == "npc_dota_hero_viper" then
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "the_mask_of_void") then
            local mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_ebony_maw/econs/mask_of_the_void/the_mask_of_void.vmdl"})
            mask:FollowEntity(hero, true)

            ParticleManager:CreateParticle( "particles/econ/courier/courier_trail_divine/courier_divine_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )

            local khan_donat = ParticleManager:CreateParticle( "particles/econ/items/lion/fish_stick/lion_fish_stick_eyes.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:SetParticleControlEnt( khan_donat, 0, hero, PATTACH_POINT_FOLLOW, "attach_eye_l" , hero:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( khan_donat, 1, hero, PATTACH_POINT_FOLLOW, "attach_eye_r" , hero:GetOrigin(), true )
        end
    end
    if hero:GetUnitName() == "npc_dota_hero_oracle" then
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "anubis_jugment") then
            hero:AddNewModifier(hero, nil, "modifier_arcana", nil)
            local mask1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_oblivion/anubis_jujment/anubis_jugment.vmdl"})
            mask1:SetParent(hero, nil)
            mask1:FollowEntity(hero, true)
            mask1:SetOwner(hero)

            local mask1_particle3 = ParticleManager:CreateParticle( "particles/units/heroes/hero_bane/bane_nightmare_inkblots.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            local mask1_particle4 = ParticleManager:CreateParticle( "particles/units/heroes/hero_bane/bane_nightmare_inkblots_thick.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            local mask1_particle5 = ParticleManager:CreateParticle( "particles/units/heroes/hero_bane/bane_nightmare_worms.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )


            local mask_particle2 = ParticleManager:CreateParticle( "particles/econ/courier/courier_roshan_desert_sands/courier_roshan_desert_sands_eyes.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask1 )
            ParticleManager:SetParticleControlEnt( mask_particle2, 0, mask1, PATTACH_POINT_FOLLOW, "attach_eye_r" , mask1:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask_particle2, 1, mask1, PATTACH_POINT_FOLLOW, "attach_eye_l" , mask1:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask_particle2, 2, mask1, PATTACH_POINT_FOLLOW, "attach_eye_l" , mask1:GetOrigin(), true )
        else
            local mask1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/oracle/head_item.vmdl"})
            mask1:SetParent(hero, nil)
            mask1:FollowEntity(hero, true)
            mask1:SetOwner(hero)
        end

        local mask1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/oracle/armor.vmdl"})
        mask1:SetParent(hero, nil)
        mask1:FollowEntity(hero, true)
        mask1:SetOwner(hero)


        local mask2 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/oracle/back_item.vmdl"})
        mask2:SetParent(hero, nil)
        mask2:FollowEntity(hero, true)
        mask2:SetOwner(hero)


        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "oblivion_shard_of_creation") == true then
            local weapon = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/oracle/ti7_immortal_weapon/oracle_ti7_immortal_weapon.vmdl"})
            weapon:SetParent(hero, nil)
            weapon:FollowEntity(hero, true)

            ParticleManager:CreateParticle( "particles/econ/items/oracle/oracle_fortune_ti7/oracle_fortune_ti7_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        else
            local mask3 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/oracle/weapon.vmdl"})
            mask3:SetParent(hero, nil)
            mask3:FollowEntity(hero, true)
            mask3:SetOwner(hero)
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_visage" then
        local nFXIndex = ParticleManager:CreateParticle( "particles/ragnaros/ragnaros_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, hero, PATTACH_POINT_FOLLOW, "attach_inner", hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, hero, PATTACH_POINT_FOLLOW, "attach_root", hero:GetOrigin(), true )
        ParticleManager:SetParticleControlEnt( nFXIndex, 3, hero, PATTACH_POINT_FOLLOW, "attach_root", hero:GetOrigin(), true )

        local eyes = ParticleManager:CreateParticle( "particles/econ/items/ancient_apparition/aa_blast_ti_5/aa_ti5_eyes.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        ParticleManager:SetParticleControlEnt( eyes, 0, hero, PATTACH_POINT_FOLLOW, "attach_eye_l" , hero:GetAbsOrigin(), true )
        ParticleManager:SetParticleControlEnt( eyes, 1, hero, PATTACH_POINT_FOLLOW, "attach_eye_r" , hero:GetAbsOrigin(), true )

        local scirt = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_ragnaros/ragnaros_skirt.vmdl"})
        scirt:FollowEntity(hero, true)
    end

    if hero:GetUnitName() == "npc_dota_hero_slardar" then
        hero:SetOriginalModel("models/heroes/hero_sauron_/sauron_.vmdl")
        SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_sauron_/econs/mace.vmdl"}):FollowEntity(hero, true)
    end

    if hero:GetUnitName() == "npc_dota_hero_beastmaster" then
        local ability = hero:FindAbilityByName("draks_flesh_heap")
        ability:SetLevel(1)
    end

    if hero:GetUnitName() == "npc_dota_hero_ember_spirit" then
        LinkLuaModifier("modifier_goldengod", "modifiers/modifier_goldengod.lua", LUA_MODIFIER_MOTION_NONE)
        hero:AddNewModifier(hero, nil, "modifier_goldengod", nil)
    end

    if hero:GetUnitName() == "npc_dota_hero_templar_assassin" then ---models/b2/b2.vmdl
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "neo_noir") then
            LinkLuaModifier("modifier_neo_noir", "modifiers/modifier_neo_noir.lua", LUA_MODIFIER_MOTION_NONE)
            hero:SetOriginalModel("models/b2/b2.vmdl")
            local mask5 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/b2/weapon/weapon.vmdl"})
            mask5:FollowEntity(hero, true)
            hero:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
            hero:AddNewModifier(hero, nil, "modifier_neo_noir", nil)
            return
        end
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "wanda_arcana") then
            hero:SetOriginalModel("models/heroes/hero_witch/wanda_arcana/wanda_arcana.vmdl")
            hero:AddNewModifier(hero, nil, "modifier_arcana", nil)
            local mask5_particle = ParticleManager:CreateParticle( "particles/witch/witch_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:SetParticleControlEnt( mask5_particle, 0, hero, PATTACH_POINT_FOLLOW, "attach_eye_l" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 1, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 2, hero, PATTACH_POINT_FOLLOW, "attach_eye_r" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 3, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 4, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 5, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 6, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask5_particle, 8, Vector(1, 0, 0) )
            ParticleManager:SetParticleControlEnt( mask5_particle, 9, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask5_particle, 15, Vector(255, 89, 0) )
            ParticleManager:SetParticleControl( mask5_particle, 16, Vector(1, 0, 0) )
            return
        end
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "scarlet_golden_armor") then
            local mask5 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_witch/wanda_immortal/wanda_belt_immortal.vmdl"})
            mask5:FollowEntity(hero, true)
            mask5:SetMaterialGroup("golden")
            local mask5_particle = ParticleManager:CreateParticle( "particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask5 )
            ParticleManager:SetParticleControlEnt( mask5_particle, 0, mask5, PATTACH_POINT_FOLLOW, "attach_armor" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 1, mask5, PATTACH_POINT_FOLLOW, "attach_armor" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 3, mask5, PATTACH_POINT_FOLLOW, "attach_armor" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 4, mask5, PATTACH_POINT_FOLLOW, "attach_armor" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask5_particle, 5, Vector(1, 1, 1) )
            ParticleManager:SetParticleControl( mask5_particle, 6, Vector(0, 0, 0) )


            local mask6_particle = ParticleManager:CreateParticle( "particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:SetParticleControlEnt( mask6_particle, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask6_particle, 1, hero, PATTACH_POINT_FOLLOW, "attach_eyeR" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask6_particle, 2, hero, PATTACH_POINT_FOLLOW, "attach_eyeL" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask6_particle, 15, Vector(255, 46, 1) )
            ParticleManager:SetParticleControl( mask6_particle, 16, Vector(1, 1, 1) )

            local mask9_particle = ParticleManager:CreateParticle( "particles/econ/items/axe/axe_cinder/axe_cinder_ambient_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask5 )
            ParticleManager:SetParticleControlEnt( mask9_particle, 0, mask5, PATTACH_POINT_FOLLOW, "attach_cape" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask9_particle, 6, Vector(1, 1, 1) )

            local mask11_particle = ParticleManager:CreateParticle( "particles/econ/items/lina/lina_ti7/lina_ti7_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask5 )
            ParticleManager:SetParticleControlEnt( mask11_particle, 0, mask5, PATTACH_POINT_FOLLOW, "attach_belt" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask11_particle, 6, Vector(1, 1, 1) )

            local mask10_particle = ParticleManager:CreateParticle( "particles/econ/items/templar_assassin/templar_assassin_focal/templar_assassin_meld_focal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        elseif Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "scarlet_armor") then
            local mask5 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_witch/wanda_immortal/wanda_belt_immortal.vmdl"})
            mask5:FollowEntity(hero, true)

            local mask5_particle = ParticleManager:CreateParticle( "particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask5 )
            ParticleManager:SetParticleControlEnt( mask5_particle, 0, mask5, PATTACH_POINT_FOLLOW, "attach_armor" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 1, mask5, PATTACH_POINT_FOLLOW, "attach_armor" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 3, mask5, PATTACH_POINT_FOLLOW, "attach_armor" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask5_particle, 4, mask5, PATTACH_POINT_FOLLOW, "attach_armor" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask5_particle, 5, Vector(1, 1, 1) )
            ParticleManager:SetParticleControl( mask5_particle, 6, Vector(0, 0, 0) )


            local mask6_particle = ParticleManager:CreateParticle( "particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:SetParticleControlEnt( mask6_particle, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask6_particle, 1, hero, PATTACH_POINT_FOLLOW, "attach_eyeR" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask6_particle, 2, hero, PATTACH_POINT_FOLLOW, "attach_eyeL" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask6_particle, 15, Vector(255, 46, 1) )
            ParticleManager:SetParticleControl( mask6_particle, 16, Vector(1, 1, 1) )

            local mask9_particle = ParticleManager:CreateParticle( "particles/econ/items/axe/axe_cinder/axe_cinder_ambient_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask5 )
            ParticleManager:SetParticleControlEnt( mask9_particle, 0, mask5, PATTACH_POINT_FOLLOW, "attach_cape" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask9_particle, 6, Vector(1, 1, 1) )

            local mask11_particle = ParticleManager:CreateParticle( "particles/econ/items/lina/lina_ti7/lina_ti7_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask5 )
            ParticleManager:SetParticleControlEnt( mask11_particle, 0, mask5, PATTACH_POINT_FOLLOW, "attach_belt" , mask5:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask11_particle, 6, Vector(1, 1, 1) )

            local mask10_particle = ParticleManager:CreateParticle( "particles/econ/items/templar_assassin/templar_assassin_focal/templar_assassin_meld_focal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
        end

        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "scarlet_weapon") then
            local mask8_particle = ParticleManager:CreateParticle( "particles/econ/items/templar_assassin/templar_assassin_focal/templar_assassin_meld_focal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            local mask7_particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_templar_assassin/templar_assassin_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:SetParticleControlEnt( mask7_particle, 0, hero, PATTACH_POINT_FOLLOW, "attach_handL" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask7_particle, 1, hero, PATTACH_POINT_FOLLOW, "attach_handR" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask7_particle, 2, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )

            local mask11_particle = ParticleManager:CreateParticle( "particles/econ/items/templar_assassin/templar_assassin_focal/ta_focal_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero )
            ParticleManager:SetParticleControlEnt( mask11_particle, 0, hero, PATTACH_POINT_FOLLOW, "attach_handL" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask11_particle, 1, hero, PATTACH_POINT_FOLLOW, "attach_head" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask11_particle, 2, hero, PATTACH_POINT_FOLLOW, "attach_handR" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask11_particle, 3, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask11_particle, 4, hero, PATTACH_POINT_FOLLOW, "attach_hitloc" , hero:GetAbsOrigin(), true )
            ParticleManager:SetParticleControl( mask11_particle, 5, Vector(1, 1, 1) )
            ParticleManager:SetParticleControl( mask11_particle, 6, Vector(0, 0, 0) )
            ParticleManager:SetParticleControl( mask11_particle, 7, Vector(0, 0, 0) )
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_huskar" then
        LinkLuaModifier("modifier_vader", "modifiers/modifier_vader.lua", LUA_MODIFIER_MOTION_NONE)
        hero:AddNewModifier(hero, nil, "modifier_vader", nil)
        SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/hero_vaider/weapon/weapon.vmdl"}):FollowEntity(hero, true)
    end

    if hero:GetUnitName() == "npc_dota_hero_lich" then
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "medivh_soul_catcher") == true then
            local mask = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/medivh_v2/the_god_of_magic/immortal_mask.vmdl"})
            mask:FollowEntity(hero, true)

            local medivh_eyes = ParticleManager:CreateParticle( "particles/econ/items/mirana/mirana_sapphire_sabrelynx/mirana_sabrelynx_eye_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask )
            ParticleManager:SetParticleControlEnt( medivh_eyes, 0, mask, PATTACH_POINT_FOLLOW, "attach_eye_l" , mask:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( medivh_eyes, 4, mask, PATTACH_POINT_FOLLOW, "attach_eye_l" , mask:GetOrigin(), true )

            local medivh_eyes2 = ParticleManager:CreateParticle( "particles/econ/items/mirana/mirana_sapphire_sabrelynx/mirana_sabrelynx_eye_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask )
            ParticleManager:SetParticleControlEnt( medivh_eyes2, 0, mask, PATTACH_POINT_FOLLOW, "attach_eye_r" , mask:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( medivh_eyes2, 4, mask, PATTACH_POINT_FOLLOW, "attach_eye_r" , mask:GetOrigin(), true )

            local mask_amb = ParticleManager:CreateParticle( "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, mask )
            ParticleManager:SetParticleControlEnt( mask_amb, 0, mask, PATTACH_POINT_FOLLOW, "attach_tail" , mask:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask_amb, 1, mask, PATTACH_POINT_FOLLOW, "attach_tail" , mask:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask_amb, 3, mask, PATTACH_POINT_FOLLOW, "attach_tail" , mask:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask_amb, 4, mask, PATTACH_POINT_FOLLOW, "attach_tail" , mask:GetOrigin(), true )
            ParticleManager:SetParticleControlEnt( mask_amb, 5, mask, PATTACH_POINT_FOLLOW, "attach_tail" , mask:GetOrigin(), true )
            ParticleManager:SetParticleControl( mask_amb, 6, Vector(0, 0, 0) )

            hero:SetMaterialGroup("immortal_mask")
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_dark_seer" then
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "out_mask") == true then
            local mask1 = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/silencer/the_hazhadal_magebreaker_head/the_hazhadal_magebreaker_head.vmdl"})
            mask1:FollowEntity(hero, true)
        end
    end

    if hero:GetUnitName() == "npc_dota_hero_earth_spirit" then
        if Util:PlayerEquipedItem(hero:GetPlayerOwnerID(), "beast_arcana") then
            LinkLuaModifier("modifier_beast_arcana", "modifiers/modifier_beast_arcana.lua", LUA_MODIFIER_MOTION_NONE)
            hero:SetOriginalModel("models/heroes/hero_beast/beast_arcana_alt1.vmdl")
            hero:AddNewModifier(hero, nil, "modifier_beast_arcana", nil)
        end
    end
end

function CDOTA_BaseNPC:HasTalent(talentName)
    if self:HasAbility(talentName) then
        if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end

function CDOTA_BaseNPC:WillReflectAnySpell()
    local modifiersList = {
        "modifier_item_lotus_orb_active",
        "modifier_item_sphere_target",
        "modifier_ebonymaw_nether_shield",
        "modifier_item_orb_of_osuvox",
        "modifier_item_void_orb_active",
        "modifier_roshan_spell_block"
    }
    for _, modifier in pairs(modifiersList) do
        if self:HasModifier(modifier) then return true end
    end
    return false
end

function CDOTA_BaseNPC:IsAbilityOnCooldown(ability)
    if self:HasAbility(ability) then return not self:FindAbilityByName(ability):IsCooldownReady() end
    return nil
end

function CDOTA_Ability_Lua:IsIgnoreCooldownReduction()
    if Util.abilities[self:GetAbilityName()]["IgnoreCooldownReduction"] ~= nil then
        if Util.abilities[self:GetAbilityName()]["IgnoreCooldownReduction"] == "1" or Util.abilities[self:GetAbilityName()]["IgnoreCooldownReduction"] == 1 then
            return true
        end
    end

    return false
end

function CDOTA_BaseNPC:FindTalentValue(talentName)
    if self:HasAbility(talentName) then
        return self:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end

function Util:FindTalentScriptFile(talentName)
    if Util.abilities and Util.abilities[talentName] and Util.abilities[talentName]["BaseClass"] == "special_bonus_undefined" then
        return Util.abilities[talentName]["ScriptFile"]
    end

    return nil
end

function CDOTABaseAbility:GetTalentSpecialValueFor(value)
    local base = self:GetSpecialValueFor(value)
    local talentName
    local valname = "value"
    local multiply = false
    local kv = self:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                    if m["LinkedSpecialBonusField"] then valname = m["LinkedSpecialBonusField"] end
                    if m["LinkedSpecialBonusOperation"] and m["LinkedSpecialBonusOperation"] == "SPECIAL_BONUS_MULTIPLY" then multiply = true end
                end
            end
        end
    end
    if talentName and self:GetCaster():HasTalent(talentName) then
        if multiply then
            base = base * talent:GetSpecialValueFor(valname)
        else
            base = base + talent:GetSpecialValueFor(valname)
        end
    end
    return base
end

function CDOTA_BaseNPC:SetGodeMode(tBool)
    LinkLuaModifier( "modifier_god", "modifiers/modifier_god.lua" ,LUA_MODIFIER_MOTION_NONE )
    if tBool == "true" then
        if self:HasModifier("modifier_god") then
            self:RemoveModifierByName("modifier_god")
        end
        self:AddNewModifier(self, nil, "modifier_god", nil)
    elseif tBool == "false" then
        if self:HasModifier("modifier_god") then
            self:RemoveModifierByName("modifier_god")
        end
    end
    return
end

function CDOTA_BaseNPC:SetDemiGodeMode(tBool)
    LinkLuaModifier( "modifier_demigod", "modifiers/modifier_demigod.lua" ,LUA_MODIFIER_MOTION_NONE )
    if tBool == "true" then
        if self:HasModifier("modifier_demigod") then
            self:RemoveModifierByName("modifier_demigod")
        end
        self:AddNewModifier(self, nil, "modifier_demigod", nil)
    elseif tBool == "false" then
        if self:HasModifier("modifier_demigod") then
            self:RemoveModifierByName("modifier_demigod")
        end
    end
    return
end

function CDOTA_BaseNPC:SwapDebuffs(hTarget)
    if not hTarget then
        return
    end
    local modifiers = self:FindAllModifiers()
    for _, mod in pairs(modifiers) do
        if mod and mod:GetDuration() > 0 and (mod:IsPurgable() or mod:IsPurgeException()) then
            local dur = mod:GetRemainingTime()
            local name = mod:GetName()
            local abil = mod:GetAbility()

            hTarget:AddNewModifier(self, abil, name, {duration = dur})

            mod:Destroy()
        end
    end
    return
end

function CDOTA_BaseNPC:CanReincarnate()
    local items = {
        "item_aegis",
        "item_frostmourne"
    }
    for _, item in pairs(items) do
        if self:FindItemInInventory(item) then
            if self:FindItemInInventory(item):IsCooldownReady() then
                return true
            end
        end
    end
    return false
end

function CDOTA_BaseNPC:RefreshUnit()
    for i=0, 15, 1 do  --The maximum number of abilities a unit can have is currently 16.
        local current_ability = self:GetAbilityByIndex(i)
        if current_ability ~= nil then
            current_ability:EndCooldown()
        end
    end

    --Refresh all items the caster has.
    for i=0, 5, 1 do
        local current_item = self:GetItemInSlot(i)
        if current_item ~= nil then
            current_item:EndCooldown()
        end
    end
    self:SetHealth(self:GetMaxHealth())
    self:SetMana(self:GetMaxMana())
end


function Util:SetupConsole()
    LinkLuaModifier("modifier_storm_spirit", "modifiers/modifier_storm_spirit.lua", LUA_MODIFIER_MOTION_NONE )
    LinkLuaModifier("modifier_io", "modifiers/modifier_customs.lua", LUA_MODIFIER_MOTION_NONE )

    Convars:RegisterCommand("ban", function(command, userid )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()
            if Util:PlayerHasAdminRules(pID) then
                local playerName = tostring(PlayerResource:GetPlayerName(tonumber(userid)))
                local msg =  playerName .. " left the game. (Account is untrusted)"
                GameRules:SendCustomMessage(msg, 0, 0)
                Timers:CreateTimer(15, function()
                    local res = "<font color=\"#ff0000\"> ".. playerName .." forever denied access to the official servers. (VAC ban) </font>"
                    GameRules:SendCustomMessage(res, 0, 0)

                    ---Network:BanPlayer(tonumber(userid))
                    local p = PlayerResource:GetPlayer(tonumber(userid))
                    local h = p:GetAssignedHero()

                    UTIL_Remove(h)
                    UTIL_Remove(p)
                end)
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Permanently ban a user with specific id", 0)

    Convars:RegisterCommand("clients_status", function()
        pcall(function() for i = 0, DOTA_MAX_PLAYERS do
            if PlayerResource:IsValidPlayerID(i) then
                local playerName = tostring(PlayerResource:GetPlayerName(i))
                GameRules:printd(playerName .. " as player ID: " .. i, Convars:GetCommandClient():GetPlayerID())
            end
        end end)
    end, "Print all players", 0)

    Convars:RegisterCommand("godmode", function(command, statement )
        local hero = Convars:GetCommandClient()
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            PlayerResource:GetPlayer(tonumber(Convars:GetCommandClient():GetPlayerID())):GetAssignedHero():SetGodeMode(statement)
        else
            Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
        end
    end, "Set on or off godmode", 0)

    Convars:RegisterCommand("demigod", function(command, statement )
        local hero = Convars:GetCommandClient()
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            PlayerResource:GetPlayer(tonumber(Convars:GetCommandClient():GetPlayerID())):GetAssignedHero():SetDemiGodeMode(statement)
        else
            Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
        end
    end, "Set on or off dimigod", 0)

    Convars:RegisterCommand("givegold", function(command, player, ammount )
        local pID = Convars:GetCommandClient():GetPlayerID()
        if Util:PlayerHasAdminRules(pID) then
            PlayerResource:ModifyGold(tonumber(player), tonumber(ammount), true, DOTA_ModifyGold_Unspecified)
        else
            Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
        end
    end, "Set gold", 0)

    Convars:RegisterCommand("levelup", function(command, player, ammount )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            local hero = PlayerResource:GetPlayer(tonumber(player)):GetAssignedHero()
            for i = 1, tonumber(ammount) do
                hero:HeroLevelUp(true)
            end
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Set hero level under specific id", 0)

    Convars:RegisterCommand("killallinradius", function(command, radius )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            local data = {
                radius = tonumber(radius),
                hero = Convars:GetCommandClient():entindex()
            }
            Util:KillUnitsInRadius(data)
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Kill all in radius", 0)

    Convars:RegisterCommand("killplayer", function(command, player )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            if PlayerResource:IsValidPlayerID(tonumber(player)) then
                local hero = PlayerResource:GetPlayer(tonumber(player)):GetAssignedHero()
                if hero then
                    hero:ForceKill(false)
                end
            end
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Kill player under specific pid", 0)

    Convars:RegisterCommand("giveitem", function(command, pid, item )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            if PlayerResource:IsValidPlayerID(tonumber(pid)) then
                local hero = PlayerResource:GetPlayer(tonumber(pid)):GetAssignedHero()
                local item_ = CreateItem(tostring(item), hero, hero)
                hero:AddItem(item_)
            end
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Give item for player", 0)

    Convars:RegisterCommand("giveitemtoall", function(command, item )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            local heroes = HeroList:GetAllHeroes()
            for k, unit in pairs(heroes) do
                local _item = CreateItem(tostring(item), unit, unit)
                unit:AddItem(_item)
            end
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Give item for all", 0)

    Convars:RegisterCommand("killall", function(command, item )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            local heroes = HeroList:GetAllHeroes()
            for k, unit in pairs(heroes) do
                if unit ~= hero then
                    unit:ForceKill(false)
                end
            end
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Kill all", 0)

    Convars:RegisterCommand("killallally", function(command )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            local heroes = HeroList:GetAllHeroes()
            for k, unit in pairs(heroes) do
                if unit ~= hero and unit:GetTeamNumber() == Convars:GetCommandClient():GetTeamNumber() then
                    unit:ForceKill(false)
                end
            end
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Kill all allies", 0)

    Convars:RegisterCommand("killallenemy", function(command )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            local heroes = HeroList:GetAllHeroes()
            for k, unit in pairs(heroes) do
                if unit ~= hero and unit:GetTeamNumber() ~= Convars:GetCommandClient():GetTeamNumber() then
                    unit:ForceKill(false)
                end
            end
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Kill all enemy", 0)

    Convars:RegisterCommand("refresh", function(command)
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            PlayerResource:GetPlayer(tonumber(Convars:GetCommandClient():GetPlayerID())):GetAssignedHero():RefreshUnit()
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Refresh", 0)

    Convars:RegisterCommand("createunit", function(command, name )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            PrecacheUnitByNameAsync(name, function()
                CreateUnitByName( tostring(name), Convars:GetCommandClient():GetAssignedHero():GetAbsOrigin(), true, Convars:GetCommandClient(), Convars:GetCommandClient():GetOwner(), Convars:GetCommandClient():GetTeamNumber()):SetControllableByPlayer(Convars:GetCommandClient():GetPlayerID(), false)
            end)
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Create unit", 0)

    Convars:RegisterCommand("wingame", function(command, team )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            if tonumber(team) == DOTA_TEAM_GOODGUYS then
                GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
            else
                GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
            end
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Win game", 0)


    Convars:RegisterCommand("setteam", function(command, palyer, team )
        if Util:PlayerHasAdminRules(Convars:GetCommandClient():GetPlayerID()) then
            PlayerResource:GetPlayer(tonumber(palyer)):GetAssignedHero():SetTeam(tonumber(team))
        else
            Warning("User with id as: " .. Convars:GetCommandClient():GetPlayerID() .. " is not allowed to issue this command!")
        end
    end, "Win game", 0)

    Convars:RegisterCommand("sethealth", function(command, health )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()
            if Util:PlayerHasAdminRules(pID) then
                local unit = PlayerResource:GetSelectedHeroEntity(pID)
                if unit and IsValidEntity(unit) then
                    unit:SetBaseMaxHealth(tonumber(health))
                end
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set Health of selected entitiy", 0)

    Convars:RegisterCommand("setdamage", function(command, damage )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()
            if Util:PlayerHasAdminRules(pID) then
                local unit = PlayerResource:GetSelectedHeroEntity(pID)
                if unit and IsValidEntity(unit) then
                    unit:SetBaseDamageMin(tonumber(damage))
                    unit:SetBaseDamageMax(tonumber(damage + 1))
                end
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set Health of selected entitiy", 0)

    Convars:RegisterCommand("setmagicarmor", function(command, damage )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()
            if Util:PlayerHasAdminRules(pID) then
                local unit = PlayerResource:GetSelectedHeroEntity(pID)
                if unit and IsValidEntity(unit) then
                    unit:SetBaseMagicalResistanceValue(tonumber(damage))
                end
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set Health of selected entitiy", 0)

    Convars:RegisterCommand("setagi", function(command, agility )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()
            if Util:PlayerHasAdminRules(pID) then
                local unit = PlayerResource:GetSelectedHeroEntity(pID)
                if unit and IsValidEntity(unit) then
                    unit:SetBaseAgility(tonumber(agility))
                end
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set Health of selected entitiy", 0)

    Convars:RegisterCommand("setint", function(command, int )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()
            if Util:PlayerHasAdminRules(pID) then
                local unit = PlayerResource:GetSelectedHeroEntity(pID)
                if unit and IsValidEntity(unit) then
                    unit:SetBaseIntellect(tonumber(int))
                end
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set Health of selected entitiy", 0)

    Convars:RegisterCommand("setstr", function(command, str )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()
            if Util:PlayerHasAdminRules(pID) then
                local unit = PlayerResource:GetSelectedHeroEntity(pID)
                if unit and IsValidEntity(unit) then
                    unit:SetBaseStrength(tonumber(str))
                end
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set Health of selected entitiy", 0)

    Convars:RegisterCommand("addability", function(command, ability )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()
            if Util:PlayerHasAdminRules(pID) then
                local unit = PlayerResource:GetSelectedHeroEntity(pID)
                if unit and IsValidEntity(unit) then
                    unit:AddAbility(ability)
                end
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set Health of selected entitiy", 0)

    Convars:RegisterCommand("settime", function(command, time )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()
            if Util:PlayerHasAdminRules(pID) then
                GameRules:SetTimeOfDay(tonumber(time))
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set time", 0)

    Convars:RegisterCommand("replace_hero", function(command )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()

            if PlayerResource:GetSteamAccountID(pID) == 246584391 or PlayerResource:GetSteamAccountID(pID) == 87670156 then
                PrecacheUnitByNameAsync( "npc_dota_hero_spirit_breaker", function()
                    local nHero = PlayerResource:ReplaceHeroWith(pID, "npc_dota_hero_spirit_breaker", 0, 0)
                    nHero:RespawnHero(false, false)
                end)
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set time", 0)
    Convars:RegisterCommand("replace_hero_d", function(command )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()

            if PlayerResource:GetSteamAccountID(pID) == 246584391 or PlayerResource:GetSteamAccountID(pID) == 87670156 then
                PrecacheUnitByNameAsync( "npc_dota_hero_phoenix", function()
                    local nHero = PlayerResource:ReplaceHeroWith(pID, "npc_dota_hero_phoenix", 0, 0)
                    nHero:RespawnHero(false, false)
                    PlayerResource:ModifyGold(pID, 800, true, 0)
                end)
            else
                Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
            end
        end)
    end, "Set time", 0)
    Convars:RegisterCommand("test_get_data", function(command )
        pcall(function()
            local pID = Convars:GetCommandClient():GetPlayerID()

            ---stats.test()
        end)
    end, "Set time", 0)
    Convars:RegisterCommand("print_dedicated_server_key", function(command )
        local pID = Convars:GetCommandClient():GetPlayerID()

        if Util:PlayerHasAdminRules(pID) then
            Util:printp(GetDedicatedServerKeyV2("8.3"), pID)
        else
            Warning("User with id as: " .. pID .. " is not allowed to issue this command!")
        end
    end, "Set time", 0)
end

function Util:printp( msg, pID )
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(pID), "print_to_client", {data = msg})
end

function HeroIsSelectedAlready(hero_name)
    local heroes = HeroList:GetAllHeroes()

    for _, hero in pairs(heroes) do
        if hero:GetUnitName() == hero_name then
            return true
        end
    end

    return false
end

function IsHasSuperStatus(id)
    local data = CustomNetTables:GetTableValue("players", "stats")

    if data and data[tostring(id)] then
        return data[tostring(id)].shards == "1"
    end

    return false
end

function HasHero(id, heroID)
    local data = CustomNetTables:GetTableValue("players", "stats")

    if data and data[tostring(id)] then
        local num = tonumber(data[tostring(id)].shards)
        local band = bit.band(num, heroID)

        print(band)

        return band == heroID
    end

    return false
end

function Util:KillUnitsInRadius(data)
    local radius = data['radius']
    local hero = data['hero']
    if hero and radius then
        hero = EntIndexToHScript(hero)

        local units = FindUnitsInRadius( hero:GetTeamNumber(), hero:GetOrigin(), hero, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
        if #units > 0 then
            for _,unit in pairs(units) do
                unit:Kill(nil, hero)
            end
        end
    end
end

function Util:FindNearestTarget( ability )
    local units = FindUnitsInRadius( ability:GetCaster():GetTeamNumber(), ability:GetCaster():GetOrigin(), ability:GetCaster(), ability:GetSpecialValueFor("radius"), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false )
	if #units > 0 then
        for _,v in pairs(units) do
            if v ~= ability:GetCaster() then
                return v
            end
		end
	end

    return nil
end

function Util:CheckGameState()
    if GameRules.Players[DOTA_TEAM_GOODGUYS] then
        local state = true
        for _, pID in pairs(GameRules.Players[DOTA_TEAM_GOODGUYS]) do
            if not PlayerResource:GetConnectionState(pID) >= DOTA_CONNECTION_STATE_DISCONNECTED then
                state = false break
            end
        end

        if state then GameRules:EndGame(DOTA_TEAM_GOODGUYS) end
    end

    if GameRules.Players[DOTA_TEAM_BADGUYS] then
        local state = true
        for _, pID in pairs(GameRules.Players[DOTA_TEAM_BADGUYS]) do
            if not PlayerResource:GetConnectionState(pID) >= DOTA_CONNECTION_STATE_DISCONNECTED then
                state = false break
            end
        end

        if state then GameRules:EndGame(DOTA_TEAM_BADGUYS) end
    end
end

function Util:GetPlayersForTeam(team)
    local result = {}
    for i = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetTeam(i) == team then
            table.insert(result, i)
        end
    end

    return result
end

function Util:GetArrayLength(array)
    local result = 0
    for k,v in pairs(array) do
        result = result + 1
    end
    return result
end

function Util:DisplayError(pID, error)
    local player = PlayerResource:GetPlayer(pid)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "dota_hud_error_message", {message=error})
    end
end

function Util:IsTableContains( table, element )
    for _, v in pairs( table ) do
        if v == element then
            return true
        end
    end

    return false
end

function Util:SendCustomMessage(data)
    CustomGameEventManager:Send_ServerToAllClients("create_custom_message", data)
end

function CDOTA_BaseNPC:SetSkillBuild(skills)
    for i=0, 5 do
        local abil = self:GetAbilityByIndex(i)

        if abil then
            self:RemoveAbilityByHandle(abil)
        end
    end

    for i=1, 24 do
        local abil = skills["Ability"..i]
       
        if abil then
            local res = self:AddAbility(abil)

            print(res:GetAbilityName() .. " : " .. res:GetLevel())
        end
    end
end

function CDOTA_BaseNPC:SetCreatureHealth(health, update_current_health)

    self:SetBaseMaxHealth(health)
    self:SetMaxHealth(health)

    if update_current_health then
        self:SetHealth(health)
    end
end

function CDOTA_BaseNPC:CreateUnit(hCaster, duration)
    local double = CreateUnitByName( self:GetUnitName(), self:GetAbsOrigin(), true, self, self:GetOwner(), hCaster:GetTeamNumber())
    double:SetControllableByPlayer(hCaster:GetPlayerID(), false)

    if self:IsHero() then
        local caster_level = self:GetLevel()
        for i = 2, caster_level do
            double:HeroLevelUp(false)
        end


        for ability_id = 0, 15 do
            local ability = double:GetAbilityByIndex(ability_id)
            if ability then
                ability:SetLevel(self:GetAbilityByIndex(ability_id):GetLevel())
                if ability:GetName() == "dormammu_tempest_double" then
                    ability:SetActivated(false)
                end
            end
        end


        for item_id = 0, 5 do
            local item_in_caster = self:GetItemInSlot(item_id)
            if item_in_caster ~= nil then
                local item_name = item_in_caster:GetName()
                local item_created = CreateItem( item_in_caster:GetName(), double, double)
                double:AddItem(item_created)
            end
        end

        double:SetMaximumGoldBounty(0)
        double:SetMinimumGoldBounty(0)
        double:SetDeathXP(0)
        double:SetAbilityPoints(0)

        double:SetHasInventory(false)
        double:SetCanSellItems(false)
    end

    double:AddNewModifier(hCaster, self, "modifier_arc_warden_tempest_double", nil)
    double:AddNewModifier(hCaster, self, "modifier_kill", {["duration"] = duration})

    FindClearSpaceForUnit(double, double:GetAbsOrigin(), false)

    return double
end


function CDOTA_BaseNPC:HasTimeStone()
    return self:HasItemInInventory("item_time")
end

function CDOTA_BaseNPC:CreateIllusion(caster, ability, duration)
    local illusion = CreateUnitByName(self:GetUnitName(), self:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber())  --handle_UnitOwner needs to be nil, or else it will crash the game.
    illusion:SetPlayerID(caster:GetPlayerOwnerID())
    illusion:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

    --Level up the illusion to the caster's level.
    local caster_level = self:GetLevel()
    for i = 1, caster_level - 1 do
        illusion:HeroLevelUp(false)
    end

    --Set the illusion's available skill points to 0 and teach it the abilities the caster has.
    illusion:SetAbilityPoints(0)

    for ability_slot = 0, 15 do
        local individual_ability = self:GetAbilityByIndex(ability_slot)
        if individual_ability ~= nil then
            local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
            if illusion_ability ~= nil then
                illusion_ability:SetLevel(individual_ability:GetLevel())
            end
        end
    end

    --Recreate the caster's items for the illusion.
    for item_slot = 0, 5 do
        local individual_item = self:GetItemInSlot(item_slot)
        if individual_item ~= nil then
            local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
            illusion:AddItem(illusion_duplicate_item)
        end
    end

    illusion:AddNewModifier(caster, ability, "modifier_illusion", {duration = duration or 8, outgoing_damage = 100, incoming_damage = 100})
    illusion:MakeIllusion()

    return illusion
end

function Util:CreateCreep(unit_name, model, caster, kv, modifiers )
    PrecacheUnitByNameAsync(model, function()
        local unit = CreateUnitByName( unit_name, caster:GetAbsOrigin(), true, caster, caster:GetOwner(), caster:GetTeamNumber())
        unit:SetControllableByPlayer(caster:GetPlayerID(), false)

        if model then
            unit:SetOriginalModel(model)
        end

        for _, mod in pairs(modifiers) do
            unit:AddNewModifier(caster, self, mod, {duration = kv["duration"]})
        end

        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), false)

        return unit
    end)
end

function Util:OnCosmeticItemUpdated( data )
    pcall(function()
        local hero = PlayerResource:GetPlayer(data["PlayerID"]):GetAssignedHero()

        for k,v in pairs(hero.wearables) do
            UTIL_Remove(v)
        end

        for _, particle in pairs(hero.particles) do
            ParticleManager:DestroyParticle(particle, true)
        end

        for _, modifier in pairs(hero.modifiers) do
            modifier:Destroy()
        end

        local steam_id = PlayerResource:GetSteamAccountID(data["PlayerID"])
        steam_id = tostring(steam_id)
        local items = Util:GetItemID(string)
        if GameRules.Globals.Inventories then
            if GameRules.Globals.Inventories[steam_id] then
                for _, item in pairs(GameRules.Globals.Inventories[steam_id]) do
                    if item["id"] == tostring(data["item"]) then
                        local state = 1
                        if data["isRemove"] == 1 then
                            state = 0
                        end
                        item["state"] = tostring(state)
                        break
                    end
                end

                Util:UpdateWearables(hero, hero:GetPlayerOwnerID())
            end
        end
    end)
end


function Util:vector_unit( vector )
    local mag = Util:vector_magnitude(vector)
    return Vector(vector.x/math.sqrt(mag), vector.y/math.sqrt(mag))
end

function Util:vector_magnitude( vector )
    return vector.x * vector.x + vector.y * vector.y
end

function Util:vector_is_clockwise(v1, v2)
    return -v1.x * v2.y + v1.y * v2.x > 0
end

function CDOTA_Item:IsDroppableAfterDeath()
    if Util.items and Util.items[self:GetName()] and Util.items[self:GetName()]["DropOnDeath"] then
        return true
    end
    return false
end

function CDOTA_Modifier_Lua:GetClass()
    return "CDOTA_Modifier_Lua"
end

function CDOTABaseAbility:RegisterParams()
    
end

function CDOTA_Ability_Lua:RegisterParams()
    
end

function GetAbilityIcon(ability)
	local abilities = CustomNetTables:GetTableValue("players", "icons")

	if abilities and abilities[ability:entindex()] then 
		return abilities[ability:entindex()]
	end
	
    return ability.BaseClass.GetAbilityTextureName(ability)
end

function CDOTA_Ability_Lua:SetAbilityTexture( icon )
    Util.ability_icons[self:entindex()] = icon

    CustomNetTables:SetTableValue("players", "icons", Util.ability_icons)
end

function CDOTABaseAbility:SetAbilityTexture( icon )
   
end

function CDOTA_Ability_Lua:SetEffect( id, effect )
    self.effects_params[id] = effect
end

function CDOTA_Ability_Lua:OnAbilityLearned(ability, time) 

end

function CDOTABaseAbility:OnAbilityLearned(ability, time) 

end

function CDOTA_Ability_Lua:SetSound( id, sound )
    self.sound_params[id] = sound
end

function CDOTA_Ability_Lua:GetEffect( id, default )
    if (not self.effects_params) then return default end 

    return self.effects_params[id] or default
end

function CDOTA_Ability_Lua:GetSound( id, default )
    if (not self.sound_params) then return default end
 
    return self.sound_params[id] or default
end

function CDOTA_Buff:IsDebuff()
    return string.find(self:GetClass(), "debuff") ~= nil or string.find(self:GetClass(), "stun") ~= nil
end

function CDOTA_Buff:IsPermanent()
    return self:GetDuration() <= 0
end

function Util:OnAbilityWasUpgraded( ability, unit ) 
    if IsValidEntity(unit) then
        for i = 0, 15, 1 do 
            local current_ability = unit:GetAbilityByIndex(i)
            if current_ability ~= nil then
                current_ability:OnAbilityLearned(ability, GameRules:GetGameTime())
            end
        end
    end
end

function Util:OnModifierWasApplied( ability, unit, caster, modifier )
    if unit:HasModifier("modifier_fate_fatebind") and ability and caster ~= unit then
        local mod = unit:FindModifierByName("modifier_fate_fatebind")
        mod:OnModifierApplied({ability = ability, unit = unit, attacker = caster, modifier_name = modifier})
    end
end

function Util:LearnedAbility( params )
    stats.record(params.PlayerID, params, stats.RECORD_ENUM.ABILITY_LEARNED)
        
    if params.abilityname and params.PlayerID and string.find(params.abilityname, "special_bonus") ~= nil then
        Talents:OnTalentLearned(params.PlayerID, params.abilityname)
    end

    Util:OnAbilityWasUpgraded(params.abilityname, PlayerResource:GetSelectedHeroEntity(params.PlayerID))
end

function CDOTA_BaseNPC:Heal_Engine(flHeal)
    self:ModifyHealth(self:GetHealth() + flHeal, nil, false, 0)
end

function CDOTABaseAbility:IsUltimate() return self:GetMaxLevel() <= 3 end

function CDOTABaseAbility:OnSpawnedForFirstTime()  

end

function PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()

    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end

function Util:OnGauntletAbilitySelected( params )
    local hero = EntIndexToHScript(params.hero)

    local item = hero:FindItemInInventory("item_glove_of_the_creator")
    if item then item:SelectAbility(params.ability) end
end

function CDOTAGamerules:EndGame(team)
    local ancients = Entities:FindAllByClassname("npc_dota_fort")
    for _, ancient in pairs(ancients) do
        if (ancient:GetTeamNumber() == team) then ancient:ForceKill(false) return end
    end
end

function CDOTA_BaseNPC:GetPhysicalArmorReduction()
    local armornpc = self:GetPhysicalArmorValue( false )
    local armor_reduction = 1 - (0.06 * armornpc) / (1 + (0.06 * math.abs(armornpc)))
    armor_reduction = 100 - (armor_reduction * 100)
    return armor_reduction
end

function CDOTA_BaseNPC:GetTarget()
    local unit

    if IsServer() then
        local units = FindUnitsInRadius( self:GetTeamNumber(), self:GetOrigin(), self, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false )
        if #units > 0 then
            unit = units[1]
        end
    end

    return unit;
end


function CDOTA_BaseNPC:IsHasSuperStatus()
    return IsHasSuperStatus(self:GetPlayerOwnerID())
end

function CDOTA_BaseNPC_Hero:GetAllStats()
    return self:GetStrength() + self:GetAgility() + self:GetIntellect()
end


function Util:Setup()

end

function CDOTA_BaseNPC:GetBasePos()
    local ancients = Entities:FindAllByClassname("ent_dota_fountain")

    for k, ancient in pairs(ancients) do
        if ancient:GetTeamNumber() == self:GetTeamNumber() then return ancient:GetAbsOrigin() end
    end

    return self:GetAbsOrigin()
end

function CDOTA_BaseNPC:IsFriendly(target)
    return target:GetTeamNumber() == self:GetTeamNumber()
end

local gods =
{
    "npc_dota_hero_omniknight",
    "npc_dota_hero_phantom_lancer",
    "npc_dota_hero_abaddon",
    "npc_dota_hero_nyx_assassin",
    "npc_dota_hero_lone_druid",
    "npc_dota_hero_windrunner",
    "npc_dota_hero_earthshaker",
    "npc_dota_hero_enigma",
    "npc_dota_hero_ember_spirit",
    "npc_dota_hero_dazzle",
    "npc_dota_hero_rubick",
    "npc_dota_hero_monkey_king",
    "npc_dota_hero_bane",
    "npc_dota_hero_disruptor",
    "npc_dota_hero_oracle",
    "npc_dota_hero_dark_seer",
    "npc_dota_hero_shadow_demon",
    "npc_dota_hero_clinkz",
    "npc_dota_hero_obsidian_destroyer",
    "npc_dota_hero_leshrac",
    "npc_dota_hero_queenofpain"
}

function CDOTA_BaseNPC:IsGod()
    for _, hero in pairs(gods) do
        if self:GetUnitName() == hero then
            return true
        end
    end

    return false
end

local speedsters =
{
    "npc_dota_hero_weaver",
    "npc_dota_hero_savitar",
    "npc_dota_hero_godspeed",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_razor",
}

function CDOTA_BaseNPC:IsSpeedster()
    for _, hero in pairs(speedsters) do
        if self:GetUnitName() == hero then
            return true
        end
    end

    return false
end

function CDOTA_BaseNPC:GetCooldownTimeAfterReduction(cooldown)
    local cooldown_reduction = 1

    for _, mod in pairs(self:FindAllModifiers()) do
        pcall(function()
            if mod:HasFunction(MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE) then
                cooldown_reduction = cooldown_reduction * (1 - mod:GetModifierPercentageCooldown() / 100)
            end
            if mod:HasFunction(MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING) then
                cooldown_reduction = cooldown_reduction * (1 - mod:GetModifierPercentageCooldownStacking() / 100)
            end
        end)
    end

    return cooldown_reduction * cooldown
end

function CDOTA_BaseNPC:FreezeAllAbilities(state)
    for i=0, 24, 1 do
        local current_ability = self:GetAbilityByIndex(i)
        if current_ability ~= nil then
            current_ability:SetFrozenCooldown( state )
        end
    end    
end

function CDOTA_BaseNPC:IncreaseCooldowns(time, bWithItems)
    local result = 0

    for i=0, 15, 1 do
        local current_ability = self:GetAbilityByIndex(i)
        if current_ability ~= nil then
            current_ability:StartCooldown(current_ability:GetCooldownTimeRemaining() + time)
        end
    end   

    if bWithItems then
        for i=0, 5, 1 do
            local current_item = self:GetItemInSlot(i)
            if current_item ~= nil then
                current_item:StartCooldown(current_item:GetCooldownTimeRemaining() + time)
            end
        end
    end
    
    return result
end

function CDOTA_BaseNPC:GetTotalCooldowns(bWithItems)
    local result = 0

    for i=0, 15, 1 do
        local current_ability = self:GetAbilityByIndex(i)
        if current_ability ~= nil then
            result = result + current_ability:GetCooldownTimeRemaining()
        end
    end   

    if bWithItems then
        for i=0, 5, 1 do
            local current_item = self:GetItemInSlot(i)
            if current_item ~= nil then
                result = result + current_item:GetCooldownTimeRemaining()
            end
        end
    end
    
    return result
end

---- Herlper method for crit attacks without костылей ебаных
function CDOTA_BaseNPC:DoCrit(target, ptc)
    local damage = self:GetAverageTrueAttackDamage(target) * ptc / 100

    --- Apply damage and get result
    local result = ApplyDamage({attacker = self, victim = target, damage = damage, ability = nil, damage_type = DAMAGE_TYPE_PHYSICAL})
    
    ---- Send Crit msg
    SendOverheadEventMessage( target:GetPlayerOwner(), OVERHEAD_ALERT_CRITICAL, target, math.floor( damage ), self:GetPlayerOwner() )

    return result
end

function AddNewModifier_pcall(target, caster, ability, modifierName, properties)
    if target:IsNull() or not target then Warning("[AddNewModifier_pcall] utils.lua - target nullptr exeption") return end

    return target:AddNewModifier(caster, ability, modifierName, properties)
end

function WaitForNextFrame(fnc)
    Timers:CreateTimer(0, fnc)
end

function SetObjectHidden( ubj, hidden )
    if hidden == true then
        ubj:AddEffects(EF_NODRAW)
    else
        ubj:RemoveEffects(EF_NODRAW)
    end
end

function Util:FilterDamage(victim, attacker, data)
    if IsValidEntity(victim) and IsValidEntity(attacker) then
      
        ---- Raise event for all mods on victim
        local modifiers = victim:FindAllModifiers()

        for _, mod in ipairs(modifiers) do
            if mod then
                mod:OnWantsApplyDamage(data)
            end
        end

        ---- Raise event for all mods on attacker
        local modifiers = attacker:FindAllModifiers()

        for _, mod in ipairs(modifiers) do
            if mod then
                mod:OnWantsApplyDamage(data)
            end
        end
    end
end

function Util:OnDamageWasApplied(data)
    if data.entindex_inflictor_const ~= nil then
        local inflictor = EntIndexToHScript(data.entindex_inflictor_const)

        if inflictor and not inflictor:IsNull() and inflictor:GetName() == "wisp_spirits" then
            local target = EntIndexToHScript(data.entindex_victim_const)
            local caster = EntIndexToHScript(data.entindex_attacker_const)

            if target and caster and not caster:IsNull() and not target:IsNull() and caster:HasTalent("special_bonus_unique_wist_str") then
                local ability = caster:FindAbilityByName("io_decay_dummy")

                if ability and not ability:IsNull() then
                    caster:SetCursorPosition(target:GetAbsOrigin())
                    ability:OnSpellStart()
                end
            end
        end
    end
end

function CDOTA_Buff:OnWantsApplyDamage(params)
    
end

function CDOTA_Modifier_Lua:OnWantsApplyDamage(params)
    
end

function Util:DoAreaDamage(hTarget, flDamage, vLoc, hAbility, hCaster, damage_type, radius, unit_type, damage_flags)
    local units = FindUnitsInRadius( hCaster:GetTeamNumber(), vLoc, hCaster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, unit_type, 0, 0, false )
	if #units > 0 then
        for _,unit in pairs(units) do
            ApplyDamage({
                victim = unit,
                attacker = hCaster,
                damage = flDamage,
                damage_type = damage_type,
                ability = hAbility,
                damage_flags = damage_flags
            })
		end
	end
end

function Util:GetHeroesInRadius(vLoc, radius, unit_type, iRelativeTeam)
    return FindUnitsInRadius( iRelativeTeam, vLoc, nil, radius, unit_type, DOTA_UNIT_TARGET_HERO, 0, 0, false )
end

function CDOTA_BaseNPC:FindAllIllusions()
    local units = FindUnitsInRadius( self:GetTeamNumber(), self:GetAbsOrigin(), self, 99999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
    local result = {}

    for _, unit in pairs(units) do 
        if IsValidEntity(unit) and unit:IsIllusion() and unit:GetPlayerOwnerID() == self:GetPlayerOwnerID() then
            table.insert(result, unit)
        end
    end

    return result
end

function CDOTA_BaseNPC:RULK_GetUltimateStacks()
    local mod = self:FindModifierByName("modifier_ross_ralk")

    if mod then
        return mod:GetStackCount()
    end
    
    return 0
end

function CDOTA_BaseNPC:RenderWearables(state)
    for _, item in pairs(self.wearables) do
        if item ~= nil then ---- the item is valid only if it has userdata type
            pcall(function() 
                if state then
                    item:RemoveEffects( EF_NODRAW )
                else 
                    item:AddEffects( EF_NODRAW )
                end
            end)
        end
    end
end