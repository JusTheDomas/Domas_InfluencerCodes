function Debug(text)
    if Config.Debug then
        print("^3[DEBUG] "..text.."^0")
    end
end

function DebugSQL(text)
    if Config.DebugSQL then
        print("^5[DEBUG SQL] "..text.."^0")
    end
end

function ExecuteSql(query, params, callback)
    DebugSQL("Executing SQL query: " .. query)

    if Config.Database == "oxmysql" then
        if exports.oxmysql then
            exports.oxmysql:execute(query, {}, callback)
        else
            DebugSQL("oxmysql is not exported. Make sure you have it installed.")
        end
    elseif Config.Database == "mysql-async" then
        if MySQL.Async then
            MySQL.Async.execute(query, {}, callback)
        else
            DebugSQL("mysql-async is not available. Make sure you have it installed.")
        end
    elseif Config.Database == "ghmattimysql" then
        if exports.ghmattimysql then
            exports.ghmattimysql:execute(query, {}, callback)
        else
            DebugSQL("ghmattimysql is not exported. Make sure you have it installed.")
        end
    else
        DebugSQL("Invalid database option in Config.Database")
    end
end

-- Function to activate a code for a player
function ActivateCode(playerId, code)
    local query = ("SELECT * FROM Domas_IC_Codes WHERE code = '%s';"):format(code)
    local identifier = GetPlayerIdentifierByType(playerId, 'license')

    -- Execute SQL query to check the validity of the code
    ExecuteSql(query, {}, function(result)
        if result[1] then
            local codeData = result[1]

            -- Check if the code has already been activated by this player
            local activationQuery = ("SELECT * FROM Domas_IC_Players WHERE player = '%s' AND code = '%s';"):format(identifier, code)

            -- Execute SQL query to check if the code has been activated by this player
            ExecuteSql(activationQuery, {}, function(activationResult)
                if not activationResult[1] then
                    -- Code has not been activated by this player, proceed with activation
                    if Config.AllowOnlyOne then
                        -- Check if the player has activated any codes before
                        local previousActivationQuery = ("SELECT * FROM Domas_IC_Players WHERE player = '%s';"):format(identifier)
                        ExecuteSql(previousActivationQuery, {}, function(previousResult)
                            if not previousResult[1] then
                                -- Player has not activated any codes before, proceed with activation
                                ProcessCodeActivation(playerId, identifier, codeData)
                            else
                                -- Player has already activated a code before (allowOnlyOne is true)
                                Notify(Config.Text['only_one'], playerId)
                            end
                        end)
                    else
                        -- allowOnlyOne is false, proceed with activation
                        ProcessCodeActivation(playerId, identifier, codeData)
                    end
                else
                    -- Code has already been activated by this player
                    Debug("Code has already been activated by this player.")
                    Notify(Config.Text['already_used'], playerId)
                end
            end)
        else
            -- Invalid code
            Debug("Invalid code.")
            Notify(Config.Text['no_code'], playerId)
        end
    end)
end

-- Function to process code activation (handle reward and logging)
function ProcessCodeActivation(playerId, identifier, codeData)
    -- Register the code activation for the player
    RegisterPlayerActivation(identifier, codeData.code)

    -- Handle reward based on codeData
    HandleReward(codeData.code, playerId)

    -- Log activation to Discord or other logging system
    Log2Discord(codeData.code, playerId)

    -- Update remaining uses if applicable
    if codeData.times then
        local updateQuery = ("UPDATE Domas_IC_Codes SET times = times - 1 WHERE code = '%s';"):format(codeData.code)
        ExecuteSql(updateQuery, {}, function(rowsChanged)
            if type(rowsChanged) == "number" and rowsChanged > 0 then
                Debug("Code usage count decremented.")
            else
                Debug("Failed to decrement code usage count.")
            end
        end)
    end
end

