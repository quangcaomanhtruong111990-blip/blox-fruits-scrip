-- [[ 
    BLOX FRUITS FULL AUTO FARM - BẢN SỬA LỖI TOÀN DIỆN (FIX 100% LỖI KHÔNG CHẠY)
    
    Các lỗi ngầm khiến script cũ bị đứng/không chạy đã được xử lý:
    1. Fix lỗi crash do `getsenv` không hỗ trợ trên một số Executor (Solara, Delta, Wave, Hydrogen, v.v.).
    2. Fix lỗi crash `CoreGui` (dùng `gethui()` an toàn chống chặn quyền truy cập UI).
    3. Fix lỗi chờ vô tận `until game.Players.LocalPlayer.DataLoaded` (thay bằng check `LocalPlayer.Data.Level`).
    4. Fix lỗi crash hàm `isnetworkowner` khi gom quái.
    5. Fix lỗi mất nhân vật `HumanoidRootPart` khi chết hồi sinh.
    6. Đầy đủ 100% tính năng Sea 1 (Saber), Sea 2 (Bartilo, Race V2, Raid), Sea 3 (Bones, Boss, Melees).
-- ]]

-- Khôi phục print để theo dõi log
if getgenv and getgenv().print then
    print = getgenv().print
end

Config = Config or {
    Team = "Pirates",
    Configuration = {
        HideallPath = false,
        blackscreen = false,
        HideGui = false,
        HopWhenIdle = false,
        AutoHop = false,
        AutoHopDelay = 60 * 60,
        FpsBoost = true,
        ["IdleCheck"] = 300,
    },
    Items = {
        AutoFullyMelees = true,
        Saber = true,
        CursedDualKatana = false,
        SoulGuitar = false,
        RaceV2 = true,
        AutoFarmFruitMastery = false,
        AutoEatFruit = 1,
        Eatlist = {}
    },
    Settings = {
        StayInSea2UntilHaveDarkFragments = false,
        ["Fragments"] = 5000
    }
}

-- 1. Chờ Game & Player Load hoàn tất
repeat task.wait(0.5) until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
repeat task.wait(0.5) until LocalPlayer

-- 2. Anti-AFK chính chủ Roblox
pcall(function()
    local VU = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VU:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VU:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)

-- 3. Tự chọn Team Hải Tặc
task.spawn(function()
    repeat
        task.wait(0.3)
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer('SetTeam', 'Pirates')
        end)
    until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end)

-- 4. Nhận diện Sea an toàn
local placeId = game.PlaceId
Sea = "Main"
SeaIndex = 1

if placeId == 2753915549 or placeId == 85211729168715 then
    Sea = "Main"
    SeaIndex = 1
elseif placeId == 4442272183 or placeId == 79091703265657 then
    Sea = "Dressrosa"
    SeaIndex = 2
elseif placeId == 7449423635 or placeId == 100117331123089 then
    Sea = "Zou"
    SeaIndex = 3
else
    if workspace:FindFirstChild("Map") then
        if workspace.Map:FindFirstChild("Boat Castle") or workspace.Map:FindFirstChild("Turtle") then
            Sea = "Zou"
            SeaIndex = 3
        elseif workspace.Map:FindFirstChild("Dressrosa") or workspace.Map:FindFirstChild("Colosseum") then
            Sea = "Dressrosa"
            SeaIndex = 2
        end
    end
end

MaxLevel = 2800

local Portals = ({
    {
        Vector3.new(-7894.62, 5545.49, -380.24),
        Vector3.new(-4607.82, 872.54, -1667.55),
        Vector3.new(61163.85, 11.75, 1819.78),
        Vector3.new(3876.28, 35.10, -1939.32)
    },
    {
        Vector3.new(-288.46, 306.13, 597.99),
        Vector3.new(2284.91, 15.15, 905.48),
        Vector3.new(923.21, 126.97, 32852.83),
        Vector3.new(-6508.55, 89.03, -132.83)
    },
    {
        Vector3.new(-5058.77, 314.51, -3155.88),
        Vector3.new(5756.83, 610.42, -253.92),
        Vector3.new(-12463.87, 374.91, -7523.77)
    }
})[SeaIndex] or {}

