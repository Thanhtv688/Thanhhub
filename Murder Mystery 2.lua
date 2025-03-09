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

-- Chạy script Thanh Hub Murder Mystery 2 ngay lập tức
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
    Name = "Thanh Hub | Murder Mystery 2 | v0.25",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ThanhHubConfig",
    IntroEnabled = true,
    IntroText = "Thanh Hub Murder Mystery 2"
    Size = UDim2.new(0, 400, 0, 250),
    Draggable = true
})

local TabCapNhat = CuaSo:MakeTab({
    Name = "🆕 Cập Nhật",
    Icon = "rbxassetid://7734068321",
    PremiumOnly = false
})

TabCapNhat:AddParagraph("📜 <font color='rgb(0, 191, 255)'>Cập Nhật Mới 4/3/2025 - Thanh Hub Murder Mystery 2 (v0.25)</font>", 
    "🔹 <font color='rgb(0, 191, 255)'>Update v0.25</font>\n" ..
    "✔ <font color='rgb(255, 255, 0)'>Fix lỗi ban hệ thống</font> – Đã khắc phục lỗi hệ thống ban nhầm người chơi.\n" ..
    "✔ <font color='rgb(255, 255, 0)'>Fix Shoot Murderer</font> – Cải thiện độ chính xác và phản hồi nhanh hơn.\n\n" ..
    
    "🔹 <font color='rgb(0, 191, 255)'>🆕 Mục Update</font>\n" ..
    "<font color='rgb(255, 105, 180)'>Thanh Hub giờ có mục cập nhật</font> để bạn theo dõi những thay đổi mới nhất.\n\n" ..
    
    "🔹 <font color='rgb(0, 191, 255)'>⚙ Chức năng mới</font>\n" ..
    "✅ <font color='rgb(0, 255, 0)'>👀 Hiển Thị Vai Trò Của Mình</font> – Hiển thị vai trò khi xác định được.\n" ..
    "✅ <font color='rgb(0, 255, 0)'>⏳ Hiển Thị Thời Gian Vòng Đấu</font> – Theo dõi thời gian còn lại trong ván chơi.\n" ..
    "✅ <font color='rgb(0, 255, 0)'>🔫 Hiển Thị Súng Rơi</font> – Hiển thị vị trí súng bị rơi trong trận đấu.\n" ..
    "✅ <font color='rgb(0, 255, 0)'>🚀 Tự động lấy súng rơi</font> – Hỗ trợ tự động nhặt súng nếu có thể.\n\n" ..
    
    "💡 Bạn đã thử những tính năng mới này chưa? Hãy trải nghiệm ngay! 🚀"
)

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

local VaiTro1 = TabHienThi:AddSection({
	Name = "🚶Vai Trò"
})

-- Highlight Vai Trò
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local roles = {}
local runningHighlight = false

local function CreateHighlight()
    for i, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and not v.Character:FindFirstChild("Highlight") then
            Instance.new("Highlight", v.Character)
        end
    end
end

