local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Trạng thái Script
local isScriptEnabled = true
local currentIsland = 1 -- 1: Đảo Bandit, 2: Đảo Khỉ (Jungle)
local isTweening = false
local currentTween = nil

-- Cấu hình tốc độ bay
local FLY_SPEED_LONG = 120  -- Bay giữa các đảo
local FLY_SPEED_SHORT = 90   -- Bay lại gần quái

-- Tọa độ cố định
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local BANDIT_MOB_POS = CFrame.new(1145, 17, 1630)

local JUNGLE_NPC_POS = CFrame.new(-1600, 36, 153)
local JUNGLE_MOB_POS = CFrame.new(-1450, 26, 200)

------------------------------------------------------------------
-- HÀM DỌN DẸP / TRẢ LẠI QUYỀN ĐIỀU KHIỂN
------------------------------------------------------------------
local function restoreCharacterControl()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "AntiFall" then 
                    v:Destroy() 
                end
            end
        end
    end
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    isTweening = false
end

------------------------------------------------------------------
-- GIAO DIỆN DECOR HIỆN ĐẠI (DARK GLASS UI)
------------------------------------------------------------------
if CoreGui:FindFirstChild("AutoFarmModernGui") then
    CoreGui.AutoFarmModernGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmModernGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- Khung chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 180, 0, 50)
mainFrame.Position = UDim2.new(0, 30, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 1.5
frameStroke.Color = Color3.fromRGB(0, 230, 150)
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = mainFrame

-- Đèn LED trạng thái
local statusDot = Instance.new("Frame")
statusDot.Name = "StatusDot"
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 14, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)
statusDot.Parent = mainFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

-- Tiêu đề chữ
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0, 100, 0, 20)
titleText.Position = UDim2.new(0, 32, 0, 8)
titleText.BackgroundTransparency = 1
titleText.Text = "AUTO FARM"
titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
titleText.TextSize = 13
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = mainFrame

-- Sub Text (Phím tắt)
local subText = Instance.new("TextLabel")
subText.Name = "SubText"
subText.Size = UDim2.new(0, 100, 0, 14)
subText.Position = UDim2.new(0, 32, 0, 26)
subText.BackgroundTransparency = 1
subText.Text = "Status: RUNNING [K]"
subText.TextColor3 = Color3.fromRGB(0, 230, 115)
subText.TextSize = 11
subText.Font = Enum.Font.GothamMedium
subText.TextXAlignment = Enum.TextXAlignment.Left
subText.Parent = mainFrame

-- Nút Bật/Tắt click trực tiếp lên Frame
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""
toggleBtn.Parent = mainFrame

local function updateUIState()
    if isScriptEnabled then
        frameStroke.Color = Color3.fromRGB(0, 230, 150)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)
        subText.Text = "Status: RUNNING [K]"
        subText.TextColor3 = Color3.fromRGB(0, 230, 115)
    else
        frameStroke.Color = Color3.fromRGB(235, 60, 60)
        statusDot.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
        subText.Text = "Status: PAUSED [K]"
        subText.TextColor3 = Color3.fromRGB(235, 60, 60)
    end
end

local function toggleState()
    isScriptEnabled = not isScriptEnabled
    updateUIState()
    if not isScriptEnabled then
        restoreCharacterControl()
    end
end

toggleBtn.MouseButton1Click:Connect(toggleState)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        toggleState()
    end
end)

------------------------------------------------------------------
-- HÀM BAY ĐƯỜNG THẲNG
------------------------------------------------------------------
local function flyLinearTo(targetCFrame, speed)
    if not isScriptEnabled then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    speed = speed or FLY_SPEED_LONG
    
    local startPos = hrp.Position
    local endPos = targetCFrame.Position
    local cruiseHeight = math.max(startPos.Y, endPos.Y) + 25
    
    local targetStraightCFrame = CFrame.new(endPos.X, cruiseHeight, endPos.Z)
    local distance = (hrp.Position - targetStraightCFrame.Position).Magnitude
    
    isTweening = true
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "AntiFall" then v:Destroy() end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "AntiFall"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    local timeToTravel = distance / speed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetStraightCFrame})
    
    currentTween:Play()
    currentTween.Completed:Wait()
    
    if isScriptEnabled then
        local landTween = TweenService:Create(hrp, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        currentTween = landTween
        landTween:Play()
        landTween.Completed:Wait()
    end

    if bv then bv:Destroy() end
    isTweening = false
end

local function flyShort(targetCFrame)
    if not isScriptEnabled then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    if distance < 3 then
        hrp.CFrame = targetCFrame
        return
    end
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    local tweenInfo = TweenInfo.new(distance / FLY_SPEED_SHORT, Enum.EasingStyle.Linear)
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
    end)
end

------------------------------------------------------------------
-- CÁC HÀM XỬ LÝ GAME
------------------------------------------------------------------
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

local function startQuest(questName)
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", questName, 1)
        end
    end)
end

local function getClosestMob(mobNamePattern)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = 1500

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, mobNamePattern) then
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

-- Fast Attack
local function fastAttack()
    pcall(function()
        local character = player.Character
        local tool = character and character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid:FindFirstChild("Animator") then
                for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
                    if track.Name:lower():find("attack") or track.Name:lower():find("slash") or track.Name:lower():find("punch") then
                        track:Stop()
                    end
                end
            end
        end
    end)
end

------------------------------------------------------------------
-- CHUYỂN ĐẢO KHI XONG QUEST
------------------------------------------------------------------
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isScriptEnabled and not isTweening then
        if currentIsland == 1 then
            currentIsland = 2
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Xong Đảo 1!",
                Text = "Đang bay từ từ sang Đảo Khỉ...",
                Duration = 4
            })
            
            task.spawn(function()
                flyLinearTo(JUNGLE_NPC_POS, FLY_SPEED_LONG)
            end)
        end
    end
end)

------------------------------------------------------------------
-- VÒNG LẮP CHÍNH
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.01) do
        if isScriptEnabled and not isTweening then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                equipWeapon()
                local hrp = character.HumanoidRootPart

                local questName = (currentIsland == 1) and "BanditQuest1" or "JungleQuest"
                local mobPattern = (currentIsland == 1) and "Bandit" or "Monkey"
                local npcPos = (currentIsland == 1) and BANDIT_NPC_POS or JUNGLE_NPC_POS
                local mobPos = (currentIsland == 1) and BANDIT_MOB_POS or JUNGLE_MOB_POS

                if questFrame and not questFrame.Visible then
                    local distToNpc = (hrp.Position - npcPos.Position).Magnitude
                    if distToNpc > 15 then
                        flyLinearTo(npcPos, FLY_SPEED_LONG)
                    end
                    if isScriptEnabled then
                        startQuest(questName)
                        task.wait(0.5)
                    end
                else
                    local targetMob = getClosestMob(mobPattern)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        local targetCFrame = mobHrp.CFrame * CFrame.new(0, 9, 0)
                        
                        flyShort(targetCFrame)
                        
                        local currentDistance = (hrp.Position - mobHrp.Position).Magnitude
                        if currentDistance <= 12 and isScriptEnabled then
                            for i = 1, 4 do
                                if not isScriptEnabled then break end
                                fastAttack()
                            end
                        end
                    else
                        flyShort(mobPos)
                    end
                end
            end)
        end
    end
end)
