local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- === TRẠNG THÁI & MỤC TIÊU ===
local isScriptEnabled = true
local currentIsland = 1 -- 1:Bandit, 2:Jungle, 3:Pirate
local isTweening = false
local currentTween = nil
local hasLearnedDarkStep = false
local targetBone = 100 -- Đạt 100 Bone thì dừng
local maxQuestPerIsland = 1 -- Chỉ làm 1 nhiệm vụ mỗi đảo 1 & 2 rồi chuyển
local completedIsland1 = false
local completedIsland2 = false
local isLearningFighting = false

-- === CẤU HÌNH ===
local FLY_SPEED_LONG = 120
local FLY_SPEED_SHORT = 90
local DARK_STEP_PRICE = 150000 -- Đúng giá Dark Step
local BLACK_LEG_POS = CFrame.new(-1125, 5, 3850) -- Sửa đúng vị trí thầy võ!

-- Tọa độ
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local BANDIT_MOB_POS = CFrame.new(1145, 17, 1630)
local JUNGLE_NPC_POS = CFrame.new(-1600, 36, 153)
local JUNGLE_MOB_POS = CFrame.new(-1450, 26, 200)
local PIRATE_NPC_POS = CFrame.new(-1140, 4, 3825)
local PIRATE_MOB_POS = CFrame.new(-1050, 6, 3900)

------------------------------------------------------------------
-- === HÀM LẤY TIỀN: IN RA TẤT CẢ TÊN + THỬ TỰ ĐỘNG CÁC TÊN PHỔ BIẾN ===
------------------------------------------------------------------
local function getStatValue(tryNameList)
    local leaderstats = player:WaitForChild("leaderstats", 5)
    if not leaderstats then
        warn("[DEBUG] ❌ Không tìm thấy leaderstats!")
        return 0
    end

    -- === IN RA TẤT CẢ CÁC CHỈ SỐ ĐANG CÓ ĐỂ XEM TÊN CHÍNH XÁC ===
    print("===== [DEBUG] DANH SÁCH TẤT CẢ CHỈ SỐ TRONG LEADERSTATS =====")
    for _, stat in pairs(leaderstats:GetChildren()) do
        print(string.format("→ Tên: '%s' | Giá trị: %s", stat.Name, tostring(stat.Value)))
    end
    print("===========================================================")

    -- Thử lần lượt các tên trong danh sách
    if type(tryNameList) == "string" then tryNameList = {tryNameList} end
    for _, tryName in ipairs(tryNameList) do
        for _, stat in pairs(leaderstats:GetChildren()) do
            if string.lower(stat.Name) == string.lower(tryName) then
                print(string.format("[DEBUG] ✅ Tìm thấy tiền: '%s' = %d", stat.Name, stat.Value))
                return tonumber(stat.Value) or 0
            end
        end
    end

    warn("[DEBUG] ❌ Không tìm thấy tiền với các tên đã thử!")
    return 0
end

