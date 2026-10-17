-- [[ NOVAX HUB V5 - RAYFIELD EDITION ]]
-- Tác giả: Nhism
-- Tích hợp: Aimbot (Fix lỗi), Silent Aim (Bắn đâu trúng đó), ESP Nâng cao, Noclip, Water Walk.

if not getgenv then getgenv = function() return _G end end
if not game:IsLoaded() then game.Loaded:Wait() end

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
local ConfigFile = "NovaX_V5_Config.json"

-- [ 1. NÂNG CẤP BYPASS ]
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
getgenv().AntiCheatDisabled = true

-- [ 2. CẤU HÌNH HỆ THỐNG ]
local Config = {
    Aimbot = {
        Enabled = false,
        SilentAim = false,
        CameraLock = false,
        TeamCheck = true,
        WallCheck = true,
        Smoothness = 0.5,
        FOV = 200,
        TargetPart = "Head",
        Keybind = "E"
    },
    ESP = {
        Enabled = false,
        Box = true,
        Tracer = true,
        Ring = true,
        Health = true,
        Rainbow = true
    },
    Exploits = {
        Speed = false,
        SpeedValue = 50,
        Jump = false,
        JumpValue = 100,
        Noclip = false,
        WaterWalk = false
    }
}

-- Load/Save Config
local function LoadConfig()
    if isfile and readfile and isfile(ConfigFile) then
        local success, data = pcall(function() return Services.HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and data then
            for k, v in pairs(data) do if Config[k] then for k2, v2 in pairs(v) do Config[k][k2] = v2 end end end
        end
    end
end
local function SaveConfig()
    if writefile then pcall(function() writefile(ConfigFile, Services.HttpService:JSONEncode(Config)) end) end
end
LoadConfig()

local function GetRainbowColor()
    return Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
end

-- [ 3. HỆ THỐNG ESP NÂNG CAO ]
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local esp = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Ring = Drawing.new("Circle"),
        Name = Drawing.new("Text")
    }
    esp.Box.Thickness = 1; esp.Box.Filled = false; esp.Box.Transparency = 1
    esp.Tracer.Thickness = 1; esp.Tracer.Transparency = 1
    esp.Ring.Thickness = 1; esp.Ring.Filled = false; esp.Ring.Transparency = 1; esp.Ring.Radius = 50
    esp.Name.Size = 14; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.OutlineColor = Color3.new(0, 0, 0)
    ESPObjects[player] = esp
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do obj:Remove() end
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
                    -- Box
                    if Config.ESP.Box then
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                        esp.Box.Color = color
                        esp.Box.Visible = true
                    else esp.Box.Visible = false end
                    
                    -- Tracer (Đường kẻ từ dưới lên)
                    if Config.ESP.Tracer then
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                        esp.Tracer.Color = color
                        esp.Tracer.Visible = true
                    else esp.Tracer.Visible = false end
                    
                    -- Ring
                    if Config.ESP.Ring then
                        esp.Ring.Position = Vector2.new(pos.X, pos.Y)
                        esp.Ring.Color = color
                        esp.Ring.Visible = true
                    else esp.Ring.Visible = false end
                    
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - 20)
                    esp.Name.Color = color
                    esp.Name.Visible = true
                else
                    for _, obj in pairs(esp) do obj.Visible = false end
                end
            end
        end
    end
end

-- [ 4. LOGIC AIMBOT & SILENT AIM ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.Transparency = 1

local function GetClosestPlayer()
    local closest, shortestDistance = nil, Config.Aimbot.FOV
    local center = Camera.ViewportSize / 2
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            local targetPart = char:FindFirstChild(Config.Aimbot.TargetPart) or char:FindFirstChild("HumanoidRootPart")
            
            if targetPart and hum and hum.Health > 0 then
                if Config.Aimbot.TeamCheck and LocalPlayer.Team == player.Team then continue end
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDistance then
                        -- Wall check (Chỉ áp dụng cho Camera Aimbot, Silent Aim có thể bắn xuyên tường)
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

-- Hook Silent Aim (Bắn đâu trúng đó)
local oldIndex
pcall(function()
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and getgenv().SilentAimActive then
            if (self == Mouse and (key == "Hit" or key == "Target")) then
                local target = GetClosestPlayer()
                if target and target.Character then
                    local part = target.Character:FindFirstChild(Config.Aimbot.TargetPart) or target.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        if key == "Hit" then return part.CFrame
                        elseif key == "Target" then return part end
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)
end)

