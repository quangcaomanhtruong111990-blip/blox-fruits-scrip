local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Cấu hình
local maxBanditQuests = 10     -- Số lần làm Q mỗi đảo
local banditCount = 0          -- Biến đếm Q Bandit
local jungleCount = 0          -- Biến đếm Q Khỉ
local isFarming = false        -- Trạng thái ON/OFF
local isTakingQuest = false    -- Biến chống spam nhận Q
local lastQuestTime = 0        -- Thời gian nhận Q gần nhất
local isAtJungle = false       -- Trạng thái đã sang Đảo Khỉ
local isTweening = false       -- Đang trong quá trình bay

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
toggleBtn.Size = UDim2.new(0, 180, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- Hàm hỗ trợ dọn dẹp UI đối thoại NPC
local function clearDialogueUI()
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        local dialogue = playerGui:FindFirstChild("Dialogue")
        if dialogue then dialogue.Enabled = false end
        
        local mainGui = playerGui:FindFirstChild("Main")
        if mainGui then
            for _, v in pairs(mainGui:GetChildren()) do
                if v.Name == "Talk" or v.Name == "Dialog" or v.Name == "Dialogue" then
                    v.Visible = false
                end
            end
        end
    end)
end

-- 2. Hàm Bay Mượt Dùng Chung (Áp dụng cho cả qua đảo và áp sát quái)
local function smoothFlyTo(targetCFrame, customSpeed)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local speed = customSpeed or 100 
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    -- Nếu đã ở rất gần (dưới 3 studs) thì giữ nguyên, không cần tween
    if distance < 3 then 
        hrp.CFrame = targetCFrame
        return 
    end
    
    isTweening = true
    
    local bodyVelocity = hrp:FindFirstChild("FlyBV") or Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyBV"
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = hrp
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local timeToTravel = distance / speed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    
    tween.Completed:Wait()
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

-- 4. Hàm Nhận Nhiệm Vụ
local function takeQuestOnce(questName, targetCFrame)
    if isTakingQuest or (tick() - lastQuestTime < 4) then return end
    isTakingQuest = true
    lastQuestTime = tick()
    
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        smoothFlyTo(targetCFrame, 120)
        task.wait(0.3)
        
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then 
                commF:InvokeServer("StartQuest", questName, 1) 
            end
        end)
        
        task.wait(0.3)
        clearDialogueUI()
    end
    
    isTakingQuest = false
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
            if string.find(mob.Name, mobName) then
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
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            banditCount = 0
            jungleCount = 0
            isAtJungle = false
            isTweening = false
            isTakingQuest = false
            lastQuestTime = 0
            
            toggleBtn.Text = "BAY VỀ ĐẢO 1..."
            pcall(function()
                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if commF then commF:InvokeServer("AbandonQuest") end
            end)
            smoothFlyTo(BANDIT_POS, 100)
            
            toggleBtn.Text = "BANDIT: (0/10)"
        end)
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            if character.HumanoidRootPart:FindFirstChild("FlyBV") then
                character.HumanoidRootPart.FlyBV:Destroy()
            end
        end
    end
end)

-- 7. Bộ Đếm Quest Tự Động
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isTweening then
        if not isAtJungle then
            banditCount = banditCount + 1
            toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxBanditQuests .. ")"
            
            if banditCount >= maxBanditQuests then
                isAtJungle = true
                toggleBtn.Text = "BAY SANG KHỈ..."
                
                task.spawn(function()
                    smoothFlyTo(JUNGLE_POS, 100)
                    toggleBtn.Text = "KHỈ: (0/10)"
                end)
            end
        else
            jungleCount = jungleCount + 1
            toggleBtn.Text = "KHỈ: (" .. jungleCount .. "/" .. maxBanditQuests .. ")"
            
            if jungleCount >= maxBanditQuests then
                isFarming = false
                toggleBtn.Text = "HOÀN THÀNH (TẮT)"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end
    end
end)

-- 8. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming and not isTweening then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                
                -- BƯỚC 1: KIỂM TRA VÀ BẢO ĐẢM CÓ QUEST
                if questFrame and not questFrame.Visible then
                    if not isAtJungle then
                        takeQuestOnce("BanditQuest1", BANDIT_POS)
                    else
                        takeQuestOnce("JungleQuest", JUNGLE_POS)
                    end
                    return
                end
                
                -- BƯỚC 2: TẮT VA CHẠM
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                
                -- BƯỚC 3: ĐÁNH QUÁI (BAY TỪ TỪ ĐẾN VỊ TRÍ QUÁI)
                local targetMobName = not isAtJungle and "Bandit" or "Monkey"
                local defaultPos = not isAtJungle and BANDIT_POS or JUNGLE_POS
                
                local targetMob = getClosestMob(targetMobName, 400)
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local targetCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                    
                    -- Bay mượt từ từ đến đỉnh đầu quái thay vì dịch chuyển tức thời
                    smoothFlyTo(targetCFrame, 120)
                    
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                else
                    smoothFlyTo(defaultPos * CFrame.new(0, 8, 0), 120)
                end
            end)
        end
    end
end)
