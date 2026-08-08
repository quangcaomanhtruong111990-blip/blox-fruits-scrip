local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Cấu hình
local maxQuests = 10           
local banditCount = 0          
local jungleCount = 0          
local isFarming = false        
local isTakingQuest = false   -- Khóa chống spam nhận Q
local isAtJungle = false       
local isCompleted = false      
local isTweening = false       

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

-- 2. Hàm dọn dẹp GUI đối thoại NPC bị kẹt
local function clearDialogueUI()
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            local dialogue = playerGui:FindFirstChild("Dialogue")
            if dialogue then dialogue.Enabled = false end
            
            local mainGui = playerGui:FindFirstChild("Main")
            if mainGui then
                local talkFrame = mainGui:FindFirstChild("Talk") or mainGui:FindFirstChild("Dialog")
                if talkFrame then talkFrame.Visible = false end
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

-- 5. Hàm Nhận Quest Bandit
local function startBanditQuest()
    if isTakingQuest then return end
    
    local playerGui = player:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("Main")
    local questFrame = mainGui and mainGui:FindFirstChild("Quest")
    
    if questFrame and questFrame.Visible then
        clearDialogueUI()
        return
    end
    
    isTakingQuest = true
    
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then 
            commF:InvokeServer("StartQuest", "BanditQuest1", 1) 
        end
    end)
    
    task.wait(0.3)
    clearDialogueUI()
    
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = BANDIT_POS * CFrame.new(0, 0, 10)
    end
    
    task.wait(1.5)
    isTakingQuest = false
end

-- 6. Hàm Nhận Quest Khỉ
local function startJungleQuest()
    if isTakingQuest then return end
    
    local playerGui = player:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("Main")
    local questFrame = mainGui and mainGui:FindFirstChild("Quest")
    
    if questFrame and questFrame.Visible then
        clearDialogueUI()
        return
    end
    
    isTakingQuest = true
    
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then 
            commF:InvokeServer("StartQuest", "JungleQuest", 1) 
        end
    end)
    
    task.wait(0.3)
    clearDialogueUI()
    
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = JUNGLE_POS * CFrame.new(0, 0, 10)
    end
    
    task.wait(1.5)
    isTakingQuest = false
end

-- 7. Tìm Quái Gần Nhất
local function getClosestMob(mobName, maxDistance)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = maxDistance

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if mob.Name == mobName then
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

-- 8. Xử Lý Nút Bấm ON/OFF
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
            toggleBtn.Text = "BANDIT: (0/10)"
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "BẮT ĐẦU",
                Text = "Farm 10 Bandit -> Bay Đảo Khỉ -> Farm 10 Khỉ!",
                Duration = 3
            })
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

-- 9. Bộ Đếm Quest Tự Động
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
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "SANG ĐẢO KHỈ",
                        Text = "Bắt đầu farm 10 Quest Khỉ!",
                        Duration = 4
                    })
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
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "HOÀN THÀNH",
                    Text = "Đã xong 10 Q Bandit và 10 Q Khỉ! Đang đứng yên.",
                    Duration = 5
                })
            end
        end
    end
end)

-- 10. Vòng Lặp Farm Chính
task.spawn(function()
    while task.wait(0.1) do
        if isFarming and not isTweening and not isCompleted then
            pcall(function()
                clearDialogueUI()
                
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                
                -- ĐẢO 1: Farm Bandit
                if not isAtJungle then
                    if questFrame and not questFrame.Visible then
                        if not isTakingQuest then
                            character.HumanoidRootPart.CFrame = BANDIT_POS
                            startBanditQuest()
                        end
                        return
                    end
                    
                    local targetMob = getClosestMob("Bandit", 350)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 4, 2)
                        
                        if not character.HumanoidRootPart:FindFirstChild("FarmBV") then
                            local bv = Instance.new("BodyVelocity")
                            bv.Name = "FarmBV"
                            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = character.HumanoidRootPart
                        end
                        
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    else
                        if character.HumanoidRootPart:FindFirstChild("FarmBV") then
                            character.HumanoidRootPart.FarmBV:Destroy()
                        end
                        character.HumanoidRootPart.CFrame = BANDIT_POS
                    end
                    
                -- ĐẢO KHỈ: Farm Monkey
                else
                    if questFrame and not questFrame.Visible then
                        if not isTakingQuest then
                            character.HumanoidRootPart.CFrame = JUNGLE_POS
                            startJungleQuest()
                        end
                        return
                    end
                    
                    local targetMob = getClosestMob("Monkey", 350)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 4, 2)
                        
                        if not character.HumanoidRootPart:FindFirstChild("FarmBV") then
                            local bv = Instance.new("BodyVelocity")
                            bv.Name = "FarmBV"
                            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = character.HumanoidRootPart
                        end
                        
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    else
                        if character.HumanoidRootPart:FindFirstChild("FarmBV") then
                            character.HumanoidRootPart.FarmBV:Destroy()
                        end
                        character.HumanoidRootPart.CFrame = JUNGLE_POS
                    end
                end
            end)
        end
    end
end)
