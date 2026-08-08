local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local maxBanditQuests = 10     -- Số lần làm Q Bandit
local banditCount = 0         -- Đếm số lần xong Q
local isScriptActive = true
local isGettingQuest = false  -- Chống kẹt NPC

-- Tọa độ Đảo Khỉ
local JUNGLE_POS = CFrame.new(-1612, 37, 149)

-- Thông báo khởi chạy
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Bandit",
    Text = "Farm 10 Q Bandit -> Bay sang Đảo Khỉ rồi TẮT!",
    Duration = 4
})

-- 1. Tự trang bị vũ khí Melee / Sword
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

-- 2. Nhận Q Bandit (Có khóa chống spam kẹt NPC)
local function startBanditQuest()
    if isGettingQuest then return end
    isGettingQuest = true
    
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", "BanditQuest1", 1)
        end
    end)
    
    task.wait(1)
    isGettingQuest = false
end

-- 3. Tìm quái Bandit gần nhất
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

-- 4. Bộ đếm 10 lần hoàn thành Quest & Tắt Script
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isScriptActive then
        banditCount = banditCount + 1
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Tiến Độ Farm",
            Text = "Đã xong: " .. banditCount .. "/" .. maxBanditQuests .. " nhiệm vụ",
            Duration = 3
        })
        
        -- Khi đủ 10 lần -> Teleport sang Đảo Khỉ & Tắt Script
        if banditCount >= maxBanditQuests then
            isScriptActive = false
            
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = JUNGLE_POS
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "HOÀN THÀNH!",
                Text = "Đã đến Đảo Khỉ. Script đã TẮT HOÀN TOÀN!",
                Duration = 6
            })
        end
    end
end)

-- 5. Vòng lặp Farm chính
task.spawn(function()
    while task.wait(0.1) do
        if not isScriptActive then break end

        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            equipWeapon()
            
            -- Nếu chưa có Quest -> Nhận Q và tạm nghỉ 1 nhịp
            if questFrame and not questFrame.Visible then
                startBanditQuest()
                return
            end
            
            -- Đã có Quest -> Đi tìm Bandit đánh
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
                character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1549)
            end
        end)
    end
end)
