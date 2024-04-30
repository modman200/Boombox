-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local InstructionNotification = false
loadModel = function(model)
    while not HasModelLoaded(model) do Wait(0) RequestModel(model) end
    return model
end

loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
    return dict
end

hasBoomBox = function(radio)
    local equipRadio = true
    CreateThread(function()
        if InstructionNotification then
            lib.notify({
                title = 'Instructions',
                description = 'Press E to drop boombox',
                type = 'success'
            })
        end
        while equipRadio do
            Wait(0)
            if IsControlJustReleased(0, 38) then
                equipRadio = false
				DetachEntity(radio)
				PlaceObjectOnGroundProperly(radio)
                FreezeEntityPosition(radio, true)
                boomboxPlaced(radio)
            end
        end
    end)
end

if Framework == "ESX" then
    boomboxPlaced = function(obj)
        local coords = GetEntityCoords(obj)
        local heading = GetEntityHeading(obj)
        local targetPlaced = false
        CreateThread(function()
            while true do
                if DoesEntityExist(obj) and not targetPlaced then
                    exports.qtarget:AddBoxZone("boomboxzone", coords, 1, 1, {
                        name="boomboxzone",
                        heading=heading,
                        debugPoly=false,
                        minZ=coords.z-0.9,
                        maxZ=coords.z+0.9
                    }, {
                        options = {
                            {
                                event = 'wasabi_boombox:interact',
                                icon = 'fas fa-hand-paper',
                                label = 'Interact',
                            },
                            {
                                event = 'wasabi_boombox:pickup',
                                icon = 'fas fa-volume-up',
                                label = 'Pick Up'
                            }

                        },
                        job = 'all',
                        distance = 1.5
                    })
                    targetPlaced = true
                elseif not DoesEntityExist(obj) then
                    exports.qtarget:RemoveZone('boomboxzone')
                    targetPlaced = false
                    break
                end
                Wait(1000)
            end
        end)
    end
elseif Framework == "qb" then
    boomboxPlaced = function(obj)
        local coords = GetEntityCoords(obj)
        local heading = GetEntityHeading(obj)
        local targetPlaced = false
        CreateThread(function()
            while true do
                if DoesEntityExist(obj) and not targetPlaced then
                    exports['qb-target']:AddBoxZone("boomboxzone", coords, 1, 1, {
                        name="boomboxzone",
                        heading=heading,
                        debugPoly=false,
                        minZ=coords.z-0.9,
                        maxZ=coords.z+0.9
                    }, {
                        options = {
                            {
                                event = 'wasabi_boombox:interact',
                                icon = 'fas fa-hand-paper',
                                label = 'Interact',
                            },
                            {
                                event = 'wasabi_boombox:pickup',
                                icon = 'fas fa-volume-up',
                                label = 'Pick Up'
                            }

                        },
                        job = 'all',
                        distance = 1.5
                    })
                    targetPlaced = true
                elseif not DoesEntityExist(obj) then
                    exports['qb-target']:RemoveZone('boomboxzone')
                    targetPlaced = false
                    break
                end
                Wait(1000)
            end
        end)
    end
end

interactBoombox = function(radio, radioCoords)
    if not activeRadios[radio] then
        activeRadios[radio] = {
            pos = radioCoords,
            data = {
                playing = false
            }
        }
    else
        activeRadios[radio].pos = radioCoords
    end
    TriggerServerEvent('wasabi_boombox:syncActive', activeRadios)
    if not activeRadios[radio].data.playing then
        lib.registerContext({
            id = 'boomboxFirst',
            title = 'Boombox',
            options = {
                {
                    title = 'Play Music',
                    description = 'Play Music On Speaker',
                    arrow = true,
                    event = 'wasabi_boombox:playMenu',
                    args = {type = 'play', id = radio}
                },
                {
                    title = 'Saved Songs',
                    description = 'Songs you previously saved',
                    arrow = true,
                    event = 'wasabi_boombox:savedSongs',
                    args = {id = radio}
                }
            }
        })
        lib.showContext('boomboxFirst')
    else
        lib.registerContext({
            id = 'boomboxSecond',
            title = 'Boombox',
            options = {
                {
                    title = 'Change Music',
                    description = 'Change music on speaker',
                    arrow = true,
                    event = 'wasabi_boombox:playMenu',
                    args = {type = 'play', id = radio}
                },
                {
                    title = 'Saved Songs',
                    description = 'Songs you previously saved',
                    arrow = true,
                    event = 'wasabi_boombox:savedSongs',
                    args = {id = radio}
                },
                {
                    title = 'Stop Music',
                    description = 'Stop music on speaker',
                    arrow = false,
                    event = 'wasabi_boombox:playMenu',
                    args = {type = 'stop', id = radio}
                },
                {
                    title = 'Adjust Volume',
                    description = 'Change volume on speaker',
                    arrow = false,
                    event = 'wasabi_boombox:playMenu',
                    args = {type = 'volume', id = radio}
                },
                {
                    title = 'Change Distance',
                    description = 'Change distance on speaker',
                    arrow = false,
                    event = 'wasabi_boombox:playMenu',
                    args = {type = 'distance', id = radio}
                }
            }
        })
        lib.showContext('boomboxSecond')
    end
