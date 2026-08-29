local currentSea = 1
local placeId = game.PlaceId

if placeId == 2753915549 then
    currentSea = 1
elseif placeId == 4442274612 or placeId == 508273428 then
    currentSea = 2
elseif placeId == 7449423635 then
    currentSea = 3
else
    local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("_WorldOrigin")
    if map then
        if map:FindFirstChild("Desert") or map:FindFirstChild("Jungle") or map:FindFirstChild("PirateVillage") then
            currentSea = 1
        elseif map:FindFirstChild("Cafe") or map:FindFirstChild("Mansion") or map:FindFirstChild("Colosseum") or map:FindFirstChild("SnowMountain") then
            currentSea = 2
        elseif map:FindFirstChild("PortTown") then
            currentSea = 3
        end
    end
end


if currentSea == 1 then
------------------------------------------------------------------
-- BẮT ĐẦU AUTO SEA 1
------------------------------------------------------------------
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")

------------------------------------------------------------------
-- CHỐNG AFK & CHỐNG KICK CAO CẤP
------------------------------------------------------------------
pcall(function()
    if getconnections then
        for _, conn in pairs(getconnections(player.Idled)) do
            if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
        end
    end
end)

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
end)

-- REMOTE FAST ATTACK TỪ GAME MODULES
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack") or Net:FindFirstChild("RegisterAttack")
local RegisterHit = Net:FindFirstChild("RE/RegisterHit") or Net:FindFirstChild("RegisterHit")

------------------------------------------------------------------
-- CẤU HÌNH CHỌN PHE & TRẠNG THÁI CHUNG
------------------------------------------------------------------
local CHOOSE_TEAM = "Pirates"
local isScriptEnabled = true
local isTweening = false
local currentTween = nil
local lastStatUpdate = 0
local lastAttackTime = 0
local isDoingGacha = false
local activeQuest = nil 
local isCheckingInitialGacha = true
local SCRIPT_VERSION = "1.0.9"

-- TỐC ĐỘ BAY AN TOÀN CHỐNG ANTI-CHEAT KICK
local FLY_SPEED_LONG = 110   
local FLY_SPEED_SHORT = 85   

local trackerText = nil 

local function updateTracker(text)
    if trackerText then
        trackerText.Text = "[v" .. SCRIPT_VERSION .. "] " .. text
    end
end

local function autoSelectTeam()
    pcall(function()
        if player.Team == nil or player.Team.Name == "Neutral" or player.Team.Name == "" then
            if CommF then CommF:InvokeServer("SetTeam", CHOOSE_TEAM) end
        end
    end)
end

autoSelectTeam()
repeat task.wait(1) autoSelectTeam() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

------------------------------------------------------------------
-- CẤU HÌNH GACHA & MELEE SEA 1
------------------------------------------------------------------
local gachaTargetPos = Vector3.new(-1441.9, 61.9, 3.1)
local TARGET_MASTERY = 400

local MeleeList = {
    { Name = "Black Leg", AltName = "Dark Step", RemoteName = "BuyBlackLeg", CFrame = CFrame.new(-983.1, 13.8, 3992.2), MinLevel = 100, Price = 150000 },
    { Name = "Electro", AltName = "Electric", RemoteName = "BuyElectro", CFrame = CFrame.new(-5384.1, 14.0, -2151.8), MinLevel = 300, Price = 500000 },
    { Name = "Fishman Karate", AltName = "Water Kung Fu", RemoteName = "BuyFishmanKarate", CFrame = CFrame.new(61587.2, 18.9, 986.9), MinLevel = 400, Price = 750000 }
}

local currentMeleeTarget = nil
local failedBuyList = {}

------------------------------------------------------------------
-- TỌA ĐỘ & TRẠNG THÁI SEA 2 QUEST
------------------------------------------------------------------
local POS_ICE_DOOR   = CFrame.new(1347, 37, -1325)
local POS_BOSS_ROOM  = CFrame.new(1385, 37, -1298)
local POS_DETECTIVE  = CFrame.new(4850, 5, 720)       
local POS_CAPTAIN    = CFrame.new(-466, 73, 300)      

local questStep = "GET_KEY"

------------------------------------------------------------------
-- DATABASE QUEST SEA 1
------------------------------------------------------------------
local QuestStages = {
    [1]  = { Level = 1,   QuestName = "BanditQuest1", QuestLevel = 1, MobName = "Bandit", NpcCFrame = CFrame.new(1059, 16, 1549), MobCFrame = CFrame.new(1190, 16, 1610) },
    [2]  = { Level = 15,  QuestName = "JungleQuest", QuestLevel = 1, MobName = "Monkey", NpcCFrame = CFrame.new(-1598, 37, 153), MobCFrame = CFrame.new(-1610, 22, 140) },
    [3]  = { Level = 30,  QuestName = "JungleQuest", QuestLevel = 2, MobName = "Gorilla", NpcCFrame = CFrame.new(-1598, 37, 153), MobCFrame = CFrame.new(-1240, 6, -490) },
    [4]  = { Level = 35,  QuestName = "BuggyQuest1", QuestLevel = 1, MobName = "Pirate", NpcCFrame = CFrame.new(-1140, 4, 3828), MobCFrame = CFrame.new(-1210, 4, 3900) },
    [5]  = { Level = 45,  QuestName = "BuggyQuest1", QuestLevel = 2, MobName = "Brute", NpcCFrame = CFrame.new(-1140, 4, 3828), MobCFrame = CFrame.new(-1145, 14, 4300) },
    [6]  = { Level = 60,  QuestName = "DesertQuest", QuestLevel = 1, MobName = "Desert Bandit", NpcCFrame = CFrame.new(894, 6, 4388), MobCFrame = CFrame.new(980, 6, 4430) },
    [7]  = { Level = 75,  QuestName = "DesertQuest", QuestLevel = 2, MobName = "Desert Officer", NpcCFrame = CFrame.new(894, 6, 4388), MobCFrame = CFrame.new(1570, 10, 4370) },
    [8]  = { Level = 90,  QuestName = "SnowQuest", QuestLevel = 1, MobName = "Snow Bandit", NpcCFrame = CFrame.new(1385, 87, -1298), MobCFrame = CFrame.new(1280, 105, -1380) },
    [9]  = { Level = 100, QuestName = "SnowQuest", QuestLevel = 2, MobName = "Snowman", NpcCFrame = CFrame.new(1385, 87, -1298), MobCFrame = CFrame.new(1280, 105, -1500) },
    [10] = { Level = 120, QuestName = "MarineQuest2", QuestLevel = 1, MobName = "Chief Petty Officer", NpcCFrame = CFrame.new(-5035, 28, 4324), MobCFrame = CFrame.new(-4800, 20, 4300) },
    [11] = { Level = 150, QuestName = "SkyQuest", QuestLevel = 1, MobName = "Sky Bandit", NpcCFrame = CFrame.new(-4840, 718, -2620), MobCFrame = CFrame.new(-4969.2, 278.1, -2820.0) },
    [12] = { Level = 250, QuestName = "ColosseumQuest", QuestLevel = 1, MobName = "Toga Warrior", NpcCFrame = CFrame.new(-1580, 7, -2980), MobCFrame = CFrame.new(-1800, 7, -2900) },
    [13] = { Level = 275, QuestName = "ColosseumQuest", QuestLevel = 2, MobName = "Gladiator", NpcCFrame = CFrame.new(-1580, 7, -2980), MobCFrame = CFrame.new(-1380, 7, -3300) },
    [14] = { Level = 300, QuestName = "MagmaQuest", QuestLevel = 1, MobName = "Military Soldier", NpcCFrame = CFrame.new(-5315, 12, 8515), MobCFrame = CFrame.new(-5400, 12, 8500) },
    [15] = { Level = 325, QuestName = "MagmaQuest", QuestLevel = 2, MobName = "Military Spy", NpcCFrame = CFrame.new(-5315, 12, 8515), MobCFrame = CFrame.new(-5800, 70, 8750) },
    [16] = { Level = 375, QuestName = "FishmanQuest", QuestLevel = 1, MobName = "Fishman Warrior", NpcCFrame = CFrame.new(61160, 18, 1565), MobCFrame = CFrame.new(60800, 18, 1500) },
    [17] = { Level = 400, QuestName = "FishmanQuest", QuestLevel = 2, MobName = "Fishman Commando", NpcCFrame = CFrame.new(61160, 18, 1565), MobCFrame = CFrame.new(61800, 18, 1500) },
    [18] = { Level = 625, QuestName = "FountainQuest", QuestLevel = 1, MobName = "Galley Pirate", NpcCFrame = CFrame.new(5258, 38, 4050), MobCFrame = CFrame.new(5580, 90, 4950) },
    [19] = { Level = 650, QuestName = "FountainQuest", QuestLevel = 2, MobName = "Galley Captain", NpcCFrame = CFrame.new(5258, 38, 4050), MobCFrame = CFrame.new(5600, 38, 4900) }
}

------------------------------------------------------------------
-- HÀM BỔ TRỢ DI CHUYỂN & GIỮ CHÂN TRÊN KHÔNG AN TOÀN
------------------------------------------------------------------
local function forceUnsit()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if humanoid.Sit then humanoid.Sit = false end
            if humanoid.PlatformStand then humanoid.PlatformStand = false end
        end
    end
end

local noclipConnection = nil

local function setNoclip(enabled)
    if enabled then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function ensureHoverBodyVelocity()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local bv = hrp:FindFirstChild("AntiFallHover")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "AntiFallHover"
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(400000, 400000, 400000) -- Đã chỉnh từ 9e9 về lực hợp lệ chống cờ gian lận
            bv.Parent = hrp
        end
    end
end

local function flyLinearTo(targetCFrame, speed)
    if not isScriptEnabled then return end
    forceUnsit()
    ensureHoverBodyVelocity()
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    speed = speed or FLY_SPEED_LONG
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    if distance < 4 then
        hrp.CFrame = targetCFrame
        isTweening = false
        setNoclip(false)
        return
    end

    isTweening = true
    setNoclip(true)

    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    currentTween.Completed:Wait()

    setNoclip(false)
    isTweening = false
end

