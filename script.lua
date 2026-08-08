local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Cấu hình
local maxBanditQuests = 10     -- Làm 10 lần Q Bandit
local banditCount = 0          -- Biến đếm
local isFarming = false        -- Trạng thái ON/OFF
local isCheckingQuest = false  -- Chống spam
local isAtJungle = false       -- Trạng thái đã sang Đảo Khỉ chưa
local isTweening = false       -- Đang trong quá trình bay từ từ

-- Tọa độ 2 Đảo
local BANDIT_POS = CFrame.new(1059, 16, 1549)
local JUNGLE_POS = CFrame.new(-1612.8, 36.8, 149.2)

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmBanditToJungleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 190, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm Bay Siêu Chậm An Toàn (Speed 150)
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

-- 4. Hàm Nhận Nhiệm Vụ Bandit (Đảo 1)
local function startBanditQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", "BanditQuest1", 1)
        end
    end)
    
    task.wait(1.5)
    isCheckingQuest = false
end

-- 5. Hàm Nhận Nhiệm Vụ Đảo Khỉ
local function startJungleQuestSlow()
    if isCheckingQuest then return end
    isCheckingQuest = true
    
    task.wait(1)
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", "JungleQuest", 1)
        end
    end)
    
    task.wait(2.5)
    isCheckingQuest = false
end

-- 6. Hàm Tìm Quái Bandit
local function getClosestBandit(maxDistance)
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

-- 7. Xử Lý Bấm Nút ON/OFF (Có Check Vị Trí Hiện Tại)
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local distToJungle = (hrp.Position - JUNGLE_POS.Position).Magnitude
                
                -- CHECK: Nếu khoảng cách tới Đảo Khỉ < 500 (Đang ở Đảo Khỉ)
                if distToJungle < 500 then
                    toggleBtn.Text = "ĐANG BAY VỀ ĐẢO 1..."
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "KÍCH HOẠT LẠI",
                        Text = "Phát hiện đang ở Đảo Khỉ. Đang bay mượt về Đảo 1 để bắt đầu lại!",
                        Duration = 4
                    })
                    
                    -- Bay mượt từ từ quay lại Đảo 1
                    ultraSlowTeleport(BANDIT_POS)
                end
            end
            
            -- Reset các trạng thái để bắt đầu lại từ đầu
            banditCount = 0
            isAtJungle = false
            isTweening = false
            toggleBtn.Text = "BANDIT: (0/10)"
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "BẮT ĐẦU FARM",
                Text = "Đã ở Đảo 1! Tiến hành farm 10 Q Bandit...",
                Duration = 3
            })
        end)
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- 8. Bộ Đếm 10 Lần Quest Bandit -> Bay & Nhận Q Đảo Khỉ
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isAtJungle and not isTweening then
        banditCount = banditCount + 1
        toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxBanditQuests .. ")"
        
        -- Khi đủ 10 lần Bandit
        if banditCount >= maxBanditQuests then
            isAtJungle = true
            toggleBtn.Text = "ĐANG BAY TỪ TỪ SANG KHỈ..."
            
            task.spawn(function()
                ultraSlowTeleport(JUNGLE_POS)
                
                toggleBtn.Text = "ĐANG NHẬN Q ĐẢO KHỈ..."
                
                while isFarming and isAtJungle and not questFrame.Visible do
                    startJungleQuestSlow()
                end
                
                toggleBtn.Text = "ĐẢO KHỈ (ĐÃ NHẬN Q - ĐỨNG YÊN)"
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "HOÀN THÀNH",
                    Text = "Đã nhận Quest Đảo Khỉ thành công! Đang đứng yên giữ Script.",
                    Duration = 5
                })
            end)
        end
    end
end)

-- 9. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming and not isTweening then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                -- GIAI ĐOẠN 1: ĐANG Ở ĐẢO BANDIT
                if not isAtJungle then
                    equipWeapon()
                    
                    if questFrame and not questFrame.Visible and not isCheckingQuest then
                        startBanditQuest()
                        return
                    end
                    
                    local targetMob = getClosestBandit(350)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
                        
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    else
                        character.HumanoidRootPart.CFrame = BANDIT_POS
                    end
                    
                -- GIAI ĐOẠN 2: ĐÃ SANG ĐẢO KHỈ (CỐ ĐỊNH VỊ TRÍ)
                else
                    character.HumanoidRootPart.CFrame = JUNGLE_POS
                end
            end)
        end
    end
end)
