SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

SB_AM.Commands.kill = {
    Description = "Убивает игрока.",
    ShowPlayerList = true,
    Callback = function(ply, args)
        args = args or {}

        if not IsValid(ply) then
            ply = Entity(0)
        end
        
        if IsValid(ply) and ply:IsPlayer() and not SB_AM.Ranks.HasPermission(ply, "kill") then
            SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
            return
        end
        
        if not args[1] then
            SB_AM.Log("Укажите игрока", "error", ply)
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

        local executorName = SB_AM.GetExecutorName(ply)
        for _, target in ipairs(targets) do
            if IsValid(target) and target:Alive() then
                if target.isBanned then
                    local currentColor = target:GetColor()
                    local currentRenderMode = target:GetRenderMode()
                    
                    target:Kill()
                    
                    timer.Simple(0.1, function()
                        if IsValid(target) then
                            target:SetRenderMode(currentRenderMode)
                            target:SetColor(currentColor)
                        end
                    end)
                else
                    target:Kill()
                end
            end
        end

        if #targets > 1 then
            SB_AM.Log(executorName .. " убил всех игроков", "info")
        else
            SB_AM.Log(executorName .. " убил игрока " .. targets[1]:Nick() .. " ( " .. targets[1]:SteamID() .. " ) ", "info")
        end
    end
}

return SB_AM.Commands.kill
