SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

if SERVER then
    util.AddNetworkString("SB_AM_MuteStatus")

    -- Блокировка чата для замученных игроков
    hook.Add("PlayerSay", "SB_AM_MuteChat", function(ply, text, teamChat)
        if ply.isMuted then
            SB_AM.Log("Вы не можете писать в чат, так как замучены", "error", ply)
            return ""
        end
    end)
end

SB_AM.Commands.mute = {
    Description = "Замутить игрока.",
    ShowPlayerList = true,
    Callback = function(ply, args)
        args = args or {}

        if not IsValid(ply) then
            ply = Entity(0)
        end
        
        if IsValid(ply) and ply:IsPlayer() and not SB_AM.Ranks.HasPermission(ply, "mute") then
            SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
            return
        end

        if not args[1] then
            SB_AM.Log("Укажите игрока", "error", ply)
            return
        end

        local target = SB_AM.FindPlayer(args[1])

        if not target then
            SB_AM.Log("Игрок не найден", "info", ply)
            return
        end
        
        if IsValid(target) then
            target.isMuted = true
            
            net.Start("SB_AM_MuteStatus")
            net.WriteString("")
            net.WriteInt(0, 32)
            net.Send(target)
        end

        local adminName = IsValid(ply) and ply:Nick() or "Console"
        SB_AM.Log(adminName .. " замутил игрока " .. target:Nick() .. " (" .. target:SteamID() .. ")", "info", ply)
    end
}

return SB_AM.Commands.mute
