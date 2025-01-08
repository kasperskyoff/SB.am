SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

SB_AM.LogPrefix = Color(255, 164, 3)
SB_AM.LogPrefixError = Color(255, 0, 0)
SB_AM.TimeColor = Color(11,253,213)

local function GetTimeString()
    local time = os.date("*t")
    return string.format("[%02d:%02d:%02d]", time.hour, time.min, time.sec)
end

function SB_AM.Log(message, logType, target, consoleOnly)
    if not message then return end
    message = tostring(message)
    
    local LOG_TYPES = {
        error = {color = SB_AM.LogPrefixError, prefix = "[SB.am ERROR]"},
        info = {color = SB_AM.LogPrefix, prefix = "[SB.am]"},
        adminconsole = {color = Color(150, 150, 255), prefix = "[SB.am CONSOLE]"}
    }
    
    local typeData = LOG_TYPES[logType or "info"]
    if not typeData then
        typeData = LOG_TYPES["info"]
    end
    
    local timeStr = GetTimeString()
    
    MsgC(SB_AM.TimeColor, timeStr, " ",
         typeData.color, typeData.prefix,
         Color(255, 255, 255), ": " .. message .. "\n")
    
    if SERVER then
        local function SendToAdmins(msg)
            for _, ply in ipairs(player.GetAll()) do
                if SB_AM.Ranks.HasPermission(ply, "adminconsole") then
                    net.Start("SB_AM_ConsoleMessage")
                    net.WriteColor(SB_AM.TimeColor)
                    net.WriteString(timeStr)
                    net.WriteColor(typeData.color)
                    net.WriteString(typeData.prefix)
                    net.WriteColor(Color(255, 255, 255))
                    net.WriteString(": " .. msg)
                    net.Send(ply)
                end
            end
        end

        local function SendToPlayers(msg, targetPlayer)
            local recipients = targetPlayer and {targetPlayer} or player.GetAll()
            for _, ply in ipairs(recipients) do
                if IsValid(ply) and ply:IsPlayer() then
                    net.Start("SB_AM_ChatMessage")
                    net.WriteString(msg)
                    net.WriteTable({color = typeData.color, prefix = typeData.prefix})
                    net.Send(ply)
                end
            end
        end

        if not (logType == "error" and target) then
            SB_AM.Logs.AddLog(message, logType)
        end
        
        if logType == "adminconsole" then
            SendToAdmins(message)
        elseif not consoleOnly then
            SendToPlayers(message, target)
        end
    end
end

-----------------------------------------
------Настройки на игроков---------
-----------------------------------------
function SB_AM.ToolLog(ply, tool)
    SB_AM.Log(ply:Nick() .. " (" .. ply:SteamID() .. ") воспользовался инструментом: " .. tool, "adminconsole")
end

function SB_AM.PropSpawnLog(ply, model)
    SB_AM.Log(ply:Nick() .. " (" .. ply:SteamID() .. ") заспавнил проп: " .. model, "adminconsole")
end

if SERVER then
    hook.Add("PhysgunPickup", "SB_AM_PhysgunPickup", function(ply, target) -- Физган для модеров и админов (права SB_AM.Permissions.PHYSGUN)
        if not IsValid(target) or not target:IsPlayer() then return end
        if not SB_AM.Ranks.HasPermission(ply, SB_AM.Permissions.PHYSGUN) then return false end
        if not SB_AM.Ranks.CanTarget(ply, target) then return false end

        target:SetMoveType(MOVETYPE_NOCLIP)
        return true
    end)

    hook.Add("PhysgunDrop", "SB_AM_PhysgunFreeze", function(ply, target)
        if not IsValid(target) or not target:IsPlayer() then return end
        
        if not SB_AM.Ranks.HasPermission(ply, SB_AM.Permissions.PHYSGUN) then return end
        
        if not SB_AM.Ranks.CanTarget(ply, target) then return end
        
        if ply:KeyDown(IN_ATTACK2) then
            target:Freeze(true)
            target:EmitSound("ambient/levels/labs/electric_explosion" .. math.random(1, 4) .. ".wav")
            target:SetMoveType(MOVETYPE_NONE)
            target:GodEnable()
        else
            target:Freeze(false) 
            target:SetMoveType(MOVETYPE_WALK)
            target:GodDisable()
        end
    end)
