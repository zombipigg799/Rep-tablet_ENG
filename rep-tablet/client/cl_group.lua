local inJob = false
local requestCoolDown = false
local isGroupLeader = false
local vpn = false
local groupID = 0
local JobCenter = {}
local request = false

local function loadConfig()
    SendNUIMessage({
        action = "loadConfig",
        config = Config.JobCenter,
    })
end

exports("IsGroupLeader", function()
    return isGroupLeader
end)

exports("GetGroupID", function()
    return groupID
end)

local function ReQuest(title, text, icon, color, timeout, accept, deny)
    request = promise.new()
    SendNUIMessage({
        action = "ReQuest",
        TabletNotify = {
            title = title or "Rep Scripts",
            text = text or "MSG",
            icon = icon or "fas fa-home",
            color = color or "#FFBF00",
            timeout = timeout or 7500, -- Om det är "INGEN" kommer det inte att stängas av automatiskt
            accept = accept or "fas fa-check-circle",
            deny = deny or "fas fa-times-circle",
        },
    })
    local result = Citizen.Await(request)
    return result
end

RegisterNUICallback('openMap', function()
    ExecuteCommand('e tablet2')
    exports['ps-ui']:ShowImage("https://images-ext-2.discordapp.net/external/Fav1ERUT4HznSnjZopp2QH3DHYw2Yh1rLmzyaCgAJUI/https/saeshq2018.weebly.com/uploads/1/1/8/7/118771343/5470709-orig_orig.png?width=690&height=702")
end)

RegisterNUICallback('AcceptNotification', function()
    request:resolve(true)
    request = nil
end)

RegisterNUICallback('DenyNotification', function()
    request:resolve(false)
    request = nil
end)

exports("ReQuest", ReQuest)

-- När den är aktiverad skickar appen ett meddelande för att se om det finns ett jobb eller inte. Om det finns ett jobb, kontrollera
RegisterNUICallback('GetData', function(data, cb)
    local job = LocalPlayer.state.nghe
    if job then
        Core.Functions.TriggerCallback('rep-tablet:callback:getGroupsApp', function (bool, data)
            if bool then
                SendNUIMessage({
                    action = "addGroupStage",  -- När du ställer in Status återgår statusen till sann, och när du uppdaterar appen återgår jobbets status till falskt. Om Stage == {} returnerar gruppmedlemmarnas gränssnitt
                    status =  data,   -- scenens struktur https://cdn.discordapp.com/attachments/1036820124784668692/1052217816528461894/image.png
                })
            else
                SendNUIMessage({
                    action = "refreshApp",  --https://cdn.discordapp.com/attachments/1036820124784668692/1052217278701244527/image.png Struktur för skickade data
                    data = data, -- Kom ihåg att göra om tabellen för att kontrollera vilka som har samma jobb att lägga till och se vilka statuser som är upptagna och vilka som inte är upptagna // Gruppinformation
                    job = LocalPlayer.state.nghe -- Yrke, filtrera bort grupper i datatabellen som har samma sysselsättning
                })
            end
        end)
    else --- jobbcenter visar en lista över yrken
        SendNUIMessage({
            action = "jobcenter",
            data = JobCenter,
        })
    end
end)

-- Skapa blip till arbetsplatsen
RegisterNUICallback('CreateBlip', function(data)
    TriggerEvent(data.event)
end)

RegisterNUICallback('readyToJob', function()
    if groupID == 0 then return end
    local success = ReQuest("Job Offer", 'Would you like to begin this job?', 'fas fa-users', '#FFBF00', "NONE", 'bx bxs-check-square', 'bx bxs-x-square')
    if success == nil then return end
    if success then
        TriggerEvent('rep-tablet:client:readyforjob')
    else
        SendNUIMessage({
            action = "reLoop", -- När du ställer in Status återgår statusen till sant och när du uppdaterar appen återgår jobbets status till misslyckad 
        })
    end
end)

-- Skapa en grupp
RegisterNUICallback('CreateJobGroup', function(data, cb) --employment
    local result = vpn
    TriggerServerEvent('rep-tablet:server:createJobGroup', result, LocalPlayer.state.nghe)
    isGroupLeader = true
    cb("ok")
end)

