-- === KHỞI TẠO BIẾN CƠ BẢN VÀ DEPENDENCIES ===
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local LocalPlayer = player

local Services = {
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    VirtualUser = game:GetService("VirtualUser"),
    TweenService = game:GetService("TweenService"),
    VirtualInputManager = game:GetService("VirtualInputManager")
}

local VirtualUser = Services.VirtualUser

local ScriptStorage = {
    Tracebacks = {}, Task = {}, PlayerData = {}, NPCs = {}, 
    Backpack = {}, Melees = {}, Connections = { LocalPlayer = {} },
    Tools = {}, IgnoreStoreFruits = {}, CurrentMeleeData = {}
}

local Config = {
    Configuration = { IdleCheck = 300 },
    Items = { Eatlist = {}, AutoEatFruit = false, Saber = true, RaceV2 = true, AutoFullyMelees = true }
}
local SCRIPT_CONFIG = Config

local Storage = {
    Data = {},
    Set = function(self, key, value) self.Data[key] = value end,
    Get = function(self, key) return self.Data[key] end,
    Save = function(self) end
}

local function SetText(...) end
local function alert(...) end
local function Report(...) end
local function Hop(...) end

-- Anti AFK
pcall(function()
    if getconnections then
        for _, conn in pairs(getconnections(player.Idled)) do
            if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
        end
    end
end)

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
end)

-- Hệ thống Noclip
local noclipConnection = nil
local function setNoclip(enabled)
    if enabled then
        if not noclipConnection then
            noclipConnection = Services.RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end
setNoclip(true)

local CHOOSE_TEAM = "Pirates"
local isScriptEnabled = true
local TweenInstance = nil
local TweenDebounce = false

-- AFK Check System
task.spawn(function()
    local lastPosition = nil
    local idleStartTime = nil
    
    while task.wait(1) do
        if not _G.Stop and Config.Configuration.IdleCheck and Config.Configuration.IdleCheck > 0 then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local currentPosition = LocalPlayer.Character.HumanoidRootPart.Position
                    local currentTime = os.time()
                    
                    if lastPosition then
                        local distance = (currentPosition - lastPosition).Magnitude
                        if distance >= 5 then
                            idleStartTime = nil
                        else
                            if not idleStartTime then
                                idleStartTime = currentTime
                            else
                                if (currentTime - idleStartTime) >= Config.Configuration.IdleCheck then
                                    print("[AFK Check] Player is idle for " .. (currentTime - idleStartTime) .. " seconds, rejoining...")
                                    if Hop then
                                        Hop("Rejoin")
                                    else
                                        game.Players.LocalPlayer:Kick("Rejoining...")
                                    end
                                    return
                                end
                            end
                        end
                    end
                    lastPosition = currentPosition
                else
                    lastPosition = nil
                    idleStartTime = nil
                end
            end)
        end
    end
end)

function CreateTraceback(Index, Value)
    table.insert(
        ScriptStorage.Tracebacks,
        (GetCurrentDateTime() .. " | " .. Index .. " | " .. Value)
    )
end

function SetTask(Index, Value)
    if ScriptStorage.Task[Index] == Value then return end
    local Parser = { MainTask = "Task1", SubTask = "Task2" }
    if Parser[Index] and SetText then
        SetText(Parser[Index], Index .. " : " .. Value)
    end
    ScriptStorage.Task[Index] = Value
    ScriptStorage.Task[Index .. "-d"] = os.time()
end

Remotes = {}
BindedMeleeNPCNames = {
    DragonClaw = "Sabi",
    FishmanKarate = "Water Kung-fu Teacher",
    Electro = "Mad Scientist",
    BlackLeg = "Dark Step Teacher",
    DeathStep = "Phoeyu, the Reformed",
    SharkmanKarate = "Sharkman Teacher",
    DragonTalon = "Uzoth",
    ElectricClaw = "Previous Hero",
    Godhuman = "Ancient Monk",
    Superhuman = "Martial Arts Master"
}
local MeleeCanBuy = {}

setmetatable(Remotes, {
    __index = function(Self, Key)
        if Key ~= "CommF_" then
            return Services.ReplicatedStorage.Remotes:FindFirstChild(Key) or Services.ReplicatedStorage.Remotes.CommF_
        end

        local tbl = {
            InvokeServer = function(Self, ...)
                local RemoteAction, IsValidate = ...
                if type(RemoteAction) == "string" and string.find(RemoteAction, "Buy") == 1 and not IsValidate then
                    local MeleeName = string.gsub(RemoteAction, "Buy", '')
                    if BindedMeleeNPCNames then
                        if table.find(MeleeCanBuy, MeleeName) then
                            local NPC = ScriptStorage.NPCs[BindedMeleeNPCNames[MeleeName]]
                            if NPC then
                                local NPCPos = NPC.WorldPivot
                                SetTask("SubTask", "Buying Melee - " .. MeleeName)
                                getgenv().anchored = true
                                if CaculateDistance(NPCPos) > 10 then
                                    repeat
                                        task.wait()
                                        TweenController.Create(NPCPos.Position)
                                    until CaculateDistance(NPCPos) < 10
                                    task.wait(3)
                                    Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
                                end
                            end
                        end
                    end
                end
                return Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
            end
        }

        return tbl
    end
})

