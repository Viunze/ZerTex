if game.PlaceId ~= 10449761463 then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ ZerTex",
        Text = "This script only works in The Strongest Battlegrounds!",
        Duration = 5
    })
    task.wait(1.5)
    game:Shutdown()
    return
end

-- Load Rayfield
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("❌ Failed to load Rayfield UI.")
    return
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Script states
local target = nil
local autofarm, camlock = false, false

-- Functions
function TeleportBehind(plr)
    local me = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local enemy = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if me and enemy then
        local pos = enemy.CFrame * CFrame.new(0, 0, 2)
        me.CFrame = CFrame.lookAt(pos.Position, enemy.Position)
    end
end

function RoughCamlock(plr)
    local enemy = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if enemy then
        local targetPos = enemy.Position
        local camPos = cam.CFrame.Position
        cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(camPos, targetPos), 0.25)
    end
end

-- Loops
RunService.RenderStepped:Connect(function()
    if target then
        if autofarm then TeleportBehind(target) end
        if camlock then RoughCamlock(target) end
    end
end)

-- UI Build
local Window = Rayfield:CreateWindow({
    Name = "ZerTex | TSB",
    LoadingTitle = "ZerTex by Vinzee",
    LoadingSubtitle = "Rayfield UI Activated",
    ConfigurationSaving = {
        Enabled = false
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateInput({
    Name = "🎯 Target Name",
    PlaceholderText = "Enter username here",
    RemoveTextAfterFocusLost = true,
    Callback = function(input)
        local found = Players:FindFirstChild(input)
        if found then
            target = found
            Rayfield:Notify({
                Title = "✅ Target Locked",
                Content = "Now tracking: " .. input,
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "❌ Not Found",
                Content = "No player named: " .. input,
                Duration = 4
            })
        end
    end
})

MainTab:CreateToggle({
    Name = "⚔️ Start Kill",
    CurrentValue = false,
    Callback = function(state)
        autofarm = state
    end
})

MainTab:CreateToggle({
    Name = "🎥 Camlock Target",
    CurrentValue = false,
    Callback = function(state)
        camlock = state
    end
})

-- Tools Tab
local ToolsTab = Window:CreateTab("🛠️ Tools", 4483362458)

-- Target ESP Variables
local targetESPEnabled = false
local allESPEnabled = false
local espObjects = {}

-- ESP Function
local function highlightChar(char, color)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:FindFirstChild("ESPHighlight") then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "ESPHighlight"
            box.Adornee = part
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Size = part.Size
            box.Transparency = 0.6
            box.Color3 = color
            box.Parent = part
            table.insert(espObjects, box)
        end
    end
end

-- Clear ESP
local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
end

-- ESP by Username
ToolsTab:CreateInput({
    Name = "👤 Target Username for ESP",
    PlaceholderText = "Enter username (case-sensitive)",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        clearESP()
        local player = game.Players:FindFirstChild(value)
        if player and player.Character then
            highlightChar(player.Character, Color3.fromRGB(255, 85, 0)) -- orange
        end
    end,
})

-- Stop ESP Target Button
ToolsTab:CreateButton({
    Name = "🔴 Stop ESP Target",
    Callback = function()
        clearESP()
        print("[ZeESP] Target ESP stopped and cleared.")
    end
})

-- ESP All Players
ToolsTab:CreateToggle({
    Name = "🎃 ESP All Players",
    CurrentValue = false,
    Callback = function(state)
        allESPEnabled = state
        clearESP()
        if state then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    highlightChar(player.Character, Color3.fromRGB(0, 255, 0)) -- green
                end
            end
        end
    end
})

-- FPS Booster
ToolsTab:CreateButton({
    Name = "🚀 Boost FPS",
    Callback = function()
        setfpscap(30)
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 0
        game:GetService("Terrain").WaterWaveSize = 0
        game:GetService("Terrain").WaterWaveSpeed = 0
        game:GetService("Terrain").WaterReflectance = 0
        game:GetService("Terrain").WaterTransparency = 0

        -- Meninggalkan tangan karakter dan tubuh utuh
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                -- Pastikan tangan tetap ada
                if v.Name ~= "RightHand" and v.Name ~= "LeftHand" then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                    v.TextureID = "" -- Hilangkan texture berat
                else
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0.1 -- Menjaga tangan lebih realistik
                end
            elseif v:IsA("Decal") then
                v.Transparency = 0.7 -- Rendahin texture supaya nggak berat
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0) -- Hapus efek partikel dan trail
            end
        end
        print("✅ Fps Booster Active, Ready")
    end
})

local ServerTab = Window:CreateTab("🌐 Server", 4483362458) -- Ikon planet Bumi

ServerTab:CreateButton({
	Name = "♻️ Rejoin Server",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
	end
})

ServerTab:CreateButton({
	Name = "🌍 Server Hop",
	Callback = function()
		local HttpService = game:GetService("HttpService")
		local TeleportService = game:GetService("TeleportService")
		local PlaceId = game.PlaceId

		local success, servers = pcall(function()
			return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
		end)

		if success and servers and servers.data then
			for _, server in ipairs(servers.data) do
				if server.playing < server.maxPlayers and server.id ~= game.JobId then
					TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
					break
				end
			end
		end
	end
})

-- Credits Tab
local CreditTab = Window:CreateTab("📜 Credits", 4483362458)

CreditTab:CreateLabel("Created by Viunze")

CreditTab:CreateButton({
    Name = "📎 Join Discord XploitForce",
    Callback = function()
        setclipboard("https://discord.gg/QjsgcpFDDr")
        Rayfield:Notify({
            Title = "Link Copied!",
            Content = "Discord link has been copied to clipboard!",
            Duration = 5
        })
    end
})
