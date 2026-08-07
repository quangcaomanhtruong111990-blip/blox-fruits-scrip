local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local isFarming = false
local NetRemotes = ReplicatedStorage:WaitForChild("Remotes")

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

-- 2. Hàm Tự Trang Bị Vũ Khí
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

-- 3. Hàm Gom Quái Về 1 Điểm
local function bringMobs(targetPos, radius)
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _, mob in pairs(enemies:GetChildren()) do
        local mobHrp = mob:FindFirstChild("HumanoidRootPart")
        local mobHum = mob:FindFirstChild("Humanoid")
        
        if mobHrp and mobHum and mobHum.Health > 0 then
            if (mobHrp.Position - targetPos).Magnitude <= radius then
                mobHrp.CFrame = CFrame.new(targetPos)
                mobHrp.CanCollide = false
                mobHum.WalkSpeed = 0
            end
        end
    end
end

-- 4. Hàm Fast Attack (Gửi Remote trực tiếp, không vung tay)
local function fastAttack()
    pcall(function()
        local netRemotesFolder = NetRemotes:FindFirstChild("Validator") or NetRemotes
        if netRemotesFolder:FindFirstChild("RegisterAttack") then
            netRemotesFolder.RegisterAttack:FireServer(0.1)
        elseif NetRemotes:FindFirstChild("CommF_") then
            NetRemotes.CommF_:InvokeServer("RegisterAttack")
        end
    end)
end

-- 5. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.01) do -- Chạy tốc độ siêu nhanh
        if isFarming then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
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
                            local dist = (character.HumanoidRootPart.Position - mobHrp.Position).Magnitude
                            if dist < shortestDistance then
                                shortestDistance = dist
                                targetMob = mob
                            end
                        end
                    end
                end

                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    local farmPos = mobHrp.Position + Vector3.new(0, 10, 0)
                    
                    -- Khóa vị trí người chơi trên đầu quái
                    character.HumanoidRootPart.CFrame = CFrame.new(farmPos, mobHrp.Position)
                    
                    -- Gom quái xung quanh lại
                    bringMobs(mobHrp.Position, 250)
                    
                    -- Xả đòn đánh cực nhanh
                    fastAttack()
                end
            end)
        end
    end
end)
