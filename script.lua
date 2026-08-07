local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

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
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- Tạo sẵn bộ giữ vị trí bay (BodyVelocity)
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.Name = "HoverVelocity"
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

-- Xử lý bấm nút START / STOP
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        toggleBtn.Text = "FARM: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        -- Hủy hiệu ứng bay để nhân vật rơi xuống di chuyển bình thường
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hover = char.HumanoidRootPart:FindFirstChild("HoverVelocity")
            if hover then hover:Destroy() end
        end
    end
end)

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Fly UI",
    Text = "Đã tích hợp nút START / STOP & Hạ độ cao trúng quái 100%!",
    Duration = 3
})

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
                
                -- Đảm bảo giữ bộ bay không bị mất khi chết / respawn
                if not myHrp:FindFirstChild("HoverVelocity") then
                    bodyVelocity.Parent = myHrp
                end

                equipWeapon()
                local targetMob = getClosestMob(400)
                
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    
                    -- Nâng độ cao lên 12 studs (Thay vì 25 studs để đánh trúng quái)
                    myHrp.CFrame = mobHrp.CFrame * CFrame.new(0, 12, 0)
                    
                    -- Kéo quái sát lại gần chân nhân vật
                    mobHrp.CFrame = myHrp.CFrame * CFrame.new(0, -8, 0)
                    mobHrp.CanCollide = false
                    
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
