Config = {}

Config.Database = 'oxmysql' -- oxmysql/mysql-async/ghmattimysql

Config.Debug = false -- Enable debug
Config.DebugSQL = false -- Enable SQL debug
Config.DiscordLog = true -- Enable discord logging
Config.AllowOnlyOne = true -- if true, player will be able to use only 1 code
Config.Webhook = 'https://discord.com/api/webhooks/1226478697415053342/HPxf2dBbDkDogLmsaXjKFj5W5oWg80Oe7TKpCFLD4aC4Mj6aXXYbJIqeqKGO-bmkgb4j'

Config.CommandName = 'code'

Config.Codes = {
    [1] = {
        code = 'Domas', -- Code that will used with Config.CommandName
        unique = false, -- If true, only one persion can use it
        times = false, -- unique cannot be used if this is true, it's how many times code can be used by players
        reward = {
            type = 'money', -- or item
            amount = 25000,
        }
    },
    [2] = {
        code = 'Scripts',
        unique = false,
        times = false,
        reward = {
            type = 'item',
            item = 'weapon_pistol',
            amount = 1,
        }
    },
}

Config.Text = {
    ['only_one'] = 'You have already used a code before.',
    ['already_used'] = 'You have already used this code.',
    ['no_code'] = 'Invalid code.',
    ['active_new'] = 'New Code Activation!',
    ['active_text'] = 'Code was activated!',
    ['active_player'] = 'Player: ',
    ['active_code'] = 'Code: ',
    
}

function AddMoney(playerId, amount) -- Add your own logic if not using ESX
    ESX = exports["es_extended"]:getSharedObject()
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.addMoney(amount)
    Debug("Giving money: "..amount.." to player: "..playerId)
    Notify("You used code and got "..amount..' €', playerId)
end


function GiveItem(playerId, itemName, quantity) -- Add your own logic if not using ESX
    ESX = exports["es_extended"]:getSharedObject()
    local xPlayer = ESX.GetPlayerFromId(playerId)
    print("playerId: "..playerId)
    xPlayer.addInventoryItem(itemName, quantity)
    Debug("Giving item: "..itemName.." x"..quantity.." to player: "..playerId)
    Notify("You used code and got "..itemName, playerId)
end

function Notify(text, playerId)
    TriggerClientEvent('esx:showNotification', playerId, text, 'info', 7000)
end