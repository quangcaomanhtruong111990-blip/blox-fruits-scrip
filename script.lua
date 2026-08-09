local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui", 10)
local StarterGui = game:GetService("StarterGui")

-- === HÀM BẤM NÚT CHẮC CHẮN ===
local function clickButton(btn)
    if not btn then return false end
    pcall(function()
        -- Cách 1: Kích hoạt trực tiếp
        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
            btn:Activate()
            -- Cách 2: Bấm ClickDetector nếu có
            local cd = btn:FindFirstChildOfClass("ClickDetector")
            if cd then fireclickdetector(cd) end
        end
    end)
    return true
end

-- === TÌM & BẤM CHỌN PHE NGẪU NHIÊN ===
local function pickRandomFaction()
    task.wait(10) -- chờ đủ 10s load xong

    local pirateBtn, marineBtn = nil, nil

    -- Duyệt toàn bộ giao diện tìm nút phe
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local ten = string.lower(obj.Name .. " " .. obj.Text)
            if string.find(ten, "hải tặc") or string.find(ten, "pirate") then
                pirateBtn = obj
            elseif string.find(ten, "hải quân") or string.find(ten, "marine") then
                marineBtn = obj
            end
        end
    end

    -- Kiểm tra tìm thấy chưa
    if not pirateBtn or not marineBtn then
        StarterGui:SetCore("SendNotification", {Title="❌ Không tìm thấy nút phe", Text="Thử chờ lâu hơn chút", Duration=3})
        return
    end

    -- Chọn ngẫu nhiên
    local chonHaiTac = math.random(1,2) == 1
    local btnChon = chonHaiTac and pirateBtn or marineBtn
    local tenPhe = chonHaiTac and "HẢI TẮC" or "HẢI QUÂN"

    -- Bấm & thông báo
    clickButton(btnChon)
    StarterGui:SetCore("SendNotification", {Title="✅ Đã chọn phe", Text=tenPhe, Duration=3})

    -- Dừng script
    task.wait(1)
    if script then script:Destroy() end
end

-- === BẮM NÚT CHẾ ĐỘ NHANH ===
task.spawn(function()
    repeat task.wait() until PlayerGui
    local quickBtn = nil

    -- Tìm nút Chế Độ Nhanh
    repeat
        for _, obj in pairs(PlayerGui:GetDescendants()) do
            if obj:IsA("TextButton") and string.find(string.lower(obj.Text), "chế độ nhanh") then
                quickBtn = obj
                break
            end
        end
        task.wait(0.3)
    until quickBtn

    -- Bấm nút chế độ nhanh
    clickButton(quickBtn)
    StarterGui:SetCore("SendNotification", {Title="⏳ Đã bấm Chế Độ Nhanh", Text="Đang chờ 10s...", Duration=2})

    -- Bắt đầu chờ rồi chọn phe
    task.spawn(pickRandomFaction)
end)
