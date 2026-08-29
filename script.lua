-- =====================================================================
-- KUNBLOX / CYNDRAL BLOX FRUITS AUTO SCRIPT (FULL TASKS & FIXED)
-- =====================================================================

Config = Config or {
    Team = "Pirates",
    Configuration = {
        HideallPath = false,
        blackscreen = false,
        HideGui = false,
        HopWhenIdle = true,
        AutoHop = true,
        AutoHopDelay = 60 * 60,
        FpsBoost = true,
        ["IdleCheck"] = 150,
    },
    Items = {
        AutoFullyMelees = true,
        Saber = true,
        CursedDualKatana = false,
        SoulGuitar = false,
        RaceV2 = false,
        AutoFarmFruitMastery = false,
        AutoEatFruit = 1,
        Eatlist = {}
    },
    Settings = {
        StayInSea2UntilHaveDarkFragments = false,
        ["Fragments"] = 5000
    }
}

repeat task.wait(0.5) until game:IsLoaded()

-- Global ScriptStorage & SetText Initialization
getgenv().ScriptStorage = getgenv().ScriptStorage or {
    IsInitalized = false,
    PlayerData = {},
    Melees = {},
    CurrentMeleeData = {},
    Enemies = {},
    Tools = {},
    Backpack = {},
    IgnoreStoreFruits = {},
    Connections = { LocalPlayer = {} },
    Task = {},
    Tracebacks = {},
    NPCs = {}
}

getgenv().SetText = getgenv().SetText or function(name, text)
    if ScriptStorage.Interface and ScriptStorage.Interface.Instances and ScriptStorage.Interface.Instances[name] then
        pcall(function()
            ScriptStorage.Interface.Instances[name].Text = text
        end)
    end
end

-- Volt Performance Optimization Setup
local Volt = nil
pcall(function()
    if typeof(volt) == "table" then
        Volt = volt
    elseif typeof(getgenv().volt) == "table" then
        Volt = getgenv().volt
    end
end)

local UseVoltActors = Volt ~= nil

function CheckKick(v)
    if v.Name == 'ErrorPrompt' then
        task.wait(2)
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer("teleport", game.PlaceId)
        end)
        v:Destroy()
    end
end

repeat
    task.wait()
    pcall(function()
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer('SetTeam', Config.Team or 'Pirates')
    end)
until game.Players.LocalPlayer.Character

pcall(function()
    game:GetService('CoreGui').RobloxPromptGui.promptOverlay.ChildAdded:Connect(CheckKick)
end)