end
-----------------------------------------

local function IncludeFolder(folderPath, isClient)
    local files, _ = file.Find(folderPath .. "/*.lua", "LUA")

    for _, fileName in ipairs(files) do
        local filePath = folderPath .. "/" .. fileName
        
        if SERVER then
            if isClient then
                AddCSLuaFile(filePath)
            else
                include(filePath)
            end
        elseif CLIENT then
            include(filePath)
        end
    end
end

function SB_AM.LoadFiles() -- Загрузка автоматом файлов
    include("sb.am/sql/sql_sb.am.lua")
    if SERVER then
        AddCSLuaFile("sb.am/sql/sql_sb.am.lua")
    end

    include("sb.am/shared/sh_sbam.lua")
    if SERVER then
        AddCSLuaFile("sb.am/shared/sh_sbam.lua")
    end

    include("sb.am/shared/sh_logs.lua")
    if SERVER then
        AddCSLuaFile("sb.am/shared/sh_logs.lua")
    end

    include("sb.am/shared/sh_category.lua")
    if SERVER then
        AddCSLuaFile("sb.am/shared/sh_category.lua")
    end

    if SERVER then
        IncludeFolder("sb.am/client", true)
        IncludeFolder("sb.am/modules", false)
    elseif CLIENT then
        IncludeFolder("sb.am/client", false)
        IncludeFolder("sb.am/modules", false)
    end
    
    local hasErrors = false
    
    if not SB_AM.Categories or not SB_AM.Categories.Main then
        SB_AM.Log("В структуре проекта обнаружены ошибки. Пожалуйста, проверьте содержимое файлов.", "error", nil, true)
        hasErrors = true
    end
    
    SB_AM.RegisterConsoleCommands()
    
    if SERVER then
        if hasErrors then
            SB_AM.Log("Загрузка завершена с ошибками.", "error", nil, true)
        else
            SB_AM.Log("Все модули были успешно загружены!", "info", nil, true)
        end
    end
end

function SB_AM.ExecuteCommand(commandName, ply, args)
    if not SB_AM.Commands[commandName] then
        SB_AM.Log("Команда '" .. commandName .. "' не найдена.", "error")
        return false, false
    end

    local command = SB_AM.Commands[commandName]
    
    if not SB_AM.Ranks.HasPermission(ply, command.Permission) then
        SB_AM.Log(ply:Nick() .. " попытался выполнить команду '" .. commandName .. "', но у него нет доступа.", "error", ply, true)
        return false, false
    end

    if not command.Callback then
        SB_AM.Log("Команда '" .. commandName .. "' настроена неправильно.", "error", nil, true)
        return true, false 
    end

    command.Callback(ply, args)
    return true, true
end

function SB_AM.RegisterConsoleCommands()
    if not SB_AM.Categories or not SB_AM.Categories.Main then
        SB_AM.Log("Ошибка - структура категорий не инициализирована!", "error", nil, true)
        return
    end

    if not SB_AM.Categories.Main.SubCategories then
        SB_AM.Log("Ошибка - подкатегории не найдены!", "error", nil, true)
        return
    end

    concommand.Add("sb", function(ply, cmd, args)
        local commandName = args[1]
        if not commandName then
            SB_AM.Log("Пожалуйста, укажите команду.", "error", ply)
            
            local commandsByCategory = {}
            for _, subCategory in ipairs(SB_AM.Categories.Main.SubCategories) do
                local categoryCommands = {}
                for _, cmd in ipairs(subCategory.Commands) do
                    if IsValid(ply) and ply:IsPlayer() then
                        if SB_AM.Ranks.HasPermission(ply, cmd.Permission) then
                            table.insert(categoryCommands, cmd.Commands)
                        end
                    else
                        table.insert(categoryCommands, cmd.Commands)
                    end
                end
                if #categoryCommands > 0 then
                    commandsByCategory[subCategory.Name] = categoryCommands
                end
            end
            
            SB_AM.Log("=== Доступные команды ===", "info", ply)
            for category, commands in pairs(commandsByCategory) do
                SB_AM.Log(category .. ": " .. table.concat(commands, ", "), "info", ply)
            end
            return
        end

        if commandName == "menu" then -- Специальная команда для открытия меню из файла cl_menu.lua
            if CLIENT then
                SunBoxAdminMenu()
            else
                net.Start("SB_AM_OpenMenu")
                net.Send(ply)
            end
            return
        end

        local success, isValid = SB_AM.ExecuteCommand(commandName, ply, {unpack(args, 2)})
        if not success then
            SB_AM.Log("Команда '" .. commandName .. "' не найдена.", "error", nil, true)
        elseif not isValid then
            SB_AM.Log("Команда работает с ошибками! Выполнение команды невозможно.", "error", nil, true)
        end
    end, SB_AM.AutoComplete)
