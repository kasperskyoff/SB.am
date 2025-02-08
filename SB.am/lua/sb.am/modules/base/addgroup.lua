SB_AM = SB_AM or {} 
SB_AM.Commands = SB_AM.Commands or {}

-- Добавляем локальные функции для работы с БД
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

SB_AM.Commands.addgroup = {
    Description = "Добавляет ранг игроку.",
    ShowPlayerList = true,
    Arguments = {
        {name = "Ранг", required = true}
    },
    Callback = function(ply, args)
        args = args or {}

        if not IsValid(ply) then
            ply = Entity(0)
        end

        if IsValid(ply) and ply:IsPlayer() then
            if not SB_AM.Ranks.HasPermission(ply, "*") then
                SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
                return
            end
        end
        
        if not args[1] then
            SB_AM.Log("Укажите игрока", "error", ply)
            return
        end

        local identifier = args[1]
        if string.match(args[1], "^STEAM_") then
            local parts = {args[1]}
            local idx = 2
            while args[idx] and not SB_AM.Ranks.List[string.lower(args[idx])] do
                table.insert(parts, args[idx])
                idx = idx + 1
            end
            identifier = table.concat(parts, "")
            
            local newArgs = {identifier}
            for i = idx, #args do
                table.insert(newArgs, args[i])
            end
            for i = 1, #newArgs do
                args[i] = newArgs[i]
            end
            for i = #newArgs + 1, #args do
                args[i] = nil
            end
        end

        if not args[2] then
            local availableRanks = {}
            for rank, _ in pairs(SB_AM.Ranks.List) do
                table.insert(availableRanks, rank)
            end
            SB_AM.Log("Укажите ранг (" .. table.concat(availableRanks, "/") .. ")", "error", ply)
            return
        end

        local newRank = args[2]
        if not SB_AM.Ranks.List[newRank] then
            local availableRanks = {}
            for rank, _ in pairs(SB_AM.Ranks.List) do
                table.insert(availableRanks, rank)
            end
            SB_AM.Log("Неверный ранг. Используйте: " .. table.concat(availableRanks, ", "), "error", ply)
            return
        end

        identifier = string.gsub(identifier, "%s+", "")
        
        local target = SB_AM.FindPlayer(identifier)

        if not IsValid(target) then
            SB_AM.Log("Игрок не найден", "error", ply)
            return
        end

        target:SetUserGroup(newRank)

        -- Сохранение в БД
        if SERVER then
            SaveRank(target:SteamID(), target:Nick(), newRank)
        end

        SB_AM.Log(SB_AM.GetExecutorName(ply) .. " установил игроку " .. target:Nick() .. " ( " .. target:SteamID() .. " ) ранг " .. SB_AM.Ranks.List[newRank].name, "info")
    end
}

return SB_AM.Commands.addgroup