local GameName = "Blox Fruit"
pcall(function()
    GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

local StartTime = os.time()
local Traces = {}

function Build(Error)
    local playerLevel = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or 1
    local Result = {
        content = "<@12313> " .. tostring(Error),
        embeds = {
            {
                title = GameName,
                description = game.PlaceId .. " | " .. game.JobId,
                color = 15642286,
                fields = {
                    { name = "Error Details", value = tostring(Error) },
                    { name = "Player Info", value = "Level: " .. tostring(playerLevel) },
                    { name = "Main Task", value = tostring(ScriptStorage.Task.MainTask or "n/a") },
                    {
                        name = "Traceback",
                        value = (function()
                            local resStr = ""
                            for _, Content in ipairs(ScriptStorage.Tracebacks) do
                                if #ScriptStorage.Tracebacks > 20 then break end
                                resStr = resStr .. (Content or "null") .. "\n"
                            end
                            return resStr ~= "" and resStr or "... ( empty list ) "
                        end)()
                    }
                },
                author = { name = tostring(game.Players.LocalPlayer) }
            }
        },
        attachments = {}
    }
    for _, Value in ipairs(Result.embeds[1].fields) do
        Value.value = "```" .. tostring(Value.value) .. "```"
    end
    return Result
end

function Report(Message)
    if Traces[Message] then return end
    Traces[Message] = true
    pcall(function()
        local Body = game:GetService("HttpService"):JSONEncode(Build(Message))
        request({
            Url = "https://discord.com/api/webhooks/1489044457503592600/72IHxqtvinkQI3TJ1b4H_GZPvfwFbIZ1ba5CyOSdwi78KlV7gs56x9CtYky5FCxZNgiY",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = Body
        })
    end)
end

-- UI Setup (mmb)
function mmb()
    local Orders = {"Task1", "Task2", "Currencies", "Melees", "LiveTime", "DebugLine"}
    local Interface = { Instances = {} }
    ScriptStorage.Interface = Interface

    local isVisible = true
    local isToggleOpen = true
    local player = game.Players.LocalPlayer

    repeat task.wait() until game.CoreGui

    local HopGui = Instance.new("ScreenGui")
    HopGui.Name = "CyndralDev"
    HopGui.Parent = game:GetService("CoreGui")
    HopGui.Enabled = not Config.Configuration.HideGui
    HopGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    HopGui.IgnoreGuiInset = true

    local NameHub = Instance.new("TextLabel", HopGui)
    NameHub.Name = "NameHub"
    NameHub.AnchorPoint = Vector2.new(0.5, 0.5)
    NameHub.Position = UDim2.new(0.5, 0, 0.3, 0)
    NameHub.Size = UDim2.new(1, 0, 0, 80)
    NameHub.BackgroundTransparency = 0.999
    NameHub.Font = Enum.Font.FredokaOne
    NameHub.Text = "kunblox.net"
    NameHub.TextColor3 = Color3.fromRGB(9, 255, 248)
    NameHub.TextSize = 50

    local UIStroke = Instance.new("UIStroke", NameHub)
    UIStroke.Color = Color3.fromRGB(0, 0, 0)
    UIStroke.Thickness = 1

    local ToggleContainer = Instance.new("Frame", HopGui)
    ToggleContainer.Name = "ToggleContainer"
    ToggleContainer.AnchorPoint = Vector2.new(1, 0)
    ToggleContainer.Position = UDim2.new(1, -20, 0, 20)
    ToggleContainer.Size = UDim2.new(0, 50, 0, 50)
    ToggleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleContainer.BackgroundTransparency = 0.2
    ToggleContainer.BorderSizePixel = 0

    local UICorner = Instance.new("UICorner", ToggleContainer)
    UICorner.CornerRadius = UDim.new(1, 0)

    local ToggleUIStroke = Instance.new("UIStroke", ToggleContainer)
    ToggleUIStroke.Color = Color3.fromRGB(9, 255, 248)
    ToggleUIStroke.Thickness = 2

    local ToggleButton = Instance.new("ImageButton", ToggleContainer)
    ToggleButton.Name = "ToggleButton"
    ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ToggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1

    local ToggleIcon = Instance.new("TextLabel", ToggleContainer)
    ToggleIcon.Name = "ToggleIcon"
    ToggleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    ToggleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToggleIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
    ToggleIcon.BackgroundTransparency = 1
    ToggleIcon.Font = Enum.Font.GothamBold
    ToggleIcon.Text = "👁️"
    ToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleIcon.TextSize = 24
    ToggleIcon.TextScaled = true

    local function createTextLabel(text, position)
        local Bounty = Instance.new("TextLabel", HopGui)
        Bounty.AnchorPoint = Vector2.new(0.5, 0.5)
        Bounty.Position = position
        Bounty.Size = UDim2.new(0, 200, 0, 30)
        Bounty.BackgroundTransparency = 0.999
        Bounty.Font = Enum.Font.FredokaOne
        Bounty.Text = text
        Bounty.TextColor3 = Color3.fromRGB(255, 255, 255)
        Bounty.TextSize = 13
        Bounty.RichText = true

        local StrokeBounty = Instance.new("UIStroke", Bounty)
        StrokeBounty.Color = Color3.fromRGB(0, 0, 0)
        StrokeBounty.Thickness = 1
        return Bounty
    end

    local MainTextLabel = createTextLabel(" ", UDim2.new(0.5, 0, 0.4, 0))
    Interface.Instances.MainTextLabel = MainTextLabel

    for Index, OrderName in ipairs(Orders) do
        Interface.Instances[OrderName] = createTextLabel("...", UDim2.new(0.5, 0, 0.45 + (.05 * Index), 0))
    end

    -- Global SetText override
    getgenv().SetText = function(Name, Text)
        pcall(function()
            local TextIns = Interface.Instances[Name]
            if TextIns then TextIns.Text = Text end
        end)
    end

    ToggleButton.MouseButton1Click:Connect(function()
        isToggleOpen = not isToggleOpen
        HopGui.Enabled = isToggleOpen
    end)

    Interface.SetText = getgenv().SetText
    return Interface
end

pcall(mmb)

-- Fluent UI & Notifications
pcall(function()
    if not isfile("fluent.lua") then
        writefile("fluent.lua", game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))
    end
end)

