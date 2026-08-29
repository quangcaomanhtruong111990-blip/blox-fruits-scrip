-- ========================================================
-- BLOX FRUITS AUTO FARM SCRIPT (Rua Hub / Kunblox.net)
-- Complete & Fixed Version
-- ========================================================

_G.Config = _G.Config or {
    AutoFarm = true,
    FastAttack = true,
    AutoBuyMelee = true,
    AutoSaber = true,
    AutoRedeemCode = true,
    WebhookURL = "" -- Nhập Discord Webhook vào đây nếu muốn gửi log
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- 1. DISCORD WEBHOOK LOGGING
local function SendWebhook(msg)
    if _G.Config.WebhookURL and _G.Config.WebhookURL ~= "" then
        pcall(function()
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if req then
                req({
                    Url = _G.Config.WebhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({content = msg})
                })
            end
        end)
    end
end

-- 2. ANTI-AFK & AUTO REJOIN ON ERROR
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

if game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui") then
    game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end

-- 3. HUD UI OVERLAY (kunblox.net)
local function CreateHUD()
    if game:GetService("CoreGui"):FindFirstChild("KunbloxHUD") then
        game:GetService("CoreGui").KunbloxHUD:Destroy()
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "KunbloxHUD"
    sg.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 65)
    frame.Position = UDim2.new(0.02, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.4, 0)
    title.Text = "kunblox.net | Rua Hub"
    title.TextColor3 = Color3.fromRGB(0, 255, 150)
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.BackgroundTransparency = 1
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Name = "StatusLabel"
    status.Size = UDim2.new(1, 0, 0.6, 0)
    status.Position = UDim2.new(0, 0, 0.4, 0)
    status.Text = "Trạng thái: Đang hoạt động..."
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextSize = 12
    status.Font = Enum.Font.SourceSans
    status.BackgroundTransparency = 1
    status.Parent = frame
end
pcall(CreateHUD)

-- 4. FAST ATTACK & MOB MAGNET
local function FastAttack()
    if not _G.Config.FastAttack then return end
    pcall(function()
        local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
        local RegisterAttack = ReplicatedStorage:FindFirstChild("RigControllerEvent") or (Net and Net:FindFirstChild("RegisterAttack"))
        
        if RegisterAttack then
            RegisterAttack:FireServer()
        end
    end)
end

local function MagnetMobs(targetCFrame)
    pcall(function()
        if not workspace:FindFirstChild("Enemies") then return end
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                if (v.HumanoidRootPart.Position - targetCFrame.Position).Magnitude < 60 then
                    v.HumanoidRootPart.CFrame = targetCFrame
                    v.HumanoidRootPart.CanCollide = false
                    v.Humanoid.Size = Vector3.new(50, 50, 50)
                end
            end
        end
    end)
end

-- 5. FUNCTIONS HANDLER & SABER METHOD
local FunctionsHandler = {
    Saber = {}
}

function FunctionsHandler.Saber:RegisterMethod(name, fn)
    self[name] = fn
end

function FunctionsHandler.Saber:ExecuteMethod(name, ...)
    if self[name] then
        self[name](...)
    end
end

FunctionsHandler.Saber:RegisterMethod("Refresh", function()
    pcall(function()
        if LocalPlayer and LocalPlayer.Character and LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") then
            if LocalPlayer.Data.Level.Value >= 200 and _G.Config.AutoSaber then
                local saberExpert = workspace:FindFirstChild("Map") 
                    and workspace.Map:FindFirstChild("Jungle") 
                    and workspace.Map.Jungle:FindFirstChild("Saber Expert")
                
                if saberExpert and saberExpert:FindFirstChild("HumanoidRootPart") and saberExpert:FindFirstChild("Humanoid") and saberExpert.Humanoid.Health > 0 then
                    if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = saberExpert.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        FastAttack()
                    end
                end
            end
        end
    end)
end)

-- 6. AUTO REDEEM CODES
local promoCodes = {
    "NEWBOOST", "EXP_50K", "SECRET_ADMIN", "ADMIN_KIT", "SUB2GAMERROBOT_EXP1",
    "KITT_RESET", "Sub2Fer999", "Enyu_is_Pro", "Magicbus", "JCWK", "Starcodeheo"
}

task.spawn(function()
    if not _G.Config.AutoRedeemCode then return end
    for _, code in ipairs(promoCodes) do
        pcall(function()
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
            if commF then
                commF:InvokeServer("RedeemCode", code)
            end
        end)
        task.wait(1)
    end
end)

-- 7. AUTO BUY MELEE
local function AutoBuyMelee()
    if not _G.Config.AutoBuyMelee then return end
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("BuyBlackLeg")
            commF:InvokeServer("BuyElectro")
            commF:InvokeServer("BuyFishmanKarate")
            commF:InvokeServer("BlackbeardReward", "DragonClaw", "2")
            commF:InvokeServer("BuySuperhuman")
        end
    end)
end

-- 8. MAIN EXECUTION LOOP
task.spawn(function()
    SendWebhook("[Kunblox / Rua Hub] Đã load script thành công cho tài khoản: " .. LocalPlayer.Name)
    
    while task.wait(0.1) do
        pcall(function()
            -- Thực thi logic Saber
            FunctionsHandler.Saber:ExecuteMethod("Refresh")
            
            -- Thực thi Fast Attack
            FastAttack()
            
            -- Tự mua võ khi đủ điều kiện
            AutoBuyMelee()

            -- Tự gom quái xung quanh
            if _G.Config.AutoFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                MagnetMobs(LocalPlayer.Character.HumanoidRootPart.CFrame)
            end
        end)
    end
end)

print("[Kunblox.net / Rua Hub] Script đã ghép hoàn chỉnh và khởi chạy thành công!")
