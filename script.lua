local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Cấu hình
local maxQuests = 10           
local banditCount = 0          
local jungleCount = 0          
local isFarming = false        
local isAtJungle = false       
local isCompleted = false      
local isTweening = false       
local isTakingQuest = false   
local lastQuestTime = 0 -- Khóa thời gian nhận quest để chống nhấp nháy

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

-- 2. Hàm dọn dẹp UI đối thoại NPC
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

-- 3. Hàm Bay Mượt
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

-- 4. Trang Bị Vũ Khí
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

-- 5. Hàm Nhận Quest Chống Nhấp Nháy Cứng
local function takeQuestOnce(questName, targetCFrame)
    if isTakingQuest or (tick() - lastQuestTime < 3) then return end
    isTakingQuest = true
    lastQuestTime = tick()
    
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = targetCFrame
        task.wait(0.5)
        
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then 
                commF:InvokeServer("StartQuest", questName, 1) 
            end
        end)
        
        task.wait(0.5)
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
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local distToJungle = (hrp.Position - JUNGLE_POS.Position).Magnitude
                
                if distToJungle < 500 then
                    toggleBtn.Text = "BAY MƯỢT VỀ ĐẢO 1..."
                    pcall(function()
                        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                        if commF then commF:InvokeServer("AbandonQuest") end
                    end)
                    ultraSlowTeleport(BANDIT_POS)
                end
            end
            
            banditCount = 0
            jungleCount = 0
            isAtJungle = false
            isCompleted = false
            isTweening = false
            isTakingQuest = false
            lastQuestTime = 0
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

-- 8. Bộ Đếm Quest Tự Động
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isTweening and not isCompleted then
        if not isAtJungle then
            banditCount = banditCount + 1
            toggleBtn.Text = "BANDIT: (" .. banditCount .. "/" .. maxQuests .. ")"
            
            if banditCount >= maxQuests then
                isAtJungle = true
                toggleBtn.Text = "ĐANG BAY SANG KHỈ..."
                
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart:FindFirstChild("FarmBV") then
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
            
            if jungleCount >= maxQuests then
                isCompleted = true
                toggleBtn.Text = "HOÀN THÀNH (2 ĐẢO)"
                toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart:FindFirstChild("FarmBV") then
                    character.HumanoidRootPart.FarmBV:Destroy()
                end
            end
        end
    end
end)

-- 9. Vòng Lặp Farm & Đánh Quái (Chống Spam Nhận Quest)
task.spawn(function()
    while task.wait(0.05) do
        if isFarming and not isTweening and not isCompleted then
            pcall(function()
                clearDialogueUI()
                
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                -- KIỂM TRA ĐÃ CÓ QUEST CHƯA (Dựa vào UI hoặc thuộc tính)
                local hasQuest = questFrame.Visible or (playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest") and playerGui.Main.Quest.Visible)
                
                -- BƯỚC 1: NHẬN QUEST NẾU CHƯA CÓ
                if not hasQuest then
                    if not isTakingQuest and (tick() - lastQuestTime > 3) then
                        if not isAtJungle then
                            takeQuestOnce("BanditQuest1", BANDIT_POS)
                        else
                            takeQuestOnce("JungleQuest", JUNGLE_POS)
                        end
                    end
                    return
                end
                
                -- BƯỚC 2: TẮT TÍNH NĂNG VA CHẠM
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
                    
                    -- Bay cao 8 studs so với quái
                    character.HumanoidRootPart.CFrame = CFrame.new(mobHrp.Position + Vector3.new(0, 8, 0))
                    
                    if not character.HumanoidRootPart:FindFirstChild("FarmBV") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "FarmBV"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.new(0, 0, 0)
                        bv.Parent = character.HumanoidRootPart
                    end
                    
                    -- Kích hoạt đòn đánh
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then 
                        tool:Activate() 
                    end
                    
                    -- Remote đánh Blox Fruits
                    local netFolder = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
                    if netFolder and netFolder:FindFirstChild("RegisterAttack") then
                        netFolder.RegisterAttack:InvokeServer(0.1)
                    elseif ReplicatedStorage:FindFirstChild("RigControllerNeverClose") then
                        ReplicatedStorage.RigControllerNeverClose:InvokeServer("WeaponAttack")
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
