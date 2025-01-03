SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}
SB_AM.LastPositions = SB_AM.LastPositions or {}

SB_AM.Commands.returnto = {
    Description = "Возвращает себя на старую позицию.",
    Callback = function(ply, args)
        if not IsValid(ply) then
            SB_AM.Log("Серьезно? Консоль пытается вернуться? Ну ты и рофлан.", "error", ply)
            return
        end

        if not SB_AM.Ranks.HasPermission(ply, "returnto") then
            SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
            return
        end

        if not SB_AM.LastPositions[ply:SteamID()] then
            SB_AM.Log("У вас нет сохраненной позиции для возврата", "error", ply)
            return
        end

        local lastPos = SB_AM.LastPositions[ply:SteamID()].pos
        local lastAngles = SB_AM.LastPositions[ply:SteamID()].angles

        ply:SetPos(lastPos)
        ply:SetEyeAngles(lastAngles)
        ply:EmitSound("ambient/machines/teleport" .. math.random(1, 4) .. ".wav")

        SB_AM.LastPositions[ply:SteamID()] = nil

        SB_AM.Log(ply:Nick() .. " вернулся на предыдущую позицию", "info")
    end
}

hook.Add("PrePlayerTeleport", "SB_AM_SaveLastPosition", function(ply)
    SB_AM.LastPositions[ply:SteamID()] = {
        pos = ply:GetPos(),
        angles = ply:EyeAngles()
    }
end)

return SB_AM.Commands.returnto
