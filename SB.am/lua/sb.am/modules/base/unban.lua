SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

SB_AM.Commands.unban = {
    Description = "Разбанивает игрока.",
    ShowPlayerList = true,
    Arguments = {
        {name = "SteamID", required = false}
    },
    Callback = function(ply, args)
        if not IsValid(ply) then
            ply = Entity(0)
        end

        if IsValid(ply) and ply:IsPlayer() and not SB_AM.Ranks.HasPermission(ply, "unban") then
            SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
            return
        end

        if not args[1] then
            SB_AM.Log("Укажите SteamID", "error", ply)
            return
        end

        local steamid = args[1]
        
        if string.match(args[1], "^STEAM_") then
            local parts = {args[1]}
            local idx = 2
            while args[idx] and args[idx] do
                table.insert(parts, args[idx])
                idx = idx + 1
            end
            steamid = table.concat(parts, "")
            
            local newArgs = {steamid}
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

        steamid = string.gsub(steamid, "%s+", "")
        
        local target = nil
        if not string.match(steamid, "STEAM_%d+:%d+:%d+") then
            target = SB_AM.FindPlayer(steamid)
            if target then
                steamid = target:SteamID()
            end
        else
            target = SB_AM.FindPlayer(steamid)
        end

        local banInfo = sql.Query("SELECT * FROM sb_am_bans WHERE steamid = " .. sql.SQLStr(steamid))
        if not banInfo or #banInfo == 0 then
            SB_AM.Log("Игрок не находится в бане", "error", ply)
            return
        end
        banInfo = banInfo[1]

        sql.Query("DELETE FROM sb_am_bans WHERE steamid = " .. sql.SQLStr(steamid))

        if IsValid(target) then
            target.isBanned = false
            target:SetModel(target.oldModel or "models/player/group01/male_01.mdl")
            target:SetMoveType(MOVETYPE_WALK)
            target:SetGravity(1)
            target:SetWalkSpeed(400)
            target:SetRunSpeed(600)

            net.Start("UnbanPlayer")
            net.Send(target)
        end

        if timer.Exists("Unban_" .. steamid) then
            timer.Remove("Unban_" .. steamid)
        end

        local playerName = banInfo.player_name or steamid
        SB_AM.Log(SB_AM.GetExecutorName(ply) .. " разбанил " .. playerName .. " ( " .. steamid .. " ) ", "info")
    end
}

return SB_AM.Commands.unban

