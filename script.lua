------------------------------------------------------------------
-- 1. SIÊU TỐI ƯU HÓA FPS (TURBO LOW GRAPHICS / ANTI-LAG CỰC HẠN)
------------------------------------------------------------------
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- Tắt toàn bộ hiệu ứng thời tiết, ánh sáng, sương mù, mây
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 0

for _, v in pairs(Lighting:GetChildren()) do
    if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") or v:IsA("Sky") then
        v:Destroy()
    end
end

-- Tối ưu hóa Địa hình (Terrain) & Nước
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
    pcall(function() sethiddenproperty(Terrain, "Decoration", false) end)
end

-- Hàm biến Part thành vật liệu SmoothPlastic phẳng (xóa Texture/Decal/Chiêu thức)
local function optimizeInstance(inst)
    if inst:IsA("BasePart") and not inst:IsA("MeshPart") then
        inst.Material = Enum.Material.SmoothPlastic
        inst.Reflectance = 0
    elseif inst:IsA("Decal") or inst:IsA("Texture") then
        inst:Destroy()
    elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
        inst.Enabled = false
    elseif inst:IsA("Shirt") or inst:IsA("Pants") or inst:IsA("ShirtGraphic") then
        inst:Destroy()
    end
end

-- Áp dụng tối ưu cho toàn bộ Map hiện tại
for _, obj in pairs(workspace:GetDescendants()) do
    optimizeInstance(obj)
end

-- Lắng nghe các Object mới sinh ra (Quái, Chiêu thức) để hạ đồ họa ngay lập tức
workspace.DescendantAdded:Connect(function(obj)
    task.spawn(function()
        optimizeInstance(obj)
    end)
end)

-- Ép Render Quality về Level 01 thấp nhất
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)


------------------------------------------------------------------
-- 2. KHỞI TẠO BIẾN & DỊCH VỤ CHÍNH
------------------------------------------------------------------
local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Trạng thái Script
local isScriptEnabled = true
local isTweening = false
local currentTween = nil

-- Cấu hình tốc độ bay
local FLY_SPEED_LONG = 160  -- Bay chuyển bãi/chuyển đảo Sea 3
local FLY_SPEED_SHORT = 100 -- Bay tới quái


