SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

SB_AM.Commands.unjail = {
    Description = "Освобождает игрока от тюрьмы.",
    ShowPlayerList = true,
    Callback = function(ply, args)
        if IsValid(ply) and ply:IsPlayer() and not SB_AM.Ranks.HasPermission(ply, "jail") then
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
                if player ~= ply and player.frozen then
                    steamid = player:SteamID()
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
            SB_AM.Log("Игрок не найден или не находится в тюрьме", "error", ply)
            return
        end

        for _, target in ipairs(targets) do
            if timer.Exists("Jail_" .. target:SteamID64()) then
                timer.Remove("Jail_" .. target:SteamID64())
            end

            if target.preJailPosition then
                target:SetPos(target.preJailPosition)
                target.preJailPosition = nil
            else
                target:SetPos(Vector(0, 0, 0))
            end

            target:EmitSound("ambient/machines/teleport" .. math.random(1, 4) .. ".wav")
            target:SetMoveType(MOVETYPE_WALK)
            target.frozen = false
        end

        local executorName = SB_AM.GetExecutorName(ply)
        if #targets > 1 then
            SB_AM.Log(executorName .. " освободил всех игроков из тюрьмы!", "info")
        else
            SB_AM.Log(executorName .. " освободил " .. targets[1]:Nick() .. " ( " .. targets[1]:SteamID() .. " ) " .. " из тюрьмы!", "info")
        end
    end
}