local function restoreCharacterControl()
    local character = player.Character
    if character then
        setNoclip(false)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "AntiFall" or v.Name == "AntiFallHover" then v:Destroy() end
            end
        end
    end
    if currentTween then currentTween:Cancel() currentTween = nil end
    isTweening = false
    forceUnsit()
end

------------------------------------------------------------------
-- HÀM THOẠI, CLICK GACHA & CẤT TRÁI ÁC QUỶ
------------------------------------------------------------------
local function autoClickDialogue()
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then return end
        for _, v in pairs(playerGui:GetDescendants()) do
            if v:IsA("TextButton") and v.Visible and v.AbsoluteSize.X > 0 then
                local text = string.lower(v.Text)
                if string.find(text, "chính xác") or string.find(text, "yes") or string.find(text, "tiếp") or string.find(text, "đi thôi") or string.find(text, "sang sea 2") then
                    pcall(function()
                        for _, signal in pairs({"MouseButton1Click", "MouseButton1Down", "Activated"}) do
                            if getconnections then
                                for _, con in pairs(getconnections(v[signal])) do con:Fire() end
                            end
                        end
                    end)
                    local pos = v.AbsolutePosition + (v.AbsoluteSize / 2)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, false, game, 1)
                end
            end
        end
    end)
end

local function getDialogue()
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui and playerGui:FindFirstChild("Main") then
        local dialogue = playerGui.Main:FindFirstChild("Dialogue")
        if dialogue and dialogue.Visible then return dialogue end
    end
    return nil
end

local function clickRedSafeSpot()
    local camera = workspace.CurrentCamera
    if camera then
        local viewportSize = camera.ViewportSize
        VirtualInputManager:SendMouseButtonEvent(viewportSize.X * 0.50, viewportSize.Y * 0.58, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(viewportSize.X * 0.50, viewportSize.Y * 0.58, 0, false, game, 0)
    end
end

local function clickGuiButton(btn)
    if not btn or not btn.Visible then return false end
    if firesignal then
        pcall(function()
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        end)
    end
    local guiInset = GuiService:GetGuiInset()
    local absPos, absSize = btn.AbsolutePosition, btn.AbsoluteSize
    if absSize.X > 0 and absSize.Y > 0 then
        local centerX = absPos.X + (absSize.X / 2)
        local centerY = absPos.Y + (absSize.Y / 2) + guiInset.Y
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
        return true
    end
    return false
end

local function clickDialogueOption1()
    local dialogue = getDialogue()
    if not dialogue then return false end
    local opt1 = dialogue:FindFirstChild("Option1", true) or dialogue:FindFirstChild("Option", true)
    if opt1 then
        local btn = opt1:IsA("TextButton") and opt1 or opt1:FindFirstChildOfClass("TextButton") or opt1.Parent
        if btn and btn:IsA("GuiObject") then return clickGuiButton(btn) end
    end
    for _, v in pairs(dialogue:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
            local txt = v:IsA("TextButton") and string.lower(v.Text) or ""
            if not string.find(txt, "bỏ qua") and not string.find(txt, "cancel") and not string.find(txt, "leave") then
                return clickGuiButton(v)
            end
        end
    end
    return false
end

local function talkToNPCSequence()
    pcall(function()
        clickRedSafeSpot()
        task.wait(0.3)
        clickDialogueOption1()
        task.wait(0.2)
        autoClickDialogue()
    end)
end

local function clickGachaBuyByCoordinates()
    local camera = workspace.CurrentCamera
    if camera then
        local viewportSize = camera.ViewportSize
        VirtualInputManager:SendMouseButtonEvent(viewportSize.X * 0.73, viewportSize.Y * 0.765, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(viewportSize.X * 0.73, viewportSize.Y * 0.765, 0, false, game, 0)
        return true
    end
    return false
end

local function clickCloseButton()
    local camera = workspace.CurrentCamera
    if camera then
        local viewportSize = camera.ViewportSize
        VirtualInputManager:SendMouseButtonEvent(viewportSize.X * 0.50, viewportSize.Y * 0.91, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(viewportSize.X * 0.50, viewportSize.Y * 0.91, 0, false, game, 0)
        return true
    end
    return false
end

local function autoStoreFruit()
    pcall(function()
        if not CommF then return end
        updateTracker("📦 Cất Trái Ác Quỷ...")
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:UnequipTools() end
        task.wait(0.5)

        local fruits = {}
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (string.find(tool.Name, "Fruit") or string.find(tool.Name, "Trái") or tool:FindFirstChild("Fruit")) then
                    table.insert(fruits, tool)
                end
            end
        end
        if character then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (string.find(tool.Name, "Fruit") or string.find(tool.Name, "Trái") or tool:FindFirstChild("Fruit")) then
                    table.insert(fruits, tool)
                end
            end
        end

        for _, tool in pairs(fruits) do
            local fullName = tool.Name
            local cleanName = fullName:gsub(" Fruit", ""):gsub("Trái ", "")
            local success = CommF:InvokeServer("StoreFruit", fullName, tool)
            if not success then success = CommF:InvokeServer("StoreFruit", cleanName, tool) end
            if not success then CommF:InvokeServer("StoreFruit", cleanName .. "-" .. cleanName, tool) end
        end

        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui and playerGui:FindFirstChild("Main") then
            if playerGui.Main:FindFirstChild("FruitDialog") then playerGui.Main.FruitDialog.Visible = false end
            if playerGui.Main:FindFirstChild("Dialog") then playerGui.Main.Dialog.Visible = false end
        end
    end)
end

------------------------------------------------------------------
-- LUỒNG THỰC THI GACHA CẤP TRÁI ÁC QUỶ
------------------------------------------------------------------
local function runGachaFruit()
    isDoingGacha = true
    restoreCharacterControl()

    updateTracker("🍇 Bay tới NPC Random Trái...")
    local startTime = tick()

    while not getDialogue() do
        if tick() - startTime > 25 then
            isDoingGacha = false
            return
        end

        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")

        if hrp then hrp.CFrame = CFrame.new(gachaTargetPos) end

        pcall(function()
            if CommF then CommF:InvokeServer("Cousin", "Buy") end
        end)

        clickRedSafeSpot()
        task.wait(0.2)
    end

    updateTracker("🎰 Giao dịch Gacha...")
    task.wait(1.5)

    if getDialogue() then clickDialogueOption1() task.wait(2.2) end
    if getDialogue() then clickDialogueOption1() task.wait(2.2) end

    for i = 1, 3 do
        clickGachaBuyByCoordinates()
        task.wait(0.2)
    end

    task.wait(1.5)

    for i = 1, 2 do
        clickCloseButton()
        task.wait(0.2)
    end

    task.wait(1.5)
    autoStoreFruit()
    
    isDoingGacha = false
    forceUnsit()
end

------------------------------------------------------------------
-- HÀM COMBAT AN TOÀN CHỐNG KICK OUT GAME
------------------------------------------------------------------
local function autoBuso()
    pcall(function()
        local character = player.Character
        if character and not character:FindFirstChild("HasBuso") then
            CommF:InvokeServer("Buso")
        end
    end)
end

local function equipWeapon()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if character and backpack and not character:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword" or item.ToolTip == "Blox Fruit") then
                character.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

-- TỐI ƯU NHỊP ĐÁNH (DELAY 0.18S + BẬT VA CHẠM THỰC THẾ)
local function attackAboveHead(mobHrp)
    pcall(function()
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = character.HumanoidRootPart
        local mob = mobHrp and mobHrp.Parent
        local mobHum = mob and mob:FindFirstChild("Humanoid")

        if not mob or not mobHum or mobHum.Health <= 0 then return end

        ensureHoverBodyVelocity()
        setNoclip(true)

        local targetPos = mobHrp.CFrame * CFrame.new(0, 20, 0)
        if (hrp.Position - targetPos.Position).Magnitude > 3 then
            hrp.CFrame = targetPos
        end
        
        equipWeapon()

        if tick() - lastAttackTime >= 0.40 then
            lastAttackTime = tick()
            if RegisterAttack then RegisterAttack:FireServer(0) end
            if RegisterHit then RegisterHit:FireServer(mobHrp, {mobHum}) end
        end
    end)
end

local function getToolMastery(toolName, altName)
    local tool = (player.Backpack and (player.Backpack:FindFirstChild(toolName) or player.Backpack:FindFirstChild(altName or "")))
              or (player.Character and (player.Character:FindFirstChild(toolName) or player.Character:FindFirstChild(altName or "")))
    if tool then
        local levelObj = tool:FindFirstChild("Level") or tool:FindFirstChild("Mastery")
        if levelObj then return levelObj.Value end
    end
    return 0
end

local function getEquippedMeleeInfo()
    for _, melee in ipairs(MeleeList) do
        local inBp = player.Backpack and (player.Backpack:FindFirstChild(melee.Name) or player.Backpack:FindFirstChild(melee.AltName))
        local inChar = player.Character and (player.Character:FindFirstChild(melee.Name) or player.Character:FindFirstChild(melee.AltName))
        if inBp or inChar then
            local mas = getToolMastery(melee.Name, melee.AltName)
            return melee.Name, mas
        end
    end
    return "Võ cơ bản", 0
end

local function hasTool(toolName, altName)
    local inBackpack = player.Backpack and (player.Backpack:FindFirstChild(toolName) or player.Backpack:FindFirstChild(altName or ""))
    local inCharacter = player.Character and (player.Character:FindFirstChild(toolName) or player.Character:FindFirstChild(altName or ""))
    return (inBackpack ~= nil) or (inCharacter ~= nil)
end

------------------------------------------------------------------
-- QUẢN LÝ TỰ ĐỘNG MUA & FARM MELEE
------------------------------------------------------------------
local function autoManageMelee()
    pcall(function()
        local myLevel = player.Data.Level.Value
        local myMoney = (player:FindFirstChild("Data") and player.Data:FindFirstChild("Beli") and player.Data.Beli.Value) or 0
        if not CommF then return end

        -- 1. Tìm võ cao nhất đã sở hữu
        local highestOwnedIndex = 0
        for i, melee in ipairs(MeleeList) do
            if hasTool(melee.Name, melee.AltName) then
                highestOwnedIndex = i
            end
        end

        -- 2. Kiểm tra xem có thể mua võ cấp cao hơn không (Ưu tiên mua võ mới)
        for i = highestOwnedIndex + 1, #MeleeList do
            local melee = MeleeList[i]
            if myLevel >= melee.MinLevel and myMoney >= melee.Price and not failedBuyList[melee.Name] then
                currentMeleeTarget = melee
                updateTracker("🥊 Đang di chuyển mua võ mới: " .. melee.Name)
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local hrp = character.HumanoidRootPart
                    if (hrp.Position - melee.CFrame.Position).Magnitude > 15 then
                        flyLinearTo(melee.CFrame, FLY_SPEED_LONG)
                    end
                    CommF:InvokeServer(melee.RemoteName)
                    task.wait(0.5)

                    if not hasTool(melee.Name, melee.AltName) then
                        failedBuyList[melee.Name] = true
                    else
                        updateTracker("✅ Đã mua thành công: " .. melee.Name)
                    end
                    return
                end
            end
        end

        -- 3. Nếu không mua được võ mới, chọn võ cao nhất đang có để cày thông thạo (Mastery)
        for i = #MeleeList, 1, -1 do
            local melee = MeleeList[i]
            if hasTool(melee.Name, melee.AltName) then
                local currentMas = getToolMastery(melee.Name, melee.AltName)
                if currentMas < TARGET_MASTERY then
                    currentMeleeTarget = melee
                    return
                end
            end
        end
    end)
end

local function autoAddStats()
    if tick() - lastStatUpdate < 2 then return end
    lastStatUpdate = tick()
    pcall(function()
        local points = player.Data.Points.Value
        if points > 0 and CommF then
            CommF:InvokeServer("AddPoint", "Melee", 2)
            CommF:InvokeServer("AddPoint", "Defense", 1)
        end
    end)
end

local function hasAllMeleesMaxed()
    for _, melee in ipairs(MeleeList) do
        if not hasTool(melee.Name, melee.AltName) then return false end
        if getToolMastery(melee.Name, melee.AltName) < TARGET_MASTERY then return false end
    end
    return true
end

------------------------------------------------------------------
-- HÀM SABER QUEST (HOÀN CHỈNH TẤT CẢ CÁC BƯỚC - AUTO RETRY 3 LẦN & TỰ ĐỘNG BƯỚC TIẾP)
------------------------------------------------------------------
local saberQuestStep = "BUTTONS"
local currentButtonIndex = 1
local lastSaberStep = ""
local saberStepAttempts = 0

-- THÔNG BÁO TRÊN MÀN HÌNH PHIÊN BẢN MỚI
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🚀 BLOX FRUITS AUTO v1.2.7",
        Text = "Đã bật chế độ Auto Retry 3x & Tự động vượt qua bước!",
        Duration = 7
    })
end)

local SABER_BUTTONS = {
    Vector3.new(-1263, 12, 310),      -- Điểm 1
    Vector3.new(-1283, 34, 301),      -- Điểm 2
    Vector3.new(-1318, 35, 285),      -- Điểm 3
    Vector3.new(-1371, 35, 260),      -- Điểm 4
    Vector3.new(-1438, 36, 229),      -- Điểm 5
    Vector3.new(-1499, 36, 201),      -- Điểm 6
    Vector3.new(-1559, 37, 173),      -- Điểm 7
    Vector3.new(-1613, 37, 149),      -- Điểm 8
    Vector3.new(-1181, 21, 188),      -- Điểm 9  [NÚT 1]
    Vector3.new(-1389, 29, 169),      -- Điểm 10 [NÚT 2]
    Vector3.new(-1648, 21, 438),      -- Điểm 11 [NÚT 3]
    Vector3.new(-1324, 31, -461),     -- Điểm 12 [NÚT 4]
    Vector3.new(-1389, 29, 169),      -- Điểm 13
    Vector3.new(-1152, -1, -701),     -- Điểm 14 [NÚT 5]
    Vector3.new(-1389, 29, 169),      -- Điểm 15
    Vector3.new(-1497, 20, 167),      -- Điểm 16
    Vector3.new(-1581, 14, 165),      -- Điểm 17
    Vector3.new(-1421.8, 48.3, 22.4)  -- Điểm 18 [NÚT BỔ SUNG]
}

local BUTTON_INDICES = {
    [9] = true, [10] = true, [11] = true, [12] = true, [14] = true, [18] = true 
}

local ownsSaberCache = false
local function checkOwnsSaber()
    if ownsSaberCache then return true end
    -- Check in backpack/character
    if hasTool("Saber", "Saber") then
        ownsSaberCache = true
        return true
    end
    -- Check in stored inventory
    pcall(function()
        local inv = CommF:InvokeServer("getInventoryWeapons")
        if type(inv) == "table" then
            for _, item in pairs(inv) do
                if (type(item) == "table" and item.Name == "Saber") or (type(item) == "string" and item == "Saber") then
                    ownsSaberCache = true
                    break
                end
            end
        end
    end)
    -- Nếu level >= 1500 mà ở Sea 1 thì chắc chắn đã hoàn thành
    if player.Data.Level.Value >= 1500 then
        ownsSaberCache = true
    end
    
    return ownsSaberCache
end

local function equipToolByName(toolName, altName)
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    if not char or not char:FindFirstChild("Humanoid") then return false end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name == toolName or (altName and tool.Name == altName)) then
            return true
        end
    end

    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == toolName or (altName and tool.Name == altName)) then
                char.Humanoid:EquipTool(tool)
                return true
            end
        end
    end
    return false
