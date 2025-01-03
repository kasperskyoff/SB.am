SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

local hook = hook
local IsValid = IsValid

function SB_AM.SetPvPMode(ply, enabled)
    if not IsValid(ply) then return end
    
    if ply.inPvP == enabled then return end
    
    ply.inPvP = enabled
    ply.isBuilder = not enabled
    ply:SetMoveType(enabled and MOVETYPE_WALK or MOVETYPE_NOCLIP)

    net.Start("UpdatePlayerMode")
    net.WriteEntity(ply)
    net.WriteBool(not enabled)
    net.Broadcast()

    if enabled then
        if math.random() < 0.5 then
            local spawnPoints = ents.FindByClass("info_player_start")
            if #spawnPoints > 0 then
                local spawnPoint = spawnPoints[math.random(#spawnPoints)]
                ply:SetPos(spawnPoint:GetPos())
                ply:SetAngles(spawnPoint:GetAngles())
                ply:Spawn()
            end
        end
    end

    hook.Run("SB_AM_PvPModeChanged", ply, enabled)
    
    SB_AM.Log(ply:Nick() .. " (" .. ply:SteamID() .. ") " ..
        (enabled and "перешел в режим PvP" or "вышел из режима PvP"),
        "info")
end

hook.Add("PlayerSpawn", "SB_AM_PvP_PlayerSpawn", function(ply)
    if not IsValid(ply) then return end
    
    ply:SetTeam(1)
    ply:SetNoCollideWithTeammates(false)
    
    if ply.inPvP then
        SB_AM.SetPvPMode(ply, true)
    elseif ply.isBuilder then
        SB_AM.SetBuilderMode(ply, true)
    end
end)

hook.Add("EntityTakeDamage", "SB_AM_PvP_Damage", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    
    if IsValid(attacker) and attacker:IsPlayer() and IsValid(target) and target:IsPlayer() then
        if SB_AM.IsPlayerBuilder(attacker) or SB_AM.IsPlayerBuilder(target) then
            return true
        end
    end
end)

SB_AM.Commands.pvp = {
    Description = "Включить режим PvP.",
    Callback = function(ply, args)
        if not IsValid(ply) then return end
        
        if ply.isBanned then
            SB_AM.Log("Вы не можете войти в режим PvP, так как забанены", "error", ply)
            return
        end

        if ply.inPvP then
            SB_AM.Log("Вы уже находитесь в режиме PvP", "error", ply)
            return
        end

        SB_AM.SetPvPMode(ply, true)
    end
}
