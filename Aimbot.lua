-- [[ NOVAX HUB V3 - MACLIB EDITION ]]
-- Tác giả: Nhism
-- Hệ thống: Aimbot, ESP, Exploits, Bypass Anti-Cheat (MacLib UI).

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    HttpService = game:GetService("HttpService"),
    Workspace = game:GetService("Workspace")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local ConfigFile = "NovaX_MacLib_Config.json"

-- [ 1. NÂNG CẤP ANTI-CHEAT & BYPASS ]
local function EnhancedBypass()
    pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" then return end
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

-- [ 2. CẤU HÌNH MẶC ĐỊNH ]
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
        local success, data = pcall(function() return Services.HttpService:JSONDecode(readfile(ConfigFile)) end)
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
    if writefile then pcall(function() writefile(ConfigFile, Services.HttpService:JSONEncode(Config)) end) end
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
    for _, player in pairs(Services.Players:GetPlayers()) do
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
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if state then
                if not originalSizes[player] then originalSizes[player] = hrp.Size end
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
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            local targetPart = char:FindFirstChild(Config.Aimbot.TargetPart) or char:FindFirstChild("HumanoidRootPart")
            
            if targetPart and hum and hum.Health > 0 then
                if Config.Aimbot.DeadCheck and hum.Health <= 0 then continue end
                if Config.Aimbot.TeamCheck and LocalPlayer.Team == player.Team then continue end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDistance then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        local ray = Services.Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
                        
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

-- Hook Silent Aim
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and getgenv().SilentAimActive and (self == Mouse or self == Camera) then
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