------------------------------------------------------------------
-- 3. DATABASE: TỔNG HỢP QUEST QUÁI THƯỜNG SEA 3 (LV 1500 - 2525+)
------------------------------------------------------------------
local Sea3MobQuests = {
    -- Port Town
    { Level = 1500, QuestName = "PiratePortQuest", QuestLevel = 1, MobName = "Pirate Millionaire", NpcCFrame = CFrame.new(-290, 44, 5580), MobCFrame = CFrame.new(-370, 75, 5550) },
    { Level = 1525, QuestName = "PiratePortQuest", QuestLevel = 2, MobName = "Pistol Billionaire", NpcCFrame = CFrame.new(-290, 44, 5580), MobCFrame = CFrame.new(-470, 75, 5950) },

    -- Hydra Island
    { Level = 1575, QuestName = "AmazonQuest", QuestLevel = 1, MobName = "Dragon Crew Warrior", NpcCFrame = CFrame.new(5833, 52, -1105), MobCFrame = CFrame.new(6450, 52, -1120) },
    { Level = 1600, QuestName = "AmazonQuest", QuestLevel = 2, MobName = "Dragon Crew Archer", NpcCFrame = CFrame.new(5833, 52, -1105), MobCFrame = CFrame.new(6800, 380, -380) },
    { Level = 1625, QuestName = "AmazonQuest2", QuestLevel = 1, MobName = "Female Islander", NpcCFrame = CFrame.new(5448, 601, 749), MobCFrame = CFrame.new(4700, 740, 400) },
    { Level = 1650, QuestName = "AmazonQuest2", QuestLevel = 2, MobName = "Giant Islander", NpcCFrame = CFrame.new(5448, 601, 749), MobCFrame = CFrame.new(5000, 600, -100) },

    -- Great Tree
    { Level = 1700, QuestName = "MarineTreeQuest", QuestLevel = 1, MobName = "Marine Commodore", NpcCFrame = CFrame.new(2180, 29, -6740), MobCFrame = CFrame.new(2450, 75, -6780) },
    { Level = 1725, QuestName = "MarineTreeQuest", QuestLevel = 2, MobName = "Marine Rear Admiral", NpcCFrame = CFrame.new(2180, 29, -6740), MobCFrame = CFrame.new(2850, 75, -7200) },

    -- Floating Turtle
    { Level = 1775, QuestName = "DeepForestIslandQuest", QuestLevel = 1, MobName = "Fishman Raider", NpcCFrame = CFrame.new(-10580, 332, -8760), MobCFrame = CFrame.new(-10300, 330, -8900) },
    { Level = 1800, QuestName = "DeepForestIslandQuest", QuestLevel = 2, MobName = "Fishman Captain", NpcCFrame = CFrame.new(-10580, 332, -8760), MobCFrame = CFrame.new(-10900, 330, -8900) },
    { Level = 1825, QuestName = "DeepForestIsland2Quest", QuestLevel = 1, MobName = "Forest Pirate", NpcCFrame = CFrame.new(-13230, 332, -7625), MobCFrame = CFrame.new(-13300, 330, -7900) },
    { Level = 1850, QuestName = "DeepForestIsland2Quest", QuestLevel = 2, MobName = "Mythological Pirate", NpcCFrame = CFrame.new(-13230, 332, -7625), MobCFrame = CFrame.new(-13540, 470, -6900) },

    -- Haunted Castle
    { Level = 1900, QuestName = "HauntedQuest1", QuestLevel = 1, MobName = "Reborn Skeleton", NpcCFrame = CFrame.new(-9480, 142, 5520), MobCFrame = CFrame.new(-8800, 140, 5900) },
    { Level = 1925, QuestName = "HauntedQuest1", QuestLevel = 2, MobName = "Living Zombie", NpcCFrame = CFrame.new(-9480, 142, 5520), MobCFrame = CFrame.new(-10100, 140, 5900) },
    { Level = 1975, QuestName = "HauntedQuest2", QuestLevel = 1, MobName = "Demonic Soul", NpcCFrame = CFrame.new(-9515, 172, 6080), MobCFrame = CFrame.new(-9500, 170, 6150) },
    { Level = 2000, QuestName = "HauntedQuest2", QuestLevel = 2, MobName = "Posessed Mummy", NpcCFrame = CFrame.new(-9515, 172, 6080), MobCFrame = CFrame.new(-9500, 6, 6100) },

    -- Peanut & Ice Cream Island
    { Level = 2075, QuestName = "NutsIslandQuest", QuestLevel = 1, MobName = "Peanut Scout", NpcCFrame = CFrame.new(-2105, 38, -10190), MobCFrame = CFrame.new(-2100, 50, -10250) },
    { Level = 2100, QuestName = "NutsIslandQuest", QuestLevel = 2, MobName = "Peanut President", NpcCFrame = CFrame.new(-2105, 38, -10190), MobCFrame = CFrame.new(-2150, 50, -9800) },
    { Level = 2125, QuestName = "IceCreamIslandQuest", QuestLevel = 1, MobName = "Ice Cream Chef", NpcCFrame = CFrame.new(-820, 66, -10965), MobCFrame = CFrame.new(-600, 70, -11100) },
    { Level = 2150, QuestName = "IceCreamIslandQuest", QuestLevel = 2, MobName = "Ice Cream Commander", NpcCFrame = CFrame.new(-820, 66, -10965), MobCFrame = CFrame.new(-800, 70, -11350) },

    -- Cake Land
    { Level = 2200, QuestName = "CakeQuest1", QuestLevel = 1, MobName = "Cookie Crafter", NpcCFrame = CFrame.new(-2020, 38, -12025), MobCFrame = CFrame.new(-2350, 40, -12100) },
    { Level = 2225, QuestName = "CakeQuest1", QuestLevel = 2, MobName = "Cake Guard", NpcCFrame = CFrame.new(-2020, 38, -12025), MobCFrame = CFrame.new(-1600, 40, -12350) },
    { Level = 2275, QuestName = "CakeQuest2", QuestLevel = 1, MobName = "Baking Staff", NpcCFrame = CFrame.new(-1925, 38, -12850), MobCFrame = CFrame.new(-1800, 40, -13000) },
    { Level = 2300, QuestName = "CakeQuest2", QuestLevel = 2, MobName = "Head Baker", NpcCFrame = CFrame.new(-1925, 38, -12850), MobCFrame = CFrame.new(-1900, 40, -13400) },

    -- Chocolate Land
    { Level = 2325, QuestName = "ChocQuest1", QuestLevel = 1, MobName = "Cocoa Warrior", NpcCFrame = CFrame.new(230, 24, -12200), MobCFrame = CFrame.new(200, 30, -12400) },
    { Level = 2350, QuestName = "ChocQuest1", QuestLevel = 2, MobName = "Chocolate Bar Battler", NpcCFrame = CFrame.new(230, 24, -12200), MobCFrame = CFrame.new(300, 30, -12800) },
    { Level = 2375, QuestName = "ChocQuest2", QuestLevel = 2, MobName = "Candy Rebel", NpcCFrame = CFrame.new(150, 24, -12800), MobCFrame = CFrame.new(50, 30, -13000) },
    { Level = 2400, QuestName = "ChocQuest2", QuestLevel = 1, MobName = "Sweet Thief", NpcCFrame = CFrame.new(150, 24, -12800), MobCFrame = CFrame.new(-100, 30, -12600) },

    -- Tiki Outpost
    { Level = 2475, QuestName = "TikiQuest1", QuestLevel = 1, MobName = "Isle Outlaw", NpcCFrame = CFrame.new(-16540, 55, -170), MobCFrame = CFrame.new(-16100, 55, -200) },
    { Level = 2500, QuestName = "TikiQuest1", QuestLevel = 2, MobName = "Island Boy", NpcCFrame = CFrame.new(-16540, 55, -170), MobCFrame = CFrame.new(-16600, 55, 300) },
    { Level = 2525, QuestName = "TikiQuest2", QuestLevel = 1, MobName = "Sun-kissed Warrior", NpcCFrame = CFrame.new(-16540, 55, -170), MobCFrame = CFrame.new(-16300, 55, 1000) }
}

