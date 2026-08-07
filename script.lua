local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Biến trạng thái bật/tắt Auto Farm
local isFarming = false

-- 1. Tạo Giao Diện Nút Bật/Tắt (Toggle UI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 130, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0) -- Vị trí bên trái màn hình
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ (OFF)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true -- Cho phép kéo thả nút đến vị trí tùy thích

-- Xử lý sự kiện khi bấm nút
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        toggleBtn.Text = "FARM: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Chuyển màu xanh
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Chuyển màu đỏ
        
        -- Xóa bộ giữ bay khi dừng script để nhân vật di chuyển bình thường
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hover = character.HumanoidRootPart:FindFirstChild("HoverVelocity")
            if hover then hover:Destroy() end
        end
    end
end)

-- 2. Hàm tự trang bị vũ khí
local function equipWeapon()
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not char or not backpack then return end
    
    if not char:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword" or item.ToolTip == "Blox Fruit") then
                char.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

-- 3. Hàm tìm quái gần nhất
local function getClosestMob(maxDistance)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myHrp = char.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

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

-- 4. Vòng lặp Farm chính
task.spawn(function()
    while task.wait(0.05) do
        if isFarming then
            pcall(function()
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                local myHrp = char.HumanoidRootPart
                
                -- Tạo bộ giữ bay lơ lửng khi đang bật Farm
                local hover = myHrp:FindFirstChild("HoverVelocity")
                if not hover then
                    hover = Instance.new("BodyVelocity")
                    hover.Name = "HoverVelocity"
                    hover.Velocity = Vector3.new(0, 0, 0)
                    hover.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    hover.Parent = myHrp
                end

                equipWeapon()
                local targetMob = getClosestMob(400)
                
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    
                    -- Đứng cao trên đầu quái 25 studs
                    myHrp.CFrame = mobHrp.CFrame * CFrame.new(0, 25, 0)
                    
                    -- Thực hiện đòn đánh
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end)
        end
    end
end)