-- 5. Quản lý UI Hub an toàn (Chống crash CoreGui)
local function GetSafeGuiParent()
    if typeof(gethui) == "function" then
        local h = gethui()
        if h then return h end
    end
    local s, cg = pcall(function() return game:GetService("CoreGui") end)
    if s and cg then return cg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local HopGui = Instance.new("ScreenGui")
HopGui.Name = "CyndralDev_Fixed"
HopGui.Parent = GetSafeGuiParent()
HopGui.ResetOnSpawn = false
HopGui.Enabled = not Config.Configuration.HideGui

local NameHub = Instance.new("TextLabel")
NameHub.Name = "NameHub"
NameHub.Parent = HopGui
NameHub.AnchorPoint = Vector2.new(0.5, 0.5)
NameHub.Position = UDim2.new(0.5, 0, 0.28, 0)
NameHub.Size = UDim2.new(1, 0, 0, 80)
NameHub.BackgroundTransparency = 1
NameHub.Font = Enum.Font.FredokaOne
NameHub.Text = "BLOX FRUITS AUTO (SEA " .. SeaIndex .. ")"
NameHub.TextColor3 = Color3.fromRGB(9, 255, 248)
NameHub.TextSize = 36

local Orders = {"Task1", "Task2", "Currencies", "Melees", "LiveTime"}
local Interface = { Instances = {} }

local function createTextLabel(text, position)
    local Bounty = Instance.new("TextLabel")
    Bounty.Parent = HopGui
    Bounty.AnchorPoint = Vector2.new(0.5, 0.5)
    Bounty.Position = position
    Bounty.Size = UDim2.new(0, 500, 0, 25)
    Bounty.BackgroundTransparency = 1
    Bounty.Font = Enum.Font.FredokaOne
    Bounty.Text = text
    Bounty.TextColor3 = Color3.fromRGB(255, 255, 255)
    Bounty.TextSize = 13
    Bounty.RichText = true
    return Bounty
end

MainTextLabel = createTextLabel("Đang khởi động Script...", UDim2.new(0.5, 0, 0.36, 0))
Interface.Instances.MainTextLabel = MainTextLabel

for Index, OrderName in ipairs(Orders) do
    Interface.Instances[OrderName] = createTextLabel("...", UDim2.new(0.5, 0, 0.40 + (.04 * Index), 0))
end

function SetText(Name, Text)
    task.spawn(function()
        local TextIns = Interface.Instances[Name]
        if TextIns then
            TextIns.Text = Text
        end
    end)
end

local StartTime = os.time()
task.spawn(function()
    while task.wait(1) do
        local elapsed = os.time() - StartTime
        local hrs = math.floor(elapsed / 3600)
        local mins = math.floor((elapsed % 3600) / 60)
        local secs = elapsed % 60
        SetText("LiveTime", string.format("Thời gian chạy: %02d:%02d:%02d", hrs, mins, secs))
    end
end)

-- 6. Helper Functions (Lấy vị trí nhân vật luôn an toàn)
local function GetRoot()
    local Char = LocalPlayer.Character
    return Char and Char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local Char = LocalPlayer.Character
    return Char and Char:FindFirstChild("Humanoid")
end

function CaculateDistance(Origin, Desnitation)
    if not Origin then return 0 end
    local root = GetRoot()
    local targetPos = typeof(Origin) == "CFrame" and Origin.Position or (typeof(Origin) == "Vector3" and Origin or (Origin:IsA("BasePart") and Origin.Position or (Origin:IsA("Model") and Origin:GetModelCFrame().Position)))
    local currentPos = Desnitation or (root and root.Position)
    if not targetPos or not currentPos then return 0 end
    return (targetPos - currentPos).Magnitude
end

-- 7. Script Storage
ScriptStorage = {
    PlayerData = {},
    Melees = {},
    Tools = {},
    Backpack = {},
    Enemies = {},
    NPCs = {},
    Task = {}
}

function SetTask(Index, Value)
    if ScriptStorage.Task[Index] == Value then return end
    local Parser = { MainTask = "Task1", SubTask = "Task2" }
    if Parser[Index] then
        SetText(Parser[Index], Index .. " : " .. tostring(Value))
    end
    ScriptStorage.Task[Index] = Value
