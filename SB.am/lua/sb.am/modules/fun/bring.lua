SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

SB_AM.Commands.bring = {
    Description = "Телепортирует игрока к себе.",
    ShowPlayerList = true,
    Callback = function(ply, args)
        if not IsValid(ply) then
            SB_AM.Log("Серьезно? Консоль телепортирует к себе игрока? Ну ты и рофлан.", "error", ply)
            return
        end
        
        if not SB_AM.Ranks.HasPermission(ply, "bring") then
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

        if target == ply then
            SB_AM.Log("Вы не можете телепортировать самого себя", "error", ply)
            return
        end

        local adminPos = ply:GetPos()
        local adminAngles = ply:EyeAngles()

        local offset = adminAngles:Forward() * 100 
        local teleportPos = adminPos + offset
        
        target:SetPos(teleportPos)
        target:SetEyeAngles(adminAngles - Angle(0, 180, 0))
        
        target:EmitSound("ambient/machines/teleport" .. math.random(1, 4) .. ".wav")
        
        SB_AM.Log(ply:Nick() .. " телепортировал к себе " .. target:Nick() .. " ( " .. target:SteamID() .. ")", "info")
    end
}

return SB_AM.Commands.bring