--Gå med i gruppen
RegisterNUICallback('RequestToJoin', function (data, cb)
    if not requestCoolDown then
        requestCoolDown = true
        Core.Functions.Notify("Sent Request", "success")
        TriggerServerEvent('rep-tablet:server:requestJoinGroup', data)
        Wait(5000)
        requestCoolDown = false
    else
        Core.Functions.Notify("You need to wait before requesting again", "error")
    end
end)

RegisterNUICallback('checkOut', function (data, cb)
    if groupID ~= 0 or inJob then
        if inJob then
            SendNUIMessage({
                action = "closeAllNotification",
            })
            TriggerServerEvent('rep-tablet:server:checkout', groupID)
            LocalPlayer.state:set('nghe', nil, false)
        end
    end
    if groupID == 0 then
        TriggerEvent('rep-tablet:client:checkout')
    end
    SendNUIMessage({
        action = "jobcenter",
        data = JobCenter,
    })
end)

RegisterNetEvent('rep-tablet:client:closeAllNotification', function ()
    SendNUIMessage({
        action = "closeAllNotification",
    })
end)
-- Ut ur gruppen
RegisterNUICallback('LeaveGroup', function(data, cb) --Klicka på gruppdata
    if not data then return end
    local success = ReQuest("Job Center", 'Are you sure you want to leave the group?', 'fas fa-users', '#FFBF00', "NONE", 'bx bxs-check-square', 'bx bxs-x-square')
    if success then
        isGroupLeader = false
        TriggerServerEvent('rep-tablet:server:LeaveGroup', groupID)
        cb("ok")
    end
end)

RegisterNUICallback('DisbandGroup', function(data, cb) --Klicka på gruppdata
    if not data then return end
    local success = ReQuest("Job Center", 'Are you sure you want to disband the group?', 'fas fa-users', '#FFBF00', "NONE", 'bx bxs-check-square', 'bx bxs-x-square')
    if success then
        isGroupLeader = false
        TriggerServerEvent('rep-tablet:server:DisbandGroup', groupID)
        cb("ok")
    end
end)
-- Event

-- Uppdatera gruppen, någon i scenen kommer inte att redigera
RegisterNetEvent('rep-tablet:client:RefreshGroupsApp', function(bool)
    local job = LocalPlayer.state.nghe
    if not job then
        SendNUIMessage({
            action = "jobcenter",
            data = JobCenter,
        })
    else
        if bool then inJob = false end
        if inJob then return end
        Core.Functions.TriggerCallback('rep-tablet:callback:getGroupsApp', function (bool1, data)
            if bool1 then
                SendNUIMessage({
                    action = "addGroupStage",  -- När du ställer in Status återgår statusen till sann, och när du uppdaterar appen återgår jobbets status till falskt. Om Stage == {} returnerar gruppmedlemmarnas gränssnitt
                    status =  data,   -- scenens struktur https://cdn.discordapp.com/attachments/1036820124784668692/1052217816528461894/image.png
                })
            else
                SendNUIMessage({
                    action = "refreshApp",  --https://cdn.discordapp.com/attachments/1036820124784668692/1052217278701244527/image.png Struktur för skickade data
                    data = data, -- Kom ihåg att göra om tabellen för att kontrollera vilka som har samma jobb att lägga till och se vilka statuser som är upptagna och vilka som inte är upptagna // Gruppinformation
                    job = LocalPlayer.state.nghe -- Yrke, filtrera bort grupper i datatabellen som har samma sysselsättning
                })
            end
        end)
    end
end)

-- När du loggar in visas grupper för det yrket
RegisterNetEvent('rep-tablet:client:signIn', function(bool)
    LocalPlayer.state:set('nghe', bool, false)
    Core.Functions.TriggerCallback('rep-tablet:callback:getGroupsApp', function (bool, data)
        if bool then
        else
            SendNUIMessage({
                action = "refreshApp",  --https://cdn.discordapp.com/attachments/1036820124784668692/1052217278701244527/image.png Cấu trúc data gửi lên
                data = data, -- Kom ihåg att göra om tabellen för att kontrollera vilket jobb som har samma jobb att lägga till och se vilken status som är upptagen och vilken som inte är upptagen
                 jobb = LocalPlayer.state.listen
                job = LocalPlayer.state.nghe
            })
        end
    end)
end)

