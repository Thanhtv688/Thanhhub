--[[
    Thanh Hub Murder Mystery 2 (2)

 :3
]]

--------------------------------------------------------------------------------------R3THPRIV----------------------------------------------------------------------------------------
repeat wait() until game:IsLoaded()

if Key == nil then
    getgenv().Key = "Thanh Hub"
end

local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
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
        print("[ " .. Key .. " ]: " .. message)
    end
    if type == true or type == nil then
        if R3TH_Device == "Mobile" then
            StarterGui:SetCore("SendNotification", {
                Title = Key;
                Text = message;
                Duration = 7;
            })
        else
            Notification:Notify(
                {Title = Key, Description = message},
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

sendnotification("Loader executed.", false)

--------------------------------------------------------------------------------------SUPPORTCHECK----------------------------------------------------------------------------------------
local function getGlobal(path)
	local value = getfenv(0)

	while value ~= nil and path ~= "" do
		local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
		value = value[name]
		path = nextValue
	end

	return value
end

local function SetSupport(name, support)
    local target = (support == "Supported") and "Supported" or "Unsupported"
    
    if name == "hookfunction" then
        getgenv().R3TH_hookfunction = target
    elseif name == "getnamecallmethod" then
        getgenv().R3TH_getnamecallmethod = target
    elseif name == "Drawing.new" then
        getgenv().R3TH_Drawingnew = target
    end
end

local function test(name, aliases, callback)
	task.spawn(function()
		if not callback then
            SetSupport(name, "Supported")
			sendnotification("⏺️ " .. name, false)
		elseif not getGlobal(name) then
            SetSupport(name, "Unsupported")
			sendnotification("⛔ " .. name, false)
		else
			local success, message = pcall(callback)
	
			if success then
                SetSupport(name, "Supported")
				sendnotification("✅ " .. name .. (message and " • " .. message or ""), false)
			else
                SetSupport(name, "Unsupported")
				sendnotification("⛔ " .. name .. " failed: " .. message, false)
			end
		end
	
		local undefinedAliases = {}
	
		for _, alias in ipairs(aliases) do
			if getGlobal(alias) == false then
				table.insert(undefinedAliases, alias)
			end
		end
	
		if #undefinedAliases > 0 then
            SetSupport(name, "Unsupported")
			sendnotification("⚠️ " .. table.concat(undefinedAliases, ", "), false)
		end

	end)
end

if games[game.PlaceId] ~= "Total%20Roblox%20Drama" then
    test("hookfunction", {"replaceclosure"}, function()
        local function test()
            return true
        end
        local ref = hookfunction(test, function()
            return false
        end)
        assert(test() == false, "Function should return false")
        assert(ref() == true, "Original function should return true")
        assert(test ~= ref, "Original function should not be same as the reference")
    end)
    
    test("getnamecallmethod", {}, function()
        local method
        local ref
        ref = hookmetamethod(game, "__namecall", function(...)
            if not method then
                method = getnamecallmethod()
            end
            return ref(...)
        end)
        game:GetService("Lighting")
        assert(method == "GetService", "Did not get the correct method (GetService)")
    end)
end

test("Drawing.new", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = false
	local canDestroy = pcall(function()
		drawing:Destroy()
	end)
	assert(canDestroy, "Drawing:Destroy() should not throw an error")
end)

--------------------------------------------------------------------------------------LOADER----------------------------------------------------------------------------------------
getgenv().R3TH_Device = Touchscreen and "Mobile" or "PC"
sendnotification(R3TH_Device .. " detected.", false)

sendnotification("Script loading, this may take a while depending on your device.", nil)

if games[game.PlaceId] then
    sendnotification("Game Supported!", false)
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Thanhtv688/Thanhhub' .. games[game.PlaceId] .. '.lua'))()
else
    sendnotification("Game not Supported.", false)
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Thanhtv688/Thanhhub/main/Troll%20Vi%E1%BB%87t%20Nam'))()
end
