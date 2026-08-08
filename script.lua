--[[
    MỤC ĐÍCH: HỌC LẬP TRÌNH LUA ROBLOX THỰC HÀNH TRONG STUDIO RIÊNG
    KHÔNG DÙNG TRONG SERVER CHÍNH THỨC BLOX FRUITS / ROBLOX CÔNG KHAI
]]

local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

-- ===== BIẾN TRẠNG THÁI KIỂM SOÁT CHẶT CHẼ =====
local isFarming = false       
local isCheckingQuest = false 
local isTweening = false      
local isAttacking = false
local lastAttackTime = 0
local ATTACK_DELAY = 0.3       -- Thời gian nghỉ giữa đòn đánh (điều chỉnh mượt)
local MIN_DIST_FLY = 6         -- Khoảng cách dưới này không chạy Tween ngắn gây rung
local ATTACK_RANGE = 20        -- Đủ gần mới đánh, không bay liên tục

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

-- ===== GIAO DIỆN NÚT BẬT/TẮT =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoLevelFarmGui"
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
toggleBtn.Text = "FARM LEVEL: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- ===== HÀM BAY MƯỢT, KHÔNG CHỒNG CHÉO =====
local function flyToTarget(targetCFrame)
    if isTweening then return end -- Ngăn bay chồng khi đang di chuyển
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    -- Gần đủ thì đặt thẳng vị trí, không Tween ngắn gây rung
    if distance < MIN_DIST_FLY then
        hrp.CFrame = targetCFrame
        return
    end

    isTweening = true
    -- Tắt va chạm 1 lần khi bắt đầu bay
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local speed = 220 -- Giảm nhẹ tốc độ bay mượt hơn
    local timeToTravel = distance / speed
    -- Dùng kiểu chuyển động cong tự nhiên hơn Linear
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- Dọn dẹp chống rơi cũ
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "AntiFall" then v:Destroy() end
    end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Parent = hrp

    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()

    tween.Completed:Wait() -- Chờ xong mới mở trạng thái lại
    bv:Destroy()
    isTweening = false
end

-- ===== BAY CHUYỂN ĐẢO DÀI KHOẢNG =====
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

-- ===== XỬ LÝ NÚT BẬT/TẮT =====
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        isCheckingQuest = false
        isTweening = false
        isAttacking = false
        currentIsland = getCurrentIslandByLevel()
        
        -- Dọn dẹp AntiFall cũ
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
            toggleBtn.Text = data.name .. " | ĐANG FARM"
        end)
    else
        -- Tắt hoàn toàn, dừng mọi hành động
        isFarming = false
        toggleBtn.Text = "FARM LEVEL: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
end)

-- ===== TỰ ĐỘNG CHUYỂN ĐẢO KHI LÊN LEVEL =====
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
                    toggleBtn.Text = data.name .. " | ĐANG FARM"
                end)
            end
        end
    end
end)

-- ===== VÒNG LẶP FARM CHÍNH ĐƯỢC TINH CHỈNH =====
task.spawn(function()
    while task.wait(0.15) do -- Tăng nhẹ chu kỳ giảm tải liên tục
        if isFarming and not isTweening and not isAttacking then
            pcall(function()
                -- Tắt hội thoại chặn hành động
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

                -- Kiểm tra nhận nhiệm vụ khi chưa có nhiệm vụ
                local questFrame = playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest")
                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    local distToNpc = (hrp.Position - npcPos.Position).Magnitude
                    if distToNpc > 15 then
                        flyToTarget(npcPos)
                        task.wait(0.5)
                    end
                    startQuestForIsland(questName)
                else
                    -- Tìm quái và đánh có kiểm soát
                    local targetMob = getClosestMob(mobPattern, 1000)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        local distance = (hrp.Position - mobHrp.Position).Magnitude
                        
                        -- Chỉ bay khi còn xa, đủ gần thì đứng yên đánh
                        if distance > ATTACK_RANGE then
                            flyToTarget(mobHrp.CFrame * CFrame.new(0, 3, 4)) -- Đứng sau quái tự nhiên
                        else
                            -- Đánh có kiểm soát thời gian, không nhấn liên tục
                            local now = os.clock()
                            if now - lastAttackTime >= ATTACK_DELAY then
                                isAttacking = true
                                local tool = character:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate()
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
