local chatOpen = false
local canOpenAt = 0
local meBubbles = {}

local function sendNui(action, payload)
    payload = payload or {}
    payload.action = action
    SendNUIMessage(payload)
end

local function closeChat()
    if not chatOpen then return end
    chatOpen = false
    SetNuiFocus(false, false)
    sendNui('close')
end

local function openChat(prefill)
    if chatOpen or GetGameTimer() < canOpenAt then return end
    chatOpen = true
    SetNuiFocus(true, true)
    sendNui('open', { prefill = prefill or '' })
end

local function addMessage(message)
    sendNui('message', message)
end

RegisterCommand('+skstreetchat', function()
    openChat()
end, false)
RegisterCommand('-skstreetchat', function() end, false)
RegisterKeyMapping('+skstreetchat', 'Open StreetKings Chat', 'keyboard', Config.OpenKey)

RegisterCommand('chat', function(_, args)
    openChat(table.concat(args, ' '))
end, false)

for command, _ in pairs(Config.Commands) do
    RegisterCommand(command, function(_, args)
        if #args == 0 then
            openChat('/' .. command .. ' ')
            return
        end
        TriggerServerEvent('sk-streetchat:server:send', command, table.concat(args, ' '))
    end, false)
end

RegisterNUICallback('send', function(data, cb)
    local text = type(data.text) == 'string' and data.text or ''
    local command = type(data.command) == 'string' and data.command or 'localChat'
    TriggerServerEvent('sk-streetchat:server:send', command, text)
    closeChat()
    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    closeChat()
    cb({ ok = true })
end)

RegisterNetEvent('sk-streetchat:client:message', function(message)
    addMessage(message)
end)

RegisterNetEvent('sk-streetchat:client:notice', function(text)
    addMessage({ mode = 'system', author = 'NETWORK', text = text, time = os.date('%H:%M') })
end)

RegisterNetEvent('sk-streetchat:client:meBubble', function(serverId, author, text)
    text = tostring(text or ''):gsub('[\r\n\t]', ' ')
    if #text > Config.MeBubbleMaxCharacters then
        text = text:sub(1, Config.MeBubbleMaxCharacters - 3) .. '...'
    end

    meBubbles[tonumber(serverId)] = {
        author = tostring(author or 'UNKNOWN'),
        text = text,
        expiresAt = GetGameTimer() + Config.MeBubbleDuration
    }
end)

local function drawMeBubble(ped, bubble)
    local coords = GetEntityCoords(ped)
    local visible, x, y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.15)
    if not visible then return end

    local distance = #(GetGameplayCamCoord() - coords)
    if distance > Config.ProximityDistance + 8.0 then return end

    local action = ('* %s'):format(bubble.text)
    local scale = distance > 14.0 and 0.28 or 0.32

    -- Font 4 is the closest built-in FiveM/GTA face to Impact: bold and condensed.
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(245, 211, 54, 255)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(action)
    EndTextCommandDisplayText(x, y - 0.026)
end

CreateThread(function()
    while true do
        local now = GetGameTimer()
        local active = false

        for serverId, bubble in pairs(meBubbles) do
            if now >= bubble.expiresAt then
                meBubbles[serverId] = nil
            else
                local player = GetPlayerFromServerId(serverId)
                if player ~= -1 then
                    local ped = GetPlayerPed(player)
                    if ped ~= 0 then
                        drawMeBubble(ped, bubble)
                        active = true
                    end
                end
            end
        end

        Wait(active and 0 or 350)
    end
end)

CreateThread(function()
    Wait(750)
    sendNui('configure', {
        modes = Config.Mode,
        commands = Config.Commands,
        maxHistory = Config.MaxHistory
    })
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