end

local function flyAcrossSeaSafe(targetPos, speed)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local dist = (hrp.Position - targetPos).Magnitude
    if dist > 350 then
        local highStart = Vector3.new(hrp.Position.X, 150, hrp.Position.Z)
        local highTarget = Vector3.new(targetPos.X, 150, targetPos.Z)
        flyLinearTo(CFrame.new(highStart), 90)
        flyLinearTo(CFrame.new(highTarget), speed or FLY_SPEED_LONG)
    end
    flyLinearTo(CFrame.new(targetPos), speed or FLY_SPEED_LONG)
end

local function getMobLeader()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    for _, mob in ipairs(enemies:GetChildren()) do
        if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local name = string.lower(mob.Name)
            if string.find(name, "mob leader") or string.find(name, "mob") then
                return mob
            end
        end
    end
    return nil
end

local function getSaberExpert()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    for _, mob in ipairs(enemies:GetChildren()) do
        if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local name = string.lower(mob.Name)
            if string.find(name, "saber expert") or string.find(name, "shanks") or string.find(name, "saber") then
                return mob
            end
        end
    end
    return nil
end

local function doSaberQuest()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    -- Kiểm tra nếu đã hoàn thành nhận kiếm
    if checkOwnsSaber() then return end

    -- Đếm số lần thực hiện cùng 1 bước, nếu quá 3 lần tự động ép qua bước tiếp theo
    if lastSaberStep == saberQuestStep then
        saberStepAttempts = saberStepAttempts + 1
    else
        lastSaberStep = saberQuestStep
        saberStepAttempts = 1
    end

    if saberStepAttempts >= 3 then
        updateTracker("⚠️ Thử 3 lần không đổi trạng thái -> Tự động ép qua bước kế tiếp!")
        saberStepAttempts = 0
        if saberQuestStep == "BUTTONS" then saberQuestStep = "TORCH"
        elseif saberQuestStep == "TORCH" then saberQuestStep = "DESERT_BURN"
        elseif saberQuestStep == "DESERT_BURN" then saberQuestStep = "GET_CUP"
        elseif saberQuestStep == "GET_CUP" then saberQuestStep = "FROZEN_WATER"
        elseif saberQuestStep == "FROZEN_WATER" then saberQuestStep = "SICK_MAN"
        elseif saberQuestStep == "SICK_MAN" then saberQuestStep = "RICH_MAN_1"
        elseif saberQuestStep == "RICH_MAN_1" then saberQuestStep = "KILL_MOB_LEADER"
        elseif saberQuestStep == "KILL_MOB_LEADER" then saberQuestStep = "RICH_MAN_2"
        elseif saberQuestStep == "RICH_MAN_2" then saberQuestStep = "OPEN_SABER_DOOR"
        elseif saberQuestStep == "OPEN_SABER_DOOR" then saberQuestStep = "KILL_SABER_EXPERT"
        end
        return
    end

    -- Tự động nhảy bước thông minh nếu đã sở hữu vật phẩm từ trước
    if hasTool("Relic", "Relic") and saberQuestStep ~= "KILL_SABER_EXPERT" then
        saberQuestStep = "OPEN_SABER_DOOR"
    elseif (hasTool("Water Cup", "Cup (Water)") or hasTool("Filled Cup", "Water Cup")) and (saberQuestStep == "BUTTONS" or saberQuestStep == "TORCH" or saberQuestStep == "DESERT_BURN" or saberQuestStep == "GET_CUP" or saberQuestStep == "FROZEN_WATER") then
        saberQuestStep = "SICK_MAN"
    elseif hasTool("Cup", "Cup") and (saberQuestStep == "BUTTONS" or saberQuestStep == "TORCH" or saberQuestStep == "DESERT_BURN" or saberQuestStep == "GET_CUP") then
        saberQuestStep = "FROZEN_WATER"
    elseif hasTool("Torch", "Torch") and (saberQuestStep == "BUTTONS" or saberQuestStep == "TORCH") then
        saberQuestStep = "DESERT_BURN"
    end

    -- BƯỚC 1: BẤM NÚT & LẤY ĐUỐC (RỪNG)
    if saberQuestStep == "BUTTONS" then
        if currentButtonIndex <= #SABER_BUTTONS then
            local targetPos = SABER_BUTTONS[currentButtonIndex]
            updateTracker(string.format("🟢 Saber B1: Bấm nút rừng (%d/18)", currentButtonIndex))
            local dist = (hrp.Position - targetPos).Magnitude
            if dist > 5 then
                flyLinearTo(CFrame.new(targetPos), FLY_SPEED_LONG)
            else
                hrp.CFrame = CFrame.new(targetPos)
                if BUTTON_INDICES[currentButtonIndex] then
                    updateTracker(string.format("🔴 ĐANG BẤM NÚT (%d) - Chờ 3s...", currentButtonIndex))
                    task.wait(3)
                else
                    task.wait(0.2)
                end
                currentButtonIndex = currentButtonIndex + 1
            end
        else
            saberQuestStep = "TORCH"
        end

    elseif saberQuestStep == "TORCH" then
        if hasTool("Torch", "Torch") then
            saberQuestStep = "DESERT_BURN"
        else
            updateTracker("🔥 Saber B1: Xuống hầm Rừng nhặt Đuốc (Torch)...")
            local SAFE_GROUND = Vector3.new(-1612, 35, 163)
            local HOLE_ENTRANCE = Vector3.new(-1612, 12, 163)
            
            local dist = (hrp.Position - HOLE_ENTRANCE).Magnitude
            if dist > 15 then
                flyLinearTo(CFrame.new(HOLE_ENTRANCE), FLY_SPEED_LONG)
            else
                local torchPart = nil
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v.Name == "Torch" and (v:IsA("BasePart") or v:IsA("Model")) then
                        torchPart = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                        break
                    end
                end
                
                local torchTarget = torchPart and torchPart.Position or Vector3.new(-1610, -4, 145)
                local distTorch = (hrp.Position - torchTarget).Magnitude
                if distTorch > 5 then
                    flyLinearTo(CFrame.new(torchTarget), 40)
                else
                    if torchPart and firetouchinterest then
                        firetouchinterest(hrp, torchPart, 0)
                        task.wait(0.2)
                        firetouchinterest(hrp, torchPart, 1)
                    end
                    task.wait(1)
                    flyLinearTo(CFrame.new(SAFE_GROUND), 90)
                    if hasTool("Torch", "Torch") then
                        saberQuestStep = "DESERT_BURN"
                    end
                end
            end
        end

    -- BƯỚC 2: SA MẠC - ĐỐT CỬA GỖ & LẤY CỐC (CUP)
    elseif saberQuestStep == "DESERT_BURN" then
        if hasTool("Cup", "Cup") or hasTool("Water Cup", "Cup (Water)") or hasTool("Relic", "Relic") then
            saberQuestStep = "FROZEN_WATER"
            return
        end

        updateTracker("🌊 Saber B2: Đang bay qua biển sang Sa Mạc...")
        equipToolByName("Torch")

        local HOUSE_DOOR = Vector3.new(1113, 5, 4350)
        local dist = (hrp.Position - HOUSE_DOOR).Magnitude
        if dist > 15 then
            flyAcrossSeaSafe(HOUSE_DOOR, FLY_SPEED_LONG)
        else
            hrp.CFrame = CFrame.new(HOUSE_DOOR)
            equipToolByName("Torch")
            updateTracker("🔥 Đang áp Đuốc đốt cháy cửa gỗ nhà Sa Mạc (3.5s)...")
            task.wait(3.5)
            saberQuestStep = "GET_CUP"
        end

    elseif saberQuestStep == "GET_CUP" then
        if hasTool("Cup", "Cup") or hasTool("Water Cup", "Cup (Water)") then
            saberQuestStep = "FROZEN_WATER"
            return
        end

        updateTracker("🏺 Saber B2: Vào nhà nhặt Cái Cốc (Cup)...")
        local CUP_POS = Vector3.new(1115, 4, 4350)
        local cupPart = nil
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "Cup" and (v:IsA("BasePart") or v:IsA("Model")) then
                cupPart = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                break
            end
        end

        local targetCup = cupPart and cupPart.Position or CUP_POS
        local dist = (hrp.Position - targetCup).Magnitude
        if dist > 5 then
            flyLinearTo(CFrame.new(targetCup), 30)
        else
            if cupPart and firetouchinterest then
                firetouchinterest(hrp, cupPart, 0)
                task.wait(0.2)
                firetouchinterest(hrp, cupPart, 1)
            end
            task.wait(1.5)
            flyLinearTo(CFrame.new(1094, 25, 4192), 80)
            if hasTool("Cup", "Cup") or hasTool("Water Cup", "Cup (Water)") then
                saberQuestStep = "FROZEN_WATER"
            end
        end

    -- BƯỚC 3: ĐẢO BĂNG TUYẾT - LẤY NƯỚC & ĐƯA NGƯỜI ỐM
    elseif saberQuestStep == "FROZEN_WATER" then
        if hasTool("Water Cup", "Cup (Water)") or hasTool("Relic", "Relic") then
            saberQuestStep = "SICK_MAN"
            return
        end

        updateTracker("💧 Saber B3: Bay sang Đảo Tuyết hứng nước vào Cốc...")
        equipToolByName("Cup")

        local CAVE_WATER = Vector3.new(1394, 38, -1322)
        local dist = (hrp.Position - CAVE_WATER).Magnitude
        if dist > 15 then
            flyAcrossSeaSafe(CAVE_WATER, FLY_SPEED_LONG)
        else
            hrp.CFrame = CFrame.new(CAVE_WATER)
            equipToolByName("Cup")
            updateTracker("💧 Đang hứng nước từ thạch nhũ băng nhỏ giọt...")
            task.wait(3.5)
            saberQuestStep = "SICK_MAN"
        end

    elseif saberQuestStep == "SICK_MAN" then
        if hasTool("Relic", "Relic") then
            saberQuestStep = "OPEN_SABER_DOOR"
            return
        end

        updateTracker("🍵 Saber B3: Đưa Cốc Nước cho Người Ốm (Sick Man)...")
        equipToolByName("Water Cup", "Cup")

        local SICK_MAN_POS = Vector3.new(1390, 87, -1299)
        local dist = (hrp.Position - SICK_MAN_POS).Magnitude
        if dist > 10 then
            flyLinearTo(CFrame.new(SICK_MAN_POS), FLY_SPEED_LONG)
        else
            hrp.CFrame = CFrame.new(SICK_MAN_POS)
            pcall(function()
                CommF:InvokeServer("HealSickMan")
                CommF:InvokeServer("SickMan")
            end)
            for i = 1, 4 do
                talkToNPCSequence()
                task.wait(0.3)
            end
            task.wait(1)
            saberQuestStep = "RICH_MAN_1"
        end

    -- BƯỚC 4: LÀNG HẢI TẶC - GẶP NGƯỜI GIÀU & DIỆT MOB LEADER
    elseif saberQuestStep == "RICH_MAN_1" then
        if hasTool("Relic", "Relic") then
            saberQuestStep = "OPEN_SABER_DOOR"
            return
        end

        updateTracker("💰 Saber B4: Gặp Người Giàu (Rich Man) tại Làng Hải Tặc...")
        local RICH_MAN_POS = Vector3.new(-2885, 44, 5368)
        local dist = (hrp.Position - RICH_MAN_POS).Magnitude
        if dist > 15 then
            flyAcrossSeaSafe(RICH_MAN_POS, FLY_SPEED_LONG)
        else
            hrp.CFrame = CFrame.new(RICH_MAN_POS)
            pcall(function()
                CommF:InvokeServer("RichMan", 1)
                CommF:InvokeServer("RichMan")
            end)
            for i = 1, 4 do
                talkToNPCSequence()
                task.wait(0.3)
            end
            task.wait(1)
            saberQuestStep = "KILL_MOB_LEADER"
        end

    elseif saberQuestStep == "KILL_MOB_LEADER" then
        if hasTool("Relic", "Relic") then
            saberQuestStep = "OPEN_SABER_DOOR"
            return
        end

        local MOB_ISLAND = Vector3.new(-2935, 2, 5320)
        local mob = getMobLeader()

        if mob and mob:FindFirstChild("HumanoidRootPart") then
            updateTracker("⚔️ Saber B4: Đang tiêu diệt Mob Leader (Lv 120)...")
            local mobHrp = mob.HumanoidRootPart
            local dist = (hrp.Position - mobHrp.Position).Magnitude
            if dist > 25 then
                flyLinearTo(mobHrp.CFrame * CFrame.new(0, 20, 0), FLY_SPEED_LONG)
            else
                attackAboveHead(mobHrp)
            end
        else
            local distToCave = (hrp.Position - MOB_ISLAND).Magnitude
            if distToCave > 15 then
                updateTracker("🏃 Saber B4: Đang bay tới Đảo Thảo Lũ (Hang Mob Leader)...")
                flyAcrossSeaSafe(MOB_ISLAND, FLY_SPEED_LONG)
            else
                updateTracker("⏳ Chờ Mob Leader hồi sinh / đã tiêu diệt...")
                task.wait(1.5)
                saberQuestStep = "RICH_MAN_2"
            end
        end

    elseif saberQuestStep == "RICH_MAN_2" then
        if hasTool("Relic", "Relic") then
            saberQuestStep = "OPEN_SABER_DOOR"
            return
        end

        updateTracker("👑 Saber B4: Nhận Cổ Vật (Relic) từ Rich Man...")
        local RICH_MAN_POS = Vector3.new(-2885, 44, 5368)
        local dist = (hrp.Position - RICH_MAN_POS).Magnitude
        if dist > 15 then
            flyAcrossSeaSafe(RICH_MAN_POS, FLY_SPEED_LONG)
        else
            hrp.CFrame = CFrame.new(RICH_MAN_POS)
            pcall(function()
                CommF:InvokeServer("RichMan", 2)
                CommF:InvokeServer("RichMan")
            end)
            for i = 1, 4 do
                talkToNPCSequence()
                task.wait(0.3)
            end
            task.wait(1)
            if hasTool("Relic", "Relic") then
                saberQuestStep = "OPEN_SABER_DOOR"
            end
        end

    -- BƯỚC 5: RỪNG - MỞ CỬA CỔ VẬT & TIÊU DIỆT BOSS SABER EXPERT (SHANKS)
    elseif saberQuestStep == "OPEN_SABER_DOOR" then
        updateTracker("🚪 Saber B5: Đang bay về Rừng cắm Cổ Vật mở cửa bí mật...")
        local SABER_DOOR = Vector3.new(-1406, 30, 4)
        local dist = (hrp.Position - SABER_DOOR).Magnitude
        if dist > 15 then
            flyAcrossSeaSafe(SABER_DOOR, FLY_SPEED_LONG)
        else
            equipToolByName("Relic")
            hrp.CFrame = CFrame.new(SABER_DOOR)
            task.wait(2)
            saberQuestStep = "KILL_SABER_EXPERT"
        end

    elseif saberQuestStep == "KILL_SABER_EXPERT" then
        local ROOM_POS = Vector3.new(-1450, 30, -50)
        local boss = getSaberExpert()

        if boss and boss:FindFirstChild("HumanoidRootPart") then
            updateTracker("⚔️ Saber B5: Đang tiêu diệt Boss Saber Expert (Shanks Lv 200)!")
            local bossHrp = boss.HumanoidRootPart
            local dist = (hrp.Position - bossHrp.Position).Magnitude
            if dist > 25 then
                flyLinearTo(bossHrp.CFrame * CFrame.new(0, 20, 0), FLY_SPEED_LONG)
            else
                attackAboveHead(bossHrp)
            end
        else
            local distToRoom = (hrp.Position - ROOM_POS).Magnitude
            if distToRoom > 15 then
                updateTracker("🏃 Saber B5: Đang bay vào phòng bí mật Saber...")
                flyLinearTo(CFrame.new(ROOM_POS), FLY_SPEED_LONG)
            else
                updateTracker("⏳ Chờ Boss Saber Expert hồi sinh...")
                task.wait(1.5)
                checkOwnsSaber()
            end
        end
    end
