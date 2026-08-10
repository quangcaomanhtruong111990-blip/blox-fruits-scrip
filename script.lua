local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Trạng thái Script
local isScriptEnabled = true
local isTweening = false
local currentTween = nil

-- Cấu hình tốc độ bay
local FLY_SPEED_LONG = 140  -- Bay chuyển bãi
local FLY_SPEED_SHORT = 90   -- Bay đánh quái

------------------------------------------------------------------
-- DATABASE: TỔNG HỢP QUEST QUÁI THƯỜNG SEA 1 (LV 1 - 700)
------------------------------------------------------------------
local Sea1MobQuests = {
    -- Starter Island
    { Level = 1, QuestName = "BanditQuest1", QuestLevel = 1, MobName = "Bandit", NpcCFrame = CFrame.new(1059, 16, 1549), MobCFrame = CFrame.new(1190, 16, 1610) },
    -- Jungle
    { Level = 15, QuestName = "JungleQuest", QuestLevel = 1, MobName = "Monkey", NpcCFrame = CFrame.new(-1598, 37, 153), MobCFrame = CFrame.new(-1610, 22, 140) },
    { Level = 30, QuestName = "JungleQuest", QuestLevel = 2, MobName = "Gorilla", NpcCFrame = CFrame.new(-1598, 37, 153), MobCFrame = CFrame.new(-1240, 6, -490) },
    -- Pirate Village
    { Level = 40, QuestName = "BuggyQuest1", QuestLevel = 1, MobName = "Pirate", NpcCFrame = CFrame.new(-1140, 4, 3828), MobCFrame = CFrame.new(-1210, 4, 3900) },
    { Level = 60, QuestName = "BuggyQuest1", QuestLevel = 2, MobName = "Brute", NpcCFrame = CFrame.new(-1140, 4, 3828), MobCFrame = CFrame.new(-1150, 15, 4250) },
    -- Desert
    { Level = 90, QuestName = "DesertQuest", QuestLevel = 1, MobName = "Desert Bandit", NpcCFrame = CFrame.new(894, 6, 4388), MobCFrame = CFrame.new(930, 6, 4450) },
    { Level = 100, QuestName = "DesertQuest", QuestLevel = 2, MobName = "Desert Officer", NpcCFrame = CFrame.new(894, 6, 4388), MobCFrame = CFrame.new(1570, 10, 4380) },
    -- Middle Island
    { Level = 120, QuestName = "Area2Quest", QuestLevel = 1, MobName = "Snow Bandit", NpcCFrame = CFrame.new(1385, 87, -1298), MobCFrame = CFrame.new(1280, 105, -1430) },
    -- Frozen Village
    { Level = 135, QuestName = "SnowQuest", QuestLevel = 1, MobName = "Snowman", NpcCFrame = CFrame.new(1385, 87, -1298), MobCFrame = CFrame.new(1280, 105, -1430) },
    -- Marine Ford
    { Level = 175, QuestName = "MarineQuest", QuestLevel = 1, MobName = "Chief Petty Officer", NpcCFrame = CFrame.new(-2573, 6, 2031), MobCFrame = CFrame.new(-2700, 20, 2100) },
    -- Skypeia (Sky 1 & 2)
    { Level = 250, QuestName = "SkyQuest", QuestLevel = 1, MobName = "Sky Bandit", NpcCFrame = CFrame.new(-4840, 718, -2623), MobCFrame = CFrame.new(-4980, 718, -2830) },
    { Level = 275, QuestName = "SkyQuest", QuestLevel = 2, MobName = "Dark Master", NpcCFrame = CFrame.new(-4840, 718, -2623), MobCFrame = CFrame.new(-5200, 390, -2250) },
    { Level = 450, QuestName = "SkyExp1Quest", QuestLevel = 1, MobName = "God's Guard", NpcCFrame = CFrame.new(-4720, 845, -1950), MobCFrame = CFrame.new(-4700, 845, -1900) },
    { Level = 475, QuestName = "SkyExp1Quest", QuestLevel = 2, MobName = "Shanda", NpcCFrame = CFrame.new(-4720, 845, -1950), MobCFrame = CFrame.new(-7680, 5561, -500) },
    { Level = 525, QuestName = "SkyExp2Quest", QuestLevel = 1, MobName = "Royal Squad", NpcCFrame = CFrame.new(-7900, 5600, -600), MobCFrame = CFrame.new(-7700, 5600, -700) },
    { Level = 550, QuestName = "SkyExp2Quest", QuestLevel = 2, MobName = "Royal Guard", NpcCFrame = CFrame.new(-7900, 5600, -600), MobCFrame = CFrame.new(-7600, 5600, -900) },
    -- Prison
    { Level = 190, QuestName = "PrisonerQuest", QuestLevel = 1, MobName = "Prisoner", NpcCFrame = CFrame.new(530, 2, 475), MobCFrame = CFrame.new(480, 2, 550) },
    { Level = 210, QuestName = "PrisonerQuest", QuestLevel = 2, MobName = "Dangerous Prisoner", NpcCFrame = CFrame.new(530, 2, 475), MobCFrame = CFrame.new(550, 2, 700) },
    -- Colosseum
    { Level = 225, QuestName = "ColosseumQuest", QuestLevel = 1, MobName = "Toga Warrior", NpcCFrame = CFrame.new(-1580, 7, -2980), MobCFrame = CFrame.new(-1800, 7, -3100) },
    { Level = 300, QuestName = "ColosseumQuest", QuestLevel = 2, MobName = "Gladiator", NpcCFrame = CFrame.new(-1580, 7, -2980), MobCFrame = CFrame.new(-1300, 7, -3300) },
    -- Magma Village
    { Level = 350, QuestName = "MagmaQuest", QuestLevel = 1, MobName = "Military Soldier", NpcCFrame = CFrame.new(-5310, 12, 8515), MobCFrame = CFrame.new(-5400, 12, 8500) },
    { Level = 375, QuestName = "MagmaQuest", QuestLevel = 2, MobName = "Military Spy", NpcCFrame = CFrame.new(-5310, 12, 8515), MobCFrame = CFrame.new(-5800, 12, 8800) },
    -- Underwater City
    { Level = 400, QuestName = "FishmanQuest", QuestLevel = 1, MobName = "Fishman Warrior", NpcCFrame = CFrame.new(61122, 18, 1569), MobCFrame = CFrame.new(61000, 18, 1200) },
    { Level = 425, QuestName = "FishmanQuest", QuestLevel = 2, MobName = "Fishman Commando", NpcCFrame = CFrame.new(61122, 18, 1569), MobCFrame = CFrame.new(61800, 18, 1500) },
    -- Fountain City
    { Level = 625, QuestName = "FountainQuest", QuestLevel = 1, MobName = "Galley Pirate", NpcCFrame = CFrame.new(5258, 38, 4050), MobCFrame = CFrame.new(5500, 38, 4000) },
    { Level = 650, QuestName = "FountainQuest", QuestLevel = 2, MobName = "Galley Captain", NpcCFrame = CFrame.new(5258, 38, 4050), MobCFrame = CFrame.new(5600, 38, 4900) }
}

