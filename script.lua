local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

local isFarming = false       
local isCheckingQuest = false 

local SEA2_MOB_DATA = {
    {
        minLvl = 1250, maxLvl = 1513, 
        quest = "ShipQuest2", 
        mob = "Ship Steward", 
        npcPos = CFrame.new(925, 125, 32850),
        mobPos = CFrame.new(915, 134, 33400)
    }
}

local function getTargetData()
    return SEA2_MOB_DATA[1]
end

-- Giao diện ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmSea2FixGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 220, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM SEA 2: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- Hàm bay mượt & chống rung lắc
local function flyToTarget(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    -- Đã ở cực gần thì đứng yên cố định CFrame, không Tween nữa
    if distance < 2 then
        hrp.CFrame = targetCFrame
        return
    end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    local speed = 250
    local timeToTravel = distance / speed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "AntiFall" then v:Destroy() end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    tween:Play()
    tween.Completed:Connect(function()
        if bv then bv:Destroy() end
    end)
end

-- Tự động cầm vũ khí
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

-- Nhận Quest trực tiếp tại NPC
local function getQuestFromNPC(questName, npcPos)
    if isCheckingQuest then return end
    isCheckingQuest = true
    
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        flyToTarget(npcPos)
        task.wait(0.8)
        
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("StartQuest", questName, 1)
            end
        end)
    end
    
    task.wait(0.8)
    isCheckingQuest = false
end

-- Tìm quái Bếp Phó
local function getClosestMob(mobNamePattern)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = 2000

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

-- Nút Bật/Tắt
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        isCheckingQuest = false
        toggleBtn.Text = "FARM BẾP PHÓ: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        toggleBtn.Text = "FARM SEA 2: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
end)

-- Vòng lặp Farm chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming then
            pcall(function()
                local dialogueGui = playerGui:FindFirstChild("Dialogue")
                if dialogueGui then dialogueGui.Visible = false end

                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                local hrp = character.HumanoidRootPart

                local targetData = getTargetData()
                local questFrame = playerGui:WaitForChild("Main"):WaitForChild("Quest")

                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    toggleBtn.Text = "ĐANG ĐẾN NHẬN Q..."
                    getQuestFromNPC(targetData.quest, targetData.npcPos)
                else
                    local targetMob = getClosestMob(targetData.mob)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        toggleBtn.Text = "ĐÁNH BẾP PHÓ (ĐỨNG YÊN)"
                        local mobHrp = targetMob.HumanoidRootPart
                        local targetPos = mobHrp.CFrame * CFrame.new(0, 10, 0) -- Tầm cao 10 studs chuẩn đét
                        local distance = (hrp.Position - targetPos.Position).Magnitude
                        
                        -- Chỉ di chuyển khi xa hơn 3 studs, đến nơi là đứng im
                        if distance > 3 then
                            flyToTarget(targetPos)
                        else
                            hrp.CFrame = targetPos
                        end
                        
                        -- Đánh quái
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    else
                        toggleBtn.Text = "ĐỜI QUÁI SPAWN"
                        flyToTarget(targetData.mobPos)
                    end
                end
            end)
        end
    end
end)
