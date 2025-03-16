local QBCore = exports['qb-core']:GetCoreObject()

local function SendNotification(source, message, type)
    if Config.Notify.system == "qb" then
        TriggerClientEvent('QBCore:Notify', source, message, type or 'success')
    elseif Config.Notify.system == "ox" then
        TriggerClientEvent('ox_lib:notify', source, {
            description = message,
            type = type or 'success'
        })
    end
end

QBCore.Functions.CreateCallback('driving-school:server:checkMoney', function(source, cb, price)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.money.cash >= price then
        Player.Functions.RemoveMoney('cash', price)
        
        local message = Config.Notify.messages.payment_success:gsub("{price}", price)
        SendNotification(source, message, 'success')
        
        cb(true)
    else
        local message = Config.Notify.messages.insufficient_funds:gsub("{price}", price)
        SendNotification(source, message, 'error')
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('driving-school:server:hasPassedTheory', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if Player.PlayerData.metadata["theorytestpassed"] then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('driving-school:server:saveTheoryResult', function(passed)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if passed then
        Player.Functions.SetMetaData("theorytestpassed", true)
    end
end)

RegisterNetEvent('driving-school:server:giveLicense', function(licenseType, licenseClass)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if licenseType == 'driver' then
        local licenses = Player.PlayerData.metadata["licences"] or {}
        local notificationMessage = ""
        
        if licenseClass == "A" then
            licenses["motorcycle"] = true
            notificationMessage = Config.Notify.messages.license_A
        elseif licenseClass == "B" then
            licenses["driver"] = true
            notificationMessage = Config.Notify.messages.license_B
        elseif licenseClass == "C" then
            licenses["truck"] = true
            notificationMessage = Config.Notify.messages.license_C
        elseif licenseClass == "D" then
            licenses["bus"] = true
            notificationMessage = Config.Notify.messages.license_D
        end
        
        Player.Functions.SetMetaData("licences", licenses)
        
        if notificationMessage ~= "" then
            SendNotification(src, notificationMessage, 'success')
        end
    end
end)