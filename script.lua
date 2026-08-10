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

-- Cấu hình tốc độ bay và độ cao
local FLY_SPEED_LONG = 250    
local FLY_SPEED_SHORT = 150   
local SAFE_HEIGHT = 120       -- Độ cao bay xa / đổi đảo
local FARM_HEIGHT = 15        -- Độ cao cố định chuẩn khi farm quái

------------------------------------------------------------------
-- DATABASE: GIỮ NGUYÊN TỌA ĐỘ CHUẨN (LEVEL 700)
------------------------------------------------------------------
local Sea2MobQuests = {
    -- Kingdom of Rose
    { Level = 700, QuestName = "Area1Quest", QuestLevel = 1, MobName = "Raider", NpcCFrame = CFrame.new(-659.8, 39.2, 2395.3), MobCFrame = CFrame.new(-750, 75, 3100) },
    { Level = 725, QuestName = "Area1Quest", QuestLevel = 2, MobName = "Mercenary", NpcCFrame = CFrame.new(-427, 73, 2981), MobCFrame = CFrame.new(-880, 80, 1600) },
    { Level = 775, QuestName = "Area2Quest", QuestLevel = 1, MobName = "Swan Pirate", NpcCFrame = CFrame.new(878, 122, 1230), MobCFrame = CFrame.new(880, 125, 1100) },
    { Level = 800, QuestName = "Area2Quest", QuestLevel = 2, MobName = "Factory Staff", NpcCFrame = CFrame.new(878, 122, 1230), MobCFrame = CFrame.new(295, 73, -55) },
    -- Green Zone
    { Level = 875, QuestName = "MarineQuest2", QuestLevel = 1, MobName = "Marine Lieutenant", NpcCFrame = CFrame.new(-2440, 73, -3218), MobCFrame = CFrame.new(-2800, 73, -3000) },
    { Level = 900, QuestName = "MarineQuest2", QuestLevel = 2, MobName = "Marine Captain", NpcCFrame = CFrame.new(-2440, 73, -3218), MobCFrame = CFrame.new(-1860, 73, -3320) },
    -- Graveyard & Snow Mountain
    { Level = 950, QuestName = "ZombieQuest", QuestLevel = 1, MobName = "Zombie", NpcCFrame = CFrame.new(-5495, 48, -795), MobCFrame = CFrame.new(-5600, 48, -900) },
    { Level = 975, QuestName = "ZombieQuest", QuestLevel = 2, MobName = "Vampire", NpcCFrame = CFrame.new(-5495, 48, -795), MobCFrame = CFrame.new(-6000, 7, -1300) },
    { Level = 1000, QuestName = "SnowMountainQuest", QuestLevel = 1, MobName = "Snow Trooper", NpcCFrame = CFrame.new(609, 401, -5372), MobCFrame = CFrame.new(500, 401, -5500) },
    { Level = 1025, QuestName = "SnowMountainQuest", QuestLevel = 2, MobName = "Winter Warrior", NpcCFrame = CFrame.new(609, 401, -5372), MobCFrame = CFrame.new(1200, 455, -5100) },
    -- Hot and Cold
    { Level = 1100, QuestName = "FireQuest", QuestLevel = 1, MobName = "Lab Subordinate", NpcCFrame = CFrame.new(-6060, 16, -4903), MobCFrame = CFrame.new(-5800, 16, -4800) },
    { Level = 1125, QuestName = "FireQuest", QuestLevel = 2, MobName = "Horned Warrior", NpcCFrame = CFrame.new(-6060, 16, -4903), MobCFrame = CFrame.new(-6400, 16, -5800) },
    { Level = 1200, QuestName = "IceQuest", QuestLevel = 1, MobName = "Magma Ninja", NpcCFrame = CFrame.new(-5428, 16, -5298), MobCFrame = CFrame.new(-5400, 16, -5800) },
    { Level = 1225, QuestName = "IceQuest", QuestLevel = 2, MobName = "Lava Pirate", NpcCFrame = CFrame.new(-5428, 16, -5298), MobCFrame = CFrame.new(-5200, 16, -4800) },
    -- Cursed Ship
    { Level = 1250, QuestName = "ShipQuest1", QuestLevel = 1, MobName = "Ship Deckhand", NpcCFrame = CFrame.new(1038, 125, 32911), MobCFrame = CFrame.new(1100, 125, 33000) },
    { Level = 1275, QuestName = "ShipQuest1", QuestLevel = 2, MobName = "Ship Engineer", NpcCFrame = CFrame.new(1038, 125, 32911), MobCFrame = CFrame.new(900, 125, 32800) },
    { Level = 1300, QuestName = "ShipQuest2", QuestLevel = 1, MobName = "Ship Steward", NpcCFrame = CFrame.new(968, 125, 33242), MobCFrame = CFrame.new(900, 125, 33400) },
    { Level = 1325, QuestName = "ShipQuest2", QuestLevel = 2, MobName = "Ship Officer", NpcCFrame = CFrame.new(968, 125, 33242), MobCFrame = CFrame.new(1000, 125, 33500) },
    -- Forgotten Island
    { Level = 1425, QuestName = "FrostQuest", QuestLevel = 1, MobName = "Sea Soldier", NpcCFrame = CFrame.new(-3054, 237, -10142), MobCFrame = CFrame.new(-3000, 237, -10300) },
    { Level = 1450, QuestName = "FrostQuest", QuestLevel = 2, MobName = "Water Fighter", NpcCFrame = CFrame.new(-3054, 237, -10142), MobCFrame = CFrame.new(-3300, 237, -10500) }
}

