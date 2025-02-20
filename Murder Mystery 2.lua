local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- **📌 Tải danh sách ban từ URL**
local BanData
local success, response = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/Chubedan3/TH/refs/heads/main/Ban", true)
end)

if success and response then
    local successLoad, data = pcall(loadstring(response))
    if successLoad and type(data) == "table" then
        BanData = data
    end
end

if not BanData then
    BanData = { BanVinhVien = {}, BanTamThoi = {} }
end

-- **🛑 Kiểm tra nếu người chơi bị ban**
local function KiemTraBan()
    local UserID = LocalPlayer.UserId

    for _, ID in pairs(BanData.BanVinhVien) do
        if UserID == ID then
            LocalPlayer:Kick("🚫 Bạn đã bị ban vĩnh viễn khỏi Thanh Hub!")
            return
        end
    end

    if BanData.BanTamThoi[UserID] then
        if os.time() < BanData.BanTamThoi[UserID] then
            LocalPlayer:Kick("⏳ Bạn bị ban tạm thời trong 1 ngày! Hãy thử lại sau.")
            return
        else
            BanData.BanTamThoi[UserID] = nil
        end
    end
end

KiemTraBan()

-- **📌 Kiểm tra người dùng và gửi Webhook**
local WebhookURL = "https://discord.com/api/webhooks/1339200430579908619/pj8_QCHfvDXJgW2j0sJadTXByc5vn5X0LMFnilsdqszYHdAHPbedmaACJhdwdnKbtvY6"
local Executor = identifyexecutor and identifyexecutor() or "Không xác định"
local TenNguoiChoi = LocalPlayer.Name
local IDNguoiChoi = LocalPlayer.UserId
local AvatarURL = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. IDNguoiChoi .. "&width=420&height=420&format=png"

local DuLieu = {
    ["username"] = "Thanh Hub Webhook",
    ["embeds"] = {{
        ["title"] = "🔍 Kiểm tra người chơi (từ Murder Mystery 2)",
        ["description"] = "**Tên người chơi:** " .. TenNguoiChoi ..  
                         "\n**ID:** " .. IDNguoiChoi ..  
                         "\n**Executor:** " .. Executor,
        ["color"] = 16776960,
        ["thumbnail"] = { ["url"] = AvatarURL }
    }}
}