-- När du loggar ut byter du tillbaka till jobbcentrets gränssnitt
RegisterNetEvent('rep-tablet:client:signOff', function()
    if groupID ~= 0 or inJob then
        if inJob then
            SendNUIMessage({
            action = "closeAllNotification",
        })
        end
        TriggerServerEvent('rep-tablet:server:checkout', groupID)
        LocalPlayer.state:set('nghe', nil, false)
    end
    if groupID == 0 then
        TriggerEvent('rep-tablet:client:checkout')
    end
    SendNUIMessage({
        action = "jobcenter",
        data = JobCenter,
    })
end)

-- Lägg till uppgifter 
RegisterNetEvent('rep-tablet:client:AddGroupStage', function(data)
    inJob = true
    SendNUIMessage({
        action = "addGroupStage",
        status =  data
    })
end)

--Ange ID för gruppen
RegisterNetEvent('rep-tablet:client:UpdateGroupId', function(id)
    groupID = id
    if id == 0 then
        isGroupLeader = false
    end
end)

--Vänligen gå med i gruppen // Begär att gå med i en grupp
RegisterNetEvent('rep-tablet:client:requestJoinGroup', function(target)
    local success = ReQuest("Job Center", target..' want to join your group', 'fas fa-users', '#FFBF00', "NONE", 'bx bxs-check-square', 'bx bxs-x-square')
    if success then
        TriggerServerEvent('rep-tablet:client:requestJoin', target, true)
    else
        TriggerServerEvent('rep-tablet:client:requestJoin', target, false)
    end
end)

RegisterNetEvent('rep-tablet:client:notReady', function ()
    SendNUIMessage({
        action = "cancelReady",
    })
end)

--Update Group Job
RegisterNetEvent('rep-tablet:client:updateGroupJob', function (data)
    Config.JobCenter = data
    loadConfig()
    JobCenter = {}
    for k, v in pairs(Config.JobCenter) do
        if vpn then
            JobCenter[#JobCenter+1] = v
        else
            if v.vpn == false then
                JobCenter[#JobCenter+1] = v
            end
        end
    end
end)

--Gå med i grupp
RegisterNetEvent('rep-tablet:client:Join', function(id)
    groupID = id
    TriggerServerEvent('rep-tablet:server:Join', id, vpn)
end)

-- ReQuest
RegisterNetEvent("rep-tablet:client:request", function(title, text, icon, color, timeout, accept, deny)
    ReQuest(title, text, icon, color, timeout, accept, deny)
end)

RegisterNetEvent('rep-tablet:jobcenter:tow', function()
    SetNewWaypoint(-238.94, -1183.74)
end)

RegisterNetEvent('rep-tablet:jobcenter:taxi', function()
    SetNewWaypoint(909.51, -177.36)
end)

RegisterNetEvent('rep-tablet:jobcenter:postop', function()
    SetNewWaypoint(-432.51, -2787.98)
end)

RegisterNetEvent('rep-tablet:jobcenter:sanitation', function()
    SetNewWaypoint(-351.44, -1566.37)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = nil
end)

local function CheckVPN()
    for _, itemData in pairs(PlayerData.items) do
        if itemData.name == 'vpn' then
            return true
        end
    end
    return false
end

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    Wait(100)
    local result = CheckVPN()
    if vpn ~= result then
        vpn = result
        JobCenter = {}
        for k, v in pairs(Config.JobCenter) do
            if vpn then
                JobCenter[#JobCenter+1] = v
            else
                if v.vpn == false then
                    JobCenter[#JobCenter+1] = v
                end
            end
        end
        TriggerServerEvent('rep-tablet:server:updateVPN', result)
    end
end)

-- Handles state if resource is restarted live.
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        PlayerData = Core.Functions.GetPlayerData()
        vpn = CheckVPN()
        JobCenter = {}
        for k, v in pairs(Config.JobCenter) do
            if vpn then
                JobCenter[#JobCenter+1] = v
            else
                if v.vpn == false then
                    JobCenter[#JobCenter+1] = v
                end
            end
        end
        LocalPlayer.state.nghe = nil
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(10000)
    Core.Functions.TriggerCallback('rep-tablet:callback:getGroupsJob', function (data)
        Config.JobCenter = data
    end)
    vpn = CheckVPN()
    loadConfig()
    JobCenter = {}
    for k, v in pairs(Config.JobCenter) do
        if vpn then
            JobCenter[#JobCenter+1] = v
        else
            if v.vpn == false then
                JobCenter[#JobCenter+1] = v
            end
        end
    end
    PlayerData = Core.Functions.GetPlayerData()
end)