Tasks = {}

function AwaitUntilPlayerLoaded(Player, Timeout)
    repeat task.wait() until Player.Character
    Player.Character:WaitForChild("Humanoid")
    repeat task.wait() until Player.Character.Humanoid.Health > 0
end

function AddPoint()
    local PointsValue = {}
    local Result

    for _, CInst in LocalPlayer.Data.Stats:GetChildren() do
        if CInst and CInst:FindFirstChild("Level") then
            PointsValue[CInst.Name] = CInst.Level.Value
        end
    end
    if PointsValue.Defense and PointsValue.Defense < MaxLevel and
       (PointsValue.Defense < (ScriptStorage.PlayerData.Level / 80) or MaxLevel - PointsValue.Melee < 100) then
        Result = "Defense"
    elseif PointsValue.Melee and PointsValue.Melee < MaxLevel then
        Result = "Melee"
    else
        Result = "Sword"
    end

    Remotes.CommF_:InvokeServer("AddPoint", Result, 999)
end

local Colors = {
    Currencies = { Level = "#00FF40", Beli = "#FF7800", Fragments = "#6600FF" }
}

function RefreshPlayerData()
    for _, ChildInstance in pairs(LocalPlayer.Data:GetChildren()) do
        pcall(function()
            local val = nil
            if ChildInstance:IsA("IntValue") or ChildInstance:IsA("NumberValue") or ChildInstance:IsA("StringValue") or ChildInstance:IsA("BoolValue") then
                val = ChildInstance.Value
            end
            if val == nil or val == 0 then
                if ChildInstance:GetAttribute("Fragments") then
                    val = ChildInstance:GetAttribute("Fragments")
                elseif ChildInstance:GetAttribute("Value") then
                    val = ChildInstance:GetAttribute("Value")
                end
            end
            if val == nil and ChildInstance.Value ~= nil then
                val = ChildInstance.Value
            end
            ScriptStorage.PlayerData[ChildInstance.Name] = val
        end)
    end
end

function RefreshRace()
    local v27, v28 = Remotes.CommF_:InvokeServer("Alchemist", "1"), Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
    ScriptStorage.PlayerData.RaceLevel = 1
    if LocalPlayer.Character:FindFirstChild("RaceTransformed") then
        ScriptStorage.PlayerData.RaceLevel = 4
    elseif v28 == -2 then
        ScriptStorage.PlayerData.RaceLevel = 3
    elseif v27 == -2 then
        ScriptStorage.PlayerData.RaceLevel = 2
    end
end

function RefreshInventory()
    ScriptStorage.Backpack2 = {}
    local inv = Remotes.CommF_:InvokeServer("getInventory")
    if type(inv) == "table" then
        for _, Value in pairs(inv) do
            if Value.Type == 'Blox Fruit' and game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and
            table.find(Config.Items.Eatlist, Value.Name) then 
                Remotes.CommF_:InvokeServer("LoadFruit", Value.Name)
                task.wait(1)
                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(FruitIdToName(Value.Name))
            end
            ScriptStorage.Backpack2[Value.Name] = Value
        end
    end
    ScriptStorage.Backpack = ScriptStorage.Backpack2
end

function RefreshMelees(ReturnOrSet)
    local Result = ""
    for MeleeName, Level in pairs(ScriptStorage.Melees) do
        Result = Result .. MeleeName .. ": " .. Level .. " "
    end
    Result = Result == "" and "[0]" or Result
    if ReturnOrSet then return Result end
end

function MeleeCheck(Child)
    if Child and typeof(Child) == "Instance" and Child:IsA("Tool") then
        if Child.ToolTip == "Melee" then
            if ScriptStorage.Connections.Melees then
                ScriptStorage.Connections.Melees:Disconnect()
            end

            ScriptStorage.CurrentMeleeData.Name = Child.Name

            if Child:FindFirstChild("Level") then
                ScriptStorage.Connections.Melees = Child.Level.Changed:Connect(function(Value)
                    ScriptStorage.Melees[Child.Name] = Value
                    RefreshMelees()
                end)
                ScriptStorage.Melees[Child.Name] = Child.Level.Value
                RefreshMelees()
            end
        elseif string.find(tostring(Child), "Fruit") then
            task.spawn(function()
                if FunctionsHandler.Trevor and FunctionsHandler.Trevor:Get("IsLoadingFruit") then return end
                if table.find(ScriptStorage.IgnoreStoreFruits, Child:GetAttribute("OriginalName")) then return end
                if Config.Items.AutoEatFruit and game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and
                   table.find(Config.Items.Eatlist, Child:GetAttribute("OriginalName")) then
                    while not LocalPlayer.Character:FindFirstChild(Child.Name) and
                        game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and task.wait(3) do
                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(Child.Name)
                    end
                    if LocalPlayer.Character:FindFirstChild(Child.Name):FindFirstChild("EatRemote") then
                        LocalPlayer.Character:FindFirstChild(Child.Name).EatRemote:InvokeServer()
                    end
                end
                Remotes.CommF_:InvokeServer("StoreFruit", Child:GetAttribute("OriginalName"), Child)
            end)
        end
    end
