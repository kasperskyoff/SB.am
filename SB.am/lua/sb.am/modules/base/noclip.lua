SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

local function EnableNoclip(ply)
    if not IsValid(ply) then return end
    
    ply:SetMoveType(MOVETYPE_NOCLIP)
    ply:SetGravity(0)
    ply.isNoclip = true
end

local function DisableNoclip(ply)
    if not IsValid(ply) then return end
    
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetGravity(1)
    ply.isNoclip = false
end

function SB_AM.ToggleNoclip(ply)
    if not IsValid(ply) then return end
    
    if ply.isNoclip then
        DisableNoclip(ply)
    else
        EnableNoclip(ply)
    end
end

hook.Add("PlayerSpawn", "SB_AM_Noclip_PlayerSpawn", function(ply)
    if not IsValid(ply) then return end
    
    if ply.isNoclip then
        EnableNoclip(ply)
    end
end)

hook.Add("PlayerNoClip", "SB_AM_Noclip_Hook", function(ply, desiredState)
    return ply.isNoclip
end)

SB_AM.Commands.noclip = {
    Description = "Включить/выключить режим полёта.",
    Callback = function(ply, args)
        if not IsValid(ply) then return end

        if not SB_AM.Ranks.HasPermission(ply, "noclip") then
            SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
            return
        end

        SB_AM.ToggleNoclip(ply)
    end
}

return SB_AM.Commands.noclip
