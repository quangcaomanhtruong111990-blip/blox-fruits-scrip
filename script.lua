local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local questCompleted = false
local hasQuestStarted = false

-- Thông báo khởi chạy
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Quest Lvl 1",
    Text = "Đang nhận Q & Bay đánh 5 quái... Xong sẽ tự tắt!",
    Duration = 4
})

-- Hàm bay mượt (Bay từ từ thay vì dịch chuyển tức thời)
local function flyToTarget(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    -- Nếu khoảng cách quá gần, gán trực tiếp để tránh giật
    if distance < 3 then
        hrp.CFrame = targetCFrame
        return
    end
    
    -- Xóa va chạm cơ thể
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    -- Tốc độ bay vừa phải (220-250) giúp di chuyển từ từ
    local speed = 230
    local timeToTravel = distance / speed
    
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    -- Chống rơi tự do khi bay
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "AntiFall" then v:Destroy() end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    tween:Play()
    tween.Completed:Connect(function()
        if bv then bv:Destroy() end
    end)
end

-- 1. Hàm Tự Trang Bị Vũ Khí
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

-- 2. Hàm Nhận Nhiệm Vụ Bandit
local function startBanditQuest()
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", "BanditQuest1", 1)
        end
    end)
end

-- 3. Hàm Tìm Quái Bandit Gần Nhất
local function getClosestMob(maxDistance)
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

-- 4. Vòng Lặp Chính
task.spawn(function()
    while task.wait(0.1) do
        if questCompleted then break end

        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local playerGui = player:FindFirstChild("PlayerGui")
            local mainGui = playerGui and playerGui:FindFirstChild("Main")
            local questFrame = mainGui and mainGui:FindFirstChild("Quest")
            
            -- Nếu chưa có nhiệm vụ -> Bay từ từ về NPC để nhận Q
            if questFrame and not questFrame.Visible then
                local npcPos = CFrame.new(1059, 16, 1549)
                flyToTarget(npcPos)
                startBanditQuest()
                task.wait(0.5)
            else
                hasQuestStarted = true
            end
            
            -- Đảm bảo đã trang bị vũ khí
            equipWeapon()
            
            -- Tìm quái Bandit
            local targetMob = getClosestMob(500)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                local targetCFrame = mobHrp.CFrame * CFrame.new(0, 9, 0)
                
                -- Bay từ từ tới vị trí trên đầu quái
                flyToTarget(targetCFrame)
                
                -- Đánh quái khi ở đủ gần
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            else
                -- Nếu không thấy quái gần đó, bay từ từ về khu vực spawn quái
                local mobArea = CFrame.new(1145, 17, 1630)
                flyToTarget(mobArea)
            end
        end)
    end
end)

-- Tự động tắt script khi làm xong 5 con quái (Bảng Quest biến mất)
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and hasQuestStarted then
        questCompleted = true
        
        -- Dọn dẹp hiệu ứng AntiFall nếu có
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto Quest Lvl 1",
            Text = "Đã xong 1 nhiệm vụ! Script đã tự động TẮT.",
            Duration = 5
        })
    end
end)
