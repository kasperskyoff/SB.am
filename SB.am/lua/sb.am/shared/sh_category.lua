SB_AM = SB_AM or {}
SB_AM.Categories = SB_AM.Categories or {}
SB_AM.Commands = SB_AM.Commands or {}

local CATEGORY = {
    SubCategories = {
        {
            Name = "Базовое",
            Category = "base",
            Commands = {
                {Name = "ban", Commands = "ban"},
                {Name = "unban", Commands = "unban"},
                {Name = "jail", Commands = "jail"},
                {Name = "unjail", Commands = "unjail"},
                {Name = "kick", Commands = "kick"},
                {Name = "mute", Commands = "mute"},
                {Name = "unmute", Commands = "unmute"},
                {Name = "vote", Commands = "vote"},
                {Name = "addgroup", Commands = "addgroup"},
                {Name = "help", Commands = "help"},
                {Name = "noclip", Commands = "noclip"},
                {Name = "pvp", Commands = "pvp"},
                {Name = "build", Commands = "build"}
            }
        },
        {
            Name = "Развлечения",
            Category = "fun",
            Commands = {
                {Name = "bring", Commands = "bring"},
                {Name = "goto", Commands = "goto"},
                {Name = "returnto", Commands = "returnto"},
                {Name = "psa", Commands = "psa"},
                {Name = "kill", Commands = "kill"}
            }
        }
    }
}

-- Функция для загрузки всех файлов из папки
local function IncludeFolder(folderPath)
    local files, _ = file.Find(folderPath .. "/*.lua", "LUA")
    
    for _, fileName in ipairs(files) do
        local filePath = folderPath .. "/" .. fileName
        if SERVER then
            AddCSLuaFile(filePath)
            include(filePath) 
        end
        if CLIENT then
            include(filePath)
        end
    end
end

-- Загружаем все команды из подкатегорий
for _, subCategory in ipairs(CATEGORY.SubCategories) do
    local folderPath = "sb.am/modules/" .. subCategory.Category
    IncludeFolder(folderPath)
end

SB_AM.Categories.Main = CATEGORY

function SB_AM.ExecuteCommand(commandName, ply, args)
    if SB_AM.Commands[commandName] then
        if SB_AM.Commands[commandName].Callback then
            if CLIENT then
                net.Start("SB_AM_ClientCommand")
                net.WriteString(commandName)
                net.WriteTable(args or {})
                net.SendToServer()
                return true, true
            else
                SB_AM.Commands[commandName].Callback(ply, args or {})
                return true, true
            end
        else
            return true, false
        end
    end
    return false, false
end

function SB_AM.CreateCommandButton(parent, command, y)

    local ply = LocalPlayer()
    if not SB_AM.Ranks.HasPermission(ply, command) then
        return nil
    end

    local button = vgui.Create("DButton", parent)
    button:SetText(SB_AM.Commands[command].Name)
    button:SetPos(10, y)
    button:SetSize(100, 30)
    button.DoClick = function()
        SB_AM.ExecuteCommand(command, ply)
        local descPanel = vgui.Create("DPanel", parent)
        descPanel:SetSize(200, 30)
        descPanel:SetPos(120, y)
        descPanel.Paint = function(self, w, h)
            SB_AM.DrawCommandDescription(command)
        end
        timer.Simple(3, function()
            if IsValid(descPanel) then
                descPanel:Remove()
            end
        end)
    end
    return button
end

if SERVER then
    util.AddNetworkString("SB_AM_ClientCommand")
    net.Receive("SB_AM_ClientCommand", function(len, ply)
        local commandName = net.ReadString()
        local args = net.ReadTable()
        
        if SB_AM.Commands[commandName] then
            SB_AM.Commands[commandName].Callback(ply, args)
        end
    end)
end


-- Если вы хотите создать команду любую (новую или старую или какую там еще), то добро пожаловать в мой гайд. 
-- Пишите:
-- SB_AM = SB_AM or {}
-- SB_AM.Commands = SB_AM.Commands or {}

-- SB_AM.Commands.ВАША_КОМАНДА = {
--     Name = "ВАША_КОМАНДА", -- Название команды
--     Description = "Описание команды", -- Описание команды
--     Arguments = { -- Аргументы команды
--         {name = "Время (например: 10)", required = true}, -- Это звездочка (Обязательно)
--         {name = "Причина", required = true} -- Это тоже звездочка (Обязательно)
--     },
--     Callback = function(ply, args)
--         -- Ваш код здесь
--     end
-- }

-- Команды должны лежать в любой папке. (например, base), можете создать свою.
-- Но не забывайте еще писать сюда файлы. {Name = "ВАША_КОМАНДА", Commands = "ВАША_КОМАНДА"} -- не забывайте писать Name с большой буквы, а то будет nil
-- И в файле sh_sbam.lua добавить SB_AM.Permissions.ВАШ_КОМАНДА = "ВАША_КОМАНДА" -- Для рангов

-- Обновил SB_AM.Log
-- Примеры использования:

-- Лог ошибки для конкретного игрока
-- SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)

-- Информационное сообщение для конкретного игрока
-- SB_AM.Log("Команда выполнена успешно", "info", ply)
-- Попроще
-- SB_AM.Log("Сообщение", "error", ply) -- сообщение об ошибке увидит только указанный игрок
-- SB_AM.Log("Сообщение", "info", ply) -- Информационное сообщение для конкретного игрока
-- SB_AM.Log("Сообщение", "adminconsole") -- Сообщение только в консоль админов
-- SB_AM.Log("Сообщение", "info", nil, true) -- Сообщение только в консоль (если указать nil, true)
-- Без ply будет видно всем

-- Перейдем про description
-- В description можно добавлять аргументы, которые будут отображаться в окошке аргументов.
-- {name = "Время (например: 10)", required = true} -- required = true, это звездочка (Обязательно) а если false, то не обязательно
-- {name = "Причина", required = true} -- Это тоже звездочка (Обязательно)

-- Можно использовать символ @, он будет заменяться на ник игрока, на которого смотрит администратор.
-- Например: !ban @ 0m пока