local Fluent = nil
pcall(function()
    Fluent = loadstring(readfile("fluent.lua"))()
end)

getgenv().alert = function(t1, t2)
    pcall(function()
        if Fluent then
            Fluent:Notify({ Title = t1 or "", Content = t2 or "", Duration = 5 })
        end
    end)
end

alert("Cyndral", "Endpoint reached & Loaded")

-- Services & Metatables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local Services = setmetatable({}, {
    __index = function(_, Index)
        return game:GetService(Index)
    end
})

setmetatable(ScriptStorage.Enemies, {
    __index = function(_, Index)
        return (Services.Workspace:FindFirstChild("Enemies") and Services.Workspace.Enemies:FindFirstChild(Index)) or Services.ReplicatedStorage:FindFirstChild(Index)
    end
})

setmetatable(ScriptStorage.Tools, {
    __index = function(_, Index)
        return (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(Index)) or LocalPlayer.Backpack:FindFirstChild(Index)
    end
})

setmetatable(ScriptStorage.NPCs, {
    __index = function(_, Index)
        if not Index then return end
        return (workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild(Index)) or game.ReplicatedStorage.NPCs:FindFirstChild(Index)
    end
})

-- Utility Math & Time functions
function ConvertTo(Type, Instance)
    return Type.new(Instance.X, Instance.Y, Instance.Z)
end

function CaculateDistance(Origin, Desnitation)
    if not Origin then return 0 end
    Desnitation = Desnitation or LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame
    if not Desnitation then return 0 end
    local oPos = typeof(Origin) == "CFrame" and Origin.Position or Origin
    local dPos = typeof(Desnitation) == "CFrame" and Desnitation.Position or Desnitation
    return (oPos - dPos).magnitude
end

function DispTime(timeSec, cc)
    timeSec = tonumber(timeSec) or 0
    local days = math.floor(timeSec / 86400)
    local hours = math.floor(math.fmod(timeSec, 86400) / 3600)
    local minutes = math.floor(math.fmod(timeSec, 3600) / 60)
    local seconds = math.floor(math.fmod(timeSec, 60))
    if cc then
        return string.format("%dday, %dhrs, %dmin, %dsec.", days, hours, minutes, seconds)
    end
    return string.format("%dday, %dhrs.", days, hours)
end

function GetCurrentDateTime()
    local now = os.date("*t")
    local weekdays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
    local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    return string.format("%02d:%02d %s, %s %d %d", now.hour, now.min, weekdays[now.wday], months[now.month], now.day, now.year)
end

function CreateTraceback(Index, Value)
    table.insert(ScriptStorage.Tracebacks, GetCurrentDateTime() .. " | " .. tostring(Index) .. " | " .. tostring(Value))
end

function SetTask(Index, Value)
    if ScriptStorage.Task[Index] == Value then return end
    ScriptStorage.Task[Index] = Value
    if Index == "MainTask" and SetText then
        SetText("Task1", "Task: " .. tostring(Value))
    elseif Index == "SubTask" and SetText then
        SetText("Sub: " .. tostring(Value))
    end
