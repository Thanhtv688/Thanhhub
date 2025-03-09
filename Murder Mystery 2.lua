local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Xác định múi giờ Việt Nam (GMT+7)
local function getVietnamTime()
    return os.time() + (7 * 3600) -- Chuyển đổi sang múi giờ GMT+7
end

-- Thời gian bảo trì kết thúc (17:00 giờ Việt Nam)
local maintenanceEndTime = os.time({
    year = os.date("*t", getVietnamTime()).year,
    month = os.date("*t", getVietnamTime()).month,
    day = os.date("*t", getVietnamTime()).day,
    hour = 17, -- 5 giờ chiều
    min = 0,
    sec = 0
}) - (7 * 3600) -- Chuyển đổi về UTC

-- Hàm tính thời gian đếm ngược
local function getRemainingTime()
    local remaining = maintenanceEndTime - os.time()
    if remaining <= 0 then
        return "Bảo trì đã kết thúc!"
    else
        local hours = math.floor(remaining / 3600)
        local minutes = math.floor((remaining % 3600) / 60)
        local seconds = remaining % 60
        return string.format("Bảo trì sẽ kết thúc sau: %02d giờ %02d phút %02d giây", hours, minutes, seconds)
    end
end

-- Kiểm tra và kick người chơi
if os.time() < maintenanceEndTime then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Thanh Hub Bảo Trì",
        Text = getRemainingTime(),
        Duration = 5
    })
    
    wait(3) -- Chờ trước khi kick
    LocalPlayer:Kick("Thanh Hub đang bảo trì.\n" .. getRemainingTime())
end
