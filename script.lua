local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tọa độ chuẩn xác phòng hầm tù bên trong Coliseum (Sea 2)
local KING_RED_HEAD_CFRAME = CFrame.new(-1508, 12, 3010)

-- 1. Giao diện nút bấm
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportKingRedHeadGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 240, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "TELE ĐẾN KING RED HEAD"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm dịch chuyển tức thời không bị trôi
local function teleportToNPC()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    
    -- Vô hiệu hóa va chạm để không bị văng map
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    -- Khóa lực rơi
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    -- Dịch chuyển thẳng vào điểm NPC
    hrp.CFrame = KING_RED_HEAD_CFRAME
    task.wait(0.2)
    hrp.CFrame = KING_RED_HEAD_CFRAME
    
    task.wait(1)
    if bv then bv:Destroy() end
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

-- 3. Sự kiện bấm nút
toggleBtn.MouseButton1Click:Connect(function()
    toggleBtn.Text = "ĐANG DỊCH CHUYỂN..."
    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    
    teleportToNPC()
    
    toggleBtn.Text = "ĐÃ ĐẾN MẶT NPC!"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
end)
