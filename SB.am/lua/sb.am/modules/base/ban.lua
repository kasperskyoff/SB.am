SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

if SERVER then    
    util.AddNetworkString("BanHUD")
    util.AddNetworkString("UnbanPlayer")
    util.AddNetworkString("SB_AM_AddLog")
end

hook.Add("SetupMove", "SB_AM_BanMove", function(ply, mv)
    if ply.isBanned then
        local aim = ply:GetAimVector()
        
        local speed = Vector(0, 0, 0)
        local moveSpeed = 200
        
        if mv:KeyDown(IN_FORWARD) then
            speed = speed + aim * moveSpeed
        end
        if mv:KeyDown(IN_BACK) then
            speed = speed - aim * moveSpeed
        end
        if mv:KeyDown(IN_MOVELEFT) then
            speed = speed - ply:GetRight() * moveSpeed
        end
        if mv:KeyDown(IN_MOVERIGHT) then
            speed = speed + ply:GetRight() * moveSpeed
        end

        local nextPos = ply:GetPos() + speed * FrameTime()
        local tr = util.TraceLine({
            start = ply:GetPos() + Vector(0, 0, 36),
            endpos = nextPos + Vector(0, 0, 36),
            filter = ply,
            mask = MASK_SOLID
        })
        
        if tr.Hit then
            local dot = speed:Dot(tr.HitNormal)
            if dot < 0 then
                speed = speed - tr.HitNormal * dot
            end
        end
        
        local hull = util.TraceHull({
            start = nextPos,
            endpos = nextPos,
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            filter = ply,
            mask = MASK_SOLID
        })
        
        if hull.StartSolid then
            speed = Vector(0, 0, 0)
        end

        mv:SetButtons(0)
        mv:SetVelocity(speed)

        return true
    end
end)

hook.Add("PlayerBindPress", "SB_AM_BanBinds", function(ply, bind, pressed)
    if ply.isBanned then
        if string.find(bind, "+attack") or 
           string.find(bind, "+attack2") or 
           string.find(bind, "+use") or
           string.find(bind, "+noclip") or
           string.find(bind, "+walk") or
           string.find(bind, "+jump") or
           string.find(bind, "+duck") then
            return false
        end
    end
end)

hook.Add("CanTool", "SB_AM_BanTool", function(ply, _, _)
    if ply.isBanned then
        return false
    end
end)

hook.Add("PlayerSpawn", "SB_AM_BanRespawn", function(ply)
    if ply.isBanned then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                ply:StripWeapons()
                ply:SetModel("models/pigeon.mdl")
                ply:SetMoveType(MOVETYPE_NOCLIP)
                ply:SetGravity(0)
                ply:SetWalkSpeed(200)
                ply:SetRunSpeed(200)
                
                ply:SetRenderMode(RENDERMODE_TRANSALPHA)
                ply:SetColor(Color(255, 255, 255, 150))
                ply:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
            end
        end)
    end
end)

hook.Add("PlayerCanPickupWeapon", "SB_AM_BanPickup", function(ply, weapon)
    if ply.isBanned then
        return false
    end
end)

local function BlockSpawn(ply)
    if ply.isBanned then
        return false
    end
end

hook.Add("PlayerSpawnProp", "SB_AM_BanProps", BlockSpawn)
hook.Add("PlayerSpawnNPC", "SB_AM_BanNPCs", BlockSpawn)
hook.Add("PlayerSpawnVehicle", "SB_AM_BanVehicles", BlockSpawn)
hook.Add("PlayerSpawnSENT", "SB_AM_BanSENT", BlockSpawn)
hook.Add("PlayerSpawnSWEP", "SB_AM_BanSWEP", BlockSpawn)

local function BanPlayer(steamid, reason, admin, unbanTime, playerName)
    sql.Query(string.format([[
        REPLACE INTO sb_am_bans (steamid, reason, admin, unban_time, player_name) 
        VALUES (%s, %s, %s, %d, %s)
    ]], 
    sql.SQLStr(steamid),
    sql.SQLStr(reason),
    sql.SQLStr(admin),
    unbanTime,
    sql.SQLStr(playerName)))
end

