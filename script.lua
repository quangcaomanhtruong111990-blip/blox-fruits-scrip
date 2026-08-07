local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Fly",
    Text = "Đã tăng độ cao lên 25 studs & khóa bay lơ lửng!",
    Duration = 3
})

-- Tạo bộ giữ vị trí bay (BodyVelocity)
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.Name = "HoverVelocity"
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.MaxForce = Vector3.new( math.huge, math.huge, math.huge )
bodyVelocity.Parent = hrp

-- 1. Hàm tự trang bị vũ khí
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

-- 2. Hàm tìm quái gần nhất
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

-- 3. Vòng lặp Farm chính
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            -- Đảm bảo giữ bộ bay không bị mất khi chết / respawn
            local myHrp = char.HumanoidRootPart
            if not myHrp:FindFirstChild("HoverVelocity") then
                bodyVelocity.Parent = myHrp
            end

            equipWeapon()
            local targetMob = getClosestMob(400)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Đứng cao trên đầu quái 25 studs (An toàn tuyệt đối)
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
end)