local function sendRequest(data)
    local httpRequest = http and http.request or syn and syn.request or request
    if httpRequest then
        httpRequest({
            Url = WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end
end

pcall(function() sendRequest(DuLieu) end)

local function CapNhatDanhSachNguoiChoi()
    DanhSachNguoiChoi = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(DanhSachNguoiChoi, player.Name)
        end
    end
    OrionLib:MakeNotification({
        Name = "✅ Đã Cập Nhật",
        Content = "Danh sách người chơi đã được làm mới!",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

-- **📌 Khởi tạo GUI**
local CuaSo = OrionLib:MakeWindow({
    Name = "Thanh Hub | Murder Mystery 2 | v0.2 | Việt Nam",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ThanhHubConfig",
    IntroEnabled = false,
    Size = UDim2.new(0, 400, 0, 250),
    Draggable = true
})

-- **🏠 Tab Chính**
local TabChinh = CuaSo:MakeTab({ Name = "🏠 Chính", Icon = "rbxassetid://4483345998" })
TabChinh:AddButton({
    Name = "📜 Mở Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

-- **👁 Tab Hiển Thị (ESP, NoClip)**
local TabHienThi = CuaSo:MakeTab({ Name = "👁 Hiển Thị", Icon = "rbxassetid://4483345998" })
TabHienThi:AddButton({
    Name = "🔍 ESP Murder/Sheriff",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Ihaveash0rtnamefordiscord/Releases/main/MurderMystery2HighlightESP"))()
    end
})

-- **🧑 Tab Người Chơi (Speed, Jump)**
local TabNguoiChoi = CuaSo:MakeTab({ Name = "🧑 Người Chơi", Icon = "rbxassetid://4483345998" })
TabNguoiChoi:AddSlider({
    Name = "🏃‍♂️ Tốc Độ Di Chuyển",
    Min = 16,
    Max = 300,
    Default = 16,
    Callback = function(value)
        getgenv().Walkspeed = value
    end
})

TabNguoiChoi:AddSlider({
    Name = "🦘 Độ Cao Nhảy",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(value)
        getgenv().Jumppower = value
    end
})

game:GetService("RunService").Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Walkspeed or 16
        LocalPlayer.Character.Humanoid.JumpPower = getgenv().Jumppower or 50
    end
end)

local TabDichChuyen = CuaSo:MakeTab({ Name = "🗺 Dịch Chuyển", Icon = "rbxassetid://4483345998" })

-- **🗺 Mục "Murder Mystery 2" trong Tab Dịch Chuyển**
local TabMM2 = TabDichChuyen:AddSection({ Name = "🎭 Murder Mystery 2" })

-- **🎯 Teleport đến Murder (Người có Knife)**
TabMM2:AddButton({
    Name = "🔪 Teleport đến Murder",
    Callback = function()
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                return
            end
        end
        OrionLib:MakeNotification({
            Name = "⚠ Không Tìm Thấy",
            Content = "Không tìm thấy Murder trong server!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- **🗺 Dropdown chọn người chơi**
local DanhSachNguoiChoi = {}
CapNhatDanhSachNguoiChoi() -- Cập nhật danh sách khi mở tab

local TabFMM2 = TabDichChuyen:AddSection({ Name = "💲Farm Murder Mystery 2" })

-- **🗺 Tab Dịch Chuyển (Auto Farm Xu)**
TabFMM2:AddButton({
    Name = "💰 Tự Động Nhặt Xu",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Chubedan3/TH/refs/heads/main/Eotufem"))()
    end
})

TabDichChuyen:AddDropdown({
    Name = "✈ Chọn người chơi để Teleport",
    Options = DanhSachNguoiChoi,
    Callback = function(value)
        getgenv().NguoiChoiDaChon = value
    end
})

-- **🔄 Nút kiểm tra lại danh sách người chơi**
TabDichChuyen:AddButton({
    Name = "🔍 Kiểm tra lại người chơi trong server",
    Callback = function()
        CapNhatDanhSachNguoiChoi()
    end
})

-- **🚀 Nút Teleport đến người chơi đã chọn**
TabDichChuyen:AddButton({
    Name = "🚀 Teleport đến người chơi",
    Callback = function()
        local TargetPlayer = game.Players:FindFirstChild(getgenv().NguoiChoiDaChon)
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame
        else
            OrionLib:MakeNotification({
                Name = "⚠ Lỗi",
                Content = "Không thể tìm thấy người chơi!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- **⚔ Tab Chiến Đấu (Shoot Murderer)**
local TabChienDau = CuaSo:MakeTab({ Name = "⚔ Chiến Đấu", Icon = "rbxassetid://4483345998" })
TabChienDau:AddButton({
    Name = "🔫 Tạo Nút Bắn Murderer",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Chubedan3/TH/refs/heads/main/chatgpt%20nh%C6%B0%20l.txt"))()
    end
})

-- **⚙ Tab Cài Đặt (Rejoin, FPS Cap)**
local TabCaiDat = CuaSo:MakeTab({ Name = "⚙ Cài Đặt", Icon = "rbxassetid://4483345998" })
TabCaiDat:AddButton({
    Name = "🔄 Tải Lại Máy Chủ",
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})

local TabHoTro = CuaSo:MakeTab({ Name = "📩 Yêu Cầu/Trợ Giúp", Icon = "rbxassetid://4483345998" })
TabHoTro:AddParagraph("Hãy nhập yêu cầu hoặc trợ giúp vào đây", "Thanh Hub sẽ xem xét và cố gắng thực hiện hoặc sửa lỗi, lưu ý không gửi những tin nhắn bậy bạ vì nó sẽ được gửi cho Thanh Hub nếu không bạn sẽ bị ban khỏi Thanh Hub 1 ngày, spam bạn sẽ 5 tiếng")

local NoiDungYeuCau = ""
TabHoTro:AddTextbox({
    Name = "📜 Nhập yêu cầu hoặc trợ giúp",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        NoiDungYeuCau = value
    end
})

-- **🛑 Hệ thống đếm số lần gửi hỗ trợ**
local DemSoLanGui = {}
local ThoiGianHienTai = os.date("*t")

local function KiemTraGioiHan(NguoiChoi)
    local IDNguoiChoi = NguoiChoi.UserId
    if not DemSoLanGui[IDNguoiChoi] then
        DemSoLanGui[IDNguoiChoi] = { SoLan = 0, Ngay = ThoiGianHienTai.day }
    end

    if DemSoLanGui[IDNguoiChoi].Ngay ~= ThoiGianHienTai.day then
        DemSoLanGui[IDNguoiChoi].SoLan = 0
        DemSoLanGui[IDNguoiChoi].Ngay = ThoiGianHienTai.day
    end

    if DemSoLanGui[IDNguoiChoi].SoLan >= 60 then
        return false
    end

    DemSoLanGui[IDNguoiChoi].SoLan = DemSoLanGui[IDNguoiChoi].SoLan + 1
    return true
end

TabHoTro:AddButton({
    Name = "📨 Gửi Yêu Cầu",
    Callback = function()
        local NguoiChoi = game.Players.LocalPlayer
        if not KiemTraGioiHan(NguoiChoi) then
            OrionLib:MakeNotification({
                Name = "⛔ Bị Cấm",
                Content = "Bạn đã gửi quá 60 yêu cầu trong ngày!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
            return
        end

        if NoiDungYeuCau == "" then
            OrionLib:MakeNotification({
                Name = "⚠ Lỗi",
                Content = "Bạn chưa nhập nội dung yêu cầu!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end

        local WebhookURL = "https://discord.com/api/webhooks/1289150124655775775/ipZnrqaXb8cPG3aFmz39d0CAXm2NGX7-RdS-xXev6UZkB-h6qYLYUZ0Gl0KQhNOE6yhU"
        local TenNguoiChoi = NguoiChoi.Name
        local IDNguoiChoi = NguoiChoi.UserId
        local AvatarURL = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. IDNguoiChoi .. "&width=420&height=420&format=png"

        local DuLieu = {
            ["username"] = "Thanh Hub Webhook",
            ["embeds"] = {{
                ["title"] = "📩 Yêu Cầu Mới Từ: " .. TenNguoiChoi .. " (ID: " .. IDNguoiChoi .. ") (từ Murder Mystery 2)",
                ["description"] = NoiDungYeuCau,
                ["color"] = 16711680,
                ["thumbnail"] = { ["url"] = AvatarURL }
            }}
        }
        local DuLieuJSON = HttpService:JSONEncode(DuLieu)

        local thanhCong, phanHoi = pcall(function()
            return http.request({
                Url = WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = DuLieuJSON
            })
        end)

        if thanhCong then
            OrionLib:MakeNotification({
                Name = "✅ Thành Công",
                Content = "Yêu cầu đã được gửi!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            NoiDungYeuCau = "" -- Xóa nội dung sau khi gửi
        else
            OrionLib:MakeNotification({
                Name = "❌ Lỗi",
                Content = "Không thể gửi yêu cầu! (Discord Webhook có thể bị chặn)",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

-- **🔄 Đảm bảo cập nhật Speed & Jump sau khi respawn**
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait(1) -- Đợi nhân vật load
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Walkspeed or 16
        LocalPlayer.Character.Humanoid.JumpPower = getgenv().Jumppower or 50
    end
end)

-- **🔄 Kiểm tra Speed & Jump liên tục**
game:GetService("RunService").Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Walkspeed or 16
        LocalPlayer.Character.Humanoid.JumpPower = getgenv().Jumppower or 50
    end
end)

-- **🔥 Hiển thị thông báo chào mừng khi bật script**
local function ChayThongBao()
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 400, 0, 100)
    Frame.Position = UDim2.new(0.5, -200, 0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.5

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Text = "🎉 Chào Mừng đến với Thanh Hub!"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 24

    wait(2)
    Label.Text = "Chúc bạn chơi vui vẻ"
    wait(2)
    ScreenGui:Destroy()
end
ChayThongBao()

-- **🔥 Khởi động giao diện GUI**
OrionLib:Init()
