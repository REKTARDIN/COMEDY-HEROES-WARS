stats = {}

RN_DROP_REGULAR_CHANCE = 10

stats.GET = -1;
stats.STATS_PRE_GAME = 1;
stats.STATS_POST_GAME = 2;
stats.GAME = 3;
stats.INVENTORY = 4;
stats.TRADE = 5;
stats.ITEM = 6;
stats.DELETE_ITEM = 7;
stats.AUTH = 8;
stats.PLUS_STATS = 9;
stats.REPORT = 10

local CONST_MAX_REPORTS = 16

--- Global table for abilities stats collections
stats.ABILITY_STATS = {}
--- Global table for items stats
stats.ITEMS_STATS = {}

stats.data = {}

stats.RECORD_ENUM = {}
stats.RECORD_ENUM.ABILITY_LEARNED = 0
stats.RECORD_ENUM.ITEM_BOUGHT = 1


stats.config = {
	server = "http://82.146.43.107:5001/stats",
	version = "9.9",
	game = "chw",
	agent = "chw",
	timeout = 25000
}

stats.drop = {
    "4",
    "5",
    "6",
    "16",
    "17",
    "20",
    "21",
    "27",
    "28",
    "30",
    "31",
    "34",
    "38",
    "50",
    "52",
    "54",
    "53",
    "55",
    "56",
    "58",
    "59",
    "74",
    "79",
    "80",
    "86",
    "91",
    "92",
    "93",
    "94",
    "95",
    "96",
    "101",
    "103",
    "106",
    "107",
    "108",
    "109",
    "112",
    "113",
    "123",
    "125",
    "127",
    "128",
    "129",
    "132",
    "148",
    "149",
    "154",
    "155",
    "156",
    "157",
    "158",
    "159",
    "160",
    "161",
    "162",
    "163",
    "164",
    "178",
    "179",
    "180",
    "181",
    "189",
    "190",
    "191",
    "192",
    "193",
    "194",
    "195",
    "196"
}

function stats.get_data()
    local data = {}
    data.players = stats.get_players_ids()

    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.STATS_PRE_GAME,
        key = GetDedicatedServerKeyV2("8.3"),
        time = {
            frames = tonumber(GetFrameCount()),
            server_time = tonumber(Time()),
            dota_time = tonumber(GameRules:GetDOTATime(true, true)),
            game_time = tonumber(GameRules:GetGameTime()),
            server_system_date_time = tostring(GetSystemDate()) .. " " .. tostring(GetSystemTime()),
        },
        data = data
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    if payload ~= nil then
		print("Payload: " .. encoded_data:sub(1, 20))
    end
    
    connection:SetHTTPRequestRawPostBody("application/json", encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
		}

		if result.code == 0 then
			print("Request timed out")
			return
        end
        
		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
            
            ---- We should always check is there valid response from server!
            if decoded ~= nil then
                stats.prepare(decoded["players"])
                PlayerTables:CreateTable("heroes", {heroes = decoded["heroes"]}, true)
            else 
                stats.set_empty()
            end
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end

---- Set empty in order to prevent errors!
function stats.set_empty()
    CustomNetTables:SetTableValue("players", "stats", {})
    PlayerTables:CreateTable("heroes", {heroes = {}}, true)
end

function stats.set_data()
    local data = {}
    data.players = stats.get_players_stats()
    data.game = stats.get_game_params()

    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.STATS_POST_GAME,
        key = GetDedicatedServerKeyV2("8.3"),
        time = {
            frames = tonumber(GetFrameCount()),
            server_time = tonumber(Time()),
            version = stats.config.version,
            dota_time = tonumber(GameRules:GetDOTATime(true, true)),
            game_time = tonumber(GameRules:GetGameTime()),
            map = GetMapName(),
            winner = stats.get_game_winner(),
            match_id = tonumber(tostring(GameRules:GetMatchID())),
            server_system_date_time = tostring(string.gsub( GetSystemDate(), "/", ":" )) .. " " .. tostring(GetSystemTime()),
        },
        data = data
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    
    connection:SetHTTPRequestRawPostBody("application/json", encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
		}

		if result.code == 0 then
			print("Request timed out")
			return
        end
        
        print(result_keys.Body)

		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end

