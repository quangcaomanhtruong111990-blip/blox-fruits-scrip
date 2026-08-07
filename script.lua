-- Tải thư viện Giao diện (Orion Library)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Tạo cửa sổ Menu
local Window = OrionLib:MakeWindow({
    Name = "Menu Script Android", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "OrionTest"
})

-- Tạo Tab chức năng
local MainTab = Window:MakeTab({
    Name = "Chính",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Tạo nút bấm (Button)
MainTab:AddButton({
    Name = "Hiển thị thông báo",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Thành công!",
            Content = "Bạn đã chạy script trên Android!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end    
})

-- Khởi tạo Menu
OrionLib:Init()
