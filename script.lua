local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local maxQuests = 10         -- Số lần nhiệm vụ muốn làm trước khi dừng
local completedCount = 0      -- Biến đếm số lần đã xong
local isScriptActive = true

-- Thông báo kích hoạt
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Quest Lvl 1",
    Text = "Sẽ tự động TẮT sau khi hoàn thành " .. maxQuests .. " lần NV!",
    Duration = 4
})

-- 1. Hàm Tự Trang Bị Melee
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

-- 2. Hàm Tự Nhận Nhiệm Vụ Bandit (Level 1)
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

-- 4. Bộ Lắng Nghe Hoàn Thành Nhiệm Vụ (Đếm đủ 10 lần)
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    -- Mỗi khi khung Quest ẩn đi (nghĩa là vừa làm xong 1 Quest)
    if not questFrame.Visible and isScriptActive then
        completedCount = completedCount + 1
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Tiến Độ Farm",
            Text = "Đã xong: " .. completedCount .. "/" .. maxQuests .. " nhiệm vụ",
            Duration = 3
        })
        
        -- Nếu đủ 10 lần thì khóa script
        if completedCount >= maxQuests then
            isScriptActive = false
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "HOÀN THÀNH!",
                Text = "Đã hoàn thành đủ " .. maxQuests .. " lần NV. Script dừng hẳn!",
                Duration = 6
            })
        end
    end
end)

-- 5. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        -- Dừng hẳn vòng lặp khi đủ 10 lần
        if not isScriptActive then break end

        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Nếu chưa có nhiệm vụ -> Tự nhận Quest Bandit
            if questFrame and not questFrame.Visible then
                startBanditQuest()
                task.wait(0.5)
            end
            
            -- Đảm bảo cầm sẵn vũ khí
            equipWeapon()
            
            -- Tìm quái Bandit
            local targetMob = getClosestMob(350)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Đứng cao trên đầu quái 9 studs
                character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 9, 0)
                
                -- Kích hoạt đòn đánh
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            else
                -- Tự quay về bãi Bandit nếu quái chưa spawn
                character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1549)
            end
        end)
    end
end)
