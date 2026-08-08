local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cấu hình
local maxBanditQuests = 10     -- Làm đủ 10 lần Q Bandit
local banditCount = 0          -- Biến đếm số lần hoàn thành Q
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false  -- Chống spam nhận Q
local reachedJungleState = 0   -- 0: Đang farm Bandit, 1: Đã sang Đảo Khỉ (chờ nhận Q), 2: Đã nhận Q Đảo Khỉ & đứng yên

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
toggleBtn.Size = UDim2.new(0, 170, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
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

-- 4. Hàm Nhận Nhiệm Vụ Đảo Khỉ
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

-- 5. Hàm Tìm Quái Bandit Gần Nhất
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

-- 6. Xử Lý Bấm Nút ON/OFF
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        banditCount = 0
        reachedJungleState = 0
        toggleBtn.Text = "BANDIT: (0/10)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BẮT ĐẦU",
            Text = "Farm 10 Bandit -> Tele Đảo Khỉ nhận Q -> Đứng yên",
            Duration = 3
        })
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- 7. Bộ Đếm 10 Lần Quest Bandit -> Chuyển Trạng Thái Đảo Khỉ
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and reachedJungleState == 0 then
        banditCount = banditCount + 1
        toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxBanditQuests .. ")"
        
        -- Khi đủ 10 lần Bandit
        if banditCount >= maxBanditQuests then
            reachedJungleState = 1 -- Chuyển sang bước sang Đảo Khỉ nhận Q
            toggleBtn.Text = "ĐANG TỚI ĐẢO KHỈ..."
            
            -- Teleport sang Đảo Khỉ
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = JUNGLE_POS
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "CHUYỂN ĐẢO",
                Text = "Đã xong 10 Q Bandit! Đang sang Đảo Khỉ nhận Quest...",
                Duration = 4
            })
        end
    end
end)

-- 8. Vòng Lặp Chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                -- Giai đoạn 1: Farm Bandit 10 lần
                if reachedJungleState == 0 then
                    equipWeapon()
                    
                    if questFrame and not questFrame.Visible and not isCheckingQuest then
                        startBanditQuest()
                        return
                    end
                    
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
                    
                -- Giai đoạn 2: Tới Đảo Khỉ và Nhận Quest
                elseif reachedJungleState == 1 then
                    character.HumanoidRootPart.CFrame = JUNGLE_POS
                    
                    if questFrame and not questFrame.Visible and not isCheckingQuest then
                        startJungleQuest()
                        task.wait(1)
                    end
                    
                    -- Nếu bảng Quest đã hiện (nhận xong Q Đảo Khỉ) -> Chuyển sang đứng yên
                    if questFrame and questFrame.Visible then
                        reachedJungleState = 2
                        toggleBtn.Text = "ĐÃ NHẬN Q KHỈ (ĐỨNG YÊN)"
                        
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "HOÀN THÀNH",
                            Text = "Đã nhận Quest Đảo Khỉ! Đang đứng yên giữ Script.",
                            Duration = 5
                        })
                    end
                    
                -- Giai đoạn 3: Giữ nguyên vị trí ở Đảo Khỉ, không đánh quái, không tắt script
                elseif reachedJungleState == 2 then
                    character.HumanoidRootPart.CFrame = JUNGLE_POS
                end
            end)
        end
    end
end)
