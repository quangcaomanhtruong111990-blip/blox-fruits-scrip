local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local maxBanditQuests = 10     -- Làm 10 lần Q Bandit
local banditCount = 0         -- Biến đếm Q Bandit
local isScriptActive = true
local isGettingQuest = false  -- Chống spam nhận Q liên tục

-- Tọa độ Đảo Khỉ (Tự bay sang khi xong 10 Q)
local JUNGLE_POS = CFrame.new(-1612, 37, 149)

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Bandit",
    Text = "Fix lỗi kẹt NPC! Xong 10 Q -> Đảo Khỉ rồi TẮT!",
    Duration = 4
})

-- 1. Hàm Trang Bị Melee
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

-- 2. Hàm Nhận Nhiệm Vụ Bandit (Đã Chống Spam)
local function startBanditQuest()
    if isGettingQuest then return end
    isGettingQuest = true
    
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", "BanditQuest1", 1)
        end
    end)
    
    task.wait(1) -- Chờ 1 giây để Server xử lý
    isGettingQuest = false
end

-- 3. Hàm Tìm Quái Bandit
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

-- 4. Đếm 10 Lần Hoàn Thành Nhiệm Vụ Bandit
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isScriptActive then
        banditCount = banditCount + 1
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Tiến Độ Bandit",
            Text = "Đã xong: " .. banditCount .. "/" .. maxBanditQuests .. " nhiệm vụ",
            Duration = 3
        })
        
        -- Khi đủ 10 lần -> Bay sang Đảo Khỉ rồi TẮT SCRIPT
        if banditCount >= maxBanditQuests then
            isScriptActive = false
            
            -- Teleport nhân vật tới Đảo Khỉ
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = JUNGLE_POS
            end
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "HOÀN THÀNH!",
                Text = "Đã tới Đảo Khỉ. Script đã TẮT HOÀN TOÀN!",
                Duration = 6
            })
        end
    end
end)

-- 5. Vòng Lặp Farm
task.spawn(function()
    while task.wait(0.1) do
        if not isScriptActive then break end

        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            equipWeapon()
            
            -- Tự động nhận Q nếu bảng Quest đang không bật
            if questFrame and not questFrame.Visible then
                startBanditQuest()
                return -- Tạm dừng 1 nhịp vòng lặp để nhận Q xong rồi mới tìm quái
            end
            
            -- Đã có Quest -> Đi tìm quái đánh
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