end

------------------------------------------------------------------
-- HÀM SEA 2 QUEST LOGIC
------------------------------------------------------------------
local function isDetectiveFinished()
    local finished = false
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then return end
        for _, v in pairs(playerGui:GetDescendants()) do
            if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Visible and v.Text then
                local text = string.lower(v.Text)
                if string.find(text, "thuyền trưởng") or string.find(text, "captain") or string.find(text, "tân thế giới") or string.find(text, "new world") then
                    finished = true
                    break
                end
            end
        end
    end)
    return finished
end

local function equipKey()
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    if not char or not char:FindFirstChild("Humanoid") then return false end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "key") or string.find(string.lower(tool.Name), "khóa")) then
            return true
        end
    end

    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "key") or string.find(string.lower(tool.Name), "khóa")) then
                char.Humanoid:EquipTool(tool)
                return true
            end
        end
    end
    return false
end

local function getIceAdmiral()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    for _, mob in ipairs(enemies:GetChildren()) do
        if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local name = string.lower(mob.Name)
            local distToCave = (mob.HumanoidRootPart.Position - POS_BOSS_ROOM.Position).Magnitude
            if string.find(name, "ice admiral") or string.find(name, "admiral") or distToCave < 150 then
                return mob
            end
        end
    end
    return nil
