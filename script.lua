local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local maxBanditQuests = 10     -- Số lần làm Quest
local banditCount = 0         -- Đếm số lần đã làm xong
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false -- Biến khóa chống spam nhận Q

-- Tọa độ Đảo Khỉ
local JUNGLE_POS = CFrame.new(-1612, 37, 149)

-- 1. Tạo Giao Diện Nút Bật/Tắt (Toggle UI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmBanditGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 140, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm Trang Bị Vũ Khí
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

-- 3. Hàm Nhận Nhiệm Vụ Bandit (Chống Spam An Toàn)
local function startBanditQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", "BanditQuest1", 1)
        end
    end)
    
    task.wait(1.2) -- Chờ 1.2s để game nhận Q xong rồi mới mở khóa
    isCheckingQuest = false
end

-- 4. Hàm Tìm Quái Bandit
local function getClosestMob(maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
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
    return closestMob
end

-- 5. Xử Lý Sự Kiện Bấm Nút ON/OFF
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        banditCount = 0 -- Reset về 0/10 khi bật lại
        toggleBtn.Text = "FARM: ON (0/10)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto Farm Bandit",
            Text = "Đã BẬT! Bắt đầu farm 10 lần Quest từ đầu.",
            Duration = 3
        })
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto Farm Bandit",
            Text = "Đã TẮT script hoàn toàn!",
            Duration = 3
        })
    end
end)

-- 6. Bộ Đếm 10 Lần Hoàn Thành Quest
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming then
        banditCount = banditCount + 1
        toggleBtn.Text = "FARM: ON (" .. banditCount .. "/" .. maxBanditQuests .. ")"
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Tiến Độ Farm",
            Text = "Đã xong: " .. banditCount .. "/" .. maxBanditQuests .. " nhiệm vụ",
            Duration = 3
        })
        
        -- Khi đủ 10 lần -> Bay sang Đảo Khỉ & TỰ TẮT
        if banditCount >= maxBanditQuests then
            isFarming = false
            toggleBtn.Text = "FARM: OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = JUNGLE_POS
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "HOÀN THÀNH!",
                Text = "Đã tới Đảo Khỉ. Script đã TẮT!",
                Duration = 6
            })
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
                
                -- Chỉ nhận Q nếu bảng Quest CHƯA HIỆN và KHÔNG TRONG TRẠNG THÁI ĐANG CHỜ
                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    startBanditQuest()
                    return -- Dừng 1 nhịp vòng lặp để nhân vật di chuyển đi đánh
                end
                
                -- Tìm quái đánh
                local targetMob = getClosestMob(300)
                
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    
                    -- Đứng cao 9 studs chuẩn đòn đánh
                    character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 9, 0)
                    
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end)
        end
    end
end)
