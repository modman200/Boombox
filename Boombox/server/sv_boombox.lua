
Framework = "qb"

local Webhook = "https://discord.com/api/webhooks/1232389682697080952/ydVdm-HORJzXxTmjafkCZiZEK3mMbd4qV63heb5YWUvfy252gsffWvSd3v-36wR1nRgt" -- Put your Discord webhook here to log Play and Saves
local BotUsername = "Boombox" -- Name for the Bot



if GetResourceState('es_extended') == 'started' or GetResourceState('es_extended') == 'starting' then
    Framework = 'ESX'
    ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' or GetResourceState('qb-core') == 'starting' then
    Framework = 'qb'
    QBCore = exports['qb-core']:GetCoreObject()
else
    print("^0[^1ERROR^0] The framework could not be initialised!^0")
end


if Framework == "ESX" then
    ESX.RegisterUsableItem('boombox', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        TriggerClientEvent('mmts-boombox:useBoombox', source)
        xPlayer.removeInventoryItem('boombox', 1)
    end)
elseif Framework == "qb" then
    QBCore.Functions.CreateUseableItem('boombox', function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        TriggerClientEvent('mmts-boombox:useBoombox', source)
        Player.Functions.RemoveItem('boombox', 1)
    end)
end

RegisterServerEvent('mmts-boombox:deleteObj', function(netId)
    TriggerClientEvent('mmts-boombox:deleteObj', -1, netId)
end)

if Framework == "ESX" then
    RegisterServerEvent('mmts-boombox:objDeleted', function()
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem('boombox', 1)
    end)
elseif Framework == "qb" then
    RegisterServerEvent('mmts-boombox:objDeleted', function()
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddItem('boombox', 1)
    end)
end

RegisterNetEvent("mmts-boombox:soundStatus")
AddEventHandler("mmts-boombox:soundStatus", function(type, musicId, data)
    TriggerClientEvent("mmts-boombox:soundStatus", -1, type, musicId, data)
end)

RegisterNetEvent("mmts-boombox:syncActive")
AddEventHandler("mmts-boombox:syncActive", function(activeRadios)
    TriggerClientEvent("mmts-boombox:syncActive", -1, activeRadios)
end)

if Framework == "ESX" then
    RegisterServerEvent('mmts-boombox:save')
    AddEventHandler('mmts-boombox:save', function(name, link)
        local xPlayer = ESX.GetPlayerFromId(source)
        SongConfirmed(16448250, "Save Song Log", "Player Name: **"..xPlayer.getName().."**\n Player Identifier: **"..xPlayer.getIdentifier().."**\n Song Name: **"..name.."**\n Song Link: **"..link.."**\n Date: "..os.date("** Time: %H:%M Date: %d.%m.%y **").."", "Made by Andistyler")
        MySQL.Async.insert('INSERT INTO `boombox_songs` (`identifier`, `label`, `link`) VALUES (@identifier, @label, @link)', {
            ['@identifier'] = xPlayer.identifier,
            ['@label'] = name,
            ['@link'] = link
        })
    end)
elseif Framework == "qb" then
    RegisterServerEvent('mmts-boombox:save')
    AddEventHandler('mmts-boombox:save', function(name, link)
        local Player = QBCore.Functions.GetPlayer(source)
        local CitizenId = Player.PlayerData.citizenid
        SongConfirmed(16448250, "Save Song Log", "Player Name: **"..GetPlayerName(source).."**\n  Player CitizenID: " .. CitizenId .."**\n Song Name: **"..name.."**\n Song Link: **"..link.."**\n Date: "..os.date("** Time: %H:%M Date: %d.%m.%y **").."", "Made by Andistyler")
        MySQL.Async.insert('INSERT INTO `boombox_songs` (`citizenid`, `label`, `link`) VALUES (@citizenid, @label, @link)', {
            ['@citizenid'] = CitizenId,
            ['@label'] = name,
            ['@link'] = link
        })
    end)
end

if Framework == "ESX" then
    RegisterServerEvent('mmts-boombox:deleteSong')
    AddEventHandler('mmts-boombox:deleteSong', function(data)
        local xPlayer = ESX.GetPlayerFromId(source)
        MySQL.Async.execute('DELETE FROM `boombox_songs` WHERE `identifier` = @identifier AND label = @label AND link = @link', {
            ["@identifier"] = xPlayer.identifier,
            ["@label"] = data.label,
            ["@link"] = data.link,
        })
    end)
elseif Framework == "qb" then
    RegisterServerEvent('mmts-boombox:deleteSong')
    AddEventHandler('mmts-boombox:deleteSong', function(data)
        local Player = QBCore.Functions.GetPlayer(source)
        MySQL.Async.execute('DELETE FROM `boombox_songs` WHERE `citizenid` = @citizenid AND label = @label AND link = @link', {
            ["@citizenid"] = Player.PlayerData.citizenid,
            ["@label"] = data.label,
            ["@link"] = data.link,
        })
    end)
end

