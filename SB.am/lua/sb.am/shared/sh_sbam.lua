SB_AM = SB_AM or {}
SB_AM.Ranks = SB_AM.Ranks or {}

-- permission это разрешение для рангов
-- если стоит * то все это разрешено
-- все команды соеденяются с файлом sh_category.lua типа права (И там можно узнать и прочитать инструкцию)

-- Таблица разрешений
SB_AM.Permissions = {
    BAN = "ban",
    UNBAN = "unban",
    JAIL = "jail",
    UNJAIL = "unjail",
    KICK = "kick",
    KILL = "kill",
    MUTE = "mute",
    UNMUTE = "unmute",
    VOTE = "vote",
    ADDGROUP = "addgroup",
    GOTO = "goto",
    BRING = "bring",
    RETURNTO = "returnto",
    HELP = "help",
    PVP = "pvp",
    BUILD = "build",
    NOCLIP = "noclip",
    PSA = "psa",
    BASIC = "basic",
    FUN = "fun",
    PHYSGUN = "physgun",
    ADMIN_CONSOLE = "admin_console", -- Админ консоль из файла sh_func.lua
}

SB_AM.Ranks.List = {
    ["user"] = {
        name = "Игрок",
        immunity = 0,
        permissions = { 
            SB_AM.Permissions.BASIC,
            SB_AM.Permissions.HELP,
            SB_AM.Permissions.PVP,
            SB_AM.Permissions.BUILD,
        },
        color = Color(241,196,15),
        canTarget = function(self, target) 
            return false 
        end
    },

    ["suser"] = {
        name = "Супер Игрок",
        immunity = 10,
        permissions = {
            SB_AM.Permissions.BASIC,
            SB_AM.Permissions.FUN,
            SB_AM.Permissions.KICK,
            SB_AM.Permissions.MUTE,
            SB_AM.Permissions.UNMUTE,
            SB_AM.Permissions.GOTO,
            SB_AM.Permissions.BRING,
            SB_AM.Permissions.RETURNTO,
            SB_AM.Permissions.HELP,
            SB_AM.Permissions.PVP,
            SB_AM.Permissions.BUILD,
        },
        color = Color(68,0,255),
        canTarget = function(self, target) 
            return false 
        end
    },

    ["engineer"] = {
        name = "Инженер",
        immunity = 20,
        permissions = {
            SB_AM.Permissions.BASIC,
            SB_AM.Permissions.FUN,
            SB_AM.Permissions.JAIL,
            SB_AM.Permissions.UNJAIL,
            SB_AM.Permissions.KICK,
            SB_AM.Permissions.MUTE,
            SB_AM.Permissions.UNMUTE,
            SB_AM.Permissions.GOTO,
            SB_AM.Permissions.BRING,
            SB_AM.Permissions.RETURNTO,
            SB_AM.Permissions.HELP,
            SB_AM.Permissions.PVP,
            SB_AM.Permissions.BUILD,
            SB_AM.Permissions.NOCLIP,
        },
        color = Color(0,218,199),
        canTarget = function(self, target) 
            return false 
        end
    },

    ["moderator"] = {
        name = "Модератор",
        immunity = 30,
        permissions = {
            SB_AM.Permissions.BASIC,
            SB_AM.Permissions.FUN,
            SB_AM.Permissions.JAIL,
            SB_AM.Permissions.UNJAIL,
            SB_AM.Permissions.KICK,
            SB_AM.Permissions.MUTE,
            SB_AM.Permissions.UNMUTE,
            SB_AM.Permissions.VOTE,
            SB_AM.Permissions.GOTO,
            SB_AM.Permissions.BRING,
            SB_AM.Permissions.RETURNTO,
            SB_AM.Permissions.HELP,
            SB_AM.Permissions.PVP,
            SB_AM.Permissions.BUILD,
            SB_AM.Permissions.NOCLIP,
            SB_AM.Permissions.PHYSGUN,
        },
        color = Color(255,255,255),
        canTarget = function(self, target)
            local targetRank = SB_AM.Ranks.Get(target)
            return targetRank.immunity < self.immunity
        end
    },
    
    ["admin"] = {
        name = "Администратор", 
        immunity = 60,
        permissions = {
            SB_AM.Permissions.BASIC,
            SB_AM.Permissions.FUN,
            SB_AM.Permissions.BAN,
            SB_AM.Permissions.UNBAN,
            SB_AM.Permissions.JAIL,
            SB_AM.Permissions.UNJAIL,
            SB_AM.Permissions.KICK,
            SB_AM.Permissions.KILL,
            SB_AM.Permissions.MUTE,
            SB_AM.Permissions.UNMUTE,
            SB_AM.Permissions.VOTE,
            SB_AM.Permissions.GOTO,
            SB_AM.Permissions.BRING,
            SB_AM.Permissions.RETURNTO,
            SB_AM.Permissions.HELP,
            SB_AM.Permissions.PVP,
            SB_AM.Permissions.BUILD,
            SB_AM.Permissions.NOCLIP,
            SB_AM.Permissions.PSA,
            SB_AM.Permissions.PHYSGUN,
            SB_AM.Permissions.ADMIN_CONSOLE,
        },
        color = Color(155,89,182),
        canTarget = function(self, target)
            local targetRank = SB_AM.Ranks.Get(target)
            return targetRank.immunity < self.immunity
        end
    },
    
    ["superadmin"] = {
        name = "Директор",
        immunity = 100,
        permissions = {"*"},
        color = Color(255, 0, 0),
        canTarget = function(self, target)
            return true
        end
    }
}

