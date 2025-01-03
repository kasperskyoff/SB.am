local selectedButton = nil
local selectedCommand = nil

local function CreateStyledButton(parent, x, y, width, height, command, onClick)
    local button = vgui.Create("DButton", parent)
    button:SetPos(x, y)
    button:SetSize(width, height)
    button:SetText("")

    button.isSelected = false

    button.Paint = function(self, w, h)
        if not IsValid(self) then return end
        local bgColor = self:IsHovered() and Color(60, 60, 60, 255) or Color(30, 30, 30, 255)
        draw.RoundedBox(3, 0, 0, w, h, bgColor)
        
        if self.isSelected then
            draw.RoundedBox(3, 1, 1, w-2, h-2, Color(100, 100, 100, 100))
        end
        
        draw.SimpleText(command, SB_AM.Fonts.ButtonFont, w/13, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    button.DoClick = function()
        if not IsValid(button) then return end
        
        if IsValid(selectedButton) and selectedButton ~= button then
            selectedButton.isSelected = false
            if IsValid(SB_AM.PlayerList) then
                SB_AM.PlayerList:SetVisible(false)
            end
            if IsValid(SB_AM.ArgumentsPanel) then
                SB_AM.ArgumentsPanel:SetVisible(false)
            end
        end
        
        button.isSelected = not button.isSelected
        
        if button.isSelected then
            selectedButton = button
            selectedCommand = command
            
            if IsValid(SB_AM.CommandDescription) then
                SB_AM.UpdateCommandDescription(command)
            end
            
            local cmdData = SB_AM.Commands[command]
            if cmdData then
                if cmdData.ShowPlayerList and IsValid(SB_AM.PlayerList) then
                    SB_AM.PlayerList:SetVisible(true)
                end
                
                if cmdData.Arguments and IsValid(SB_AM.ArgumentsPanel) then
                    SB_AM.ArgumentsPanel:SetupArguments(command)
                end
            end
        else
            selectedButton = nil
            selectedCommand = nil
            
            if IsValid(SB_AM.CommandDescription) then
                SB_AM.CommandDescription:SetText("Выберите команду из списка.")
            end
            
            if IsValid(SB_AM.PlayerList) then
                SB_AM.PlayerList:SetVisible(false)
            end
            
            if IsValid(SB_AM.ArgumentsPanel) then
                SB_AM.ArgumentsPanel:SetVisible(false)
            end
        end
    end

    return button
end

function CreatePlayButton(parent)
    local button = vgui.Create("DButton", parent)
    button:SetText("Выполнить")
    -- button:SetPos(6, 6) Можете это удалить, но мы используем положения в cl_menu.lua
    button:SetSize(200, 40)
    button:SetTextColor(Color(255, 255, 255))
    button:SetFont("SB_AM_ButtonFont")

    button.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(30, 30, 30, 250))
        if self:IsHovered() then
            draw.RoundedBox(5, 0, 0, w, h, Color(60, 60, 60, 255))
        end
    end

    button.DoClick = function()
        local selectedCommand = GetSelectedCommand()
        if selectedCommand then
            RunConsoleCommand("sb", selectedCommand)
        end
    end

    return button
end

