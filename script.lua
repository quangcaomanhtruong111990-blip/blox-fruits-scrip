local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- RemoteEvent Fast Attack Blox Fruits
local Net = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:FindFirstChild("Net")
local RegisterAttack = Net and Net:FindFirstChild("RE/RegisterAttack")

-- Cấu hình
local maxQuests = 1           -- Số lần làm Q cho mỗi đảo (1 lần)
local banditCount = 0          -- Đếm Q Bandit
local jungleCount = 0          -- Đếm Q Khỉ
local pirateCount = 0          -- Đếm Q Pirate (Đảo 3)
local currentIsland = 1        -- 1: Bandit, 2: Khỉ, 3: Làng Hải Tặc
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false  -- Chống spam nhận Q
local isTweening = false       -- Đang trong quá trình bay giữa đảo
local isAttacking = false      -- Trạng thái xả đòn (Chỉ bật khi đã đáp đất)

-- Tọa độ trung tâm/bãi quái cho 3 Đảo (TUYỆT ĐỐI KHÔNG ĐỨNG GẦN NPC)
local BANDIT_POS = CFrame.new(1038, 16, 1575)
local JUNGLE_POS = CFrame.new(-1485, 36, 68)
local PIRATE_POS = CFrame.new(-1190, 16, 3950) 

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarm3IslandsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

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

-- 2. Hàm Bay Siêu Chậm An Toàn (Bay trên cao giữa các Đảo)
local function ultraSlowTeleport(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    isAttacking = false -- Tắt đánh khi bay chuyển đảo
    local hrp = character.HumanoidRootPart
    local highTarget = targetCFrame * CFrame.new(0, 25, 0)
    local distance = (hrp.Position - highTarget.Position).Magnitude
    local speed = 150 
    local timeToTravel = distance / speed
    
    isTweening = true
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyBV"
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = hrp
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = highTarget})
    tween:Play()
    
    tween.Completed:Wait()
    
    if bodyVelocity then bodyVelocity:Destroy() end
    isTweening = false
end

-- Hàm tìm tọa độ mặt đất bằng Raycast
local function getGroundPos(pos)
    local raycastResult = workspace:Raycast(pos + Vector3.new(0, 25, 0), Vector3.new(0, -100, 0))
    if raycastResult then
        return raycastResult.Position + Vector3.new(0, 3, 0)
    end
    return pos
end

-- Hàm bay đến quái: Bay lơ lửng trên cao -> Hạ từ từ xuống đất sát quái
local function flyToMobAndLand(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    isAttacking = false -- Tắt đánh trong suốt quá trình bay
    local hrp = character.HumanoidRootPart
    
    -- Bước 1: Bay tới trên đầu quái (độ cao Y + 25)
    local highTarget = CFrame.new(targetCFrame.Position + Vector3.new(0, 25, 0))
    local distHigh = (hrp.Position - highTarget.Position).Magnitude
    if distHigh > 6 then
        local tween1 = TweenService:Create(hrp, TweenInfo.new(distHigh / 140, Enum.EasingStyle.Linear), {CFrame = highTarget})
        tween1:Play()
        tween1.Completed:Wait()
    end
    
    -- Bước 2: Hạ từ từ xuống đất
    local groundPos = getGroundPos(targetCFrame.Position)
    local landTarget = CFrame.new(groundPos, targetCFrame.Position)
    local tween2 = TweenService:Create(hrp, TweenInfo.new(0.6, Enum.EasingStyle.QuadOut), {CFrame = landTarget})
    tween2:Play()
    tween2.Completed:Wait()
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

-- 4. Các Hàm Nhận Nhiệm Vụ Từ Xa
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
            commF:InvokeServer("StartQuest", "JungleQuest", 1)
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
        isAttacking = false
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") then v:Destroy() end
            end
            
            local hrp = character.HumanoidRootPart
            local x, y, z = hrp.CFrame:ToOrientation()
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.fromOrientation(x, y + math.rad(90), z)
        end
        
        -- Cất trái cây vào rương
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

        -- Random trái cây (Cousin)
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
            ultraSlowTeleport(BANDIT_POS)
            toggleBtn.Text = "BANDIT: (0/10)"
        end)
    else
        isAttacking = false
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") then v:Destroy() end
            end
        end
    end
