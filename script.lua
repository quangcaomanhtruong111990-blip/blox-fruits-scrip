local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Cấu hình chuyên biệt cho Đảo 3
local maxQuests = 10          -- Số lượng nhiệm vụ cần làm
local pirateCount = 0         -- Đếm số Q Pirate đã hoàn thành
local isFarming = false       -- Trạng thái ON/OFF
local isCheckingQuest = false -- Chống spam nhận Q

-- Tọa độ bãi quái Đảo 3 (Đã dời lên cao và lệch hẳn khỏi NPC/Thợ Rèn để không bao giờ bị kẹt hội thoại)
local PIRATE_POS = CFrame.new(-1250, 50, 3900) 

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmIsland3Gui"
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
toggleBtn.Text = "PIRATE FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm Bay Siêu Chậm An Toàn (Dùng khi dịch chuyển ra đảo)
local function ultraSlowTeleport(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 150 
    local timeToTravel = distance / speed
    
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
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    
    tween.Completed:Wait()
    
    if bodyVelocity then bodyVelocity:Destroy() end
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
    
    local speed = 120
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

-- 4. Hàm Nhận Nhiệm Vụ Đảo Hải Tặc ("BuggyQuest1")
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

-- 5. Hàm Tìm Quái Hải Tặc Gần Nhất
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
        pirateCount = 0
        isCheckingQuest = false
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") then v:Destroy() end
            end
        end
        
        toggleBtn.Text = "ĐANG BAY ĐẾN ĐẢO 3..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            ultraSlowTeleport(PIRATE_POS)
            toggleBtn.Text = "PIRATE: (0/10)"
        end)
    else
        toggleBtn.Text = "PIRATE FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") then v:Destroy() end
            end
        end
    end
end)

-- 7. Bộ Đếm Quest Đảo 3
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming then
        pirateCount = pirateCount + 1
        toggleBtn.Text = "PIRATE: (" .. pirateCount .. "/" .. maxQuests .. ")"
        
        if pirateCount >= maxQuests then
            isFarming = false
            toggleBtn.Text = "HOÀN THÀNH - OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end
end)

-- 8. Vòng Lặp Farm Chính Đảo 3
task.spawn(function()
    while task.wait(0.1) do
        if isFarming then
            pcall(function()
                -- Tự động ẩn hoặc xóa sạch khung hội thoại lạ nếu lỡ xuất hiện
                local dialogueGui = playerGui:FindFirstChild("Dialogue")
                if dialogueGui then
                    dialogueGui.Visible = false
                end

                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                
                -- Nhận nhiệm vụ nếu chưa có bảng Quest
                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    startPirateVillageQuest()
                end
                
                -- Tìm và đánh quái "Pirate"
                local targetMob = getClosestMob("Pirate", 350)
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    flyToMob(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0))
                    
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end)
        end
    end
end)
