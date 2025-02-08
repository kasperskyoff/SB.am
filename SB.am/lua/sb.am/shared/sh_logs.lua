SB_AM = SB_AM or {}
SB_AM.Logs = SB_AM.Logs or {}

if SERVER then
    util.AddNetworkString("SB_AM_AddLog")
    
    function SB_AM.Logs.AddLog(message, logType)
        local time = "[" .. os.date("%H:%M:%S") .. "]"
        local logEntry = {
            time = time,
            message = message,
            logType = logType or "info"
        }

        if logType == "error" or logType == "info" then
            net.Start("SB_AM_AddLog")
            net.WriteTable(logEntry)
            net.Broadcast()
            
            table.insert(SB_AM.Logs, logEntry)
        end
    end
else
    net.Receive("SB_AM_AddLog", function()
        local logEntry = net.ReadTable()
        table.insert(SB_AM.Logs, logEntry)
        hook.Run("SB_AM_LogAdded")
    end)
end 