-- [ 5. HỆ THỐNG NOCLIP & WATER WALK ]
Services.RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        -- Noclip
        if Config.Exploits.Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
        
        -- Water Walk (Đi trên nước)
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and Config.Exploits.WaterWalk then
            if hum:GetState() == Enum.HumanoidStateType.Swimming then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local ray = Services.Workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), RaycastParams.new())
                    if ray then
                        hrp.CFrame = CFrame.new(ray.Position + Vector3.new(0, 3, 0)) -- Nâng lên mặt nước
                    end
                end
            end
        end
    end
end)

-- [ 6. RENDER LOOP CHÍNH ]
Services.RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Color = Config.ESP.Rainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = Config.Aimbot.Enabled
    
    UpdateESP()
    
    -- Logic Aimbot
    if Config.Aimbot.Enabled then
        getgenv().SilentAimActive = Config.Aimbot.SilentAim
        local isKeyDown = Services.UserInputService:IsKeyDown(Enum.KeyCode[Config.Aimbot.Keybind])
        
        if isKeyDown or Config.Aimbot.CameraLock then
            local target = GetClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(Config.Aimbot.TargetPart) or target.Character:FindFirstChild("HumanoidRootPart")
                if part and not Config.Aimbot.SilentAim then -- Nếu không bật Silent Aim thì dùng Camera Lock
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Aimbot.Smoothness)
                end
            end
        end
    else
        getgenv().SilentAimActive = false
    end
    
    -- Exploits Tốc độ / Nhảy
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = Config.Exploits.Speed and Config.Exploits.SpeedValue or 16
        hum.UseJumpPower = true
        hum.JumpPower = Config.Exploits.Jump and Config.Exploits.JumpValue or 50
    end
end)

-- [ 7. RAYFIELD UI ]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "NovaX Hub V5",
    LoadingTitle = "NovaX Hub",
    LoadingSubtitle = "by Nhism | V5 Ultimate",
    ConfigurationSaving = {Enabled = true, FolderName = "NovaXV5", FileName = "Config"},
    KeySystem = true,
    KeySettings = {
        Title = "NovaX Authentication",
        Subtitle = "Nhập Key Để Tiếp Tục",
        Note = "Discord: discord.gg/nhism",
        FileName = "NovaXV5Key",
        SaveKey = true,
        Key = {"NHISM-PREMIUM-999", "NHISM-FREE-111"}
    }
})

local InfoTab = Window:CreateTab("Info Hub", 4483362458)
InfoTab:CreateLabel("NovaX V5 | Nâng cấp toàn diện Aimbot & Exploits")
InfoTab:CreateLabel("Trạng thái: Undetected")

local MainTab = Window:CreateTab("Aimbot & ESP", 4483362458)
MainTab:CreateSection("Cấu Hình Aimbot")
MainTab:CreateToggle({Name = "Bật Aimbot", CurrentValue = Config.Aimbot.Enabled, Flag = "AimbotToggle", Callback = function(Value) Config.Aimbot.Enabled = Value end})
MainTab:CreateToggle({Name = "Silent Aim (Bắn đâu trúng đó)", CurrentValue = Config.Aimbot.SilentAim, Flag = "SilentToggle", Callback = function(Value) Config.Aimbot.SilentAim = Value end})
MainTab:CreateToggle({Name = "Khóa Camera", CurrentValue = Config.Aimbot.CameraLock, Flag = "CamLock", Callback = function(Value) Config.Aimbot.CameraLock = Value end})
MainTab:CreateToggle({Name = "Check Team", CurrentValue = Config.Aimbot.TeamCheck, Flag = "TeamCheck", Callback = function(Value) Config.Aimbot.TeamCheck = Value end})
MainTab:CreateToggle({Name = "Wall Check", CurrentValue = Config.Aimbot.WallCheck, Flag = "WallCheck", Callback = function(Value) Config.Aimbot.WallCheck = Value end})

