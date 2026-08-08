local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Cấu hình
local maxQuests = 10           -- Số lần làm Q mỗi đảo
local banditCount = 0          -- Đếm Q Bandit
local jungleCount = 0          -- Đếm Q Khỉ
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false  -- Chống spam nhận Q
local isAtJungle = false       -- Đã chuyển sang Đảo Khỉ chưa
local isCompleted = false      -- Đã hoàn thành cả 2 đảo chưa
local isTweening = false       -- Đang bay mượt

-- Tọa độ 2 Đảo
local BANDIT_POS = CFrame.new(1059, 16, 1549)
local JUNGLE_POS = CFrame.new(-1612.8, 36.8, 149.2)

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmTwoIslandsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 200, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm Bay Mượt 2 Chiều (Speed 150)
local function ultraSlowTeleport(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 150
    local timeToTravel = distance / speed
    
    isTweening = true
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = hrp
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    
    tween.Completed:Wait()
    
    if bodyVelocity then bodyVelocity:Destroy() end
    isTweening = false
end

-- 3. Trang Bị Vũ Khí
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

-- 4. Hàm Nhận Quest Đảo 1 (Bandit)
local function startBanditQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("StartQuest", "BanditQuest1", 1) end
    end)
    task.wait(1.5)
    isCheckingQuest = false
end

-- 5. Hàm Nhận Quest Đảo Khỉ (Monkey)
local function startJungleQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("StartQuest", "JungleQuest", 1) end
    end)
    task.wait(1.5)
    isCheckingQuest = false
end

-- 6. Tìm Quái Gần Nhất Theo Tên
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

-- 7. Xử Lý Nút Bấm ON/OFF
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local distToJungle = (hrp.Position - JUNGLE_POS.Position).Magnitude
                
                -- Nếu đang ở Đảo Khỉ thì bay mượt về Đảo 1
                if distToJungle < 500 then
                    toggleBtn.Text = "BAY MƯỢT VỀ ĐẢO 1..."
                    pcall(function()
                        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                        if commF then commF:InvokeServer("AbandonQuest") end
                    end)
                    ultraSlowTeleport(BANDIT_POS)
                end
            end
            
            -- Reset các bộ đếm
            banditCount = 0
            jungleCount = 0
            isAtJungle = false
            isCompleted = false
            isTweening = false
            toggleBtn.Text = "BANDIT: (0/10)"
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "BẮT ĐẦU",
                Text = "Farm 10 Bandit -> Bay Đảo Khỉ -> Farm 10 Khỉ!",
                Duration = 3
            })
        end)
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- 8. Bộ Đếm Quest Tự Động (Chuyển Đảo & Hoàn Thành)
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isTweening and not isCompleted then
        
        -- GIAI ĐOẠN 1: Đếm Quest Bandit
        if not isAtJungle then
            banditCount = banditCount + 1
            toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxQuests .. ")"
            
            if banditCount >= maxQuests then
                isAtJungle = true
                toggleBtn.Text = "ĐANG BAY SANG KHỈ..."
                
                task.spawn(function()
                    ultraSlowTeleport(JUNGLE_POS)
                    toggleBtn.Text = "KHỈ: (0/10)"
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "SANG ĐẢO KHỈ",
                        Text = "Bắt đầu farm 10 Quest Khỉ!",
                        Duration = 4
                    })
                end)
            end
            
        -- GIAI ĐOẠN 2: Đếm Quest Khỉ
        else
            jungleCount = jungleCount + 1
            toggleBtn.Text = "KHỈ: (" .. jungleCount .. "/" .. maxQuests .. ")"
            
            if jungleCount >= maxQuests then
                isCompleted = true
                toggleBtn.Text = "HOÀN THÀNH (2 ĐẢO)"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "HOÀN THÀNH",
                    Text = "Đã xong 10 Q Bandit và 10 Q Khỉ! Đang đứng yên.",
                    Duration = 5
                })
            end
        end
    end
end)

-- 9. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming and not isTweening and not isCompleted then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                
                -- ĐẢO 1: Farm Bandit
                if not isAtJungle then
                    if questFrame and not questFrame.Visible and not isCheckingQuest then
                        startBanditQuest()
                        return
                    end
                    
                    local targetMob = getClosestMob("Bandit", 350)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
                        
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    else
                        character.HumanoidRootPart.CFrame = BANDIT_POS
                    end
                    
               -- ĐẢO KHỈ: Farm Monkey (Đã tối ưu mượt, không giật)
else
    if questFrame and not questFrame.Visible and not isCheckingQuest then
        startJungleQuest()
        return
    end
    
    local targetMob = getClosestMob("Monkey", 350)
    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
        local mobHrp = targetMob.HumanoidRootPart
        
        -- 1. Tắt va chạm với cây cối/vật cản xung quanh quái
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- 2. Giữ khoảng cách an toàn 10 stud phía trên đầu quái
        character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 10, 0)
        
        -- 3. Triệt tiêu vận tốc rơi để đứng im mượt mà trên không
        if not character.HumanoidRootPart:FindFirstChild("FarmBV") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FarmBV"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = character.HumanoidRootPart
        end
        
        -- Đánh quái
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    else
        -- Xóa giữ trọng lực khi không có quái để di chuyển bình thường
        if character.HumanoidRootPart:FindFirstChild("FarmBV") then
            character.HumanoidRootPart.FarmBV:Destroy()
        end
        character.HumanoidRootPart.CFrame = JUNGLE_POS
    end
end
