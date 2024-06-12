Config = {}

Config.Database = 'oxmysql' -- oxmysql/mysql-async/ghmattimysql

Config.Debug = false -- Enable debug
Config.DebugSQL = false -- Enable SQL debug
Config.DiscordLog = true -- Enable discord logging
Config.AllowOnlyOne = false -- if true, player will be able to use only 1 code
Config.Webhook = 'https://discord.com/api/webhooks/...'

Config.CommandName = 'code'

Config.Codes = {
    [1] = {
        code = 'Domas', -- Code that will used with Config.CommandName
        unique = false, -- If true, only one persion can use it
        times = false, -- unique cannot be used if this is true, it's how many times code can be used by players
        reward = {
            type = 'money', -- or item
            amount = 25000,
        },
        referral = {
            enabled = true,
            owner = 'license:123', -- Identifier of player who will get the reward bellow when this code is used.
            reward = 1000, -- Money will be added to the owners account
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
        },
        referral = {
            enabled = false,
            owner = 'license:123', -- Identifier of player who will get the reward bellow when this code is used.
            reward = 1000, -- Money will be added to the owners account
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
    ['referral_notification'] = 'Your referral code has been used %d times and you have earned %d €.',
    ['referral_reward'] = 'Referral Reward',
    ['player_reward'] = 'Player was rewarded (Referrals)',
    ['amount'] = 'Player got from referrals',
    ['currency'] = '€',
    
}

function AddMoney(playerId, amount)
    if GetResourceState('es_extended') == 'started' then
        Debug("You're using ESX!")
        ESX = exports["es_extended"]:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(playerId)
        xPlayer.addMoney(amount)
        Debug("Giving money: "..amount.." to player: "..playerId)
        Notify("You used code and got "..amount..' €', playerId)
    elseif GetResourceState('qb-core') == 'started' then 
        Debug("You're using QB-Core!")
        QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(playerId)
        Player.Functions.AddMoney('cash', amount, 'Admin give money')
        Debug("Giving money: "..amount.." to player: "..playerId)
        Notify("You used code and got "..amount..' €', playerId)
    else
        Debug("You're using non supported framework, please edit the functions (AddMoney) for rewards at config.lua file! (line 77)")
    end
end


function GiveItem(playerId, itemName, quantity)
    if GetResourceState('es_extended') == 'started' then
        Debug("You're using ESX!")
        ESX = exports["es_extended"]:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(playerId)
        xPlayer.addInventoryItem(itemName, quantity)
        Debug("Giving item: " .. itemName .. " x" .. quantity .. " to player: " .. playerId)
        Notify("You used code and got " .. itemName, playerId)
    elseif GetResourceState('qb-core') == 'started' then
        Debug("You're using QB-Core!")
        QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(playerId)
        Player.Functions.AddItem(itemName, quantity)
        Debug("Giving item: " .. itemName .. " x" .. quantity .. " to player: " .. playerId)
        Notify("You used code and got " .. itemName, playerId)
    else
        Debug("You're using non supported framework, please edit the functions (GiveItem) for rewards at config.lua file! (line 98)")
    end
end


function Notify(text, playerId)
    if GetResourceState('es_extended') == 'started' then
        TriggerClientEvent('esx:showNotification', playerId, text, 'info', 7000)
    elseif GetResourceState('qb-core') == 'started' then
        TriggerClientEvent('QBCore:Notify', playerId, text)
    else
        Debug("You're using non supported framework, please edit the functions (Notify) for rewards at config.lua file! (line 109)")
    end
end