-----------------------------------------------------------------------
------Хуки, таймеры тим колоры, и сами тим колор---------
-----------------------------------------------------------------------
hook.Add("Initialize", "SB_AM_CreateTeams", function()
    local teamIndex = 1
    SB_AM.TeamIndexToRank = {}
    
    for rankID, rankData in pairs(SB_AM.Ranks.List) do
        _G["TEAM_" .. string.upper(rankID)] = teamIndex
        team.SetUp(teamIndex, rankData.name, rankData.color)
        SB_AM.TeamIndexToRank[teamIndex] = rankID
        teamIndex = teamIndex + 1
    end
end)

hook.Add("PlayerInitialSpawn", "SB_AM_SetTeam", function(ply)
    timer.Simple(0, function()
        if IsValid(ply) then
            local userGroup = ply:GetUserGroup()
            local teamID = _G["TEAM_" .. string.upper(userGroup)] or 1
            ply:SetTeam(teamID)
        end
    end)
end)

hook.Add("PlayerUserGroupChanged", "SB_AM_UpdateTeam", function(ply, old, new)
    if IsValid(ply) then
        local teamID = _G["TEAM_" .. string.upper(new)] or 1
        ply:SetTeam(teamID)
    end
end)

local oldGetColor = team.GetColor
function team.GetColor(teamID)
    if not teamID then return oldGetColor(teamID) end
    
    local ply = nil
    for _, p in ipairs(player.GetAll()) do
        if p:Team() == teamID then
            ply = p
            break
        end
    end
    
    if IsValid(ply) then
        local userGroup = ply:GetUserGroup()
        if SB_AM.Ranks.List[userGroup] then
            return SB_AM.Ranks.List[userGroup].color
        end
    end

    if SB_AM.TeamIndexToRank and SB_AM.TeamIndexToRank[teamID] then
        local rankID = SB_AM.TeamIndexToRank[teamID]
        return SB_AM.Ranks.List[rankID].color
    end
    
    return oldGetColor(teamID)
end

local oldGetTeamNumColor = player.GetTeamNumColor
function player.GetTeamNumColor(ply)
    if IsValid(ply) then
        return SB_AM.Ranks.GetColor(ply)
    end
    return oldGetColor(ply:Team())
end
-----------------------------------------------------------------------

function SB_AM.Ranks.Get(ply)
    if not IsValid(ply) then return SB_AM.Ranks.List["user"] end
    
    local userGroup = ply:GetUserGroup()
    return SB_AM.Ranks.List[userGroup] or SB_AM.Ranks.List["user"]
end

function SB_AM.Ranks.HasPermission(ply, permission)
    if not IsValid(ply) then return false end
    
    local rank = SB_AM.Ranks.Get(ply)
    if not rank then return false end
    
    if table.HasValue(rank.permissions, "*") then
        return true
    end
    
    return table.HasValue(rank.permissions, permission)
end

function SB_AM.Ranks.CanTarget(ply, target)
    if not IsValid(ply) or not IsValid(target) then return false end
    
    local rank = SB_AM.Ranks.Get(ply)
    return rank.canTarget(rank, target)
end

function SB_AM.Ranks.GetColor(ply)
    if not IsValid(ply) then return Color(200, 200, 200) end
    
    local rank = SB_AM.Ranks.Get(ply)
    return rank and rank.color or Color(200, 200, 200) 
end

function SB_AM.Ranks.GetName(ply)
    local rank = SB_AM.Ranks.Get(ply)
    return rank.name or "Игрок"
end

