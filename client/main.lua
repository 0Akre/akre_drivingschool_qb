local QBCore = exports['qb-core']:GetCoreObject()
local testActive = false
local testPassed = false
local drivingTestActive = false
local currentCheckpoint = 1
local drivingTestVehicle = nil
local testBlip = nil
local testRoute = nil
local penaltyPoints = 0
local checkpointMarker = nil
local speedLimitCheckActive = false
local currentLicenseTest = nil
local drivingTestStarted = false

local function SendNotification(message, type, duration)
    if Config.Notify.system == "qb" then
        QBCore.Functions.Notify(message, type or 'success', duration)
    elseif Config.Notify.system == "ox" then
        exports.ox_lib:notify({
            description = message,
            type = type or 'success',
            duration = duration or 3000
        })
    end
end

local function GetMessage(key, replacements)
    local message = Config.Notify.messages[key]
    if not message then return key end
    
    if replacements then
        for k, v in pairs(replacements) do
            message = message:gsub("{"..k.."}", v)
        end
    end
    
    return message
end

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('startTest', function(data, cb)
    QBCore.Functions.TriggerCallback('driving-school:server:checkMoney', function(hasMoney)
        if hasMoney then
            cb({ success = true })
        else
            cb({ success = false, message = GetMessage('insufficient_funds', {price = Config.TestPrice}) })
            SetNuiFocus(false, false)
        end
    end, Config.TestPrice)
end)

local function startTheoryTest()
    local selectedQuestions = {}
    local allQuestions = Config.TestQuestions
    local totalQuestions = #allQuestions
    
    local questionsToSelect = math.min(10, totalQuestions)
    
    local indices = {}
    for i = 1, totalQuestions do
        indices[i] = i
    end
    
    for i = 1, questionsToSelect do
        local randomIndex = math.random(1, #indices)
        local questionIndex = indices[randomIndex]
        
        table.insert(selectedQuestions, allQuestions[questionIndex])
        
        table.remove(indices, randomIndex)
    end
    
    testActive = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "open",
        questions = selectedQuestions,
        price = Config.TestPrice
    })
end

RegisterNUICallback('completeTest', function(data, cb)
    testActive = false
    SetNuiFocus(false, false)
    
    if data.passed then
        SendNotification(GetMessage('theory_pass'), 'success')
        
        testPassed = true
        TriggerServerEvent('driving-school:server:saveTheoryResult', true)
    else
        SendNotification(GetMessage('theory_fail'), 'error')
    end
    
    cb('ok')
end)

local function hasPassedTheoryTest()
    local passed = false
    QBCore.Functions.TriggerCallback('driving-school:server:hasPassedTheory', function(result)
        passed = result
        testPassed = result
    end)
    
    local timeout = 0
    while passed == false and timeout < 20 do
        Wait(100)
        timeout = timeout + 1
    end
    
    return passed
end

local instructorPed = nil

