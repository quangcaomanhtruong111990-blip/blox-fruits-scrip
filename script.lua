local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Cấu hình
local maxQuests = 10           -- Số lần làm Q mỗi đảo
local banditCount = 0          -- Đếm Q Bandit
local jungleCount = 0          -- Đếm Q Khỉ
local isFarming = false        -- Trạng thái ON/OFF
local isAtJungle = false       -- Trạng thái đang ở Đảo Khỉ
local isTweening = false       -- Đang trong quá trình bay
local isTakingQuest = false   -- Chống lặp nhận quest
local lastQuestTime = 0 

-- Tọa độ 2 Đảo
local BANDIT_POS = CFrame.new(1059, 16, 1549)
local JUNGLE_POS = CFrame.new(-1612.8, 36.8, 149.2)

-- 1. Giao diện nút bấm ON/OFF
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmTwoIslandsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.new(0, 200, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "FARM: OFF"
toggleBtn.Active = true
toggleBtn.Draggable = true

-- 2. Hàm dọn dẹp UI đối thoại NPC (Ngăn kẹt thoại)
local function clearDialogueUI()
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        local dialogue = playerGui:FindFirstChild("Dialogue")
        if dialogue then dialogue.Enabled = false end
        
        local mainGui = playerGui:FindFirstChild("Main")
        if mainGui then
            for _, v in pairs(mainGui:GetChildren()) do
                if v.Name == "Talk" or v.Name == "Dialog" or v.Name == "Dialogue" then
                    v.Visible = false
                end
            end
        end
    end)
end

-- 3. Hàm Bay Mượt (Speed 150 - An toàn Anti-cheat)
local function ultraSlowTeleport(targetCFrame)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 150 
    local timeToTravel = distance / speed
    
    isTweening = true
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = hrp
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    
    tween.Completed:Wait()
    
    if bodyVelocity then bodyVelocity:Destroy() end
    isTweening = false
end

-- 4. Hàm Trang Bị Vũ Khí
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

-- 5. Hàm Nhận Quest Gửi Remote Chuẩn
local function takeQuestOnce(questName, targetCFrame)
    if isTakingQuest or (tick() - lastQuestTime < 4) then return end
    isTakingQuest = true
    lastQuestTime = tick()
    
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = targetCFrame
        task.wait(0.4)
        
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then 
                commF:InvokeServer("StartQuest", questName, 1) 
            end
        end)
        
        task.wait(0.4)
        clearDialogueUI()
    end
    
    isTakingQuest = false
end

-- 6. Tìm Quái Gần Nhất
local function getClosestMob(mobName, maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, mobName) then
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
    end
    return closestMob
end

-- 7. Xử Lý Nút Bấm ON/OFF
toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        task.spawn(function()
            banditCount = 0
            jungleCount = 0
            isAtJungle = false
            isTweening = false
            isTakingQuest = false
            lastQuestTime = 0
            
            -- Đứng ở đâu cũng sẽ bay từ từ về Đảo Bandit trước
            toggleBtn.Text = "BAY VỀ ĐẢO BANDIT..."
            pcall(function()
                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if commF then commF:InvokeServer("AbandonQuest") end
            end)
            ultraSlowTeleport(BANDIT_POS)
            
            toggleBtn.Text = "BANDIT: (0/10)"
        end)
    else
        toggleBtn.Text = "FARM: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            if character.HumanoidRootPart:FindFirstChild("FarmBV") then
                character.HumanoidRootPart.FarmBV:Destroy()
            end
        end
    end
end)

-- 8. Vòng Lặp Farm Chính
local currentMobTarget = nil

task.spawn(function()
    while task.wait(0.05) do
        if isFarming and not isTweening then
            pcall(function()
                clearDialogueUI()
                
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                -- BƯỚC 1: KIỂM TRA VÀ NHẬN QUEST NẾU CẦN
                if tick() - lastQuestTime > 4 then
                    if not isAtJungle then
                        takeQuestOnce("BanditQuest1", BANDIT_POS)
                    else
                        takeQuestOnce("JungleQuest", JUNGLE_POS)
                    end
                end
                
                -- BƯỚC 2: TẮT VA CHẠM
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                
                equipWeapon()
                
                local targetMobName = not isAtJungle and "Bandit" or "Monkey"
                local defaultPos = not isAtJungle and BANDIT_POS or JUNGLE_POS
                
                local targetMob = getClosestMob(targetMobName, 500)
                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local mobHrp = targetMob.HumanoidRootPart
                    local mobHumanoid = targetMob:FindFirstChild("Humanoid")
                    
                    -- Bay cao 8 studs đứng trên đầu quái
                    character.HumanoidRootPart.CFrame = CFrame.new(mobHrp.Position + Vector3.new(0, 8, 0))
                    
                    if not character.HumanoidRootPart:FindFirstChild("FarmBV") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "FarmBV"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.new(0, 0, 0)
                        bv.Parent = character.HumanoidRootPart
                    end
                    
                    -- Lắng nghe quái chết để đếm lượt làm Q
                    if currentMobTarget ~= targetMob and mobHumanoid then
                        currentMobTarget = targetMob
                        mobHumanoid.Died:Connect(function()
                            if not isAtJungle then
                                banditCount = banditCount + 1
                                toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxQuests .. ")"
                                
                                -- Hoàn thành 10 lần Q Bandit -> Bay sang Đảo Khỉ
                                if banditCount >= maxQuests then
                                    isAtJungle = true
                                    toggleBtn.Text = "BAY THẲNG SANG KHỈ..."
                                    
                                    if character.HumanoidRootPart:FindFirstChild("FarmBV") then
                                        character.HumanoidRootPart.FarmBV:Destroy()
                                    end
                                    
                                    task.spawn(function()
                                        ultraSlowTeleport(JUNGLE_POS)
                                        toggleBtn.Text = "KHỈ: (0/10)"
                                    end)
                                end
                            else
                                jungleCount = jungleCount + 1
                                toggleBtn.Text = "KHỈ: (" .. jungleCount .. "/" .. maxQuests .. ")"
                                
                                -- Hoàn thành 10 lần Q Khỉ -> Đứng yên & Tắt Script
                                if jungleCount >= maxQuests then
                                    isFarming = false
                                    toggleBtn.Text = "HOÀN THÀNH - TẮT SCRIPT"
                                    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                                    
                                    if character.HumanoidRootPart:FindFirstChild("FarmBV") then
                                        character.HumanoidRootPart.FarmBV:Destroy()
                                    end
                                end
                            end
                        end)
                    end
                    
                    -- Kích hoạt đòn đánh
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then 
                        tool:Activate() 
                    end
                    
                    local netFolder = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
                    if netFolder and netFolder:FindFirstChild("RegisterAttack") then
                        netFolder.RegisterAttack:InvokeServer(0.1)
                    end
                    
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(1, 1))
                    VirtualUser:Button1Up(Vector2.new(1, 1))
                else
                    if character.HumanoidRootPart:FindFirstChild("FarmBV") then
                        character.HumanoidRootPart.FarmBV:Destroy()
                    end
                    character.HumanoidRootPart.CFrame = defaultPos * CFrame.new(0, 8, 0)
                end
            end)
        end
    end
end)