local function UpdateHighlights()
    for _, v in pairs(Players:GetChildren()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Highlight") then
            local highlight = v.Character:FindFirstChild("Highlight")
            if v.Name == roles.Sheriff then
                highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Xanh dương
            elseif v.Name == roles.Murderer then
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Đỏ
            elseif v.Name == roles.Hero and not roles.Sheriff then
                highlight.FillColor = Color3.fromRGB(255, 250, 0) -- Vàng
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Xanh lá
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

local function HighlightLoop()
    while runningHighlight do
        roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
        for i, v in pairs(roles) do
            if v.Role == "Murderer" then
                roles.Murderer = i
            elseif v.Role == "Sheriff" then
                roles.Sheriff = i
            elseif v.Role == "Hero" then
                roles.Hero = i
            end
        end
        CreateHighlight()
        UpdateHighlights()
        task.wait(1)
    end
    RemoveHighlights()
end

-- Nút bật/tắt Highlight trong Orion UI
VaiTro1:AddToggle({
    Name = "🔍 Hiển Thị Highlight Vai Trò",
    Default = false,
    Callback = function(state)
        runningHighlight = state
        if runningHighlight then
            task.spawn(HighlightLoop)
        else
            RemoveHighlights()
        end
    end
})

-- Hiển Thị Vai Trò Của Mình
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local currentRole = ""
local runningRole = false

-- Tạo GUI hiển thị vai trò
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local roleLabel = Instance.new("TextLabel")
roleLabel.Parent = ScreenGui
roleLabel.Size = UDim2.new(0, 250, 0, 60)
roleLabel.Position = UDim2.new(0.5, -125, 0.4, 0)
roleLabel.Font = Enum.Font.SourceSansBold
roleLabel.TextSize = 36
roleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
roleLabel.BackgroundTransparency = 1
roleLabel.Visible = false

local function updateRoleDisplay()
    while runningRole do
        local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
        if roles and roles[LP.Name] then
            local newRole = roles[LP.Name].Role
            if newRole ~= currentRole then
                currentRole = newRole
                roleLabel.Text = newRole
                roleLabel.TextColor3 = newRole == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                                       newRole == "Sheriff" and Color3.fromRGB(0, 0, 255) or 
                                       newRole == "Hero" and Color3.fromRGB(255, 215, 0) or 
                                       newRole == "Innocent" and Color3.fromRGB(0, 255, 0) or 
                                       Color3.fromRGB(255, 255, 255)
                roleLabel.Visible = true
                task.wait(5)
                roleLabel.Visible = false
            end
        end
        task.wait(1)
    end
    roleLabel.Visible = false
end

-- Nút bật/tắt hiển thị vai trò trong Orion UI
VaiTro1:AddToggle({
    Name = "👀 Hiển Thị Vai Trò Của Mình",
    Default = false,
    Callback = function(state)
        runningRole = state
        if runningRole then
            task.spawn(updateRoleDisplay)
        else
            roleLabel.Visible = false
        end
    end
})

local VanChoi1 = TabHienThi:AddSection({
	Name = "🎮 Ván Chơi"
})

-- Hiển Thị Thời Gian Vòng Chơi
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runningRoundTimer = false
local timerText
local timerTask

-- Chuyển đổi giây thành phút và giây
local function secondsToMinutes(seconds)
    if not seconds or seconds < 0 then return "" end
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%dm %ds", minutes, remainingSeconds)
end

local function showRoundTimer()
    if not timerText then
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game.CoreGui

        timerText = Instance.new("TextLabel")
        timerText.Parent = ScreenGui
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

    if not timerTask then
        timerTask = task.spawn(function()
            while runningRoundTimer do
                local success, timeLeft = pcall(function()
                    return ReplicatedStorage.Remotes.Extras.GetTimer:InvokeServer()
                end)
                
                if success and timeLeft then
                    timerText.Text = secondsToMinutes(timeLeft)
                else
                    timerText.Text = "Không có dữ liệu thời gian"
                end
                task.wait(0.5)
            end
            timerText.Visible = false
        end)
    end
end

VanChoi1:AddToggle({
    Name = "⏳ Hiển Thị Thời Gian Vòng Đấu",
    Default = false,
    Callback = function(state)
        runningRoundTimer = state
        if runningRoundTimer then
            showRoundTimer()
        else
            if timerText then
                timerText.Visible = false
            end
            if timerTask then
                task.cancel(timerTask)
                timerTask = nil
            end
        end
    end
})

-- Hiển Thị & Tương Tác Với Súng Rơi
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local runningGunESP = false
local autoGetDroppedGun = false

-- Hiển thị highlight khi súng rơi
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

-- Khi súng xuất hiện
workspace.DescendantAdded:Connect(function(ch)
    if runningGunESP and ch.Name == "GunDrop" then
        showGunESP(ch)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Thông báo",
            Text = "Súng đã rơi! Được đánh dấu màu vàng.",
            Duration = 5
        })
        
        if autoGetDroppedGun then
            task.wait(1)
            if not ch or not ch:IsDescendantOf(workspace) then return end
            local previousPosition = LP.Character:GetPivot()
            LP.Character:MoveTo(ch.Position)
            LP.Backpack.ChildAdded:Wait()
            LP.Character:PivotTo(previousPosition)
        end
    end
end)

-- Khi súng bị nhặt
workspace.DescendantRemoving:Connect(function(ch)
    if runningGunESP and ch.Name == "GunDrop" then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Thông báo",
            Text = "Súng đã bị nhặt.",
            Duration = 5
        })
    end
end)

-- Toggle hiển thị súng rơi
VanChoi1:AddToggle({
    Name = "🔫 Hiển Thị Súng Rơi",
    Default = false,
    Callback = function(state)
        runningGunESP = state
    end
})

