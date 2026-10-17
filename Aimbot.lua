-- [[ NOVAX HUB V2 - UNIVERSAL AIMBOT, ESP & EXPLOITS ]]
-- Tác giả: Nhism
-- Tích hợp: LinUI, Drawing API, Metatable Bypass.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local ConfigFile = "NovaX_Aimbot_Config_V2.json"

-- [ 1. NÂNG CẤP ANTI-CHEAT & BYPASS ]
local function EnhancedBypass()
    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            -- Chặn Kick
            if method == "Kick" then return end
            -- Bypass Silent Aim / Raycast nếu game dùng Raycast chống hack
            if method == "Raycast" and getgenv().SilentAimActive then
                -- Logic can thiệp Raycast có thể thêm ở đây nếu cần
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
    
    if getgenv then
        getgenv().AntiCheatDisabled = true
        getgenv().BypassActive = true
    end
end
EnhancedBypass()

-- [ 2. CẤU HÌNH HỆ THỐNG ]
local Config = {
    Aimbot = {
        Enabled = false,
        SilentAim = false,
        CameraLock = false,
        TeamCheck = true,
        WallCheck = true,
        DeadCheck = true,
        Smoothness = 0.5,
        FOV = 150,
        TargetPart = "Head",
        Keybind = "E"
    },
    ESP = {
        Enabled = false,
        Box = true,
        Ring = true,
        Health = true,
        Rainbow = true
    },
    Exploits = {
        Speed = false,
        SpeedValue = 50,
        Jump = false,
        JumpValue = 100,
        Hitbox = false,
        HitboxSize = 10
    }
}

-- Tải/Lưu Config JSON
local function LoadConfig()
    if isfile and readfile and isfile(ConfigFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and data then
            for k, v in pairs(data) do
                if Config[k] then
                    for k2, v2 in pairs(v) do Config[k][k2] = v2 end
                end
            end
        end
    end
end
local function SaveConfig()
    if writefile then pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end) end
end
LoadConfig()

-- [ 3. HÀM RAINBOW COLOR ]
local function GetRainbowColor()
    return Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
end

-- [ 4. HỆ THỐNG ESP (DRAWING API) ]
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local esp = {
        Box = Drawing.new("Square"),
        Ring = Drawing.new("Circle"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square")
    }
    
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    esp.Ring.Thickness = 1
    esp.Ring.Filled = false
    esp.Ring.Transparency = 1
    esp.Ring.Radius = 50
    
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.new(0, 0, 0)
    
    esp.HealthBar.Filled = true
    esp.HealthBar.Thickness = 1
    
    ESPObjects[player] = esp
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not ESPObjects[player] then CreateESP(player) end
            local esp = ESPObjects[player]
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChild("Humanoid")
            
            if not Config.ESP.Enabled or not hum or hum.Health <= 0 then
                for _, obj in pairs(esp) do obj.Visible = false end
            else
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headPos = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                local color = Config.ESP.Rainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
                
                if onScreen then
                    if Config.ESP.Box then
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                        esp.Box.Color = color
                        esp.Box.Visible = true
                    else esp.Box.Visible = false end
                    
                    if Config.ESP.Ring then
                        esp.Ring.Position = Vector2.new(pos.X, pos.Y)
                        esp.Ring.Color = color
                        esp.Ring.Visible = true
                    else esp.Ring.Visible = false end
                    
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - 20)
                    esp.Name.Color = color
                    esp.Name.Visible = true
                    
                    if Config.ESP.Health then
                        local healthPct = hum.Health / hum.MaxHealth
                        esp.HealthBar.Size = Vector2.new(2, 50)
                        esp.HealthBar.Position = Vector2.new(pos.X - 40, pos.Y - 25)
                        esp.HealthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), healthPct)
                        esp.HealthBar.Visible = true
                    else esp.HealthBar.Visible = false end
                else
                    for _, obj in pairs(esp) do obj.Visible = false end
                end
            end
        end
    end
end

