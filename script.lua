--[[
    MỤC ĐÍCH: HỌC LẬP TRÌNH ROBLOX - CHỈ ĐÁNH KHI ĐÃ BAY ĐẾN VỊ TRÍ
]]

local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

-- Cấu hình
local maxQuests = 1           
local banditCount = 0         
local jungleCount = 0         
local pirateCount = 0         
local desertCount = 0         
local currentIsland = 1       -- 1: Bandit, 2: Khỉ, 3: Hải Tặc, 4: Sa Mạc
local isFarming = false       
local isCheckingQuest = false 
local isTweening = false      
local isAtTarget = false      -- === CỜ: Đã đến vị trí quái mới đánh ===
local lastAttackTime = 0
local ATTACK_DELAY = 0.3      -- Nhịp đánh đều, không nhấn liên tục
local ATTACK_RANGE = 18       -- Khoảng cách đủ gần mới tính là đến nơi
local ATTACK_HEIGHT = 9       -- Chiều cao bay trên quái

-- Tọa độ NPC nhận nhiệm vụ 4 Đảo
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local JUNGLE_NPC_POS = CFrame.new(-1485, 36, 68)
local PIRATE_NPC_POS = CFrame.new(-1140, 4, 3825)
local DESERT_NPC_POS = CFrame.new(903, 16, 4376)

-- ========== GIAO DIỆN ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarm4IslandsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 220, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- ========== HÀM BAY MƯỢT ==========
local function flyToTarget(targetCFrame)
    if isTweening then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    -- Gần đủ thì đặt thẳng vị trí, đánh dấu đã đến
    if distance < 8 then
        hrp.CFrame = targetCFrame
        isAtTarget = true
        return
    end

    isAtTarget = false -- Đang bay → chưa đến, KHÔNG ĐÁNH
    isTweening = true

    -- Tắt va chạm
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local speed = 220
    local timeToTravel = distance / speed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- Chống rơi
    for _, v in pairs(hrp:GetChildren()) do if v.Name == "AntiFall" then v:Destroy() end end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Parent = hrp

    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()

    tween.Completed:Wait() -- Chờ bay xong
    bv:Destroy()
    isTweening = false
    isAtTarget = true -- === KẾT THÚC BAY → MỞ CHO PHÉP ĐÁNH ===
end

-- ========== BAY CHUYỂN ĐẢO ==========
local function ultraSlowTeleport(targetCFrame)
    if isTweening then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 150
    local timeToTravel = distance / speed

    isAtTarget = false
    isTweening = true

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Parent = hrp

    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()

    tween.Completed:Wait()
    bv:Destroy()
    isTweening = false
    isAtTarget = true
end

-- ========== TRANG BỊ VŨ KHÍ ==========
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

-- ========== NHẬN NHIỆM VỤ ==========
local function startQuestForIsland(questName)
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", questName, 1)
        end
    end)
    task.wait(1.2)
    isCheckingQuest = false
end

-- ========== TÌM QUÁI GẦN NHẤT ==========
local function getClosestMob(mobNamePattern, maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, mobNamePattern) then
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

-- ========== NÚT BẬT/TẮT ==========
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        banditCount = 0
        jungleCount = 0
        pirateCount = 0
        desertCount = 0
        currentIsland = 1
        isCheckingQuest = false
        isAtTarget = false
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
        
        toggleBtn.Text = "ĐANG BAY VỀ ĐẢO 1..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            ultraSlowTeleport(BANDIT_NPC_POS)
            toggleBtn.Text = "BANDIT: (0/1)"
        end)
    else
        isFarming = false
        isAtTarget = false
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
end)

