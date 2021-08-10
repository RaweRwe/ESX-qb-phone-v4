ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Races = {}

AvailableRaces = {}

LastRaces = {}
NotFinished = {}

Citizen.CreateThread(function()
    MySQL.Async.fetchAll("SELECT * FROM `lapraces`", {}, function(races)
        if races[1] ~= nil then
            for k, v in pairs(races) do
                local Records = {}
                if v.records ~= nil then
                    Records = json.decode(v.records)
                end
                Races[v.raceid] = {
                    RaceName = v.name,
                    Checkpoints = json.decode(v.checkpoints),
                    Records = Records,
                    Creator = v.creator,
                    RaceId = v.raceid,
                    Started = false,
                    Waiting = false,
                    Distance = v.distance,
                    LastLeaderboard = {},
                    Racers = {},
                }
            end
        end
    end)
end)

ESX.RegisterServerCallback('qb-lapraces:server:GetRacingLeaderboards', function(source, cb)
    cb(Races)
end)

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)
    local retval = 0
    if seconds <= 0 then
        retval = "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        retval = hours..":"..mins..":"..secs
    end
    return retval
end

RegisterServerEvent('qb-lapraces:server:FinishPlayer')
AddEventHandler('qb-lapraces:server:FinishPlayer', function(RaceData, TotalTime, TotalLaps, BestLap)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local esxChar = GetCharacterName(src)
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local PlayersFinished = 0
    local AmountOfRacers = 0
    for k, v in pairs(Races[RaceData.RaceId].Racers) do
        if v.Finished then
            PlayersFinished = PlayersFinished + 1
        end
        AmountOfRacers = AmountOfRacers + 1
    end
    local BLap = 0
    if TotalLaps < 2 then
        BLap = TotalTime
    else
        BLap = BestLap
    end
    if LastRaces[RaceData.RaceId] ~= nil then
        table.insert(LastRaces[RaceData.RaceId], {
            TotalTime = TotalTime,
            BestLap = BLap,
            Holder = {
                [1] = esxChar.firstname,
                [2] = esxChar.lastname
            }
        })
    else
        LastRaces[RaceData.RaceId] = {}
        table.insert(LastRaces[RaceData.RaceId], {
            TotalTime = TotalTime,
            BestLap = BLap,
            Holder = {
                [1] = esxChar.firstname,
                [2] = esxChar.lastname
            }
        })
    end
    if Races[RaceData.RaceId].Records ~= nil and next(Races[RaceData.RaceId].Records) ~= nil then
        if BLap < Races[RaceData.RaceId].Records.Time then
            Races[RaceData.RaceId].Records = {
                Time = BLap,
                Holder = {
                    [1] = esxChar.firstname, 
                    [2] = esxChar.lastname,
                }
            }
            MySQL.Sync.execute("UPDATE `lapraces` SET `records` = '"..json.encode(Races[RaceData.RaceId].Records).."' WHERE `raceid` = '"..RaceData.RaceId.."'", {})
            TriggerClientEvent('qb-phone:client:RaceNotify', src, 'Je hebt het WR van '..RaceData.RaceName..' verbroken met een tijd van: '..SecondsToClock(BLap)..'!')
        end
    else
        Races[RaceData.RaceId].Records = {
            Time = BLap,
            Holder = {
                [1] = esxChar.firstname,
                [2] = esxChar.lastname,
            }
        }

        MySQL.Sync.execute("UPDATE `lapraces` SET `records` = '"..json.encode(Races[RaceData.RaceId].Records).."' WHERE `raceid` = '"..RaceData.RaceId.."'", {})
        TriggerClientEvent('qb-phone:client:RaceNotify', src, 'Je hebt het WR van '..RaceData.RaceName..' neergezet met een tijd van: '..SecondsToClock(BLap)..'!')
    end
    AvailableRaces[AvailableKey].RaceData = Races[RaceData.RaceId]
    TriggerClientEvent('qb-lapraces:client:PlayerFinishs', -1, RaceData.RaceId, PlayersFinished, esxChar)
    if PlayersFinished == AmountOfRacers then
        if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[RaceData.RaceId] ~= nil and next(NotFinished[RaceData.RaceId]) ~= nil then
            for k, v in pairs(NotFinished[RaceData.RaceId]) do
                table.insert(LastRaces[RaceData.RaceId], {
                    TotalTime = v.TotalTime,
                    BestLap = v.BestLap,
                    Holder = {
                        [1] = v.Holder[1],
                        [2] = v.Holder[2]
                    }
                })
            end
        end
        Races[RaceData.RaceId].LastLeaderboard = LastRaces[RaceData.RaceId]
        Races[RaceData.RaceId].Racers = {}
        Races[RaceData.RaceId].Started = false
        Races[RaceData.RaceId].Waiting = false
        table.remove(AvailableRaces, AvailableKey)
        LastRaces[RaceData.RaceId] = nil
        NotFinished[RaceData.RaceId] = nil
    end
    TriggerClientEvent('qb-phone:client:UpdateLapraces', -1)
end)