------------------------------------------------------------------
-- === HÀM KIỂM TRA & MUA ===
------------------------------------------------------------------
local function tryBuyLearnDarkStep()
    if hasLearnedDarkStep or not isScriptEnabled or isLearningFighting then return true end
    isLearningFighting = true

    -- === THỰC HIỆN THỬ TỰ ĐỘNG CÁC TÊN THƯỜNG GẶP ===
    local currentMoney = getStatValue({"$", "Money", "Beli", "Cash", "Coins"})
    print(string.format("[DEBUG] === Kiểm tra mua Dark Step: Cần %d | Có %d ===", DARK_STEP_PRICE, currentMoney))

    if currentMoney < DARK_STEP_PRICE then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚠️ Thông báo kiểm tra tiền",
            Text = string.format("Cần: %d | Đọc được: %d", DARK_STEP_PRICE, currentMoney),
            Duration = 5
        })
        isLearningFighting = false
        return false
    end

    -- === ĐỦ TIỀN → THỰC HIỆN MUA ===
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "✅ ĐỦ TIỀN! Đang mua Dark Step...",
        Text = string.format("Số tiền hiện có: %d", currentMoney),
        Duration = 4
    })

    flyLinearTo(BLACK_LEG_POS, FLY_SPEED_LONG)
    task.wait(1.5)

    local buySuccess = false
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            -- Thử đổi tên lệnh nếu cần: BuySkill / LearnFightingStyle / BuyMelee
            commF:InvokeServer("BuyFightingStyle", "Dark Step", DARK_STEP_PRICE)
            task.wait(1)
            buySuccess = true
            hasLearnedDarkStep = true
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ HỌC THÀNH CÔNG DARK STEP!",
                Text = "Bắt đầu farm Bone đến 100 điểm",
                Duration = 5
            })
        else
            warn("[DEBUG] ❌ Không tìm thấy Remote gửi yêu cầu mua!")
        end
    end)

    if not buySuccess then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ Mua thất bại",
            Text = "Kiểm tra tên kỹ năng/vị trí NPC",
            Duration = 5
        })
    end

    isLearningFighting = false
    return buySuccess
end

------------------------------------------------------------------
-- DỌN DẸP & TỰ DỪNG KHI ĐỦ BONE
------------------------------------------------------------------
local function stopScriptWhenDone(reason)
    isScriptEnabled = false
    if currentTween then currentTween:Cancel() currentTween = nil end
    local character = player.Character
    if character then
        for _,p in pairs(character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = true end end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then for _,v in pairs(hrp:GetChildren()) do if v.Name == "AntiFall" then v:Destroy() end end end
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🛑 Kết thúc Script",
        Text = reason, Duration = 5
    })
    updateUIState()
end

------------------------------------------------------------------
-- GIAO DIỆN THEO DÕI TRẠNG THÁI
------------------------------------------------------------------
if CoreGui:FindFirstChild("AutoFarmModernGui") then CoreGui.AutoFarmModernGui:Destroy() end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmModernGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,300,0,55)
mainFrame.Position = UDim2.new(0,30,0,80)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,22,28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Active = true; mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,10)
local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Thickness = 1.5; frameStroke.Color = Color3.fromRGB(0,230,150)

local statusDot = Instance.new("Frame", mainFrame)
statusDot.Size = UDim2.new(0,10,0,10); statusDot.Position = UDim2.new(0,14,0.5,-5)
statusDot.BackgroundColor3 = Color3.fromRGB(0,230,115)
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1,0)

local titleText = Instance.new("TextLabel", mainFrame)
titleText.Size = UDim2.new(0,280,0,20); titleText.Position = UDim2.new(0,32,0,5)
titleText.BackgroundTransparency = 1; titleText.Text = "AUTO FARM → HỌC → FARM BONE"
titleText.TextColor3 = Color3.new(1,1,1); titleText.TextSize =12; titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left

local subText = Instance.new("TextLabel", mainFrame)
subText.Size = UDim2.new(0,280,0,16); subText.Position = UDim2.new(0,32,0,28)
subText.BackgroundTransparency =1; subText.TextSize=11; subText.Font=Enum.Font.GothamMedium
subText.TextXAlignment = Enum.TextXAlignment.Left

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(1,0,1,0); toggleBtn.BackgroundTransparency=1; toggleBtn.Text=""

function updateUIState()
    if not isScriptEnabled then
        frameStroke.Color = Color3.fromRGB(235,60,60)
        statusDot.BackgroundColor3 = Color3.fromRGB(235,60,60)
        subText.Text = "ĐÃ DỪNG | HOÀN THÀNH"
        subText.TextColor3 = Color3.fromRGB(235,60,60)
        return
    end
    frameStroke.Color = Color3.fromRGB(0,230,150)
    statusDot.BackgroundColor3 = Color3.fromRGB(0,230,115)
    local islandName = currentIsland==1 and "Bandit" or currentIsland==2 and "Jungle" or "Pirate"
    local boneNow = getStatValue("Bone")
    local moneyNow = getStatValue({"$", "Money", "Beli", "Cash", "Coins"})
    subText.Text = string.format("Đảo: %s | Tiền: %d | Bone: %d/%d", islandName, moneyNow, boneNow, targetBone)
    subText.TextColor3 = Color3.fromRGB(0,230,115)
