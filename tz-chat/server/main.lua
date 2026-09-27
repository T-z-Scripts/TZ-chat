local lastMessageAt = {}

local function cleanText(text)
    text = tostring(text or ''):gsub('[\r\n\t]', ' ')
    text = text:gsub('^%s+', ''):gsub('%s+$', '')
    if #text > Config.MaxMessageLength then
        text = text:sub(1, Config.MaxMessageLength)
    end
    return text
end

local function broadcastNearby(source, message)
    local origin = GetEntityCoords(GetPlayerPed(source))
    for _, id in ipairs(GetPlayers()) do
        local target = tonumber(id)
        local ped = GetPlayerPed(target)
        if ped ~= 0 and #(GetEntityCoords(ped) - origin) <= Config.ProximityDistance then
            TriggerClientEvent('sk-streetchat:client:message', target, message)
        end
    end
end

local function broadcastMeBubble(source, message)
    local origin = GetEntityCoords(GetPlayerPed(source))
    for _, id in ipairs(GetPlayers()) do
        local target = tonumber(id)
        local ped = GetPlayerPed(target)
        if ped ~= 0 and #(GetEntityCoords(ped) - origin) <= Config.ProximityDistance then
            TriggerClientEvent('sk-streetchat:client:meBubble', target, source, message.author, message.text)
        end
    end
end

RegisterNetEvent('sk-streetchat:server:send', function(requestedMode, rawText)
    local source = source
    local now = GetGameTimer()
    if lastMessageAt[source] and now - lastMessageAt[source] < Config.RateLimitMs then return end

    local mode = requestedMode == 'localChat' and 'localChat' or requestedMode
    local command = Config.Commands[mode]
    if mode ~= 'localChat' and not command then return end

    local text = cleanText(rawText)
    if text == '' then return end
    lastMessageAt[source] = now

    local message = {
        mode = mode,
        author = GetPlayerName(source) or ('ID ' .. source),
        text = text,
        time = os.date('%H:%M')
    }

    if command and command.proximity then
        broadcastNearby(source, message)
        if mode == 'me' then
            broadcastMeBubble(source, message)
        end
    elseif mode == 'localChat' then
        broadcastNearby(source, message)
    else
        TriggerClientEvent('sk-streetchat:client:message', -1, message)
    end
end)

AddEventHandler('playerJoining', function()
    if Config.ShowJoinLeave then
        TriggerClientEvent('sk-streetchat:client:notice', -1, (GetPlayerName(source) or 'A resident') .. ' connected to the grid.')
    end
end)

AddEventHandler('playerDropped', function()
    if Config.ShowJoinLeave then
        TriggerClientEvent('sk-streetchat:client:notice', -1, (GetPlayerName(source) or 'A resident') .. ' disconnected from the grid.')
    end
    lastMessageAt[source] = nil
end)
