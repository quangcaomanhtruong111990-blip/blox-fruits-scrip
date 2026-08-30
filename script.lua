-- GUI hiển thị trạng thái Race V4
local player = game.Players.LocalPlayer

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RaceV4StatusGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Tạo khung viền (Frame)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 330, 0, 60)
frame.Position = UDim2.new(0.5, -165, 0, 20) -- giữa màn hình, phía trên
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderSizePixel = 2
frame.Parent = screenGui

-- Label tên người chơi
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -20, 0.5, -5)
nameLabel.Position = UDim2.new(0, 10, 0, 5)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Text = "Tên: Đang tải..."
nameLabel.Parent = frame

-- Label trạng thái train
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0.5, -5)
statusLabel.Position = UDim2.new(0, 10, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Đơn: Đang kiểm tra..."
statusLabel.Parent = frame

-- Hàm kiểm tra Race V4
function CheckRaceV4Status()
	if not player.Character or not player.Character:FindFirstChild("RaceTransformed") then
		return "Bạn chưa thức tỉnh V4."
	end

	local status, current, fragment = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Check")

	if status == 1 or status == 3 then
		return "Bạn cần train thêm."
	elseif status == 2 or status == 4 or status == 7 then
		return "Có thể mua gear với " .. tostring(fragment) .. " mảnh."
	elseif status == 5 then
		return "Bạn đã hoàn thành Race V4."
	elseif status == 6 then
		return "Đã nâng cấp: " .. tostring(current - 2) .. "/3. Cần train thêm."
	elseif status == 8 then
		return "Còn " .. tostring(10 - current) .. " buổi train."
	elseif status == 0 then
		return "Sẵn sàng cho Trial."
	else
		return "Không đọc được dữ liệu"
	end
end

-- Hàm cập nhật GUI
function UpdateRaceV4GUI()
	nameLabel.Text = "Tên: " .. player.Name

	local success, result = pcall(CheckRaceV4Status)
	if success then
		statusLabel.Text = "Đơn: " .. result
	else
		statusLabel.Text = "Đơn: Không đọc được dữ liệu"
	end
end

-- Cập nhật ban đầu
UpdateRaceV4GUI()

-- Cập nhật tự động mỗi 10 giây
task.spawn(function()
	while true do
		wait(10)
		UpdateRaceV4GUI()
	end
end)
