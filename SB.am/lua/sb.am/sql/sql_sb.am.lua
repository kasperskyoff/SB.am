SB = SB or {}
SB.AM = SB.AM or {}

local function InitializeDatabase()
    if not sql.TableExists("sb_am_ranks") then
        sql.Query([[
            CREATE TABLE "sb_am_ranks" (
                steamid TEXT PRIMARY KEY,
                rank TEXT NOT NULL,
                name TEXT NOT NULL
            )
        ]])
    end

    if not sql.TableExists("sb_am_bans") then
        sql.Query([[
            CREATE TABLE "sb_am_bans" (
                steamid TEXT PRIMARY KEY,
                player_name TEXT,
                reason TEXT,
                admin TEXT,
                unban_time INTEGER
            )
        ]])
    end
end

InitializeDatabase()

function SB.AM.FolderExists(folderName)
    local result = sql.Query(string.format(
        'SELECT folder_name FROM "sb.am" WHERE folder_name = \'SB.AM/%s\'',
        sql.SQLStr(folderName):sub(2, -2)
    ))
    return result ~= nil and #result > 0
end

function SB.AM.CreateSubfolder(folderName)
    if not SB.AM.FolderExists(folderName) then
        local success = sql.Query(string.format(
            'INSERT INTO "sb.am" (folder_name) VALUES (\'SB.AM/%s\')',
            sql.SQLStr(folderName):sub(2, -2)
        ))
        return success ~= false
    end
    return false
end