end

toggleBtn.MouseButton1Click:Connect(function()
    isScriptEnabled = not isScriptEnabled
    if not isScriptEnabled then stopScriptWhenDone("Ngừng thủ công") end
    updateUIState()
end)
UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.K then toggleBtn() end end)

------------------------------------------------------------------
-- HÀM BAY
------------------------------------------------------------------
local function flyLinearTo(targetCFrame, speed)
    if not isScriptEnabled then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    speed = speed or FLY_SPEED_LONG
    local startPos = hrp.Position
    local endPos = targetCFrame.Position
    local cruiseHeight = math.max(startPos.Y, endPos.Y)+25
    local targetStraightCFrame = CFrame.new(endPos.X, cruiseHeight, endPos.Z)
    local distance = (hrp.Position - targetStraightCFrame.Position).Magnitude
    isTweening=true
    for _,p in pairs(character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end
    for _,v in pairs(hrp:GetChildren()) do if v.Name=="AntiFall" then v:Destroy() end end
    local bv=Instance.new("BodyVelocity") bv.Name="AntiFall" bv.Velocity=Vector3.zero bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Parent=hrp
    local ttime=distance/speed
    local tween=TweenService:Create(hrp,TweenInfo.new(ttime,Enum.EasingStyle.Linear),{CFrame=targetStraightCFrame})
    currentTween=tween; tween:Play(); tween.Completed:Wait()
    if isScriptEnabled then local land=TweenService:Create(hrp,TweenInfo.new(0.6),{CFrame=targetCFrame}) currentTween=land land:Play() land.Completed:Wait() end
    if bv then bv:Destroy() end
    isTweening=false
end

local function flyShort(targetCFrame)
    if not isScriptEnabled then return end
    local character=player.Character if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp=character.HumanoidRootPart
    local dist=(hrp.Position-targetCFrame.Position).Magnitude
    if dist<3 then hrp.CFrame=targetCFrame return end
    for _,p in pairs(character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end
    local tween=TweenService:Create(hrp,TweenInfo.new(dist/FLY_SPEED_SHORT),{CFrame=targetCFrame})
    for _,v in pairs(hrp:GetChildren()) do if v.Name=="AntiFall" then v:Destroy() end end
    local bv=Instance.new("BodyVelocity") bv.Name="AntiFall" bv.Velocity=Vector3.zero bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Parent=hrp
    tween:Play() tween.Completed:Connect(function() if bv then bv:Destroy() end end)
end

------------------------------------------------------------------
-- CÔNG CỤ CHÍNH
------------------------------------------------------------------
local function equipWeapon()
    local c=player.Character local bp=player:FindFirstChild("Backpack") if not c or not bp then return end
    if not c:FindFirstChildOfClass("Tool") then for _,i in pairs(bp:GetChildren()) do if i:IsA("Tool") and (i.ToolTip=="Melee" or i.ToolTip=="Sword" or i.ToolTip=="Blox Fruit") then c.Humanoid:EquipTool(i) break end end end
end

local function startQuest(qName)
    pcall(function() local c=ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_") if c then c:InvokeServer("StartQuest",qName,1) end end)
end

local function getClosestMob(pattern)
    local c=player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp=c.HumanoidRootPart local closest, minD=nil,1500
    local enemies=workspace:FindFirstChild("Enemies")
    if enemies then for _,m in pairs(enemies:GetChildren()) do if string.find(m.Name,pattern) then local mh=m:FindFirstChild("HumanoidRootPart") local mh2=m:FindFirstChild("Humanoid") if mh and mh2 and mh2.Health>0 then local d=(hrp.Position-mh.Position).Magnitude if d<minD then minD=d closest=m end end end end end
    return closest
end

local function fastAttack()
    pcall(function() local c=player.Character local t=c and c:FindFirstChildOfClass("Tool") if t then t:Activate() VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1) VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1) end end)
end

------------------------------------------------------------------
-- CHUYỂN ĐẢO KHI HOÀN THÀNH 1 NHIỆM VỤ
------------------------------------------------------------------
local playerGui=player:WaitForChild("PlayerGui")
local mainGui=playerGui:WaitForChild("Main")
local questFrame=mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isScriptEnabled and not isTweening then
        -- Xong 1 nhiệm vụ đảo 1 → sang đảo 2
        if currentIsland ==1 and not completedIsland1 then
            completedIsland1 = true
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ Xong 1 nhiệm vụ Bandit",Text="Đang chuyển sang Đảo Khỉ Jungle",Duration=3})
            currentIsland=2 updateUIState()
            task.spawn(function() flyLinearTo(JUNGLE_NPC_POS,FLY_SPEED_LONG) end)
        -- Xong 1 nhiệm vụ đảo 2 → sang đảo 3 hải tặc
        elseif currentIsland ==2 and not completedIsland2 then
            completedIsland2 = true
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ Xong 1 nhiệm vụ Jungle",Text="Đang chuyển sang Làng Hải Tặc",Duration=3})
            currentIsland=3 updateUIState()
            task.spawn(function() flyLinearTo(PIRATE_NPC_POS,FLY_SPEED_LONG) end)
        end
    end
end)

