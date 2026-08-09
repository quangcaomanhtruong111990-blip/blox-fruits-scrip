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
