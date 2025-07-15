SB_AM = SB_AM or {}
SB_AM.Ranks = SB_AM.Ranks or {}

-- Таблица разрешений
SB_AM.Permissions = {
    BAN = "ban",
    UNBAN = "unban",
    JAIL = "jail",
    UNJAIL = "unjail",
    KICK = "kick",
    KILL = "kill",
    MUTE = "mute",
    UNMUTE = "unmute",
    VOTE = "vote",
    ADDGROUP = "addgroup",
    GOTO = "goto",
    BRING = "bring",
    RETURNTO = "returnto",
    HELP = "help",
    PVP = "pvp",
    BUILD = "build",
    NOCLIP = "noclip",
    PSA = "psa",
    BASIC = "basic",
    FUN = "fun",
    PHYSGUN = "physgun",
    ADMIN_CONSOLE = "admin_console", -- Админ консоль из файла sh_func.lua
}

local function defaultCanTarget(self, target)
    return false
end

SB_AM.Ranks.List = {
    user = {
        name = "Игрок",
        immunity = 0,
        permissions = {
            SB_AM.Permissions.BASIC,
            SB_AM.Permissions.HELP,
            SB_AM.Permissions.PVP,
            SB_AM.Permissions.BUILD,
        },
        color = Color(241, 196, 15),
        canTarget = defaultCanTarget,
    },
    suser = {
        name = "Супер Игрок",
        immunity = 10,
        permissions = {
            SB_AM.Permissions.BASIC,
            SB_AM.Permissions.FUN,
            SB_AM.Permissions.KICK,
            SB_AM.Permissions.MUTE,
            SB_AM.Permissions.UNMUTE,
            SB_AM.Permissions.GOTO,
            SB_AM.Permissions.BRING,
            SB_AM.Permissions.RETURNTO,
            SB_AM.Permissions.HELP,
            SB_AM.Permissions.PVP,
        },
        color = Color(41, 128, 185),
        canTarget = defaultCanTarget,
    },
    -- Добавьте остальные ранги по аналогии...
}
