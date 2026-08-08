local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cấu hình
local maxQuestEachIsland = 10  -- Mãi đảo 10 lần Quest
local currentIsland = "Bandit"  -- Trạng thái bắt đầu: "Bandit" hoặc "Jungle"
local questCount = 0           -- Biến đếm số lần hoàn thành Quest
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false  -- Biến khóa chống spam nhận Quest

-- Tọa độ 2 đảo
local BANDIT_POS = CFrame.new(1059, 16, 1549)
local JUNGLE_POS = CFrame.new(-1612.8, 36.8, 149.2)

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmComboGui"
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

-- 3. Hàm Nhận Nhiệm Vụ Theo Đảo
local function startQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            if currentIsland == "Bandit" then
                commF:InvokeServer("StartQuest", "BanditQuest1", 1)
            elseif currentIsland == "Jungle" then
                commF:InvokeServer("StartQuest", "JungleQuest", 1)
            end
        end
    end)
    
    task.wait(1.2)
    isCheckingQuest = false
end

-- 4. Hàm Tìm Quái Tương Ứng Đảo Gần Nhất
local function getClosestMob(maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            local isTargetMob = false
            if currentIsland == "Bandit" and mob.Name == "Bandit" then
                isTargetMob = true
            elseif currentIsland == "Jungle" and (mob.Name == "Monkey" or mob.Name == "Gorilla") then
                isTargetMob = true
            end

            if isTargetMob then
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
        currentIsland = "Bandit"
        questCount = 0
        toggleBtn.Text = "BANDIT: (0/10)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto Farm Combo",
            Text = "Đã BẬT! Bắt đầu farm 10 lần Bandit...",
            Duration = 3
        })
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- 6. Bộ Đếm 10 Lần Mãi Đảo & Tự Chuyển Đảo / Tắt Script
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming then
        questCount = questCount + 1
        
        if currentIsland == "Bandit" then
            toggleBtn.Text = "BANDIT: (" .. questCount .. "/" .. maxQuestEachIsland .. ")"
            
            -- Xong 10 lần Bandit -> Bay sang Đảo Khỉ
            if questCount >= maxQuestEachIsland then
                currentIsland = "Jungle"
                questCount = 0
                toggleBtn.Text = "KHỈ: (0/10)"
                
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = JUNGLE_POS
                end
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "CHUYỂN ĐẢO",
                    Text = "Xong 10 Bandit! Đang chuyển sang Đảo Khỉ...",
                    Duration = 4
                })
            end
            
        elseif currentIsland == "Jungle" then
            toggleBtn.Text = "KHỈ: (" .. questCount .. "/" .. maxQuestEachIsland .. ")"
            
            -- Xong 10 lần Khỉ -> TẮT SCRIPT HOÀN TOÀN
            if questCount >= maxQuestEachIsland then
                isFarming = false
                toggleBtn.Text = "FARM: OFF (HOÀN THÀNH)"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "HOÀN THÀNH!",
                    Text = "Đã xong 10 Q Bandit + 10 Q Khỉ. Script đã TẮT!",
                    Duration = 6
                })
            end
        end
    end
end)

-- 7. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                
                -- Tự nhận Quest nếu bảng Q đang ẩn
                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    startQuest()
                    return
                end
                
                -- Tìm quái đánh
                local targetMob = getClosestMob(350)
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
                    
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                else
                    -- Giữ vị trí tại Đảo tương ứng nếu quái chưa kịp spawn
                    if currentIsland == "Bandit" then
                        character.HumanoidRootPart.CFrame = BANDIT_POS
                    elseif currentIsland == "Jungle" then
                        character.HumanoidRootPart.CFrame = JUNGLE_POS
                    end
                end
            end)
        end
    end
end)
