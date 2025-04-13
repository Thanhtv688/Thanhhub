-- Tải thư viện Fluent UI
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaCrack/Library/78b99523c0413609a998e34bc3dda1328f25f63e/LibraryFluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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

Fluent:Notify({
    Title = "Thanh Hub",
    Content = "Đang tải..",
    Duration = 5
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
    BanData = loadstring(response)() or { BanVinhVien = {}, BanTamThoi = {} }
else
    BanData = { BanVinhVien = {}, BanTamThoi = {} }
end

-- Kiểm tra nếu người chơi bị ban
local function KiemTraBan()
    local UserID = LocalPlayer.UserId
    for _, ID in ipairs(BanData.BanVinhVien) do
        if UserID == ID then
            LocalPlayer:Kick("🚫 Bạn đã bị ban vĩnh viễn khỏi Thanh Hub!")
            return true
        end
    end
    if BanData.BanTamThoi[UserID] and os.time() < BanData.BanTamThoi[UserID] then
        LocalPlayer:Kick("⏳ Bạn bị ban tạm thời trong 1 ngày! Hãy thử lại sau.")
        return true
    elseif BanData.BanTamThoi[UserID] then
        BanData.BanTamThoi[UserID] = nil
    end
    return false
end

if KiemTraBan() then return end

-- Gửi Webhook (chỉ chạy một lần)
local WebhookURL = game:HttpGet("https://drive.google.com/uc?export=download&id=1wwR25jdkdz8iswuP0PV5Wis_BRX_-MhP")
local function sendWebhook()
    local httpRequest = http and http.request or syn and syn.request or request
    if httpRequest then
        local data = {
            ["username"] = "Thanh Hub Webhook",
            ["embeds"] = {{
                ["title"] = "🔍 Kiểm tra người chơi (từ Murder Mystery 2)",
                ["description"] = "**Tên người chơi:** " .. LocalPlayer.Name ..  
                                 "\n**ID:** " .. LocalPlayer.UserId ..  
                                 "\n**Executor:** " .. Executor,
                ["color"] = 16776960,
                ["thumbnail"] = { ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png" }
            }}
        }
        pcall(function()
            httpRequest({
                Url = WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(data)
            })
        end)
    end
end
spawn(sendWebhook)

-- Khởi tạo GUI với Fluent UI (Theme mặc định: Rose)
local Window = Fluent:CreateWindow({
    Title = "Thanh Hub | Murder Mystery 2 | v0.3",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 300),
    Acrylic = false,
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.LeftControl
})
Fluent:SetTheme("Rose")

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
    Title = "📜 Cập Nhật Mới 13/4/2025 - v0.3",
    Content = "🔹 Update v0.3: Thêm nút bấm bật/tắt GUI, Fix lỗi hiển thị highlight vai trò.\n🔹 Chức năng mới\n + Giết tất cả (khi làm Murder).\n + Speed glitch (khi vừa chạy vừa nhảy sẽ tăng tốc theo mức điều chỉnh).\n + 📛 ESP Vai Trò Bằng Tên Người Chơi"
})