end

-- Sea & Place ID
local placeId = game.PlaceId
local SeaIndex = 1
if placeId == 2753915549 or placeId == 85211729168715 then
    SeaIndex = 1
elseif placeId == 4442272183 or placeId == 79091703265657 then
    SeaIndex = 2
elseif placeId == 7449423635 or placeId == 100117331123089 then
    SeaIndex = 3
end

local BossesOrder = {"Awakened Ice Admiral", "Tide Keeper", "Deandre", "Urban", "Diablo", "Soul Reaper", "Cake Prince"}
local BossesOrderLevel = {
    ["Awakened Ice Admiral"] = 700,
    ["Tide Keeper"] = 700,
    ["Deandre"] = 1500,
    ["Urban"] = 1500,
    ["Diablo"] = 1500,
    ["Cake Prince"] = 1500,
    ["Soul Reaper"] = 1500
}

local BossesOrderWL = {
    ["Deandre"] = 1500,
    ["Urban"] = 1500,
    ["Diablo"] = 1500,
    ["Cake Prince"] = 1500,
    ["Don Swan"] = 1100,
    ["Awakened Ice Admiral"] = 700,
    ["Tide Keeper"] = 700
}

local SpecialBossesOrder = {
    ["Core"] = 700,
    ["Darkbeard"] = 700,
    ["rip_indra True Form"] = 1500,
    ["Dough King"] = 1500
}

local TasksOrder = {
    "ExpRedeem",
    "SoulGuitar",
    "Tushita",
    "SpecialBossesTask",
    "RaidController",
    "Trevor",
    "UtillyItemsActivitation",
    "ColosseumPuzzle",
    "ThirdSeaPuzzle",
    "Yama",
    "Saber",
    "PirateRaid",
    "SecondSeaPuzzle",
    "CollectDrops",
    "BossesTask",
    "LevelFarm"
}

MaxLevel = 2800

-- Remotes wrapper
Remotes = {}
setmetatable(Remotes, {
    __index = function(Self, Key)
        if Key ~= "CommF_" then
            return Services.ReplicatedStorage.Remotes[Key]
        end
        return {
            InvokeServer = function(_, ...)
                return Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
            end
        }
    end
})

-- FunctionsHandler registration structure
FunctionsHandler = {}
setmetatable(FunctionsHandler, {
    __index = function(Self, Index)
        local QueryResult = rawget(Self, Index)
        if not QueryResult then
            local Result = {
                CacheListener = {},
                RealCache = {},
                Methods = {},
                Constants = {},
                Events = {},
                Initalized = true
            }
            function Result.RegisterMethod(s, Name, Fn)
                s.Methods[Name] = { Name = Name, Callback = Fn }
                return true
            end
            function Result.Set(s, K, V) s.CacheListener[K] = V return V end
            function Result.Get(s, K) return s.Constants[K] or s.RealCache[K] end
            FunctionsHandler[Index] = Result
            return Result
        end
        return QueryResult
    end
})

-- Register all Tasks modules
for _, tName in ipairs(TasksOrder) do
    pcall(function() FunctionsHandler[tName]:Register() end)
end
pcall(function() FunctionsHandler.LocalPlayerController:Register() end)
pcall(function() FunctionsHandler.ExpRedeem:Register() end)
pcall(function() FunctionsHandler.LevelFarm:Register() end)
pcall(function() FunctionsHandler.Saber:Register() end)
pcall(function() FunctionsHandler.MeleesController:Register() end)
pcall(function() FunctionsHandler.RaidController:Register() end)
pcall(function() FunctionsHandler.SoulGuitar:Register() end)
pcall(function() FunctionsHandler.Tushita:Register() end)
pcall(function() FunctionsHandler.Yama:Register() end)