function stats.get_game_params()
    local game = {}

    game.players = stats.get_players_items()
    game.heroes = stats.get_heroes()

    return game
end

function stats.get_players_items()
    local players = {}
    
    for pID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(pID) and PlayerResource:IsFakeClient(pID) == false then
            local player = {}
            player.steam_id = PlayerResource:GetSteamAccountID(pID)
            player.name = PlayerResource:GetPlayerName(pID)
            player.player_data = {}
            player.player_data.items = {}
            local hero = PlayerResource:GetSelectedHeroEntity(pID)
            local net_worth = hero:GetGold()

            player.player_data.kda = PlayerResource:GetKills(pID) .. " | " .. PlayerResource:GetDeaths(pID) .. " | " .. PlayerResource:GetAssists(pID)
            player.player_data.hero = hero:GetUnitName()

            for i = 0, 5, 1 do
                local current_item = hero:GetItemInSlot(i)
                if current_item then 
                    local item_name = current_item:GetName()
                    
                    table.insert(player.player_data.items, item_name)
                end 
            end

            table.insert(players, player)
        end
    end
    
    return players
end 

function stats.get_players_stats()
    local players = {}

    for i = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) and PlayerResource:IsFakeClient(i) == false then
            local data = {
                steam_id = tostring(PlayerResource:GetSteamAccountID(i)),
                win_state = stats.is_winner(i), 
                connection_state = PlayerResource:GetConnectionState(i), 
                stuns = PlayerResource:GetStuns(i),          
                name = PlayerResource:GetPlayerName(i),
                gold = PlayerResource:GetTotalEarnedGold(i),
                kills = PlayerResource:GetKills(i), 
                deaths = PlayerResource:GetDeaths(i), 
                assists = PlayerResource:GetAssists(i), 
                last_hits = PlayerResource:GetLastHits(i), 
                denies = PlayerResource:GetDenies(i),
                gold_per_min = math.floor(PlayerResource:GetGoldPerMin(i)), 
                xp_per_minute = math.floor(PlayerResource:GetXPPerMin(i)), 
                gold_spent = (PlayerResource:GetGoldSpentOnItems(i) or 0) + (PlayerResource:GetGoldSpentOnConsumables(i) or 0) + (PlayerResource:GetGoldSpentOnSupport(i) or 0), 
                misses = PlayerResource:GetMisses(i), 
                net_worth = stats.get_net_worth(i),
                hero_damage = stats.get_hero_damage(i),
                tower_damage = PlayerResource:GetTowerDamageTaken(i, true),
                hero_healing = PlayerResource:GetHealing(i),
                level = PlayerResource:GetLevel(i), 
                total_damage_taken_from_heroes = PlayerResource:GetHeroDamageTaken(i, true), 
                time = tonumber(GameRules:GetDOTATime(true, true)),
                hero_pick_order = i
            }

            table.insert(players, data)
        end
    end

    return players
end

function stats.get_net_worth(pID)
    if pID and PlayerResource:IsValidPlayerID(pID) then 
        local hero = PlayerResource:GetSelectedHeroEntity(pID)
        local name = hero:GetUnitName()
        local net_worth = PlayerResource:GetGold(pID)

        for i = 0, 5, 1 do
            local current_item = hero:GetItemInSlot(i)
            if current_item then net_worth = net_worth + (GetItemCost(current_item:GetName()) or 0) end 
        end

        return net_worth
    end 
end

function stats.is_winner(pID)
    local player_team = PlayerResource:GetTeam(pID)
    local forts = Entities:FindAllByClassname('npc_dota_fort')
    
    for _, v in pairs(forts) do
        if v:IsAlive() and v:GetTeam() == player_team then
            return true
        end

    end
   
    return false
