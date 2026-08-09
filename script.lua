
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- Cấu hình
local maxQuests = 1           -- Số lần làm Q cho mỗi đảo (1 lần)
@@ -363,16 +365,22 @@ task.spawn(function()

                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
 ---- 9. Anti-AFK (Chống bị kick khi ngâm máy 20 phút)
local VirtualUser = game:GetService("VirtualUser")
                    end
                end
            end)
        end
    end
end)

-- 9. Anti-AFK (Chống bị kick khi ngâm máy 20 phút)
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- 10. Noclip (Xuyên vật thể liên tục khi đang farm/bay)
game:GetService("RunService").Stepped:Connect(function()
RunService.Stepped:Connect(function()
    if isFarming then
        local character = player.Character
        if character then
@@ -383,10 +391,4 @@ game:GetService("RunService").Stepped:Connect(function()
            end
        end
    end
end)
                    end
                end
            end)
        end
    end
end)
