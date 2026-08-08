local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local maxBanditQuests = 10     -- Làm 10 lần Q Bandit trước
local banditCount = 0         -- Biến đếm Q Bandit
local currentStage = "Bandit"  -- Trạng thái: "Bandit" hoặc "Jungle"

-- Tọa độ cố định của Đảo Khỉ
local JUNGLE_POS = CFrame.new(-1612, 37, 149)

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Chuyển Đảo",
    Text = "Farm 10 Q Bandit -> Tự sang Đảo Khỉ!",
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

-- 2. Hàm Nhận Nhiệm Vụ Theo Trạng Thái
local function startQuest()
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            if currentStage == "Bandit" then
                commF:InvokeServer("StartQuest", "BanditQuest1", 1)
            elseif currentStage == "Jungle" then
                commF:InvokeServer("StartQuest", "JungleQuest", 1) -- Q đánh Monkey (Khỉ)
            end
        end
    end)
end

-- 3. Hàm Tìm Quái Gần Nhất Theo Loại
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

-- 4. Đếm Số Lần Hoàn Thành Nhiệm Vụ Bandit
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and currentStage == "Bandit" then
        banditCount = banditCount + 1
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Tiến Độ Bandit",
            Text = "Đã xong: " .. banditCount .. "/" .. maxBanditQuests .. " nhiệm vụ",
            Duration = 3
        })
        
        -- Khi xong 10 lần Bandit -> Chuyển sang Đảo Khỉ
        if banditCount >= maxBanditQuests then
            currentStage = "Jungle"
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "CHUYỂN ĐẢO!",
                Text = "Đã xong 10 Q Bandit! Đang bay sang Đảo Khỉ...",
                Duration = 5
            })
        end
    end
end)

-- 5. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Đảm bảo luôn cầm vũ khí
            equipWeapon()
            
            -- Nếu chưa có Q -> Nhận Q tương ứng
            if questFrame and not questFrame.Visible then
                startQuest()
                task.wait(0.5)
            end
            
            -- Xử lý theo từng Đảo
            if currentStage == "Bandit" then
                local targetMob = getClosestMob("Bandit", 350)
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
                else
                    character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1549)
                end
            elseif currentStage == "Jungle" then
                local targetMob = getClosestMob("Monkey", 350)
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
                else
                    -- Teleport sang Đảo Khỉ nếu chưa có quái gần đó
                    character.HumanoidRootPart.CFrame = JUNGLE_POS
                end
            end
            
            -- Đánh quái
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
            
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end)
