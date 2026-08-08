local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- === CÀI ĐẶT ===
local isScriptEnabled = true
local currentIsland = 1
local isTweening = false
local hasLearnedDarkStep = false
local targetBone = 100
local completedIsland1, completedIsland2 = false, false
local isLearningFighting = false

local FLY_SPEED_LONG = 120
local FLY_SPEED_SHORT = 90
local DARK_STEP_PRICE = 150000
local BLACK_LEG_POS = CFrame.new(-1125, 5, 3850) -- sửa đúng vị trí thầy võ
local FACTION_CHOICE = "Pirate" -- đổi thành "Marine" nếu muốn

-- Tọa độ đảo
local BANDIT_NPC_POS = CFrame.new(1038, 16, 1575)
local BANDIT_MOB_POS = CFrame.new(1145, 17, 1630)
local JUNGLE_NPC_POS = CFrame.new(-1600, 36, 153)
local JUNGLE_MOB_POS = CFrame.new(-1450, 26, 200)
local PIRATE_NPC_POS = CFrame.new(-1140, 4, 3825)
local PIRATE_MOB_POS = CFrame.new(-1050, 6, 3900)

------------------------------------------------------------------
-- TỰ CHỌN PHE KHI VÀO
------------------------------------------------------------------
task.spawn(function()
    repeat task.wait() until player:FindFirstChild("PlayerGui")
    task.wait(2)
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("SetFaction", FACTION_CHOICE)
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="✅ Đã chọn phe: "..FACTION_CHOICE, Duration=3})
        end
    end)
end)

------------------------------------------------------------------
-- MUA DARK STEP NGAY KHÔNG KIỂM TRA TIỀN
------------------------------------------------------------------
local function tryBuyLearnDarkStep()
    if hasLearnedDarkStep or not isScriptEnabled or isLearningFighting then return true end
    isLearningFighting = true

    game:GetService("StarterGui"):SetCore("SendNotification", {Title="🚀 Đi mua Dark Step", Duration=3})
    flyLinearTo(BLACK_LEG_POS, FLY_SPEED_LONG)
    task.wait(1.5)

    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("BuyFightingStyle", "Dark Step", DARK_STEP_PRICE)
            task.wait(1)
            hasLearnedDarkStep = true
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="✅ Học được Dark Step!", Duration=4})
        end
    end)

    isLearningFighting = false
    return hasLearnedDarkStep
end

------------------------------------------------------------------
-- LẤY CHỈ SỐ & DỪNG KHI ĐỦ BONE
------------------------------------------------------------------
local function getStatValue(statName)
    local ls = player:WaitForChild("leaderstats", 5)
    local s = ls and ls:FindFirstChild(statName)
    return s and tonumber(s.Value) or 0
end

local function stopScriptWhenDone(reason)
    isScriptEnabled = false
    if currentTween then currentTween:Cancel() end
    local char = player.Character
    if char then
        for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=true end end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then for _,v in pairs(hrp:GetChildren()) do if v.Name=="AntiFall" then v:Destroy() end end end
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="🛑 Kết thúc", Text=reason, Duration=5})
    updateUIState()
end

------------------------------------------------------------------
-- GIAO DIỆN ĐƠN GIẢN
------------------------------------------------------------------
if CoreGui:FindFirstChild("AutoFarmGui") then CoreGui.AutoFarmGui:Destroy() end
local sg = Instance.new("ScreenGui")
sg.Name = "AutoFarmGui"
sg.Parent = CoreGui

local f = Instance.new("Frame")
f.Size = UDim2.new(0,220,0,50)
f.Position = UDim2.new(0,30,0,80)
f.BackgroundColor3 = Color3.fromRGB(20,22,28)
f.Active = true; f.Draggable = true
f.Parent = sg
Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

local txt = Instance.new("TextLabel")
txt.Size = UDim2.new(1,-10,1,0)
txt.Position = UDim2.new(0,10,0,0)
txt.BackgroundTransparency = 1
txt.TextColor3 = Color3.new(1,1,1)
txt.Font = Enum.Font.GothamBold
txt.TextSize = 12
txt.Parent = f

