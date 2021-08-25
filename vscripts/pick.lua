if Pick == nil then
  Pick = {}
  Pick.__index = Pick
end

HERO_TABLE = {}
PLAYER_TABLE = {}
PENALTIES = {}

IS_SUPPORT_DRAFTS = false
IS_IN_DRAFT_SRAGE = false
CURRENT_TEAM_DRAFT = 0
IS_PICK_ENDED = false
SHOULD_CHANGE_DRAFT = false

PENALTY = 100

BANS = {}
BANS[DOTA_TEAM_GOODGUYS] = {}
BANS[DOTA_TEAM_BADGUYS] = {}
BANS["TOTAL"] = 0

TIMER = 90

TOTAL_PICK_TIME = 90
BAN_TIME = 25

PICK_TIME_FOR_PLAYER = 20

CAN_ENTER_GAME = false
MAX_BANS_PER_TEAM = 5

PICKS = {}

local heroes = {}


function Pick:Start()
    IS_SUPPORT_DRAFTS = GetMapName() == "dota"

    CustomGameEventManager:RegisterListener("hero_picked", Dynamic_Wrap(Pick, 'OnPick'))
    CustomGameEventManager:RegisterListener("random_hero", Dynamic_Wrap(Pick, 'OnRandomHeroSelected'))
    CustomGameEventManager:RegisterListener("hero_banned", Dynamic_Wrap(Pick, 'OnBan'))

    print(IS_SUPPORT_DRAFTS)

    heroes = Util:GetHeroes()

    GameRules:GetGameModeEntity():SetThink("OnIntervalThink", Pick, 1)

    Convars:RegisterCommand( "try_connect", Dynamic_Wrap(Pick, 'OnConnectFull'), "Test", FCVAR_CHEAT )

    LinkLuaModifier("modifier_connection_state", "modifiers/modifier_connection_state.lua", LUA_MODIFIER_MOTION_NONE)

    if IsInToolsMode() then
        TIMER = 5
        IS_SUPPORT_DRAFTS = false
    end
end

function Pick:UpdateTime()
    CustomNetTables:SetTableValue("pick", "timer", {time = TIMER})
end

function Pick:IsSelectedHero(id)
    return PlayerResource:GetSelectedHeroName(id) ~= "npc_dota_hero_wisp"
end

function Pick:SetPenaltyForPlayersInTeam(val)
    Pick:SetDraftTeamID(val, 1)

    for pID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(pID) and PlayerResource:GetTeam(pID) == val and not Pick:IsSelectedHero(pID) and not PlayerResource:IsFakeClient(pID) then
            PENALTIES[pID] = (PENALTIES[pID] or 0) + PENALTY
        end
    end
end

function Pick:SetDraftTeamID(id, penalty)
    CustomNetTables:SetTableValue("pick", "stage", {stage = id, penalty = penalty})
end

function Pick:PlayForAllPlayers(sound)
    for pID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(pID) and not Pick:IsSelectedHero(pID) and not PlayerResource:IsFakeClient(pID) then
            EmitAnnouncerSoundForPlayer(sound, pID)
        end
    end
end

function Pick:Change()
    if not IS_PICK_ENDED then
        if CURRENT_TEAM_DRAFT == 2 then 
            CURRENT_TEAM_DRAFT = 3
            
            Pick:PlayForAllPlayers("announcer_announcer_pick_dire")
        else 
            CURRENT_TEAM_DRAFT = 2
    
            Pick:PlayForAllPlayers("announcer_announcer_pick_rad")
        end
    
        TIMER = PICK_TIME_FOR_PLAYER
    
        Pick:SetDraftTeamID(CURRENT_TEAM_DRAFT, 0)
    end
end

function Pick:CheckPickCount()
    if #PICKS >= PlayerResource:GetPlayerCount() then
        IS_PICK_ENDED = true 

        TIMER = -1
    end
end