local function startDrivingTest(licenseType)
    if not testPassed and not hasPassedTheoryTest() then
        SendNotification(GetMessage('theory_required'), 'error')
        return
    end
    
    local licenseConfig = Config.LicenseTypes[licenseType]
    QBCore.Functions.TriggerCallback('driving-school:server:checkMoney', function(hasMoney)
        if hasMoney then
            currentLicenseTest = licenseType
            
            local startPos = Config.StartLocations[math.random(1, #Config.StartLocations)]
            
            testRoute = Config.TestRoutes[math.random(1, #Config.TestRoutes)]
            
            local vehicleModel = licenseConfig.vehicle
            if type(vehicleModel) == "table" then
                vehicleModel = vehicleModel[math.random(1, #vehicleModel)]
            end
            
            QBCore.Functions.SpawnVehicle(vehicleModel, function(vehicle)
                SetEntityHeading(vehicle, startPos.w)
                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                SetVehicleNumberPlateText(vehicle, "DRVSCHL")
                SetEntityAsMissionEntity(vehicle, true, true)
                drivingTestVehicle = vehicle
                
                local instructorModel = Config.DrivingInstructorPed.model
                RequestModel(instructorModel)
                while not HasModelLoaded(instructorModel) do
                    Wait(10)
                end
                
                instructorPed = CreatePed(4, instructorModel, 0, 0, 0, 0, true, false)
                TaskWarpPedIntoVehicle(instructorPed, vehicle, 0)
                SetEntityInvincible(instructorPed, true)
                SetBlockingOfNonTemporaryEvents(instructorPed, true)
                
                drivingTestActive = true
                currentCheckpoint = 1
                penaltyPoints = 0
                
                createTestCheckpoint()
                
                speedLimitCheckActive = true
                CreateThread(function()
                    monitorSpeed()
                end)
                
                startCheckpointTracking()
                
                CreateThread(function()
                    checkVehicleExists()
                end)
                
                local unit = Config.Units == "kmh" and "KM/H" or "MPH"
                SendNotification(GetMessage('test_started'), 'primary', 7000)
                SendNotification(GetMessage('penalty_limit'), 'primary', 7000)
                SendNotification(GetMessage('speed_limit', {limit = testRoute[1].speedLimit, unit = unit}), 'primary', 5000)
                
                drivingTestStarted = true
            end, startPos, true)
        else
            SendNotification(GetMessage('insufficient_funds', {price = licenseConfig.price}), 'error')
        end
    end, licenseConfig.price)
end

function checkVehicleExists()
    while drivingTestActive do
        Wait(1000)
        
        if drivingTestVehicle and drivingTestStarted then
            if not DoesEntityExist(drivingTestVehicle) then
                SendNotification(GetMessage('vehicle_destroyed'), 'error')
                failDrivingTest("vehicle_destroyed")
                break
            end
        else
            break
        end
    end
end

function createTestCheckpoint()
    if testRoute and currentCheckpoint <= #testRoute then
        if testBlip then
            RemoveBlip(testBlip)
            testBlip = nil
        end
        
        local checkpointData = testRoute[currentCheckpoint]
        local coords = checkpointData.coords
        local prevSpeedLimit = currentCheckpoint > 1 and testRoute[currentCheckpoint-1].speedLimit or nil
        
        local unit = Config.Units == "kmh" and "KM/H" or "MPH"
        if prevSpeedLimit and prevSpeedLimit ~= checkpointData.speedLimit then
            SendNotification(GetMessage('speed_limit', {limit = checkpointData.speedLimit, unit = unit}), 'primary', 5000)
        elseif currentCheckpoint == 1 then
            SendNotification(GetMessage('speed_limit', {limit = checkpointData.speedLimit, unit = unit}), 'primary', 5000)
        end
        
        testBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(testBlip, 1)
        SetBlipDisplay(testBlip, 4)
        SetBlipScale(testBlip, 0.8)
        SetBlipColour(testBlip, 66)
        SetBlipAsShortRange(testBlip, false)
        SetBlipRoute(testBlip, true)
        SetBlipRouteColour(testBlip, 66)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Checkpoint " .. currentCheckpoint .. "/" .. #testRoute)
        EndTextCommandSetBlipName(testBlip)
        
        CreateThread(function()
            checkpointMarker = true
            while checkpointMarker and drivingTestActive do
                Wait(0)
                DrawMarker(21, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                    1.0, 1.0, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)
            end
        end)
    end
end

function startCheckpointTracking()
    CreateThread(function()
        while drivingTestActive do
            Wait(100)
            
            if testRoute and currentCheckpoint <= #testRoute then
                local checkpointData = testRoute[currentCheckpoint]
                local coords = checkpointData.coords
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(pos - coords)
                
                if dist < checkpointData.radius then
                    checkpointMarker = false
                    
                    if currentCheckpoint == #testRoute then
                        finishDrivingTest()
                        break
                    else
                        currentCheckpoint = currentCheckpoint + 1
                        SendNotification(GetMessage('checkpoint_complete', {current = currentCheckpoint-1, total = #testRoute}), 'success')
                        createTestCheckpoint()
                    end
                end
                
                if drivingTestVehicle and DoesEntityExist(drivingTestVehicle) and drivingTestStarted then
                    if not IsPedInVehicle(PlayerPedId(), drivingTestVehicle, false) then
                        SendNotification(GetMessage('vehicle_abandoned'), 'error')
                        failDrivingTest("vehicle_abandoned")
                        break
                    end
                else
                    if drivingTestStarted then
                        SendNotification(GetMessage('vehicle_destroyed'), 'error')
                        failDrivingTest("vehicle_destroyed")
                        break
                    end
                end
            else
                break
            end
        end
    end)
end

function monitorSpeed()
    while speedLimitCheckActive and drivingTestActive do
        Wait(1000)
        
        if drivingTestVehicle and DoesEntityExist(drivingTestVehicle) and drivingTestStarted then
            local veh = drivingTestVehicle
            local speed = GetEntitySpeed(veh)
            
            if Config.Units == "kmh" then
                speed = speed * 3.6
            else
                speed = speed * 2.236936
            end
            
            local currentLimit = testRoute[currentCheckpoint].speedLimit
            local unit = Config.Units == "kmh" and "KM/H" or "MPH"
            
            if speed > (currentLimit + 2) then
                penaltyPoints = penaltyPoints + 1
                
                if penaltyPoints == 3 then
                    SendNotification(GetMessage('speeding_fail', {limit = currentLimit, unit = unit, points = penaltyPoints}), 'error')
                    failDrivingTest("penalty_limit_reached")
                    break
                else
                    SendNotification(GetMessage('speeding_penalty', {limit = currentLimit, unit = unit, points = penaltyPoints}), 'error')
                end
                
                Wait(5000)
            end
        else
            if drivingTestStarted then
                SendNotification(GetMessage('vehicle_destroyed'), 'error')
                failDrivingTest("vehicle_destroyed")
            end
            break
        end
    end
end

function finishDrivingTest()
    if not drivingTestActive then return end
    
    local result = false
    if penaltyPoints < 3 then
        result = true
        SendNotification(GetMessage('test_passed', {points = penaltyPoints}), 'success')
        TriggerServerEvent('driving-school:server:giveLicense', 'driver', currentLicenseTest)
    else
        SendNotification(GetMessage('test_failed', {points = penaltyPoints}), 'error')
    end
    
    cleanupDrivingTest(result)
end

function cleanupDrivingTest(testSuccess)
    drivingTestActive = false
    speedLimitCheckActive = false
    checkpointMarker = false
    drivingTestStarted = false
    
    if testBlip then
        RemoveBlip(testBlip)
        testBlip = nil
    end
    
    if testSuccess then
        SendNotification(GetMessage('test_passed_final'), 'success')
        
        if instructorPed then
            DeletePed(instructorPed)
            instructorPed = nil
        end
        
        if drivingTestVehicle and DoesEntityExist(drivingTestVehicle) then
            DeleteVehicle(drivingTestVehicle)
            drivingTestVehicle = nil
        end
    else
        local drivingSchoolBlip = AddBlipForCoord(Config.DrivingSchoolPed.coords.x, Config.DrivingSchoolPed.coords.y, Config.DrivingSchoolPed.coords.z)
        SetBlipSprite(drivingSchoolBlip, 1)
        SetBlipDisplay(drivingSchoolBlip, 4)
        SetBlipScale(drivingSchoolBlip, 0.8)
        SetBlipColour(drivingSchoolBlip, 66)
        SetBlipAsShortRange(drivingSchoolBlip, false)
        SetBlipRoute(drivingSchoolBlip, true)
        SetBlipRouteColour(drivingSchoolBlip, 66)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Driving School")
        EndTextCommandSetBlipName(drivingSchoolBlip)
        
        if drivingTestVehicle and DoesEntityExist(drivingTestVehicle) then
            CreateThread(function()
                local returnMarker = true
                SendNotification(GetMessage('return_vehicle'), 'primary', 7000)
                
                while returnMarker do
                    Wait(1000)
                    local pos = GetEntityCoords(PlayerPedId())
                    local drivingSchoolCoords = vector3(Config.DrivingSchoolPed.coords.x, Config.DrivingSchoolPed.coords.y, Config.DrivingSchoolPed.coords.z)
                    local dist = #(pos - drivingSchoolCoords)
                    
                    if not DoesEntityExist(drivingTestVehicle) then
                        RemoveBlip(drivingSchoolBlip)
                        
                        if instructorPed then
                            DeletePed(instructorPed)
                            instructorPed = nil
                        end
                        
                        drivingTestVehicle = nil
                        returnMarker = false
                        break
                    end
                    
                    if dist < 30.0 and IsPedInVehicle(PlayerPedId(), drivingTestVehicle, false) then
                        RemoveBlip(drivingSchoolBlip)
                        
                        if instructorPed then
                            DeletePed(instructorPed)
                            instructorPed = nil
                        end
                        
                        if drivingTestVehicle then
                            TaskLeaveVehicle(PlayerPedId(), drivingTestVehicle, 0)
                            Wait(2000)
                            DeleteVehicle(drivingTestVehicle)
                            drivingTestVehicle = nil
                        end
                        
                        returnMarker = false
                        break
                    end
                    
                    if DoesEntityExist(drivingTestVehicle) and not IsPedInVehicle(PlayerPedId(), drivingTestVehicle, false) and dist > 30.0 then
                        Wait(5000)
                    end
                end
            end)
        else
            RemoveBlip(drivingSchoolBlip)
            
            if instructorPed then
                DeletePed(instructorPed)
                instructorPed = nil
            end
        end
    end
end

function failDrivingTest(reason)
    SendNotification(GetMessage('test_failed_reason', {reason = GetMessage(reason)}), 'error')
    cleanupDrivingTest(false)
end

CreateThread(function()
    if Config.Blip.enabled then
        local blip = AddBlipForCoord(Config.DrivingSchoolPed.coords.x, Config.DrivingSchoolPed.coords.y, Config.DrivingSchoolPed.coords.z)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipDisplay(blip, Config.Blip.display)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipColour(blip, Config.Blip.color)
        SetBlipAsShortRange(blip, Config.Blip.shortRange)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.name)
        EndTextCommandSetBlipName(blip)
    end
    
    local pedModel = Config.DrivingSchoolPed.model
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end
    
    local npc = CreatePed(4, pedModel, Config.DrivingSchoolPed.coords.x, Config.DrivingSchoolPed.coords.y, Config.DrivingSchoolPed.coords.z - 1.0, Config.DrivingSchoolPed.coords.w, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    if Config.DrivingSchoolPed.scenario then
        TaskStartScenarioInPlace(npc, Config.DrivingSchoolPed.scenario, 0, true)
    end
    
    local theoryOption = {
        name = 'driving_school_theory',
        icon = Config.DrivingSchoolPed.target.icon,
        label = Config.DrivingSchoolPed.target.label,
        distance = Config.DrivingSchoolPed.target.distance,
        onSelect = function()
            startTheoryTest()
        end
    }
    
    if Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(npc, {theoryOption})
    elseif Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(npc, {

            options = {
                {
                    type = "client",
                    icon = theoryOption.icon,
                    label = theoryOption.label,
                    action = theoryOption.onSelect,
                }
            },
            distance = theoryOption.distance
        })
    end
    
    local instructorModel = Config.DrivingInstructorPed.model
    RequestModel(instructorModel)
    while not HasModelLoaded(instructorModel) do
        Wait(10)
    end
    
    local instructor = CreatePed(4, instructorModel, Config.DrivingInstructorPed.coords.x, Config.DrivingInstructorPed.coords.y, Config.DrivingInstructorPed.coords.z - 1.0, Config.DrivingInstructorPed.coords.w, false, true)
    FreezeEntityPosition(instructor, true)
    SetEntityInvincible(instructor, true)
    SetBlockingOfNonTemporaryEvents(instructor, true)
    
    if Config.DrivingInstructorPed.scenario then
        TaskStartScenarioInPlace(instructor, Config.DrivingInstructorPed.scenario, 0, true)
    end
    
    if Config.Target == 'ox' then
        local targets = {}
        for licType, licConfig in pairs(Config.LicenseTypes) do
            local targetLabel = licConfig.target.label or (licConfig.label .. ' ($' .. licConfig.price .. ')')
            table.insert(targets, {
                name = 'driving_test_' .. licType,
                icon = licConfig.target.icon or Config.DrivingInstructorPed.target.icon,
                label = targetLabel,
                distance = Config.DrivingInstructorPed.target.distance,
                onSelect = function()
                    startDrivingTest(licType)
                end
            })
        end
        exports.ox_target:addLocalEntity(instructor, targets)
    elseif Config.Target == 'qb' then
        local options = {}
        for licType, licConfig in pairs(Config.LicenseTypes) do
            local targetLabel = licConfig.target.label or (licConfig.label .. ' ($' .. licConfig.price .. ')')
            table.insert(options, {
                type = "client",
                icon = licConfig.target.icon or Config.DrivingInstructorPed.target.icon,
                label = targetLabel,
                action = function()
                    startDrivingTest(licType)
                end
            })
        end
        exports['qb-target']:AddTargetEntity(instructor, {
            options = options,
            distance = Config.DrivingInstructorPed.target.distance
        })
    end
end)