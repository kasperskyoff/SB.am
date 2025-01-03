SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

SB_AM.Commands.kick = {
    Description = "Кикает игрока.",
    ShowPlayerList = true,
    Arguments = {
        {name = "Причина", required = true}
    },
    Callback = function(ply, args)
        args = args or {}

        if not IsValid(ply) then
            ply = Entity(0)
        end
        
        if IsValid(ply) and ply:IsPlayer() and not SB_AM.Ranks.HasPermission(ply, "kick") then
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

        local reason = args[2] and table.concat(args, " ", 2) or "Без причины"
        local executorName = SB_AM.GetExecutorName(ply)
        
        for _, target in ipairs(targets) do
            target:Kick("Вы были кикнуты с сервера\nАдмином: " .. executorName .. "\nПричина: " .. reason)
        end

        if #targets > 1 then
            SB_AM.Log(executorName .. " кикнул всех игроков " .. "по причине: " .. reason, "info")
        else
            SB_AM.Log(executorName .. " кикнул игрока " .. targets[1]:Nick() .. " (" .. targets[1]:SteamID() .. ")" .. " по причине: " .. reason, "info")
        end
    end
}

return SB_AM.Commands.kick