end

------------------------------------------------------------------
-- GUI GIAO DIỆN
------------------------------------------------------------------
if CoreGui:FindFirstChild("AutoFarmLeftGui") then CoreGui.AutoFarmLeftGui:Destroy() end
if CoreGui:FindFirstChild("AutoFarmTopGui") then CoreGui.AutoFarmTopGui:Destroy() end

local screenGuiLeft = Instance.new("ScreenGui", CoreGui)
screenGuiLeft.Name = "AutoFarmLeftGui"

local screenGuiTop = Instance.new("ScreenGui", CoreGui)
screenGuiTop.Name = "AutoFarmTopGui"
screenGuiTop.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame", screenGuiLeft)
mainFrame.Size = UDim2.new(0, 260, 0, 50)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Active = true
mainFrame.Draggable = true

local frameCorner = Instance.new("UICorner", mainFrame)
frameCorner.CornerRadius = UDim.new(0, 10)

local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Thickness = 1.5
frameStroke.Color = Color3.fromRGB(0, 230, 150)

local statusDot = Instance.new("Frame", mainFrame)
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 14, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)

local dotCorner = Instance.new("UICorner", statusDot)
dotCorner.CornerRadius = UDim.new(1, 0)

local titleText = Instance.new("TextLabel", mainFrame)
titleText.Size = UDim2.new(0, 210, 0, 20)
titleText.Position = UDim2.new(0, 32, 0, 8)
titleText.BackgroundTransparency = 1
titleText.Text = "AUTO FARM & TRANSITION SEA 2"
titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
titleText.TextSize = 11
titleText.Font = Enum.Font.GothamBold

local subText = Instance.new("TextLabel", mainFrame)
subText.Size = UDim2.new(0, 210, 0, 14)
subText.Position = UDim2.new(0, 32, 0, 26)
subText.BackgroundTransparency = 1
subText.Text = "Status: RUNNING [K]"
subText.TextColor3 = Color3.fromRGB(0, 230, 115)
subText.TextSize = 10
subText.Font = Enum.Font.GothamMedium

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""

local trackerFrame = Instance.new("Frame", screenGuiTop)
trackerFrame.Size = UDim2.new(0, 420, 0, 28)
trackerFrame.Position = UDim2.new(0.5, -210, 0, 2)
trackerFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
trackerFrame.BackgroundTransparency = 0.2

local trackerCorner = Instance.new("UICorner", trackerFrame)
trackerCorner.CornerRadius = UDim.new(0, 6)

local trackerStroke = Instance.new("UIStroke", trackerFrame)
trackerStroke.Thickness = 1
trackerStroke.Color = Color3.fromRGB(0, 230, 150)

trackerText = Instance.new("TextLabel", trackerFrame)
trackerText.Size = UDim2.new(1, 0, 1, 0)
trackerText.BackgroundTransparency = 1
trackerText.Text = "🎯 Anti-Kick Active | Chống Disconnect Safe Mode"
trackerText.TextColor3 = Color3.fromRGB(255, 255, 255)
trackerText.TextSize = 11
trackerText.Font = Enum.Font.GothamBold

toggleBtn.MouseButton1Click:Connect(function()
    isScriptEnabled = not isScriptEnabled
    if not isScriptEnabled then 
        restoreCharacterControl()
        updateTracker("⏸️ Script đang tạm dừng")
    end
end)

UserInputService.InputBegan:Connect(function(input, gP)
    if not gP and input.KeyCode == Enum.KeyCode.K then
        isScriptEnabled = not isScriptEnabled
        if not isScriptEnabled then 
            restoreCharacterControl()
            updateTracker("⏸️ Script đang tạm dừng")
        end
    end
end)

------------------------------------------------------------------
-- VÒNG LẶP CHÍNH AUTO FARM
------------------------------------------------------------------
local function getCurrentQuestData()
    local myLevel = player.Data.Level.Value
    local selectedQuest = QuestStages[1]
    for i = #QuestStages, 1, -1 do
        if myLevel >= QuestStages[i].Level then
            selectedQuest = QuestStages[i]
            break
        end
    end
    return selectedQuest
end