------------------------------------------------------------------
-- VÒNG LẶP CHÍNH: ĐÚNG TRÌNH TỰ + KIỂMTRA BONE 100 DỪNG
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.05) do
        if not isScriptEnabled then break end
        updateUIState()

        -- Kiểm tra đã đủ Bone 100 chưa → dừng ngay
        local currentBone = getStatValue("Bone")
        if currentBone >= targetBone then
            stopScriptWhenDone(string.format("Đạt đủ %d Bone! Hoàn thành mục tiêu ✅", targetBone))
            break
        end

        -- Đang chuyển đảo/học võ thì chờ
        if isTweening or isLearningFighting then continue end

        pcall(function()
            local c=player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
            equipWeapon()
            local hrp=c.HumanoidRootPart

            -- Lấy thông tin đảo hiện tại
            local qName, mobPat, npcP, mobP
            if currentIsland==1 then
                qName="BanditQuest1" mobPat="Bandit" npcP=BANDIT_NPC_POS mobP=BANDIT_MOB_POS
            elseif currentIsland==2 then
                qName="JungleQuest" mobPat="Monkey" npcP=JUNGLE_NPC_POS mobP=JUNGLE_MOB_POS
            elseif currentIsland==3 then
                -- Ở đảo 3: kiểm tra & học võ trước khi tập trung farm Bone
                if not hasLearnedDarkStep then
                    tryBuyLearnDarkStep() -- Gọi kiểm tra + tự học
                end
                qName="BuggyQuest1" mobPat="Pirate" npcP=PIRATE_NPC_POS mobP=PIRATE_MOB_POS
            end

            -- Nhận nhiệm vụ khi chưa có
            if questFrame and not questFrame.Visible then
                local distNpc=(hrp.Position-npcP.Position).Magnitude
                if distNpc>15 then flyLinearTo(npcP,FLY_SPEED_LONG) end
                if isScriptEnabled then startQuest(qName) task.wait(0.3) end
            else
                -- Tìm quái gần nhất đánh liên tục
                local target=getClosestMob(mobPat)
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local mh=target.HumanoidRootPart
                    flyShort(mh.CFrame*CFrame.new(0,9,0))
                    if (hrp.Position-mh.Position).Magnitude<=12 then
                        for i=1,4 do if not isScriptEnabled then break end fastAttack() end
                    end
                else flyShort(mobP) end
            end
        end)
    end
end)
