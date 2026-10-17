-- [[ NOVAX HUB V4 - RAYFIELD EDITION ]]
-- Tác giả: Nhism
-- Tích hợp: Rayfield UI (Không lỗi Executor), Bypass, Aimbot, ESP.

-- [ 1. KHỞI TẠO MÔI TRƯỜNG AN TOÀN ]
if not getgenv then getgenv = function() return _G end end
if not game:IsLoaded() then game.Loaded:Wait() end
local successInit, errInit = pcall(function()
    if not game:GetService("CoreGui") then error("CoreGui không khả dụng") end
end)
if not successInit then return end

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
local ConfigFile = "NovaX_Rayfield_Config.json"

-- [ 2. NÂNG CẤP BYPASS & ANTI-CHEAT ]
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

-- [ 3. CẤU HÌNH HỆ THỐNG ]
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

-- [ 4. HÀM RAINBOW COLOR ]
local function GetRainbowColor()
    return Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
end

-- [ 5. HỆ THỐNG ESP (DRAWING API) ]
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

-- [ 6. HỆ THỐNG HITBOX EXPANDER ]
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

-- [ 7. LOGIC AIMBOT & SILENT AIM ]
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

-- Hook Silent Aim (Bọc pcall để chống crash)
local oldIndex
pcall(function()
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
end)

-- [ 8. RENDER LOOP ]
Services.RunService.RenderStepped:Connect(function()
    -- FOV Update
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Color = Config.ESP.Rainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = Config.Aimbot.Enabled
    
    -- ESP Update
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

-- [ 9. KHỞI TẠO RAYFIELD UI ]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "NovaX Hub | Rayfield",
    LoadingTitle = "NovaX Hub",
    LoadingSubtitle = "by Nhism",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "NovaXConfig", 
        FileName = "NovaX_Rayfield"
    },
    KeySystem = true,
    KeySettings = {
        Title = "NovaX Key System",
        Subtitle = "Nhập Key Để Tiếp Tục",
        Note = "Lấy Key Tại Discord: discord.gg/nhism",
        FileName = "NovaXKey",
        SaveKey = true,
        GrabKeyFromSite = false, -- Thay bằng link web nếu có
        Key = {"NHISM-PREMIUM-999", "NHISM-FREE-111"}
    }
})

-- TAB: INFO
local InfoTab = Window:CreateTab("Info Hub", 4483362458)
InfoTab:CreateSection("NovaX Hub V4")
InfoTab:CreateLabel("Tác giả: Nhism")
InfoTab:CreateLabel("Trạng thái: Bypassed / Undetected")
InfoTab:CreateLabel("Phiên bản: 4.0.0 (Rayfield Edition)")

InfoTab:CreateSection("Liên kết")
local DiscordBtn = InfoTab:CreateButton({
    Name = "Copy Link Discord",
    Callback = function()
        if setclipboard then setclipboard("https://discord.gg/nhism") end
        Rayfield:Notify({Title = "Đã Copy", Content = "Link Discord đã được lưu vào Clipboard", Duration = 3})
    end,
})
local WebBtn = InfoTab:CreateButton({
    Name = "Copy Link Website",
    Callback = function()
        if setclipboard then setclipboard("https://nhism.com") end
        Rayfield:Notify({Title = "Đã Copy", Content = "Link Website đã được lưu vào Clipboard", Duration = 3})
    end,
})

-- TAB: AIMBOT & VISUALS
local MainTab = Window:CreateTab("Aimbot & Visuals", 4483362458)
MainTab:CreateSection("Cấu Hình Aimbot")

local AimbotToggle = MainTab:CreateToggle({
    Name = "Bật Aimbot",
    CurrentValue = Config.Aimbot.Enabled,
    Flag = "AimbotToggle",
    Callback = function(Value) Config.Aimbot.Enabled = Value end,
})
local SilentAimToggle = MainTab:CreateToggle({
    Name = "Silent Aim (Bắn đâu trúng đó)",
    CurrentValue = Config.Aimbot.SilentAim,
    Flag = "SilentAimToggle",
    Callback = function(Value) Config.Aimbot.SilentAim = Value end,
})
local CamLockToggle = MainTab:CreateToggle({
    Name = "Khóa Camera",
    CurrentValue = Config.Aimbot.CameraLock,
    Flag = "CamLockToggle",
    Callback = function(Value) Config.Aimbot.CameraLock = Value end,
})
local TeamCheckToggle = MainTab:CreateToggle({
    Name = "Check Team (Không bắn đồng đội)",
    CurrentValue = Config.Aimbot.TeamCheck,
    Flag = "TeamCheck",
    Callback = function(Value) Config.Aimbot.TeamCheck = Value end,
})
local WallCheckToggle = MainTab:CreateToggle({
    Name = "Wall Check (Không bắn xuyên tường)",
    CurrentValue = Config.Aimbot.WallCheck,
    Flag = "WallCheck",
    Callback = function(Value) Config.Aimbot.WallCheck = Value end,
})
local DeadCheckToggle = MainTab:CreateToggle({
    Name = "Check Dead (Không bắn người chết)",
    CurrentValue = Config.Aimbot.DeadCheck,
    Flag = "DeadCheck",
    Callback = function(Value) Config.Aimbot.DeadCheck = Value end,
})