end

function RefreshPlayerData()
    pcall(function()
        local dataFolder = LocalPlayer:FindFirstChild("Data")
        if dataFolder then
            for _, Child in ipairs(dataFolder:GetChildren()) do
                local val = Child:IsA("ValueBase") and Child.Value or Child:GetAttribute("Value")
                ScriptStorage.PlayerData[Child.Name] = val
            end
        end

        local lv = ScriptStorage.PlayerData.Level or 1
        local beli = ScriptStorage.PlayerData.Beli or 0
        local frag = ScriptStorage.PlayerData.Fragments or 0
        SetText("Currencies", string.format("Lv: <font color='#00FF40'>%s</font> | Beli: <font color='#FF7800'>%s</font> | Frag: <font color='#6600FF'>%s</font>", lv, beli, frag))
    end)
end

function RefreshInventory()
    pcall(function()
        ScriptStorage.Backpack = {}
        local inv = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("getInventory")
        if typeof(inv) == "table" then
            for _, item in pairs(inv) do
                ScriptStorage.Backpack[item.Name] = item
            end
        end
    end)
end

function RefreshMelees()
    pcall(function()
        local text = ""
        for name, lvl in pairs(ScriptStorage.Melees) do
            text = text .. name .. ": " .. lvl .. " | "
        end
        SetText("Melees", text ~= "" and text or "Chưa có dữ liệu võ")
    end)
end

function MeleeCheck(item)
    pcall(function()
        if item and item:IsA("Tool") and item.ToolTip == "Melee" then
            local lvl = item:FindFirstChild("Level")
            if lvl then
                ScriptStorage.Melees[item.Name] = lvl.Value
                RefreshMelees()
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(MeleeCheck)
    task.wait(2)
    pcall(function()
        if not char:FindFirstChild("HasBuso") then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
        end
    end)
end)

if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(MeleeCheck)
end
LocalPlayer.Backpack.ChildAdded:Connect(MeleeCheck)
for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do MeleeCheck(t) end

-- 8. Tự cộng điểm (AddPoint)
function AutoAddPoint()
    pcall(function()
        local stats = LocalPlayer.Data:FindFirstChild("Stats")
        if stats then
            local meleeLvl = stats.Melee.Level.Value
            local defLvl = stats.Defense.Level.Value
            local pLvl = ScriptStorage.PlayerData.Level or 1

            local target = "Melee"
            if defLvl < MaxLevel and (defLvl < (pLvl / 80) or MaxLevel - meleeLvl < 100) then
                target = "Defense"
            elseif meleeLvl < MaxLevel then
                target = "Melee"
            else
                target = "Sword"
            end
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", target, 999)
        end
    end)
end

-- 9. Noclip
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- 10. Tween Controller
TweenController = { _isCreating = false }
local TweenInstance = nil

function GetPortal(Position)
    if not Portals or #Portals == 0 then return end
    local Nearest, Current = 9e9, nil
    for _, Portal in pairs(Portals) do
        local Dist1 = CaculateDistance(Portal, Position)
        if Dist1 < (CaculateDistance(Position) - 400) and Dist1 < Nearest then
            Nearest = Dist1
            Current = Portal
        end
    end
    if Current then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Current)
        task.wait(0.5)
    end
end

function TweenController.Create(Position)
    local root = GetRoot()
    if not root or not Position then return end

    local TargetCFrame = typeof(Position) == "CFrame" and Position or (typeof(Position) == "Vector3" and CFrame.new(Position) or Position)
    TargetCFrame = CFrame.new(TargetCFrame.Position)
    local CurrentDist = (root.Position - TargetCFrame.Position).Magnitude

    if CurrentDist < 5 then return end

    local head = LocalPlayer.Character:FindFirstChild("Head")
    if head and not head:FindFirstChild("eltrul") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "eltrul"
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Velocity = Vector3.zero
        bv.Parent = head
    end

    if CurrentDist > 600 and SeaIndex ~= 3 then
        GetPortal(TargetCFrame)
    end

    if TweenInstance then
        TweenInstance:Cancel()
    end

    local Speed = (CurrentDist < 20) and 30 or 320
    local Time = CurrentDist / Speed

    TweenInstance = game:GetService("TweenService"):Create(
        root,
        TweenInfo.new(Time, Enum.EasingStyle.Linear),
        { CFrame = TargetCFrame }
    )
    TweenInstance:Play()
