local ResetStress = false

Framework.RegisterCommand('money', 'user', function(xxPlayer, args, showError)
    local cashamount = xxPlayer.getAccount('money').money
    TriggerClientEvent('JLRP-Hud:Client:ShowAccounts', xxPlayer.source, 'cash', cashamount)
end, false, {help = "Check cash/money balanace"})

Framework.RegisterCommand('bank', 'user', function(xxPlayer, args, showError)
    local bankamount = xxPlayer.getAccount('bank').money
    TriggerClientEvent('JLRP-Hud:Client:ShowAccounts', xxPlayer.source, 'bank', bankamount)
end, false, {help = "Check bank balanace"})

RegisterNetEvent('JLRP-Hud:Server:GainStress', function(amount)
    local src = source
    local xPlayer = Framework.GetPlayerFromId(src)
    local newStress
    if not xPlayer or (Config.DisablePoliceStress and xPlayer.getJob().name == 'police') then return end
    if not ResetStress then
        if not xPlayer.getMetadata('stress') then
            xPlayer.setMetadata('stress', 0, true)
        end
        newStress = xPlayer.getMetadata('stress') + amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    xPlayer.setMetadata('stress', newStress, true)
    TriggerClientEvent('JLRP-Hud:Client:UpdateStress', src, newStress)
	xPlayer.showNotification(_U('stress_gain'), 'error', 1500)
end)

RegisterNetEvent('JLRP-Hud:Server:RelieveStress', function(amount)
    local src = source
    local xPlayer = Framework.GetPlayerFromId(src)
    local newStress
    if not xPlayer then return end
    if not ResetStress then
        if not xPlayer.getMetadata('stress') then
            xPlayer.setMetadata('stress', 0, true)
        end
        newStress = xPlayer.getMetadata('stress') - amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    xPlayer.setMetadata('stress', newStress, true)
    TriggerClientEvent('JLRP-Hud:Client:UpdateStress', src, newStress)
	xPlayer.showNotification(_U('stress_removed'), 'info', 1500)
end)

Framework.RegisterServerCallback('JLRP-Hud:Server:getMenu', function(source, cb)
    cb(Config.Menu)
end)