-- Toggle tự động lấy súng rơi
VanChoi1:AddToggle({
    Name = "🚀 Tự động lấy súng rơi",
    Default = false,
    Callback = function(state)
        autoGetDroppedGun = state
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

TabChienDau:AddParagraph("🎯 Tỉ lệ bắn dính Murder <font color='rgb(255,105,180)'>(theo ping)</font>", 
    "Ping <font color='rgb(0,0,255)'>1000 đến 2000</font>: <font color='rgb(255,0,0)'>1%</font>\n" ..
    "Ping <font color='rgb(0,0,255)'>500 đến 700</font>: <font color='rgb(255,255,0)'>34%</font>\n" ..
    "Ping <font color='rgb(0,0,255)'>200 đến 400</font>: <font color='rgb(255,255,0)'>67%</font>\n" ..
    "Ping <font color='rgb(0,0,255)'>100 đến 170</font>: <font color='rgb(0,255,0)'>86%</font>\n" ..
    "Ping <font color='rgb(0,0,255)'>80 đến 90</font>: <font color='rgb(0,255,0)'>93%</font>\n" ..
    "Ping <font color='rgb(0,0,255)'>40 đến 60</font>: <b><font color='rgb(0,255,0)'>100%</font></b>\n"
)

-- Tạo GUI chứa nút
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local shootButton = Instance.new("TextButton")
shootButton.Parent = ScreenGui
shootButton.Size = UDim2.new(0, 200, 0, 50)
shootButton.Position = UDim2.new(0.5, -100, 0.5, 0)
shootButton.Text = "Bắn Murderer"
shootButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
shootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shootButton.Font = Enum.Font.SourceSansBold
shootButton.TextSize = 20
shootButton.Visible = false
shootButton.Active = true

local runningShootToggle = false

-- Cho phép kéo nút mà không bị lỗi xê dịch
local dragging, dragInput, dragStart, startPos
local UIS = game:GetService("UserInputService")
local camera = game:GetService("Workspace").CurrentCamera

shootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = shootButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
        
        -- Giới hạn nút trong màn hình
        local screenSize = camera.ViewportSize
        newPos = UDim2.new(
            0, math.clamp(newPos.X.Offset, 0, screenSize.X - shootButton.AbsoluteSize.X),
            0, math.clamp(newPos.Y.Offset, 0, screenSize.Y - shootButton.AbsoluteSize.Y)
        )
        shootButton.Position = newPos
    end
end)

-- Kiểm tra nếu có súng và trang bị nó
local function equipGun()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local backpack = player:FindFirstChild("Backpack")
    local gun = character:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    
    if gun and not character:FindFirstChild("Gun") then
        gun.Parent = character -- Trang bị súng từ balo
        task.wait(0.2) -- Chờ súng được trang bị
    end
    
    return character:FindFirstChild("Gun")
end

-- Xác định kẻ sát nhân (Murderer) từ server
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local function findMurderer()
    local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    for playerName, data in pairs(roles) do
        if data.Role == "Murderer" and not data.Killed and not data.Dead then
            return game.Players:FindFirstChild(playerName)
        end
    end
    return nil
end

-- Dự đoán vị trí bắn chính xác
local function predictPosition(target)
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        return hrp.Position + Vector3.new(0, 3, 0) -- Bắn cao hơn để tránh trượt
    end
    return nil
end

-- Thực hiện bắn Murderer
local function shootTarget(target)
    local predictedPosition = predictPosition(target)
    if not predictedPosition then return end
    
    local args = {
        [1] = 1,
        [2] = predictedPosition,
        [3] = "AH2"
    }
    game.Players.LocalPlayer.Character.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
end

-- Khi nhấn nút, kiểm tra và bắn Murderer
shootButton.MouseButton1Click:Connect(function()
    if not equipGun() then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Lỗi",
            Text = "Bạn không có súng!",
            Duration = 5
        })
        return
    end
    
    local murderer = findMurderer()
    if murderer then
        shootTarget(murderer)
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Lỗi",
            Text = "Không tìm thấy Murderer!",
            Duration = 5
        })
    end
end)

-- Nút bật/tắt hiển thị nút bắn Murderer
TabChienDau:AddToggle({
    Name = "🎯 Hiển Thị Nút Bắn Murderer",
    Default = false,
    Callback = function(state)
        runningShootToggle = state
        shootButton.Visible = state
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