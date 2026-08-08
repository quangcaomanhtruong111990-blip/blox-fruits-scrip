--[[
    MỤC ĐÍCH: HỌC LẬP TRÌNH - BÁM CAO + ĐÁNH NHANH HƠN
]]

local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

-- CẤU HÌNH: GIẢM THỜI GIAN ĐỂ ĐÁNH NHANH
local FIXED_HEIGHT = 12        
local maxQuests = 1           
local banditCount = 0         
local jungleCount = 0         
local pirateCount = 0         
local desertCount = 0         
local currentIsland = 1       
local isFarming = false       
local isCheckingQuest = false 
local isTweening = false      
local isStableHigh = false     
local lastAttackTime = 0
local ATTACK_DELAY = 0.12      -- === GIẢM NHỎ RẤT NHIỀU ĐỂ ĐÁNH NHANH ===
local STABLE_TOLERANCE = 1.5   
local LOOP_WAIT = 0.02          -- Vòng lặp chạy nhanh hơn phản ứng kịp nhịp đánh

-- Tọa độ NPC nhận nhiệm vụ
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local JUNGLE_NPC_POS = CFrame.new(-1485, 36, 68)
local PIRATE_NPC_POS = CFrame.new(-1140, 4, 3825)
local DESERT_NPC_POS = CFrame.new(903, 16, 4376)

-- ========== GIAO DIỆN ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmFastAttackGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 260, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "BÁM CAO + ĐÁNH NHANH: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- ========== HÀM BAY MƯỢT LUÔN Ở CAO ==========
local function flyToTarget(targetCFrame)
    if isTweening then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude

    if distance < 8 then
        hrp.CFrame = targetCFrame
        isStableHigh = true
        return
    end

    isStableHigh = false
    isTweening = true

    -- Tắt va chạm giữ trên cao không chạm đất
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local speed = 240 -- Tăng nhẹ tốc bay cho linh hoạt
    local timeToTravel = distance / speed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- Chống rơi liên tục
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
    isStableHigh = true
end

-- ========== BAY CHUYỂN ĐẢO ==========
local function ultraSlowTeleport(targetCFrame)
    if isTweening then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 160
    local timeToTravel = distance / speed

    isStableHigh = false
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
    isStableHigh = true
end

-- ========== TRANG BỊ VŨ KHÍ, NHẬN NHIỆM VỤ, TÌM QUÁI ==========
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

local function startQuestForIsland(questName)
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("StartQuest", questName, 1) end
    end)
    task.wait(1.2)
    isCheckingQuest = false