local function UnbanPlayer(steamid)
    sql.Query(string.format([[
        DELETE FROM sb_am_bans 
        WHERE steamid = %s
    ]], sql.SQLStr(steamid)))
    
    local ply = player.GetBySteamID(steamid)
    if IsValid(ply) then
        ply:SetRenderMode(RENDERMODE_NORMAL)
        ply:SetColor(Color(255, 255, 255, 255))
        ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
    end
end

local function GetBanData(steamid)
    local result = sql.Query(string.format([[
        SELECT * FROM sb_am_bans 
        WHERE steamid = %s
    ]], sql.SQLStr(steamid)))
    
    return result and result[1] or nil
end

hook.Add("PlayerInitialSpawn", "SB_AM_CheckBan", function(ply)
    local steamid = ply:SteamID()
    local banData = GetBanData(steamid)
    
    if banData then
        local currentTime = os.time()
        if tonumber(banData.unban_time) > 0 and currentTime >= tonumber(banData.unban_time) then
            UnbanPlayer(steamid)
            ply.isBanned = false
            return
        end
       
        ply.isBanned = true
        ply.unbanTime = tonumber(banData.unban_time)
        
        timer.Simple(0.1, function()
            if IsValid(ply) then
                ply:StripWeapons()
                ply:SetModel("models/pigeon.mdl")
                ply:SetMoveType(MOVETYPE_NOCLIP)
                ply:SetGravity(0)
                ply:SetWalkSpeed(200)
                ply:SetRunSpeed(200)
                
                net.Start("BanHUD")
                net.WriteString(banData.reason)
                net.WriteInt(tonumber(banData.unban_time) > 0 and (tonumber(banData.unban_time) - currentTime) or 0, 32)
                net.Send(ply)
            end
        end)
    end
end)

timer.Create("CheckBans", 60, 0, function()
    local currentTime = os.time()
    local expiredBans = sql.Query(string.format([[
        SELECT steamid FROM sb_am_bans 
        WHERE unban_time > 0 AND unban_time <= %d
    ]], currentTime))
    
    if expiredBans then
        for _, data in ipairs(expiredBans) do
            UnbanPlayer(data.steamid)
            
            local ply = player.GetBySteamID(data.steamid)
            if IsValid(ply) then
                ply.isBanned = false
                ply:SetModel("models/player/group01/male_01.mdl")
                ply:SetMoveType(MOVETYPE_WALK)
                ply:SetGravity(1)
                ply:SetWalkSpeed(400)
                ply:SetRunSpeed(600)
                
                ply:Spawn()
                
                net.Start("UnbanPlayer")
                net.Send(ply)
                
                SB_AM.Log("Игрок " .. ply:Nick() .. " был разбанен (истек срок бана)")
            end
        end
    end
end)