end

MeleeCheck(LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool"))
RefreshPlayerData()

function RegisterLocalPlayerEventsConnection()
    task.spawn(function()
        task.wait(2)
        if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
            Remotes.CommF_:InvokeServer("Buso")
        end
    end)

    for _, Connection in pairs(ScriptStorage.Connections.LocalPlayer) do
        pcall(function() Connection:Disconnect() end)
    end

    AwaitUntilPlayerLoaded(LocalPlayer)
    LocalPlayer:SetAttribute("IsAvailable", true)

    ScriptStorage.Connections.LocalPlayer["HealthCheck"] =
        LocalPlayer.Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("Health"):Connect(function()
            local Health = LocalPlayer.Character.Humanoid.Health
            LocalPlayer:SetAttribute("IsAvailable", Health > 10)
            ScriptStorage.LocalPlayerHealth = Health
        end)

    ScriptStorage.Connections.LocalPlayer["Melee"] = LocalPlayer.Character.ChildAdded:Connect(MeleeCheck)
    ScriptStorage.Connections.LocalPlayer["Fruit"] = LocalPlayer.Backpack.ChildAdded:Connect(MeleeCheck)

    for _, Melee in pairs(LocalPlayer.Backpack:GetChildren()) do
        MeleeCheck(Melee)
    end

    local PointsInstance = LocalPlayer.Data:WaitForChild("Points")
    ScriptStorage.Connections.LocalPlayer.PointConnection =
        PointsInstance:GetPropertyChangedSignal("Value"):Connect(function()
            task.wait(1)
            AddPoint()
        end)
end
RegisterLocalPlayerEventsConnection()

game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
    RegisterLocalPlayerEventsConnection()
end)

MeleesTable = {
    "Black Leg", "Electro", "Fishman Karate", "Dragon Claw", "Superhuman",
    "Death Step", "Electric Claw", "Sharkman Karate", "Dragon Talon", "Godhuman", "SanguineArt"
}
MeleesId = {
    "BlackLeg", "Electro", "FishmanKarate", "DragonClaw", "Superhuman",
    "DeathStep", "ElectricClaw", "SharkmanKarate", "DragonTalon", "Godhuman", "SanguineArt"
}

MeleePrices = {
    ["Black Leg"] = { Price = { Beli = 150000 }, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(Check) return BuyMelee("BlackLeg", Check, "Dark Step Teacher") end },
    ["Electro"] = { Price = { Beli = 500000 }, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(Check) return BuyMelee("Electro", Check, "Mad Scientist") end },
    ["Fishman Karate"] = { Price = { Beli = 750000 }, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(Check) return BuyMelee("FishmanKarate", Check, "Water Kung-fu Teacher") end },
    ["Dragon Claw"] = { Price = { Fragments = 1500 }, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(Check) return BuyMelee("DragonClaw", Check, "Sabi") end },
    ["Superhuman"] = { Price = { Beli = 3000000 }, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(Check) return BuyMelee("Superhuman", Check, "Martial Arts Master") end },
    ["Death Step"] = { Price = { Beli = 2500000, Fragments = 5000 }, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(Check) return BuyMelee("DeathStep", Check, "Phoeyu, the Reformed") end },
    ["Sharkman Karate"] = { Price = { Beli = 2500000, Fragments = 5000 }, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(Check) return BuyMelee("SharkmanKarate", Check, "Sharkman Teacher") end },
    ["Dragon Talon"] = { Price = { Beli = 2500000, Fragments = 5000 }, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(Check) return BuyMelee("DragonTalon", Check, "Uzoth") end },
    ["Electric Claw"] = { Price = { Beli = 2500000, Fragments = 5000 }, NextLevelRequirement = 400, Requirements = function() return true end, Buy = function(Check) return BuyMelee("ElectricClaw", Check, "Previous Hero") end },
    ["Godhuman"] = { Price = { Beli = 5000000, Fragments = 5000 }, NextLevelRequirement = 350, Requirements = function() return true end, Buy = function(Check) return BuyMelee("Godhuman", Check, "Ancient Monk") end }
}

GodhumanMaterials = {
    ["Fish Tail"] = { 20, 3, { "Fishman Raider", "Fishman Captain" }, { "DeepForestIsland3", 1, 1775, "Turtle Adventure Quest Giver" } },
    ["Dragon Scale"] = { 10, 3, { "Dragon Crew Warrior", "Dragon Crew Archer" }, { "DragonCrewQuest", 1, 1575, "Dragon Crew Quest Giver" } },
    ["Magma Ore"] = { 20, 2, { "Magma Ninja" }, { "FireSideQuest", 1, 1100, "Fire Quest Giver" } },
    ["Mystic Droplet"] = { 10, 2, { "Sea Soldier", "Water Fighter" }, { "ForgottenQuest", 2, 1425, "Forgotten Quest Giver" } }
}

SeaIndexes = {"Main", "Dressrosa", "Zou"}
TasksOrder = {
    "ExpRedeem", "SoulGuitar", "Tushita", "SpecialBossesTask", "RaidController",
    "Trevor", "UtillyItemsActivitation", "ColosseumPuzzle", "EvoRace", "ThirdSeaPuzzle",
    "Yama", "Saber", "PirateRaid", "SecondSeaPuzzle", "CollectDrops", "BossesTask", "LevelFarm"
}

