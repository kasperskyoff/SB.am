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