end

function stats.get_hero_damage(pID)
    local result = 0
    for i = 0, DOTA_MAX_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(i) then
            if not pID ~= i then
                result = result + PlayerResource:GetDamageDoneToHero(pID, i)
            end
        end
    end
    return math.floor(result)
end

function stats.get_players_ids()
    local players = {}
    for i = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) then
            local steam_id = PlayerResource:GetSteamAccountID(i)
            if steam_id ~= 0 then table.insert(players, steam_id) end
        end
    end

    return players
end 

function stats.get_heroes()
    local heroes = {}

    local current_heroes = HeroList:GetAllHeroes()

    for _, i in pairs(current_heroes) do
        local hero = {}

        hero.name = i:GetUnitName()
        hero.id = Util:GetHeroID(hero.name)

        if hero.name ~= "npc_dota_hero_wisp" and hero.id and PlayerResource:IsFakeClient(i:GetPlayerOwnerID()) == false then 
            hero.deaths = i:GetDeaths()
            hero.kills = i:GetKills()
            hero.last_hits = i:GetLastHits()
            hero.level = i:GetLevel()
            hero.is_won = stats.is_winner(i:GetPlayerOwnerID())
            hero.net_worth = stats.get_net_worth(i:GetPlayerOwnerID())
            hero.items = stats.get_hero_items(i)
            table.insert(heroes, hero)
        end 
    end

    return heroes
end

function stats.get_hero_items(hero)
    local items = {}

    for i = 0, 5, 1 do
        local current_item = hero:GetItemInSlot(i)
        if current_item then 
            local item_name = current_item:GetName()
            
            table.insert(items, item_name)
        end 
    end

    return items
end

function stats.get_game_winner()
    local forts = Entities:FindAllByClassname('npc_dota_fort')
    
    for k, fort in pairs(forts) do
        if fort:GetHealth() <= 0 then
            return fort:GetOpposingTeamNumber()
        end
    end

    return 1
end

function stats.prepare( data )
    local array = {}

    for _, player in pairs(data) do
        for i = 0, DOTA_MAX_PLAYERS do
            if PlayerResource:IsValidPlayerID(i) then
                local steam_id = PlayerResource:GetSteamAccountID(i)
                
                if steam_id == player["steam_id"] then 
                    array[i] = player
                end 
            end
        end
    end

    CustomNetTables:SetTableValue("players", "stats", array)
end

function stats.get_ids()
    local players = {}

    for i = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) then
            local steam_id = PlayerResource:GetSteamAccountID(i)
            if steam_id ~= 0 then
                players[steam_id] = i
            end
        end
    end
    return players
end

function stats.has_plus( pID )
    local value = CustomNetTables:GetTableValue("players", "stats")

    if value[tostring(pID)] then 
        return (value[tostring(pID)]["is_using_plus"] == "1")
    end 

    return false
end

function stats.request_hero_data(hero_name)
    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.PLUS_STATS,
        key = GetDedicatedServerKeyV2("8.3"),
        data = hero_name
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    if payload ~= nil then
		print("Payload: " .. encoded_data:sub(1, 20))
    end
    
    connection:SetHTTPRequestRawPostBody("application/json", encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
		}

		if result.code == 0 then
			print("Request timed out")
			return
        end
        
		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
            
            if decoded then 
                stats.data[decoded["hero_name"]] = decoded
            end 

            PlayerTables:SetTableValue("heroes_data", "heroes", stats.data)
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end
function stats.get_all_inventories()
    local data = {}
    data.players = stats.get_players_ids()

    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.INVENTORY,
        key = GetDedicatedServerKeyV2("8.3"),
        time = {
            frames = tonumber(GetFrameCount()),
            server_time = tonumber(Time()),
            dota_time = tonumber(GameRules:GetDOTATime(true, true)),
            game_time = tonumber(GameRules:GetGameTime()),
            server_system_date_time = tostring(GetSystemDate()) .. " " .. tostring(GetSystemTime()),
        },
        data = data
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    if payload ~= nil then
		print("Payload: " .. encoded_data:sub(1, 20))
    end
    
    connection:SetHTTPRequestRawPostBody("application/json", encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
        }

		if result.code == 0 then
			print("Request timed out")
			return
        end
        
		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
            

            GameRules.Globals.Inventories = decoded
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end