local function getClosestMob(mobName)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = 2000
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, mobName) then
                local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChild("Humanoid")
                if mobHrp and mobHum and mobHum.Health > 0 then
                    local dist = (hrp.Position - mobHrp.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestMob = mob
                    end
                end
            end
        end
    end
    return closestMob
end

task.spawn(function()
    while task.wait(0.02) do
        if isScriptEnabled and not isTweening and not isDoingGacha and not isCheckingInitialGacha then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                local hrp = character.HumanoidRootPart
                local myLevel = player.Data.Level.Value
                local playerGui = player:WaitForChild("PlayerGui")
                local questFrame = playerGui.Main.Quest

                autoBuso()
                autoAddStats()

                local meleeName, meleeMas = getEquippedMeleeInfo()

                if questFrame.Visible then
                    if not activeQuest then
                        activeQuest = getCurrentQuestData()
                    end

                    forceUnsit()
                    autoManageMelee()

                    subText.Text = string.format("Quest: %s | Lv: %d", activeQuest.MobName, myLevel)

                    local targetMob = getClosestMob(activeQuest.MobName)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        updateTracker(string.format("⚡ Fast Attack (Safe): %s | Võ: %s (%d/%d)", activeQuest.MobName, meleeName, meleeMas, TARGET_MASTERY))
                        local mobHrp = targetMob.HumanoidRootPart
                        local distToMob = (hrp.Position - mobHrp.Position).Magnitude
                        
                        if distToMob > 25 then
                            flyLinearTo(mobHrp.CFrame * CFrame.new(0, 20, 0), FLY_SPEED_SHORT)
                        else
                            attackAboveHead(mobHrp)
                        end
                    else
                        updateTracker(string.format("🏃 Tìm quái: %s | Võ: %s (%d/%d)", activeQuest.MobName, meleeName, meleeMas, TARGET_MASTERY))
                        if (hrp.Position - activeQuest.MobCFrame.Position).Magnitude > 20 then
                            flyLinearTo(activeQuest.MobCFrame, FLY_SPEED_SHORT)
                        end
                    end

                else
                    activeQuest = nil 

                    if myLevel < 200 then
                        forceUnsit()
                        autoManageMelee()

                        local qData = getCurrentQuestData()
                        activeQuest = qData
                        subText.Text = string.format("Mob: %s | Lv: %d", qData.MobName, myLevel)

                        local distToNpc = (hrp.Position - qData.NpcCFrame.Position).Magnitude
                        if distToNpc > 15 then
                            updateTracker(string.format("📜 Bay nhận Quest: %s (Lv %d)", qData.MobName, qData.Level))
                            flyLinearTo(qData.NpcCFrame, FLY_SPEED_LONG)
                        end
                        if isScriptEnabled and not isDoingGacha then
                            CommF:InvokeServer("StartQuest", qData.QuestName, qData.QuestLevel)
                            task.wait(0.5)
                        end

                    elseif not checkOwnsSaber() then
                        subText.Text = "🚀 Đang làm nhiệm vụ Saber..."
                        doSaberQuest()

                    elseif myLevel < 700 then
                        forceUnsit()
                        autoManageMelee()

                        local qData = getCurrentQuestData()
                        activeQuest = qData
                        subText.Text = string.format("Mob: %s | Lv: %d", qData.MobName, myLevel)

                        local distToNpc = (hrp.Position - qData.NpcCFrame.Position).Magnitude
                        if distToNpc > 15 then
                            updateTracker(string.format("📜 Bay nhận Quest: %s (Lv %d)", qData.MobName, qData.Level))
                            flyLinearTo(qData.NpcCFrame, FLY_SPEED_LONG)
                        end
                        if isScriptEnabled and not isDoingGacha then
                            CommF:InvokeServer("StartQuest", qData.QuestName, qData.QuestLevel)
                            task.wait(0.5)
                        end
                    else
                        subText.Text = "🚀 Đang làm nhiệm vụ sang Sea 2..."

                        if questStep == "GET_KEY" then
                            if equipKey() then
                                questStep = "UNLOCK_DOOR"
                            else
                                updateTracker("🔑 Đang bay tới Thám Tử để lấy Chìa Khóa Sea 2")
                                local dist = (hrp.Position - POS_DETECTIVE.Position).Magnitude
                                if dist > 8 then
                                    flyLinearTo(POS_DETECTIVE, FLY_SPEED_LONG)
                                else
                                    hrp.CFrame = POS_DETECTIVE
                                    CommF:InvokeServer("TalkMilitaryDetective")
                                    for i = 1, 10 do
                                        if isDetectiveFinished() then
                                            questStep = "GOTO_SEA2"
                                            break
                                        end
                                        talkToNPCSequence()
                                        task.wait(0.3)
                                        if equipKey() then
                                            questStep = "UNLOCK_DOOR"
                                            break
                                        end
                                    end
                                end
                            end

                        elseif questStep == "UNLOCK_DOOR" then
                            if equipKey() then
                                updateTracker("🔓 Đang bay tới Mở Cửa Băng bằng Chìa Khóa")
                                local dist = (hrp.Position - POS_ICE_DOOR.Position).Magnitude
                                if dist > 5 then
                                    flyLinearTo(POS_ICE_DOOR, FLY_SPEED_LONG)
                                else
                                    hrp.CFrame = POS_ICE_DOOR
                                    task.wait(1.5)
                                end
                            else
                                questStep = "KILL_BOSS"
                            end

                        elseif questStep == "KILL_BOSS" then
                            local boss = getIceAdmiral()
                            if boss and boss:FindFirstChild("HumanoidRootPart") then
                                updateTracker("⚔️ Đang tiêu diệt Ice Admiral")
                                local mobHrp = boss.HumanoidRootPart
                                local distToMob = (hrp.Position - mobHrp.Position).Magnitude

                                if distToMob > 25 then
                                    flyLinearTo(mobHrp.CFrame * CFrame.new(0, 20, 0), FLY_SPEED_LONG)
                                else
                                    attackAboveHead(mobHrp)
                                end
                            else
                                updateTracker("🏃 Đang di chuyển vào hang Boss Ice Admiral")
                                local distToRoom = (hrp.Position - POS_BOSS_ROOM.Position).Magnitude
                                if distToRoom > 10 then
                                    flyLinearTo(POS_BOSS_ROOM, FLY_SPEED_LONG)
                                else
                                    task.wait(1)
                                    if not getIceAdmiral() then
                                        questStep = "TALK_DETECTIVE_2"
                                    end
                                end
                            end

                        elseif questStep == "TALK_DETECTIVE_2" then
                            updateTracker("🗣️ Đang báo cáo Thám Tử & kích hoạt chuyển Sea")
                            local dist = (hrp.Position - POS_DETECTIVE.Position).Magnitude
                            if dist > 8 then
                                flyLinearTo(POS_DETECTIVE, FLY_SPEED_LONG)
                            else
                                hrp.CFrame = POS_DETECTIVE
                                CommF:InvokeServer("TalkMilitaryDetective")
                                for i = 1, 6 do
                                    if isDetectiveFinished() then
                                        questStep = "GOTO_SEA2"
                                        break
                                    end
                                    talkToNPCSequence()
                                    task.wait(0.3)
                                end
                                
                                if questStep ~= "GOTO_SEA2" then
                                    CommF:InvokeServer("TravelDressrosa")
                                    task.wait(1)
                                    questStep = "GOTO_SEA2"
                                end
                            end

                        elseif questStep == "GOTO_SEA2" then
                            updateTracker("⛵ Dự phòng chuyển Sea qua Thuyền Trưởng Middle Town")
                            local dist = (hrp.Position - POS_CAPTAIN.Position).Magnitude
                            if dist > 10 then
                                flyLinearTo(POS_CAPTAIN, FLY_SPEED_LONG)
                            else
                                hrp.CFrame = POS_CAPTAIN
                                CommF:InvokeServer("TravelDressrosa")
                                for i = 1, 6 do
                                    talkToNPCSequence()
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

------------------------------------------------------------------
-- LUỒNG THỜI GIAN LẶP GACHA THEO THỜI GIAN THỰC (LƯU FILE)
------------------------------------------------------------------
local fileName = "BloxFruits_Gacha_" .. player.Name .. ".txt"

local function getLastGachaTime()
    if isfile and readfile and isfile(fileName) then
        local success, result = pcall(function()
            return tonumber(readfile(fileName))
        end)
        if success and result then return result end
    end
    return 0
end

local function saveGachaTime()
    if writefile then
        pcall(function()
            writefile(fileName, tostring(os.time()))
        end)
    end
end

task.spawn(function()
    -- KIỂM TRA GACHA LẦN ĐẦU KHI MỚI VÀO GAME
    pcall(function()
        updateTracker("⏳ Đang chờ load dữ liệu game...")
        local data = player:WaitForChild("Data", 15)
        if data then 
            data:WaitForChild("Level", 15) 
            local currentLevel = data.Level.Value
            if currentLevel >= 50 then
                local lastGachaTime = getLastGachaTime()
                if (os.time() - lastGachaTime) >= 7210 then
                    updateTracker("🎰 Load game xong, ưu tiên Random Trái trước!")
                    runGachaFruit()
                    saveGachaTime()
                end
            end
        end
    end)
    
    -- Mở khóa cho Auto Farm hoạt động sau khi kiểm tra xong Gacha
    isCheckingInitialGacha = false
    
    -- BẮT ĐẦU VÒNG LẶP KIỂM TRA GACHA ĐỊNH KỲ
    while task.wait(5) do
        pcall(function()
            if not player:FindFirstChild("Data") or not player.Data:FindFirstChild("Level") then return end
            local currentLevel = player.Data.Level.Value

            if currentLevel >= 50 then
                local lastGachaTime = getLastGachaTime()
                local currentTime = os.time()
                local elapsedTime = currentTime - lastGachaTime
                local cooldownSeconds = 7210

                if elapsedTime >= cooldownSeconds then
                    updateTracker("🎰 Đã tới giờ Random Trái (Thời gian thực)!")
                    runGachaFruit()
                    saveGachaTime()
                else
                    local remainingSeconds = cooldownSeconds - elapsedTime
                    local minutes = math.floor(remainingSeconds / 60)
                    local seconds = remainingSeconds % 60
                    
                    updateTracker(string.format("⏳ Cooldown Gacha: còn %d phút %d giây", minutes, seconds))
                end
            end
        end)
    end
end)

elseif currentSea == 2 then
------------------------------------------------------------------
-- BẮT ĐẦU AUTO SEA 2
------------------------------------------------------------------
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

------------------------------------------------------------------
-- CHỐNG AFK & CHỐNG KICK CAO CẤP
------------------------------------------------------------------
pcall(function()
    if getconnections then
        for _, conn in pairs(getconnections(player.Idled)) do
            if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
        end
    end
end)

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
end)

------------------------------------------------------------------
-- NATIVE NOCLIP HỆ THỐNG (TRÁNH BỊ KICK KHI BAY XUYÊN TƯỜNG)
------------------------------------------------------------------
local noclipConnection = nil

local function setNoclip(enabled)
    if enabled then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

------------------------------------------------------------------
-- TÍCH HỢP REMOTE FAST ATTACK
------------------------------------------------------------------
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack") or Net:FindFirstChild("RegisterAttack")
local RegisterHit = Net:FindFirstChild("RE/RegisterHit") or Net:FindFirstChild("RegisterHit")

------------------------------------------------------------------
-- TỐI ƯU HẠ ĐỒ HỌA & HIỆU ỨNG THẤP NHẤT (FPS BOOST)
------------------------------------------------------------------
local function optimizeVisuals()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
                v.Enabled = false
            end
        end

        if Workspace:FindFirstChildOfClass("Terrain") then
            local terrain = Workspace.Terrain
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            if sethiddenproperty then
                pcall(function() sethiddenproperty(terrain, "Decoration", false) end)
            end
        end

        local function cleanItem(v)
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Texture = ""
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Explosion") then
                v.Enabled = false
            elseif v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.TextureID = ""
            end
        end

        for _, v in pairs(Workspace:GetDescendants()) do
            cleanItem(v)
        end

        Workspace.DescendantAdded:Connect(function(v)
            task.spawn(function()
                cleanItem(v)
            end)
        end)
    end)
end

task.spawn(optimizeVisuals)

------------------------------------------------------------------
-- CẤU HÌNH CHỌN PHE (PIRATES / MARINES)
------------------------------------------------------------------
local CHOOSE_TEAM = "Pirates"

local function autoSelectTeam()
    pcall(function()
        if player.Team == nil or player.Team.Name == "Neutral" or player.Team.Name == "" then
            local commF = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 5)
            if commF then
                commF:InvokeServer("SetTeam", CHOOSE_TEAM)
            end
        end
    end)
end

autoSelectTeam()

repeat task.wait(1) 
    autoSelectTeam()
until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

task.wait(5)

------------------------------------------------------------------
-- CẤU HÌNH NHẬN TRÁI (GACHA SEA 2)
------------------------------------------------------------------
local gachaTargetPos = Vector3.new(-422.3, 73.0, 393.7) 
local gachaClickPos  = Vector3.new(-429.9, 67.3, 390.1) 
local isDoingGacha   = false                             

------------------------------------------------------------------
-- CẤU HÌNH AUTO FARM MOB SEA 2
------------------------------------------------------------------
local isScriptEnabled = true
local isTweening = false
local currentTween = nil
local lastStatUpdate = 0
local lastAttackTime = 0