function IsNameAvailable(RaceName)
    local retval = true
    for RaceId,_ in pairs(Races) do
        if Races[RaceId].RaceName == RaceName then
            retval = false
            break
        end
    end
    return retval
end

RegisterServerEvent('qb-lapraces:server:CreateLapRace')
AddEventHandler('qb-lapraces:server:CreateLapRace', function(RaceName)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    
    if IsNameAvailable(RaceName) then
         TriggerClientEvent('qb-lapraces:client:StartRaceEditor', source, RaceName)
    else
        TriggerClientEvent('notification', source, 'There is already a race with this name.', 2)
    end
end)

ESX.RegisterServerCallback('qb-lapraces:server:GetRaces', function(source, cb)
    cb(AvailableRaces)
end)

ESX.RegisterServerCallback('qb-lapraces:server:GetListedRaces', function(source, cb)
    cb(Races)
end)

ESX.RegisterServerCallback('qb-lapraces:server:GetRacingData', function(source, cb, RaceId)
    cb(Races[RaceId])
end)

ESX.RegisterServerCallback('qb-lapraces:server:HasCreatedRace', function(source, cb)
    cb(HasOpenedRace(ESX.GetPlayerFromId(source).identifier))
end)

ESX.RegisterServerCallback('qb-lapraces:server:IsAuthorizedToCreateRaces', function(source, cb, TrackName)
    cb(true)
end)

function HasOpenedRace(identifier)
    local retval = false
    for k, v in pairs(AvailableRaces) do
        if v.SetupSteam == identifier then
            retval = true
        end
    end
    return retval
end

ESX.RegisterServerCallback('qb-lapraces:server:GetTrackData', function(source, cb, RaceId)
    MySQL.Sync.execute("SELECT * FROM `users` WHERE `identifier` = '"..Races[RaceId].Creator.."'", {}, function(result)
        if result[1] ~= nil then
            result[1].charinfo = { firstname = result[1].firstname, lastname = result[1].lastname }
            cb(Races[RaceId], result[1])
        else
            cb(Races[RaceId], {
                charinfo = {
                    firstname = "Unknown",
                    lastname = "Unknown",
                }
            })
        end
    end)
end)

function GetOpenedRaceKey(RaceId)
    local retval = nil
    for k, v in pairs(AvailableRaces) do
        if v.RaceId == RaceId then
            retval = k
            break
        end
    end
    return retval
end

function GetCurrentRace(identifier)
    local retval = nil
    for RaceId,_ in pairs(Races) do
        for cid,_ in pairs(Races[RaceId].Racers) do
            if cid == identifier then
                retval = RaceId
                break
            end
        end
    end
    return retval
end

