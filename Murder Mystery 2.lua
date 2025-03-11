local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Xác định múi giờ Việt Nam (GMT+7)
local function getVietnamTime()
    return os.time() + (7 * 3600)
end

-- Thời gian kick (19:15 tối hôm nay, giờ Việt Nam)
local kickTime = os.time({
    year = os.date("*t", getVietnamTime()).year,
    month = os.date("*t", getVietnamTime()).month,
    day = os.date("*t", getVietnamTime()).day,
    hour = 19,
    min = 15,
    sec = 0
}) - (7 * 3600)

-- Hàm đếm ngược thời gian
local function getRemainingTime()
    local remaining = kickTime - os.time()
    if remaining <= 0 then
        return "Bảo trì đã kết thúc!"
    else
        local minutes = math.floor(remaining / 60)
        local seconds = remaining % 60
        return string.format("Bảo trì sẽ kết thúc sau: %02d phút %02d giây", minutes, seconds)
    end
end

-- Kiểm tra và kick người chơi
if os.time() < kickTime then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Thanh Hub Bảo Trì",
        Text = getRemainingTime(),
        Duration = 5
    })
    
    wait(3)
    LocalPlayer:Kick("Thanh Hub đang bảo trì.\n" .. getRemainingTime())
end