end

selectSavedSong = function(data)
    lib.registerContext({
        id = 'selectSavedSong',
        title = 'Manage Song',
        options = {
            {
                title = 'Play Song',
                description = 'Play this song',
                arrow = false,
                event = 'wasabi_boombox:playSavedSong',
                args = data
            },
            {
                title = 'Delete Song',
                description = 'Delete this song',
                arrow = true,
                event = 'wasabi_boombox:deleteSong',
                args = data
            }
        }
    })
    lib.showContext('selectSavedSong')
end

if Framework == "ESX" then
    savedSongsMenu = function(radio)
        ESX.TriggerServerCallback('wasabi_boombox:getSavedSongs', function(cb)
            local radio = radio.id
            local Options = {
                {
                    title = 'Save A Song',
                    description = 'Save a song to play later',
                    arrow = true,
                    event = 'wasabi_boombox:saveSong',
                    args = {id = radio}
                }
            }
            if cb then
                for i=1, #cb do
                    print(radio)
                    table.insert(Options, {
                        title = cb[i].label,
                        description = '',
                        arrow = true,
                        event = 'wasabi_boombox:selectSavedSong',
                        args = {id = radio, link = cb[i].link, label = cb[i].label}
                    })
                end
            end
            lib.registerContext({
                id = 'boomboxSaved',
                title = 'Boombox',
                options = Options
            })
            lib.showContext('boomboxSaved')
        end)
    end
elseif Framework == "qb" then
    savedSongsMenu = function(radio)
        QBCore.Functions.TriggerCallback('wasabi_boombox:getSavedSongs', function(cb)
            local radio = radio.id
            local Options = {
                {
                    title = 'Save A Song',
                    description = 'Save a song to play later',
                    arrow = true,
                    event = 'wasabi_boombox:saveSong',
                    args = {id = radio}
                }
            }
            if cb then
                for i=1, #cb do
                    print(radio)
                    table.insert(Options, {
                        title = cb[i].label,
                        description = '',
                        arrow = true,
                        event = 'wasabi_boombox:selectSavedSong',
                        args = {id = radio, link = cb[i].link, label = cb[i].label}
                    })
                end
            end
            lib.registerContext({
                id = 'boomboxSaved',
                title = 'Boombox',
                options = Options
            })
            lib.showContext('boomboxSaved')
        end)
    end
end

--local url = nil
--local YOUR_API_KEY = "AIzaSyDR3ZCK4hqQMcnRLJYbX5siXqp1bp6KvXc"
--function split(inputstr, sep)
--    if sep == nil then
--        sep = "%s"
--    end
--    local t = {}
--    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
--        table.insert(t, str)
--    end
--    return t
--end
--ResgisterCommand("bommbox", function(args, rawCommand)
--    if args[1] == nil then
--        print("error")
--    else
--        url = args[1]
--    end
--    -- Extracting video ID from the URL
--    local id
--    if string.find(url, "youtu.be") then
--        id = split(url, "/")[4]
--    else
--        id = split(split(url, "?v=")[2], "&")[1]
--    end
--    
--    -- Constructing API request URL
--    api = "https://www.googleapis.com/youtube/v3/videos?id=" .. id .. "&part=snippet&key="..YOUR_API_KEY
--    
--    -- Making the HTTP request
--    local http = require("socket.http")
--    local response, code = http.request(api)
--    
--    -- Checking for copyright status in response
--    if string.find(string.lower(response), "copyright free") then
--        print("This is copyright free")
--    else
--        print("Can't play this")
--    end
--
--
--end, false)

--RegisterCommand("boombox", function(source, args, rawCommand)
--    if args[1] == nil then
--        print("error")
--    else
--        url = args[1]
--    end
--    -- Extracting video ID from the URL
--    local id
--    if string.find(url, "youtu.be") then
--        id = split(url, "/")[4]
--    else
--        id = split(split(url, "?v=")[2], "&")[1]
--    end
--    
--    -- Constructing API request URL
--    api = "https://www.googleapis.com/youtube/v3/videos?id=" .. id .. "&part=snippet&key="..YOUR_API_KEY
--    
--    -- Making the HTTP request
--    --local http = require("socket.http")
--    local response, code = PerformHttpRequest(api)--http.request
--    
--    -- Checking for copyright status in response
--    if string.find(string.lower(response), "copyright free") then
--        print("This is copyright free")
--    else
--        print("Can't play this")
--    end
--end, false --[[this command is not restricted, everyone can use this.]])
--
--
--PerformHttpRequest(api, function (errorCode, resultData, resultHeaders, errorData)
--    print("Returned error code:" .. tostring(errorCode))
--    print("Returned data:" .. tostring(resultData))
--    print("Returned result Headers:" .. tostring(resultHeaders))
--    print("Returned error data:" .. tostring(errorData))
--  end)