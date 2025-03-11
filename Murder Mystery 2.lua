-- Kiểm tra ID map
if game.PlaceId ~= 142823291 then
    game.Players.LocalPlayer:Kick("⚠ Script không hoạt động cho map này!")
    return
end

local Executor = identifyexecutor and identifyexecutor() or "Unknown"
local BlacklistedExecutors = { "Solara", "Ronix", "Ghost", "Unknown" }

for _, exec in pairs(BlacklistedExecutors) do
    if Executor == exec then
        game.Players.LocalPlayer:Kick("⚠ Executor không được hỗ trợ!")
        return
    end
end

-- Tải thư viện Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Thông báo khi tải xong thư viện Fluent UI
Fluent:Notify({
    Title = "📚 Bước 1/4: Tải thư viện",
    Content = "Đã tải xong Fluent UI, SaveManager và InterfaceManager.",
    Duration = 2
})

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Tải danh sách ban từ URL
local BanData
local success, response = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/Chubedan3/TH/refs/heads/main/Ban", true)
end)

if success and response then
    local successLoad, data = pcall(function() return loadstring(response)() end)
    if successLoad and type(data) == "table" then
        BanData = data
    end
end

if not BanData then
    BanData = { BanVinhVien = {}, BanTamThoi = {} }
end

-- Thông báo khi tải xong danh sách ban
Fluent:Notify({
    Title = "🔒 Bước 2/4: Kiểm tra ban",
    Content = "Đã tải danh sách ban và kiểm tra trạng thái người chơi.",
    Duration = 2
})

-- Kiểm tra nếu người chơi bị ban
local function KiemTraBan()
    local UserID = LocalPlayer.UserId
    for _, ID in pairs(BanData.BanVinhVien) do
        if UserID == ID then
            LocalPlayer:Kick("🚫 Bạn đã bị ban vĩnh viễn khỏi Thanh Hub!")
            return true
        end
    end
    if BanData.BanTamThoi[UserID] then
        if os.time() < BanData.BanTamThoi[UserID] then
            LocalPlayer:Kick("⏳ Bạn bị ban tạm thời trong 1 ngày! Hãy thử lại sau.")
            return true
        else
            BanData.BanTamThoi[UserID] = nil
        end
    end
    return false
end

if KiemTraBan() then return end

-- Gửi Webhook
local WebhookURL = game:HttpGet("https://drive.google.com/uc?export=download&id=1wwR25jdkdz8iswuP0PV5Wis_BRX_-MhP")
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

local DanhSachNguoiChoi = {}
local function CapNhatDanhSachNguoiChoi()
    DanhSachNguoiChoi = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(DanhSachNguoiChoi, player.Name)
        end
    end
end