function stats.create_item( params )
    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.ITEM,
        key = GetDedicatedServerKeyV2("8.3"),
        time = {
            frames = tonumber(GetFrameCount()),
            server_time = tonumber(Time()),
            dota_time = tonumber(GameRules:GetDOTATime(true, true)),
            game_time = tonumber(GameRules:GetGameTime()),
            server_system_date_time = tostring(GetSystemDate()) .. " " .. tostring(GetSystemTime()),
        },
        data = params
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    if payload ~= nil then
		print("Payload: " .. encoded_data:sub(1, 20))
    end
    
    connection:SetHTTPRequestRawPostBody("application/json", encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
		}

		if result.code == 0 then
			print("Request to " .. endpoint .. " timed out")
			return
        end

        print(result_keys.Body)
        
		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end

function stats.submit_trade(params)
    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.TRADE,
        key = GetDedicatedServerKeyV2("8.3"),
        time = {
            frames = tonumber(GetFrameCount()),
            server_time = tonumber(Time()),
            dota_time = tonumber(GameRules:GetDOTATime(true, true)),
            game_time = tonumber(GameRules:GetGameTime()),
            server_system_date_time = tostring(GetSystemDate()) .. " " .. tostring(GetSystemTime()),
        },
        data = params
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    if payload ~= nil then
		print("Payload: " .. encoded_data:sub(1, 20))
    end
    
    connection:SetHTTPRequestRawPostBody("application/json", encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
		}

		if result.code == 0 then
			print("Request to " .. endpoint .. " timed out")
			return
        end

        print(result_keys.Body)
        
		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end
function stats.delete_item(params)
    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.DELETE_ITEM,
        key = GetDedicatedServerKeyV2("8.3"),
        time = {
            frames = tonumber(GetFrameCount()),
            server_time = tonumber(Time()),
            dota_time = tonumber(GameRules:GetDOTATime(true, true)),
            game_time = tonumber(GameRules:GetGameTime()),
            server_system_date_time = tostring(GetSystemDate()) .. " " .. tostring(GetSystemTime()),
        },
        data = params
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    if payload ~= nil then
		print("Payload: " .. encoded_data:sub(1, 20))
    end
    
    connection:SetHTTPRequestRawPostBody("application/json", encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
		}

		if result.code == 0 then
			print("Request to " .. endpoint .. " timed out")
			return
        end

        print(result_keys.Body)
        
		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end