local function getCurrentQuestData()
    local myLevel = 1500
    pcall(function()
        myLevel = player.Data.Level.Value
    end)
    
    local selectedQuest = Sea3MobQuests[1]
    for i = #Sea3MobQuests, 1, -1 do
        if myLevel >= Sea3MobQuests[i].Level then
            selectedQuest = Sea3MobQuests[i]
            break
        end
    end
    return selectedQuest
end


------------------------------------------------------------------
-- 4. QUẢN LÝ GIAO DIỆN VÀ TRẠNG THÁI
------------------------------------------------------------------
local function restoreCharacterControl()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
    if currentTween then currentTween:Cancel() currentTween = nil end
    isTweening = false
end

-- Dọn GUI cũ
if CoreGui:FindFirstChild("AutoFarmLeftGui") then CoreGui.AutoFarmLeftGui:Destroy() end
if CoreGui:FindFirstChild("AutoFarmTopGui") then CoreGui.AutoFarmTopGui:Destroy() end

-- ScreenGui cho Bảng Trạng Thái Trái
local screenGuiLeft = Instance.new("ScreenGui")
screenGuiLeft.Name = "AutoFarmLeftGui"
screenGuiLeft.Parent = CoreGui

-- ScreenGui cho Khung Nhiệm Vụ (Kịch trần)
local screenGuiTop = Instance.new("ScreenGui")
screenGuiTop.Name = "AutoFarmTopGui"
screenGuiTop.IgnoreGuiInset = true
screenGuiTop.Parent = CoreGui