-- ========== TỰ ĐỘNG CHUYỂN ĐẢO KHI HOÀN THÀNH NHỆM VỤ ==========
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isTweening then
        if currentIsland == 1 then
            banditCount += 1
            toggleBtn.Text = "BANDIT: ("..banditCount.."/"..maxQuests..")"
            if banditCount >= maxQuests then
                currentIsland = 2
                toggleBtn.Text = "BAY SANG ĐẢO KHỈ..."
                task.spawn(function()
                    ultraSlowTeleport(JUNGLE_NPC_POS)
                    toggleBtn.Text = "KHỈ: (0/1)"
                end)
            end
        elseif currentIsland == 2 then
            jungleCount += 1
            toggleBtn.Text = "KHỈ: ("..jungleCount.."/"..maxQuests..")"
            if jungleCount >= maxQuests then
                currentIsland = 3
                toggleBtn.Text = "BAY SANG HẢI TẶC..."
                task.spawn(function()
                    ultraSlowTeleport(PIRATE_NPC_POS)
                    toggleBtn.Text = "PIRATE: (0/1)"
                end)
            end
        elseif currentIsland == 3 then
            pirateCount += 1
            toggleBtn.Text = "PIRATE: ("..pirateCount.."/"..maxQuests..")"
            if pirateCount >= maxQuests then
                currentIsland = 4
                toggleBtn.Text = "BAY SANG SA MẠC..."
                task.spawn(function()
                    ultraSlowTeleport(DESERT_NPC_POS)
                    toggleBtn.Text = "DESERT: (0/1)"
                end)
            end
        elseif currentIsland == 4 then
            desertCount += 1
            toggleBtn.Text = "DESERT: ("..desertCount.."/"..maxQuests..")"
            if desertCount >= maxQuests then
                isFarming = false
                toggleBtn.Text = "HOÀN THÀNH 4 ĐẢO - OFF"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end
    end
end)

-- ========== VÒNG LẶP FARM CHÍNH ==========
task.spawn(function()
    while task.wait(0.1) do
        if isFarming and not isTweening then
            pcall(function()
                -- Tắt hội thoại cản trở
                local dialogueGui = playerGui:FindFirstChild("Dialogue")
                if dialogueGui then dialogueGui.Visible = false end

                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                local hrp = character.HumanoidRootPart

                -- Lấy thông tin đảo hiện tại
                local questName, mobPattern, npcPos
                if currentIsland == 1 then
                    questName = "BanditQuest1"
                    mobPattern = "Bandit"
                    npcPos = BANDIT_NPC_POS
                elseif currentIsland == 2 then
                    questName = "JungleQuest"
                    mobPattern = "Monkey"
                    npcPos = JUNGLE_NPC_POS
                elseif currentIsland == 3 then
                    questName = "BuggyQuest1"
                    mobPattern = "Pirate"
                    npcPos = PIRATE_NPC_POS
                elseif currentIsland == 4 then
                    questName = "DesertQuest"
                    mobPattern = "Desert"
                    npcPos = DESERT_NPC_POS
                end

                -- Nhận nhiệm vụ khi chưa có
                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    local distToNpc = (hrp.Position - npcPos.Position).Magnitude
                    if distToNpc > 15 then
                        flyToTarget(npcPos)
                        task.wait(0.5)
                    end
                    startQuestForIsland(questName)
                else
                    -- Tìm quái mục tiêu
                    local targetMob = getClosestMob(mobPattern, 1000)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        -- Vị trí bay cao trên quái
                        local targetPos = mobHrp.CFrame * CFrame.new(0, ATTACK_HEIGHT, 0)
                        local distance = (hrp.Position - targetPos.Position).Magnitude

                        -- Bay nếu còn xa, KHÔNG ĐÁNH KHI ĐANG BAY
                        if distance > ATTACK_RANGE then
                            flyToTarget(targetPos)
                        else
                            -- === CHỈ ĐÁNH KHI ĐÃ ĐẾN VỊ TRÍ ===
                            if isAtTarget then
                                local now = os.clock()
                                if now - lastAttackTime >= ATTACK_DELAY then
                                    local tool = character:FindFirstChildOfClass("Tool")
                                    if tool then
                                        tool:Activate()
                                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                        lastAttackTime = now
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