-- Tab Chính
Tabs.Chinh:AddButton({
    Title = "📜 Mở Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

-- Tab Hiển Thị
local VaiTroSection = Tabs.HienThi:AddSection("🚶 Vai Trò")
local roles = {}
local runningHighlight = false
local highlightConnection

-- ESP Tên Người Chơi
local runningNameESP = false
local nameESPConnections = {}
local defaultHighlightColor = Color3.fromRGB(128, 128, 128) -- Màu xám mặc định

-- Hàm tạo BillboardGui hiển thị tên
local function CreateNameESP(player)
    if player ~= LocalPlayer and player.Character and not player.Character:FindFirstChild("NameESP") then
        local head = player.Character:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "NameESP"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 100, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = defaultHighlightColor
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.Parent = billboard
        end
    end
end

-- Hàm xóa tất cả BillboardGui
local function RemoveNameESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local billboard = head:FindFirstChild("NameESP")
                if billboard then
                    billboard:Destroy()
                end
            end
        end
    end
end

-- Hàm cập nhật màu tên liên tục
local function UpdateNameESP()
    local success, roleData = pcall(function()
        return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    end)
    if not success or not roleData then
        -- Nếu không lấy được dữ liệu, đặt màu xám
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local billboard = player.Character.Head:FindFirstChild("NameESP")
                if billboard then
                    billboard.TextLabel.TextColor3 = defaultHighlightColor
                end
            end
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Tạo NameESP nếu chưa có
            if not player.Character.Head:FindFirstChild("NameESP") and runningNameESP then
                CreateNameESP(player)
            end
            -- Cập nhật màu theo vai trò
            local billboard = player.Character.Head:FindFirstChild("NameESP")
            if billboard then
                local playerRole = roleData[player.Name] and roleData[player.Name].Role
                billboard.TextLabel.TextColor3 = playerRole == "Murderer" and Color3.fromRGB(255, 0, 0) or
                                                playerRole == "Sheriff" and Color3.fromRGB(0, 0, 255) or
                                                playerRole == "Hero" and Color3.fromRGB(255, 250, 0) or
                                                playerRole == "Innocent" and Color3.fromRGB(0, 255, 0) or
                                                defaultHighlightColor
            end
        end
    end
end

-- Toggle ESP Vai Trò Bằng Tên
VaiTroSection:AddToggle("NameESPToggle", {
    Title = "📛 ESP Vai Trò Bằng Tên Người Chơi",
    Default = false,
    Callback = function(state)
        runningNameESP = state
        if state then
            -- Tạo NameESP cho tất cả người chơi hiện tại
            for _, player in pairs(Players:GetPlayers()) do
                CreateNameESP(player)
            end
            -- Cập nhật liên tục mỗi frame
            nameESPConnections.main = RunService.Heartbeat:Connect(function()
                if runningNameESP then
                    pcall(UpdateNameESP)
                end
            end)
            -- Theo dõi người chơi mới và hồi sinh
            nameESPConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
                if runningNameESP then
                    player.CharacterAdded:Connect(function()
                        task.wait(0.1) -- Đợi nhân vật tải
                        CreateNameESP(player)
                    end)
                end
            end)
        else
            -- Ngắt kết nối và xóa NameESP
            for _, connection in pairs(nameESPConnections) do
                connection:Disconnect()
            end
            nameESPConnections = {}
            RemoveNameESP()
        end
    end
})

-- Hàm tạo Highlight
local function CreateHighlight(player)
    if player ~= LocalPlayer then
        -- Xóa Highlight cũ nếu có
        if player.Character and player.Character:FindFirstChild("RoleHighlight") then
            player.Character.RoleHighlight:Destroy()
        end
        -- Tạo Highlight mới
        if player.Character then
            local highlight = Instance.new("Highlight", player.Character)
            highlight.Name = "RoleHighlight"
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.FillColor = defaultHighlightColor
        end
        -- Theo dõi hồi sinh
        player.CharacterAdded:Connect(function(character)
            task.wait(0.1) -- Đợi nhân vật tải
            if runningHighlight then
                local highlight = Instance.new("Highlight", character)
                highlight.Name = "RoleHighlight"
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.FillColor = defaultHighlightColor
            end
        end)
    end
end

-- Hàm cập nhật Highlight liên tục
local function UpdateHighlights()
    local success, roleData = pcall(function()
        return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    end)
    if not success or not roleData then 
        -- Nếu không lấy được dữ liệu, đặt màu xám
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("RoleHighlight") then
                player.Character.RoleHighlight.FillColor = defaultHighlightColor
            end
        end
        return 
    end
    roles = roleData

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Tạo Highlight nếu chưa có
            if not player.Character:FindFirstChild("RoleHighlight") and runningHighlight then
                local highlight = Instance.new("Highlight", player.Character)
                highlight.Name = "RoleHighlight"
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.FillColor = defaultHighlightColor
            end
            -- Cập nhật màu theo vai trò
            if player.Character:FindFirstChild("RoleHighlight") then
                local highlight = player.Character.RoleHighlight
                local playerRole = roles[player.Name] and roles[player.Name].Role
                highlight.FillColor = playerRole == "Murderer" and Color3.fromRGB(255, 0, 0) or
                                      playerRole == "Sheriff" and Color3.fromRGB(0, 0, 255) or
                                      playerRole == "Hero" and Color3.fromRGB(255, 250, 0) or
                                      playerRole == "Innocent" and Color3.fromRGB(0, 255, 0) or
                                      defaultHighlightColor
            end
        end
    end
end

-- Toggle Highlight Vai Trò
VaiTroSection:AddToggle("HighlightVaiTro", {
    Title = "🔍 Hiển Thị Highlight Vai Trò",
    Default = false,
    Callback = function(state)
        runningHighlight = state
        if state then
            -- Tạo Highlight cho tất cả người chơi hiện tại
            for _, player in pairs(Players:GetPlayers()) do
                CreateHighlight(player)
            end
            -- Cập nhật liên tục mỗi frame
            highlightConnection = RunService.Heartbeat:Connect(function()
                if runningHighlight then
                    pcall(UpdateHighlights)
                end
            end)
            -- Theo dõi người chơi mới
            Players.PlayerAdded:Connect(function(player)
                if runningHighlight then
                    CreateHighlight(player)
                end
            end)
        else
            -- Ngắt kết nối và xóa Highlight
            if highlightConnection then 
                highlightConnection:Disconnect() 
                highlightConnection = nil 
            end
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("RoleHighlight") then
                    player.Character.RoleHighlight:Destroy()
                end
            end
        end
    end
})

local runningRole = false
local roleLabel = Instance.new("TextLabel", Instance.new("ScreenGui", game.CoreGui))
roleLabel.Size = UDim2.new(0, 250, 0, 60)
roleLabel.Position = UDim2.new(0.5, -125, 0.4, 0)
roleLabel.Font = Enum.Font.SourceSansBold
roleLabel.TextSize = 36
roleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
roleLabel.BackgroundTransparency = 1
roleLabel.Visible = false
local roleConnection

local function updateRoleDisplay()
    local success, roleData = pcall(function()
        return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    end)
    if success and roleData and roleData[LocalPlayer.Name] then
        local newRole = roleData[LocalPlayer.Name].Role
        if newRole and newRole ~= roleLabel.Text then
            roleLabel.Text = newRole
            roleLabel.TextColor3 = newRole == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                                   newRole == "Sheriff" and Color3.fromRGB(0, 0, 255) or 
                                   newRole == "Hero" and Color3.fromRGB(255, 215, 0) or 
                                   Color3.fromRGB(0, 255, 0)
            roleLabel.Visible = true
            task.delay(5, function() if runningRole then roleLabel.Visible = false end end)
        end
    end
end

VaiTroSection:AddToggle("HienThiVaiTro", {
    Title = "👀 Hiển Thị Vai Trò Của Mình",
    Default = false,
    Callback = function(state)
        runningRole = state
        if state then
            roleConnection = RunService.RenderStepped:Connect(function()
                if runningRole then
                    task.spawn(function()
                        task.wait(1) -- Cập nhật mỗi 1 giây để giảm tải
                        pcall(updateRoleDisplay)
                    end)
                end
            end)
        else
            if roleConnection then roleConnection:Disconnect() end
            roleLabel.Visible = false
        end
    end
})

local VanChoiSection = Tabs.HienThi:AddSection("🎮 Ván Chơi")
local runningRoundTimer = false
local timerText = Instance.new("TextLabel", Instance.new("ScreenGui", game.CoreGui))
timerText.BackgroundTransparency = 1
timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
timerText.TextScaled = true
timerText.AnchorPoint = Vector2.new(0.5, 0.5)
timerText.Position = UDim2.fromScale(0.5, 0.15)
timerText.Size = UDim2.fromOffset(180, 40)
timerText.Font = Enum.Font.SourceSansBold
timerText.TextSize = 24
timerText.Visible = false
local timerConnection

local function secondsToMinutes(seconds)
    if not seconds or seconds < 0 then return "N/A" end
    return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
end

local function showRoundTimer()
    local success, timeLeft = pcall(function()
        return ReplicatedStorage.Remotes.Extras.GetTimer:InvokeServer()
    end)
    timerText.Text = success and secondsToMinutes(timeLeft) or "N/A"
    timerText.Visible = runningRoundTimer
end

VanChoiSection:AddToggle("HienThiThoiGian", {
    Title = "⏳ Hiển Thị Thời Gian Vòng Đấu",
    Default = false,
    Callback = function(state)
        runningRoundTimer = state
        if state then
            timerConnection = RunService.RenderStepped:Connect(function()
                if runningRoundTimer then
                    task.spawn(function()
                        task.wait(1) -- Cập nhật mỗi 1 giây
                        pcall(showRoundTimer)
                    end)
                end
            end)
        else
            if timerConnection then timerConnection:Disconnect() end
            timerText.Visible = false
        end
    end
})

local runningGunESP = false
local autoGetDroppedGun = false
local gunESPConnection

local function showGunESP(gun)
    local gunesp = Instance.new("Highlight", gun)
    gunesp.OutlineTransparency = 1
    gunesp.FillColor = Color3.fromRGB(255, 255, 0)
    gunesp.Name = "GunESP"
    gunesp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    gunesp.Adornee = gun
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

VanChoiSection:AddToggle("HienThiSungRoi", {
    Title = "🔫 Hiển Thị Súng Rơi",
    Default = false,
    Callback = function(state)
        runningGunESP = state
        if state then
            gunESPConnection = Workspace.DescendantAdded:Connect(function(ch)
                if runningGunESP and ch.Name == "GunDrop" then
                    showGunESP(ch)
                    if autoGetDroppedGun and LocalPlayer.Character then
                        task.spawn(function()
                            task.wait(1)
                            if ch and ch:IsDescendantOf(Workspace) then
                                local prevPos = LocalPlayer.Character:GetPivot()
                                LocalPlayer.Character:MoveTo(ch.Position)
                                LocalPlayer.Backpack.ChildAdded:Wait()
                                LocalPlayer.Character:PivotTo(prevPos)
                            end
                        end)
                    end
                end
            end)
        else
            if gunESPConnection then gunESPConnection:Disconnect() end
        end
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
    Default = 16,
    Min = 16,
    Max = 300,
    Rounding = 1,
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
        getgenv().Walkspeed = value
    end
})

Tabs.NguoiChoi:AddSlider("Jumppower", {
    Title = "🦘 Độ Cao Nhảy",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 1,
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
        getgenv().Jumppower = value
    end
})

-- Tab Dịch Chuyển
local MM2Section = Tabs.DichChuyen:AddSection("🎭 Murder Mystery 2")
MM2Section:AddButton({
    Title = "🔪 Teleport đến Murder",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and (player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                return
            end
        end
        Fluent:Notify({ Title = "⚠ Không Tìm Thấy", Content = "Không tìm thấy người có dao!", Duration = 3 })
    end
})

MM2Section:AddButton({
    Title = "🔫 Teleport Đến Sheriff",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and (player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun")) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                return
            end
        end
        Fluent:Notify({ Title = "⚠ Không Tìm Thấy", Content = "Không tìm thấy người có súng!", Duration = 3 })
    end
})

local FMM2Section = Tabs.DichChuyen:AddSection("💲 Farm Murder Mystery 2")
FMM2Section:AddButton({
    Title = "💰 Tự Động Nhặt Xu",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Chubedan3/TH/refs/heads/main/Eotufem"))()
    end
})

local DanhSachNguoiChoi = {}
local function CapNhatDanhSachNguoiChoi()
    DanhSachNguoiChoi = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(DanhSachNguoiChoi, player.Name)
        end
    end
end
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
    Title = "🔍 Kiểm tra lại người chơi",
    Callback = function()
        CapNhatDanhSachNguoiChoi()
        DropdownTeleport:SetValues(DanhSachNguoiChoi)
    end
})

Tabs.DichChuyen:AddButton({
    Title = "🚀 Teleport đến người chơi",
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
-- Thêm vào Tab Chiến Đấu hoặc Tab Tiện Ích của Thanh Hub
local ChienDauSection = Tabs.ChienDau:AddSection("🎯 Tăng Tốc (Speed Glitch)") -- Có thể đổi sang tab khác nếu muốn

-- Biến toàn cục
local defaultSpeed = 16 -- Tốc độ mặc định trong MM2
local glitchSpeed = 50 -- Tốc độ mặc định khi bật glitch
local isGlitchEnabled = false
local speedConnection = nil

-- Hàm kiểm tra trạng thái di chuyển và nhảy
local function isMovingAndJumping()
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return false end
    local humanoid = character.Humanoid
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    -- Kiểm tra nhảy (JumpState) và di chuyển (Velocity lớn hơn ngưỡng nhỏ)
    local isJumping = humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall
    local isMoving = rootPart.Velocity.Magnitude > 1 -- Ngưỡng để xác định di chuyển
    return isJumping and isMoving
end

-- Hàm cập nhật tốc độ
local function updateSpeed()
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    local humanoid = character.Humanoid

    if isGlitchEnabled and isMovingAndJumping() then
        humanoid.WalkSpeed = glitchSpeed
    else
        humanoid.WalkSpeed = defaultSpeed
    end
end

-- Ô nhập tốc độ
ChienDauSection:AddInput("GlitchSpeedInput", {
    Title = "Tốc Độ Glitch",
    Default = tostring(glitchSpeed),
    Placeholder = "Nhập tốc độ (ví dụ: 50)",
    Numeric = true, -- Chỉ cho phép số
    Callback = function(value)
        local newSpeed = tonumber(value)
        if newSpeed and newSpeed > 0 then
            glitchSpeed = newSpeed
            Fluent:Notify({ Title = "Đã Cập Nhật", Content = "Tốc độ glitch đặt thành: " .. glitchSpeed, Duration = 3 })
        else
            Fluent:Notify({ Title = "Lỗi", Content = "Vui lòng nhập số hợp lệ!", Duration = 5 })
        end
    end
})

-- Toggle bật/tắt Auto Speed Glitch
ChienDauSection:AddToggle("AutoSpeedGlitchToggle", {
    Title = "Bật Auto Speed Glitch",
    Default = false,
    Callback = function(state)
        isGlitchEnabled = state
        if state then
            -- Bật vòng lặp kiểm tra tốc độ
            speedConnection = game:GetService("RunService").Heartbeat:Connect(updateSpeed)
            Fluent:Notify({ Title = "Đã Bật", Content = "Auto Speed Glitch đã được kích hoạt!", Duration = 3 })
        else
            -- Tắt vòng lặp và khôi phục tốc độ mặc định
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = defaultSpeed
            end
            Fluent:Notify({ Title = "Đã Tắt", Content = "Auto Speed Glitch đã được tắt!", Duration = 3 })
        end
    end
})

-- Đảm bảo tốc độ được khôi phục khi nhân vật respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if not isGlitchEnabled then return end
    task.wait(1) -- Đợi nhân vật tải xong
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = defaultSpeed -- Đặt lại tốc độ mặc định ban đầu
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = game:GetService("RunService").Heartbeat:Connect(updateSpeed)
    end
end)

-- Dịch vụ và biến toàn cục
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Hàm Kill All
local function KillAll()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Fluent:Notify({
            Title = "Lỗi",
            Content = "Nhân vật của bạn chưa tải!",
            Duration = 3
        })
        return
    end

    local knife = LocalPlayer.Backpack:FindFirstChild("Knife")
    if knife then
        knife.Parent = LocalPlayer.Character
    else
        Fluent:Notify({
            Title = "Cảnh báo",
            Content = "Không tìm thấy dao trong ba lô!",
            Duration = 3
        })
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, false, 0)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, false, 0)
            task.wait(0.5)
        end
    end

    Fluent:Notify({
        Title = "Thành công",
        Content = "Đã thực thi Kill All!",
        Duration = 3
    })