MaxLevel = 2800
placeId = game.PlaceId
if placeId == 2753915549 or placeId == 85211729168715 then
    Sea = "Main"; SeaIndex = 1
elseif placeId == 4442272183 or placeId == 79091703265657 then
    Sea = "Dressrosa"; SeaIndex = 2
elseif placeId == 7449423635 or placeId == 100117331123089 then
    Sea = "Zou"; SeaIndex = 3
end

Portals = ({
    {
        Vector3.new(-7894.62, 5545.49, -380.24), Vector3.new(-4607.82, 872.54, -1667.55),
        Vector3.new(61163.85, 11.75, 1819.78), Vector3.new(3876.28, 35.10, -1939.32)
    },
    {
        Vector3.new(-288.46, 306.13, 597.99), Vector3.new(2284.91, 15.15, 905.48),
        Vector3.new(923.21, 126.97, 32852.83), Vector3.new(-6508.55, 89.03, -132.83)
    },
    {}
})[SeaIndex] or {}

function ConvertTo(Type, Instance)
    if typeof(Instance) == "CFrame" then
        return Type.new(Instance.X, Instance.Y, Instance.Z)
    elseif typeof(Instance) == "Vector3" then
        return Instance
    end
    return Type.new(0, 0, 0)
end

function CaculateDistance(Origin, Desnitation)
    if not Origin then return 0 end
    Desnitation = Desnitation or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame)
    if not Desnitation then return 0 end
    local oVec, dVec = ConvertTo(Vector3, Origin), ConvertTo(Vector3, Desnitation)
    return (oVec - dVec).magnitude
end

function DispTime(time, cc)
    time = tonumber(time) or 0
    local days = math.floor(time / 86400)
    local hours = math.floor(math.fmod(time, 86400) / 3600)
    local minutes = math.floor(math.fmod(time, 3600) / 60)
    local seconds = math.floor(math.fmod(time, 60))
    if cc then
        return (days .. "day, " .. hours .. "hrs, " .. minutes .. "min, " .. seconds .. "sec.")
    end
    return (days .. "day, " .. hours .. "hrs.")
end

function GetCurrentDateTime()
    return os.date("%X %a, %b %d %Y")
end

function RoundVector3Down(vec)
    return Vector3.new(math.floor(vec.X / 10) * 10, math.floor(vec.Y / 10) * 10, math.floor(vec.Z / 10) * 10)
end

local Angle = 30
local lastChange = tick()
CaculateCircreDirection = function(Position)
    if Angle > 50000 then Angle = 60 end
    Angle = Angle + ((tick() - lastChange) > .4 and 80 or 0)
    if tick() - lastChange > .4 then lastChange = tick() end
    local sum = Position + Vector3.new(math.cos(math.rad(Angle)) * 40, 0, math.sin(math.rad(Angle)) * 40)
    return CFrame.new(RoundVector3Down(sum.p))
end

function GetMonAsSortedRange()
    local Result = {}
    if Services.Workspace:FindFirstChild("Enemies") then
        for _, Mon in pairs(Services.Workspace.Enemies:GetChildren()) do
            if Mon and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and Mon.Humanoid.Health > 0 then
                table.insert(Result, Mon)
            end
        end
    end
    table.sort(Result, function(C1, C2)
        return CaculateDistance(C1.HumanoidRootPart.CFrame) < CaculateDistance(C2.HumanoidRootPart.CFrame)
    end)
    return Result
end

function GetMeleeIdByName(MeleeName)
    for Index, Melee in pairs(MeleesTable) do
        if Melee == MeleeName then return MeleesId[Index] end
    end
end

