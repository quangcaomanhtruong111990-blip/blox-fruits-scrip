local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Trạng thái Script
local isScriptEnabled = true
local currentIsland = 1 -- 1: Bandit, 2: Jungle, 3: Pirate
local isTweening = false
local currentTween = nil
local lastTryQuest = 0 -- Thời gian thử nhận nhiệm vụ gần nhất

-- Cấu hình tốc độ bay
local FLY_SPEED_LONG = 120
local FLY_SPEED_SHORT = 90

-- Tọa độ cố định
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local BANDIT_MOB_POS = CFrame.new(1145, 17, 1630)

local JUNGLE_NPC_POS = CFrame.new(-1600, 36, 153)
local JUNGLE_MOB_POS = CFrame.new(-1450, 26, 200)

local PIRATE_NPC_POS = CFrame.new(-1140, 4, 3825)
local PIRATE_MOB_POS = CFrame.new(-1050, 6, 3900)

------------------------------------------------------------------
-- HÀM DỌN DẸP
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
-- GIAO DIỆN
------------------------------------------------------------------
if CoreGui:FindFirstChild("AutoFarmModernGui") then CoreGui.AutoFarmModernGui:Destroy() end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmModernGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,220,0,50)
mainFrame.Position = UDim2.new(0,30,0,80)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,22,28)
mainFrame.Active = true; mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,10)
local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Thickness =1.5; frameStroke.Color = Color3.fromRGB(0,230,150)

local statusDot = Instance.new("Frame", mainFrame)
statusDot.Size = UDim2.new(0,10,0,10); statusDot.Position=UDim2.new(0,14,0.5,-5)
statusDot.BackgroundColor3=Color3.fromRGB(0,230,115)
Instance.new("UICorner", statusDot).CornerRadius=UDim.new(1,0)

local subText = Instance.new("TextLabel", mainFrame)
subText.Size=UDim2.new(1,-40,1,0); subText.Position=UDim2.new(0,32,0,0)
subText.BackgroundTransparency=1; subText.TextColor3=Color3.new(1,1,1)
subText.Font=Enum.Font.GothamMedium; subText.TextSize=11; subText.TextXAlignment=Enum.TextXAlignment.Left

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size=UDim2.new(1,0,1,0); toggleBtn.BackgroundTransparency=1; toggleBtn.Text=""

local function updateUIState()
    local tenDao = currentIsland==1 and "Bandit" or currentIsland==2 and "Jungle" or "Hải Tặc"
    if isScriptEnabled then
        frameStroke.Color=Color3.fromRGB(0,230,150); statusDot.BackgroundColor3=Color3.fromRGB(0,230,115)
        subText.Text=string.format("RUN | %s [K]", tenDao)
    else
        frameStroke.Color=Color3.fromRGB(235,60,60); statusDot.BackgroundColor3=Color3.fromRGB(235,60,60)
        subText.Text=string.format("PAUSE | %s [K]", tenDao)
    end
end

toggleBtn.MouseButton1Click:Connect(function() isScriptEnabled=not isScriptEnabled; updateUIState(); if not isScriptEnabled then restoreCharacterControl() end end)
UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.K then toggleBtn:Fire("MouseButton1Click") end end)

------------------------------------------------------------------
-- HÀM BAY
------------------------------------------------------------------
local function flyLinearTo(targetCFrame, speed)
    if not isScriptEnabled then return end
    local char=player.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp=char.HumanoidRootPart; speed=speed or FLY_SPEED_LONG
    local start=hrp.Position; local endPos=targetCFrame.Position
    local cao=math.max(start.Y,endPos.Y)+25
    local targetBay=CFrame.new(endPos.X,cao,endPos.Z)
    local kc=(hrp.Position-targetBay.Position).Magnitude
    isTweening=true
    for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end
    local bv=Instance.new("BodyVelocity",hrp); bv.Name="AntiFall"; bv.MaxForce=Vector3.new(1e9,1e9,1e9)
    local tween=TweenService:Create(hrp,TweenInfo.new(kc/speed),{CFrame=targetBay})
    tween:Play(); tween.Completed:Wait()
    if isScriptEnabled then local land=TweenService:Create(hrp,TweenInfo.new(0.6),{CFrame=targetCFrame}) land:Play() land.Completed:Wait() end
    bv:Destroy(); isTweening=false
end

local function flyShort(targetCFrame)
    if not isScriptEnabled then return end
    local char=player.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp=char.HumanoidRootPart
    local kc=(hrp.Position-targetCFrame.Position).Magnitude
    if kc<3 then hrp.CFrame=targetCFrame return end
    for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end
    local tween=TweenService:Create(hrp,TweenInfo.new(kc/FLY_SPEED_SHORT),{CFrame=targetCFrame})
    local bv=Instance.new("BodyVelocity",hrp); bv.Name="AntiFall"; bv.MaxForce=Vector3.new(1e9,1e9,1e9)
    tween:Play(); tween.Completed:Connect(function() bv:Destroy() end)