end

local MurderSection = Tabs.ChienDau:AddSection("🔪 Murder")
-- Thêm nút "Kill All" vào tab Main
MurderSection:AddButton({
    Title = "Giết Tất Cả",
    Description = "Giết tất cả người chơi khác bằng dao",
    Callback = function()
        KillAll()
    end
})

local ChienDauSection = Tabs.ChienDau:AddSection("🎯 Chiến Đấu")
ChienDauSection:AddParagraph({
    Title = "🎯 Tỉ lệ bắn dính Murder (theo ping)",
    Content = "Ping 40-60: 100%\nPing 80-90: 93%\nPing 100-170: 86%\nPing 200-400: 67%\nPing 500-700: 34%\nPing 1000-2000: 1%"
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
        local screenSize = Workspace.CurrentCamera.ViewportSize
        shootButton.Position = UDim2.new(
            0, math.clamp(newPos.X.Offset, 0, screenSize.X - shootButton.AbsoluteSize.X),
            0, math.clamp(newPos.Y.Offset, 0, screenSize.Y - shootButton.AbsoluteSize.Y)
        )
    end
end)

local function equipGun()
    local character = LocalPlayer.Character
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
end

local function shootTarget(target)
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
        LocalPlayer.Character.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, hrp.Position + Vector3.new(0, 3, 0), "AH2")
    end
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
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Tab Hỗ Trợ
local HoTroSection = Tabs.HoTro:AddSection("📩 Hỗ Trợ")
HoTroSection:AddParagraph({
    Title = "Hỗ Trợ",
    Content = "Nhập yêu cầu, tránh spam hoặc nội dung không phù hợp để không bị ban."
})

