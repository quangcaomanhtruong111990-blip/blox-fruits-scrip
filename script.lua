local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

local isTeleporting = false
-- Tọa độ chuẩn xác trên đất liền tại khu vực Coliseum (Sea 2)
local COLISEUM_SAFE_POS = CFrame.new(-1514, 118, 3075) 

-- 1. Tạo giao diện nút bấm
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportColiseumGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 220, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "TELEPORT ĐẾN COLISEUM"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm bay mượt chống kẹt
local function flyToTarget(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    local speed = 250
    local timeToTravel = distance / speed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "AntiFall" then v:Destroy() end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    tween:Play()
    tween.Completed:Connect(function()
        if bv then bv:Destroy() end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        isTeleporting = false
    end)
end

-- 3. Xử lý sự kiện bấm nút
toggleBtn.MouseButton1Click:Connect(function()
    if isTeleporting then return end
    isTeleporting = true
    toggleBtn.Text = "ĐANG BAY TỚI ĐẤT LIỀN..."
    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    
    task.spawn(function()
        flyToTarget(COLISEUM_SAFE_POS)
        task.wait(1.5)
        toggleBtn.Text = "ĐÃ ĐẾN NƠI AN TOÀN"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    end)
end)
