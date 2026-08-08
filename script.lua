local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local questCompleted = false

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Quest Lvl 1",
    Text = "Đang nhận Q & Farm 5 quái... Xong sẽ tự tắt!",
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

-- 4. Vòng Lặp Chính (Chạy đúng 1 lần nhiệm vụ rồi ngắt)
task.spawn(function()
    while task.wait(0.1) do
        if questCompleted then break end

        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Kiểm tra bảng Quest xem đã nhận chưa / làm xong chưa
            local playerGui = player:FindFirstChild("PlayerGui")
            local mainGui = playerGui and playerGui:FindFirstChild("Main")
            local questFrame = mainGui and mainGui:FindFirstChild("Quest")
            
            -- Nếu chưa có nhiệm vụ -> Tự động nhận Q Bandit
            if questFrame and not questFrame.Visible then
                startBanditQuest()
                task.wait(0.5)
            end
            
            -- Đảm bảo cầm vũ khí
            equipWeapon()
            
            -- Tìm quái Bandit
            local targetMob = getClosestMob(350)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Đứng cao trên đầu quái 9 studs
                character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 9, 0)
                
                -- Đánh quái
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            else
                -- Nếu không thấy quái, tự teleport về bãi Bandit (Đảo Khởi Đầu)
                character.HumanoidRootPart.CFrame = CFrame.new(1059, 16, 1549)
            end
            
            -- Khi khung Quest ẩn đi sau khi đã nhận (nghĩa là đã đánh đủ 5/5 con)
            -- Hoặc kiểm tra tiến trình Quest để ngắt script
            if questFrame and questFrame.Visible then
                local titleContainer = questFrame:FindFirstChild("Container") and questFrame.Container:FindFirstChild("QuestTitle")
                if titleContainer and titleContainer:FindFirstChild("Title") then
                    -- Đang trong nhiệm vụ
                end
            end
        end)
    end
end)

-- Lắng nghe sự kiện hoàn thành Quest từ Server để TẮT SCRIPT ngay lập tức
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    -- Nếu Quest vừa bị ẩn đi sau khi đã từng bật -> Đã hoàn thành 1 nhiệm vụ
    if not questFrame.Visible then
        questCompleted = true
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto Quest Lvl 1",
            Text = "Đã xong 1 nhiệm vụ! Script đã tự động TẮT.",
            Duration = 5
        })
    end
end)