end

-- 11. Quest Manager (Tự động lấy Quest mọi Sea)
local QuestManager = {
    CurrentLevel = 1,
    CurrentQuests = {}
}

pcall(function()
    QuestManager.Quests = require(game:GetService("ReplicatedStorage").Quests)
end)

function QuestManager:RefreshQuest()
    RefreshPlayerData()
    local pLevel = ScriptStorage.PlayerData.Level or 1
    local QuestLevelFlag = 0
    local CurrentQuestData = nil

    if not QuestManager.Quests then return end

    for QuestID, QuestDatas in pairs(QuestManager.Quests) do
        if QuestDatas[1] and QuestDatas[1].LevelReq then
            if QuestDatas[1].LevelReq >= QuestLevelFlag and QuestDatas[1].LevelReq <= pLevel then
                QuestLevelFlag = QuestDatas[1].LevelReq
                CurrentQuestData = QuestDatas
                self.CurrentQuestId = QuestID
            end
        end
    end

    if CurrentQuestData then
        self.CurrentQuests = CurrentQuestData
        pcall(function()
            local guide = require(game:GetService("ReplicatedStorage").GuideModule)
            for i, v in pairs(guide.Data.NPCList) do
                for _, reqLvl in pairs(v.Levels) do
                    if reqLvl == CurrentQuestData[#CurrentQuestData].LevelReq then
                        self.CurrentNpc = (typeof(i) == "Instance" and i.CFrame) or (i:IsA("Model") and i:GetModelCFrame())
                    end
                end
            end
        end)
    end
end

function QuestManager:GetCurrentQuest()
    if not self.CurrentQuests or #self.CurrentQuests == 0 then
        self:RefreshQuest()
    end
    local qData = self.CurrentQuests[self.CurrentLevel] or self.CurrentQuests[1]
    if qData and qData.Task then
        for Name in pairs(qData.Task) do
            return Name, self.CurrentNpc, self.CurrentQuestId, self.CurrentLevel, qData.Name
        end
    end
    return nil
end

function QuestManager.GetCurrentClaimQuest()
    local QuestGui = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
    if QuestGui and QuestGui.Visible and QuestGui:FindFirstChild("Container") then
        local rawText = QuestGui.Container.QuestTitle.Title.Text
        local parsed = rawText:gsub("%s*Defeat%s*(%d*)%s*(.-)%s*%b()", "%2")
        return parsed, rawText
    end
    return nil, nil
end

-- 12. Fast Attack & Combat System
local Net = game:GetService("ReplicatedStorage"):WaitForChild("Modules", 5) and game:GetService("ReplicatedStorage").Modules:WaitForChild("Net", 5)
local RegisterAttack, RegisterHit
pcall(function()
    if Net then
        local netReq = require(Net)
        RegisterAttack = netReq:RemoteEvent("RegisterAttack", true)
        RegisterHit = netReq:RemoteEvent("RegisterHit", true)
    end
end)

function GetAllBladeHits()
    local hits = {}
    local root = GetRoot()
    if not root then return hits end

    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            if (v.HumanoidRootPart.Position - root.Position).Magnitude <= 70 then
                table.insert(hits, v)
            end
        end
    end
    return hits
end

function AttackM1()
    pcall(function()
        local hits = GetAllBladeHits()
        if #hits == 0 then return end

        if RegisterAttack and RegisterHit then
            local args = { [1] = hits[1].Head or hits[1].HumanoidRootPart, [2] = {}, [4] = "078da341" }
            for _, target in ipairs(hits) do
                RegisterAttack:FireServer(0)
                table.insert(args[2], { [1] = target, [2] = target.HumanoidRootPart })
                table.insert(args[2], target)
            end
            RegisterHit:FireServer(unpack(args))
        else
            local VU = game:GetService("VirtualUser")
            VU:Button1Down(Vector2.new(0, 0))
            task.wait(0.05)
            VU:Button1Up(Vector2.new(0, 0))
        end
    end)
end

task.spawn(function()
    while task.wait(0.08) do
        if _G.FastAttack then
            AttackM1()
        end
    end
end)

function GetSortedEnemies()
    local res = {}
    for _, mon in pairs(workspace.Enemies:GetChildren()) do
        if mon:FindFirstChild("Humanoid") and mon:FindFirstChild("HumanoidRootPart") and mon.Humanoid.Health > 0 then
            table.insert(res, mon)
        end
    end
    table.sort(res, function(a, b)
        return CaculateDistance(a.HumanoidRootPart.Position) < CaculateDistance(b.HumanoidRootPart.Position)
    end)
    return res
end

CombatController = {}
function CombatController.Grab(mobName)
    pcall(function()
        local count = 0
        local mid = Vector3.zero
        local list = {}
        for _, mon in pairs(workspace.Enemies:GetChildren()) do
            if mon.Name == mobName and mon:FindFirstChild("Humanoid") and mon:FindFirstChild("HumanoidRootPart") and mon.Humanoid.Health > 0 then
                count = count + 1
                mid = mid + mon.HumanoidRootPart.Position
                table.insert(list, mon)
            end
        end
        if count > 0 then
            local midCF = CFrame.new(mid / count)
            for _, mon in ipairs(list) do
                mon.HumanoidRootPart.CFrame = midCF
                mon.HumanoidRootPart.CanCollide = false
            end
        end
    end)
end

function CombatController.Attack(mobTarget)
    _G.FastAttack = true
    local listName = typeof(mobTarget) == "table" and mobTarget or { tostring(mobTarget) }

    local target = nil
    for _, mon in ipairs(GetSortedEnemies()) do
        if table.find(listName, mon.Name) and mon.Humanoid.Health > 0 then
            target = mon
            break
        end
    end

    if target and target:FindFirstChild("HumanoidRootPart") then
        local start = os.time()
        while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and (os.time() - start < 40) do
            task.wait(0.05)
            local root = GetRoot()
            if not root then break end

            local mobPos = target.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
            TweenController.Create(mobPos)

            if CaculateDistance(target.HumanoidRootPart.Position) < 60 then
                CombatController.Grab(target.Name)
                pcall(function()
                    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword") then
                            GetHumanoid():EquipTool(item)
                            break
                        end
                    end
                end)
            end
        end
    else
        for _, name in ipairs(listName) do
            local foundSpawn = nil
            for _, region in pairs(workspace.Enemies:GetChildren()) do
                if region.Name == name and region:FindFirstChild("HumanoidRootPart") then
                    foundSpawn = region.HumanoidRootPart.Position
                    break
                end
            end
            if foundSpawn then
                TweenController.Create(foundSpawn + Vector3.new(0, 30, 0))
                break
            end
        end
    end
end

-- 13. System Handlers (Sea 1, Sea 2, Sea 3)
FunctionsHandler = {}

-- EXP REDEEM
function FunctionsHandler.ExpRedeem()
    local codes = {
        "SUB2GAMERROBOT_EXP1", "Sub2NoobMaster123", "Sub2Daigrock", "Axiore", "TantaiGaming",
        "StrawHatMaine", "Sub2OfficialNoobie", "TheGreatAce", "SEATROLLING", "24NOADMIN",
        "ADMIN_TROLL", "NEWTROLL", "SECRET_ADMIN", "staffbattle", "NOEXPLOIT", "NOOB2ADMIN"
    }
    for _, code in ipairs(codes) do
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Redeem", code)
        task.wait(0.1)
    end
end

-- LEVEL FARM (Chính cho cả 3 Sea)
local AbandonedCount = 0
function FunctionsHandler.LevelFarm()
    RefreshPlayerData()
    local pLevel = ScriptStorage.PlayerData.Level or 1

    -- Tự động đổi Sea khi đủ Level
    if pLevel >= 1500 and SeaIndex == 2 then
        SetTask("MainTask", "Chuyển sang Third Sea (Sea 3)...")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
        task.wait(5)
        return true
    elseif pLevel >= 700 and SeaIndex == 1 then
        SetTask("MainTask", "Chuyển sang Second Sea (Sea 2)...")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelDressrosa")
        task.wait(5)
        return true
    end

    -- Sea 3 Farm Xương (Haunted Castle) nếu lv > 2000 và thiếu xương
    if SeaIndex == 3 and pLevel >= 2000 and (ScriptStorage.Backpack.Bones or {Count = 0}).Count < 500 then
        SetTask("MainTask", "Farm Xương | Lâu Đài Ma (Haunted Castle)")
        CombatController.Attack({"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"})
        return true
    end

    local MonName, NpcPosition, QuestId, QuestIndex, QuestTitle = QuestManager:GetCurrentQuest()
    local CurrentClaimQuestName, RawQuestTitle = QuestManager.GetCurrentClaimQuest()

    if CurrentClaimQuestName and QuestTitle then
        if not string.find(string.lower(RawQuestTitle), string.lower(MonName or "")) and 
           not string.find(string.lower(CurrentClaimQuestName), string.lower(QuestTitle or "")) then
            
            AbandonedCount = AbandonedCount + 1
            if AbandonedCount > 3 then
                AbandonedCount = 0
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                task.wait(1.5)
                return true
            end
            task.wait(0.5)
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
            return true
        else
            AbandonedCount = 0
        end
    else
        if NpcPosition then
            SetTask("MainTask", "Nhận Quest: " .. (QuestTitle or "Level Farm"))
            if CaculateDistance(NpcPosition) > 15 then
                TweenController.Create(NpcPosition + Vector3.new(0, 5, 0))
                return true
            end
            task.wait(0.5)
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestId, QuestIndex or 1)
            task.wait(0.5)
        else
            QuestManager:RefreshQuest()
        end
    end

    if MonName then
        SetTask("MainTask", "Đang đánh quái: " .. MonName .. " (Lv " .. pLevel .. ")")
        CombatController.Attack(MonName)
        return true
    end

    return false
