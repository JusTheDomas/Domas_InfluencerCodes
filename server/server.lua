RegisterCommand(Config.CommandName, function(source, args)
    local playerId = source
    local code = args[1]

    if code then
        ActivateCode(playerId, code)
    else
        TriggerClientEvent('chatMessage', playerId, "^1Error: ^7Invalid usage. Syntax: /" .. Config.CommandName .. " [code]")
    end
end, false)

-- Register an event handler for when the resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        InsertCodesOnResourceStart()
    end
end)

-- Server-side event handler for checking referral data
RegisterServerEvent('Domas_IC:checkReferralData')
AddEventHandler('Domas_IC:checkReferralData', function(player)
    local playerId = player
    local playerIdentifier = GetPlayerIdentifier(playerId)

    local query = "SELECT ref_money, ref_times FROM Domas_IC_Referrals WHERE owner = '"..playerIdentifier.."'"
    local parameters = {
        ['@owner'] = playerIdentifier
    }
    
    ExecuteSql(query, parameters, function(result)
        if result and #result > 0 then
            local refData = result[1]
            local moneyToGive = refData.ref_money
            local timesUsed = refData.ref_times
            
            if moneyToGive > 0 then
                AddMoney(playerId, moneyToGive)
                local notificationText = string.format(Config.Text['referral_notification'], timesUsed, moneyToGive)
                Notify(notificationText)
                Log2Discord("I'm to lazy to program this", playerId, 2, moneyToGive)
                
                -- Reset referral data
                local resetQuery = "UPDATE Domas_IC_Referrals SET ref_money = 0, ref_times = 0 WHERE owner = '"..playerIdentifier.."'"
                ExecuteSql(resetQuery, parameters, function(rowsChanged)
                    Debug("Rows changed after resetting referral data: " .. tostring(rowsChanged))
                    if type(rowsChanged) == "number" and rowsChanged > 0 then
                        Debug("Referral data reset for owner: " .. playerIdentifier)
                    else
                        Debug("Failed to reset referral data for owner: " .. playerIdentifier)
                    end
                end)
            end
        end
    end)
end)