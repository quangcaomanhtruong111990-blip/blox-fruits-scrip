local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local maxJungleQuests = 10     -- Làm 10 lần Q Đảo Khỉ
local jungleCount = 0          -- Đếm số lần xong Q
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false  -- Chống spam

-- Tọa độ Đảo Khỉ
local JUNGLE_CFRAME = CFrame.new(-1612.8, 36.8, 149.2)

-- 1. Giao Diện Nút ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmJungleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 150, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM KHỈ: OFF"
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

-- 3. Hàm Tự Đặt Điểm Hồi Sinh (Set Spawn Point) tại Đảo Khỉ
local function setJungleSpawn()
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("SetSpawnPoint")
        end
    end)
end

-- 4. Hàm Nhận Nhiệm Vụ Khỉ
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

-- 5. Hàm Tìm Quái Khỉ Gần Nhất
local function getClosestMob(maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if mob.Name == "Monkey" or mob.Name == "Gorilla" then
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
        jungleCount = 0
        toggleBtn.Text = "KHỈ: ON (0/10)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        -- Dịch chuyển sang Đảo Khỉ & Khóa luôn điểm hồi sinh tại Đảo Khỉ
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = JUNGLE_CFRAME
            task.wait(0.5)
            setJungleSpawn()
        end
    else
        toggleBtn.Text = "FARM KHỈ: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- 7. Bộ Đếm 10 Lần Quest Đảo Khỉ
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming then
        jungleCount = jungleCount + 1
        toggleBtn.Text = "KHỈ: ON (" .. jungleCount .. "/" .. maxJungleQuests .. ")"
        
        if jungleCount >= maxJungleQuests then
            isFarming = false
            toggleBtn.Text = "FARM KHỈ: OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "HOÀN THÀNH!",
                Text = "Đã xong 10 Q Đảo Khỉ! Script TẮT hoàn toàn.",
                Duration = 6
            })
        end
    end
end)

-- 8. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                
                -- Nếu vị trí bị văng xa khỏi Đảo Khỉ (> 800 studs) -> Bay lại Đảo Khỉ ngay lập tức
                local distanceToJungle = (character.HumanoidRootPart.Position - JUNGLE_CFRAME.Position).Magnitude
                if distanceToJungle > 800 then
                    character.HumanoidRootPart.CFrame = JUNGLE_CFRAME
                    setJungleSpawn()
                    task.wait(0.5)
                end
                
                -- Nhận Quest nếu chưa có
                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    startJungleQuest()
                    return
                end
                
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
                    character.HumanoidRootPart.CFrame = JUNGLE_CFRAME
                end
            end)
        end
    end
end)