-- Bảng Trạng Thái Trái
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 50)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGuiLeft

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 1.5
frameStroke.Color = Color3.fromRGB(0, 230, 150)
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = mainFrame

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 14, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)
statusDot.Parent = mainFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 200, 0, 20)
titleText.Position = UDim2.new(0, 32, 0, 8)
titleText.BackgroundTransparency = 1
titleText.Text = "AUTO FARM MOB ONLY (SEA 3)"
titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
titleText.TextSize = 11
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = mainFrame

local subText = Instance.new("TextLabel")
subText.Size = UDim2.new(0, 200, 0, 14)
subText.Position = UDim2.new(0, 32, 0, 26)
subText.BackgroundTransparency = 1
subText.Text = "Status: RUNNING [Phím K]"
subText.TextColor3 = Color3.fromRGB(0, 230, 115)
subText.TextSize = 10
subText.Font = Enum.Font.GothamMedium
subText.TextXAlignment = Enum.TextXAlignment.Left
subText.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""
toggleBtn.Parent = mainFrame

-- UI THEO DÕI NHIỆM VỤ (Kịch trần ở giữa)
local trackerFrame = Instance.new("Frame")
trackerFrame.Size = UDim2.new(0, 240, 0, 28)
trackerFrame.Position = UDim2.new(0.5, -120, 0, 0)
trackerFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
trackerFrame.BackgroundTransparency = 0.2
trackerFrame.Parent = screenGuiTop

local trackerCorner = Instance.new("UICorner")
trackerCorner.CornerRadius = UDim.new(0, 6)
trackerCorner.Parent = trackerFrame

local trackerStroke = Instance.new("UIStroke")
trackerStroke.Thickness = 1
trackerStroke.Color = Color3.fromRGB(0, 230, 150)
trackerStroke.Parent = trackerFrame

local trackerText = Instance.new("TextLabel")
trackerText.Size = UDim2.new(1, 0, 1, 0)
trackerText.BackgroundTransparency = 1
trackerText.Text = "🎯 Đang cập nhật nhiệm vụ..."
trackerText.TextColor3 = Color3.fromRGB(255, 255, 255)
trackerText.TextSize = 11
trackerText.Font = Enum.Font.GothamBold
trackerText.Parent = trackerFrame


------------------------------------------------------------------
-- 5. HÀM CẬP NHẬT TRẠNG THÁI, QUEST TRACKER, HỦY QUEST SAI & STATS
------------------------------------------------------------------
local function cancelQuest()
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("AbandonQuest")
        end
    end)
end

-- Hàm kiểm tra xem quest hiện tại có đúng không, nếu sai thì tự hủy
local function checkAndCancelWrongQuest(expectedMobName)
    pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        local questFrame = playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest")
        
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            if container and container:FindFirstChild("QuestTitle") then
                local currentQuestTitle = container.QuestTitle.Title.Text
                -- Nếu tên quái/quest trong UI không khớp với quest phù hợp Level -> Tự bỏ Quest
                if not string.find(string.lower(currentQuestTitle), string.lower(expectedMobName)) then
                    cancelQuest()
                end
            end
        end
    end)
end

local function updateQuestTracker()
    pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        local questFrame = playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest")
        
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            if container and container:FindFirstChild("QuestTitle") then
                local title = container.QuestTitle.Title.Text
                local progress = container:FindFirstChild("QuestProgress") and container.QuestProgress.Text or ""
                trackerText.Text = string.format("🎯 %s (%s)", title, progress)
            else
                trackerText.Text = "🎯 Đang làm nhiệm vụ..."
            end
        else
            trackerText.Text = "❌ Chưa nhận nhiệm vụ"
        end
    end)
end

local function enableHaki()
    local character = player.Character
    if character and not character:FindFirstChild("HasBuso") then
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then pcall(function() commF:InvokeServer("Buso") end) end
    end
end

local function autoAddStats()
    pcall(function()
        local points = player.Data.Points.Value
        if points > 0 then
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("AddPoint", "Melee", 1)
                commF:InvokeServer("AddPoint", "Defense", 1)
                commF:InvokeServer("AddPoint", "Sword", 1)
            end
        end
    end)
end