-- [ 5. HỆ THỐNG HITBOX EXPANDER ]
local originalSizes = {}
local function ToggleHitbox(state)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if state then
                if not originalSizes[player] then
                    originalSizes[player] = hrp.Size
                end
                hrp.Size = Vector3.new(Config.Exploits.HitboxSize, Config.Exploits.HitboxSize, Config.Exploits.HitboxSize)
                hrp.Transparency = 1
                hrp.CanCollide = false
            else
                if originalSizes[player] then
                    hrp.Size = originalSizes[player]
                    hrp.Transparency = 0
                    hrp.CanCollide = true
                end
            end
        end
    end
end

-- [ 6. LOGIC AIMBOT & SILENT AIM ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 1

local function GetClosestPlayer()
    local closest, shortestDistance = nil, Config.Aimbot.FOV
    local center = Camera.ViewportSize / 2
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            local targetPart = char:FindFirstChild(Config.Aimbot.TargetPart) or char:FindFirstChild("HumanoidRootPart")
            
            if targetPart and hum and hum.Health > 0 then
                -- Check Dead
                if Config.Aimbot.DeadCheck and hum.Health <= 0 then continue end
                -- Check Team
                if Config.Aimbot.TeamCheck and LocalPlayer.Team == player.Team then continue end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDistance then
                        -- Check Wall
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        local ray = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
                        
                        if not Config.Aimbot.WallCheck or (ray and ray.Instance:IsDescendantOf(char)) then
                            closest = player
                            shortestDistance = dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Hook Silent Aim (Can thiệp Mouse.Hit)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and getgenv().SilentAimActive and (self == Mouse or self == Workspace.CurrentCamera) then
        if key == "Hit" or key == "Target" then
            local target = GetClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(Config.Aimbot.TargetPart) or target.Character:FindFirstChild("HumanoidRootPart")
                if part then return part.CFrame end
            end
        end
    end
    return oldIndex(self, key)
end)

-- Render Loop
RunService.RenderStepped:Connect(function()
    -- FOV Rainbow Update
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Color = Config.ESP.Rainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = Config.Aimbot.Enabled
    
    -- ESP Update
    UpdateESP()
    
    -- Aimbot Logic
    if Config.Aimbot.Enabled then
        getgenv().SilentAimActive = Config.Aimbot.SilentAim
        local isKeyDown = UserInputService:IsKeyDown(Enum.KeyCode[Config.Aimbot.Keybind])
        
        if isKeyDown or Config.Aimbot.CameraLock then
            local target = GetClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(Config.Aimbot.TargetPart) or target.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    if Config.Aimbot.CameraLock or not Config.Aimbot.SilentAim then
                        local newCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Config.Aimbot.Smoothness)
                    end
                end
            end
        end
    else
        getgenv().SilentAimActive = false
    end
    
    -- Exploits
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = Config.Exploits.Speed and Config.Exploits.SpeedValue or 16
        hum.UseJumpPower = true
        hum.JumpPower = Config.Exploits.Jump and Config.Exploits.JumpValue or 50
    end
end)

-- [ 7. GIAO DIỆN LINUI ]
local Library = loadstring(game:HttpGet("https://reallinen.github.io/Files/Scripts/Linui.lua"))()

local InfoTab = Library:Section("Info Hub")
InfoTab:Label({Text = "NovaX Hub V2 | Universal Aimbot & ESP"})
InfoTab:Label({Text = "Developer: Nhism"})
InfoTab:Label({Text = "Status: Bypassed / Undetected"})
InfoTab:Label({Text = "Version: 2.0.0 (Rainbow Update)"})

