
local SW, SH = ScrW(), ScrH()

surface.CreateFont( "TextVote", {
	font = "CloseCaption_Bold", -- On Windows/macOS, use the font-name which is shown to you by your operating system Font Viewer. On Linux, use the file name
	extended = false,
	size = 15,
	weight = 10500,
	antialias = true,
} )
surface.CreateFont( "TextVote2", {
	font = "CloseCaption_Bold", -- On Windows/macOS, use the font-name which is shown to you by your operating system Font Viewer. On Linux, use the file name
	extended = false,
	size = 12,
	weight = 10500,
	antialias = true,
} )

net.Receive( "StarVote", function()
    
    local st = net.ReadTable()
    local votes = #st-1

    

    if votes < 2 then return end

    local function votemember(ply)
        ply:EmitSound("sunbox/vote/voteyes.wav", 75, 100, 1, CHAN_AUTO)
    end
    
    LocalPlayer():EmitSound("sunbox/vote/startvote.wav", 75, 100, 0.5, CHAN_AUTO)

    function drawMultilineText(x, y, text, font, color, maxWidth)
        surface.SetFont(font)
        local words = string.Explode(" ", text)
        local currentLine = ""
        local yOffset = 0
        
        for _, word in ipairs(words) do
            local testLine = currentLine == "" and word or currentLine .. " " .. word
            local textWidth, textHeight = surface.GetTextSize(testLine)
    
            if textWidth > maxWidth then
                draw.SimpleText(currentLine, font, x, y + yOffset, color, TEXT_ALIGN_LEFT)
                currentLine = word
                yOffset = yOffset + textHeight
            else
                currentLine = testLine
            end
        end

        if currentLine ~= "" then
            draw.SimpleText(currentLine, font, x, y + yOffset, color, TEXT_ALIGN_LEFT)
        end
    end

    local function calculateTextWidth(text, font)
        surface.SetFont(font)
        local w, h = surface.GetTextSize(text)
        return w, h
    end

    local maxWidth = 170
    surface.SetFont("TextVote")
    for i = 1, #st do
        local textWidth = calculateTextWidth(st[i], "TextVote")
        maxWidth = math.max(maxWidth, textWidth + 40)
    end

    maxWidth = math.min(maxWidth, ScrW() * 0.4)

    local votebase = vgui.Create("DFrame") 
	votebase:SetSize(maxWidth, 100+votes*25) 
	votebase:SetPos(SW*0.005, SH*0.15)
	votebase:SetTitle("") 
	votebase:SetDraggable(false) 
    votebase:ShowCloseButton( false )

    function votebase:Paint( w, h )
        draw.RoundedBox( 6, 0, 0, w, h, Color( 35, 35, 35, 230 ) )
        draw.SimpleText("Голосование тема:", "TextVote", 10, 10, color_white )
        draw.DrawText("Для выбора нажми\nсоответствующую цифру\nна клавиатуре", "TextVote2", 10, 50, Color( 195, 195, 195, 255 ), TEXT_ALIGN_LEFT)

        drawMultilineText(10, 25, st[1], "TextVote", Color( 195, 195, 195, 255 ), maxWidth - 20)

        for i = 1, votes do
            draw.SimpleText(""..i..".", "TextVote", 7, 70+i*25, color_white )
            drawMultilineText(24, 70+i*25, st[i+1], "TextVote", Color( 195, 195, 195, 255 ), maxWidth - 34)
        end
    end
    

    net.Receive( "CloseVoteGui", function()
        if IsValid(votebase) then
            local ply = net.ReadEntity()
            votemember(ply)
            votebase:Close()
        end
    end)

    
    net.Receive( "NotifyVotes", function()
        local ply = net.ReadEntity()
        notification.AddLegacy( "Игрок: "..ply:Name()..' проголосовал за ответ "'..st[net.ReadFloat()+1]..'"', NOTIFY_GENERIC, 4 )
    end)

    net.Receive( "CloseVoteGuiGlobal", function()
        if IsValid(votebase) then
            votebase:Close()
        end
        LocalPlayer():EmitSound("sunbox/vote/finalvote.wav", 75, 100, 0.5, CHAN_AUTO)
    end)
end)