-- Define a function to handle rewards based on the code
function HandleReward(code, playerId)
    local rewardData = GetRewardByCode(code)

    if rewardData then
        if rewardData.type == 'money' then
            -- Handle money reward
            local amount = rewardData.amount
            AddMoney(playerId, amount)
        elseif rewardData.type == 'item' then
            -- Handle item reward
            local item = rewardData.item
            local amount = rewardData.amount
            GiveItem(playerId, item, amount)
        elseif rewardData.type == 'null' then
            -- Handle null reward (no action needed)
            Debug("Null reward - no action needed")
        else
            -- Unknown reward type
            Debug("Unknown reward type:", rewardData.type)
        end
    else
        -- No reward data found for the code
        Debug("No reward data found for code:", code)
    end
end


-- Define a function to get reward data by code
function GetRewardByCode(code)
    for _, data in pairs(Config.Codes) do
        if data.code == code then
            return data.reward  -- Return the reward data associated with the code
        end
    end

    return nil  -- Return nil if code is not found in Config.Codes
end

-- Function to get the remaining uses of a code
function GetRemainingUses(code)
    local query = ("SELECT times FROM Domas_IC_Codes WHERE code = '%s';"):format(code)

    local remainingUses = 0
    ExecuteSql(query, {}, function(result)
        if result[1] and result[1].times then
            remainingUses = tonumber(result[1].times)
        end
    end)

    return remainingUses
end



function RegisterPlayerActivation(identifier, code)
    local query = ("INSERT INTO Domas_IC_Players (player, code) VALUES ('%s', '%s');"):format(
        identifier,
        code
    )

    ExecuteSql(query, {}, function(result)
        if result.affectedRows and result.affectedRows > 0 then
            Debug("Registered player activation for code: " .. code)
        else
            Debug("Failed to register player activation for code: " .. code)
        end
    end)
end



function InsertCodeIntoDatabase(codeData)
    local code = codeData.code
    local unique = codeData.unique and 1 or 0 -- Convert boolean to 1 or 0 for SQL
    local times = codeData.times

    local timesValue = "NULL" -- Default to NULL for unlimited times
    if type(times) == "number" then
        timesValue = tostring(times) -- Convert number to string for SQL
    end

    local query = ("INSERT INTO Domas_IC_Codes (code, unique_code, times) VALUES ('%s', %d, %s);"):format(
        code,
        unique,
        timesValue
    )

    ExecuteSql(query, {}, function(rowsChanged)
        Debug("Inserted code into database.")
    end)
end


-- Function to insert codes from Config into the database on resource start
function InsertCodesOnResourceStart()
    for _, codeData in pairs(Config.Codes) do
        local code = codeData.code
        local unique = codeData.unique and 1 or 0 -- Convert boolean to 1 or 0 for SQL
        local times = codeData.times or "NULL" -- Use NULL for unlimited times

        -- Check if the code already exists in the database
        local query = ("SELECT * FROM Domas_IC_Codes WHERE code = '%s';"):format(code)

        ExecuteSql(query, {}, function(result)
            if not result[1] then
                -- Code does not exist in the database, insert it
                local insertQuery = ("INSERT INTO Domas_IC_Codes (code, unique_code, times) VALUES ('%s', %d, %s);"):format(
                    code,
                    unique,
                    times
                )

                ExecuteSql(insertQuery, {}, function(rowsChanged)
                    Debug("Inserted code '" .. code .. "' into database.")
                end)
            else
                Debug("Code '" .. code .. "' already exists in the database, skipping insertion.")
            end
        end)
    end
end

function Log2Discord(kodas, playerId)
    local name = GetPlayerName(playerId)
    if Config.DiscordLog then
        local embeds = {
            {
                ["title"]= Config.Text['active_new'],
                ["type"]="rich",
                ["color"] = 1770588,
                ["footer"]=  {
                    ["text"]= Config.Text['active_text'],
                },
                ["fields"] = {
                    {
                        name = Config.Text['active_player']..name,
                        value = Config.Text['active_code']..kodas,
                    },
                }
            }
        }
        PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
    end
end

