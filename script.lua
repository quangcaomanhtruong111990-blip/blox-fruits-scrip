local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- === TRẠNG THÁI & CẤU HÌNH ===
local isScriptEnabled = true
local currentIsland = 1
local isTweening = false
local hasLearnedDarkStep = false
local targetBone = 100
local completedIsland1 = false
local completedIsland2 = false
local isLearningFighting = false

local FLY_SPEED_LONG = 120
local FLY_SPEED_SHORT = 90
local DARK_STEP_PRICE = 150000
local BLACK_LEG_POS = CFrame.new(-1125, 5, 3850) -- Sửa đúng vị trí thầy võ
local FACTION_CHOICE = "Pirate" -- === TÊN PHE MUỐN CHỌN: Pirate / Marine ===

-- Tọa độ đảo
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local BANDIT_MOB_POS = CFrame.new(1145, 17, 1630)
local JUNGLE_NPC_POS = CFrame.new(-1600, 36, 153)
local JUNGLE_MOB_POS = CFrame.new(-1450, 26, 200)
local PIRATE_NPC_POS = CFrame.new(-1140, 4, 3825)
local PIRATE_MOB_POS = CFrame.new(-1050, 6, 3900)

------------------------------------------------------------------
-- === TỰ CHỌN PHE NGAY KHI VÀO GAME ===
------------------------------------------------------------------
task.spawn(function()
    repeat task.wait() until player:FindFirstChild("PlayerGui")
    task.wait(2) -- chờ giao diện tải xong
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("SetFaction", FACTION_CHOICE) -- chọn phe
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ Tự chọn phe thành công",
                Text = "Đã chọn phe: "..FACTION_CHOICE, Duration = 3
            })
        end
    end)
end)

------------------------------------------------------------------
-- === BỎ KIỂM TRA TIỀN → ĐI MUA LUÔN ===
------------------------------------------------------------------
local function tryBuyLearnDarkStep()
    if hasLearnedDarkStep or not isScriptEnabled or isLearningFighting then return true end
    isLearningFighting = true

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🚀 Đi mua Dark Step ngay!", Duration = 3
    })

    -- Bay đến thầy võ
    flyLinearTo(BLACK_LEG_POS, FLY_SPEED_LONG)
    task.wait(1.5) -- đứng đủ gần NPC

    local buySuccess = false
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            -- Gọi mua thẳng
            commF:InvokeServer("BuyFightingStyle", "Dark Step", DARK_STEP_PRICE)
            task.wait(1)
            buySuccess = true
            hasLearnedDarkStep = true
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ HỌC ĐƯỢC DARK STEP!",
                Text = "Bắt đầu farm Bone đến 100 điểm", Duration = 4
            })
        end
    end)

    if not buySuccess then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚠️ Không mua được",
            Text = "Kiểm tra vị trí NPC hoặc tên kỹ năng", Duration = 3
        })
    end

    isLearningFighting = false
    return buySuccess
end

------------------------------------------------------------------
-- DỌN DẸP & TỰ DỪNG KHI ĐỦ BONE
------------------------------------------------------------------
local function getStatValue(statName)
    local leaderstats = player:WaitForChild("leaderstats",5)
    if not leaderstats then return 0 end
    local s = leaderstats:FindFirstChild(statName)
    return s and tonumber(s.Value) or 0
end

local function stopScriptWhenDone(reason)
    isScriptEnabled = false
    if currentTween then currentTween:Cancel() currentTween=nil end
    local char = player.Character
    if char then
        for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=true end end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then for _,v in pairs(hrp:GetChildren()) do if v.Name=="AntiFall" then v:Destroy() end end end
    end
    game:GetService("StarterGui"):SetCore("SendNotification",{Title="🛑 Kết thúc",Text=reason,Duration=5})
    updateUIState()
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
mainFrame.Size = UDim2.new(0,250,0,55)
mainFrame.Position = UDim2.new(0,30,0,80)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,22,28)
mainFrame.Active = true; mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,10)
local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Thickness=1.5; frameStroke.Color=Color3.fromRGB(0,230,150)

local statusDot = Instance.new("Frame", mainFrame)
statusDot.Size = UDim2.new(0,10,0,10); statusDot.Position=UDim2.new(0,14,0.5,-5)
statusDot.BackgroundColor3=Color3.fromRGB(0,230,115)
Instance.new("UICorner", statusDot).CornerRadius=UDim.new(1,0)

local subText = Instance.new("TextLabel", mainFrame)
subText.Size=UDim2.new(1,-40,0,16); subText.Position=UDim2.new(0,32,0,28)
subText.BackgroundTransparency=1; subText.TextColor3=Color3.new(1,1,1)
subText.Font=Enum.Font.GothamMedium; subText.TextSize=11; subText.TextXAlignment=Enum.TextXAlignment.Left

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size=UDim2.new(1,0,1,0); toggleBtn.BackgroundTransparency=1; toggleBtn.Text=""

function updateUIState()
    if not isScriptEnabled then
        frameStroke.Color=Color3.fromRGB(235,60,60); statusDot.BackgroundColor3=Color3.fromRGB(235,60,60)
        subText.Text="ĐÃ DỪNG"
        return
    end
    frameStroke.Color=Color3.fromRGB(0,230,150); statusDot.BackgroundColor3=Color3.fromRGB(0,230,115)
    local n = currentIsland==1 and "Bandit" or currentIsland==2 and "Jungle" or "Pirate"
    subText.Text=string.format("Đảo: %s | Bone: %d/%d",n,getStatValue("Bone"),targetBone)
end