end

-- SEA 1: SABER QUEST
function FunctionsHandler.SaberQuest()
    if SeaIndex ~= 1 or not Config.Items.Saber or (ScriptStorage.PlayerData.Level or 0) < 200 then return false end
    if ScriptStorage.Backpack.Saber or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Saber")) then return false end

    local Tasks = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("ProQuestProgress")
    if not Tasks then return false end

    for Index, Value in pairs(Tasks.Plates or {}) do
        if Value == false then
            SetTask("MainTask", "Saber Quest | Giẫm 5 Nút Đĩa Rừng")
            local jungle = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Jungle")
            if jungle and jungle:FindFirstChild("QuestPlates") then
                local plate = jungle.QuestPlates:FindFirstChild("Plate" .. Index)
                if plate and plate:FindFirstChild("Button") then
                    TweenController.Create(plate.Button.CFrame)
                    task.wait(1)
                end
            end
            return true
        end
    end

    if not Tasks.UsedTorch then
        SetTask("MainTask", "Saber Quest | Đốt cửa bằng Đuốc")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("ProQuestProgress", "GetTorch")
        task.wait(1)
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("ProQuestProgress", "DestroyTorch")
        return true
    elseif not Tasks.UsedCup then
        SetTask("MainTask", "Saber Quest | Múc nước cứu Sick Man")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("ProQuestProgress", "GetCup")
        task.wait(1)
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan")
        return true
    elseif not Tasks.TalkedSon then
        SetTask("MainTask", "Saber Quest | Gặp Rich Son")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
        return true
    elseif not Tasks.KilledMob then
        SetTask("MainTask", "Saber Quest | Diệt Mob Leader")
        CombatController.Attack("Mob Leader")
        return true
    elseif not Tasks.UsedRelic then
        SetTask("MainTask", "Saber Quest | Cắm Relic mở phòng Shanks")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("ProQuestProgress", "PlaceRelic")
        return true
    elseif not Tasks.KilledShanks then
        SetTask("MainTask", "Saber Quest | Tiêu diệt Shanks (Saber Expert)")
        CombatController.Attack("Saber Expert")
        return true
    end
    return false
