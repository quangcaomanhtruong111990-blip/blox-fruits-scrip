local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cấu hình
local maxBanditQuests = 10     -- Làm 10 lần Q Bandit
local banditCount = 0          -- Biến đếm
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false  -- Chống spam

-- Trạng thái: 0 = Đang ở Đảo Bandit, 1 = Đã sang Đảo Khỉ (Khóa vĩnh viễn không cho về đảo cũ)
local isAtJungle = false

-- Tọa độ 2 Đảo
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
toggleBtn.Size = UDim2.new(0, 180, 0, 45)
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
        isAtJungle = false
        toggleBtn.Text = "BANDIT: (0/10)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "BẮT ĐẦU",
            Text = "Farm 10 Bandit -> Tới Đảo Khỉ nhận Q -> Đứng yên!",
            Duration = 3
        })
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- 7. Bộ Đếm 10 Lần Quest Bandit (CHỈ HOẠT ĐỘNG KHI CHƯA SANG ĐẢO KHỈ)
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isAtJungle then
        banditCount = banditCount + 1
        toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxBanditQuests .. ")"
        
        -- Khi đủ 10 lần Bandit -> Khóa chế độ Đảo Khỉ ngay lập tức
        if banditCount >= maxBanditQuests then
            isAtJungle = true -- KHÓA VĨNH VIỄN, KHÔNG BAO GIỜ CHẠY LẠI ĐẢO BANDIT NỮA
            toggleBtn.Text = "ĐẢO KHỈ (ĐỨNG YÊN)"
            
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = JUNGLE_POS
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "HOÀN THÀNH BANDIT",
                Text = "Đã xong 10 Q Bandit! Đang giữ vị trí ở Đảo Khỉ.",
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
                
                -- GIAI ĐOẠN 1: ĐANG Ở ĐẢO BANDIT
                if not isAtJungle then
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
                    
                -- GIAI ĐOẠN 2: ĐÃ CHUYỂN SANG ĐẢO KHỈ (CỐ ĐỊNH HOÀN TOÀN TẠI ĐẢO KHỈ)
                else
                    -- Cố định tọa độ ở Đảo Khỉ, không cho di chuyển đi đâu khác
                    character.HumanoidRootPart.CFrame = JUNGLE_POS
                    
                    -- Nếu chưa nhận Quest ở Đảo Khỉ thì nhận
                    if questFrame and not questFrame.Visible and not isCheckingQuest then
                        startJungleQuest()
                    end
                end
            end)
        end
    end
end)
