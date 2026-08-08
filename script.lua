local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cấu hình
local maxBanditQuests = 10     -- Làm đủ 10 lần Q Bandit
local banditCount = 0          -- Biến đếm số lần hoàn thành Q
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false  -- Chống spam nhận Q

-- Tọa độ Đảo Khởi Đầu và Đảo Khỉ
local BANDIT_POS = CFrame.new(1059, 16, 1549)
local JUNGLE_POS = CFrame.new(-1612.8, 36.8, 149.2)

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmBanditToJungleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 160, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 15
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm Tự Trang Bị Vũ Khí
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

-- 3. Hàm Nhận Nhiệm Vụ Bandit
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

-- 4. Hàm Tìm Quái Bandit Gần Nhất
local function getClosestBandit(maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if mob.Name == "Bandit" then
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

-- 5. Xử Lý Bấm Nút ON/OFF
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        banditCount = 0
        toggleBtn.Text = "BANDIT: (0/10)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BẮT ĐẦU",
            Text = "Farm 10 lần Bandit -> Tele Đảo Khỉ -> Dừng",
            Duration = 3
        })
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- 6. Bộ Đếm 10 Lần Quest Bandit -> Bay Sang Đảo Khỉ -> TẮT SCRIPT
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming then
        banditCount = banditCount + 1
        toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxBanditQuests .. ")"
        
        -- Khi đủ 10 lần Bandit
        if banditCount >= maxBanditQuests then
            isFarming = false -- Tắt trạng thái farm ngay lập tức
            toggleBtn.Text = "FARM: OFF (ĐÃ TỚI ĐẢO KHỈ)"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            
            -- Teleport nhân vật sang Đảo Khỉ
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = JUNGLE_POS
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "HOÀN THÀNH!",
                Text = "Đã hoàn thành 10 Q Bandit và bay sang Đảo Khỉ. Script đã DỪNG!",
                Duration = 6
            })
        end
    end
end)

-- 7. Vòng Lặp Farm Bandit
task.spawn(function()
    while task.wait(0.1) do
        if isFarming then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                
                -- Nhận Quest nếu chưa có
                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    startBanditQuest()
                    return
                end
                
                -- Tìm và đánh Bandit
                local targetMob = getClosestBandit(350)
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
                    
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                else
                    character.HumanoidRootPart.CFrame = BANDIT_POS
                end
            end)
        end
    end
end)