local TargetDropdown = MainTab:CreateDropdown({
    Name = "Vị trí Aim (Target Part)",
    Options = {"Head", "UpperTorso", "LowerTorso", "LeftLeg", "RightLeg"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "TargetPart",
    Callback = function(Options) Config.Aimbot.TargetPart = Options[1] end,
})

local SmoothSlider = MainTab:CreateSlider({
    Name = "Độ Mượt (Smoothness)",
    Range = {10, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = Config.Aimbot.Smoothness * 100,
    Flag = "Smoothness",
    Callback = function(Value) Config.Aimbot.Smoothness = Value / 100 end,
})
local FOVSlider = MainTab:CreateSlider({
    Name = "Bán Kính FOV",
    Range = {50, 800},
    Increment = 10,
    Suffix = "px",
    CurrentValue = Config.Aimbot.FOV,
    Flag = "FOVRadius",
    Callback = function(Value) Config.Aimbot.FOV = Value end,
})
local AimKeybind = MainTab:CreateKeybind({
    Name = "Phím Aim (Hold)",
    CurrentKeybind = Config.Aimbot.Keybind,
    HoldToInteract = false,
    Flag = "AimKey",
    Callback = function(Key) Config.Aimbot.Keybind = Key end,
})

MainTab:CreateSection("Cấu Hình ESP (Visual)")
local ESPToggle = MainTab:CreateToggle({
    Name = "Bật ESP",
    CurrentValue = Config.ESP.Enabled,
    Flag = "ESPToggle",
    Callback = function(Value) Config.ESP.Enabled = Value end,
})
local RainbowToggle = MainTab:CreateToggle({
    Name = "Chế Độ Cầu Vồng (Rainbow)",
    CurrentValue = Config.ESP.Rainbow,
    Flag = "RainbowToggle",
    Callback = function(Value) Config.ESP.Rainbow = Value end,
})
local BoxToggle = MainTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = Config.ESP.Box,
    Flag = "BoxESP",
    Callback = function(Value) Config.ESP.Box = Value end,
})
local RingToggle = MainTab:CreateToggle({
    Name = "Ring ESP (Vòng kẻ)",
    CurrentValue = Config.ESP.Ring,
    Flag = "RingESP",
    Callback = function(Value) Config.ESP.Ring = Value end,
})
local HealthToggle = MainTab:CreateToggle({
    Name = "Thanh Máu (Health Bar)",
    CurrentValue = Config.ESP.Health,
    Flag = "HealthESP",
    Callback = function(Value) Config.ESP.Health = Value end,
})

-- TAB: EXPLOITS
local ExploitTab = Window:CreateTab("Exploits", 4483362458)
ExploitTab:CreateSection("Di Chuyển")
local SpeedToggle = ExploitTab:CreateToggle({
    Name = "Tốc Độ (Speed Hack)",
    CurrentValue = Config.Exploits.Speed,
    Flag = "SpeedToggle",
    Callback = function(Value) Config.Exploits.Speed = Value end,
})
local SpeedSlider = ExploitTab:CreateSlider({
    Name = "Giá Trị Tốc Độ",
    Range = {16, 250},
    Increment = 1,
    Suffix = "spd",
    CurrentValue = Config.Exploits.SpeedValue,
    Flag = "SpeedValue",
    Callback = function(Value) Config.Exploits.SpeedValue = Value end,
})
local JumpToggle = ExploitTab:CreateToggle({
    Name = "Nhảy Cao (Jump Hack)",
    CurrentValue = Config.Exploits.Jump,
    Flag = "JumpToggle",
    Callback = function(Value) Config.Exploits.Jump = Value end,
})
local JumpSlider = ExploitTab:CreateSlider({
    Name = "Giá Trị Nhảy",
    Range = {50, 500},
    Increment = 5,
    Suffix = "pwr",
    CurrentValue = Config.Exploits.JumpValue,
    Flag = "JumpValue",
    Callback = function(Value) Config.Exploits.JumpValue = Value end,
})

ExploitTab:CreateSection("Hitbox")
local HitboxToggle = ExploitTab:CreateToggle({
    Name = "Tăng Hitbox (Hitbox Expander)",
    CurrentValue = Config.Exploits.Hitbox,
    Flag = "HitboxToggle",
    Callback = function(Value) 
        Config.Exploits.Hitbox = Value
        ToggleHitbox(Value)
    end,
})
local HitboxSlider = ExploitTab:CreateSlider({
    Name = "Kích Thước Hitbox",
    Range = {5, 50},
    Increment = 1,
    Suffix = "size",
    CurrentValue = Config.Exploits.HitboxSize,
    Flag = "HitboxSize",
    Callback = function(Value) 
        Config.Exploits.HitboxSize = Value 
        if Config.Exploits.Hitbox then ToggleHitbox(true) end
    end,
})

-- QUẢN LÝ CONFIG
ExploitTab:CreateSection("Cấu Hình (JSON)")
local SaveBtn = ExploitTab:CreateButton({
    Name = "Lưu Cấu Hình",
    Callback = function()
        SaveConfig()
        Rayfield:Notify({Title = "Lưu Thành Công", Content = "Đã lưu cấu hình vào File JSON", Duration = 3})
    end,
})

-- TỰ ĐỘNG CẬP NHẬT HITBOX KHI RESPAWN
Services.Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        if Config.Exploits.Hitbox then task.wait(1) ToggleHitbox(true) end
        if Config.ESP.Enabled then CreateESP(p) end
    end)
end)
Services.Players.PlayerRemoving:Connect(RemoveESP)