RegisterServerEvent('qb-lapraces:server:JoinRace')
AddEventHandler('qb-lapraces:server:JoinRace', function(RaceData)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local esxChar = GetCharacterName(src)
    local RaceName = RaceData.RaceData.RaceName
    local RaceId = GetRaceId(RaceName)
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local CurrentRace = GetCurrentRace(Player.identifier)
    if CurrentRace ~= nil then
        local AmountOfRacers = 0
        PreviousRaceKey = GetOpenedRaceKey(CurrentRace)
        for k, v in pairs(Races[CurrentRace].Racers) do
            AmountOfRacers = AmountOfRacers + 1
        end
        Races[CurrentRace].Racers[Player.identifier] = nil
        if (AmountOfRacers - 1) == 0 then
            Races[CurrentRace].Racers = {}
            Races[CurrentRace].Started = false
            Races[CurrentRace].Waiting = false
            table.remove(AvailableRaces, PreviousRaceKey)
            TriggerClientEvent('notification', src, 'You were the only one in the race. The race is over.', 2)
            TriggerClientEvent('qb-lapraces:client:LeaveRace', src, Races[CurrentRace])
        else
            AvailableRaces[PreviousRaceKey].RaceData = Races[CurrentRace]
            TriggerClientEvent('qb-lapraces:client:LeaveRace', src, Races[CurrentRace])
        end
        TriggerClientEvent('qb-phone:client:UpdateLapraces', -1)
    end
    Races[RaceId].Waiting = true
    Races[RaceId].Racers[Player.identifier] = {
        Checkpoint = 0,
        Lap = 1,
        Finished = false,
    }
    AvailableRaces[AvailableKey].RaceData = Races[RaceId]
    TriggerClientEvent('qb-lapraces:client:JoinRace', src, Races[RaceId], RaceData.Laps)
    TriggerClientEvent('qb-phone:client:UpdateLapraces', -1)
    local creatorsource = ESX.GetPlayerFromIdentifier(AvailableRaces[AvailableKey].SetupSteam).source
    if creatorsource ~= Player.source then
        TriggerClientEvent('qb-phone:client:RaceNotify', creatorsource, string.sub(esxChar.firstname, 1, 1)..'. '..esxChar.lastname..' is de race gejoined!')
    end
end)

RegisterServerEvent('qb-lapraces:server:LeaveRace')
AddEventHandler('qb-lapraces:server:LeaveRace', function(RaceData)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local esxChar = GetCharacterName(src)
    local RaceName
    if RaceData.RaceData ~= nil then
        RaceName = RaceData.RaceData.RaceName
    else
        RaceName = RaceData.RaceName
    end
    local RaceId = GetRaceId(RaceName)
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local creatorsource = ESX.GetPlayerFromIdentifier(AvailableRaces[AvailableKey].SetupSteam).source
    if creatorsource ~= Player.source then
        TriggerClientEvent('qb-phone:client:RaceNotify', creatorsource, string.sub(esxChar.firstname, 1, 1)..'. '..esxChar.lastname..' is de race geleaved!')
    end
    local AmountOfRacers = 0
    for k, v in pairs(Races[RaceData.RaceId].Racers) do
        AmountOfRacers = AmountOfRacers + 1
    end
    if NotFinished[RaceData.RaceId] ~= nil then
        table.insert(NotFinished[RaceData.RaceId], {
            TotalTime = "DNF",
            BestLap = "DNF",
            Holder = {
                [1] = esxChar.firstname,
                [2] = esxChar.lastname
            }
        })
    else
        NotFinished[RaceData.RaceId] = {}
        table.insert(NotFinished[RaceData.RaceId], {
            TotalTime = "DNF",
            BestLap = "DNF",
            Holder = {
                [1] = esxChar.firstname,
                [2] = esxChar.lastname
            }
        })
    end
    Races[RaceId].Racers[Player.identifier] = nil
    if (AmountOfRacers - 1) == 0 then
        if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[RaceId] ~= nil and next(NotFinished[RaceId]) ~= nil then
            for k, v in pairs(NotFinished[RaceId]) do
                if LastRaces[RaceId] ~= nil then
                    table.insert(LastRaces[RaceId], {
                        TotalTime = v.TotalTime,
                        BestLap = v.BestLap,
                        Holder = {
                            [1] = v.Holder[1],
                            [2] = v.Holder[2]
                        }
                    })
                else
                    LastRaces[RaceId] = {}
                    table.insert(LastRaces[RaceId], {
                        TotalTime = v.TotalTime,
                        BestLap = v.BestLap,
                        Holder = {
                            [1] = v.Holder[1],
                            [2] = v.Holder[2]
                        }
                    })
                end
            end
        end
        Races[RaceId].LastLeaderboard = LastRaces[RaceId]
        Races[RaceId].Racers = {}
        Races[RaceId].Started = false
        Races[RaceId].Waiting = false
        table.remove(AvailableRaces, AvailableKey)
        TriggerClientEvent('notification', src, 'You were the only one in the race. The race is over.', 2)
        TriggerClientEvent('qb-lapraces:client:LeaveRace', src, Races[RaceId])
        LastRaces[RaceId] = nil
        NotFinished[RaceId] = nil
    else
        AvailableRaces[AvailableKey].RaceData = Races[RaceId]
        TriggerClientEvent('qb-lapraces:client:LeaveRace', src, Races[RaceId])
    end
    TriggerClientEvent('qb-phone:client:UpdateLapraces', -1)
end)