function stats.roll()
    local items = {}

    for i = 0, DOTA_MAX_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) and PlayerResource:GetConnectionState(i) ~= DOTA_CONNECTION_STATE_ABANDONED then
            if RollPercentage(RN_DROP_REGULAR_CHANCE) and Util.econs then 
                local drop = stats.drop[ math.random( #stats.drop ) ]
                local item = Util.econs[drop]

                local data = {
                    item = drop,
                    rarity = item['rarity'],
                    quality = item['quality'],
                    is_medal = item['is_medal'],
                    is_treasure = item['is_treasure'],
                    tradeable = 1,
                    steam_id = tostring(PlayerResource:GetSteamAccountID(i))
                }
                  
                stats.create_item(data)

                items[i] = data
            end 
        end
    end

    DeepPrintTable(items)

    CustomNetTables:SetTableValue("players", "drop", items)
end


function stats.send_report(steam_id, pID)
    local data = {}
    data.user = steam_id

    local connection = CreateHTTPRequestScriptVM('POST', stats.config.server)
    
    local encoded_data = json.encode({
        type = stats.REPORT,
        key = GetDedicatedServerKeyV2("8.3"),
        time = {
            frames = tonumber(GetFrameCount()),
            server_time = tonumber(Time()),
            dota_time = tonumber(GameRules:GetDOTATime(true, true)),
            game_time = tonumber(GameRules:GetGameTime()),
            server_system_date_time = tostring(GetSystemDate()) .. " " .. tostring(GetSystemTime()),
        },
        data = data
    })

	print("Performing request to " .. stats.config.server)
    print("Method: " .. 'POST')
    if payload ~= nil then
		print("Payload: " .. encoded_data:sub(1, 20))
    end
    
    connection:SetHTTPRequestRawPostBody("application/json", encoded_data)
    connection:SetHTTPRequestAbsoluteTimeoutMS(stats.config.timeout)

    connection:Send (function(result_keys)
        local result = {
			code = result_keys.StatusCode,
			body = result_keys.Body,
		}

		if result.code == 0 then
			print("Request timed out")
			return
        end

        local reports_number = tonumber(result_keys.Body)

        if reports_number >= CONST_MAX_REPORTS then
            ---stats.kick_player(pID)
        end 
        
		if result.body ~= nil then
			local decoded = json.decode(result.body)
			if result.code == 503 then
				print("Server unavailable")
			elseif result.code == 500 then
				if result.message ~= nil then print("Internal Server Error: " .. tostring(result.message)) else print("Internal Server Error") end
			elseif result.code == 405 then
				print("Used invalid method on endpoint" .. endpoint)
			elseif result.code == 404 then
				print("Tried to access unknown endpoint " .. endpoint)
			elseif result.code ~= 200 then
				print("Unknown Error: " .. tostring(result.code))
            end
		else
			print("Warning: Recieved response for request " .. endpoint .. " without body!")
		end
    end)
end

function stats.kick_player(pID)
    if not Util:PlayerHasAdminRules(pID) then
        local playerName = tostring(PlayerResource:GetPlayerName(tonumber(pID)))

        local res = "<font color=\"#FFFF33\"> ".. playerName .." was excluded from the game and blocked for 4 hours. (Temporally cooldown) </font>"
        GameRules:SendCustomMessage(res, 0, 0)

        local p = PlayerResource:GetPlayer(tonumber(pID))
        local h = p:GetAssignedHero()

        UTIL_Remove(h)
        UTIL_Remove(p)
    end
end

--- Stats record main method
function stats.record(playerID, params, type)
    --[[
        abilityname	spawn_raising_hell
PlayerID	0
game_event_listener	1602224133
game_event_name	dota_player_learned_ability
splitscreenplayer	-1
    ]]
    
    if PlayerResource:IsValidPlayerID(playerID) then
        -----------------------------Check fields---------------------------------------------
        if (not stats.ABILITY_STATS[playerID]) then stats.ABILITY_STATS[playerID] = {}  end
        if (not stats.ITEMS_STATS[playerID]) then stats.ITEMS_STATS[playerID] = {}  end
        --------------------------------------------------------------------------------------
       
        if (type == stats.RECORD_ENUM.ABILITY_LEARNED) then
            
        elseif (type == stats.RECORD_ENUM.ITEM_BOUGHT) then 
            
        end 
    end
end

function stats.set_event_drop(itemdefid)
    local items = {}

    for i = 0, DOTA_MAX_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsFakeClient(i) and PlayerResource:GetConnectionState(i) ~= DOTA_CONNECTION_STATE_ABANDONED then
            if Util.econs then 
                local item = Util.econs[tostring(itemdefid)]

                local data = {
                    item = tostring(itemdefid),
                    rarity = item['rarity'],
                    quality = item['quality'],
                    is_medal = item['is_medal'],
                    is_treasure = item['is_treasure'],
                    tradeable = 1,
                    steam_id = tostring(PlayerResource:GetSteamAccountID(i))
                }
                  
                stats.create_item(data)

                items[i] = data
            end 
        end
    end

    CustomNetTables:SetTableValue("players", "drop", items)
end

function stats.test()
    
end