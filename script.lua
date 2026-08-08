local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Trạng thái Script
local isScriptEnabled = true
local currentIsland = 1 -- 1: Bandit, 2: Jungle, 3: Hải Tặc Pirate
local isTweening = false
local currentTween = nil
local hasLearnedDarkStep = false -- Đánh dấu đã học để không lặp lại

-- Cấu hình tốc độ bay & thông tin học kỹ năng
local FLY_SPEED_LONG = 120
local FLY_SPEED_SHORT = 90
local DARK_STEP_PRICE = 150000 -- Giá Cước Đen
local BLACK_LEG_TEACHER_NAME = "Black Leg Teacher" -- Tên NPC dạy võ
-- Tọa độ NPC Black Leg Teacher (điều chỉnh cho đúng vị trí trong game của bạn!)
local BLACK_LEG_POS = CFrame.new(-1125, 5, 3850)

-- Tọa độ các đảo
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local BANDIT_MOB_POS = CFrame.new(1145, 17, 1630)
local JUNGLE_NPC_POS = CFrame.new(-1600, 36, 153)
local JUNGLE_MOB_POS = CFrame.new(-1450, 26, 200)
local PIRATE_NPC_POS = CFrame.new(-1140, 4, 3825)
local PIRATE_MOB_POS = CFrame.new(-1050, 6, 3900)

------------------------------------------------------------------
-- HÀM KIỂM TRA SỐ TIỀN BELI CỦA NHÂN VẬT
------------------------------------------------------------------
local function getPlayerBeli()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local beli = leaderstats:FindFirstChild("Beli")
        if beli then return beli.Value end
    end
    return 0
end

------------------------------------------------------------------
-- HÀM TỰ ĐỘNG HỌC DARK STEP TỪ BLACK LEG TEACHER
------------------------------------------------------------------
local function autoLearnDarkStep()
    if hasLearnedDarkStep or not isScriptEnabled then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    -- Kiểm tra tiền đủ chưa
    local currentBeli = getPlayerBeli()
    if currentBeli < DARK_STEP_PRICE then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚠️ Không đủ tiền!",
            Text = "Cần "..DARK_STEP_PRICE.." Beli để học Dark Step, có "..currentBeli.." Beli",
            Duration = 5
        })
        return
    end

    -- Bay đến vị trí NPC Black Leg Teacher
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🔍 Đang tìm Black Leg Teacher...",
        Text = "Đang di chuyển đến học Dark Step",
        Duration = 4
    })
    flyLinearTo(BLACK_LEG_POS, FLY_SPEED_LONG)
    task.wait(1.5) -- chờ ổn định vị trí

    -- Gọi tương tác mua học kỹ năng (cần điều chỉnh tên Remote/chuỗi lệnh cho chính xác game)
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            -- Lệnh tương tác mua học từ NPC Black Leg Teacher (thường là BuySkill/LearnFightingStyle)
            commF:InvokeServer("BuyFightingStyle", "Dark Step", DARK_STEP_PRICE)
            task.wait(1)
            -- Kiểm tra thành công
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ Học thành công!",
                Text = "Đã học Dark Step (Cước Đen) rồi, tiếp tục farm!",
                Duration = 5
            })
            hasLearnedDarkStep = true -- không chạy lại nữa
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "❌ Không tương tác được NPC",
                Text = "Kiểm tra tên Remote hoặc vị trí NPC",
                Duration = 4
            })
        end
    end)
end

------------------------------------------------------------------
-- HÀM DỌN DẸP / TRẢ LẠI QUYỀN ĐIỀU KHIỂN
------------------------------------------------------------------
local function restoreCharacterControl()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do if v.Name == "AntiFall" then v:Destroy() end end
        end
    end
    if currentTween then currentTween:Cancel() currentTween = nil end
    isTweening = false
end

------------------------------------------------------------------
-- GIAO DIỆN DECOR HIỆN ĐẠI
------------------------------------------------------------------
if CoreGui:FindFirstChild("AutoFarmModernGui") then CoreGui.AutoFarmModernGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmModernGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- Khung chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 50)
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

-- Chữ
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0, 120, 0, 20)
titleText.Position = UDim2.new(0, 32, 0, 8)
titleText.BackgroundTransparency = 1
titleText.Text = "AUTO FARM + HỌC VÕ"
titleText.TextColor3 = Color3.fromRGB(240,240,240)
titleText.TextSize = 13
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = mainFrame