RegisterServerEvent('qb-lapraces:server:SetupRace')
AddEventHandler('qb-lapraces:server:SetupRace', function(RaceId, Laps)
    local Player = ESX.GetPlayerFromId(source)
    if Races[RaceId] ~= nil then
        if not Races[RaceId].Waiting then
            if not Races[RaceId].Started then
                Races[RaceId].Waiting = true
                table.insert(AvailableRaces, {
                    RaceData = Races[RaceId],
                    Laps = Laps,
                    RaceId = RaceId,
                    SetupSteam = Player.identifier,
                })
                TriggerClientEvent('qb-phone:client:UpdateLapraces', -1)
                SetTimeout(5 * 60 * 1000, function()
                    if Races[RaceId].Waiting then
                        local AvailableKey = GetOpenedRaceKey(RaceId)
                        for cid,_ in pairs(Races[RaceId].Racers) do
                            local RacerData = ESX.GetPlayerFromIdentifier(cid)
                            if RacerData ~= nil then
                                TriggerClientEvent('qb-lapraces:client:LeaveRace', RacerData.source, Races[RaceId])
                            end
                        end
                        table.remove(AvailableRaces, AvailableKey)
                        Races[RaceId].LastLeaderboard = {}
                        Races[RaceId].Racers = {}
                        Races[RaceId].Started = false
                        Races[RaceId].Waiting = false
                        LastRaces[RaceId] = nil
                        TriggerClientEvent('qb-phone:client:UpdateLapraces', -1)
                    end
                end)
            else
                TriggerClientEvent('notification', source, 'The race is already active.', 2)
            end
        else
            TriggerClientEvent('notification', source, 'The race is already active.', 2)
        end
    else
        TriggerClientEvent('notification', source, 'This race does not exist.', 2)
    end
end)

RegisterServerEvent('qb-lapraces:server:UpdateRaceState')
AddEventHandler('qb-lapraces:server:UpdateRaceState', function(RaceId, Started, Waiting)
    Races[RaceId].Waiting = Waiting
    Races[RaceId].Started = Started
end)

RegisterServerEvent('qb-lapraces:server:UpdateRacerData')
AddEventHandler('qb-lapraces:server:UpdateRacerData', function(RaceId, Checkpoint, Lap, Finished)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local steam = Player.identifier

    Races[RaceId].Racers[steam].Checkpoint = Checkpoint
    Races[RaceId].Racers[steam].Lap = Lap
    Races[RaceId].Racers[steam].Finished = Finished

    TriggerClientEvent('qb-lapraces:client:UpdateRaceRacerData', -1, RaceId, Races[RaceId])
end)

RegisterServerEvent('qb-lapraces:server:StartRace')
AddEventHandler('qb-lapraces:server:StartRace', function(RaceId)
    local src = source
    local MyPlayer = ESX.GetPlayerFromId(src)
    local AvailableKey = GetOpenedRaceKey(RaceId)
    
    if RaceId ~= nil then
        if AvailableRaces[AvailableKey].SetupSteam == MyPlayer.identifier then
            AvailableRaces[AvailableKey].RaceData.Started = true
            AvailableRaces[AvailableKey].RaceData.Waiting = false
            for identifier,_ in pairs(Races[RaceId].Racers) do
                local Player = ESX.GetPlayerFromIdentifier(identifier)
                if Player ~= nil then
                    TriggerClientEvent('qb-lapraces:client:RaceCountdown', Player.source)
                end
            end
            TriggerClientEvent('qb-phone:client:UpdateLapraces', -1)
        else
            TriggerClientEvent('notification', src, 'You are not the maker of the race.', 2)
        end
    else
        TriggerClientEvent('notification', src, 'You are not in a race.', 2)
    end
end)

