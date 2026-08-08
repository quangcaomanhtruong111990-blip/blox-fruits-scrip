local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

-- Cấu hình: Đặt số lượng nhiệm vụ mỗi đảo là 1 để test nhanh
local maxQuests = 1           
local banditCount = 0         
local jungleCount = 0         
local pirateCount = 0         
local desertCount = 0         
local currentIsland = 1       -- 1: Bandit, 2: Khỉ, 3: Hải Tặc, 4: Sa Mạc
local isFarming = false       
local isCheckingQuest = false 
local isTweening = false      

-- Tọa độ vị trí gần NPC nhận nhiệm vụ của 4 Đảo
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local JUNGLE_NPC_POS = CFrame.new(-1485, 36, 68)
local PIRATE_NPC_POS = CFrame.new(-1140, 4, 3825)
local DESERT_NPC_POS = CFrame.new(903, 16, 4376)

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarm4IslandsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 180, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
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

-- Hàm bay chuyển đảo
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
        banditCount = 0
        jungleCount = 0
        pirateCount = 0
        desertCount = 0
        currentIsland = 1
        isCheckingQuest = false
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
        
        toggleBtn.Text = "ĐANG BAY VỀ ĐẢO 1..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            ultraSlowTeleport(BANDIT_NPC_POS)
            toggleBtn.Text = "BANDIT: (0/1)"
        end)
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
end)

-- 7. Bộ Đếm Quest Tự Động Chuyển Đảo
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isTweening then
        if currentIsland == 1 then
            banditCount = banditCount + 1
            toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxQuests .. ")"
            if banditCount >= maxQuests then
                currentIsland = 2
                toggleBtn.Text = "BAY SANG ĐẢO KHỈ..."
                task.spawn(function()
                    ultraSlowTeleport(JUNGLE_NPC_POS)
                    toggleBtn.Text = "KHỈ: (0/1)"
                end)
            end
        elseif currentIsland == 2 then
            jungleCount = jungleCount + 1
            toggleBtn.Text = "KHỈ: (" .. jungleCount .. "/" .. maxQuests .. ")"
            if jungleCount >= maxQuests then
                currentIsland = 3
                toggleBtn.Text = "BAY SANG HẢI TẶC..."
                task.spawn(function()
                    ultraSlowTeleport(PIRATE_NPC_POS)
                    toggleBtn.Text = "PIRATE: (0/1)"
                end)
            end
        elseif currentIsland == 3 then
            pirateCount = pirateCount + 1
            toggleBtn.Text = "PIRATE: (" .. pirateCount .. "/" .. maxQuests .. ")"
            if pirateCount >= maxQuests then
                currentIsland = 4
                toggleBtn.Text = "BAY SANG SA MẠC..."
                task.spawn(function()
                    ultraSlowTeleport(DESERT_NPC_POS)
                    toggleBtn.Text = "DESERT: (0/1)"
                end)
            end
        elseif currentIsland == 4 then
            desertCount = desertCount + 1
            toggleBtn.Text = "DESERT: (" .. desertCount .. "/" .. maxQuests .. ")"
            if desertCount >= maxQuests then
                isFarming = false
                toggleBtn.Text = "HOÀN THÀNH 4 ĐẢO - OFF"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end
    end
end)

-- 8. Vòng Lặp Farm Chính 4 Đảo
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

                local questName, mobPattern, npcPos
                if currentIsland == 1 then
                    questName = "BanditQuest1"
                    mobPattern = "Bandit"
                    npcPos = BANDIT_NPC_POS
                elseif currentIsland == 2 then
                    questName = "JungleQuest"
                    mobPattern = "Monkey"
                    npcPos = JUNGLE_NPC_POS
                elseif currentIsland == 3 then
                    questName = "BuggyQuest1"
                    mobPattern = "Pirate"
                    npcPos = PIRATE_NPC_POS
                elseif currentIsland == 4 then
                    questName = "DesertQuest"
                    mobPattern = "Desert"
                    npcPos = DESERT_NPC_POS
                end

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
