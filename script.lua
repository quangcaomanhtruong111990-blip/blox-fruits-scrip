local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

local isFarming = false       
local isCheckingQuest = false 
local isTweening = false      

-- Tọa độ vị trí gần NPC nhận nhiệm vụ của 5 Đảo
local ISLAND_DATA = {
    {minLevel = 1,  maxLevel = 9,  name = "BANDIT",  questName = "BanditQuest1", mobPattern = "Bandit",       pos = CFrame.new(1038, 16, 1575)},
    {minLevel = 10, maxLevel = 29, name = "JUNGLE",  questName = "JungleQuest",  mobPattern = "Monkey",       pos = CFrame.new(-1485, 36, 68)},
    {minLevel = 30, maxLevel = 59, name = "PIRATE",  questName = "BuggyQuest1",  mobPattern = "Pirate",       pos = CFrame.new(-1140, 4, 3825)},
    {minLevel = 60, maxLevel = 89, name = "DESERT",  questName = "DesertQuest",  mobPattern = "Desert",       pos = CFrame.new(903, 16, 4376)},
    {minLevel = 90, maxLevel = 9999, name = "SNOW",   questName = "SnowQuest",    mobPattern = "Snow Bandit",  pos = CFrame.new(1389, 88, -1298)}
}

-- Hàm lấy thông tin đảo hiện tại dựa vào Level của nhân vật
local function getCurrentIslandByLevel()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local levelVal = leaderstats:FindFirstChild("Level")
        if levelVal then
            local lvl = levelVal.Value
            for i, data in ipairs(ISLAND_DATA) do
                if lvl >= data.minLevel and lvl <= data.maxLevel then
                    return i
                end
            end
        end
    end
    return 1
end

local currentIsland = getCurrentIslandByLevel()

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoLevelFarmGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 200, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM LEVEL: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm Bay Mượt Chống Kẹt (Noclip & AntiFall)
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
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
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

-- Hàm bay chuyển đảo mượt
local function ultraSlowTeleport(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 150 
    local timeToTravel = distance / speed
    
    isTweening = true
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
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
local function startQuestForIsland(questName)
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

-- 5. Hàm Tìm Quái Linh Hoạt
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
        currentIsland = getCurrentIslandByLevel()
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
        
        local data = ISLAND_DATA[currentIsland]
        toggleBtn.Text = "ĐANG ĐẾN ĐẢO " .. data.name .. "..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            ultraSlowTeleport(data.pos)
            toggleBtn.Text = data.name .. " (LEVEL CHECK)"
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

-- 7. Tự động kiểm tra và cập nhật đảo liên tục theo Level thực tế của nhân vật
task.spawn(function()
    while task.wait(1) do
        if isFarming and not isTweening then
            local realIsland = getCurrentIslandByLevel()
            if realIsland ~= currentIsland then
                currentIsland = realIsland
                local data = ISLAND_DATA[currentIsland]
                toggleBtn.Text = "LÊN LEVEL! ĐẾN " .. data.name
                task.spawn(function()
                    ultraSlowTeleport(data.pos)
                end)
            end
        end
    end
end)

-- 8. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming and not isTweening then
            pcall(function()
                local dialogueGui = playerGui:FindFirstChild("Dialogue")
                if dialogueGui then dialogueGui.Visible = false end

                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                local hrp = character.HumanoidRootPart

                local data = ISLAND_DATA[currentIsland]
                local questName = data.questName
                local mobPattern = data.mobPattern
                local npcPos = data.pos

                local questFrame = playerGui:WaitForChild("Main"):WaitForChild("Quest")

                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    local distToNpc = (hrp.Position - npcPos.Position).Magnitude
                    if distToNpc > 15 then
                        flyToTarget(npcPos)
                        task.wait(0.5)
                    end
                    startQuestForIsland(questName)
                else
                    local targetMob = getClosestMob(mobPattern, 1000)
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
