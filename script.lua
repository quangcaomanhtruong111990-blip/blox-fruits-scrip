local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- RemoteEvent gửi sát thương Blox Fruits
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")

-- Cấu hình
local maxQuests = 1           -- Số lần làm Q cho mỗi đảo (1 lần)
local banditCount = 0          -- Đếm Q Bandit
local jungleCount = 0          -- Đếm Q Khỉ
local pirateCount = 0          -- Đếm Q Pirate (Đảo 3)
local currentIsland = 1        -- 1: Bandit, 2: Khỉ, 3: Làng Hải Tặc
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false  -- Chống spam nhận Q
local isTweening = false       -- Đang trong quá trình bay từ từ
local isAttacking = false      -- Trạng thái đang đánh Fast Attack

-- Tọa độ trung tâm/bãi quái cho 3 Đảo
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

-- 2. Hàm Bay Qua Đảo (Độ cao Y +18)
local function ultraSlowTeleport(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local adjustedTarget = targetCFrame * CFrame.new(0, 18, 0)
    local distance = (hrp.Position - adjustedTarget.Position).Magnitude
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
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = adjustedTarget})
    tween:Play()
    
    tween.Completed:Wait()
    
    if bodyVelocity then bodyVelocity:Destroy() end
    isTweening = false
end

-- Hàm bay giữ khoảng cách an toàn phía trên quái (Y + 25)
local function flyToMob(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local adjustedTarget = targetCFrame * CFrame.new(0, 25, 0)
    local distance = (hrp.Position - adjustedTarget.Position).Magnitude
    
    if distance < 4 then
        hrp.CFrame = adjustedTarget
        return
    end
    
    local speed = 150
    local timeToTravel = distance / speed
    
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = adjustedTarget})
    tween:Play()
    
    tween.Completed:Wait()
end

-- 3. Trang Bị Vũ Khí & Tắt Chuyển Động (Animation)
local function equipWeapon()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not character or not backpack then return end
    
    local toolInChar = character:FindFirstChildOfClass("Tool")
    if not toolInChar then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword" or item.ToolTip == "Blox Fruit") then
                character.Humanoid:EquipTool(item)
                task.wait(0.1)
                break
            end
        end
    end
end

local function unequipWeapon()
    local character = player.Character
    if character and character:FindFirstChildOfClass("Tool") then
        character.Humanoid:UnequipTools()
    end
end

-- Tắt Animation vung tay/chân để đứng yên hoàn toàn
local function stopAnimations()
    local character = player.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        for _, track in pairs(character.Humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end

-- 4. Các Hàm Nhận Nhiệm Vụ Từ Xa
local function startBanditQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("StartQuest", "BanditQuest1", 1) end
    end)
    task.wait(1.2)
    isCheckingQuest = false
end

local function startJungleQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("StartQuest", "JungleQuest", 1) end
    end)
    task.wait(1.2)
    isCheckingQuest = false
end

local function startPirateVillageQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("StartQuest", "BuggyQuest1", 1) end
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
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") then v:Destroy() end
            end
        end
        
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
        
        unequipWeapon()
        
        local character = player.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    for _, v in pairs(part:GetChildren()) do
                        if v:IsA("BodyVelocity") then v:Destroy() end
                    end
                end
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
                unequipWeapon()
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
                unequipWeapon()
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
                unequipWeapon()
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

-- 9. Noclip (Xóa va chạm)
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

-- 10. Vòng lặp Fast Attack (Đánh siêu tốc + Đứng yên)
task.spawn(function()
    while task.wait(0.01) do
        if isFarming and isAttacking then
            pcall(function()
                stopAnimations() -- Tắt hoạt ảnh vung tay
                
                -- Gửi RemoteEvent gây sát thương trực tiếp siêu tốc
                RegisterAttack:FireServer(0.01)
            end)
        end
    end
end)

-- 11. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
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
                    isAttacking = false
                    unequipWeapon()
                    
                    -- Bay đến phía trên quái
                    flyToMob(targetMob.HumanoidRootPart.CFrame)
                    
                    if not isFarming then return end
                    
                    -- Dừng hẳn 1 giây ở trên cao
                    task.wait(1)
                    if not isFarming then return end
                    
                    equipWeapon()
                    isAttacking = true -- Bật Fast Attack
                    
                    -- Đánh cho đến khi quái chết
                    local targetHumanoid = targetMob:FindFirstChild("Humanoid")
                    while isFarming and targetHumanoid and targetHumanoid.Health > 0 do
                        task.wait(0.1)
                    end
                    
                    isAttacking = false
                end
            end)
        end
    end
end)
