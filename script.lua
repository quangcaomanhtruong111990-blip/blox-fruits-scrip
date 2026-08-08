local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

local isFarming = false       
local isCheckingQuest = false 
local isTweening = false      

-- Bảng cấu hình cấp độ và tọa độ các đảo chuẩn xác
local ISLAND_DATA = {
    {min = 1,   max = 9,    name = "BANDIT",     quest = "BanditQuest1",     mob = "Bandit",       pos = CFrame.new(1038, 16, 1575)},
    {min = 10,  max = 29,   name = "JUNGLE",     quest = "JungleQuest",      mob = "Monkey",       pos = CFrame.new(-1485, 36, 68)},
    {min = 30,  max = 59,   name = "PIRATE",     quest = "BuggyQuest1",      mob = "Pirate",       pos = CFrame.new(-1140, 4, 3825)},
    {min = 60,  max = 89,   name = "DESERT",     quest = "DesertQuest",      mob = "Desert",       pos = CFrame.new(903, 16, 4376)},
    {min = 90,  max = 119,  name = "SNOW",       quest = "SnowQuest",        mob = "Snow Bandit",  pos = CFrame.new(1389, 88, -1298)},
    {min = 120, max = 9999, name = "MARINE",     quest = "MarineQuest",      mob = "Chief Petty Officer", pos = CFrame.new(-2466, 17, 3792)}
}

-- Hàm quét số Cấp chính xác từ màn hình game
local function getPlayerLevel()
    local success, level = pcall(function()
        for _, v in ipairs(playerGui:GetDescendants()) do
            if v:IsA("TextLabel") and string.find(v.Text, "Cấp") then
                local num = tonumber(string.match(v.Text, "%d+"))
                if num and num > 0 then return num end
            end
        end
        return nil
    end)
    if success and level then return level end
    return 1513 -- Mặc định phòng hờ level hiện tại của bạn
end

-- Hàm tìm đúng đảo dựa theo level hiện tại
local function getIslandIndexByLevel(lvl)
    for i, data in ipairs(ISLAND_DATA) do
        if lvl >= data.min and lvl <= data.max then
            return i
        end
    end
    return #ISLAND_DATA
end

local currentIsland = getIslandIndexByLevel(getPlayerLevel())

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoLevelFarmGui"
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
toggleBtn.Text = "FARM LEVEL: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm Bay Mượt Chống Kẹt
local function flyToTarget(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    if distance < 8 then
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

local function ultraSlowTeleport(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 150 
    local timeToTravel = distance / speed
    isTweening = true
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    
    tween.Completed:Wait()
    if bv then bv:Destroy() end
    isTweening = false
end

-- 3. Hàm Trang Bị Vũ Khí
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

-- 4. Hàm Nhận Nhiệm Vụ
local function startQuest(questName)
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", questName, 1)
        end
    end)
    task.wait(1.2)
    isCheckingQuest = false
end

-- 5. Hàm Tìm Quái
local function getClosestMob(mobNamePattern, maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

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

-- 6. Xử Lý Bấm Nút ON/OFF
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        isCheckingQuest = false
        local currentLvl = getPlayerLevel()
        currentIsland = getIslandIndexByLevel(currentLvl)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
        
        local data = ISLAND_DATA[currentIsland]
        toggleBtn.Text = "LV " .. currentLvl .. " -> ĐẢO " .. data.name
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            ultraSlowTeleport(data.pos)
        end)
    else
        toggleBtn.Text = "FARM LEVEL: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
end)

-- 7. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming and not isTweening then
            pcall(function()
                -- Cập nhật liên tục level theo thời gian thực để nhảy đảo nếu đạt mốc
                local realLvl = getPlayerLevel()
                local correctIsland = getIslandIndexByLevel(realLvl)
                if correctIsland ~= currentIsland then
                    currentIsland = correctIsland
                    local newData = ISLAND_DATA[currentIsland]
                    toggleBtn.Text = "LÊN CẤP! -> " .. newData.name
                    ultraSlowTeleport(newData.pos)
                    return
                end

                local dialogueGui = playerGui:FindFirstChild("Dialogue")
                if dialogueGui then dialogueGui.Visible = false end

                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                local hrp = character.HumanoidRootPart

                local data = ISLAND_DATA[currentIsland]
                local questFrame = playerGui:WaitForChild("Main"):WaitForChild("Quest")

                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    local distToNpc = (hrp.Position - data.pos.Position).Magnitude
                    if distToNpc > 15 then
                        flyToTarget(data.pos)
                        task.wait(0.5)
                    end
                    startQuest(data.quest)
                else
                    local targetMob = getClosestMob(data.mob, 1000)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        local distance = (hrp.Position - mobHrp.Position).Magnitude
                        
                        flyToTarget(mobHrp.CFrame * CFrame.new(0, 9, 0))
                        
                        if distance <= 15 then
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                            
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end
                    end
                end
            end)
        end
    end
end)
