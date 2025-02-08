SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

hook.Add("SetupMove", "SB_AM_JailMove", function(ply, mv)
    if ply.frozen then

        mv:SetVelocity(Vector(0, 0, 0))
        mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
        

        local pos = mv:GetOrigin()
        pos.z = 9999
        mv:SetOrigin(pos)
    end
end)

hook.Add("PlayerDisconnected", "SB_AM_JailDisconnect", function(ply)
    if ply.frozen then
        SB_AM.Log(ply:Nick() .. " покинул сервер во время тюрьмы!", "info")
    end
end)

SB_AM.Commands.jail = {
    Description = "Отправляет игрока в тюрьму.",
    ShowPlayerList = true,
    Arguments = {
        {name = "Время (например: 10 секунд)", required = true},
        {name = "Причина", required = true}
    },
    Callback = function(ply, args)
        args = args or {}

        if not IsValid(ply) then
            ply = Entity(0)
        end
        
        if IsValid(ply) and ply:IsPlayer() and not SB_AM.Ranks.HasPermission(ply, "jail") then
            SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
            return
        end
        
        if not args[1] then
            SB_AM.Log("Укажите игрока", "error", ply)
            return
        end

        if not args[2] then
            SB_AM.Log("Укажите время в секундах (0 = навсегда)", "error", ply)
            return
        end

        if not args[3] then
            SB_AM.Log("Укажите причину", "error", ply)
            return
        end

        local targets = {}
        if args[1] == "*" then
            for _, player in ipairs(player.GetAll()) do
                if player ~= ply then
                    table.insert(targets, player)
                end
            end
        else
            local target = SB_AM.FindPlayer(args[1])
            if target then
                targets = {target}
            end
        end

        if #targets == 0 then
            SB_AM.Log("Игрок не найден", "error", ply)
            return
        end

        local time = tonumber(args[2])
        if not time then
            SB_AM.Log("Время должно быть числом", "error", ply)
            return
        end

        local reason = table.concat(args, " ", 3)
        
        for _, target in ipairs(targets) do
            target.preJailPosition = target:GetPos()
            
            local pos = target:GetPos()
            target:SetPos(Vector(pos.x, pos.y, 9999))
            target:EmitSound("ambient/machines/teleport" .. math.random(1, 4) .. ".wav")
            
            target:SetMoveType(MOVETYPE_NONE)
            target:SetNoDraw(false)
            target.frozen = true
            
            if time > 0 then
                timer.Create("Jail_" .. target:SteamID64(), time, 1, function()
                    if IsValid(target) then
                        if target.preJailPosition then
                            target:SetPos(target.preJailPosition)
                            target.preJailPosition = nil
                        else
                            target:SetPos(Vector(0, 0, 0))
                        end
                        
                        target:EmitSound("ambient/machines/teleport" .. math.random(1, 4) .. ".wav")
                        target:SetMoveType(MOVETYPE_WALK)
                        target.frozen = false
                        
                        SB_AM.Log(target:Nick() .. " освобожден из тюрьмы (истекло время)", "info")
                    end
                end)
            end
        end

        local timeStr = time == 0 and "навсегда" or string.format("%d секунд", time)
        if #targets > 1 then
            SB_AM.Log(SB_AM.GetExecutorName(ply) .. " отправил всех игроков в тюрьму на " .. timeStr .. "! По причине: " .. reason, "info")
        else
            SB_AM.Log(SB_AM.GetExecutorName(ply) .. " отправил " .. targets[1]:Nick() .. " ( " .. targets[1]:SteamID() .. " ) " .. " в тюрьму на " .. timeStr .. "! По причине: " .. reason, "info")
        end
    end
}

return SB_AM.Commands.jail