MainTab:CreateDropdown({Name = "Target Part", Options = {"Head", "UpperTorso", "LowerTorso"}, CurrentOption = {"Head"}, Flag = "TargetPart", Callback = function(opt) Config.Aimbot.TargetPart = opt[1] end})
MainTab:CreateSlider({Name = "Độ Mượt", Range = {10, 100}, Increment = 1, CurrentValue = Config.Aimbot.Smoothness * 100, Flag = "Smooth", Callback = function(Value) Config.Aimbot.Smoothness = Value / 100 end})
MainTab:CreateSlider({Name = "Bán Kính FOV", Range = {50, 800}, Increment = 10, CurrentValue = Config.Aimbot.FOV, Flag = "FOV", Callback = function(Value) Config.Aimbot.FOV = Value end})
MainTab:CreateKeybind({Name = "Phím Aim", CurrentKeybind = Config.Aimbot.Keybind, Flag = "AimKey", Callback = function(Key) Config.Aimbot.Keybind = Key end})

MainTab:CreateSection("Cấu Hình ESP")
MainTab:CreateToggle({Name = "Bật ESP", CurrentValue = Config.ESP.Enabled, Flag = "ESPToggle", Callback = function(Value) Config.ESP.Enabled = Value end})
MainTab:CreateToggle({Name = "Rainbow Mode", CurrentValue = Config.ESP.Rainbow, Flag = "RainbowToggle", Callback = function(Value) Config.ESP.Rainbow = Value end})
MainTab:CreateToggle({Name = "Box ESP", CurrentValue = Config.ESP.Box, Flag = "BoxToggle", Callback = function(Value) Config.ESP.Box = Value end})
MainTab:CreateToggle({Name = "Tracer (Đường Kẻ)", CurrentValue = Config.ESP.Tracer, Flag = "TracerToggle", Callback = function(Value) Config.ESP.Tracer = Value end})
MainTab:CreateToggle({Name = "Ring ESP (Vòng Tròn)", CurrentValue = Config.ESP.Ring, Flag = "RingToggle", Callback = function(Value) Config.ESP.Ring = Value end})

local ExploitTab = Window:CreateTab("Exploits", 4483362458)
ExploitTab:CreateSection("Di Chuyển & Bypass")
ExploitTab:CreateToggle({Name = "Speed Hack", CurrentValue = Config.Exploits.Speed, Flag = "SpeedToggle", Callback = function(Value) Config.Exploits.Speed = Value end})
ExploitTab:CreateSlider({Name = "Tốc Độ", Range = {16, 250}, Increment = 1, CurrentValue = Config.Exploits.SpeedValue, Flag = "SpeedValue", Callback = function(Value) Config.Exploits.SpeedValue = Value end})
ExploitTab:CreateToggle({Name = "Jump Hack", CurrentValue = Config.Exploits.Jump, Flag = "JumpToggle", Callback = function(Value) Config.Exploits.Jump = Value end})
ExploitTab:CreateSlider({Name = "Lực Nhảy", Range = {50, 500}, Increment = 5, CurrentValue = Config.Exploits.JumpValue, Flag = "JumpValue", Callback = function(Value) Config.Exploits.JumpValue = Value end})

ExploitTab:CreateSection("Tính Năng Đặc Biệt")
ExploitTab:CreateToggle({Name = "Noclip (Xuyên Tường)", CurrentValue = Config.Exploits.Noclip, Flag = "NoclipToggle", Callback = function(Value) Config.Exploits.Noclip = Value end})
ExploitTab:CreateToggle({Name = "Water Walk (Đi Trên Nước)", CurrentValue = Config.Exploits.WaterWalk, Flag = "WaterWalkToggle", Callback = function(Value) Config.Exploits.WaterWalk = Value end})

ExploitTab:CreateButton({Name = "Lưu Cấu Hình", Callback = function() SaveConfig() Rayfield:Notify({Title = "Config", Content = "Đã lưu cấu hình", Duration = 2}) end})

Services.Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(c) if Config.ESP.Enabled then CreateESP(p) end end) end)
Services.Players.PlayerRemoving:Connect(RemoveESP)
