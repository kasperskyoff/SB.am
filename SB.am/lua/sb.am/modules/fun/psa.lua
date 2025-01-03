SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

if SERVER then
    util.AddNetworkString("SB_AM_PSA")
end

SB_AM.Commands.psa = {
    Description = "Отправляет всем игрокам уведомление.",
    Arguments = {
        {name = "Сообщение", required = true}
    },
    Callback = function(ply, args)
        if not IsValid(ply) then
            ply = Entity(0)
        end

        if IsValid(ply) and ply:IsPlayer() and not SB_AM.Ranks.HasPermission(ply, "psa") then
            SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
            return
        end

        if not args[1] then
            SB_AM.Log("Укажите сообщение", "error", ply)
            return
        end

        local message = table.concat(args, " ")

        net.Start("SB_AM_PSA")
        net.WriteString(message)
        net.WriteString(SB_AM.GetExecutorName(ply))
        net.Broadcast()

        SB_AM.Log(SB_AM.GetExecutorName(ply) .. " отправил уведомление: " .. message, "info", nil, true)
    end
}

if CLIENT then
    local notifications = {}
    local NOTIFICATION_LIFETIME = 6
    local NOTIFICATION_FADE_TIME = 0.5
    local NOTIFICATION_HEIGHT = 40
    local NOTIFICATION_START_Y = -NOTIFICATION_HEIGHT
    local NOTIFICATION_TARGET_Y = 0
    
    local NOTIFICATION_SOUND = "sunbox/notification_zerahypt.wav" -- Можете поменять звук.

    net.Receive("SB_AM_PSA", function()
        local message = net.ReadString()
        local sender = net.ReadString()
        
        surface.PlaySound(NOTIFICATION_SOUND)
        
        local notification = {
            message = message,
            sender = sender,
            startTime = SysTime(),
            y = NOTIFICATION_START_Y,
            alpha = 0
        }
        
        table.insert(notifications, notification)
    end)

    hook.Add("HUDPaint", "SB_AM_PSA_Draw", function()
        local currentTime = SysTime()
        local screenW = ScrW()
        
        for i = #notifications, 1, -1 do
            local notif = notifications[i]
            local elapsed = currentTime - notif.startTime
            
            if elapsed > NOTIFICATION_LIFETIME + NOTIFICATION_FADE_TIME then
                table.remove(notifications, i)
                continue
            end
            
            if elapsed < NOTIFICATION_FADE_TIME then
                notif.alpha = (elapsed / NOTIFICATION_FADE_TIME) * 255
                notif.y = Lerp(elapsed / NOTIFICATION_FADE_TIME, NOTIFICATION_START_Y, NOTIFICATION_TARGET_Y)
            elseif elapsed > NOTIFICATION_LIFETIME then
                local fadeElapsed = elapsed - NOTIFICATION_LIFETIME
                notif.alpha = 255 - (fadeElapsed / NOTIFICATION_FADE_TIME) * 255
                notif.y = Lerp(fadeElapsed / NOTIFICATION_FADE_TIME, NOTIFICATION_TARGET_Y, NOTIFICATION_START_Y)
            else
                notif.alpha = 255
                notif.y = NOTIFICATION_TARGET_Y
            end
            
            surface.SetDrawColor(40, 40, 40, notif.alpha * 0.8)
            surface.DrawRect(0, notif.y, screenW, NOTIFICATION_HEIGHT)
            
            surface.SetDrawColor(255, 163, 3, notif.alpha)
            surface.DrawRect(0, notif.y + NOTIFICATION_HEIGHT - 2, screenW, 2)
            
            draw.SimpleText(
                notif.message,
                "SB_AM_ButtonFont",
                screenW / 2,
                notif.y + NOTIFICATION_HEIGHT / 2,
                Color(255, 255, 255, notif.alpha),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
            
            draw.SimpleText(
                "От: " .. notif.sender,
                "SB_AM_ButtonFont",
                5,
                notif.y + NOTIFICATION_HEIGHT / 2,
                Color(200, 200, 200, notif.alpha),
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )
        end
    end)
end

return SB_AM.Commands.psa
