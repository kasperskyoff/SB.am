net.Receive("BanHUD", function()
    local reason = net.ReadString()
    local banDuration = net.ReadInt(32)
    local endTime = CurTime() + banDuration

    if hook.GetTable()["HUDPaint"] and hook.GetTable()["HUDPaint"]["BanText"] then
        hook.Remove("HUDPaint", "BanText")
    end
    
    hook.Add("HUDPaint", "BanText", function()
        -- Если время бана истекло, удаляем HUD
        if banDuration > 0 and CurTime() >= endTime then
            hook.Remove("HUDPaint", "BanText")
            return
        end

        surface.SetFont("DermaLarge")
        local text1 = "Опа, а вот и бан!"
        local text2 = "Вы были забанены на сервере"
        local text3 = "по причине: " .. reason
        local text5 = "☀"

        local timeLeft = math.max(0, math.floor(endTime - CurTime()))
        local text4
        
        if banDuration > 0 then
            if timeLeft >= 31536000 then -- год
                text4 = "Осталось времени: " .. math.floor(timeLeft / 31536000) .. " г."
            elseif timeLeft >= 2592000 then -- месяц
                text4 = "Осталось времени: " .. math.floor(timeLeft / 2592000) .. " мес."
            elseif timeLeft >= 604800 then -- неделя
                text4 = "Осталось времени: " .. math.floor(timeLeft / 604800) .. " нед."
            elseif timeLeft >= 86400 then -- день
                text4 = "Осталось времени: " .. math.floor(timeLeft / 86400) .. " дн."
            elseif timeLeft >= 3600 then -- час
                text4 = "Осталось времени: " .. math.floor(timeLeft / 3600) .. " ч."
            elseif timeLeft >= 60 then -- минута
                text4 = "Осталось времени: " .. math.floor(timeLeft / 60) .. " мин."
            else
                text4 = "Осталось времени: " .. timeLeft .. " сек."
            end
        else
            text4 = "Бан навсегда"
        end

        local width1, height1 = surface.GetTextSize(text1)
        local width2, height2 = surface.GetTextSize(text2)
        local width3, height3 = surface.GetTextSize(text3)
        local width4, height4 = surface.GetTextSize(text4)
        local width5, height5 = surface.GetTextSize(text5)

        local maxWidth = math.max(width1, width2, width3, width4)
        local totalHeight = height1 + height2 + height3 + height4 + 40
        
        local padding = 25
        local boxX = ScrW()/2 - (maxWidth + padding*2)/2
        local boxY = 40
        draw.RoundedBox(20, boxX, boxY, maxWidth + padding*2, totalHeight + padding*2, Color(20, 20, 20, 240))
        
        local function DrawTextWithOutline(text, x, y)
            surface.SetTextColor(0, 0, 0, 255)
            
            surface.SetTextPos(x - 1, y - 1)
            surface.DrawText(text)
            surface.SetTextPos(x + 1, y - 1)
            surface.DrawText(text)
            surface.SetTextPos(x - 1, y + 1)
            surface.DrawText(text)
            surface.SetTextPos(x + 1, y + 1)
            surface.DrawText(text)
            
            surface.SetTextColor(255, 255, 255, 255)
            surface.SetTextPos(x, y)
            surface.DrawText(text)
        end
        
        local function DrawTextSun(text, x, y)
            surface.SetTextColor(255, 163, 3, 255)
            surface.SetTextPos(x, y)
            surface.DrawText(text)
        end
        
        DrawTextSun(text5, ScrW()/2- width4/19, boxY + 7)
        DrawTextWithOutline(text1, ScrW()/2 - width1/2, boxY/3 + padding + height1)
        DrawTextWithOutline(text2, ScrW()/2 - width2/2, boxY/3 + padding + height1 + height2 + 5)
        DrawTextWithOutline(text3, ScrW()/2 - width3/2, boxY/3 + padding + height1 + height2 + height3 + 7)
        DrawTextWithOutline(text4, ScrW()/2 - width4/2, boxY/3 + padding + height1 + height2 + height3 + height4 + 10)
    end)
end)

-- Добавляем обработчик разбана
net.Receive("UnbanPlayer", function()
    if hook.GetTable()["HUDPaint"] and hook.GetTable()["HUDPaint"]["BanText"] then
        hook.Remove("HUDPaint", "BanText")
    end
end)