local FLY_SPEED_LONG = 110  
local FLY_SPEED_SHORT = 85  

------------------------------------------------------------------
-- DATABASE: TỔNG HỢP QUEST QUÁI THƯỜNG SEA 2
------------------------------------------------------------------
local Sea2MobQuests = {
    { Level = 700, QuestName = "Area1Quest", QuestLevel = 1, MobName = "Raider", NpcCFrame = CFrame.new(-425, 73, 1837), MobCFrame = CFrame.new(-750, 73, 2400) },
    { Level = 725, QuestName = "Area1Quest", QuestLevel = 2, MobName = "Mercenary", NpcCFrame = CFrame.new(-425, 73, 1837), MobCFrame = CFrame.new(-930, 73, 1400) },
    { Level = 775, QuestName = "Area2Quest", QuestLevel = 1, MobName = "Swan Pirate", NpcCFrame = CFrame.new(635, 73, 918), MobCFrame = CFrame.new(880, 120, 1200) },
    { Level = 800, QuestName = "Area2Quest", QuestLevel = 2, MobName = "Factory Staff", NpcCFrame = CFrame.new(635, 73, 918), MobCFrame = CFrame.new(280, 73, -50) },
    { Level = 950, QuestName = "ZombieQuest", QuestLevel = 1, MobName = "Zombie", NpcCFrame = CFrame.new(-5490, 48, -795), MobCFrame = CFrame.new(-5600, 48, -950) },
    { Level = 975, QuestName = "ZombieQuest", QuestLevel = 2, MobName = "Vampire", NpcCFrame = CFrame.new(-5490, 48, -795), MobCFrame = CFrame.new(-6000, 6, -1300) },
    { Level = 1000, QuestName = "SnowMountainQuest", QuestLevel = 1, MobName = "Snow Trooper", NpcCFrame = CFrame.new(605, 401, -5370), MobCFrame = CFrame.new(500, 401, -5500) },
    { Level = 1050, QuestName = "SnowMountainQuest", QuestLevel = 2, MobName = "Winter Warrior", NpcCFrame = CFrame.new(605, 401, -5370), MobCFrame = CFrame.new(1100, 430, -5200) },
    { Level = 1100, QuestName = "IceSideQuest", QuestLevel = 1, MobName = "Lab Subordinate", NpcCFrame = CFrame.new(-6060, 16, -4900), MobCFrame = CFrame.new(-5850, 16, -4800) },
    { Level = 1150, QuestName = "IceSideQuest", QuestLevel = 2, MobName = "Horned Warrior", NpcCFrame = CFrame.new(-6060, 16, -4900), MobCFrame = CFrame.new(-6400, 16, -5800) },
    { Level = 1175, QuestName = "FireSideQuest", QuestLevel = 1, MobName = "Magma Ninja", NpcCFrame = CFrame.new(-5430, 16, -5295), MobCFrame = CFrame.new(-5400, 16, -5800) },
    { Level = 1200, QuestName = "FireSideQuest", QuestLevel = 2, MobName = "Lava Pirate", NpcCFrame = CFrame.new(-5430, 16, -5295), MobCFrame = CFrame.new(-5200, 16, -4800) },
    { Level = 1250, QuestName = "ShipQuest1", QuestLevel = 1, MobName = "Ship Deckhand", NpcCFrame = CFrame.new(1030, 125, 32910), MobCFrame = CFrame.new(1180, 130, 33000) },
    { Level = 1275, QuestName = "ShipQuest1", QuestLevel = 2, MobName = "Ship Engineer", NpcCFrame = CFrame.new(1030, 125, 32910), MobCFrame = CFrame.new(900, 50, 33000) },
    { Level = 1300, QuestName = "ShipQuest2", QuestLevel = 1, MobName = "Ship Steward", NpcCFrame = CFrame.new(968, 125, 33240), MobCFrame = CFrame.new(915, 130, 33400) },
    { Level = 1325, QuestName = "ShipQuest2", QuestLevel = 2, MobName = "Ship Officer", NpcCFrame = CFrame.new(968, 125, 33240), MobCFrame = CFrame.new(915, 180, 33300) },
    { Level = 1350, QuestName = "FrostQuest", QuestLevel = 1, MobName = "Arctic Warrior", NpcCFrame = CFrame.new(5560, 28, -6250), MobCFrame = CFrame.new(6000, 28, -6200) },
    { Level = 1375, QuestName = "FrostQuest", QuestLevel = 2, MobName = "Snow Lurker", NpcCFrame = CFrame.new(5560, 28, -6250), MobCFrame = CFrame.new(5500, 50, -6800) },
    { Level = 1425, QuestName = "ForgottenQuest", QuestLevel = 1, MobName = "Sea Soldier", NpcCFrame = CFrame.new(-3050, 238, -10145), MobCFrame = CFrame.new(-3000, 50, -9600) },
    { Level = 1450, QuestName = "ForgottenQuest", QuestLevel = 2, MobName = "Water Fighter", NpcCFrame = CFrame.new(-3050, 238, -10145), MobCFrame = CFrame.new(-3300, 240, -10500) }
}

------------------------------------------------------------------
-- HÀM BỔ TRỢ DI CHUYỂN & GIỮ CHÂN TRÊN KHÔNG AN TOÀN
------------------------------------------------------------------
local function forceUnsit()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if humanoid.Sit then humanoid.Sit = false end
            if humanoid.PlatformStand then humanoid.PlatformStand = false end
        end
    end
end

local function ensureHoverBodyVelocity()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local bv = hrp:FindFirstChild("AntiFallHover")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "AntiFallHover"
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(9e5, 9e5, 9e5)
            bv.Parent = hrp
        end
    end
end

local function flyLinearTo(targetCFrame, speed)
    if not isScriptEnabled or isDoingGacha then return end
    forceUnsit()
    ensureHoverBodyVelocity()
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    speed = speed or FLY_SPEED_LONG
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    if distance < 4 then
        hrp.CFrame = targetCFrame
        isTweening = false
        setNoclip(false)
        return
    end

    isTweening = true
    setNoclip(true)

    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    currentTween.Completed:Wait()

    setNoclip(false)
    isTweening = false
end

local function restoreCharacterControl()
    local character = player.Character
    if character then
        setNoclip(false)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "AntiFall" or v.Name == "AntiFallHover" then v:Destroy() end
            end
        end
    end
    if currentTween then currentTween:Cancel() currentTween = nil end
    isTweening = false
    forceUnsit()
end

------------------------------------------------------------------
-- HÀM COMBAT FAST ATTACK AN TOÀN
------------------------------------------------------------------
local function autoBuso()
    pcall(function()
        local character = player.Character
        if character and not character:FindFirstChild("HasBuso") then
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("Buso")
            end
        end
    end)
end

task.spawn(function()
    while task.wait(1) do
        autoBuso()
    end
end)

local function equipWeapon()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if character and backpack and not character:FindFirstChildOfClass("Tool") then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword" or item.ToolTip == "Blox Fruit") then
                character.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

local function attackAboveHead(mobHrp)
    pcall(function()
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = character.HumanoidRootPart
        local mob = mobHrp.Parent
        local mobHum = mob and mob:FindFirstChild("Humanoid")

        if not mob or not mobHum or mobHum.Health <= 0 then return end

        ensureHoverBodyVelocity()
        setNoclip(true)

        local targetPos = mobHrp.CFrame * CFrame.new(0, 20, 0)
        if (hrp.Position - targetPos.Position).Magnitude > 3 then
            hrp.CFrame = targetPos
        end
        
        equipWeapon()

        if tick() - lastAttackTime >= 0.40 then
            lastAttackTime = tick()
            if RegisterAttack then RegisterAttack:FireServer(0) end
            if RegisterHit then RegisterHit:FireServer(mobHrp, {mobHum}) end
        end
    end)
end

------------------------------------------------------------------
-- HÀM AUTO STORE FRUIT
------------------------------------------------------------------
local function autoStoreFruit()
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if not commF then return end

        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then humanoid:UnequipTools() end
        task.wait(1)

        local fruits = {}
        local backpack = player:FindFirstChild("Backpack")
        
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (string.find(tool.Name, "Fruit") or string.find(tool.Name, "Trái") or tool:GetAttribute("OriginalName")) then
                    table.insert(fruits, tool)
                end
            end
        end
        
        if character then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (string.find(tool.Name, "Fruit") or string.find(tool.Name, "Trái") or tool:GetAttribute("OriginalName")) then
                    table.insert(fruits, tool)
                end
            end
        end

        for _, tool in pairs(fruits) do
            local storeName = tool:GetAttribute("OriginalName")
            if not storeName then
                local cleanName = tool.Name:gsub(" Fruit", ""):gsub("Trái ", ""):gsub(" ", "")
                storeName = cleanName .. "-" .. cleanName
            end
            
            pcall(function()
                commF:InvokeServer("StoreFruit", storeName, tool)
            end)
        end

        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui and playerGui:FindFirstChild("Main") then
            if playerGui.Main:FindFirstChild("FruitDialog") then playerGui.Main.FruitDialog.Visible = false end
            if playerGui.Main:FindFirstChild("Dialog") then playerGui.Main.Dialog.Visible = false end
        end
    end)
end

------------------------------------------------------------------
-- HÀM GIẢ LẬP CLICK 3D VÀ NÚT MUA GACHA
------------------------------------------------------------------
local function clickWorldPosition(worldPos, times)
    times = times or 1
    local camera = workspace.CurrentCamera
    if not camera then return end

    local screenPos, onScreen = camera:WorldToViewportPoint(worldPos)
    if onScreen then
        for i = 1, times do
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
            task.wait(0.05)
        end
    end
end

local function autoClickGachaUIButton()
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then return end

        for _, v in pairs(playerGui:GetDescendants()) do
            if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                local text = v:IsA("TextButton") and v.Text or ""
                local name = string.lower(v.Name)

                if string.find(text, "%$") or string.find(name, "buy") or string.find(name, "gacha") or string.find(name, "cousin") then
                    if firesignal then
                        firesignal(v.MouseButton1Click)
                        firesignal(v.Activated)
                    end

                    local absPos = v.AbsolutePosition
                    local absSize = v.AbsoluteSize
                    local centerX = absPos.X + (absSize.X / 2)
                    local centerY = absPos.Y + (absSize.Y / 2) + 38 

                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                end
            end
        end
    end)
