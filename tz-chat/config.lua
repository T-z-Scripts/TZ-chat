Config = {}

-- Set this to false if another resource is already responsible for opening chat with T.
Config.OpenKey = 'T'
Config.MaxMessageLength = 280
Config.MaxHistory = 120
Config.ProximityDistance = 20.0
Config.RateLimitMs = 650
Config.ShowJoinLeave = false
Config.MeBubbleDuration = 7000
Config.MeBubbleMaxCharacters = 86

Config.Commands = {
    me = { label = 'ME', description = 'Describe a character action', mode = 'me', proximity = true, color = '#f5d336' },
    ["do"] = { label = 'DO', description = 'Describe the surrounding scene', mode = 'do', proximity = true, color = '#d8b938' },
    ooc = { label = 'OOC', description = 'Out of character message', mode = 'ooc', proximity = false, color = '#aab0b5' },
    g = { label = 'GLOBAL', description = 'Send a city-wide message', mode = 'global', proximity = false, color = '#f5d336' },
    twt = { label = 'PULSE', description = 'Post a city pulse', mode = 'pulse', proximity = false, color = '#d8b938' }
}

Config.Mode = {
    localChat = { label = 'LOCAL', description = 'People nearby', color = '#f5d336' },
    me = { label = 'ME', description = 'Character action', color = '#f5d336' },
    ["do"] = { label = 'DO', description = 'Scene detail', color = '#d8b938' },
    ooc = { label = 'OOC', description = 'Out of character', color = '#aab0b5' },
    global = { label = 'GLOBAL', description = 'City broadcast', color = '#f5d336' },
    pulse = { label = 'PULSE', description = 'City social feed', color = '#d8b938' },
    system = { label = 'SYSTEM', description = 'Network notice', color = '#f5d336' }
}
