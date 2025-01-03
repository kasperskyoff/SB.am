local selectedPlayer = nil

local function CreatePlayerList(parent)
    local playerScroll = vgui.Create("DScrollPanel", parent)
    playerScroll:SetPos(256, 80)
    playerScroll:SetSize(210, 270)
    playerScroll:SetVisible(false)

    local sbar = playerScroll:GetVBar()
    sbar:SetWide(5)
    sbar:SetHideButtons(true)
    sbar.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 200))
    end
    sbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 100)) 
    end

    function playerScroll:ToggleVisibility()
        self:SetVisible(not self:IsVisible())
    end

    local listLayout = vgui.Create("DListLayout", playerScroll)
    listLayout:Dock(FILL)
    listLayout:DockMargin(0, 0, 0, 0)

    local header = vgui.Create("DPanel", listLayout)
    header:SetSize(230, 25)
    header.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 255))
        draw.RoundedBox(0, 0, h - 2, w, 2, Color(255, 255, 255))
        draw.SimpleText("Игроки", "SB_AM_ButtonFont", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local function CreatePlayerButton(ply)
        if not IsValid(listLayout) then return end
        
        local button = vgui.Create("DButton", listLayout)
        button:SetSize(230, 22)
        button:SetText("")
        
        button.Paint = function(self, w, h)
            if not IsValid(ply) then return end
            
            local bgColor = self:IsHovered() and Color(60, 60, 60, 255) or Color(30, 30, 30, 255)
            if selectedPlayer == ply then
                bgColor = Color(80, 80, 80, 255)
            end
            
            draw.RoundedBox(3, 0, 0, w, h, bgColor)
            
            local name = IsValid(ply) and ply:Nick() or "Unknown"
            draw.SimpleText(name, "SB_AM_ButtonFont", 10, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        button.DoClick = function()
            if IsValid(ply) then
                if selectedPlayer == ply then
                    selectedPlayer = nil
                    ply.selected = false
                else
                    for _, p in ipairs(player.GetAll()) do
                        p.selected = false
                    end
                    ply.selected = true
                    selectedPlayer = ply
                end
            end
        end

        return button
    end

    local function UpdatePlayerList()
        if not IsValid(listLayout) then 
            timer.Remove("SB_AM_UpdatePlayerList")
            return
        end

        for k, v in pairs(listLayout:GetChildren()) do
            if k > 1 then
                if IsValid(v) then
                    v:Remove()
                end
            end
        end

        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                CreatePlayerButton(ply)
            end
        end
    end

    UpdatePlayerList()

    timer.Create("SB_AM_UpdatePlayerList", 1, 0, UpdatePlayerList)

    playerScroll.OnRemove = function()
        timer.Remove("SB_AM_UpdatePlayerList")
    end

    return playerScroll
end

SB_AM.CreatePlayerList = CreatePlayerList

function SB_AM.GetSelectedPlayer()
    if selectedPlayer and IsValid(selectedPlayer) and selectedPlayer.selected then
        return selectedPlayer
    end
    return nil
end