local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

local isFarming = false       
local isCheckingQuest = false 

-- Danh sách quái Sea 2 chuẩn tên tiếng Anh
local SEA2_MOB_DATA = {
    {minLvl = 700,  maxLvl = 724,  quest = "Area1Quest",        mob = "Raider",            pos = CFrame.new(-425, 73, 2996)},
    {minLvl = 725,  maxLvl = 774,  quest = "Area1Quest",        mob = "Mercenary",         pos = CFrame.new(-868, 141, 1398)},
    {minLvl = 775,  maxLvl = 874,  quest = "Area2Quest",        mob = "Swan Pirate",       pos = CFrame.new(878, 122, 1235)},
    {minLvl = 875,  maxLvl = 949,  quest = "MarineQuest2",      mob = "Marine Lieutenant", pos = CFrame.new(-2840, 73, -3010)},
    {minLvl = 950,  maxLvl = 999,  quest = "MarineQuest2",      mob = "Marine Captain",    pos = CFrame.new(-3100, 73, -2840)},
    {minLvl = 1000, maxLvl = 1099, quest = "ZombieQuest",       mob = "Zombie",            pos = CFrame.new(-5490, 48, -795)},
    {minLvl = 1100, maxLvl = 1174, quest = "SnowMountainQuest", mob = "Snow Trooper",      pos = CFrame.new(1150, 410, -5180)},
    {minLvl = 1175, maxLvl = 1249, quest = "SnowMountainQuest", mob = "Winter Warrior",     pos = CFrame.new(1280, 430, -5400)},
    {minLvl = 1250, maxLvl = 1274, quest = "ShipQuest1",        mob = "Ship Deckhand",     pos = CFrame.new(1030, 125, 32900)},
    {minLvl = 1275, maxLvl = 1299, quest = "ShipQuest1",        mob = "Ship Engineer",     pos = CFrame.new(920, 130, 32800)},
    {minLvl = 1300, maxLvl = 1324, quest = "ShipQuest2",        mob = "Ship Steward",      pos = CFrame.new(915, 130, 33400)}, -- Bếp Phó
    {minLvl = 1325, maxLvl = 1349, quest = "ShipQuest2",        mob = "Ship Officer",      pos = CFrame.new(915, 180, 33200)},
    {minLvl = 1350, maxLvl = 1424, quest = "IceFireQuest",      mob = "Horned Warrior",    pos = CFrame.new(-6400, 15, -5800)},
    {minLvl = 1425, maxLvl = 9999, quest = "IceFireQuest",      mob = "Magma Ninja",       pos = CFrame.new(-5400, 15, -5800)}
}

local function getRealPlayerLevel()
    local success, level = pcall(function()
        for _, descendant in ipairs(playerGui:GetDescendants()) do
            if descendant:IsA("TextLabel") and string.find(descendant.Text, "Cấp") then
                local num = tonumber(string.match(descendant.Text, "%d+"))
                if num and num > 0 then return num end
            end
        end
        return nil
    end)
    if success and level then return level end
    return 1500
end

local function getTargetData()
    local lvl = getRealPlayerLevel()
    for _, data in ipairs(SEA2_MOB_DATA) do
        if lvl >= data.minLvl and lvl <= data.maxLvl then
            return data
        end
    end
    return SEA2_MOB_DATA[#SEA2_MOB_DATA]
end

-- 1. Giao diện ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmSea2Gui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 220, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "AUTO FARM SEA 2: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Bay mượt
local function flyToTarget(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    if distance < 6 then
        hrp.CFrame = targetCFrame
        return
    end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    local speed = 250
    local timeToTravel = distance / speed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "AntiFall" then v:Destroy() end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    tween:Play()
    tween.Completed:Connect(function()
        if bv then bv:Destroy() end
    end)
end

local function equipWeapon()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not character or not backpack then return end
    
    if not character:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword" or item.ToolTip == "Blox Fruit") then
                character.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

local function startQuestRemote(questName)
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", questName, 2)
        end
    end)
    task.wait(1)
    isCheckingQuest = false
end

-- Tìm quái theo Quest hiện tại
local function getClosestMob(mobNamePattern)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = 2000

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, mobNamePattern) then
                local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                local mobHumanoid = mob:FindFirstChild("Humanoid")
                
                if mobHrp and mobHumanoid and mobHumanoid.Health > 0 then
                    local distance = (hrp.Position - mobHrp.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestMob = mob
                    end
                end
            end
        end
    end
    return closestMob
end

toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        isCheckingQuest = false
        toggleBtn.Text = "FARM SEA 2: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        toggleBtn.Text = "AUTO FARM SEA 2: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if isFarming then
            pcall(function()
                local dialogueGui = playerGui:FindFirstChild("Dialogue")
                if dialogueGui then dialogueGui.Visible = false end

                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                local hrp = character.HumanoidRootPart

                local targetData = getTargetData()
                local questFrame = playerGui:WaitForChild("Main"):WaitForChild("Quest")

                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    startQuestRemote(targetData.quest)
                end

                local targetMob = getClosestMob("Ship Steward") or getClosestMob(targetData.mob)
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    local distance = (hrp.Position - mobHrp.Position).Magnitude
                    
                    flyToTarget(mobHrp.CFrame * CFrame.new(0, 8, 0))
                    
                    if distance <= 15 then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                else
                    flyToTarget(targetData.pos)
                end
            end)
        end
    end
end)
