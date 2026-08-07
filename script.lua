local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- Thông báo kích hoạt
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Quái",
    Text = "Fix triệt để: Đã khóa trọng lực & quay mặt đánh!",
    Duration = 3
})

-- 1. Bật Noclip xuyên vật thể
RunService.Stepped:Connect(function()
    if player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 2. Hàm Tự Động Chọn & Trang Bị Melee
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

-- 3. Hàm Tìm Quái Gần Nhất
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

-- 4. Vòng Lặp Auto Farm (Tự tắt sau 3 phút)
task.spawn(function()
    local startTime = tick()
    
    while task.wait(0.05) do
        -- Tự ngắt sau 3 phút (180 giây)
        if tick() - startTime >= 180 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Auto Farm Quái",
                Text = "Đã hết 3 phút, script đã dừng hoàn toàn!",
                Duration = 5
            })
            break
        end

        pcall(function()
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = character.HumanoidRootPart
            equipMelee()
            
            local targetMob = getClosestMob(300)
            
            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                local mobHrp = targetMob.HumanoidRootPart
                
                -- Triệt tiêu lực rơi, giữ nhân vật đứng im trên không
                hrp.AssemblyLinearVelocity = Vector3.zero
                
                -- Đứng cao 9 studs và XOAY MẶT THẲNG XUỐNG ĐẦU QUÁI để đánh trúng
                hrp.CFrame = CFrame.new(mobHrp.Position + Vector3.new(0, 9, 0), mobHrp.Position)
                
                -- Kích hoạt đòn đánh trực tiếp từ vũ khí
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                
                -- Nhấp chuột liên tục
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1, 1))
                VirtualUser:Button1Up(Vector2.new(1, 1))
            end
        end)
    end
end)
