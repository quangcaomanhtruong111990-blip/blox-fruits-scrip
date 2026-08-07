local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isFarming = false

-- 1. Tạo Giao Diện Toggle
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

toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        toggleBtn.Text = "FARM: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- 2. Hàm Tự Equip Vũ Khí
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

-- 3. Noclip & Giữ Vị Trí Tuyệt Đối (Chống giật / chống rơi)
RunService.Stepped:Connect(function()
    if isFarming and player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 4. Fast Attack Đạt Chuẩn Blox Fruits (Kích hoạt hitbox gây dame thật)
local function executeFastAttack()
    local char = player.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        -- Kích hoạt đòn đánh gốc
        tool:Activate()
        
        -- Bypass cooldown đòn đánh
        pcall(function()
            local combatFramework = require(player.PlayerScripts:WaitForChild("CombatFramework"))
            local activeController = combatFramework.activeController
            if activeController then
                activeController.timeToNextAttack = 0
                activeController.hitboxMagnitude = 60
                activeController:attack()
            end
        end)
    end
end

-- 5. Vòng Lặp Farm Chính
task.spawn(function()
    while true do
        task.wait()
        if isFarming then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local hrp = character.HumanoidRootPart
                equipWeapon()
                
                -- Tìm quái gần nhất
                local enemies = Workspace:FindFirstChild("Enemies")
                local targetMob = nil
                local shortestDistance = 350

                if enemies then
                    for _, mob in pairs(enemies:GetChildren()) do
                        local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                        local mobHum = mob:FindFirstChild("Humanoid")
                        if mobHrp and mobHum and mobHum.Health > 0 then
                            local dist = (hrp.Position - mobHrp.Position).Magnitude
                            if dist < shortestDistance then
                                shortestDistance = dist
                                targetMob = mob
                            end
                        end
                    end
                end

                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    
                    -- Khóa trọng lực để nhân vật KHÔNG RƠI / KHÔNG GIẬT
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    
                    -- Neo nhân vật cách đầu quái 10 studs
                    hrp.CFrame = mobHrp.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    -- Gom quái về vị trí target
                    for _, mob in pairs(enemies:GetChildren()) do
                        local mHrp = mob:FindFirstChild("HumanoidRootPart")
                        local mHum = mob:FindFirstChild("Humanoid")
                        if mHrp and mHum and mHum.Health > 0 and (mHrp.Position - mobHrp.Position).Magnitude < 200 then
                            mHrp.CFrame = mobHrp.CFrame
                            mHrp.CanCollide = false
                            mHum.WalkSpeed = 0
                        end
                    end
                    
                    -- Đánh
                    executeFastAttack()
                end
            end)
        end
    end
end)