if SERVER then
    util.AddNetworkString("SB_AM_SyncRanks")
    
    -- Обновление БД
    local function LoadAllRanks()
        local result = sql.Query("SELECT * FROM sb_am_ranks") or {}
        local ranks = {}
        
        for _, data in ipairs(result) do
            ranks[data.steamid] = {
                name = data.name,
                rank = data.rank
            }
        end
        
        return ranks
    end

    local function SaveRank(steamID, name, rank)
        if rank == "user" then
            sql.Query(string.format(
                "DELETE FROM sb_am_ranks WHERE steamid = %s",
                sql.SQLStr(steamID)
            ))
        else
            sql.Query(string.format(
                [[REPLACE INTO sb_am_ranks (steamid, name, rank) 
                   VALUES (%s, %s, %s)]],
                sql.SQLStr(steamID),
                sql.SQLStr(name),
                sql.SQLStr(rank)
            ))
        end
    end
    
    local function UpdatePlayerRank(ply)
        if not IsValid(ply) then return end
        
        local userGroup = ply:GetUserGroup()
        if userGroup == "user" then
            local steamID = ply:SteamID()
            SaveRank(steamID, ply:Nick(), "user")
            return
        end
        
        if userGroup ~= "admin" and userGroup ~= "superadmin" then return end
        
        local steamID = ply:SteamID()
        if not steamID then return end
        
        SaveRank(steamID, ply:Nick(), userGroup)
    end
    
    hook.Add("PlayerInitialSpawn", "SB_AM_SyncRanks", function(ply)
        local allRanks = LoadAllRanks()
        local steamID = ply:SteamID()

        if allRanks[steamID] and allRanks[steamID].rank then
            ply:SetUserGroup(allRanks[steamID].rank)
        end
        
        UpdatePlayerRank(ply)
        
        local ranksToSync = {}
        for rankID, rankData in pairs(SB_AM.Ranks.List) do
            ranksToSync[rankID] = {
                name = rankData.name,
                immunity = rankData.immunity,
                chance = rankData.chance,
                color = rankData.color
            }
        end
        
        net.Start("SB_AM_SyncRanks")
        net.WriteTable(ranksToSync)
        net.Send(ply)
    end)

    hook.Add("PlayerUserGroupChanged", "SB_AM_SaveRank", function(ply, old, new)
        UpdatePlayerRank(ply)
    end)

    net.Receive("SB_AM_ClientCommand", function(len, ply)
        local commandName = net.ReadString()
        local args = net.ReadTable()
        
        local success, hasCallback = SB_AM.ExecuteCommand(commandName, ply, args)
        
        if not success then
            SB_AM.Error(ply, "Команда '" .. commandName .. "' не найдена")
        end
    end)
end

if CLIENT then
    net.Receive("SB_AM_SyncRanks", function()
        local receivedRanks = net.ReadTable()
        
        for rankID, rankData in pairs(receivedRanks) do
            if not SB_AM.Ranks.List[rankID] then
                SB_AM.Ranks.List[rankID] = {}
            end
            
            SB_AM.Ranks.List[rankID].name = rankData.name
            SB_AM.Ranks.List[rankID].immunity = rankData.immunity
            SB_AM.Ranks.List[rankID].chance = rankData.chance
            SB_AM.Ranks.List[rankID].color = rankData.color
            
            if rankID == "user" then
                SB_AM.Ranks.List[rankID].canTarget = function(self, target)
                    return false
                end
            elseif rankID == "superadmin" then
                SB_AM.Ranks.List[rankID].canTarget = function(self, target)
                    return true
                end
            else
                SB_AM.Ranks.List[rankID].canTarget = function(self, target)
                    local targetRank = SB_AM.Ranks.Get(target)
                    return targetRank.immunity < self.immunity
                end
            end
        end
    end)

    hook.Add("OnPlayerChat", "SB_AM_ColoredChat", function(ply, text, teamChat, isDead, isLocal )
        if not IsValid(ply) then return end
        
        if string.sub(text, 1, 1) == "!" or
           string.sub(text, 1, 1) == "/" or
           string.sub(text, 1, 1) == "." then
            return
        end

        local tab = {}


        local deadcolor = Color( 255, 75, 75)
        local localcolor = Color( 75, 132, 255)
        local rankColor = SB_AM.Ranks.GetColor(ply)
        local playerName = ply:Nick()
        rankColor.a = 255

        if (isDead) then
            table.insert( tab, deadcolor )
            table.insert( tab, " ***[Мертвый]*** " )
        end

        if (isLocal) then
            table.insert( tab, localcolor )
            table.insert( tab, " **[Локальный]** " )
        end

        table.insert( tab, rankColor )
        table.insert( tab, playerName )
        table.insert( tab, Color(255, 255, 255) )
        table.insert( tab, ": "..text )
        
        chat.AddText( unpack( tab ) )
        
        return true
    end)
end