-- Khởi tạo GUI với Fluent UI
local Window = Fluent:CreateWindow({
    Title = "Thanh Hub | Murder Mystery 2 | v0.25",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 300),
    Acrylic = true,
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Thông báo khi khởi tạo xong GUI
Fluent:Notify({
    Title = "🖥️ Bước 3/4: Khởi tạo GUI",
    Content = "Cửa sổ Thanh Hub đã được tạo với giao diện đỏ nhạt.",
    Duration = 2
})

local Tabs = {
    CapNhat = Window:AddTab({ Title = "🆕 Cập Nhật", Icon = "refresh" }),
    Chinh = Window:AddTab({ Title = "🏠 Chính", Icon = "home" }),
    HienThi = Window:AddTab({ Title = "👁 Hiển Thị", Icon = "eye" }),
    NguoiChoi = Window:AddTab({ Title = "🧑 Người Chơi", Icon = "user" }),
    DichChuyen = Window:AddTab({ Title = "🗺 Dịch Chuyển", Icon = "map" }),
    ChienDau = Window:AddTab({ Title = "⚔ Chiến Đấu", Icon = "sword" }),
    CaiDat = Window:AddTab({ Title = "⚙ Cài Đặt", Icon = "settings" }),
    HoTro = Window:AddTab({ Title = "📩 Hỗ Trợ", Icon = "help-circle" })
}

local Options = Fluent.Options

-- Tab Cập Nhật
Tabs.CapNhat:AddParagraph({
    Title = "📜 Cập Nhật Mới 4/3/2025 - Thanh Hub Murder Mystery 2 (v0.25)",
    Content = "🔹 Update v0.25\n" ..
              "✔ Fix lỗi ban hệ thống – Đã khắc phục lỗi hệ thống ban nhầm người chơi.\n" ..
              "✔ Fix Shoot Murderer – Cải thiện độ chính xác và phản hồi nhanh hơn.\n\n" ..
              "🔹 🆕 Mục Update\n" ..
              "Thanh Hub giờ có mục cập nhật để bạn theo dõi những thay đổi mới nhất.\n\n" ..
              "🔹 ⚙ Chức năng mới\n" ..
              "✅ 👀 Hiển Thị Vai Trò Của Mình – Hiển thị vai trò khi xác định được.\n" ..
              "✅ ⏳ Hiển Thị Thời Gian Vòng Đấu – Theo dõi thời gian còn lại trong ván chơi.\n" ..
              "✅ 🔫 Hiển Thị Súng Rơi – Hiển thị vị trí súng bị rơi trong trận đấu.\n" ..
              "✅ 🚀 Tự động lấy súng rơi – Hỗ trợ tự động nhặt súng nếu có thể.\n\n" ..
              "💡 Bạn đã thử những tính năng mới này chưa? Hãy trải nghiệm ngay! 🚀"
})

-- Tab Chính
Tabs.Chinh:AddButton({
    Title = "📜 Mở Infinite Yield",
    Description = "Tải Infinite Yield script",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

-- Tab Hiển Thị
local VaiTroSection = Tabs.HienThi:AddSection("🚶 Vai Trò")
local roles = {}
local runningHighlight = false

local function CreateHighlight()
    for _, v in pairs(Players:GetChildren()) do
        if v ~= LocalPlayer and v.Character and not v.Character:FindFirstChild("Highlight") then
            Instance.new("Highlight", v.Character)
        end
    end
end

local function UpdateHighlights()
    if not runningHighlight then return end
    roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer() or roles
    for _, v in pairs(Players:GetChildren()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Highlight") then
            local highlight = v.Character.Highlight
            if v.Name == roles.Sheriff then
                highlight.FillColor = Color3.fromRGB(0, 0, 255)
            elseif v.Name == roles.Murderer then
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
            elseif v.Name == roles.Hero and not roles.Sheriff then
                highlight.FillColor = Color3.fromRGB(255, 250, 0)
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
            end
        end
    end
end

local function RemoveHighlights()
    for _, v in pairs(Players:GetChildren()) do
        if v.Character and v.Character:FindFirstChild("Highlight") then
            v.Character.Highlight:Destroy()
        end
    end
end

RunService.Heartbeat:Connect(function()
    if runningHighlight then UpdateHighlights() end
end)

VaiTroSection:AddToggle("HighlightVaiTro", {
    Title = "🔍 Hiển Thị Highlight Vai Trò",
    Default = false,
    Callback = function(state)
        runningHighlight = state
        if state then CreateHighlight() else RemoveHighlights() end
    end
})

local currentRole = ""
local runningRole = false
local roleLabel = Instance.new("TextLabel", Instance.new("ScreenGui", game.CoreGui))
roleLabel.Size = UDim2.new(0, 250, 0, 60)
roleLabel.Position = UDim2.new(0.5, -125, 0.4, 0)
roleLabel.Font = Enum.Font.SourceSansBold
roleLabel.TextSize = 36
roleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
roleLabel.BackgroundTransparency = 1
roleLabel.Visible = false

local function updateRoleDisplay()
    if not runningRole then roleLabel.Visible = false return end
    local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer() or roles
    if roles and roles[LocalPlayer.Name] then
        local newRole = roles[LocalPlayer.Name].Role
        if newRole ~= currentRole then
            currentRole = newRole
            roleLabel.Text = newRole
            roleLabel.TextColor3 = newRole == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                                   newRole == "Sheriff" and Color3.fromRGB(0, 0, 255) or 
                                   newRole == "Hero" and Color3.fromRGB(255, 215, 0) or 
                                   newRole == "Innocent" and Color3.fromRGB(0, 255, 0) or 
                                   Color3.fromRGB(255, 255, 255)
            roleLabel.Visible = true
            task.delay(5, function() if runningRole then roleLabel.Visible = false end end)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if runningRole then updateRoleDisplay() end
end)

VaiTroSection:AddToggle("HienThiVaiTro", {
    Title = "👀 Hiển Thị Vai Trò Của Mình",
    Default = false,
    Callback = function(state)
        runningRole = state
    end
})

local VanChoiSection = Tabs.HienThi:AddSection("🎮 Ván Chơi")
local runningRoundTimer = false
local timerText

local function secondsToMinutes(seconds)
    if not seconds or seconds < 0 then return "" end
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%dm %ds", minutes, remainingSeconds)
end

local function showRoundTimer()
    if not timerText then
        timerText = Instance.new("TextLabel", Instance.new("ScreenGui", game.CoreGui))
        timerText.BackgroundTransparency = 1
        timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerText.TextScaled = true
        timerText.AnchorPoint = Vector2.new(0.5, 0.5)
        timerText.Position = UDim2.fromScale(0.5, 0.15)
        timerText.Size = UDim2.fromOffset(180, 40)
        timerText.Font = Enum.Font.SourceSansBold
        timerText.TextSize = 24
        timerText.Visible = true
    end
    if not runningRoundTimer then timerText.Visible = false return end
    local success, timeLeft = pcall(function()
        return ReplicatedStorage.Remotes.Extras.GetTimer:InvokeServer()
    end)
    timerText.Text = success and secondsToMinutes(timeLeft) or "Không có dữ liệu thời gian"
    timerText.Visible = runningRoundTimer
end

RunService.Heartbeat:Connect(function()
    if runningRoundTimer then showRoundTimer() end
end)

VanChoiSection:AddToggle("HienThiThoiGian", {
    Title = "⏳ Hiển Thị Thời Gian Vòng Đấu",
    Default = false,
    Callback = function(state)
        runningRoundTimer = state
    end
})

local runningGunESP = false
local autoGetDroppedGun = false
local function showGunESP(gun)
    local gunesp = Instance.new("Highlight", gun)
    gunesp.OutlineTransparency = 1
    gunesp.FillColor = Color3.fromRGB(255, 255, 0)
    gunesp.Name = "GunESP"
    gunesp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    gunesp.Adornee = gun
    gunesp.Enabled = true
    local bguiclone = Instance.new("BillboardGui", gun)
    bguiclone.Size = UDim2.new(0, 100, 0, 50)
    bguiclone.StudsOffset = Vector3.new(0, 2, 0)
    bguiclone.AlwaysOnTop = true
    bguiclone.Name = "DGBGUIClone"
    local label = Instance.new("TextLabel", bguiclone)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextScaled = true
    label.Text = "Súng Rơi!"
end

Workspace.DescendantAdded:Connect(function(ch)
    if runningGunESP and ch.Name == "GunDrop" then
        showGunESP(ch)
        if autoGetDroppedGun then
            task.wait(1)
            if not ch or not ch:IsDescendantOf(Workspace) then return end
            local previousPosition = LocalPlayer.Character and LocalPlayer.Character:GetPivot()
            if previousPosition then
                LocalPlayer.Character:MoveTo(ch.Position)
                LocalPlayer.Backpack.ChildAdded:Wait()
                LocalPlayer.Character:PivotTo(previousPosition)
            end
        end
    end
end)

VanChoiSection:AddToggle("HienThiSungRoi", {
    Title = "🔫 Hiển Thị Súng Rơi",
    Default = false,
    Callback = function(state)
        runningGunESP = state
    end
})

VanChoiSection:AddToggle("TuDongLaySung", {
    Title = "🚀 Tự động lấy súng rơi",
    Default = false,
    Callback = function(state)
        autoGetDroppedGun = state
    end
})

-- Tab Người Chơi
Tabs.NguoiChoi:AddSlider("Walkspeed", {
    Title = "🏃‍♂️ Tốc Độ Di Chuyển",
    Description = "Điều chỉnh tốc độ di chuyển",
    Default = 16,
    Min = 16,
    Max = 300,
    Rounding = 1,
    Callback = function(value)
        getgenv().Walkspeed = value
    end
})

Tabs.NguoiChoi:AddSlider("Jumppower", {
    Title = "🦘 Độ Cao Nhảy",
    Description = "Điều chỉnh độ cao nhảy",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 1,
    Callback = function(value)
        getgenv().Jumppower = value
    end
})

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Walkspeed or 16
        LocalPlayer.Character.Humanoid.JumpPower = getgenv().Jumppower or 50
    end
end)

-- Tab Dịch Chuyển
local MM2Section = Tabs.DichChuyen:AddSection("🎭 Murder Mystery 2")
MM2Section:AddButton({
    Title = "🔪 Teleport đến Murder",
    Description = "Dịch chuyển đến người chơi có dao",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and (player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                return
            end
        end
        Fluent:Notify({ Title = "⚠ Không Tìm Thấy", Content = "Không tìm thấy Murder trong server!", Duration = 3 })
    end
})

local FMM2Section = Tabs.DichChuyen:AddSection("💲 Farm Murder Mystery 2")
FMM2Section:AddButton({
    Title = "💰 Tự Động Nhặt Xu",
    Description = "Tự động thu thập xu trong game",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Chubedan3/TH/refs/heads/main/Eotufem"))()
    end
})

CapNhatDanhSachNguoiChoi()
local DropdownTeleport = Tabs.DichChuyen:AddDropdown("TeleportNguoiChoi", {
    Title = "✈ Chọn người chơi để Teleport",
    Values = DanhSachNguoiChoi,
    Multi = false,
    Default = "",
    Callback = function(value)
        getgenv().NguoiChoiDaChon = value
    end
})

Tabs.DichChuyen:AddButton({
    Title = "🔍 Kiểm tra lại người chơi trong server",
    Description = "Làm mới danh sách người chơi",
    Callback = function()
        CapNhatDanhSachNguoiChoi()
        DropdownTeleport:SetValues(DanhSachNguoiChoi)
    end
})

Tabs.DichChuyen:AddButton({
    Title = "🚀 Teleport đến người chơi",
    Description = "Dịch chuyển đến người chơi đã chọn",
    Callback = function()
        local TargetPlayer = Players:FindFirstChild(getgenv().NguoiChoiDaChon)
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame
        else
            Fluent:Notify({ Title = "⚠ Lỗi", Content = "Không thể tìm thấy người chơi!", Duration = 3 })
        end
    end
})

-- Tab Chiến Đấu
local ChienDauSection = Tabs.ChienDau:AddSection("🎯 Chiến Đấu")
ChienDauSection:AddParagraph({
    Title = "🎯 Tỉ lệ bắn dính Murder (theo ping)",
    Content = "Ping 1000 đến 2000: 1%\nPing 500 đến 700: 34%\nPing 200 đến 400: 67%\nPing 100 đến 170: 86%\nPing 80 đến 90: 93%\nPing 40 đến 60: 100%"
})

local shootButton = Instance.new("TextButton", Instance.new("ScreenGui", game.CoreGui))
shootButton.Size = UDim2.new(0, 200, 0, 50)
shootButton.Position = UDim2.new(0.5, -100, 0.5, 0)
shootButton.Text = "Bắn Murderer"
shootButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
shootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shootButton.Font = Enum.Font.SourceSansBold
shootButton.TextSize = 20
shootButton.Visible = false
shootButton.Active = true

local dragging, dragInput, dragStart, startPos
local camera = Workspace.CurrentCamera

shootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = shootButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

shootButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        local screenSize = camera.ViewportSize
        newPos = UDim2.new(
            0, math.clamp(newPos.X.Offset, 0, screenSize.X - shootButton.AbsoluteSize.X),
            0, math.clamp(newPos.Y.Offset, 0, screenSize.Y - shootButton.AbsoluteSize.Y)
        )
        shootButton.Position = newPos
    end
end)

local function equipGun()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local gun = character:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    if gun and not character:FindFirstChild("Gun") then
        gun.Parent = character
        task.wait(0.2)
    end
    return character:FindFirstChild("Gun")
end

local function findMurderer()
    local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    for playerName, data in pairs(roles or {}) do
        if data.Role == "Murderer" and not data.Killed and not data.Dead then
            return Players:FindFirstChild(playerName)
        end
    end
    return nil
end

local function predictPosition(target)
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position + Vector3.new(0, 3, 0) end
    return nil
end

local function shootTarget(target)
    local predictedPosition = predictPosition(target)
    if not predictedPosition then return end
    local args = { [1] = 1, [2] = predictedPosition, [3] = "AH2" }
    LocalPlayer.Character.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
end

shootButton.MouseButton1Click:Connect(function()
    if not equipGun() then
        Fluent:Notify({ Title = "Lỗi", Content = "Bạn không có súng!", Duration = 5 })
        return
    end
    local murderer = findMurderer()
    if murderer then shootTarget(murderer)
    else Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy Murderer!", Duration = 5 }) end
end)

ChienDauSection:AddToggle("HienThiNutBan", {
    Title = "🎯 Hiển Thị Nút Bắn Murderer",
    Default = false,
    Callback = function(state)
        shootButton.Visible = state
    end
})

-- Tab Cài Đặt
local CaiDatSection = Tabs.CaiDat:AddSection("⚙ Cài Đặt")
CaiDatSection:AddButton({
    Title = "🔄 Tải Lại Máy Chủ",
    Description = "Tái tham gia server",
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Tab Hỗ Trợ
local HoTroSection = Tabs.HoTro:AddSection("📩 Hỗ Trợ")
HoTroSection:AddParagraph({
    Title = "Hãy nhập yêu cầu hoặc trợ giúp vào đây",
    Content = "Thanh Hub sẽ xem xét và cố gắng thực hiện hoặc sửa lỗi, lưu ý không gửi những tin nhắn bậy bạ vì nó sẽ được gửi cho Thanh Hub nếu không bạn sẽ bị ban khỏi Thanh Hub 1 ngày, spam bạn sẽ 5 tiếng"
})

local NoiDungYeuCau = ""
HoTroSection:AddInput("YeuCauInput", {
    Title = "📜 Nhập yêu cầu hoặc trợ giúp",
    Default = "",
    Placeholder = "Nhập nội dung...",
    Callback = function(value)
        NoiDungYeuCau = value
    end
})

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
    if DemSoLanGui[IDNguoiChoi].SoLan >= 60 then return false end
    DemSoLanGui[IDNguoiChoi].SoLan = DemSoLanGui[IDNguoiChoi].SoLan + 1
    return true
end

HoTroSection:AddButton({
    Title = "📨 Gửi Yêu Cầu",
    Description = "Gửi yêu cầu đến Thanh Hub",
    Callback = function()
        local NguoiChoi = LocalPlayer
        if not KiemTraGioiHan(NguoiChoi) then
            Fluent:Notify({ Title = "⛔ Bị Cấm", Content = "Bạn đã gửi quá 60 yêu cầu trong ngày!", Duration = 5 })
            return
        end
        if NoiDungYeuCau == "" then
            Fluent:Notify({ Title = "⚠ Lỗi", Content = "Bạn chưa nhập nội dung yêu cầu!", Duration = 3 })
            return
        end
        local WebhookURL = game:HttpGet("https://drive.google.com/uc?export=download&id=1wwDQluZHISyNgRUtBbxLjjFxcmHwprZS")
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
        local thanhCong = pcall(function()
            (http and http.request or syn and syn.request or request)({
                Url = WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = DuLieuJSON
            })
        end)
        if thanhCong then
            NoiDungYeuCau = ""
            Options.YeuCauInput:SetValue("")
        end
    end
})

-- Đảm bảo cập nhật Speed & Jump sau khi respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Walkspeed or 16
        LocalPlayer.Character.Humanoid.JumpPower = getgenv().Jumppower or 50
    end
end)

-- Hiển thị thông báo chào mừng
Fluent:Notify({
    Title = "🎉 Chào Mừng đến với Thanh Hub!",
    Content = "Chúc bạn chơi vui vẻ",
    Duration = 4
})

-- Cấu hình SaveManager và InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("ThanhHubConfig")
InterfaceManager:SetFolder("ThanhHubConfig")
SaveManager:BuildConfigSection(Tabs.CaiDat)
InterfaceManager:BuildInterfaceSection(Tabs.CaiDat)

-- Thông báo khi hoàn tất toàn bộ script
Fluent:Notify({
    Title = "✅ Bước 4/4: Hoàn tất",
    Content = "Thanh Hub đã sẵn sàng để sử dụng!",
    Duration = 3
})

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()