local NoiDungYeuCau = ""
HoTroSection:AddInput("YeuCauInput", {
    Title = "📜 Nhập yêu cầu",
    Placeholder = "Nhập nội dung...",
    Callback = function(value)
        NoiDungYeuCau = value
    end
})

local DemSoLanGui = {}
local ThoiGianHienTai = os.date("*t")
local function KiemTraGioiHan()
    local ID = LocalPlayer.UserId
    if not DemSoLanGui[ID] then DemSoLanGui[ID] = { SoLan = 0, Ngay = ThoiGianHienTai.day } end
    if DemSoLanGui[ID].Ngay ~= ThoiGianHienTai.day then
        DemSoLanGui[ID] = { SoLan = 0, Ngay = ThoiGianHienTai.day }
    end
    if DemSoLanGui[ID].SoLan >= 60 then return false end
    DemSoLanGui[ID].SoLan += 1
    return true
end

HoTroSection:AddButton({
    Title = "📨 Gửi Yêu Cầu",
    Callback = function()
        if not KiemTraGioiHan() then
            Fluent:Notify({ Title = "⛔ Bị Cấm", Content = "Quá 60 yêu cầu/ngày!", Duration = 5 })
            return
        end
        if NoiDungYeuCau == "" then
            Fluent:Notify({ Title = "⚠ Lỗi", Content = "Chưa nhập nội dung!", Duration = 3 })
            return
        end
        local WebhookURL = game:HttpGet("https://drive.google.com/uc?export=download&id=1wwDQluZHISyNgRUtBbxLjjFxcmHwprZS")
        local data = {
            ["username"] = "Thanh Hub Webhook",
            ["embeds"] = {{
                ["title"] = "📩 Yêu Cầu Mới Từ: " .. LocalPlayer.Name .. " (ID: " .. LocalPlayer.UserId .. ")",
                ["description"] = NoiDungYeuCau,
                ["color"] = 16711680,
                ["thumbnail"] = { ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png" }
            }}
        }
        pcall(function()
            (http and http.request or syn and syn.request or request)({
                Url = WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(data)
            })
        end)
        NoiDungYeuCau = ""
        Options.YeuCauInput:SetValue("")
    end
})

-- Cấu hình SaveManager và InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("ThanhHubConfig")
InterfaceManager:SetFolder("ThanhHubConfig")
SaveManager:IgnoreThemeSettings()
InterfaceManager:BuildInterfaceSection(Tabs.CaiDat)

local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local guiName = "CustomScreenGui"

-- Lưu vị trí cuối cùng
local savedPosition = UDim2.new(0.300, -96, 0.300, -72) -- Vị trí mặc định ban đầu

local function createGUI()
    -- Xoá GUI cũ nếu còn
    local old = playerGui:FindFirstChild(guiName)
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = guiName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local Button = Instance.new("ImageButton")
    Button.Name = "CustomButton"
    Button.Parent = ScreenGui
    Button.Size = UDim2.new(0, 50, 0, 50)
    Button.Position = savedPosition
    Button.BackgroundTransparency = 1
    Button.Image = "rbxassetid://17764595132"

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Button

    -- Dù ảnh có lỗi hay không, không làm mất nút
    pcall(function()
        ContentProvider:PreloadAsync({Button.Image})
    end)

    -- Kéo nút
    local dragging, dragInput, dragStart, startPos
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Button.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            Button.Position = newPos
            savedPosition = newPos -- Cập nhật vị trí mới nhất
        end
    end)

    -- Click
    Button.MouseButton1Click:Connect(function()
        local vim = game:GetService("VirtualInputManager")
        if vim then
            task.defer(function()
                vim:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end)
        end
    end)
end

-- Tạo lần đầu
createGUI()

-- Nếu chết thì tạo lại
player.CharacterAdded:Connect(function()
    task.wait(1)
    createGUI()
end)

-- Luôn kiểm tra nếu GUI bị xóa → tạo lại
task.spawn(function()
    while true do
        task.wait(3)
        if not playerGui:FindFirstChild(guiName) then
            createGUI()
        end
    end
end)

-- Thông báo khởi động
Fluent:Notify({
    Title = "✅ Thanh Hub Đã Sẵn Sàng",
    Content = "Highlight Vai Trò đã được sửa!",
    Duration = 3
})

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
