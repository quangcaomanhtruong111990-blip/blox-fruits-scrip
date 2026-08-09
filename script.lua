local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui", 15)
local VirtualInput = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- === HÀM BẤM CHUỘT THẬT VÀO VỊ TRÍ ĐỐI TƯỢNG ===
local function clickOnObject(obj)
    if not obj then return false end
    -- Lấy vị trí trung tâm trên màn hình
    local pos, onScreen = obj:IsDescendantOf(workspace) and 
        workspace.CurrentCamera:WorldToViewportPoint(obj.Position) or 
        obj.AbsolutePosition + obj.AbsoluteSize/2
    
    if not onScreen or pos.Z < 0 then return false end

    -- Di chuyển chuột + bấm trái + nhả ra
    VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)  -- Nhấn xuống
    task.wait(0.05)
    VirtualInput:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1) -- Nhả ra
    return true
end

-- === CHỜ GIAO DIỆN HIỆN RÕ RÀNG RỒI CHỌN PHE ===
local function waitAndChooseFaction()
    StarterGui:SetCore("SendNotification", {Title="⏳ Đang chờ giao diện chọn phe...", Duration=3})
    
    -- Chờ đến khi thấy cả 2 phe xuất hiện, không chỉ chờ cố định 10s
    local pirateObj, marineObj = nil, nil
    repeat
        pirateObj, marineObj = nil, nil
        for _, obj in pairs(PlayerGui:GetDescendants()) do
            if obj:IsA("GuiObject") and obj.Visible and obj.Enabled then
                local ten = string.lower(obj.Name.." "..tostring(obj.Text or ""))
                if string.find(ten, "hải tặc") then pirateObj = obj end
                if string.find(ten, "hải quân") then marineObj = obj end
            end
        end
        task.wait(0.3)
    until pirateObj and marineObj

    -- Chờ thêm chút cho tương tác hoạt động
    task.wait(1.5)

    -- Chọn ngẫu nhiên 1 bên
    local chonPirate = math.random() > 0.5
    local chon = chonPirate and pirateObj or marineObj
    local tenPhe = chonPirate and "HẢI TẮC" or "HẢI QUÂN"

    -- Bấm bằng tọa độ chuột thật
    local ok = clickOnObject(chon)
    if ok then
        StarterGui:SetCore("SendNotification", {Title="✅ Đã chọn phe", Text=tenPhe, Duration=3})
    else
        StarterGui:SetCore("SendNotification", {Title="⚠️ Thử cách bấm phụ", Text="Đang cố gắng bấm lại...", Duration=2})
        -- Cách dự phòng: kích hoạt trực tiếp
        pcall(function() if chon:IsA("Button") then chon:Activate() end end)
    end

    -- Dừng hoàn toàn
    task.wait(1)
    if script then script:Destroy() end
end

-- === TÌM & BẤM CHẾ ĐỘ NHANH ===
task.spawn(function()
    repeat task.wait() until PlayerGui
    local quickBtn = nil

    -- Tìm nút chế độ nhanh cho đến khi thấy
    repeat
        quickBtn = nil
        for _, obj in pairs(PlayerGui:GetDescendants()) do
            if obj:IsA("TextButton") and obj.Visible and obj.Enabled and 
               string.find(string.lower(obj.Text), "chế độ nhanh") then
                quickBtn = obj
                break
            end
        end
        task.wait(0.3)
    until quickBtn

    -- Bấm chế độ nhanh bằng chuột thật
    clickOnObject(quickBtn)
    StarterGui:SetCore("SendNotification", {Title="✅ Đã bấm Chế Độ Nhanh", Text="Đang chờ vào giao diện chọn phe", Duration=2})

    -- Bắt đầu luồng chờ chọn phe
    task.spawn(waitAndChooseFaction)
end)
