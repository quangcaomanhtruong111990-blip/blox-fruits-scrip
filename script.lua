local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- Thông báo kích hoạt
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Quái",
    Text = "Hạ cao độ xuống 9 - Tự động tắt sau 3 phút!",
    Duration = 3
})

-- 1. Hàm Tự Động Chọn & Trang Bị Cận Chiến (Melee)
local function equipMelee()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not character or not backpack then return end
    
    if not character:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword") then
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

-- 3. Vòng Lặp Auto Farm (Chạy trong 3 phút = 180 giây)
task.spawn(function()
    local startTime = tick()
    
    while task.wait(0.05) do
        -- Kiểm tra nếu đủ 3 phút (180s) thì tự tắt
        if tick() - startTime >= 180 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Auto Farm Quái",
                Text = "Đã hết 3 phút, script đã tự dừng!",
                Duration = 5
            })
            break
        end

        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Tự động lấy Melee cầm lên tay
            equipMelee()
            
            local targetMob = getClosestMob(300)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Bay cao đúng 9 studs trên đầu quái
                character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 9, 0)
                
                -- Kích hoạt đòn đánh của vũ khí
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                
                -- Nhấp chuột đánh liên tục
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1, 1))
                VirtualUser:Button1Up(Vector2.new(1, 1))
            end
        end)
    end
end)