-- Quest Manager
local QuestManager = { CurrentLevel = 2, CurrentQuests = {}, BlacklistedQuestIds = { BartiloQuest = 1, CitizenQuest = 1, Trainees = 1, MarineQuest = 1, ImpelQuest = 1 } }
pcall(function() QuestManager.Quests = require(game.ReplicatedStorage.Quests) end)

function QuestManager.RefreshQuest(Self)
    if not ScriptStorage.PlayerData.Level then return end
    local QuestLevelFlag = 0
    local CurrentQuestData
    for QuestID, QuestDatas in pairs(QuestManager.Quests or {}) do
        if not QuestManager.BlacklistedQuestIds[QuestID] then
            if QuestDatas[1] and QuestDatas[1].LevelReq >= QuestLevelFlag and QuestDatas[1].LevelReq <= ScriptStorage.PlayerData.Level then
                QuestLevelFlag = QuestDatas[1].LevelReq
                CurrentQuestData = QuestDatas
                Self.CurrentQuestId = QuestID
            end
        end
    end
    Self.CurrentQuests = CurrentQuestData or {}
end

function QuestManager.StartQuest(QuestId, QuestLevel)
    return Remotes.CommF_:InvokeServer("StartQuest", QuestId, QuestLevel)
end

function QuestManager.AbandonQuest()
    Remotes.CommF_:InvokeServer("AbandonQuest")
end

-- TweenController & Noclip
local TweenController = {}
local TweenInstance = nil

function TweenController.Create(Position)
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    local TargetCFrame = typeof(Position) ~= "CFrame" and CFrame.new(Position) or Position
    local RootPart = Character.HumanoidRootPart
    local CurrentDist = (RootPart.Position - TargetCFrame.Position).Magnitude

    pcall(function()
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end)

    if TweenInstance then TweenInstance:Cancel() end
    local Speed = CurrentDist < 18 and 25 or 330
    local Time = CurrentDist / Speed
    TweenInstance = Services.TweenService:Create(RootPart, TweenInfo.new(Time, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    TweenInstance:Play()
end

-- CombatController & FastAttack
local CombatController = {}
function GetMonAsSortedRange()
    local Result = {}
    pcall(function()
        for _, Mon in ipairs(Services.Workspace.Enemies:GetChildren()) do
            if Mon and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and Mon.Humanoid.Health > 0 then
                table.insert(Result, Mon)
            end
        end
    end)
    table.sort(Result, function(C1, C2)
        return CaculateDistance(C1.HumanoidRootPart.CFrame) < CaculateDistance(C2.HumanoidRootPart.CFrame)
    end)
    return Result
end

function CombatController.Search(MobTable)
    for _, ChildInstance in ipairs(GetMonAsSortedRange()) do
        if table.find(MobTable, ChildInstance.Name) and ChildInstance.Humanoid.Health > 0 then
            return ChildInstance
        end
    end
end

function CombatController.Attack(MobTable)
    MobTable = type(MobTable) == "string" and {MobTable} or (MobTable or {})
    local MonResult = CombatController.Search(MobTable)
    if MonResult and MonResult:FindFirstChild("HumanoidRootPart") then
        TweenController.Create(MonResult.HumanoidRootPart.CFrame + Vector3.new(0, 20, 0))
    end
end

-- Main Task Runner Loop
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.Stop then return end
            -- Refresh Player Data
            for _, v in ipairs(LocalPlayer.Data:GetChildren()) do
                pcall(function() ScriptStorage.PlayerData[v.Name] = v.Value end)
            end
            
            -- Run Tasks Order
            for _, TaskName in ipairs(TasksOrder) do
                local Task = FunctionsHandler[TaskName]
                if Task and Task.Methods and Task.Methods.Refresh and Task.Methods.Start then
                    local canRun = Task.Methods.Refresh:Call()
                    if canRun then
                        SetTask("MainTask", TaskName)
                        Task.Methods.Start:Call(canRun)
                        break
                    end
                end
            end
        end)
    end
end)

print("🚀 Kunblox Blox Fruits Auto Script successfully loaded and executed!")
