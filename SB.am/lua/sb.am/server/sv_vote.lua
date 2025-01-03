local VOTE_SETTINGS = {
    DURATION = 30,
    MAX_OPTIONS = 5
}

local VoteSystem = {
    votes = {},
    active = false,
    question = ""
}

for i = 1, VOTE_SETTINGS.MAX_OPTIONS do
    VoteSystem.votes["vote" .. i] = {}
end

util.AddNetworkString("StarVote")
util.AddNetworkString("CloseVoteGui")
util.AddNetworkString("CloseVoteGuiGlobal")
util.AddNetworkString("NotifyVotes")

local function NotifyVoteChoice(player, voteNumber)
    SB_AM.Log(player:Nick() .. " (" .. player:SteamID() .. ") проголосовал за вариант " .. (voteNumber + 1), "info", nil, true)
    
    net.Start("CloseVoteGui")
        net.WriteEntity(player)
        net.WriteFloat(voteNumber)
    net.Send(player)

    net.Start("NotifyVotes")
        net.WriteEntity(player)
        net.WriteFloat(voteNumber)
    net.Broadcast()
end

local function ProcessVoteResults()
    local results = {
        mostVotes = 0,
        winningOption = 1,
        isTied = false,
        totalVotes = 0
    }

    for i = 1, VOTE_SETTINGS.MAX_OPTIONS do
        local currentVotes = #VoteSystem.votes["vote" .. i]
        results.totalVotes = results.totalVotes + currentVotes

        if currentVotes > results.mostVotes then
            results.mostVotes = currentVotes
            results.winningOption = i
            results.isTied = false
        elseif currentVotes == results.mostVotes and currentVotes > 0 then
            results.isTied = true
        end
    end

    return results
end

local function ResetVoteSystem()
    VoteSystem.active = false
    VoteSystem.question = ""
    for i = 1, VOTE_SETTINGS.MAX_OPTIONS do
        table.Empty(VoteSystem.votes["vote" .. i])
    end
    hook.Remove("PlayerButtonDown", "HandleVoteInput")
end

local function HandleVoteInput(player, button)
    if not VoteSystem.active then return end

    for i = 1, VOTE_SETTINGS.MAX_OPTIONS do
        if table.HasValue(VoteSystem.votes["vote" .. i], player) then return end
    end

    local voteNumber = button - KEY_1
    if voteNumber >= 0 and voteNumber < VOTE_SETTINGS.MAX_OPTIONS then
        local voteKey = "vote" .. (voteNumber + 1)
        if VoteSystem.votes[voteKey] then
            table.insert(VoteSystem.votes[voteKey], player)
            NotifyVoteChoice(player, voteNumber)
        end
    end
end

function startvote(text, ...)
    if not text or string.len(text) < 2 then 
        SB_AM.Log("Попытка начать голосование с пустым текстом", "error", ply)
        return 
    end
    
    local options = {...}
    if #options < 2 then 
        SB_AM.Log("Попытка начать голосование с недостаточным количеством вариантов", "error", ply)
        return 
    end

    if VoteSystem.active then 
        SB_AM.Log("Попытка начать голосование когда уже идет другое голосование", "error", ply)
        return 
    end
    
    VoteSystem.active = true
    VoteSystem.question = text
    SB_AM.Log("Начато новое голосование: " .. text, "info")

    net.Start("StarVote")
        net.WriteTable({text, ...})
    net.Broadcast()

    hook.Add("PlayerButtonDown", "HandleVoteInput", HandleVoteInput)

    timer.Create("VoteTimer", VOTE_SETTINGS.DURATION, 1, function()
        local results = ProcessVoteResults()

        if results.totalVotes > 0 then
            local totalPlayers = player.GetCount()
            local votePercentage = math.Round((results.totalVotes / totalPlayers) * 100)
            SB_AM.Log(string.format('Голосование "%s" завершено. Всего голосов: %d (%d%% игроков)', VoteSystem.question, results.totalVotes, votePercentage), "info")
        else
            SB_AM.Log(string.format('Голосование "%s" завершено без голосов', VoteSystem.question), "info")
        end

        ResetVoteSystem()

        net.Start("CloseVoteGuiGlobal")
        net.Broadcast()
    end)
end
