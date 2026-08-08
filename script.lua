Config =
        Config or
        {
            Team = "Pirates",
            Configuration = {
                HideallPath = false,
                blackscreen = true,
                HideGui = false,
                HopWhenIdle = true,
                FpsBoost = true,
                LockFPS = 15,
                ["IdleCheck"] = 150, -- every (x) seconds if not moving rejoin
            },
            Items = {
                -- Melees
                AutoFullyMelees = true,
                -- Swords
                Saber = true,
                CursedDualKatana = false,
                -- Guns
                SoulGuitar = false,
                -- Upgrades

                RaceV2 = false,
                AutoFarmFruitMastery = false,
                AutoEatFruit = 1,
                Eatlist = {"Spider-Spider"}
            },
            Settings = {
                StayInSea2UntilHaveDarkFragments = false, -- bat cai nay se hop tim darkbeard / turn this on to force hop for darkbeard ( for sg )
                ["Fragments"] = 10000, -- Auto farm fragments until you have 5000 fragments to buy the chip
                ["Devil Fruit Sniper Name"] = "Kitsune-Kitsune", -- ten fruit muon snipe (vi du "Spider-Spider")
                ["Devil Fruit Sniper"] = false -- bat/tat auto mua fruit khi co stock
            }
}
repeat
    task.wait(0.5)
until game:IsLoaded()


task.spawn(function()
    while true do
        setfpscap(Config.Configuration.LockFPS or 10)
        task.wait(5)
    end
end)

-- game.ReplicatedStorage.Remotes.CommF_:InvokeServer('SetTeam', Config.Configuration.SetTeam or 'Pirates')

cloneref = cloneref or clonereference or function(x) return x end
Services = setmetatable({}, {__index = function(self, name)
    local s, c = pcall(function() return cloneref(game:GetService(name)) end)
    if s then rawset(self, name, c) return c
    else error("Invalid Roblox Service: " .. tostring(name))
    end
end})
TeleportService = Services.TeleportService
GuiService = Services.GuiService

function GetGuideServerData()
    local ok, env = pcall(function()
        return getsenv and getsenv(game.ReplicatedStorage.GuideModule)
    end)
    if ok and env and env._G and env._G.ServerData then
        return env._G.ServerData
    end
    return {ExpBoost = 0, InCombat = false}
end
function CheckKick()
    if GuiService.ErrorMessageChanged then
        GuiService.ErrorMessageChanged:Connect((newcclosure or function(f) return f end)(function()
            if GuiService:GetErrorType() == Enum.ConnectionError.DisconnectErrors then
                while true do TeleportService:TeleportReconnect() task.wait(5) end
            end
        end))
    end
end
CheckKick()
print = function() end
repeat
    wait()
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer('SetTeam', 'Pirates')
until game.Players.LocalPlayer.Character
    if os.time() >= 1756319996 then
        -- while true do end
    end

    local checkdone = false

    local LogService = game:GetService("LogService")
    local GameName = "Blox Fruit"

    pcall(
        function()
            GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end
    )
    local StartTime = os.time()

    local Traces = {}

function Build(Error)
        warn("Error\n\n", Error, "\n\n")
        local Result = {
            content = "<@12313> " .. tostring(Error) or " " .. tostring(game.Players.LocalPlayer) or "",
            embeds = {
                {
                    title = GameName,
                    description = game.PlaceId .. " | " .. game.JobId,
                    color = 15642286,
                    fields = {
                        {
                            name = "Error Details",
                            value = Error
                        },
                        {
                            name = "Player Info",
                            value = "Level: " .. ScriptStorage.PlayerData.Level
                        },
                        {
                            name = "Script Details",
                            value = GetCurrentDateTime() ..
                                " | " ..
                                    DispTime(os.time() - StartTime, true) ..
                                        " after execution\nMain task: " ..
                                            (ScriptStorage.Task.MainTask or "n/a") ..
                                                " ( " ..
                                                    (ScriptStorage.Task["MainTask-d"] and
                                                        DispTime(os.time() - ScriptStorage.Task["MainTask-d"], true) or
                                                        "n/a") ..
                                                        " ) \nSub task: " ..
                                                            (ScriptStorage.Task.SubTask or "n/a") ..
                                                                " ( " ..
                                                                    (ScriptStorage.Task["SubTask-d"] and
                                                                        DispTime(
                                                                            os.time() - ScriptStorage.Task["SubTask-d"],
                                                                            true
                                                                        ) or
                                                                        "n/a") ..
                                                                        " )"
                        },
                        {
                            name = "Traceback",
                            value = (function()
                                local Result = ""

                                for Index, Content in ScriptStorage.Tracebacks do
                                    if #ScriptStorage.Tracebacks > 20 then
                                        break
                                    end

                                    Result = Result .. (Content or "null") .. "\n"
                                end

                                return Result ~= "" and Result or "... ( empty list ) "
                            end)()
                        }
                    },
                    author = {
                        name = tostring(game.Players.LocalPlayer)
                    }
                }
            },
            attachments = {}
        }

        for Index, Value in Result.embeds[1].fields do
            Value.value = "```" .. Value.value .. "```"
        end
        return Result
    end

    function Report(Message)
        if true then
            if Traces[Message] then
                return
            end
            Traces[Message] = true
    
            local Body = game:GetService("HttpService"):JSONEncode(Build(Message))
    
            local AffectedIndexes = {0, 0, 0, 0}
    
            request({
                Url = "https://discord.com/api/webhooks/1510909753969213460/e0c9BKmyJmWQhP5nl9diz13QuyJWAU5CFXbb_zrPkoNnjVoK7hUlItNHPAPThH3NDR_w",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = Body
            })
        end
    end