toggleBtn.MouseButton1Click:Connect(function() isScriptEnabled=not isScriptEnabled; if not isScriptEnabled then stopScriptWhenDone("Tắt thủ công") end updateUIState() end)
UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.K then toggleBtn() end end)

------------------------------------------------------------------
-- HÀM BAY & CÔNG CỤ
------------------------------------------------------------------
local function flyLinearTo(targetCFrame, speed)
    if not isScriptEnabled then return end
    local char=player.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp=char.HumanoidRootPart; speed=speed or FLY_SPEED_LONG
    local start=hrp.Position; local target=targetCFrame.Position
    local high=math.max(start.Y,target.Y)+25
    local dist=(hrp.Position - Vector3.new(target.X,high,target.Z)).Magnitude
    isTweening=true
    for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end
    local bv=Instance.new("BodyVelocity",hrp); bv.Name="AntiFall"; bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(9e9,9e9,9e9)
    local tween=TweenService:Create(hrp,TweenInfo.new(dist/speed,Enum.EasingStyle.Linear),{CFrame=CFrame.new(target.X,high,target.Z)})
    tween:Play(); tween.Completed:Wait()
    if isScriptEnabled then local land=TweenService:Create(hrp,TweenInfo.new(0.6),{CFrame=targetCFrame}) land:Play() land.Completed:Wait() end
    bv:Destroy(); isTweening=false
end

local function flyShort(targetCFrame)
    if not isScriptEnabled then return end
    local char=player.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp=char.HumanoidRootPart
    local dist=(hrp.Position-targetCFrame.Position).Magnitude
    if dist<3 then hrp.CFrame=targetCFrame return end
    for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end
    local bv=Instance.new("BodyVelocity",hrp); bv.Name="AntiFall"; bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(9e9,9e9,9e9)
    local tween=TweenService:Create(hrp,TweenInfo.new(dist/FLY_SPEED_SHORT),{CFrame=targetCFrame})
    tween:Play(); tween.Completed:Connect(function() bv:Destroy() end)
end

local function equipWeapon()
    local c=player.Character local bp=player:FindFirstChild("Backpack") if not c or not bp then return end
    if not c:FindFirstChildOfClass("Tool") then for _,i in pairs(bp:GetChildren()) do if i:IsA("Tool") then c.Humanoid:EquipTool(i) break end end end
end

local function startQuest(qName)
    pcall(function() local c=ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_") if c then c:InvokeServer("StartQuest",qName,1) end end)
end

local function getClosestMob(pattern)
    local c=player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp=c.HumanoidRootPart local closest,minD=nil,1500
    local enemies=workspace:FindFirstChild("Enemies")
    if enemies then for _,m in pairs(enemies:GetChildren()) do if string.find(m.Name,pattern) then local mh=m:FindFirstChild("HumanoidRootPart") local mh2=m:FindFirstChild("Humanoid") if mh and mh2 and mh2.Health>0 then local d=(hrp.Position-mh.Position).Magnitude if d<minD then minD=d closest=m end end end end end
    return closest
end

local function fastAttack()
    pcall(function() local t=player.Character and player.Character:FindFirstChildOfClass("Tool") if t then t:Activate() end end)
end

------------------------------------------------------------------
-- CHUYỂN ĐẢO & VÒNG LẶP CHÍNH
------------------------------------------------------------------
local playerGui=player:WaitForChild("PlayerGui")
local questFrame=playerGui:WaitForChild("Main"):WaitForChild("Quest")

questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isScriptEnabled and not isTweening then
        if currentIsland==1 and not completedIsland1 then
            completedIsland1=true; currentIsland=2; updateUIState()
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ Xong Bandit",Text="Đi Jungle",Duration=2})
            task.spawn(function() flyLinearTo(JUNGLE_NPC_POS,FLY_SPEED_LONG) end)
        elseif currentIsland==2 and not completedIsland2 then
            completedIsland2=true; currentIsland=3; updateUIState()
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ Xong Jungle",Text="Đi Hải Tặc",Duration=2})
            task.spawn(function() flyLinearTo(PIRATE_NPC_POS,FLY_SPEED_LONG) end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if not isScriptEnabled then break end
        updateUIState()

        if getStatValue("Bone") >= targetBone then
            stopScriptWhenDone("Đủ 100 Bone! Hoàn thành ✅")
            break
        end

        if isTweening or isLearningFighting then continue end

        pcall(function()
            local c=player.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
            equipWeapon()
            local hrp=c.HumanoidRootPart

            local qName,pat,npcP,mobP
            if currentIsland==1 then qName="BanditQuest1" pat="Bandit" npcP=BANDIT_NPC_POS mobP=BANDIT_MOB_POS
            elseif currentIsland==2 then qName="JungleQuest" pat="Monkey" npcP=JUNGLE_NPC_POS mobP=JUNGLE_MOB_POS
            elseif currentIsland==3 then
                if not hasLearnedDarkStep then tryBuyLearnDarkStep() end -- mua ngay không hỏi tiền
                qName="BuggyQuest1" pat="Pirate" npcP=PIRATE_NPC_POS mobP=PIRATE_MOB_POS
            end

            if questFrame and not questFrame.Visible then
                if (hrp.Position-npcP.Position).Magnitude>15 then flyLinearTo(npcP,FLY_SPEED_LONG) end
                startQuest(qName) task.wait(0.3)
            else
                local target=getClosestMob(pat)
                if target and target:FindFirstChild("HumanoidRootPart") then
                    flyShort(target.HumanoidRootPart.CFrame*CFrame.new(0,9,0))
                    if (hrp.Position-target.HumanoidRootPart.Position).Magnitude<=12 then for i=1,4 do fastAttack() end end
                else flyShort(mobP) end
            end
        end)
    end
end)
