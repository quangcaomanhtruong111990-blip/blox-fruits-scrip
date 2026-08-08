--[[
    MỤC ĐÍCH: HỌC LẬP TRÌNH - THỬ NGHIỆM TRONG STUDIO RIÊNG
    Tính năng: Bay cao 12 đơn vị trên quái, bám sát, đánh ổn định có dame
]]

local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService") -- Dùng để bám sát mượt
local playerGui = player:WaitForChild("PlayerGui")

-- ===== BIẾN TRẠNG THÁI & THAM SỐ =====
local isFarming = false       
local isCheckingQuest = false 
local isTweening = false      
local isAttacking = false
local lastAttackTime = 0
local ATTACK_DELAY = 0.3       -- Thời gian nghỉ giữa đòn đánh
local MIN_DIST_FLY = 6         -- Không Tween ngắn gây rung
local TARGET_HEIGHT = 12       -- === CAO 12 ĐƠN VỊ TRÊN QUÁI ===
local STICK_DISTANCE = 18      -- Khoảng cách giữ bám sát

-- ===== DỮ LIỆU 5 ĐẢO =====
local ISLAND_DATA = {
    {minLevel = 1,  maxLevel = 9,   name = "BANDIT",  questName = "BanditQuest1", mobPattern = "Bandit",  pos = CFrame.new(1038, 16, 1575)},
    {minLevel = 10, maxLevel = 29,  name = "JUNGLE",  questName = "JungleQuest",  mobPattern = "Monkey",  pos = CFrame.new(-1485, 36, 68)},
    {minLevel = 30, maxLevel = 59,  name = "PIRATE",  questName = "BuggyQuest1",  mobPattern = "Pirate",  pos = CFrame.new(-1140, 4, 3825)},
    {minLevel = 60, maxLevel = 89,  name = "DESERT",  questName = "DesertQuest",  mobPattern = "Desert",  pos = CFrame.new(903, 16, 4376)},
    {minLevel = 90, maxLevel = 9999,name = "SNOW",    questName = "SnowQuest",    mobPattern = "Snow Bandit", pos = CFrame.new(1389, 88, -1298)}
}

-- ===== LẤY CHỈ SỐ ĐẢO THEO LEVEL =====
local function getCurrentIslandByLevel()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local levelVal = leaderstats:FindFirstChild("Level")
        if levelVal then
            local lvl = levelVal.Value
            for i, data in ipairs(ISLAND_DATA) do
                if lvl >= data.minLevel and lvl <= data.maxLevel then
                    return i
                end
            end
        end
    end
    return 1
end
local currentIsland = getCurrentIslandByLevel()

-- ===== GIAO DIỆN =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoLevelFarmGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 240, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM BÁM TRÊN CAO 12: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- ===== HÀM BAY MƯỢT =====
local function flyToTarget(targetCFrame)
    if isTweening then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    if distance < MIN_DIST_FLY then
        hrp.CFrame = targetCFrame
        return
    end

    isTweening = true
    -- Tắt va chạm
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local speed = 200
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

    tween.Completed:Wait()
    bv:Destroy()
    isTweening = false
end

-- ===== BAY CHUYỂN ĐẢO =====
local function ultraSlowTeleport(targetCFrame)
    if isTweening then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 150
    local timeToTravel = distance / speed

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
end

-- ===== TRANG BỊ VŨ KHÍ =====
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

-- ===== NHẬN NHIỆM VỤ =====
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

-- ===== TÌM QUÁI GẦN NHẤT =====
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

-- ===== NÚT BẬT/TẮT =====
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        isCheckingQuest = false
        isTweening = false
        isAttacking = false
        currentIsland = getCurrentIslandByLevel()
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
        
        local data = ISLAND_DATA[currentIsland]
        toggleBtn.Text = "ĐANG ĐẾN ĐẢO " .. data.name .. "..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            ultraSlowTeleport(data.pos)
            toggleBtn.Text = data.name .. " | BÁM CAO 12 ĐANG FARM"
        end)
    else
        isFarming = false
        toggleBtn.Text = "FARM BÁM TRÊN CAO 12: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
end)

-- ===== TỰ ĐỘNG CHUYỂN ĐẢO =====
task.spawn(function()
    while task.wait(1) do
        if isFarming and not isTweening then
            local realIsland = getCurrentIslandByLevel()
            if realIsland ~= currentIsland then
                currentIsland = realIsland
                local data = ISLAND_DATA[currentIsland]
                toggleBtn.Text = "LÊN LEVEL! ĐẾN " .. data.name
                task.spawn(function()
                    ultraSlowTeleport(data.pos)
                    toggleBtn.Text = data.name .. " | BÁM CAO 12 ĐANG FARM"
                end)
            end
        end
    end
end)

-- ===== VÒNG LẶP BÁM SÁT + ĐÁNH =====
task.spawn(function()
    while task.wait(0.03) do -- Lặp nhanh nhẹ để bám sát mượt
        if isFarming and not isTweening and not isAttacking then
            pcall(function()
                -- Tắt hội thoại cản trở
                local dialogueGui = playerGui:FindFirstChild("Dialogue")
                if dialogueGui then dialogueGui.Visible = false end

                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                local hrp = character.HumanoidRootPart

                local data = ISLAND_DATA[currentIsland]
                local questName = data.questName
                local mobPattern = data.mobPattern
                local npcPos = data.pos

                -- Nhận nhiệm vụ nếu chưa có
                local questFrame = playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest")
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
                        -- === VỊ TRÍ BÁM TRÊN CAO CHÍNH XÁC 12 ===
                        local stickPos = mobHrp.Position + Vector3.new(0, TARGET_HEIGHT, 0)
                        local targetCFrame = CFrame.new(stickPos, mobHrp.Position) -- Nhìn thẳng xuống quái để đánh trúng có dame
                        local distance = (hrp.Position - stickPos).Magnitude

                        -- Di chuyển nhanh về vị trí bám nếu quá xa
                        if distance > STICK_DISTANCE then
                            flyToTarget(targetCFrame)
                        else
                            -- Giữ vị trí bám sát liên tục + hướng xuống quái
                            hrp.CFrame = targetCFrame

                            -- Đánh có kiểm soát thời gian, đảm bảo có sát thương
                            local now = os.clock()
                            if now - lastAttackTime >= ATTACK_DELAY then
                                isAttacking = true
                                local tool = character:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate() -- Kích hoạt vũ khí đúng cách tạo dame
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                    lastAttackTime = now
                                end
                                task.wait(ATTACK_DELAY)
                                isAttacking = false
                            end
                        end
                    end
                end
            end)
        end
    end
end)
