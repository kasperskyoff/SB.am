include("sb.am/shared/sh_category.lua")
include("cl_logs.lua")
include("cl_menu.lua")

local function ParseCommandArgs(text)
    local args = {}
    for arg in string.gmatch(text, "%S+") do
        table.insert(args, arg)
    end

    table.remove(args, 1)
    return args
end

local function GetTargetPlayer(ply)
    local trace = ply:GetEyeTrace()
    if trace.Hit and trace.Entity and trace.Entity:IsPlayer() then
        return trace.Entity
    end
    return nil
end

local function ProcessAtSymbol(ply, args)
    for i, arg in ipairs(args) do
        if arg == "@" then
            local target = GetTargetPlayer(ply)
            if target then
                args[i] = target:Nick()
            end
        end
    end
    return args
end


hook.Add("OnPlayerChat", "SunBoxAdminMenuChatCommand", function(ply, text, teamChat, isDead)
    if ply != LocalPlayer() then return end

    if not IsValid(ply) then return end
    local cleanText = string.Trim(string.lower(text))
    
    if cleanText == "!menu" or cleanText == "/menu" or cleanText == ".menu" then
        SunBoxAdminMenu()
        return true
    end

    for _, subCategory in ipairs(SB_AM.Categories.Main.SubCategories) do
        for _, cmd in ipairs(subCategory.Commands) do
            local cmdName = string.lower(cmd.Commands)
            local prefixes = {"!", "/", "."}
            
            for _, prefix in ipairs(prefixes) do
                local fullCmd = prefix .. cmdName
                local inputParts = string.Explode(" ", cleanText)
                local inputCmd = inputParts[1] -- Берем только первое слово (команду)
                
                if inputCmd == fullCmd then -- Точное сравнение команды
                    if SB_AM.Ranks.HasPermission(ply, cmdName) then
                        local args = ParseCommandArgs(text)
                        args = ProcessAtSymbol(ply, args)
                        
                        local success, err = pcall(function()
                            SB_AM.ExecuteCommand(cmdName, ply, args)
                        end)
                        
                        if not success then
                            chat.AddText(Color(255, 0, 0), "Ошибка выполнения команды: " .. tostring(err))
                        end
                        return true
                    else
                        chat.AddText(Color(255, 0, 0), "У вас нет прав на использование этой команды!")
                        return true
                    end
                end
            end
        end
    end
end)
