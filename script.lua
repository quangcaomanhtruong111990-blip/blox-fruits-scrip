-- Chờ giao diện tải xong
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Tìm nút "Chế Độ Nhanh"
local function findQuickModeButton()
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and string.find(string.lower(gui.Text), "chế độ nhanh") then
            return gui
        end
    end
    return nil
end

-- Chọn phe ngẫu nhiên rồi dừng
local function chooseRandomFactionAndStop()
    task.wait(10) -- chờ load xong 10 giây

    -- Tìm 2 nút phe: HẢI TẮC & HẢI QUÂN
    local btnPirate, btnMarine = nil, nil
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local txt = string.lower(gui.Text)
            if string.find(txt, "hải tặc") then btnPirate = gui end
            if string.find(txt, "hải quân") then btnMarine = gui end
        end
    end

    -- Chọn ngẫu nhiên 1 trong 2
    local chosen = math.random(1, 2) == 1 and btnPirate or btnMarine
    if chosen then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "✅ Đã chọn phe",
            Text = string.find(string.lower(chosen.Text), "hải tặc") and "HẢI TẮC" or "HẢI QUÂN",
            Duration = 3
        })
        -- Bấm nút
        fireclickdetector(chosen:IsA("TextButton") and chosen or chosen:FindFirstChildOfClass("ClickDetector"))
    end

    -- Dừng script
    script:Destroy()
end

-- Bắt đầu: bấm nút chế độ nhanh
task.spawn(function()
    repeat task.wait() until PlayerGui
    local btnQuick = nil
    repeat
        btnQuick = findQuickModeButton()
        task.wait(0.2)
    until btnQuick

    -- Bấm nút
    fireclickdetector(btnQuick:IsA("TextButton") and btnQuick or btnQuick:FindFirstChildOfClass("ClickDetector"))
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "⏳ Đang chờ load...", Duration = 2})

    -- Chạy luồng chờ rồi chọn phe
    task.spawn(chooseRandomFactionAndStop)
end)