local function getCurrentQuestData()
    local myLevel = 700
    pcall(function()
        myLevel = player.Data.Level.Value
    end)
    
    local selectedQuest = Sea2MobQuests[1]
    for i = #Sea2MobQuests, 1, -1 do
        if myLevel >= Sea2MobQuests[i].Level then
            selectedQuest = Sea2MobQuests[i]
            break
        end
    end
    return selectedQuest
end

local function restoreCharacterControl()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "AntiFall" or v.Name == "FarmLock" then v:Destroy() end
            end
        end
    end
    if currentTween then currentTween:Cancel() currentTween = nil end
    isTweening = false
end

if CoreGui:FindFirstChild("AutoFarmMobGui") then CoreGui.AutoFarmMobGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmMobGui"
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
frameStroke.Parent = mainFrame

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 14, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)
statusDot.Parent = mainFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local subText = Instance.new("TextLabel")
subText.Size = UDim2.new(0, 200, 0, 14)
subText.Position = UDim2.new(0, 32, 0, 18)
subText.BackgroundTransparency = 1
subText.Text = "Status: RUNNING [K]"
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
        subText.Text = string.format("Mob: %s | Lv: %d", qData.MobName, qData.Level)
    else
        subText.Text = "Status: PAUSED [K]"
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

-- HÀM BAY AN TOÀN (CHỈ DÙNG KHI BAY XA HOẶC LẤY NHIỆM VỤ)
local function flyToTarget(targetPosition, speed)
    if not isScriptEnabled then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    speed = speed or FLY_SPEED_LONG
    isTweening = true
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "AntiFall" or v.Name == "FarmLock" then v:Destroy() end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    -- Bay vút lên cao né vật cản
    local highPos = Vector3.new(hrp.Position.X, SAFE_HEIGHT, hrp.Position.Z)
    local distUp = (hrp.Position - highPos).Magnitude
    if distUp > 5 then
        local tUp = TweenService:Create(hrp, TweenInfo.new(distUp / speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(highPos)})
        tUp:Play()
        currentTween = tUp
        tUp.Completed:Wait()
    end

    -- Bay ngang qua mục tiêu ở trên cao
    local flyOverPos = Vector3.new(targetPosition.X, SAFE_HEIGHT, targetPosition.Z)
    hrp.CFrame = CFrame.new(hrp.Position, flyOverPos)
    local distAcross = (hrp.Position - flyOverPos).Magnitude
    if distAcross > 5 then
        local tAcross = TweenService:Create(hrp, TweenInfo.new(distAcross / speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(flyOverPos)})
        tAcross:Play()
        currentTween = tAcross
        tAcross.Completed:Wait()
    end

    -- Hạ xuống đúng độ cao farm chuẩn 15 stud
    local finalLanding = CFrame.new(targetPosition.X, targetPosition.Y + FARM_HEIGHT, targetPosition.Z)
    local distDown = (hrp.Position - finalLanding.Position).Magnitude
    if distDown > 2 then
        local tDown = TweenService:Create(hrp, TweenInfo.new(distDown / speed, Enum.EasingStyle.Sine), {CFrame = finalLanding})
        tDown:Play()
        currentTween = tDown
        tDown.Completed:Wait()
    end

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
        if commF then 
            commF:InvokeServer("StartQuest", qName, qLevel) 
        end
    end)
