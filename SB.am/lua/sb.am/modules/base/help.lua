SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

SB_AM.Commands.help = {
    Description = "Показать список команд.",
    Callback = function(ply, args)
        if not IsValid(ply) then
            ply = Entity(0)
        end

        local commandsByCategory = {}
        for _, subCategory in ipairs(SB_AM.Categories.Main.SubCategories) do
            local categoryCommands = {}
            for _, cmd in ipairs(subCategory.Commands) do
                if IsValid(ply) and ply:IsPlayer() then
                    if SB_AM.Ranks.HasPermission(ply, cmd.Commands) then
                        table.insert(categoryCommands, cmd.Name)
                    end
                else
                    table.insert(categoryCommands, cmd.Name)
                end
            end
            if #categoryCommands > 0 then
                commandsByCategory[subCategory.Name] = categoryCommands
            end
        end

        if SERVER then
            if IsValid(ply) and ply:IsPlayer() then
                ply:ChatPrint("=== Доступные команды ===")
                for category, commands in pairs(commandsByCategory) do
                    ply:ChatPrint(category .. ": " .. table.concat(commands, ", "))
                    SB_AM.Logs.AddLog("Вы запросили список команд! " .. category .. ": " .. table.concat(commands, ", "))
                end
            else
                print("=== Доступные команды ===")
                for category, commands in pairs(commandsByCategory) do
                    print(category .. ": " .. table.concat(commands, ", "))
                end
            end
        end

        SB_AM.Log(SB_AM.GetExecutorName(ply) .. " запросил список команд", "info", nil, true)
    end
}

return SB_AM.Commands.help