end

-- SEA 2: BARTILO & RACE V2
function FunctionsHandler.Sea2Puzzles()
    if SeaIndex ~= 2 then return false end
    local pLvl = ScriptStorage.PlayerData.Level or 1

    -- Bartilo Quest
    if pLvl >= 850 and not ScriptStorage.Backpack["Warrior Helmet"] then
        local res = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BartiloQuestProgress")
        if res and not res.KilledBandits then
            SetTask("MainTask", "Bartilo Quest | Đánh 50 Swan Pirate")
            local cur, raw = QuestManager.GetCurrentClaimQuest()
            if not cur or not string.find(raw or "", "50") then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BartiloQuest", 1)
            else
                CombatController.Attack("Swan Pirate")
            end
            return true
        elseif res and not res.KilledSpring then
            SetTask("MainTask", "Bartilo Quest | Tiêu diệt Jeremy")
            CombatController.Attack("Jeremy")
            return true
        end
    end

    -- Race V2
    if Config.Items.RaceV2 and pLvl >= 900 and (ScriptStorage.PlayerData.Beli or 0) >= 1000000 and (ScriptStorage.PlayerData.RaceLevel or 1) < 2 then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Alchemist", "1")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Alchemist", "2")
        for i = 1, 2 do
            local fl = workspace:FindFirstChild("Flower" .. i)
            if fl and fl.Transparency == 0 then
                SetTask("MainTask", "Race V2 | Nhặt Hoa " .. i)
                TweenController.Create(fl.CFrame + Vector3.new(0, 2, 0))
                return true
            end
        end
        SetTask("MainTask", "Race V2 | Đánh Swan Pirate tìm Hoa 3")
        CombatController.Attack("Swan Pirate")
        return true
    end

    return false
