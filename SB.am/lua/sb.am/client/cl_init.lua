net.Receive("SB_AM_ConsoleMessage", function()
    local timeColor = net.ReadColor()
    local timeStr = net.ReadString()
    local prefixColor = net.ReadColor()
    local prefix = net.ReadString()
    local textColor = net.ReadColor()
    local text = net.ReadString()
    
    MsgC(timeColor, timeStr, " ",
         prefixColor, prefix,
         textColor, text .. "\n")
end) 