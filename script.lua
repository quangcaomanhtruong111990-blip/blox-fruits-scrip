local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Cấu hình
local maxQuests = 10           
local banditCount = 0          
local jungleCount = 0          
local pirateCount = 0          
local currentIsland = 1        
local isFarming = false        
local isCheckingQuest = false  
local isTweening = false       

-- Tọa độ trung tâm/bãi quái cho 3 Đảo
local BANDIT_POS = CFrame.new(1038, 16, 1575)
local JUNGLE_POS = CFrame.new(-1485, 36, 68)
local PIRATE_POS = CFrame.new(-1190, 16, 3950) 

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarm3IslandsGui"
screenGui.ResetOnSpawn = false

local success, err = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

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

-- 2. Hàm Bay Giữa Các Đảo An Toàn
local function safeTeleport(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    isTweening = true
    
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "FlyBV" then v:Destroy() end
    end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local currentPos = hrp.Position
    local highPos = CFrame.new(currentPos.X, 350, currentPos.Z)
    
    local dist1 = (hrp.Position - highPos.Position).Magnitude
    local tween1 = TweenService:Create(hrp, TweenInfo.new(dist1 / 200, Enum.EasingStyle.Linear), {CFrame = highPos})
    tween1:Play()
    tween1.Completed:Wait()
    
    local targetHighPos = CFrame.new(targetCFrame.X, 350, targetCFrame.Z)
    local dist2 = (hrp.Position - targetHighPos.Position).Magnitude
    local tween2 = TweenService:Create(hrp, TweenInfo.new(dist2 / 250, Enum.EasingStyle.Linear), {CFrame = targetHighPos})
    tween2:Play()
    tween2.Completed:Wait()
    
    local dist3 = (hrp.Position - targetCFrame.Position).Magnitude
    local tween3 = TweenService:Create(hrp, TweenInfo.new(dist3 / 200, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween3:Play()
    tween3.Completed:Wait()
    
    hrp.CFrame = targetCFrame
    isTweening = false
end

-- Hàm bay mượt ngắn áp sát quái
local function flyToMob(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    if distance < 4 then
        hrp.CFrame = targetCFrame
        return
    end
    
    local speed = 150
    local timeToTravel = distance / speed
    
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
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

-- 4. Các Hàm Nhận Nhiệm Vụ (Đã sửa lại tên đúng chuẩn hệ thống Blox Fruits cho Đảo Khỉ và Đảo Hải Tặc)
local function startBanditQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", "BanditQuest1", 1)
        end
    end)
    task.wait(1.2)
    isCheckingQuest = false
end

local function startJungleQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            -- Tên ID nhiệm vụ chuẩn của Đảo Khỉ là JungleQuest1 thay vì JungleQuest
            commF:InvokeServer("StartQuest", "JungleQuest1", 1)
        end
    end)
    task.wait(1.2)
    isCheckingQuest = false
end

local function startPirateVillageQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", "BuggyQuest1", 1)
        end
    end)
    task.wait(1.2)
    isCheckingQuest = false
end

-- 5. Hàm Tìm Quái Gần Nhất
local function getClosestMob(mobName, maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if mob.Name == mobName then
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
        currentIsland = 1
        isCheckingQuest = false
        isTweening = false
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "FlyBV" then v:Destroy() end
            end
            
            local hrp = character.HumanoidRootPart
            local x, y, z = hrp.CFrame:ToOrientation()
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.fromOrientation(x, y + math.rad(90), z)
        end
        
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and item.ToolTip == "Blox Fruit" then
                        commF:InvokeServer("StoreFruit", item.Name)
                    end
                end
                if character then
                    for _, item in pairs(character:GetChildren()) do
                        if item:IsA("Tool") and item.ToolTip == "Blox Fruit" then
                            commF:InvokeServer("StoreFruit", item.Name)
                        end
                    end
                end
            end
        end)

        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("Cousin", "Buy")
            end
        end)

        task.wait(1)
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and item.ToolTip == "Blox Fruit" then
                        commF:InvokeServer("StoreFruit", item.Name)
                    end
                end
            end
        end)
        
        toggleBtn.Text = "ĐANG BAY VỀ ĐẢO 1..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            safeTeleport(BANDIT_POS)
            toggleBtn.Text = "BANDIT: (0/10)"
        end)
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        isTweening = false
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "FlyBV" then v:Destroy() end
            end
        end
    end
end)

-- 7. Bộ Đếm Quest Cho 3 Đảo
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local mainGui = playerGui:FindFirstChild("Main")
                if mainGui then
                    local questFrame = mainGui:FindFirstChild("Quest")
                    if questFrame then
                        if not questFrame.Visible and isFarming and not isTweening then
                            if currentIsland == 1 then
                                banditCount = banditCount + 1
                                toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxQuests .. ")"
                                
                                if banditCount >= maxQuests then
                                    currentIsland = 2
                                    toggleBtn.Text = "BAY SANG ĐẢO KHỈ..."
                                    task.spawn(function()
                                        safeTeleport(JUNGLE_POS)
                                        toggleBtn.Text = "KHỈ: (0/10)"
                                    end)
                                end
                            elseif currentIsland == 2 then
                                jungleCount = jungleCount + 1
                                toggleBtn.Text = "KHỈ: (" .. jungleCount .. "/" .. maxQuests .. ")"
                                
                                if jungleCount >= maxQuests then
                                    currentIsland = 3
                                    toggleBtn.Text = "BAY SANG LÀNG HẢI TẶC..."
                                    task.spawn(function()
                                        safeTeleport(PIRATE_POS)
                                        toggleBtn.Text = "PIRATE: (0/10)"
                                    end)
                                end
                            elseif currentIsland == 3 then
                                pirateCount = pirateCount + 1
                                toggleBtn.Text = "PIRATE: (" .. pirateCount .. "/" .. maxQuests .. ")"
                                
                                if pirateCount >= maxQuests then
                                    isFarming = false
                                    toggleBtn.Text = "HOÀN THÀNH - OFF"
                                    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                                end
                            end
                            task.wait(1.5)
                        end
                    end
                end
            end
        end)
    end
end)

-- 8. Vòng Lặp Farm Chính (3 Đảo)
task.spawn(function()
    while task.wait(0.1) do
        if isFarming and not isTweening then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                
                local playerGui = player:FindFirstChild("PlayerGui")
                local questVisible = false
                if playerGui and playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest") then
                    questVisible = playerGui.Main.Quest.Visible
                end
                
                -- ĐẢO 1: BANDIT
                if currentIsland == 1 then
                    if not questVisible and not isCheckingQuest then
                        startBanditQuest()
                    end
                    
                    local targetMob = getClosestMob("Bandit", 350)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        flyToMob(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0))
                        
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                    
                -- ĐẢO 2: KHỈ (MONKEY)
                elseif currentIsland == 2 then
                    if not questVisible and not isCheckingQuest then
                        startJungleQuest()
                    end
                    
                    local targetMob = getClosestMob("Monkey", 350)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        flyToMob(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0))
                        
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                    
                -- ĐẢO 3: LÀNG HẢI TẶC (PIRATE)
                elseif currentIsland == 3 then
                    if not questVisible and not isCheckingQuest then
                        startPirateVillageQuest()
                    end
                    
                    local targetMob = getClosestMob("Pirate", 350)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        flyToMob(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0))
                        
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end
            end)
        end
    end
end)