hook.Add("CheckPassword", "SB_AM_CheckBanConnection", function(steamID64, ipAddress)
    local steamID = util.SteamIDFrom64(steamID64)
    local banData = GetBanData(steamID)
    
    if banData then
        local currentTime = os.time()
        local reason = banData.reason:Trim() ~= "" and banData.reason or "Без причины"
        local playerName = banData.player_name or "Unknown"
        
        if tonumber(banData.unban_time) == 0 then
            SB_AM.Log(playerName .. " (" .. steamID .. ") попытался зайти на сервер но у него блокировка по причине: " .. reason, "info", nil, true)
            
            return false, [[Солнечный Sandbox

Вы забанены навсегда
Причина: ]] .. reason .. [[

Админом: ]] .. banData.admin .. [[

Подать апелляцию можно в нашем Discord: discord.gg/3cbDEDRnWC
Так же у нас есть сайт: http://178.141.253.17/]]
        end

        if tonumber(banData.unban_time) > 0 and currentTime >= tonumber(banData.unban_time) then
            UnbanPlayer(steamID)
            return true
        end
    end
end)

hook.Add("ShouldCollide", "SB_AM_BanCollide", function(ent1, ent2)
    if IsValid(ent1) and IsValid(ent2) and ent1:IsPlayer() and ent2:IsPlayer() then
        if ent1.isBanned or ent2.isBanned then
            return false
        end
    end
end)

SB_AM.Commands.ban = {
    Description = "Банит игрока.",
    ShowPlayerList = true,
    Arguments = {
        {name = "Время (например: 10m)", required = true},
        {name = "Причина", required = true},
        {name = "SteamID", required = false},
    },
    Callback = function(ply, args)
        args = args or {}
        
        local adminName = "Console"
        if IsValid(ply) and ply:IsPlayer() then
            if not SB_AM.Ranks.HasPermission(ply, "ban") then
                SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
                return
            end
            adminName = ply:Nick()
        end

        if not args[1] then
            SB_AM.Log("Укажите игрока", "error", ply)
            return
        end

        if not args[2] then
            SB_AM.Log("Укажите время бана (1m, 0m - навсегда)", "error", ply)
            return
        end

        local target = nil
        local targetSteamID = nil
        local targetNick = nil

        local potentialSteamID = args[1]
        if string.match(args[1], "^STEAM_") then
            local parts = {args[1]}
            local idx = 2
            while args[idx] and not string.match(args[idx], "^%d+[mhdwMy]$") do
                table.insert(parts, args[idx])
                idx = idx + 1
            end
            potentialSteamID = table.concat(parts, "")
            
            local newArgs = {potentialSteamID}
            for i = idx, #args do
                table.insert(newArgs, args[i])
            end
            for i = 1, #newArgs do
                args[i] = newArgs[i]
            end
            for i = #newArgs + 1, #args do
                args[i] = nil
            end
        end

        local cleanInput = string.gsub(potentialSteamID, "%s+", "")
        
        local isMatch = string.match(cleanInput, "STEAM_%d+:%d+:%d+")
        
        if isMatch then
            targetSteamID = cleanInput
            target = SB_AM.FindPlayer(targetSteamID)
            if target then
                targetNick = target:Nick()
            else
                targetNick = "ОФФЛАЙН"
            end
        else
            target = SB_AM.FindPlayer(args[1])
            if target then
                targetSteamID = target:SteamID()
                targetNick = target:Nick()
            end
        end

        if not targetSteamID then
            SB_AM.Log("Игрок не найден. Используйте ник или SteamID (например: STEAM_0:1:123456)", "info", ply)
            return
        end

        local banTime = args[2]
        local duration = 0
        local timeUnit = string.sub(banTime, -1)
        local timeValue = tonumber(string.sub(banTime, 1, -2))

        if not timeValue then
            SB_AM.Log("Неверный формат времени", "error", ply)
            return
        end

        if timeUnit == "m" then
            duration = timeValue * 60
        elseif timeUnit == "h" then
            duration = timeValue * 3600
        elseif timeUnit == "d" then
            duration = timeValue * 86400
        elseif timeUnit == "w" then
            duration = timeValue * 604800
        elseif timeUnit == "M" then
            duration = timeValue * 2592000
        elseif timeUnit == "y" then
            duration = timeValue * 31536000
        else
            SB_AM.Log("Неверный формат времени (используйте: m-минуты, h-часы, d-дни, w-недели, M-месяцы, y-годы, 0m-перманентный)", "error", ply)
            return
        end

        local reason = args[3] and table.concat(args, " ", 3) or "Без причины"
        local unbanTime = duration > 0 and os.time() + duration or 0
        
        -- Ban the player
        BanPlayer(targetSteamID, reason, IsValid(ply) and ply:Nick() or "Console", unbanTime, targetNick)
        
        if IsValid(target) then
            if duration == 0 then
                target:Kick("Вы забанены навсегда на сервере Солнечный Sandbox\nПричина: " .. reason .. "\nАдмином: " .. adminName)
                SB_AM.Log(adminName .. " забанил игрока " .. target:Nick() .. " (" .. target:SteamID() .. ") навсегда по причине: " .. reason, "info")
                return
            end
            
            target.isBanned = true
            target.unbanTime = unbanTime
            
            target:StripWeapons()
            target:SetModel("models/pigeon.mdl")
            target:SetMoveType(MOVETYPE_NOCLIP)
            target:SetGravity(0)
            target:SetWalkSpeed(200)
            target:SetRunSpeed(200)
            
            net.Start("BanHUD")
            net.WriteString(reason)
            net.WriteInt(duration, 32)
            net.Send(target)
        end

        -- Исправляем синтаксис тернарного оператора
        local banDurationText = duration > 0 and (" на " .. banTime) or " навсегда"
        SB_AM.Log(adminName .. " забанил игрока " .. targetNick .. " (" .. targetSteamID .. ")" .. banDurationText .. " по причине: " .. reason, "info")
    end
}

return SB_AM.Commands.ban