end)

-- 7. Bộ Đếm Quest Cho 3 Đảo
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isTweening then
        if currentIsland == 1 then
            banditCount = banditCount + 1
            toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxQuests .. ")"
            
            if banditCount >= maxQuests then
                currentIsland = 2
                isAttacking = false
                toggleBtn.Text = "BAY SANG ĐẢO KHỈ..."
                task.spawn(function()
                    ultraSlowTeleport(JUNGLE_POS)
                    toggleBtn.Text = "KHỈ: (0/10)"
                end)
            end
        elseif currentIsland == 2 then
            jungleCount = jungleCount + 1
            toggleBtn.Text = "KHỈ: (" .. jungleCount .. "/" .. maxQuests .. ")"
            
            if jungleCount >= maxQuests then
                currentIsland = 3
                isAttacking = false
                toggleBtn.Text = "BAY SANG LÀNG HẢI TẶC..."
                task.spawn(function()
                    ultraSlowTeleport(PIRATE_POS)
                    toggleBtn.Text = "PIRATE: (0/10)"
                end)
            end
        elseif currentIsland == 3 then
            pirateCount = pirateCount + 1
            toggleBtn.Text = "PIRATE: (" .. pirateCount .. "/" .. maxQuests .. ")"
            
            if pirateCount >= maxQuests then
                isFarming = false
                isAttacking = false
                toggleBtn.Text = "HOÀN THÀNH - OFF"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end
    end
end)

-- 8. Anti-AFK
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- 9. Noclip
RunService.Stepped:Connect(function()
    if isFarming then
        local character = player.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 10. Luồng Đánh Siêu Tốc (Chỉ hoạt động khi isAttacking = true)
task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if isFarming and isAttacking then
            pcall(function()
                local character = player.Character
                if character then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
                
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)

                if RegisterAttack then
                    RegisterAttack:FireServer(0.001)
                end
            end)
        end
    end
end)

-- 11. Vòng Lặp Farm Chính (Hạ xuống đất mới đánh, khi bay thì ngắt đánh)
task.spawn(function()
    while task.wait(0.05) do
        if isFarming and not isTweening then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local mobName = ""
                if currentIsland == 1 then
                    mobName = "Bandit"
                    if questFrame and not questFrame.Visible and not isCheckingQuest then startBanditQuest() end
                elseif currentIsland == 2 then
                    mobName = "Monkey"
                    if questFrame and not questFrame.Visible and not isCheckingQuest then startJungleQuest() end
                elseif currentIsland == 3 then
                    mobName = "Pirate"
                    if questFrame and not questFrame.Visible and not isCheckingQuest then startPirateVillageQuest() end
                end

                local targetMob = getClosestMob(mobName, 350)
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    -- Tắt đánh hoàn toàn khi chuẩn bị di chuyển
                    isAttacking = false
                    
                    -- Bay lơ lửng rồi đáp thẳng xuống mặt đất
                    flyToMobAndLand(targetMob.HumanoidRootPart.CFrame)
                    if not isFarming then return end
                    
                    -- Đáp đất thành công mới trang bị vũ khí và bật đánh siêu tốc
                    equipWeapon()
                    isAttacking = true
                    
                    -- Đứng dưới đất bám sát quái và xả đòn cho tới khi quái chết
                    local targetHumanoid = targetMob:FindFirstChild("Humanoid")
                    local targetHrp = targetMob:FindFirstChild("HumanoidRootPart")
                    
                    while isFarming and targetHumanoid and targetHumanoid.Health > 0 and targetHrp do
                        local groundPos = getGroundPos(targetHrp.Position)
                        character.HumanoidRootPart.CFrame = CFrame.new(groundPos, targetHrp.Position)
                        task.wait(0.01)
                    end
                    
                    -- Quái chết -> Tắt đánh để chuyển quái khác
                    isAttacking = false
                end
            end)
        end
    end
end)