local subText = Instance.new("TextLabel")
subText.Name = "SubText"
subText.Size = UDim2.new(0, 180, 0, 14)
subText.Position = UDim2.new(0, 32, 0, 26)
subText.BackgroundTransparency = 1
subText.Text = "Đảo: Bandit | RUNNING [K]"
subText.TextColor3 = Color3.fromRGB(0,230,115)
subText.TextSize = 11
subText.Font = Enum.Font.GothamMedium
subText.TextXAlignment = Enum.TextXAlignment.Left
subText.Parent = mainFrame

-- Nút bật tắt
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(1,0,1,0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""
toggleBtn.Parent = mainFrame

local function updateUIState()
    if isScriptEnabled then
        frameStroke.Color = Color3.fromRGB(0,230,150)
        statusDot.BackgroundColor3 = Color3.fromRGB(0,230,115)
        local islandName = currentIsland==1 and "Bandit" or currentIsland==2 and "Jungle" or "Pirate"
        subText.Text = "Đảo: "..islandName.." | RUNNING [K]"
        subText.TextColor3 = Color3.fromRGB(0,230,115)
    else
        frameStroke.Color = Color3.fromRGB(235,60,60)
        statusDot.BackgroundColor3 = Color3.fromRGB(235,60,60)
        subText.Text = "PAUSED [K]"
        subText.TextColor3 = Color3.fromRGB(235,60,60)
    end
end

local function toggleState()
    isScriptEnabled = not isScriptEnabled
    updateUIState()
    if not isScriptEnabled then restoreCharacterControl() end
end

toggleBtn.MouseButton1Click:Connect(toggleState)
UserInputService.InputBegan:Connect(function(input,gp)
    if not gp and input.KeyCode==Enum.KeyCode.K then toggleState() end
end)

------------------------------------------------------------------
-- HÀM BAY ĐƯỜNG THẲNG, BAY NGẮN GIỮ NGUYÊN
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
    currentTween=tween tween:Play() tween.Completed:Wait()
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
-- TRANG BỊ VŨ KHÍ, NHẬN NHIỆM VỤ, TÌM QUÁI, ĐÁNH
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
-- CHUYỂN ĐẢO & TỰ ĐỘNG HỌC DARK STEP KHI ĐẾN HẢI TẶC
------------------------------------------------------------------
local playerGui=player:WaitForChild("PlayerGui")
local mainGui=playerGui:WaitForChild("Main")
local questFrame=mainGui:WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isScriptEnabled and not isTweening then
        if currentIsland==1 then
            currentIsland=2 updateUIState()
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ Xong Bandit",Text="Đang bay sang Jungle",Duration=3})
            task.spawn(function() flyLinearTo(JUNGLE_NPC_POS,FLY_SPEED_LONG) end)
        elseif currentIsland==2 then
            -- Xong đảo 2 → sang Hải Tặc + tự động chạy học Dark Step
            currentIsland=3 updateUIState()
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ Xong Jungle",Text="Đang bay sang Hải Tặc, sẽ học Dark Step tự động",Duration=4})
            task.spawn(function()
                flyLinearTo(PIRATE_NPC_POS,FLY_SPEED_LONG)
                task.wait(2) -- chờ ổn định ở đảo hải tặc rồi mới học võ
                autoLearnDarkStep() -- Gọi hàm tự học Cước Đen
            end)
        end
    end
end)

------------------------------------------------------------------
-- VÒNG LẶP CHÍNH FARM
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.01) do
        if isScriptEnabled and not isTweening then
            pcall(function()
                local c=player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
                equipWeapon()
                local hrp=c.HumanoidRootPart
                local qName, mobPat, npcP, mobP
                if currentIsland==1 then qName="BanditQuest1" mobPat="Bandit" npcP=BANDIT_NPC_POS mobP=BANDIT_MOB_POS
                elseif currentIsland==2 then qName="JungleQuest" mobPat="Monkey" npcP=JUNGLE_NPC_POS mobP=JUNGLE_MOB_POS
                elseif currentIsland==3 then qName="BuggyQuest1" mobPat="Pirate" npcP=PIRATE_NPC_POS mobP=PIRATE_MOB_POS end

                if questFrame and not questFrame.Visible then
                    local distNpc=(hrp.Position-npcP.Position).Magnitude
                    if distNpc>15 then flyLinearTo(npcP,FLY_SPEED_LONG) end
                    if isScriptEnabled then startQuest(qName) task.wait(0.5) end
                else
                    local target=getClosestMob(mobPat)
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        local mh=target.HumanoidRootPart
                        flyShort(mh.CFrame*CFrame.new(0,9,0))
                        if (hrp.Position-mh.Position).Magnitude<=12 then for i=1,4 do if not isScriptEnabled then break end fastAttack() end end
                    else flyShort(mobP) end
                end
            end)
        end
    end
end)