end

------------------------------------------------------------------
-- HÀM KIỂM TRA QUYẾT ĐỊNH QUEST
------------------------------------------------------------------
local function getQuestDataForActiveQuest()
    local questData = nil
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        local questFrame = playerGui and playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest")
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            if container and container:FindFirstChild("QuestTitle") and container.QuestTitle:FindFirstChild("Title") then
                local titleText = string.lower(container.QuestTitle.Title.Text)
                for _, q in ipairs(Sea2MobQuests) do
                    if string.find(titleText, string.lower(q.MobName)) then
                        questData = q
                        break
                    end
                end
            end
        end
    end)
    return questData
end

local function getCurrentQuestData()
    local activeQuest = getQuestDataForActiveQuest()
    if activeQuest then return activeQuest end

    local myLevel = 700
    pcall(function() myLevel = player.Data.Level.Value end)
    local selectedQuest = Sea2MobQuests[1]
    for i = #Sea2MobQuests, 1, -1 do
        if myLevel >= Sea2MobQuests[i].Level then
            selectedQuest = Sea2MobQuests[i]
            break
        end
    end
    return selectedQuest
end

------------------------------------------------------------------
-- UI GIAO DIỆN SEA 2
------------------------------------------------------------------
if CoreGui:FindFirstChild("AutoFarmLeftGui") then CoreGui.AutoFarmLeftGui:Destroy() end
if CoreGui:FindFirstChild("AutoFarmTopGui") then CoreGui.AutoFarmTopGui:Destroy() end

local screenGuiLeft = Instance.new("ScreenGui", CoreGui)
screenGuiLeft.Name = "AutoFarmLeftGui"

local screenGuiTop = Instance.new("ScreenGui", CoreGui)
screenGuiTop.Name = "AutoFarmTopGui"
screenGuiTop.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame", screenGuiLeft)
mainFrame.Size = UDim2.new(0, 250, 0, 50)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Active = true
mainFrame.Draggable = true

local frameCorner = Instance.new("UICorner", mainFrame)
frameCorner.CornerRadius = UDim.new(0, 10)

local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Thickness = 1.5
frameStroke.Color = Color3.fromRGB(0, 230, 150)

local statusDot = Instance.new("Frame", mainFrame)
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 14, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)

local dotCorner = Instance.new("UICorner", statusDot)
dotCorner.CornerRadius = UDim.new(1, 0)

local titleText = Instance.new("TextLabel", mainFrame)
titleText.Size = UDim2.new(0, 200, 0, 20)
titleText.Position = UDim2.new(0, 32, 0, 8)
titleText.BackgroundTransparency = 1
titleText.Text = "AUTO FARM & GACHA (SEA 2)"
titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
titleText.TextSize = 11
titleText.Font = Enum.Font.GothamBold

local subText = Instance.new("TextLabel", mainFrame)
subText.Size = UDim2.new(0, 200, 0, 14)
subText.Position = UDim2.new(0, 32, 0, 26)
subText.BackgroundTransparency = 1
subText.Text = "Status: RUNNING [Phím K]"
subText.TextColor3 = Color3.fromRGB(0, 230, 115)
subText.TextSize = 10
subText.Font = Enum.Font.GothamMedium

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""

local trackerFrame = Instance.new("Frame", screenGuiTop)
trackerFrame.Size = UDim2.new(0, 420, 0, 28)
trackerFrame.Position = UDim2.new(0.5, -210, 0, 2)
trackerFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
trackerFrame.BackgroundTransparency = 0.2

local trackerCorner = Instance.new("UICorner", trackerFrame)
trackerCorner.CornerRadius = UDim.new(0, 6)

local trackerStroke = Instance.new("UIStroke", trackerFrame)
trackerStroke.Thickness = 1
trackerStroke.Color = Color3.fromRGB(0, 230, 150)

local trackerText = Instance.new("TextLabel", trackerFrame)
trackerText.Size = UDim2.new(1, 0, 1, 0)
trackerText.BackgroundTransparency = 1
trackerText.Text = "🎯 Anti-AFK Active | Fast Attack (Safe)"
trackerText.TextColor3 = Color3.fromRGB(255, 255, 255)
trackerText.TextSize = 11
trackerText.Font = Enum.Font.GothamBold

------------------------------------------------------------------
-- HÀM CẬP NHẬT UI & STATS
------------------------------------------------------------------
local function updateQuestTracker()
    pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        local questFrame = playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest")
        
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            if container and container:FindFirstChild("QuestTitle") then
                local title = container.QuestTitle.Title.Text
                local progress = container:FindFirstChild("QuestProgress") and container.QuestProgress.Text or ""
                trackerText.Text = string.format("🎯 %s (%s)", title, progress)
            else
                trackerText.Text = "🎯 Đang làm nhiệm vụ..."
            end
        else
            trackerText.Text = "❌ Chưa nhận nhiệm vụ"
        end
    end)
end

local function autoAddStats()
    if tick() - lastStatUpdate < 2 then return end
    lastStatUpdate = tick()

    pcall(function()
        local points = player.Data.Points.Value
        if points > 0 then
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("AddPoint", "Melee", 2)
                commF:InvokeServer("AddPoint", "Defense", 1)
            end
        end
    end)
end

local function updateUIState()
    if isDoingGacha then
        frameStroke.Color = Color3.fromRGB(255, 200, 0)
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        subText.Text = "🍇 Đang nhận trái (10s)..."
        subText.TextColor3 = Color3.fromRGB(255, 200, 0)
        trackerText.Text = "🍇 Đang lấy trái ác quỷ..."
        return
    end

    local qData = getCurrentQuestData()
    if isScriptEnabled then
        frameStroke.Color = Color3.fromRGB(0, 230, 150)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 115)
        subText.Text = string.format("Mob: %s | Lv: %d [K]", qData.MobName, qData.Level)
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
    if not isScriptEnabled then restoreCharacterControl() end
end

toggleBtn.MouseButton1Click:Connect(toggleState)
UserInputService.InputBegan:Connect(function(input, gP)
    if not gP and input.KeyCode == Enum.KeyCode.K then toggleState() end
end)

local function startQuest(qName, qLevel)
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("StartQuest", qName, qLevel) end
    end)
end

local function getClosestMob(mobName)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local closestMob = nil
    local shortestDistance = 2000

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if string.find(mob.Name, mobName) then
                local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChild("Humanoid")
                if mobHrp and mobHum and mobHum.Health > 0 then
                    local dist = (hrp.Position - mobHrp.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestMob = mob
                    end
                end
            end
        end
    end
    return closestMob
end

------------------------------------------------------------------
-- HÀM NHẬN TRÁI ÁC QUỶ (GACHA)
------------------------------------------------------------------
local function runGachaFruit()
    isDoingGacha = true
    restoreCharacterControl()
    updateUIState()

    local startTime = tick()

    while tick() - startTime < 10 do
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")

        if hrp then
            hrp.CFrame = CFrame.new(gachaTargetPos)
        end

        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("Cousin", "Buy")
            end
        end)

        clickWorldPosition(gachaClickPos, 2)
        autoClickGachaUIButton()
        autoStoreFruit()
        
        task.wait(0.4)
    end

    autoStoreFruit()
    isDoingGacha = false
    
    forceUnsit()
    updateUIState()
end

------------------------------------------------------------------
-- VÒNG LẶP CHÍNH AUTO FARM MOB SEA 2
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.05) do
        if isScriptEnabled and not isTweening and not isDoingGacha then
            pcall(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                forceUnsit()
                ensureHoverBodyVelocity()
                autoBuso()
                updateUIState()
                updateQuestTracker()
                autoAddStats()
                
                local hrp = character.HumanoidRootPart
                local qData = getCurrentQuestData()
                local playerGui = player:WaitForChild("PlayerGui")
                local questFrame = playerGui.Main.Quest

                if not questFrame.Visible then
                    local distToNpc = (hrp.Position - qData.NpcCFrame.Position).Magnitude
                    if distToNpc > 15 then
                        flyLinearTo(qData.NpcCFrame, FLY_SPEED_LONG)
                    end
                    if isScriptEnabled and not isDoingGacha then
                        startQuest(qData.QuestName, qData.QuestLevel)
                        task.wait(0.5)
                    end
                else
                    local targetMob = getClosestMob(qData.MobName)
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobHrp = targetMob.HumanoidRootPart
                        local distToMob = (hrp.Position - mobHrp.Position).Magnitude
                        
                        if distToMob > 25 then
                            flyLinearTo(mobHrp.CFrame * CFrame.new(0, 20, 0), FLY_SPEED_SHORT)
                        else
                            attackAboveHead(mobHrp)
                        end
                    else
                        if (hrp.Position - qData.MobCFrame.Position).Magnitude > 20 then
                            flyLinearTo(qData.MobCFrame, FLY_SPEED_SHORT)
                        end
                    end
                end
            end)
        end
    end
end)

------------------------------------------------------------------
-- LUỒNG ĐIỀU KHIỂN THỜI GIAN LẶP GACHA (MỖI 2 TIẾNG)
------------------------------------------------------------------
task.spawn(function()
    while true do
        runGachaFruit()
        task.wait(7210)
    end
end)


else
    -- Không ở Sea 1 hoặc Sea 2
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("AutoFarmLeftGui") then CoreGui.AutoFarmLeftGui:Destroy() end
    if CoreGui:FindFirstChild("AutoFarmTopGui") then CoreGui.AutoFarmTopGui:Destroy() end

    local p = game:GetService("Players").LocalPlayer
    local gui = p:FindFirstChild("PlayerGui")
    if gui then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto Farm Lỗi",
            Text = "Phiên bản này chỉ hỗ trợ Sea 1 và Sea 2!",
            Duration = 10
        })
    end
end


-- Version: 1.2.7 (Saber Auto-Retry 3x & UI Notification Banner)
