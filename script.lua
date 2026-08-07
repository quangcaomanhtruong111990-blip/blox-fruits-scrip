-- Tải thư viện Fluent UI (Hoạt động tốt trên Android)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Tạo cửa sổ Menu
local Window = Fluent:CreateWindow({
    Title = "Menu Script Android",
    SubTitle = "by Thành",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

-- Tạo Tab
local Tabs = {
    Main = Window:AddTab({ Title = "Chính", Icon = "home" })
}

-- Tạo Nút bấm
Tabs.Main:AddButton({
    Title = "Hiển thị thông báo",
    Description = "Bấm để kiểm tra script",
    Callback = function()
        Fluent:Notify({
            Title = "Thành công!",
            Content = "Script chạy mượt mà trên Android!",
            Duration = 5
        })
    end
})

-- Chọn mặc định Tab chính
Window:SelectTab(1)