function CreateCategoryButtons(parent, category)
    local xOffset = 10
    local yOffset = 10
    local categoryWidth = 210
    local categoryHeight = 25
    local categorySpacing = 5 -- Растояние между категориями (база 5)
    local commandHeight = 22 -- размер команды
    local commandSpacing = 0 -- растояние между командами
    local maxCommandsVisible = 10 -- максимальное количество команд (база 10)

    if not SB_AM or not SB_AM.Categories or not SB_AM.Categories.Main then
        SB_AM.Error("Категории не найдены")
        return
    end
    
    if not SB_AM.Categories.Main.SubCategories then
        SB_AM.Error("Подкатегории не найдены")
        return
    end

    local categories = {}

    for _, subCategory in ipairs(SB_AM.Categories.Main.SubCategories) do
        local categoryPermission = subCategory.Permission or SB_AM.Permissions.BASIC

        if SB_AM.Ranks.HasPermission(LocalPlayer(), categoryPermission) then
            if subCategory.Commands and #subCategory.Commands > 0 then
                local availableCommands = {}
                for _, command in ipairs(subCategory.Commands) do
                    if SB_AM.Ranks.HasPermission(LocalPlayer(), command.Commands) then -- проверка разрешений для каждой команды
                        table.insert(availableCommands, command)
                    end
                end

                -- Категории с разрешениями, очень сложная штука.
                if #availableCommands > 0 then
                    local categoryButton = vgui.Create("DButton", parent)
                    categoryButton:SetPos(xOffset, yOffset)
                    categoryButton:SetSize(categoryWidth, categoryHeight)
                    categoryButton:SetText(subCategory.Name)
                    categoryButton:SetTextColor(Color(255, 255, 255))
                    categoryButton:SetFont("SB_AM_ButtonFont")
                    categoryButton:SetContentAlignment(5)
                    
                    categoryButton.Paint = function(self, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 255))
                        draw.RoundedBox(0, 0, h - 2, w, 2, Color(255, 255, 255))
                    end
                    
                    local commandScroll = vgui.Create("DScrollPanel", parent)
                    commandScroll:SetPos(xOffset, yOffset + categoryHeight)
                    commandScroll:SetSize(categoryWidth, 0)
                    commandScroll:SetVisible(false)

                    local sbar = commandScroll:GetVBar()
                    sbar:SetWide(6) -- Make scrollbar thinner
                    sbar:SetHideButtons(true)
                    
                    function sbar:Paint(w, h)
                        draw.RoundedBox(5, 0, 0, w, h, Color(30, 30, 30, 200))
                    end
                    
                    function sbar.btnGrip:Paint(w, h)
                        local gripColor = self:IsHovered() and Color(120, 120, 120, 200) or Color(70, 70, 70, 200)
                        draw.RoundedBox(5, 0, 0, w, h, gripColor)
                    end
                    
                    local commandList = vgui.Create("DListLayout", commandScroll)
                    commandList:Dock(FILL)
                    
                    for _, command in ipairs(availableCommands) do
                        local cmdButton = CreateStyledButton(commandList, 0, 0, categoryWidth, commandHeight, command.Name, function(cmd)
                            selectedCommand = cmd
                        end)
                    end
                    
                    categoryButton.isExpanded = false
                    categoryButton.commandScroll = commandScroll
                    
                    categoryButton.DoClick = function()
                        categoryButton.isExpanded = not categoryButton.isExpanded
                        commandScroll:SetVisible(categoryButton.isExpanded)
                        
                        local totalHeight = categoryHeight
                        if categoryButton.isExpanded then
                            local commandCount = #availableCommands
                            local scrollHeight = math.min(commandCount, maxCommandsVisible) * (commandHeight + commandSpacing)
                            commandScroll:SetSize(categoryWidth, scrollHeight)
                            totalHeight = totalHeight + scrollHeight
                        end
                        
                        local currentY = 10 -- Начальная позиция Y
                        for _, cat in ipairs(categories) do
                            cat:SetPos(xOffset, currentY)
                            currentY = currentY + categoryHeight
                            
                            if cat.isExpanded then
                                cat.commandScroll:SetPos(xOffset, currentY)
                                currentY = currentY + cat.commandScroll:GetTall()
                            end
                            
                            currentY = currentY + categorySpacing
                        end
                        
                        parent:InvalidateLayout(true)
                        
                        SmoothUpdatePositions(categories)
                    end
                    
                    table.insert(categories, categoryButton)
                    categoryButton.originalY = yOffset
                    
                    yOffset = yOffset + categoryHeight + categorySpacing
                end
            else
                SB_AM.Error("В категории '" .. subCategory.Name .. "' нет команд")
            end
        end
    end

    for _, categoryButton in ipairs(categories) do
        categoryButton.Think = function(self)
            if self.targetY and self.y ~= self.targetY then
                self.y = Lerp(FrameTime() * 10, self.y, self.targetY)
                self:SetPos(self.x, self.y)
            end
        end
    end
    
    SmoothUpdatePositions(categories)
end

function GetSelectedCommand()
    return selectedCommand
end

function SmoothUpdatePositions(categories)
    local targetY = 10
    for _, cat in ipairs(categories) do
        cat.targetY = targetY
        targetY = targetY + cat:GetTall() + 5 -- 5 это categorySpacing

        if cat.isExpanded then
            targetY = targetY + cat.commandScroll:GetTall()
        end
    end

    for _, cat in ipairs(categories) do
        if not cat.Think then
            cat.Think = function(self)
                if self.targetY and self.y ~= self.targetY then
                    self.y = Lerp(FrameTime() * 10, self.y, self.targetY)
                    self:SetPos(self.x, self.y)
                    
                    if self.isExpanded then
                        self.commandScroll:SetPos(self.x, self.y + self:GetTall())
                    end
                end
            end
        end
    end
end

function FormatDescription(text, charsPerLine)
    if not text then return "" end
    
    local words = string.Explode(" ", text)
    local lines = {}
    local currentLine = ""
    
    for _, word in ipairs(words) do
        if #currentLine + #word + 1 <= charsPerLine then
            currentLine = currentLine .. (currentLine == "" and "" or " ") .. word
        else
            table.insert(lines, currentLine)
            currentLine = word
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return table.concat(lines, "\n")
end