------------------------------------------------------------------
-- HÀM LẤY QUEST QUÁI THƯỜNG PHÙ HỢP LEVEL
------------------------------------------------------------------
local function getCurrentQuestData()
    local myLevel = 1
    pcall(function()
        myLevel = player.Data.Level.Value
    end)
    
    local selectedQuest = Sea1MobQuests[1]
    for i = #Sea1MobQuests, 1, -1 do
        if myLevel >= Sea1MobQuests[i].Level then
            selectedQuest = Sea1MobQuests[i]
            break
        end
    end
    return selectedQuest
end

------------------------------------------------------------------
-- QUẢN LÝ GIAO DIỆN VÀ TRẠNG THÁI
------------------------------------------------------------------
local function restoreCharacterControl()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
    if currentTween then currentTween:Cancel() currentTween = nil end
    isTweening = false
end

if CoreGui:FindFirstChild("AutoFarmSea1Gui") then CoreGui.AutoFarmSea1Gui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmSea1Gui"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 50)
mainFrame.Position = UDim2.new(0, 30, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 1.5
frameStroke.Color = Color3.fromRGB(0, 230, 150)
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = mainFrame

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 14, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)
statusDot.Parent = mainFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 200, 0, 20)
titleText.Position = UDim2.new(0, 32, 0, 8)
titleText.BackgroundTransparency = 1
titleText.Text = "AUTO FARM MOB ONLY (SEA 1)"
titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
titleText.TextSize = 11
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = mainFrame

