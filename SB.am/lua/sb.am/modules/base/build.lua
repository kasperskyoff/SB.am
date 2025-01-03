SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

local hook = hook
local timer = timer
local IsValid = IsValid
local BUILDER_SWITCH_DELAY = 5
local BUILDER_MOVE_TYPE = MOVETYPE_NOCLIP

function SB_AM.IsPlayerBuilder(ply)
    if not IsValid(ply) then return false end
    return ply.isBuilder == true
end

function SB_AM.SetBuilderMode(ply, enabled)
    if not IsValid(ply) then return end
    
    if ply.isBuilder == enabled then return end
    
    ply.isBuilder = enabled
    ply.inPvP = not enabled
    -- ply:SetMoveType(enabled and BUILDER_MOVE_TYPE or MOVETYPE_WALK) -- Можно убрать, если не хотите, чтоб при заходе в билд вы сразу же летали.

    net.Start("UpdatePlayerMode")
    net.WriteEntity(ply)
    net.WriteBool(enabled)
    net.Broadcast()

    hook.Run("SB_AM_BuilderModeChanged", ply, enabled)
    
    SB_AM.Log(ply:Nick() .. " (" .. ply:SteamID() .. ") " .. 
        (enabled and "перешел в режим строительства" or "вышел из режима строительства"), 
        "info")
end

hook.Add("PlayerNoClip", "SB_AM_Build_NoClip", function(ply, desiredState)
    return SB_AM.IsPlayerBuilder(ply)
end)

hook.Add("EntityTakeDamage", "SB_AM_Build_Damage", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    
    if IsValid(target) and target:IsPlayer() and SB_AM.IsPlayerBuilder(target) then
        return true
    end
    
    if IsValid(attacker) and attacker:IsPlayer() and SB_AM.IsPlayerBuilder(attacker) then
        return true
    end
end)

SB_AM.Commands.build = {
    Description = "Включить режим Build.",
    Callback = function(ply, args)
        if not IsValid(ply) then return end
        
        if ply.isBanned then
            SB_AM.Log("Вы не можете войти в режим строительства, так как забанены", "error", ply)
            return
        end

        if ply.isBuilder then
            SB_AM.Log("Вы уже находитесь в режиме строительства", "error", ply)
            return
        end

        if ply.inPvP then
            SB_AM.Log("Вы перейдете в режим строительства через " .. BUILDER_SWITCH_DELAY .. " секунд...", "info", ply)
            
            local timerName = "BuildMode_" .. ply:SteamID64()
            timer.Create(timerName, BUILDER_SWITCH_DELAY, 1, function()
                if IsValid(ply) then
                    SB_AM.SetBuilderMode(ply, true)
                end
            end)
        else
            SB_AM.SetBuilderMode(ply, true)
        end
    end
}