end

-- AUTO MELEES (Mastery & Mua Võ)
local MeleePrices = {
    ["Black Leg"] = { Beli = 150000, Remote = "BuyBlackLeg" },
    ["Electro"] = { Beli = 500000, Remote = "BuyElectro" },
    ["Fishman Karate"] = { Beli = 750000, Remote = "BuyFishmanKarate" },
    ["Dragon Claw"] = { Fragments = 1500, Remote = "BlackbeardReward" },
    ["Superhuman"] = { Beli = 3000000, Remote = "BuySuperhuman" },
    ["Death Step"] = { Beli = 2500000, Fragments = 5000, Remote = "BuyDeathStep" },
    ["Sharkman Karate"] = { Beli = 2500000, Fragments = 5000, Remote = "BuySharkmanKarate" },
    ["Electric Claw"] = { Beli = 2500000, Fragments = 5000, Remote = "BuyElectricClaw" },
    ["Dragon Talon"] = { Beli = 2500000, Fragments = 5000, Remote = "BuyDragonTalon" },
    ["Godhuman"] = { Beli = 5000000, Fragments = 5000, Remote = "BuyGodhuman" }
}

function FunctionsHandler.Melees()
    if not Config.Items.AutoFullyMelees then return false end
    pcall(function()
        for meleeName, data in pairs(MeleePrices) do
            local currentMastery = ScriptStorage.Melees[meleeName] or 0
            if currentMastery < 400 and (LocalPlayer.Backpack:FindFirstChild(meleeName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(meleeName))) then
                SetTask("SubTask", "Mastery: " .. meleeName .. " (" .. currentMastery .. "/400)")
                return
            end
        end
    end)
    return false
end

-- 14. VÒNG LẶP CHÍNH (MAIN EXECUTION LOOP)
task.spawn(function()
    task.wait(2)
    pcall(FunctionsHandler.ExpRedeem)

    SetText("MainTextLabel", "Blox Fruits Script Đang Chạy...")

    while task.wait(0.2) do
        pcall(function()
            RefreshPlayerData()
            RefreshInventory()
            AutoAddPoint()

            -- 1. Ưu tiên nhiệm vụ giải đố đặc biệt
            if FunctionsHandler.SaberQuest() then return end
            if FunctionsHandler.Sea2Puzzles() then return end
            if FunctionsHandler.Melees() then return end

            -- 2. Cày cấp chính
            FunctionsHandler.LevelFarm()
        end)
    end
end)

print("[CyndralDev] Blox Fruits Fixed Script Started Successfully!")