local subText = Instance.new("TextLabel")
subText.Size = UDim2.new(0, 200, 0, 14)
subText.Position = UDim2.new(0, 32, 0, 26)
subText.BackgroundTransparency = 1
subText.Text = "Status: RUNNING [Phím K]"
subText.TextColor3 = Color3.fromRGB(0, 230, 115)
subText.TextSize = 10
subText.Font = Enum.Font.GothamMedium
subText.TextXAlignment = Enum.TextXAlignment.Left
subText.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""
toggleBtn.Parent = mainFrame

local function updateUIState()
    local qData = getCurrentQuestData()
    if isScriptEnabled then
        frameStroke.Color = Color3.fromRGB(0, 230, 150)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)
        subText.Text = string.format("Mob: %s | Lv: %d [K]", qData.MobName, qData.Level)
        subText.TextColor3 = Color3.fromRGB(0, 230, 115)
    else
        frameStroke.Color = Color3.fromRGB(235, 60, 60)
        statusDot.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
        subText.Text = "Status: PAUSED [K]"
        subText.TextColor3 = Color3.fromRGB(235, 60, 60)
    end
end

local function toggleState()
    isScriptEnabled = not isScriptEnabled
    updateUIState()
    if not isScriptEnabled then restoreCharacterControl() end
end

toggleBtn.MouseButton1Click:Connect(toggleState)
UserInputService.InputBegan:Connect(function(input, gP)
    if not gP and input.KeyCode == Enum.KeyCode.K then toggleState() end
end)

------------------------------------------------------------------
-- SYSTEM BAY TWEEN & COMBAT
------------------------------------------------------------------
local function flyLinearTo(targetCFrame, speed)
    if not isScriptEnabled then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    speed = speed or FLY_SPEED_LONG
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    isTweening = true
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "AntiFall" then v:Destroy() end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    currentTween.Completed:Wait()

    if bv then bv:Destroy() end
    isTweening = false
end

local function equipWeapon()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if character and backpack and not character:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword" or item.ToolTip == "Blox Fruit") then
                character.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

local function startQuest(qName, qLevel)
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("StartQuest", qName, qLevel) end
    end)
end

local function getClosestMob(mobName)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = 2000

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, mobName) then
                local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChild("Humanoid")
                if mobHrp and mobHum and mobHum.Health > 0 then
                    local dist = (hrp.Position - mobHrp.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestMob = mob
                    end
                end
            end
        end
    end
    return closestMob
end

local function fastAttack()
    pcall(function()
        local character = player.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end)
end

------------------------------------------------------------------
-- VÒNG LẶP CHÍNH (SEA 1)
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.01) do
        if isScriptEnabled and not isTweening then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                updateUIState()
                
                local hrp = character.HumanoidRootPart
                local qData = getCurrentQuestData()
                local playerGui = player:WaitForChild("PlayerGui")
                local questFrame = playerGui.Main.Quest

------------------------------------------------------------------
-- VÒNG LẶP CHÍNH (NHẬN QUEST TỪ XA - BAY THẲNG ĐẾN BÃI QUÁI)
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.01) do
        if isScriptEnabled and not isTweening then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                autoAddStats()
                updateUIState()
                
                local hrp = character.HumanoidRootPart
                local qData = getCurrentQuestData()
                local playerGui = player:WaitForChild("PlayerGui")
                local questFrame = playerGui.Main.Quest

                -- 1. Nếu chưa có Quest -> Tự nhận từ xa ngay lập tức (Không bay tới NPC)
                if not questFrame.Visible then
                    startQuest(qData.QuestName, qData.QuestLevel)
                    task.wait(0.3)
                else
                    -- 2. Đã có Quest -> Bay thẳng tới bãi quái đánh luôn
                    local targetMob = getClosestMob(qData.MobName)
                    
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        local targetCFrame = mobHrp.CFrame * CFrame.new(0, 9, 0)
                        
                        local distToMob = (hrp.Position - mobHrp.Position).Magnitude
                        if distToMob > 12 then
                            flyLinearTo(targetCFrame, FLY_SPEED_SHORT)
                        else
                            hrp.CFrame = targetCFrame
                            fastAttack()
                        end
                    else
                        -- Nếu quái chưa spawn -> Bay thẳng tới tọa độ bãi quái ngồi chờ
                        local distToMobArea = (hrp.Position - qData.MobCFrame.Position).Magnitude
                        if distToMobArea > 20 then
                            flyLinearTo(qData.MobCFrame, FLY_SPEED_LONG)
                        end
                    end
                end
            end)
        end
    end
end)
