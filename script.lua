local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

local maxQuests = 10
local desertCount = 0
local isFarming = false
local isCheckingQuest = false

-- Tọa độ nhận nhiệm vụ (gần NPC thay vì bãi quái để nhận Q trước)
local DESERT_POS = CFrame.new(1093, 16, 4390)

-- Giao diện bật/tắt
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmDesertGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 180, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "DESERT FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- HÀM DI CHUYỂN MỚI (BẢN SỬA LỖI ĐỨNG YÊN)
local function flyToMob(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    -- Nếu đã ở rất gần thì giật nhẹ (Teleport) thẳng tới luôn cho lẹ
    if distance < 10 then
        hrp.CFrame = targetCFrame
        return
    end
    
    -- Tắt va chạm (Noclip) để không bị kẹt vào tường/cát khi bay
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local speed = 250 -- Tăng tốc độ bay cho mượt
    local timeToTravel = distance / speed
    
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    -- Xóa các BodyVelocity cũ (nếu có) gây cản trở di chuyển
    for _, v in pairs(hrp:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyPosition") then
            v:Destroy()
        end
    end

    -- Thêm BodyVelocity để giữ nhân vật bay lơ lửng không bị rơi
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    tween:Play()
    
    -- Khi di chuyển xong thì xóa BodyVelocity
    tween.Completed:Connect(function()
        if bv then bv:Destroy() end
    end)
end

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

local function startDesertQuest()
    if isCheckingQuest then return end
    isCheckingQuest = true
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", "DesertQuest", 1)
        end
    end)
    task.wait(1.2)
    isCheckingQuest = false
end

-- Hàm tìm kiếm quái Desert
local function getClosestDesertMob(maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, "Desert") then
                local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                local mobHumanoid = mob:FindFirstChild("Humanoid")
                
                -- Đảm bảo quái còn sống
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

toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        desertCount = 0
        isCheckingQuest = false
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Dọn dẹp tàn dư di chuyển trước khi bắt đầu
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") then v:Destroy() end
            end
        end
        
        toggleBtn.Text = "ĐANG ĐẾN SA MẠC..."
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = DESERT_POS
            end
            toggleBtn.Text = "DESERT: (0/10)"
        end)
    else
        toggleBtn.Text = "DESERT FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        -- Xóa bay khi tắt
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(character.HumanoidRootPart:GetChildren()) do
                if v.Name == "AntiFall" then v:Destroy() end
            end
        end
    end
end)

local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming then
        desertCount = desertCount + 1
        toggleBtn.Text = "DESERT: (" .. desertCount .. "/" .. maxQuests .. ")"
        
        if desertCount >= maxQuests then
            isFarming = false
            toggleBtn.Text = "HOÀN THÀNH - OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end
end)

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

                -- Chỉ nhận Quest khi bảng Quest không hiện
                if questFrame and not questFrame.Visible and not isCheckingQuest then
                    startDesertQuest()
                end
                
                local targetMob = getClosestDesertMob(1000) -- Tăng phạm vi quét tìm quái
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    local distance = (hrp.Position - mobHrp.Position).Magnitude
                    
                    -- Bay lên đầu quái
                    flyToMob(mobHrp.CFrame * CFrame.new(0, 9, 0))
                    
                    if distance <= 15 then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end
            end)
        end
    end
end)
