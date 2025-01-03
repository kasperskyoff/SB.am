function CreateArgumentInput(parent)
    local argumentsPanel = vgui.Create("DPanel", parent)
    argumentsPanel:SetPos(857, 180)
    argumentsPanel:SetSize(230, 360)
    argumentsPanel:SetVisible(false)
    
    argumentsPanel.Paint = function(self, w, h)
        -- Фон мы уже сделали в основном меню
    end

    local inputs = {}
    
    function argumentsPanel:SetupArguments(command)
        self:Clear()
        inputs = {}
        
        if not SB_AM.Commands[command] or not SB_AM.Commands[command].Arguments then
            self:SetVisible(false)
            return
        end
        
        local yPos = 10
        for i, arg in ipairs(SB_AM.Commands[command].Arguments) do
            local container = vgui.Create("DPanel", self)
            container:SetPos(10, yPos)
            container:SetSize(210, 65)
            container.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(20, 20, 20, 250))
            end

            local headerPanel = vgui.Create("DPanel", container)
            headerPanel:SetPos(8, 5)
            headerPanel:SetSize(194, 20)
            headerPanel.Paint = function(self, w, h)
                draw.SimpleText(arg.name, "DermaDefault", 0, h/2, 
                    Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                if arg.required then
                    draw.SimpleText("*", "DermaDefault", w - 5, h/2, 
                        Color(255, 50, 50), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
            
            local input = vgui.Create("DTextEntry", container)
            input:SetPos(8, 28)
            input:SetSize(194, 30)
            input:SetText("")
            input.arg = arg

            input.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(45, 45, 45, 255))
                
                if self:HasFocus() then
                    surface.SetDrawColor(255, 164, 3, 100)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                else
                    surface.SetDrawColor(60, 60, 60, 250)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                end

                self:DrawTextEntryText(
                    Color(255, 255, 255),  -- Цвет текста
                    Color(255, 164, 3),    -- Цвет выделения  
                    Color(255, 255, 255)   -- Цвет курсора
                )
                
                -- Плейсхолдер
                if self:GetText() == "" then
                    draw.SimpleText("Введите " .. string.lower(self.arg.name), "DermaDefault", 5, h/2, 
                        Color(150, 150, 150, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end
            
            table.insert(inputs, input)
            yPos = yPos + 75
        end
        
        local hint = vgui.Create("DLabel", self)
        hint:SetPos(25, 340)
        hint:SetSize(210, 20)
        hint:SetText("* - обязательное поле")
        hint:SetTextColor(Color(150, 150, 150))
        hint:SetFont("SB_AM_ButtonFont")
        
        self:SetVisible(true)
    end
    
    function argumentsPanel:GetArguments()
        local args = {}
        for _, input in ipairs(inputs) do
            table.insert(args, input:GetValue())
        end
        return args
    end
    
    return argumentsPanel
end 