-- [ 7. RENDER LOOP ]
Services.RunService.RenderStepped:Connect(function()
    -- FOV Update
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Color = Config.ESP.Rainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = Config.Aimbot.Enabled
    
    UpdateESP()
    
    -- Aimbot Logic
    if Config.Aimbot.Enabled then
        getgenv().SilentAimActive = Config.Aimbot.SilentAim
        local isKeyDown = Services.UserInputService:IsKeyDown(Enum.KeyCode[Config.Aimbot.Keybind])
        
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

-- [ 8. KHỞI TẠO UI MACLIB ]
local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/yourrepo/main/maclib.lua"))()

local Window = MacLib:Window({
    Title = "NovaX Hub",
    Subtitle = "MacLib Edition | By Nhism",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,
    AcrylicBlur = true,
})

local TabGroup = Window:TabGroup()
local InfoTab = TabGroup:Tab({Name = "Information", Image = "rbxassetid://18821914323"})
local HomeTab = TabGroup:Tab({Name = "Aimbot & Visuals", Image = "rbxassetid://10734950309"})
local SettingTab = TabGroup:Tab({Name = "Settings & Exploits", Image = "rbxassetid://10734950309"})

-- INFO TAB
local InfoSection = InfoTab:Section({Side = "Left"})
InfoSection:Label({Text = "NovaX Hub V3 | MacLib UI"})
InfoSection:Label({Text = "Developer: Nhism"})
InfoSection:Label({Text = "Status: Bypassed / Undetected"})
InfoSection:Label({Text = "Version: 3.0.0"})
InfoSection:Button({
    Name = "Copy Discord Link",
    Callback = function()
        if setclipboard then setclipboard("https://discord.gg/nhism") end
        Window:Notify({Title = "Copied", Description = "Discord link copied to clipboard."})
    end
})
InfoSection:Button({
    Name = "Copy Website Link",
    Callback = function()
        if setclipboard then setclipboard("https://nhism.com") end
        Window:Notify({Title = "Copied", Description = "Website link copied to clipboard."})
    end
})

-- HOME TAB (AIMBOT & ESP)
local AimSection = HomeTab:Section({Side = "Left"})
local ESP_Section = HomeTab:Section({Side = "Right"})

AimSection:Header({Name = "Aimbot Settings"})
AimSection:Toggle({Name = "Enable Aimbot", Default = Config.Aimbot.Enabled, Callback = function(v) Config.Aimbot.Enabled = v end})
AimSection:Toggle({Name = "Silent Aim", Default = Config.Aimbot.SilentAim, Callback = function(v) Config.Aimbot.SilentAim = v end})
AimSection:Toggle({Name = "Camera Lock", Default = Config.Aimbot.CameraLock, Callback = function(v) Config.Aimbot.CameraLock = v end})
AimSection:Toggle({Name = "Team Check", Default = Config.Aimbot.TeamCheck, Callback = function(v) Config.Aimbot.TeamCheck = v end})
AimSection:Toggle({Name = "Wall Check", Default = Config.Aimbot.WallCheck, Callback = function(v) Config.Aimbot.WallCheck = v end})
AimSection:Toggle({Name = "Dead Check", Default = Config.Aimbot.DeadCheck, Callback = function(v) Config.Aimbot.DeadCheck = v end})

AimSection:Dropdown({
    Name = "Target Part",
    Options = { "Head", "Neck", "UpperTorso", "LowerTorso", "LeftLeg", "RightLeg" },
    Default = 1,
    Callback = function(v) Config.Aimbot.TargetPart = v end
})
AimSection:Slider({Name = "Smoothness", Default = Config.Aimbot.Smoothness * 100, Minimum = 10, Maximum = 100, Callback = function(v) Config.Aimbot.Smoothness = v / 100 end})
AimSection:Slider({Name = "FOV Radius", Default = Config.Aimbot.FOV, Minimum = 50, Maximum = 800, Callback = function(v) Config.Aimbot.FOV = v end})
AimSection:Keybind({Name = "Aimbot Key", Default = Enum.KeyCode.E, Callback = function(k) Config.Aimbot.Keybind = k.Name end})

ESP_Section:Header({Name = "Visual Settings (ESP)"})
ESP_Section:Toggle({Name = "Enable ESP", Default = Config.ESP.Enabled, Callback = function(v) Config.ESP.Enabled = v end})
ESP_Section:Toggle({Name = "Rainbow Mode", Default = Config.ESP.Rainbow, Callback = function(v) Config.ESP.Rainbow = v end})
ESP_Section:Toggle({Name = "Box ESP", Default = Config.ESP.Box, Callback = function(v) Config.ESP.Box = v end})
ESP_Section:Toggle({Name = "Ring ESP", Default = Config.ESP.Ring, Callback = function(v) Config.ESP.Ring = v end})
ESP_Section:Toggle({Name = "Health Bar", Default = Config.ESP.Health, Callback = function(v) Config.ESP.Health = v end})

-- SETTING TAB (EXPLOITS)
local ExploitSection = SettingTab:Section({Side = "Left"})
local ConfigSection = SettingTab:Section({Side = "Right"})

ExploitSection:Header({Name = "Exploits & Bypass"})
ExploitSection:Toggle({Name = "Speed Hack", Default = Config.Exploits.Speed, Callback = function(v) Config.Exploits.Speed = v end})
ExploitSection:Slider({Name = "Speed Value", Default = Config.Exploits.SpeedValue, Minimum = 16, Maximum = 250, Callback = function(v) Config.Exploits.SpeedValue = v end})
ExploitSection:Toggle({Name = "Jump Hack", Default = Config.Exploits.Jump, Callback = function(v) Config.Exploits.Jump = v end})
ExploitSection:Slider({Name = "Jump Value", Default = Config.Exploits.JumpValue, Minimum = 50, Maximum = 500, Callback = function(v) Config.Exploits.JumpValue = v end})

ExploitSection:Toggle({
    Name = "Hitbox Expander", 
    Default = Config.Exploits.Hitbox, 
    Callback = function(v) 
        Config.Exploits.Hitbox = v
        ToggleHitbox(v)
    end
})
ExploitSection:Slider({
    Name = "Hitbox Size", 
    Default = Config.Exploits.HitboxSize, 
    Minimum = 5, 
    Maximum = 50, 
    Callback = function(v) 
        Config.Exploits.HitboxSize = v 
        if Config.Exploits.Hitbox then ToggleHitbox(true) end
    end
})

ConfigSection:Header({Name = "Configuration"})
ConfigSection:Button({Name = "Save Settings", Callback = function() 
    SaveConfig() 
    Window:Notify({Title = "Config", Description = "Settings saved successfully."})
end})
ConfigSection:Button({Name = "Load Settings", Callback = function() 
    LoadConfig()
    Window:Notify({Title = "Config", Description = "Settings loaded successfully."})
end})

Services.Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        if Config.Exploits.Hitbox then task.wait(1) ToggleHitbox(true) end
        if Config.ESP.Enabled then CreateESP(p) end
    end)
end)
Services.Players.PlayerRemoving:Connect(RemoveESP)