end

if CLIENT then
    net.Receive("SB_AM_CommandExec", function()
        local args = util.JSONToTable(net.ReadString())
        local cmd = args[1]
        if SB_AM.Commands[cmd] then
            table.remove(args, 1)
            SB_AM.Commands[cmd].Callback(LocalPlayer(), args)
        end
    end)

    function SB_AM.AutoComplete(cmd, stringargs)
        local args = string.Explode(" ", stringargs)
        local command = args[1]
        local results = {}

        for _, subCategory in ipairs(SB_AM.Categories.Main.SubCategories) do
            for _, cmd in ipairs(subCategory.Commands) do
                if command == "" or string.StartWith(cmd.Commands, command) then
                    table.insert(results, "sb " .. cmd.Commands)
                end
            end
        end

        return results
    end

    function SB_AM.RunCommand(ply, cmd, args)
        if SB_AM.Commands[cmd] then
            net.Start("SB_AM_CommandExec")
            net.WriteString(util.TableToJSON({cmd, unpack(args)}))
            net.SendToServer()
        end
    end

    concommand.Add("sb", function(ply, _, args)
        SB_AM.RunCommand(ply, args[1], {unpack(args, 2)})
    end, SB_AM.AutoComplete)
end

if SERVER then
    util.AddNetworkString("SB_AM_OpenMenu")
    util.AddNetworkString("UpdatePlayerMode")
    util.AddNetworkString("SB_AM_CommandExec")
    util.AddNetworkString("SB_AM_ConsoleMessage") -- Для консоли админов

    net.Receive("SB_AM_CommandExec", function(len, ply)
        local args = util.JSONToTable(net.ReadString())
        local cmd = args[1]
        if SB_AM.Commands[cmd] then
            table.remove(args, 1)
            SB_AM.Commands[cmd].Callback(ply, args)
        end
    end)

    hook.Add("PlayerSpawnedProp", "SB_AM_PropSpawnLog", function(ply, model)
        SB_AM.PropSpawnLog(ply, model)
    end)

    hook.Add("CanTool", "SB_AM_ToolLog", function(ply, tr, toolname)
        SB_AM.ToolLog(ply, toolname)
    end)
end

-- Имя для консоли
function SB_AM.GetExecutorName(ply)
    if IsValid(ply) and ply:IsPlayer() then
        return ply:Nick()
    end
    return "Console"
end

function SB_AM.FindPlayer(identifier) -- Взаимодействие с игроками
    if not identifier then return nil end
    
    identifier = string.Trim(identifier)
    
    if string.match(identifier, "STEAM_%d:%d:%d+") then
        for _, player in ipairs(player.GetAll()) do
            if player:SteamID() == identifier then
                return player
            end
        end
    end
    
    local searchName = string.lower(identifier)
    searchName = string.gsub(searchName, "[%p%s]", "")
    
    for _, player in ipairs(player.GetAll()) do
        local playerName = string.lower(player:Nick())
        playerName = string.gsub(playerName, "[%p%s]", "")
        
        if string.find(playerName, searchName) then
            return player
        end
    end
    
    return nil
end

SB_AM.LoadFiles()

if SERVER then
    AddCSLuaFile()
end

-- Для чата
if SERVER then
    util.AddNetworkString("SB_AM_ChatMessage")
end

if CLIENT then
    net.Receive("SB_AM_ChatMessage", function()
        local message = net.ReadString()
        local data = net.ReadTable()
        chat.AddText(
            data.color, data.prefix,
            Color(255, 255, 255), ": " .. message
        )
    end)
end