function SendKey(key, hold)
    task.spawn(function()
        Services.VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(hold or 0.1)
        Services.VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

function FruitIdToName(FruitId)
    local ParserResult = string.match(FruitId, "(((%u)%-?)([^-.]+))$") or FruitId
    return ParserResult .. " Fruit"
end

function Split(inputstr, sep)
    sep = sep or "%s"
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do table.insert(t, str) end
    return t
end

local QuestManager = {
    CurrentLevel = 2,
    DoubleQuest = true,
    CurrentQuests = {},
    BlacklistedQuestIds = { BartiloQuest = 1, CitizenQuest = 1, Trainees = 1, MarineQuest = 1, ImpelQuest = 1 }
}

repeat task.wait() until game.Players.LocalPlayer.DataLoaded and ScriptStorage
QuestManager.Quests = require(game.ReplicatedStorage.Quests)

function QuestManager.Set(Self, Index, Value) Self[Index] = Value end

function QuestManager.RefreshQuest(Self)
    while not ScriptStorage.PlayerData.Level do task.wait(1) end
    local QuestLevelFlag = 0
    local CurrentQuestData

    for QuestID, QuestDatas in pairs(QuestManager.Quests) do
        if not QuestManager.BlacklistedQuestIds[QuestID] then
            if (QuestDatas[1].LevelReq >= QuestLevelFlag and QuestDatas[1].LevelReq <= ScriptStorage.PlayerData.Level) then
                QuestLevelFlag = QuestDatas[1].LevelReq
                CurrentQuestData = QuestDatas
                Self.CurrentQuestId = QuestID
                if ScriptStorage.PlayerData.Level >= 1500 and SeaIndex == 2 and QuestID == "ForgottenQuest" then break end
            end
        end
    end

    if CurrentQuestData then
        local GuideModule = require(game.ReplicatedStorage.GuideModule)
        for i, v in pairs(GuideModule.Data.NPCList) do
            for _, v1 in pairs(v.Levels) do
                if v1 == CurrentQuestData[#CurrentQuestData].LevelReq then
                    Self.CurrentNpc = i.CFrame
                end
            end
        end
        Self.CurrentQuests = CurrentQuestData
    end
end

function QuestManager.GetCurrentQuest(Self)
    local QuestIndex = (Self.CurrentQuests[Self.CurrentLevel] and Self.CurrentQuests[Self.CurrentLevel].LevelReq <= ScriptStorage.PlayerData.Level) and Self.CurrentLevel or 1
    if Self.CurrentQuests[QuestIndex] then
        for Name in pairs(Self.CurrentQuests[QuestIndex].Task) do
            return Name, Self.CurrentNpc, Self.CurrentQuestId, QuestIndex, Self.CurrentQuests[QuestIndex].Name
        end
    end
end

function QuestManager.AbandonQuest()
    Remotes.CommF_:InvokeServer("AbandonQuest")
end

function QuestManager.GetCurrentClaimQuest()
    local QuestTitle = LocalPlayer.PlayerGui.Main.Quest.Visible and
        LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:gsub("%s*Defeat%s*(%d*)%s*(.-)%s*%b()", "%2")
    return (type(QuestTitle) == "string" and string.gsub(QuestTitle, "Military ", "Mil. ") or QuestTitle),
           LocalPlayer.PlayerGui.Main.Quest.Visible and LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text or ""
end

function QuestManager.StartQuest(QuestId, QuestLevel)
    return Remotes.CommF_:InvokeServer("StartQuest", QuestId, QuestLevel)
end

ScriptStorage.MobRegions = {}
if game:GetService("ReplicatedStorage"):FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder") then
    for _, Region in pairs(game:GetService("ReplicatedStorage").FortBuilderReplicatedSpawnPositionsFolder:GetChildren()) do
        ScriptStorage.MobRegions[tostring(Region)] = ScriptStorage.MobRegions[tostring(Region)] or {}
        table.insert(ScriptStorage.MobRegions[tostring(Region)], Region.CFrame)
    end
end

TweenController = {}
function GetPortal(Position)
    local Nearest, Current = 9e9, nil
    for _, Portal in pairs(Portals) do
        local Dist1 = CaculateDistance(Portal, Position)
        if Dist1 < (CaculateDistance(Position) - 300) and Dist1 < Nearest then
            Nearest = Dist1
            Current = Portal
        end
    end
    if Current then
        Remotes.CommF_:InvokeServer("requestEntrance", Current)
        return task.wait()
    end
end

function TweenController.Create(Position)
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    if not Position or TweenDebounce or TweenController._isCreating then return end

    local TargetCFrame = typeof(Position) ~= "CFrame" and CFrame.new(Position) or Position
    TargetCFrame = CFrame.new(TargetCFrame.Position)

    local RootPart = Character.HumanoidRootPart
    local CurrentDist = (RootPart.Position - TargetCFrame.Position).Magnitude

    if TweenInstance and TweenInstance.PlaybackState == Enum.PlaybackState.Playing then
        if CurrentDist < 5 then return end
    end

    TweenController._isCreating = true

    pcall(function()
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end)

    local head = Character:FindFirstChild("Head")
    if head and not head:FindFirstChild("eltrul") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "eltrul"
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Velocity = Vector3.zero
        bv.Parent = head
    end

    if CurrentDist > 500 and SeaIndex ~= 3 then
        GetPortal(TargetCFrame)
    end

    if TweenInstance then TweenInstance:Cancel() end

    local Speed = (CurrentDist < 18) and 25 or 330
    local Time = CurrentDist / Speed

    TweenInstance = Services.TweenService:Create(
        RootPart,
        TweenInfo.new(Time, Enum.EasingStyle.Linear),
        {CFrame = TargetCFrame}
    )
    TweenInstance:Play()

    task.delay(0.1, function() TweenController._isCreating = false end)
end

local AttackController = {}
function BuyMelee(M1, Check, NPCName)
    if M1 == "DragonClaw" then
        if Check then
            RefreshPlayerData()
            local PlayerData = ScriptStorage.PlayerData
            local HasEnoughFragments = PlayerData and PlayerData.Fragments and PlayerData.Fragments >= 1500
            if HasEnoughFragments and not table.find(MeleeCanBuy, M1) then
                table.insert(MeleeCanBuy, M1)
            end
            return HasEnoughFragments
        end
        if SeaIndex == 3 then
            local SabiPos = CFrame.new(-4979.9, 371.3, -3205.4)
            SetTask("SubTask", "Buying Melee - Dragon Claw (Sea 3)")
            if CaculateDistance(SabiPos) > 10 then
                repeat task.wait() TweenController.Create(SabiPos) until CaculateDistance(SabiPos) < 10
                task.wait(3)
            end
            return Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
        end
        return Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
    end 
    if Check then
        local Response_ = Remotes.CommF_:InvokeServer("Buy" .. M1, true)
        if type(Response_) == "number" and not table.find(MeleeCanBuy, M1) then
            table.insert(MeleeCanBuy, M1)
        end
        return Response_ == 1
    end
    return Remotes.CommF_:InvokeServer("Buy" .. M1)
end

local Funcs = {}
function GetAllBladeHits()
    local bladehits = {}
    if Services.Workspace:FindFirstChild("Enemies") then
        for _, v in pairs(Services.Workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and
               (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 65 then
                table.insert(bladehits, v)
            end
        end
    end
    return bladehits
end

function Getplayerhit()
    local bladehits = {}
    if Services.Workspace:FindFirstChild("Characters") then
        for _, v in pairs(Services.Workspace.Characters:GetChildren()) do
            if v.Name ~= LocalPlayer.Name and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and
               v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 65 then
                table.insert(bladehits, v)
            end
        end
    end
    return bladehits
end

local NetModule = Services.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = NetModule:WaitForChild("RE/RegisterAttack")
local RegisterHit = NetModule:WaitForChild("RE/RegisterHit")

function Funcs:Attack()
    local bladehits = {}
    for _, v in pairs(GetAllBladeHits()) do table.insert(bladehits, v) end
    for _, v in pairs(Getplayerhit()) do table.insert(bladehits, v) end

    if #bladehits == 0 then return end

    local args = { [1] = nil, [2] = {}, [4] = "078da341" }
    for _, v in pairs(bladehits) do
        RegisterAttack:FireServer(0)
        if not args[1] then args[1] = v.Head end
        table.insert(args[2], { [1] = v, [2] = v.HumanoidRootPart })
        table.insert(args[2], v)
    end
    RegisterHit:FireServer(unpack(args))
end

task.spawn(function()
    while task.wait(0.06) do
        if _G.FastAttack == os.time() then
            pcall(function() Funcs:Attack() end)
        end
    end
end)

function AttackController.Attack(MonResult)
    pcall(function() _G.FastAttack = os.time() end)
end

CombatController = {
    GRAB = true,
    GRAB_DISTANCE = SeaIndex == 1 and 250 or 350,
    MAX_ATTACK_DURATION = 3,
    MAX_ATTACK_DURATION_2 = 60,
    CurrentIndex = 1
}
LastFound = os.time()

function CombatController.Grab(MobName)
    pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)
    local MidPoint, Count = Vector3.zero, 0
    local ForcePosition = nil
    local MobsTable = {}

    if Services.Workspace:FindFirstChild("Enemies") then
        for _, Mon in pairs(Services.Workspace.Enemies:GetChildren()) do
            if Mon.Name == MobName and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and Mon.Humanoid.Health > 0 then
                local MonPosition = Mon.HumanoidRootPart.Position
                if MonPosition and isnetworkowner(Mon.PrimaryPart) then
                    if not ForcePosition or CaculateDistance(MonPosition, ForcePosition) < CombatController.GRAB_DISTANCE then
                        Count = Count + 1
                        MidPoint = MidPoint + MonPosition
                        ForcePosition = ForcePosition or MonPosition
                        table.insert(MobsTable, Mon)
                    end
                end
            end
        end
    end
    if Count > 0 then
        MidPoint = CFrame.new(MidPoint / Count)
        for _, ChildInstance in pairs(MobsTable) do
            if not ChildInstance:GetAttribute("IgnoreGrab") then
                local RootPart = ChildInstance:FindFirstChild("HumanoidRootPart")
                if RootPart then
                    local BodyVelocity = RootPart:FindFirstChild("FarmingVelocity") or Instance.new("BodyVelocity")
                    BodyVelocity.Name = "FarmingVelocity"
                    BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                    BodyVelocity.Velocity = Vector3.zero
                    BodyVelocity.Parent = RootPart

                    ChildInstance.HumanoidRootPart.CFrame = MidPoint
                end
            end
        end
    end
end

function CombatController.Search(MobTable)
    local Lists = {}
    local Found = false
    for _, ChildInstance in pairs(GetMonAsSortedRange()) do
        if table.find(MobTable, ChildInstance.Name) and ChildInstance:FindFirstChild("Humanoid") and ChildInstance.Humanoid.Health > 0 then
            Found = true
            table.insert(Lists, ChildInstance)
        end
    end

    if Found then return Lists[1] end

    for _, ChildName in pairs(MobTable) do
        local MonResult2 = game.ReplicatedStorage:FindFirstChild(ChildName)
        if MonResult2 then return MonResult2 end
    end
end

function CombatController.Attack(MobTable, NearbyHit, Range)
    MobTable = type(MobTable) == "string" and {MobTable} or (MobTable or {})

    for _, Child in pairs(MobTable) do
        local MonResult = CombatController.Search({Child})
        if MonResult then
            LastFound = os.time()
            local Debounce = os.time()
            while task.wait(0.1) do
                if _G.Stop then return end
                local MobHumanoid = MonResult:FindFirstChild("Humanoid")
                local MobHumanoidRootPart = MonResult:FindFirstChild("HumanoidRootPart")

                if not MobHumanoid or MobHumanoid.Health <= 0 then break end

                TweenController.Create(CaculateCircreDirection(MobHumanoidRootPart.CFrame) + Vector3.new(0, 35, 0))

                if CaculateDistance(MobHumanoidRootPart.Position + Vector3.new(0, 35, 0)) < 150 then
                    CombatController.Grab(Child or "")
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(ScriptStorage.ForceToUseSword and "Sword" or "Melee")
                    AttackController:Attack(MonResult)
                end
            end
        end
    end
end

FunctionsHandler = { Initalized = false }

setmetatable(FunctionsHandler, {
    __index = function(Self, Index)
        local QueryResult = rawget(Self, Index)
        if not QueryResult then
            return {
                Register = function(Coditional)
                    if Coditional == false then return end
                    local Result = {
                        CacheListener = {}, RealCache = {}, Methods = {}, Constants = {}, Events = {}, Initalized = true
                    }
                    function Result.RegisterMethod(Self, Name, Function)
                        Self.Methods[Name] = {
                            Name = Name, Callback = Function,
                            Call = function(Self, ...) return Self.Callback(...) end
                        }
                        return true
                    end
                    function Result.Set(Self, Key, Value) Self.RealCache[Key] = Value return Value end
                    function Result.Get(Self, Index) return Self.Constants[Index] or Self.RealCache[Index] end
                    FunctionsHandler[Index] = Result
                end,
                Initalized = false
            }
        end
        return QueryResult
    end
})

-- Đăng ký các Handler Tác Vụ
FunctionsHandler.LocalPlayerController.Register()
FunctionsHandler.ExpRedeem:Register()
FunctionsHandler.LevelFarm:Register()
FunctionsHandler.Saber:Register()
FunctionsHandler.SecondSeaPuzzle:Register()
FunctionsHandler.ColosseumPuzzle:Register()
FunctionsHandler.EvoRace:Register()
FunctionsHandler.MeleesController:Register()

-- LP Methods
FunctionsHandler.LocalPlayerController:RegisterMethod("EquipTool", function(Tool)
    local char = LocalPlayer.Character
    if not char then return end
    local Humanoid = char:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    
    local toolObj = LocalPlayer.Backpack:FindFirstChild(Tool) or char:FindFirstChild(Tool)
    if toolObj and toolObj:IsA("Tool") then
        Humanoid:EquipTool(toolObj)
    end
end)

-- ExpRedeem
FunctionsHandler.ExpRedeem:RegisterMethod("Refresh", function()
    return ScriptStorage.PlayerData.Level and ScriptStorage.PlayerData.Level < MaxLevel and not Storage:Get("IsCodesRanOut")
end)

FunctionsHandler.ExpRedeem:RegisterMethod("Start", function()
    local Codes = {"Sub2UncleKizaru", "SUB2GAMERROBOT_EXP1", "KITT_RESET", "Sub2OfficialNoobie", "TheGreatAce"}
    for _, Promo in ipairs(Codes) do
        SetTask("MainTask", "Code Redemption | " .. Promo)
        Remotes.CommF_:InvokeServer("RedeemCode", Promo)
        task.wait(0.5)
    end
    Storage:Set("IsCodesRanOut", true)
end)

-- LevelFarm
FunctionsHandler.LevelFarm:RegisterMethod("Refresh", function()
    return true
end)

FunctionsHandler.LevelFarm:RegisterMethod("Start", function()
    local PlayerLevel = ScriptStorage.PlayerData.Level or 1
    
    if PlayerLevel >= 1500 and SeaIndex == 2 then
        SetTask("MainTask", "Sea Travel | Teleporting to Third Sea")
        Remotes.CommF_:InvokeServer("TravelZou")
        return
    elseif PlayerLevel >= 700 and SeaIndex == 1 then
        SetTask("MainTask", "Sea Travel | Teleporting to Second Sea")
        Remotes.CommF_:InvokeServer("TravelDressrosa")
        return
    end

    local MonName, NpcPosition, QuestId, QuestIndex, QuestTitle = QuestManager:GetCurrentQuest()
    local CurrentClaimQuest1, RawTitle = QuestManager.GetCurrentClaimQuest()

    if CurrentClaimQuest1 then
        if CurrentClaimQuest1 ~= QuestTitle and CurrentClaimQuest1 ~= (QuestTitle .. "s") then
            QuestManager.AbandonQuest()
            return
        end
    else
        if NpcPosition then
            TweenController.Create(NpcPosition + Vector3.new(0, 5, 3))
            SetTask("MainTask", "Level Farming | Claiming Quest")
            if CaculateDistance(NpcPosition) < 15 then
                task.wait(1)
                QuestManager.StartQuest(QuestId, QuestIndex)
                task.wait(1)
            end
            return
        else
            QuestManager:RefreshQuest()
        end
    end

    if MonName then
        SetTask("MainTask", "Level Farming | Defeating " .. tostring(MonName))
        CombatController.Attack(MonName)
    end
end)

-- Saber Quest
FunctionsHandler.Saber:RegisterMethod("Refresh", function()
    if not Config.Items.Saber or SeaIndex ~= 1 or ScriptStorage.Backpack.Saber or (ScriptStorage.PlayerData.Level or 0) < 200 then
        return false
    end
    return true
end)

FunctionsHandler.Saber:RegisterMethod("Start", function()
    SetTask("MainTask", "Saber Quest | In Progress")
    Remotes.CommF_:InvokeServer("ProQuestProgress", "GetTorch")
end)

-- Colosseum Puzzle (Bartilo)
FunctionsHandler.ColosseumPuzzle:RegisterMethod("Refresh", function()
    if SeaIndex ~= 2 or (ScriptStorage.PlayerData.Level or 0) < 850 then return false end
    return true
end)

FunctionsHandler.ColosseumPuzzle:RegisterMethod("Start", function()
    SetTask("MainTask", "Colosseum Quest | Defeating Swan Pirates")
    CombatController.Attack("Swan Pirate")
end)

-- EvoRace (Race V2 - Hoàn chỉnh)
FunctionsHandler.EvoRace:RegisterMethod("Refresh", function()
    if not Config.Items.RaceV2 or SeaIndex ~= 2 then return false end
    if (ScriptStorage.PlayerData.Level or 0) < 900 or (ScriptStorage.PlayerData.Beli or 0) < 500000 then return false end
    if ScriptStorage.PlayerData.RaceLevel and ScriptStorage.PlayerData.RaceLevel >= 2 then return false end
    return true
end)

FunctionsHandler.EvoRace:RegisterMethod("Start", function()
    Remotes.CommF_:InvokeServer("Alchemist", "1")
    Remotes.CommF_:InvokeServer("Alchemist", "2")

    local hasF1 = LocalPlayer.Backpack:FindFirstChild("Flower 1") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Flower 1"))
    local hasF2 = LocalPlayer.Backpack:FindFirstChild("Flower 2") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Flower 2"))
    local hasF3 = LocalPlayer.Backpack:FindFirstChild("Flower 3") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Flower 3"))

    if hasF1 and hasF2 and hasF3 then
        SetTask("MainTask", "Race V2 | Returning to Alchemist")
        local AlchemistPos = CFrame.new(624.4, 73.5, 915.2)
        if CaculateDistance(AlchemistPos) > 10 then
            TweenController.Create(AlchemistPos)
            return
        end
        Remotes.CommF_:InvokeServer("Alchemist", "3")
        RefreshRace()
        return
    end

    if not hasF1 then
        SetTask("MainTask", "Race V2 | Locating Red Flower (Flower 1)")
        for _, obj in pairs(Services.Workspace:GetChildren()) do
            if obj.Name == "Flower1" and obj:IsA("BasePart") and obj.Transparency == 0 then
                TweenController.Create(obj.CFrame)
                return
            end
        end
    end

    if not hasF2 then
        SetTask("MainTask", "Race V2 | Locating Blue Flower (Flower 2)")
        for _, obj in pairs(Services.Workspace:GetChildren()) do
            if obj.Name == "Flower2" and obj:IsA("BasePart") and obj.Transparency == 0 then
                TweenController.Create(obj.CFrame)
                return
            end
        end
    end

    if not hasF3 then
        SetTask("MainTask", "Race V2 | Farming Yellow Flower (Flower 3) from Swan Pirates")
        CombatController.Attack("Swan Pirate")
        return
    end
end)

-- Melees Controller
FunctionsHandler.MeleesController:RegisterMethod("Refresh", function()
    return Config.Items.AutoFullyMelees
end)

FunctionsHandler.MeleesController:RegisterMethod("Start", function()
    for _, Melee in ipairs(MeleesTable) do
        local Data = MeleePrices[Melee]
        if Data and not ScriptStorage.Melees[Melee] then
            SetTask("SubTask", "Auto Melee | Buying " .. Melee)
            Data.Buy()
            break
        end
    end
end)

-- Safe connection for RefreshQuestPro remote
pcall(function()
    local RefreshRemote = Services.ReplicatedStorage.Remotes:FindFirstChild("RefreshQuestPro")
    if RefreshRemote and RefreshRemote:IsA("RemoteEvent") then
        RefreshRemote.OnClientEvent:Connect(function(...)
            if FunctionsHandler.Saber.Methods.Refresh then
                FunctionsHandler.Saber.Methods.Refresh.Callback(...)
            end
        end)
    end
end)

-- === MAIN ENGINE TASK LOOP ===
task.spawn(function()
    while task.wait(0.5) do
        if not _G.Stop then
            pcall(function()
                RefreshPlayerData()
                for _, TaskName in ipairs(TasksOrder) do
                    local Handler = FunctionsHandler[TaskName]
                    if Handler and Handler.Initalized and Handler.Methods.Refresh and Handler.Methods.Start then
                        local canRun = Handler.Methods.Refresh:Call()
                        if canRun then
                            Handler.Methods.Start:Call(canRun)
                            break
                        end
                    end
                end
            end)
        end
    end
end)
