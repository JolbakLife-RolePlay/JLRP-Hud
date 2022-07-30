local ResetStress = false

Framework.RegisterCommand('money', 'user', function(xxPlayer, args, showError)
    local cashamount = xxPlayer.getAccount('money').money
    TriggerClientEvent('JLRP-Hud:Client:ShowAccounts', xxPlayer.source, 'cash', cashamount)
end, false, {help = "Check cash/money balanace"})

Framework.RegisterCommand('bank', 'user', function(xxPlayer, args, showError)
    local bankamount = xxPlayer.getAccount('bank').money
    TriggerClientEvent('JLRP-Hud:Client:ShowAccounts', xxPlayer.source, 'bank', bankamount)
end, false, {help = "Check bank balanace"})


Framework.RegisterServerCallback('JLRP-Hud:Server:getMenu', function(source, cb)
    cb(Config.Menu)
end)