RegisterServerEvent('qb-lapraces:server:SaveRace')
AddEventHandler('qb-lapraces:server:SaveRace', function(RaceData)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local RaceId = GenerateRaceId()
    local Checkpoints = {}
    for k, v in pairs(RaceData.Checkpoints) do
        Checkpoints[k] = {
            offset = v.offset,
            coords = v.coords,
        }
    end
    Races[RaceId] = {
        RaceName = RaceData.RaceName,
        Checkpoints = Checkpoints,
        Records = {},
        Creator = Player.identifier,
        RaceId = RaceId,
        Started = false,
        Waiting = false,
        Distance = math.ceil(RaceData.RaceDistance),
        Racers = {},
        LastLeaderboard = {},
    }

    MySQL.Sync.execute("INSERT INTO `lapraces` (`name`, `checkpoints`, `creator`, `distance`, `raceid`) VALUES ('"..RaceData.RaceName.."', '"..json.encode(Checkpoints).."', '"..Player.identifier.."', '"..RaceData.RaceDistance.."', '"..GenerateRaceId().."')", {})
end)

function GetRaceId(name)
    local retval = nil
    for k, v in pairs(Races) do
        if v.RaceName == name then
            retval = k
            break
        end
    end
    return retval
end

function GenerateRaceId()
    local RaceId = "LR-"..math.random(1111, 9999)
    while Races[RaceId] ~= nil do
        RaceId = "LR-"..math.random(1111, 9999)
    end
    return RaceId
end

RegisterCommand("togglesetup", function(source, args)
    local Player = ESX.GetPlayerFromId(source)

    Config.RaceSetupAllowed = not Config.RaceSetupAllowed
    if not Config.RaceSetupAllowed then
        TriggerClientEvent('notification', source, 'No more races can be created!', 2)
    else
        TriggerClientEvent('notification', source, "Race's can be created again!", 1)
    end
end)

RegisterCommand('cancelrace', function(source, args, user)
    local Player = ESX.GetPlayerFromId(source)

    local RaceName = table.concat(args, " ")
    if RaceName ~= nil then
        local RaceId = GetRaceId(RaceName)
        if Races[RaceId].Started then
            local AvailableKey = GetOpenedRaceKey(RaceId)
            for steam,_ in pairs(Races[RaceId].Racers) do
                local RacerData = ESX.GetPlayerFromIdentifier(steam)
                if RacerData ~= nil then
                    TriggerClientEvent('qb-lapraces:client:LeaveRace', RacerData.source, Races[RaceId])
                end
            end
            table.remove(AvailableRaces, AvailableKey)
            Races[RaceId].LastLeaderboard = {}
            Races[RaceId].Racers = {}
            Races[RaceId].Started = false
            Races[RaceId].Waiting = false
            LastRaces[RaceId] = nil
            TriggerClientEvent('qb-phone:client:UpdateLapraces', -1)
        else
            TriggerClientEvent('notification', source, 'This race has not started yet.', 2)
        end
    end
end)

ESX.RegisterServerCallback('qb-lapraces:server:CanRaceSetup', function(source, cb)
    cb(Config.RaceSetupAllowed)
end)

-- ESX V1-Final
--[[
function GetCharacter(source)
    local xPlayer = ESX.GetPlayerFromId(source)

	local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.getIdentifier()
	})

    return result[1]
end ]]


function GetCharacter(source)
    for k,v in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(v, 'license:') then
            identifier = string.sub(v, 9)
            break
        end
    end
	local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	})

    return result[1]
end

function GetCharacterName(source)
    char = GetCharacter(source)
	return char.firstname, char.lastname
end