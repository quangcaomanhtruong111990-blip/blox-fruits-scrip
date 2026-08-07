local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- Thông báo kích hoạt
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Quái",
    Text = "Tự lấy Cận Chiến & Đánh (Tắt sau 3 phút)",
    Duration = 3
})

-- 1. Hàm Tự Động Chọn & Cầm Vũ Khí Cận Chiến (Melee)
local function equipMelee()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not character or not backpack then return end
    
    -- Kiểm tra nếu chưa cầm vũ khí trên tay
    if not character:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.ToolTip == "Melee" then
                character.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

-- 2. Hàm Tìm Con Quái Gần Nhất
local function getClosestMob(maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
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
    return closestMob
end

-- 3. Vòng Lặp Auto Farm (Tự tắt sau 3 phút)
task.spawn(function()
    local startTime = tick()
    
    while task.wait(0.1) do
        -- Tự ngắt sau 3 phút (180 giây)
        if tick() - startTime >= 180 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Auto Farm Quái",
                Text = "Đã hết 3 phút, script đã dừng!",
                Duration = 5
            })
            break
        end

        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Tự chọn Cận Chiến
            equipMelee()
            
            -- Quét quái trong phạm vi 300 studs
            local targetMob = getClosestMob(300)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Bay cao 12 studs trên đầu quái
                character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 12, 0)
                
                -- Kích hoạt chiêu đòn của Tool trên tay
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                
                -- Giả lập nhấp chuột đầy đủ (Nhấn xuống + Thả ra)
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(500, 500))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(500, 500))
            end
        end)
    end
end)