end

local function autoStatPoints()
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("AddPoint", "Melee", 1)
            commF:InvokeServer("AddPoint", "Defense", 1)
            commF:InvokeServer("AddPoint", "Sword", 1)
        end
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
        local myPos = hrp.Position
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, mobName) then
                local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChild("Humanoid")
                if mobHrp and mobHum and mobHum.Health > 0 then
                    local dist = (myPos - mobHrp.Position).Magnitude
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

task.spawn(function()
    while task.wait(0.01) do
        if isScriptEnabled and not isTweening then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                updateUIState()
                autoStatPoints()
                
                local hrp = character.HumanoidRootPart
                local qData = getCurrentQuestData()
                local playerGui = player:WaitForChild("PlayerGui", 2)
                if not playerGui then return end
                
                local mainGui = playerGui:FindFirstChild("Main")
                local questFrame = mainGui and mainGui:FindFirstChild("Quest")

                local hasQuest = false
                if questFrame and questFrame.Visible then
                    hasQuest = true
                end

                if not hasQuest then
                    -- Xóa khóa farm cũ nếu có
                    for _, v in pairs(hrp:GetChildren()) do
                        if v.Name == "FarmLock" then v:Destroy() end
                    end
                    
                    local distToNpc = (hrp.Position - qData.NpcCFrame.Position).Magnitude
                    if distToNpc > 12 then
                        flyToTarget(qData.NpcCFrame.Position, FLY_SPEED_LONG)
                    else
                        startQuest(qData.QuestName, qData.QuestLevel)
                        task.wait(0.5)
                    end
                else
                    local targetMob = getClosestMob(qData.MobName)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        local targetPos = mobHrp.Position
                        local distToMob = (hrp.Position - targetPos).Magnitude
                        
                        if distToMob > 35 then
                            for _, v in pairs(hrp:GetChildren()) do
                                if v.Name == "FarmLock" then v:Destroy() end
                            end
                            flyToTarget(targetPos, FLY_SPEED_SHORT)
                        else
                            -- KHÓA CỨNG VỊ TRÍ LƠ LỬNG 15 STUD TRÊN ĐẦU QUÁI, KHÔNG DÙNG TWEEN NỮA
                            if not hrp:FindFirstChild("FarmLock") then
                                for _, part in pairs(character:GetChildren()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end
                                local bv = Instance.new("BodyVelocity")
                                bv.Name = "FarmLock"
                                bv.Velocity = Vector3.new(0, 0, 0)
                                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                                bv.Parent = hrp
                            end
                            
                            -- Cố định vị trí đứng yên 1 chỗ cách đầu quái đúng 15 stud để chém
                            hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y + FARM_HEIGHT, targetPos.Z)
                            fastAttack()
                        end
                    else
                        for _, v in pairs(hrp:GetChildren()) do
                            if v.Name == "FarmLock" then v:Destroy() end
                        end
                        local distToMobArea = (hrp.Position - qData.MobCFrame.Position).Magnitude
                        if distToMobArea > 35 then
                            flyToTarget(qData.MobCFrame.Position, FLY_SPEED_LONG)
                        end
                    end
                end
            end)
        end
    end
end)