if Framework == "ESX" then
    ESX.RegisterServerCallback('mmts-boombox:getSavedSongs', function(source, cb)
        local savedSongs = {}
        local xPlayer = ESX.GetPlayerFromId(source)
        MySQL.Async.fetchAll('SELECT label, link FROM boombox_songs WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(result)
            if result[1] then
                for i=1, #result do
                    table.insert(savedSongs, {label = result[i].label, link = result[i].link})
                end
            end
            if savedSongs then
                cb(savedSongs)
            else
                cb(false)
            end
        end)
    end)
elseif Framework == "qb" then
    QBCore.Functions.CreateCallback('mmts-boombox:getSavedSongs', function(source, cb)
        local savedSongs = {}
        local Player = QBCore.Functions.GetPlayer(source)
        MySQL.Async.fetchAll('SELECT label, link FROM boombox_songs WHERE citizenid = @citizenid', {
            ['@citizenid'] = Player.PlayerData.citizenid
        }, function(result)
            if result[1] then
                for i=1, #result do
                    table.insert(savedSongs, {label = result[i].label, link = result[i].link})
                end
            end
            if savedSongs then
                cb(savedSongs)
            else
                cb(false)
            end
        end)
    end)
end

if Framework == "ESX" then
    RegisterNetEvent("mmts-boombox:DiscordKnows")
    AddEventHandler("mmts-boombox:DiscordKnows", function(link)
        local xPlayer = ESX.GetPlayerFromId(source)
        SongConfirmed(16448250, "Play Song Log", "Player Name: **"..xPlayer.getName().."**\n Player Identifier: **"..xPlayer.getIdentifier().."**\n Song Link: **"..link.."**\n Date: "..os.date("** Time: %H:%M Date: %d.%m.%y **").."", "Made by Andistyler")
    end)
elseif Framework == "qb" then
    RegisterNetEvent("mmts-boombox:DiscordKnows")
    AddEventHandler("mmts-boombox:DiscordKnows", function(link)
        local Player = QBCore.Functions.GetPlayer(source)
        local CitizenId = Player.PlayerData.citizenid
        SongConfirmed(16448250, "Play Song Log", "Player Name: **"..GetPlayerName(source).."**\n  Player CitizenID: " .. CitizenId .."**\n Song Link: **"..link.."**\n Date: "..os.date("** Time: %H:%M Date: %d.%m.%y **").."", "Made by Andistyler")
    end)
end

----- Boom Box Discord Hook System -----

SongConfirmed = function(color, name, message, footer)
    if Webhook and Webhook ~= 'WEBHOOK_HERE' then
        local SongConfirmed = {
                {
                    ["color"] = color,
                    ["title"] = "**".. name .."**",
                    ["description"] = message,
                    ["footer"] = {
                        ["text"] = footer,
                    },
                }
            }

          PerformHttpRequest(Webhook, function(err, text, headers) end, 'POST', json.encode({username = BotUsername, embeds = SongConfirmed}), { ['Content-Type'] = 'application/json' })
    end
end

local url = nil
local YOUR_API_KEY = "AIzaSyDR3ZCK4hqQMcnRLJYbX5siXqp1bp6KvXc"
function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

RegisterCommand("boombox", function(source, args, rawCommand)
    if args[1] == nil then
        print("error")
    else
        url = args[1]
    end
    -- Extracting video ID from the URL
    local id
    if string.find(url, "youtu.be") then
        id = split(url, "/")[4]
       
    else
        id = split(split(url, "?v=")[2], "&")[1]
    end

    --print(id)
    --print(YOUR_API_KEY)
    --print(url)
    --print(PerformHttpRequest("https://www.googleapis.com/youtube/v3/videos?id=" .. id .. "&part=snippet&key="..YOUR_API_KEY))
    -- Constructing API request URL
    --api = "https://www.googleapis.com/youtube/v3/videos?id=" .. id .. "&part=snippet&key="..YOUR_API_KEY
    
    -- Making the HTTP request
    --local http = require("socket.http")
    local response = PerformHttpRequest("https://www.googleapis.com/youtube/v3/videos?id=" .. id .. "&part=snippet&key="..YOUR_API_KEY, function (errorCode, resultData, resultHeaders, errorData)
    response = resultData
    local truecount = 0

        for k,v in pairs(Config.WordsList) do
            if string.find(string.lower(response), v.text) and v.allowed then
                truecount = truecount +1
            else
            
            end
            
        end
            print(truecount)

    --if string.find(string.lower(response), "copyright free") then
    --    print("This is copyright free")
    --elseif string.find(string.lower(response), "no copyright") then
    --    print("This is copyright free")
    --else
    --    print("Can't play this")
    --end
--
    --local pattern = "(copyright%s*%-?%s*free)|(no%s*%-?%s*copyright)|(royalty%s*%-?%s*Free)|(no%s*copy%s*right)|(twitch%s*%-?%s*friendly)|(twitch%s*%-?%s*safe)"
--
    --for match in string.gmatch(response, pattern) do
    --    print(match)
    --end
end)
end, false)
--PerformHttpRequest("https://www.googleapis.com/youtube/v3/videos?id=" .. id .. "&part=snippet&key="..YOUR_API_KEY, function(text) end)--http.request