function updateUIState()
    if not isScriptEnabled then txt.Text = "ĐÃ DỪNG" return end
    local tenDao = currentIsland==1 and "Bandit" or currentIsland==2 and "Jungle" or "Pirate"
    txt.Text = string.format("Đảo: %s | Bone: %d/%d", tenDao, getStatValue("Bone"), targetBone)
end

------------------------------------------------------------------
-- HÀM BAY & ĐÁNH ĐƠN GIẢN
------------------------------------------------------------------
local function flyLinearTo(targetCf, speed)
    if not isScriptEnabled then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    speed = speed or FLY_SPEED_LONG
    local startP = hrp.Position
    local endP = targetCf.Position
    local cao = math.max(startP.Y, endP.Y)+20
    local targetBay = CFrame.new(endP.X, cao, endP.Z)
    isTweening = true
    for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end
    local bv = Instance.new("BodyVelocity", hrp)
    bv.Name = "AntiFall"
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    local tween = TweenService:Create(hrp, TweenInfo.new((hrp.Position - targetBay.Position).Magnitude/speed), {CFrame=targetBay})
    tween:Play() tween.Completed:Wait()
    if isScriptEnabled then TweenService:Create(hrp, TweenInfo.new(0.5), {CFrame=targetCf}):Play() task.wait(0.5) end
    bv:Destroy()
    isTweening = false
end

local function equipSword()
    local c = player.Character
    local bp = player:FindFirstChild("Backpack")
    if not c or not bp then return end
    if not c:FindFirstChildOfClass("Tool") then
        for _,v in pairs(bp:GetChildren()) do
            if v:IsA("Tool") then c.Humanoid:EquipTool(v) break end
        end
    end
end

local function attackNearestMob(tenQuai)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local ganNhat, khoangCachNhat = nil, 1000
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and string.find(v.Name, tenQuai) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local hrpQ = v:FindFirstChild("HumanoidRootPart")
            if hrpQ then
                local kc = (hrp.Position - hrpQ.Position).Magnitude
                if kc < khoangCachNhat then khoangCachNhat = kc ganNhat = hrpQ end
            end
        end
    end
    if ganNhat then
        hrp.CFrame = CFrame.new(ganNhat.Position + Vector3.new(0,5,0))
        task.wait(0.1)
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end

------------------------------------------------------------------
-- CHUYỂN ĐẢO & CHẠY CHÍNH
------------------------------------------------------------------
local questFrame = player:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Quest")
questFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not questFrame.Visible and isScriptEnabled and not isTweening then
        if currentIsland==1 and not completedIsland1 then
            completedIsland1 = true
            currentIsland = 2
            updateUIState()
            task.spawn(function() flyLinearTo(JUNGLE_NPC_POS, FLY_SPEED_LONG) end)
        elseif currentIsland==2 and not completedIsland2 then
            completedIsland2 = true
            currentIsland = 3
            updateUIState()
            task.spawn(function() flyLinearTo(PIRATE_NPC_POS, FLY_SPEED_LONG) end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if not isScriptEnabled then break end
        updateUIState()

        if getStatValue("Bone") >= targetBone then
            stopScriptWhenDone("Đủ 100 Bone ✅")
            break
        end

        if isTweening or isLearningFighting then continue end

        pcall(function()
            equipSword()
            local tenQuai, npcVi
            if currentIsland ==1 then tenQuai="Bandit" npcVi=BANDIT_NPC_POS
            elseif currentIsland==2 then tenQuai="Monkey" npcVi=JUNGLE_NPC_POS
            elseif currentIsland==3 then
                if not hasLearnedDarkStep then tryBuyLearnDarkStep() end
                tenQuai="Pirate" npcVi=PIRATE_NPC_POS
            end

            if questFrame.Visible then
                attackNearestMob(tenQuai) -- đánh quái gọn gàng
            else
                if (player.Character.HumanoidRootPart.Position - npcVi.Position).Magnitude > 15 then
                    flyLinearTo(npcVi, FLY_SPEED_LONG)
                end
                task.wait(0.3)
            end
        end)
    end
end)
