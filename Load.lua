--[[
    Thanh Hub LOADER SOURCE
:3
]]

--------------------------------------------------------------------------------------R3THPRIV----------------------------------------------------------------------------------------
repeat wait() until game:IsLoaded()

local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()
local StarterGui = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")
local Touchscreen = UIS.TouchEnabled

local games = {
    [142823291] = 'Murder%20Mystery%202',
    [335132309] = 'Murder%20Mystery%202',
    [636649648] = 'Murder%20Mystery%202',
}

function sendnotification(message, type)
    if type == false or type == nil then
        print("[ Thanh Hub ]: " .. message)
    end
    if type == true or type == nil then
        if R3TH_Device == "Mobile" then
            StarterGui:SetCore("SendNotification", {
                Title = "Thanh Hub";
                Text = message;
                Duration = 7;
            })
        else
            Notification:Notify(
                {Title = "Thanh Hub", Description = message},
                {OutlineColor = Color3.fromRGB(80, 80, 80),Time = 7, Type = "default"}
            )
        end
    end
end

if getgenv().r3thexecuted then
    sendnotification("Script already executed, if you're having any problems join discord.gg/pethicial for support.", nil)
    return
end
getgenv().r3thexecuted = true

print("[ Thanh Hub ]: Thanh Hub Loader executed.")

--------------------------------------------------------------------------------------LOADER----------------------------------------------------------------------------------------
getgenv().R3TH_Device = Touchscreen and "Mobile" or "PC"
sendnotification(R3TH_Device .. " detected.", false)

getgenv().R3TH_Hook = (type(hookmetamethod) == "function" and type(getnamecallmethod) == "function") and "Supported" or "Unsupported"
sendnotification("Hook method is " .. R3TH_Hook .. ".", false)

getgenv().R3TH_Drawing = (type(Drawing.new) == "function") and "Supported" or "Unsupported"
sendnotification("Drawing.new is " .. R3TH_Drawing .. ".", false)

sendnotification("Script loading, this may take a while depending on your device.", nil)

if games[game.PlaceId] then
    sendnotification("Game Supported!", false)
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Thanhtv688/' .. games[game.PlaceId] .. '.lua'))()
else
    sendnotification("Game not Supported.", false)
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Thanhtv688/Thanhhub/main/Troll%20Vi%E1%BB%87t%20Nam'))()
end