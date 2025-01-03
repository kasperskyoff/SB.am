net.Receive("SB_AM_OpenMenu", function()
    SunBoxAdminMenu()
end)

function SunBoxAdminMenu()
    local selectedCommand = nil

    local background = vgui.Create("DPanel")
    background:SetSize(ScrW(), ScrH())
    background:SetPos(0, 0)
    
    local alpha = 0
    local targetAlpha = 200
    background.Think = function()
        alpha = Lerp(FrameTime() * 5, alpha, targetAlpha)
    end
    
    background.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, alpha))
    end
    
    local frame = vgui.Create("DFrame")
    local screenW, screenH = ScrW(), ScrH()
    local frameW, frameH = math.min(screenW * 0.8, 1100), math.min(screenH * 0.8, 630)
    
    frame:SetTitle("")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    frame.OnRemove = function()
        if IsValid(background) then
            targetAlpha = 0
            background.Think = function()
                alpha = Lerp(FrameTime() * 5, alpha, targetAlpha)
                if alpha < 1 then
                    background:Remove()
                end
            end
        end
    end
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(20, 0, 30, w, 600, Color(20, 20, 20, 240))
        draw.RoundedBox(5, 16, 0, 230, 30, Color(20, 20, 20, 240))
        draw.RoundedBox(5, 13, 70, 230, 540, Color(41, 41, 41, 240))
        draw.RoundedBox(5, 246, 70, 230, 540, Color(41, 41, 41, 240))
        draw.RoundedBox(5, 479, 70, 375, 540, Color(41, 41, 41, 240))
        draw.RoundedBox(5, 857, 70, 230, 540, Color(41, 41, 41, 240))
        
        -- Версия (Сначала будет Alpha Version потом Beta Version и когда выйдет полная версия можно удалить)
        -- draw.SimpleText("С Новым 2025 годом!", "SB_AM_ButtonFont", 940, 620, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Заголовки
        draw.RoundedBox(5, 76, 40, 100, 30, Color(41, 41, 41, 240))
        draw.SimpleText("Команды", "HudDefault", 126, 55, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.RoundedBox(5, 605, 40, 100, 30, Color(41, 41, 41, 240))
        draw.SimpleText("Логи", "HudDefault", 655, 55, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.RoundedBox(5, 910, 40, 120, 30, Color(41, 41, 41, 240))
        draw.SimpleText("Выполнение", "HudDefault", 970, 55, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Для команды.
        draw.RoundedBox(5, 865, 80, 214, 90, Color(20, 20, 20, 250))
        -- Название
        draw.SimpleText("☀", "Trebuchet24", 26, 15, Color(255, 163, 3), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(" SunBox Admin Menu", "Trebuchet24", 45, 15, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local playButton = CreatePlayButton(frame)
    playButton:SetPos(873, 550)
    playButton.DoClick = function()
        local selectedCommand = GetSelectedCommand()
        if selectedCommand then
            local commandData = SB_AM.Commands[selectedCommand]
            local args = {}
            
            if commandData.ShowPlayerList then
                local selectedPlayer = SB_AM.GetSelectedPlayer()
                if not selectedPlayer then
                    if IsValid(SB_AM.ArgumentsPanel) then
                        local inputArgs = SB_AM.ArgumentsPanel:GetArguments()
                        if inputArgs[1] and string.match(inputArgs[1], "STEAM_%d+:%d+:%d+") then
                            table.insert(args, inputArgs[1])
                            for i = 2, #inputArgs do
                                table.insert(args, inputArgs[i])
                            end
                        else
                            SB_AM.Log("Укажите корректный SteamID (STEAM_X:Y:Z)", "error")
                            return
                        end
                    else
                        SB_AM.Log("Выберите игрока или укажите SteamID", "error")
                        return
                    end
                else
                    table.insert(args, selectedPlayer:Nick())
                    if IsValid(SB_AM.ArgumentsPanel) then
                        local inputArgs = SB_AM.ArgumentsPanel:GetArguments()
                        for _, arg in ipairs(inputArgs) do
                            table.insert(args, arg)
                        end
                    end
                end
            else
                -- Для команд без списка игроков просто добавляем все аргументы
                if IsValid(SB_AM.ArgumentsPanel) then
                    local inputArgs = SB_AM.ArgumentsPanel:GetArguments()
                    for _, arg in ipairs(inputArgs) do
                        table.insert(args, arg)
                    end
                end
            end
            
            SB_AM.ExecuteCommand(selectedCommand, LocalPlayer(), args)
        end
    end

    local closeButton = vgui.Create("DButton", frame)

    closeButton:SetText("")
    closeButton:SetPos(frame:GetWide() - 35, 37)
    closeButton:SetSize(25, 25)
    closeButton.DoClick = function()
        frame:Close()
    end
    closeButton.Paint = function(self, w, h)
        draw.SimpleText("✕", "Trebuchet24", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if self:IsHovered() then
            draw.RoundedBox(12, 0, 0, w, h, Color(80, 80, 80, 100))
        end
    end

    local commandsScroll = vgui.Create("DScrollPanel", frame)
    commandsScroll:SetPos(13, 70)
    commandsScroll:SetSize(230, 540)

    if CreateCategoryButtons then
        CreateCategoryButtons(commandsScroll, "Команды", UpdateSelectedCommand)
    end

    if SB_AM and SB_AM.Logs and SB_AM.Logs.CreateLogsList then -- логи
        SB_AM.LogPanel = SB_AM.Logs.CreateLogsList(frame)
    end

    if SB_AM and SB_AM.CreatePlayerList then -- список игроков
        SB_AM.PlayerList = SB_AM.CreatePlayerList(frame)
    end

    local descriptionPanel = vgui.Create("DLabel", frame)
    descriptionPanel:SetPos(870, 85)
    descriptionPanel:SetSize(210, 90)
    descriptionPanel:SetTextColor(Color(255, 255, 255))
    descriptionPanel:SetFont("SB_AM_DescriptionFont")
    descriptionPanel:SetWrap(true)
    descriptionPanel:SetContentAlignment(7)
    descriptionPanel:SetText("Выберите команду из списка.")
    
    -- Функция для получения минимального ранга с доступом к команде
    local function GetAvailableRanks(permission)
        if not permission then return "Все" end
        
        local lowestRank = nil
        local lowestImmunity = math.huge
        
        for rankID, rankData in pairs(SB_AM.Ranks.List) do
            if table.HasValue(rankData.permissions, "*") or table.HasValue(rankData.permissions, permission) then
                if rankData.immunity < lowestImmunity then
                    lowestImmunity = rankData.immunity
                    lowestRank = rankData.name
                end
            end
        end
        
        return lowestRank or "Нет"
    end

    -- Обновляем функцию обновления описания команды
    function UpdateCommandDescription(command)
        if not command or not SB_AM.Commands[command] then
            descriptionPanel:SetText("Выберите команду из списка.")
            return
        end

        local commandData = SB_AM.Commands[command]
        local description = commandData.Description or "Нет описания"
        local rank = GetAvailableRanks(command)
        
        local fullDescription = description .. "\n\nДоступно с: " .. rank
        descriptionPanel:SetText(fullDescription)
    end

    -- панель описания
    SB_AM.CommandDescription = descriptionPanel
    SB_AM.UpdateCommandDescription = UpdateCommandDescription

    -- панель аргументов
    SB_AM.ArgumentsPanel = CreateArgumentInput(frame)
end