end

------------------------------------------------------------------
-- CÔNG CỤ CHÍNH
------------------------------------------------------------------
local function equipWeapon()
    local c=player.Character local bp=player:FindFirstChild("Backpack") if not c or not bp then return end
    if not c:FindFirstChildOfClass("Tool") then for _,i in pairs(bp:GetChildren()) do if i:IsA("Tool") then c.Humanoid:EquipTool(i) break end end end
end

-- === CẢI THIỆN: THỬ LẠI NHIỆM VỤ MỖI 2 GIÂY CHO ĐẾN KHI THÀNH CÔNG ===
local function startQuest(questName)
    local now = os.clock()
    if now - lastTryQuest < 2 then return end -- không spam quá nhanh
    lastTryQuest = now

    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("StartQuest", questName, 1)
            print("[AUTO] Đã gửi yêu cầu nhận: "..questName)
        end
    end)
end

local function getClosestMob(pattern)
    local c=player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp=c.HumanoidRootPart local gan,kcNhat=nil,1500
    local enemies=workspace:FindFirstChild("Enemies")
    if enemies then for _,m in pairs(enemies:GetChildren()) do if string.find(m.Name,pattern) then local mh=m:FindFirstChild("HumanoidRootPart") local mh2=m:FindFirstChild("Humanoid") if mh and mh2 and mh2.Health>0 then local kc=(hrp.Position-mh.Position).Magnitude if kc<kcNhat then kcNhat=kc gan=m end end end end end
    return gan
end

local function fastAttack()
    pcall(function() local t=player.Character and player.Character:FindFirstChildOfClass("Tool") if t then t:Activate() end end)
end

------------------------------------------------------------------
-- CHUYỂN ĐẢO
------------------------------------------------------------------
local playerGui=player:WaitForChild("PlayerGui")
local questFrame=playerGui:WaitForChild("Main"):WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isScriptEnabled and not isTweening then
        if currentIsland==1 then
            currentIsland=2 updateUIState()
            task.spawn(function() flyLinearTo(JUNGLE_NPC_POS,FLY_SPEED_LONG) end)
        elseif currentIsland==2 then
            currentIsland=3 updateUIState()
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="Đến Làng Hải Tặc!",Text="Đang nhận nhiệm vụ Pirate...",Duration=3})
            task.spawn(function() flyLinearTo(PIRATE_NPC_POS,FLY_SPEED_LONG) end)
        end
    end
end)

------------------------------------------------------------------
-- VÒNG LẶP CHÍNH: SỬA KHÔNG BỊ ĐỨNG YÊN
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.15) do -- chậm chút ổn định hơn
        if not isScriptEnabled then break end
        updateUIState()

        pcall(function()
            local c=player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
            equipWeapon()
            local hrp=c.HumanoidRootPart

            -- Lấy thông tin đảo
            local qName,tenQuai,npcVi,quaiVi
            if currentIsland==1 then qName="BanditQuest1" tenQuai="Bandit" npcVi=BANDIT_NPC_POS quaiVi=BANDIT_MOB_POS
            elseif currentIsland==2 then qName="JungleQuest" tenQuai="Monkey" npcVi=JUNGLE_NPC_POS quaiVi=JUNGLE_MOB_POS
            else -- === Đảo Hải Tặc ===
                qName="PirateAdventurer" -- ✅ ĐÚNG TÊN NHƯ HÌNH: Pirate Adventurer
                tenQuai="Pirate"
                npcVi=PIRATE_NPC_POS
                quaiVi=PIRATE_MOB_POS
            end

            -- === KHI KHÔNG CÓ NHIỆM VỤ: ĐỨNG GẦN NPC + THỬ NHẬN LẠI LIÊN TỤC ===
            if not questFrame.Visible then
                local kcNpc=(hrp.Position-npcVi.Position).Magnitude
                if kcNpc>8 then -- chưa đủ gần → bay sát hơn
                    flyLinearTo(npcVi, FLY_SPEED_SHORT)
                else
                    -- Đủ gần rồi → liên tục thử nhận nhiệm vụ mỗi 2s
                    startQuest(qName)
                end
            else
                -- === Đang có nhiệm vụ: đi đánh quái liên tục ===
                local target=getClosestMob(tenQuai)
                if target and target:FindFirstChild("HumanoidRootPart") then
                    flyShort(target.HumanoidRootPart.CFrame*CFrame.new(0,8,0))
                    if (hrp.Position-target.HumanoidRootPart.Position).Magnitude<=12 then
                        for i=1,3 do if not isScriptEnabled then break end fastAttack() task.wait(0.08) end
                    end
                else
                    flyShort(quaiVi)
                end
            end
        end)
    end
end)
