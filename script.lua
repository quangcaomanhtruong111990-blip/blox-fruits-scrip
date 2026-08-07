local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isFarming = false

-- 1. TẠO NÚT BẬT / TẮT (UI TOGGLE)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmGuiNew"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 130, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- Tạo hiệu ứng lơ lửng khi farm
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.Name = "HoverVelocity"
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

-- Xử lý khi nhấn nút
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        toggleBtn.Text = "FARM: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        
        -- Hủy hiệu ứng bay khi tắt farm để di chuyển bình thường
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hover = char.HumanoidRootPart:FindFirstChild("HoverVelocity")
            if hover then hover:Destroy() end
        end
    end
end)

-- 2. HÀM TỰ CẦM VŨ KHÍ (Melee / Sword)
local function equipWeapon()
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not char or not backpack then return end
    
    if not char:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                char.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

-- 3. HÀM TÌM QUÁI GẦN NHẤT
local function getClosestMob()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myHrp = char.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = 350 -- Bán kính quét quái

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            local mobHumanoid = mob:FindFirstChild("Humanoid")
            
            if mobHrp and mobHumanoid and mobHumanoid.Health > 0 then
                local distance = (myHrp.Position - mobHrp.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestMob = mob
                end
            end
        end
    end
    return closestMob
end

-- 4. VÒNG LẶP FARM CHÍNH
task.spawn(function()
    while task.wait(0.03) do
        if isFarming then
            pcall(function()
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                local myHrp = char.HumanoidRootPart
                
                -- Khóa vị trí không bị rơi
                if not myHrp:FindFirstChild("HoverVelocity") then
                    bodyVelocity.Parent = myHrp
                end

                equipWeapon()
                local targetMob = getClosestMob()
                
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    
                    -- Bay tới đứng phía trên đầu quái 11 studs
                    myHrp.CFrame = mobHrp.CFrame * CFrame.new(0, 11, 0)
                    
                    -- Tự động vung vũ khí đánh
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
            end)
        end
    end
end)
