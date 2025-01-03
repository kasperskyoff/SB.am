SB_AM = SB_AM or {}
SB_AM.Commands = SB_AM.Commands or {}

if SERVER then
    include("../../server/sv_vote.lua")
end

SB_AM.Commands.vote = {
    Description = "Создает голосование.",
    ShowPlayerList = false,
    Arguments = {
        {name = "Вопрос", required = true},
        {name = "Варианты", required = true},
    },
    Callback = function(ply, args)
        if not IsValid(ply) then
            SB_AM.Log("Консоль не может создавать голосования", "error", ply)
            return
        end

        if not SB_AM.Ranks.HasPermission(ply, "vote") then
            SB_AM.Log("У вас нет прав на использование этой команды", "error", ply)
            return
        end

        if not args[1] or not args[2] then
            SB_AM.Log("Использование: !vote \"Вопрос\" Вариант1. Вариант2. И т.д", "error", ply)
            return
        end

        local text = args[1]
        
        table.remove(args, 1)
        local optionsText = table.concat(args, " ")
        
        local options = string.Split(optionsText, ".")
        for i, option in ipairs(options) do
            options[i] = string.Trim(option)
        end

        local option1 = options[1]
        local option2 = options[2]
        local option3 = options[3]
        local option4 = options[4]
        local option5 = options[5]

        if not option1 or not option2 then
            SB_AM.Log("Необходимо указать минимум 2 варианта ответа", "error", ply)
            return
        end

        if string.len(text) < 2 or string.len(option1) < 2 or string.len(option2) < 2 then
            SB_AM.Log("Текст вопроса и варианты ответов должны содержать минимум 2 символа", "error", ply)
            return
        end

        if SERVER and startvote then
            startvote(text, option1, option2, option3, option4, option5)
        else
            SB_AM.Log("Ошибка: функция голосования недоступна", "error", ply)
        end
    end
}

if SERVER then
    util.AddNetworkString("StarVote")
    util.AddNetworkString("EndVote")
    util.AddNetworkString("VoteResponse")
    net.Receive("VoteResponse", function(len, ply)
        if not SB_AM.ActiveVote then return end
        
        local vote = net.ReadBool()
        
        if table.HasValue(SB_AM.ActiveVote.votes.yes, ply) or 
           table.HasValue(SB_AM.ActiveVote.votes.no, ply) then
            SB_AM.Log("Вы уже проголосовали!", "error", ply)
            return
        end
        
        if vote then
            table.insert(SB_AM.ActiveVote.votes.yes, ply)
        else
            table.insert(SB_AM.ActiveVote.votes.no, ply)
        end
    end)
end