end

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
                    local dist = (hrp.Position - mobHrp.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
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
        banditCount = 0 jungleCount = 0 pirateCount = 0 desertCount = 0
        currentIsland = 1 isCheckingQuest = false isStableHigh = false
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do if v.Name == "AntiFall" then v:Destroy() end end
            for _, part in pairs(character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
        end
        toggleBtn.Text = "ĐANG BAY VỀ ĐẢO 1..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        task.spawn(function() ultraSlowTeleport(BANDIT_NPC_POS + Vector3.new(0,FIXED_HEIGHT,0)) toggleBtn.Text = "BANDIT CAO 12 - NHANH" end)
    else
        isFarming = false isStableHigh = false
        toggleBtn.Text = "BÁM CAO + ĐÁNH NHANH: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do if v.Name == "AntiFall" then v:Destroy() end end
        end
    end
end)

-- ========== TỰ CHUYỂN ĐẢO KHI XONG NHIỆM VỤ ==========
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")
questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isTweening then
        if currentIsland == 1 then
            banditCount +=1 toggleBtn.Text = "BANDIT: ("..banditCount.."/"..maxQuests..")"
            if banditCount >= maxQuests then currentIsland=2 toggleBtn.Text="BAY SANG KHỈ..." task.spawn(function() ultraSlowTeleport(JUNGLE_NPC_POS+Vector3.new(0,FIXED_HEIGHT,0)) toggleBtn.Text="KHỈ - NHANH" end) end
        elseif currentIsland == 2 then
            jungleCount +=1 toggleBtn.Text = "KHỈ: ("..jungleCount.."/"..maxQuests..")"
            if jungleCount >= maxQuests then currentIsland=3 toggleBtn.Text="BAY SANG HẢI TẶC..." task.spawn(function() ultraSlowTeleport(PIRATE_NPC_POS+Vector3.new(0,FIXED_HEIGHT,0)) toggleBtn.Text="PIRATE - NHANH" end) end
        elseif currentIsland ==3 then
            pirateCount +=1 toggleBtn.Text = "PIRATE: ("..pirateCount.."/"..maxQuests..")"
            if pirateCount >= maxQuests then currentIsland=4 toggleBtn.Text="BAY SANG SA MẠC..." task.spawn(function() ultraSlowTeleport(DESERT_NPC_POS+Vector3.new(0,FIXED_HEIGHT,0)) toggleBtn.Text="DESERT - NHANH" end) end
        elseif currentIsland ==4 then
            desertCount +=1 toggleBtn.Text = "DESERT: ("..desertCount.."/"..maxQuests..")"
            if desertCount >= maxQuests then isFarming=false toggleBtn.Text="HOÀN THÀNH - OFF" toggleBtn.BackgroundColor3=Color3.new(0.8,0.2,0.2) end
        end
    end
end)

-- ========== VÒNG LẶP CHÍNH ĐÁNH NHANH ỔN ĐỊNH ==========
task.spawn(function()
    while task.wait(LOOP_WAIT) do -- Chạy nhanh bắt kịp nhịp đánh
        if isFarming and not isTweening then
            pcall(function()
                local dialogueGui = playerGui:FindFirstChild("Dialogue")
                if dialogueGui then dialogueGui.Visible = false end
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                equipWeapon()
                local hrp = character.HumanoidRootPart

                -- Lấy thông tin đảo hiện tại
                local questName, mobPattern, npcPos
                if currentIsland ==1 then questName="BanditQuest1" mobPattern="Bandit" npcPos=BANDIT_NPC_POS
                elseif currentIsland==2 then questName="JungleQuest" mobPattern="Monkey" npcPos=JUNGLE_NPC_POS
                elseif currentIsland==3 then questName="BuggyQuest1" mobPattern="Pirate" npcPos=PIRATE_NPC_POS
                elseif currentIsland==4 then questName="DesertQuest" mobPattern="Desert" npcPos=DESERT_NPC_POS end

                -- Nhận nhiệm vụ khi chưa có
                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    local distNpc = (hrp.Position - npcPos.Position).Magnitude
                    if distNpc>15 then flyToTarget(CFrame.new(npcPos.Position + Vector3.new(0,FIXED_HEIGHT,0))) task.wait(0.5) end
                    startQuestForIsland(questName)
                else
                    local targetMob = getClosestMob(mobPattern,1000)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        -- Vị trí cố định cao + nhìn xuống quái
                        local idealPos = mobHrp.Position + Vector3.new(0,FIXED_HEIGHT,0)
                        local targetCFrame = CFrame.new(idealPos, mobHrp.Position)
                        local dist = (hrp.Position - idealPos).Magnitude

                        if dist > 10 then
                            flyToTarget(targetCFrame)
                        else
                            -- Luôn chỉnh ngay cao nếu lệch
                            if math.abs(hrp.Position.Y - idealPos.Y) > STABLE_TOLERANCE then
                                hrp.CFrame = targetCFrame
                            end
                            isStableHigh = true

                            -- === ĐÁNH NHANH THEO ATTACK_DELAY ĐÃ GIẢM ===
                            local now = os.clock()
                            if isStableHigh and now - lastAttackTime >= ATTACK_DELAY then
                                local tool = character:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate()
                                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
                                    lastAttackTime = now
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
