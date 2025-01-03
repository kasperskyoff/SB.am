SB_AM = SB_AM or {}
SB_AM.Logs = SB_AM.Logs or {}

-- Это для логов лучше не трогать а то может сломаться что-то. И тем более для клиента в меню.

function SB_AM.Logs.CreateLogsList(parent)
    local logPanel = vgui.Create("DPanel", parent)
    logPanel:SetPos(490, 80)
    logPanel:SetSize(353, 520)
    
    logPanel.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 200))
    end

    local scrollPanel = vgui.Create("DScrollPanel", logPanel)
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(0, 0, 0, 12)
    
    local vbar = scrollPanel:GetVBar()
    vbar:SetWide(6)
    vbar:SetHideButtons(true)
    
    function vbar:Paint(w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(30, 30, 30, 200))
    end
    
    function vbar.btnGrip:Paint(w, h)
        local gripColor = self:IsHovered() and Color(120, 120, 120, 200) or Color(70, 70, 70, 200)
        draw.RoundedBox(5, 0, 0, w, h, gripColor)
    end

    local hbar = vgui.Create("DHScrollBar", logPanel)
    hbar:SetPos(0, logPanel:GetTall() - 10)
    hbar:SetSize(logPanel:GetWide() - 6, 6)
    hbar:SetHideButtons(true)

    function hbar:Paint(w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(30, 30, 30, 200))
    end
    
    function hbar.btnGrip:Paint(w, h)
        local gripColor = self:IsHovered() and Color(120, 120, 120, 200) or Color(70, 70, 70, 200)
        draw.RoundedBox(5, 0, 0, w, h, gripColor)
    end

    hbar:SetUp(logPanel:GetWide(), 1000)

    local function UpdateLogs()
        scrollPanel:Clear()
        
        if not SB_AM.Logs or #SB_AM.Logs == 0 then
            local emptyText1 = vgui.Create("DLabel", scrollPanel)
            emptyText1:SetPos(165, 3)
            emptyText1:SetWide(353)
            emptyText1:SetText("☀")
            emptyText1:SetTextColor(Color(255, 163, 3))
            emptyText1:SetFont("SB_AM_ButtonFont")

            local emptyText2 = vgui.Create("DLabel", scrollPanel)
            emptyText2:SetPos(110, 20)
            emptyText2:SetWide(353)
            emptyText2:SetText("Пока что тут пусто")
            emptyText2:SetTextColor(Color(200, 200, 200))
            emptyText2:SetFont("SB_AM_ButtonFont")

            local emptyText3 = vgui.Create("DLabel", scrollPanel)
            emptyText3:SetPos(25, 40)
            emptyText3:SetWide(353)
            emptyText3:SetText("Давайте мы с вами заполним эту пустоту!")
            emptyText3:SetTextColor(Color(200, 200, 200))
            emptyText3:SetFont("SB_AM_ButtonFont")
        else
            for i = 1, #SB_AM.Logs do
                local log = SB_AM.Logs[i]
                local logEntry = vgui.Create("DPanel", scrollPanel)
                logEntry:Dock(TOP)
                logEntry:SetTall(25)
                logEntry:DockMargin(0, 0, 0, 2)
                
                logEntry.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
                    local x = -hbar:GetScroll()
                    
                    -- Выбираем цвет и префикс в зависимости от типа лога
                    local prefixColor = Color(255, 164, 3) -- Стандартный цвет для info
                    local prefix = "[SB.am]:"
                    
                    if log.logType == "error" then
                        prefixColor = Color(255, 0, 0)
                        prefix = "[SB.am ERROR]:"
                    end
                    
                    draw.SimpleText(log.time, "DermaDefault", x + 5, h/2, Color(11, 253, 213), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(prefix, "DermaDefault", x + 62, h/2, prefixColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(log.message, "DermaDefault", x + 108, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end
        end
    end

    local function UpdateScrollWidth()
        local maxWidth = 0
        for _, log in ipairs(SB_AM.Logs) do
            local timeWidth = surface.GetTextSize(log.time)
            local prefixWidth = surface.GetTextSize("[SB.am]:")
            local messageWidth = surface.GetTextSize(log.message)
            local totalWidth = 108 + messageWidth + 50
            maxWidth = math.max(maxWidth, totalWidth)
        end
        
        hbar:SetUp(logPanel:GetWide(), maxWidth)
    end

    hbar.OnScroll = function(self, scroll)
        scrollPanel:InvalidateLayout(true)
        UpdateLogs()
    end

    logPanel.PerformLayout = function(self)
        hbar:SetPos(0, self:GetTall() - 10)
        hbar:SetSize(self:GetWide() - 6, 6)
        UpdateScrollWidth()
    end

    local function UpdateAll()
        UpdateLogs()
        UpdateScrollWidth()
    end

    hook.Add("SB_AM_LogAdded", "UpdateLogsInMenu", function()
        if not IsValid(SB_AM.LogPanel) then return end
        
        if SB_AM.LogPanel.UpdateLogs then
            UpdateAll()
        end
    end)

    logPanel.OnRemove = function()
        if timer.Exists("SB_AM_UpdateLogs") then
            timer.Remove("SB_AM_UpdateLogs")
        end
    end

    UpdateAll()

    logPanel.UpdateLogs = UpdateLogs
    return logPanel
end
