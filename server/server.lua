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