function Pick:OnIntervalThink()
    if IS_SUPPORT_DRAFTS then
        if SHOULD_CHANGE_DRAFT then
            SHOULD_CHANGE_DRAFT = false
            Pick:Change()

            return 1
        end
        if TIMER >= 0 then
            TIMER = TIMER - 1

            if not Pick:IsInBanStage() and not IS_IN_DRAFT_SRAGE then
                IS_IN_DRAFT_SRAGE = true

                EmitAnnouncerSound("announcer_announcer_now_select")

                Pick:Change()
            end

            if IS_IN_DRAFT_SRAGE then
                if TIMER - 1 == -1 then  
                    Pick:PlayForAllPlayers("Pick.GoldTick")

                    Pick:SetDraftTeamID(CURRENT_TEAM_DRAFT, 1)
                end

                if TIMER <= 0 then
                    Pick:SetPenaltyForPlayersInTeam(CURRENT_TEAM_DRAFT)

                    SHOULD_CHANGE_DRAFT = true

                    TIMER = 0
                end
            end
        end

        Pick:CheckPickCount()
    else 
        if TIMER >= 0 then
            TIMER = TIMER - 1
        else 
            IS_PICK_ENDED = true 

            TIMER = -1
        end
    end

    
    Pick:UpdateTime()

    if IS_PICK_ENDED then
        return nil
    end
   
    return 1
end

function Pick:IsInBanStage()
    return TIMER >= TOTAL_PICK_TIME - BAN_TIME
end

function Pick:CanPick(playerid)
    if not IS_SUPPORT_DRAFTS then 
        return true
    end

    return CURRENT_TEAM_DRAFT == PlayerResource:GetTeam(playerid)
end

function Pick:OnPick(params)
    local hero = params.hero
    local playerid = params.playerID
    local team = PlayerResource:GetTeam(playerid)

    if PLAYER_TABLE[playerid] then
        return
    end

    if HERO_TABLE[hero] then
        return
    end

    if Pick:IsHeroBanned(hero) then
        return
    end

    if not Pick:CanPick(playerid) or Pick:IsInBanStage() then
        return
    end

    local gold = 1000
    local HasRandomed = false

    if PlayerResource:HasRandomed(playerid) then
        gold = gold + 800;
        HasRandomed = true;
    end

    gold = gold - (PENALTIES[playerid] or 0)

    HERO_TABLE[hero] = hero

    PLAYER_TABLE[playerid] = {}

    PLAYER_TABLE[playerid].playerid = playerid
    PLAYER_TABLE[playerid].hero = hero
    PLAYER_TABLE[playerid].isRandomed = HasRandomed

    PrecacheUnitByNameAsync( hero, function()
        local nHero = PlayerResource:ReplaceHeroWith(playerid, hero, gold, 0)
        nHero:RespawnHero(false, false)
        nHero:AddNewModifier(nHero, nil, "modifier_connection_state", nil)
    end)

    table.insert( PICKS, playerid )

    CustomNetTables:SetTableValue("pick", "heroes", PLAYER_TABLE)

    if IS_SUPPORT_DRAFTS and IS_IN_DRAFT_SRAGE then
        Pick:CheckPickCount()
        Pick:Change(PlayerResource:GetTeam(playerid))
    end
end

function Pick:HasHero(m)
    local heroes = HeroList:GetAllHeroes()
    
    for k, hero in pairs(heroes) do
        if hero:GetUnitName() == m then
            return true
        end
    end

    return false
end

function Pick:OnRandomHeroSelected(params)
    local playerid = params.playerID

    if not Pick:CanPick(playerid) or Pick:IsInBanStage() then
        return
    end

    local hero_name = heroes[RandomInt(1, #heroes)]

    while HERO_TABLE[hero_name] or Pick:HasHero(hero_name) do
        hero_name = heroes[RandomInt(1, #heroes)]
    end

    local keys = {}
    keys.hero = hero_name
    keys.playerID = playerid

    PlayerResource:SetHasRandomed(playerid)
    Pick:OnPick(keys)
end

function Pick:OnConnectFull(  )
    Timers:CreateTimer(1, function()
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(0), "OnConnectFull", {})
        return nil
    end)
end

function Pick:OnBan(params)
    local hero = params.hero
    local playerid = params.playerID
    local team = PlayerResource:GetTeam(playerid)

    if HERO_TABLE[hero_name] then
        return
    end

    if #BANS[team] >= MAX_BANS_PER_TEAM then
        return
    end

    if not Pick:IsInBanStage() then
        return 
    end

    BANS["TOTAL"] = BANS["TOTAL"] + 1
    table.insert(BANS[team], hero)
    CustomNetTables:SetTableValue("pick", "bans", BANS)
end

function Pick:IsHeroBanned(heroname)
    for _,v in pairs(BANS[DOTA_TEAM_GOODGUYS]) do
        if heroname == v then
            return true
        end
    end

    for _,c in pairs(BANS[DOTA_TEAM_BADGUYS]) do
        if heroname == c then
            return true
        end
    end

    return false
end