local HomeTab = Library:Section("Aimbot & ESP")
HomeTab:Toggle({Text = "Enable Aimbot", Value = Config.Aimbot.Enabled, Callback = function(v) Config.Aimbot.Enabled = v end})
HomeTab:Toggle({Text = "Silent Aim (Bắn đâu cũng trúng)", Value = Config.Aimbot.SilentAim, Callback = function(v) Config.Aimbot.SilentAim = v end})
HomeTab:Toggle({Text = "Camera Lock (Khóa Cam)", Value = Config.Aimbot.CameraLock, Callback = function(v) Config.Aimbot.CameraLock = v end})
HomeTab:Toggle({Text = "Team Check", Value = Config.Aimbot.TeamCheck, Callback = function(v) Config.Aimbot.TeamCheck = v end})
HomeTab:Toggle({Text = "Wall Check", Value = Config.Aimbot.WallCheck, Callback = function(v) Config.Aimbot.WallCheck = v end})
HomeTab:Toggle({Text = "Dead Check", Value = Config.Aimbot.DeadCheck, Callback = function(v) Config.Aimbot.DeadCheck = v end})

HomeTab:Dropdown({
    Text = "Target Part",
    Data = { "Head", "Neck", "UpperTorso", "LowerTorso", "LeftLeg", "RightLeg" },
    Callback = function(v) Config.Aimbot.TargetPart = v end
})
HomeTab:Slider({Text = "Smoothness", Min = 0.1, Max = 1, Value = Config.Aimbot.Smoothness, Callback = function(v) Config.Aimbot.Smoothness = v end})
HomeTab:Slider({Text = "FOV Radius", Min = 50, Max = 800, Value = Config.Aimbot.FOV, Callback = function(v) Config.Aimbot.FOV = v end})
HomeTab:Keybind({Text = "Aimbot Key", Value = Config.Aimbot.Keybind, Callback = function(k) Config.Aimbot.Keybind = k end})

-- ESP Section
local ESPTab = Library:Section("Visual (ESP)")
ESPTab:Toggle({Text = "Enable ESP", Value = Config.ESP.Enabled, Callback = function(v) Config.ESP.Enabled = v end})
ESPTab:Toggle({Text = "Rainbow Mode (Cầu Vồng)", Value = Config.ESP.Rainbow, Callback = function(v) Config.ESP.Rainbow = v end})
ESPTab:Toggle({Text = "Box ESP", Value = Config.ESP.Box, Callback = function(v) Config.ESP.Box = v end})
ESPTab:Toggle({Text = "Ring ESP (Vòng kẻ)", Value = Config.ESP.Ring, Callback = function(v) Config.ESP.Ring = v end})
ESPTab:Toggle({Text = "Health Bar", Value = Config.ESP.Health, Callback = function(v) Config.ESP.Health = v end})

-- Setting Section
local SettingTab = Library:Section("Settings & Exploits")
SettingTab:Toggle({Text = "Speed Hack", Value = Config.Exploits.Speed, Callback = function(v) Config.Exploits.Speed = v end})
SettingTab:Slider({Text = "Speed Value", Min = 16, Max = 250, Value = Config.Exploits.SpeedValue, Callback = function(v) Config.Exploits.SpeedValue = v end})
SettingTab:Toggle({Text = "Jump Hack", Value = Config.Exploits.Jump, Callback = function(v) Config.Exploits.Jump = v end})
SettingTab:Slider({Text = "Jump Value", Min = 50, Max = 500, Value = Config.Exploits.JumpValue, Callback = function(v) Config.Exploits.JumpValue = v end})

SettingTab:Toggle({
    Text = "Hitbox Expander (Tăng Hitbox)", 
    Value = Config.Exploits.Hitbox, 
    Callback = function(v) 
        Config.Exploits.Hitbox = v
        ToggleHitbox(v)
    end
})
SettingTab:Slider({
    Text = "Hitbox Size", 
    Min = 5, 
    Max = 50, 
    Value = Config.Exploits.HitboxSize, 
    Callback = function(v) 
        Config.Exploits.HitboxSize = v 
        if Config.Exploits.Hitbox then ToggleHitbox(true) end
    end
})

SettingTab:Button({Text = "Save Config", Callback = function() SaveConfig() end})
SettingTab:Button({Text = "Load Config", Callback = function() LoadConfig() end})

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        if Config.Exploits.Hitbox then task.wait(1) ToggleHitbox(true) end
        if Config.ESP.Enabled then CreateESP(p) end
    end)
end)
Players.PlayerRemoving:Connect(RemoveESP)
