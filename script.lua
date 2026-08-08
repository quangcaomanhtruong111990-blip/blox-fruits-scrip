local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = player:WaitForChild("PlayerGui")

local currentIsland = 1 -- 1: Đảo 1 (Bandit), 2: Đảo Khỉ (Jungle)
local isFarming = true
local isTweening = false
local questCompletedCount = 0

-- Tọa độ cố định
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local BANDIT_MOB_POS = CFrame.new(1145, 17, 1630)

local JUNGLE_NPC_POS = CFrame.new(-1600, 36, 153)
local JUNGLE_MOB_POS = CFrame.new(-1450, 26, 200)

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm 2 Đảo",
    Text = "Chạy mượt - Bay đường thẳng - Không nhấp nhô!",
    Duration = 4
})

-- Hàm Bay Đường Thẳng Cố Định Độ Cao (Chống bay lên xuống)
local function flyLinearTo(targetCFrame, speed)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    speed = speed or 200
    
    -- Giữ nguyên độ cao Y an toàn (30 studs) để bay thẳng tắp
    local startPos = hrp.Position
    local endPos = targetCFrame.Position
    local cruiseHeight = math.max(startPos.Y, endPos.Y) + 30
    
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
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetStraightCFrame})
    
    tween:Play()
    tween.Completed:Wait()
    
    -- Đáp nhẹ xuống vị trí đích
    local landTween = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    landTween:Play()
    landTween.Completed:Wait()

    if bv then bv:Destroy() end
    isTweening = false
end

-- Bay khoảng ngắn khi đánh quái
local function flyShort(targetCFrame)
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
    
    local tweenInfo = TweenInfo.new(distance / 250, Enum.EasingStyle.Linear)
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

-- Trang bị vũ khí
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

-- Nhận Quest
local function startQuest(questName)
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", questName, 1)
        end
    end)
end

-- Tìm quái
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

-- Super Fast Attack Max Speed
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

-- Bộ lắng nghe xong Quest để bay chuyển đảo
local mainGui = playerGui:WaitForChild("Main")
local questFrame = mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isFarming and not isTweening then
        if currentIsland == 1 then
            currentIsland = 2
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Hoàn Thành Đảo 1!",
                Text = "Đang bay thẳng sang Đảo Khỉ...",
                Duration = 4
            })
            
            -- Bay thẳng tắp sang NPC Đảo Khỉ
            task.spawn(function()
                flyLinearTo(JUNGLE_NPC_POS, 180)
            end)
        end
    end
end)

-- Vòng lặp chính
task.spawn(function()
    while task.wait(0.01) do
        if isFarming and not isTweening then
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
                    if distToNpc > 20 then
                        flyLinearTo(npcPos, 200)
                    end
                    startQuest(questName)
                    task.wait(0.5)
                else
                    local targetMob = getClosestMob(mobPattern)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        local targetCFrame = mobHrp.CFrame * CFrame.new(0, 9, 0)
                        
                        flyShort(targetCFrame)
                        
                        for i = 1, 4 do
                            fastAttack()
                        end
                    else
                        flyShort(mobPos)
                    end
                end
            end)
        end
    end
end)