local function updateUIState()
    local qData = getCurrentQuestData()
    if isScriptEnabled then
        frameStroke.Color = Color3.fromRGB(0, 230, 150)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)
        subText.Text = string.format("Mob: %s | Lv: %d [K]", qData.MobName, qData.Level)
        subText.TextColor3 = Color3.fromRGB(0, 230, 115)
    else
        frameStroke.Color = Color3.fromRGB(235, 60, 60)
        statusDot.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
        subText.Text = "Status: PAUSED [K]"
        subText.TextColor3 = Color3.fromRGB(235, 60, 60)
    end
end

local function toggleState()
    isScriptEnabled = not isScriptEnabled
    updateUIState()
    if not isScriptEnabled then restoreCharacterControl() end
end

toggleBtn.MouseButton1Click:Connect(toggleState)
UserInputService.InputBegan:Connect(function(input, gP)
    if not gP and input.KeyCode == Enum.KeyCode.K then toggleState() end
end)


------------------------------------------------------------------
-- 6. SYSTEM BAY TWEEN & COMBAT
------------------------------------------------------------------
local function flyLinearTo(targetCFrame, speed)
    if not isScriptEnabled then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    speed = speed or FLY_SPEED_LONG
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    isTweening = true
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "AntiFall" then v:Destroy() end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    currentTween.Completed:Wait()

    if bv then bv:Destroy() end
    isTweening = false
end

local function equipWeapon()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if character and backpack and not character:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword" or item.ToolTip == "Blox Fruit") then
                character.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

local function startQuest(qName, qLevel)
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("StartQuest", qName, qLevel) end
    end)
end

local function getClosestMob(mobName)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = 3000

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, mobName) then
                local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChild("Humanoid")
                if mobHrp and mobHum and mobHum.Health > 0 then
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

local function fastAttack()
    pcall(function()
        local character = player.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    end)
end


------------------------------------------------------------------
-- 7. VÒNG LẶP CHÍNH (SEA 3)
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.01) do
        if isScriptEnabled and not isTweening then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                enableHaki()
                updateUIState()
                updateQuestTracker()
                autoAddStats()
                
                local hrp = character.HumanoidRootPart
                local qData = getCurrentQuestData()
                
                -- TỰ ĐỘNG BỎ QUEST SAI NẾU LEVEL ĐÃ TĂNG HOẶC NHẬN LẦM
                checkAndCancelWrongQuest(qData.MobName)
                
                local playerGui = player:WaitForChild("PlayerGui")
                local questFrame = playerGui.Main.Quest

                -- 1. Chưa nhận Quest -> Bay tới NPC nhận
                if not questFrame.Visible then
                    local distToNpc = (hrp.Position - qData.NpcCFrame.Position).Magnitude
                    if distToNpc > 15 then
                        flyLinearTo(qData.NpcCFrame, FLY_SPEED_LONG)
                    end
                    if isScriptEnabled then
                        startQuest(qData.QuestName, qData.QuestLevel)
                        task.wait(0.5)
                    end
                else
                    -- 2. Đã nhận Quest -> Đi tìm quái đánh
                    local targetMob = getClosestMob(qData.MobName)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        
                        -- TỐI ƯU: Đứng sát hơn (9 studs) & Xoay góc nhìn cắm thẳng xuống quái
                        local standPos = mobHrp.Position + Vector3.new(0, 9, 0)
                        local targetCFrame = CFrame.lookAt(standPos, mobHrp.Position)
                        
                        local distToMob = (hrp.Position - mobHrp.Position).Magnitude
                        if distToMob > 10 then
                            flyLinearTo(targetCFrame, FLY_SPEED_SHORT)
                        else
                            hrp.CFrame = targetCFrame
                            fastAttack()
                        end
                    else
                        -- Không thấy quái -> Bay về khu vực spawn chờ quái ra
                        local distToMobArea = (hrp.Position - qData.MobCFrame.Position).Magnitude
                        if distToMobArea > 20 then
                            flyLinearTo(qData.MobCFrame, FLY_SPEED_SHORT)
                        end
                    end
                end
            end)
        end
    end
end)
