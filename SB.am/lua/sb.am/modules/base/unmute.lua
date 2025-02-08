SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

SB_AM.Commands.unmute = {
    Description = "Размутить игрока.",
    ShowPlayerList = true,
    Callback = function(ply, args)
        if not IsValid(ply) then
            ply = Entity(0)
        end
        
        if IsValid(ply) and ply:IsPlayer() and not SB_AM.Ranks.HasPermission(ply, "unmute") then
            SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
            return
        end

        if not args[1] then
            SB_AM.Log("Укажите игрока", "error", ply)
            return
        end

        local target = SB_AM.FindPlayer(args[1])

        if not target then
            SB_AM.Log("Игрок не найден", "error", ply)
            return
        end

        if not target.isMuted then
            SB_AM.Log("Игрок не замучен", "error", ply)
            return
        end

        target.isMuted = false
        target.unmuteTime = 0
        
        net.Start("SB_AM_MuteStatus")
        net.WriteString("")
        net.WriteInt(0, 32)
        net.Send(target)

        local executorName = IsValid(ply) and ply:Nick() or "Console"
        SB_AM.Log(executorName .. " размутил игрока " .. target:Nick() .. " ( " .. target:SteamID() .. " ) ", "info")
    end
}

return SB_AM.Commands.unmute
