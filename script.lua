-- Ví dụ logic nhận quest và teleport đến vị trí quái
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

-- 1. Gọi RemoteEvent để nhận nhiệm vụ từ xa (không cần chạy lại gặp NPC)
local function getQuest()
    -- Tên Quest và Level tương ứng ở Sea 2
    local args = {
        [1] = "StartQuest",
        [2] = "Area1Quest", -- Tên quest ví dụ
        [3] = 1
    }
    ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
end

-- 2. Bay (Tween) nhân vật đến vị trí quái an toàn
local function teleportToMob(targetCFrame)
    local hrp = player.Character:WaitForChild("HumanoidRootPart")
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 300 -- Tốc độ bay an toàn chống Anti-Cheat
    
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
end

-- Chạy thử nhận quest
getQuest()
