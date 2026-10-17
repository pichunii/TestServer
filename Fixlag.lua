-- [[ NOVAX OPTIMIZER V6 - PREMIUM PERFORMANCE ENGINE ]]
-- Author: Nhism
-- Description: Deep Engine & Memory Intervention. 
-- Guarantee: Prevent Mobile Red Screen (pcall protected), Standalone Toggle UI, Real-time Culling.

if not game:IsLoaded() then game.Loaded:Wait() end
if not getgenv then getgenv = function() return _G end end

local Services = {
    Players = game:GetService("Players"),
    Lighting = game:GetService("Lighting"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService"),
    CoreGui = game:GetService("CoreGui"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Terrain = Services.Workspace.Terrain
local Camera = Services.Workspace.CurrentCamera

-- ==========================================
-- [ SAFE INITIALIZATION ]
-- ==========================================
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    return warn("[NovaX] Critical Error: Failed to load UI. Executor may be outdated.")
end

local Window = Rayfield:CreateWindow({
    Name = "NovaX Optimizer V6",
    LoadingTitle = "Injecting Engine Tweaks...",
    LoadingSubtitle = "Premium Performance | By Nhism",
    ConfigurationSaving = { Enabled = true, FolderName = "NovaX_V6", FileName = "Config" },
    KeySystem = false
})

-- ==========================================
-- [ CONFIGURATION & REAL FUNCTIONS ]
-- ==========================================
local Config = {
    Graphics = { Shadows = false, PostEffects = false, Textures = false },
    World = { Particles = false, Terrain = false, PlayerParts = false },
    Engine = { LowQuality = false, Network = false, Physics = false },
    Memory = { AutoGC = true, FOVValue = 70 }
}

-- 1. Safe Engine Settings API Wrapper (Prevents Red Screen)
local function SafeEngineSetting(func)
    pcall(func)
end

-- 2. Graphics Real Optimization
local function ApplyGraphics()
    pcall(function()
        Services.Lighting.GlobalShadows = not Config.Graphics.Shadows
        
        for _, v in pairs(Services.Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                v.Enabled = not Config.Graphics.PostEffects
            end
        end
        
        if Config.Graphics.PostEffects then
            Services.Lighting.FogEnd = 1000000
            Services.Lighting.FogStart = 1000000
            Services.Lighting.Brightness = 1
            Services.Lighting.EnvironmentDiffuseScale = 0
            Services.Lighting.EnvironmentSpecularScale = 0
            Services.Lighting.Ambient = Color3.fromRGB(150, 150, 150) -- Flatten shadows
        end
    end)
end

-- 3. World Real Optimization (Dynamic & Static)
local function CullObject(inst)
    if not inst then return end
    if inst:IsA("ParticleEmitter") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") or inst:IsA("Explosion") then
        if Config.World.Particles then 
            pcall(function() inst.Enabled = false end) 
        end
    elseif inst:IsA("Decal") or inst:IsA("Texture") then
        if Config.Graphics.Textures then 
            pcall(function() inst.Transparency = 1 end) 
        end
    end
end

local function ApplyWorld()
    pcall(function()
        if Config.World.Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
            Terrain:Clear() -- Destroy grass/heavy terrain meshes
        end
    end)
    
    for _, v in ipairs(Services.Workspace:GetDescendants()) do CullObject(v) end
end

-- 4. Player Culling
local function ApplyPlayerCulling()
    pcall(function()
        for _, plr in pairs(Services.Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                for _, v in pairs(plr.Character:GetDescendants()) do
                    if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") then
                        if v:IsA("BasePart") then v.LocalTransparencyModifier = Config.World.PlayerParts and 1 or 0 end
                        if v:IsA("Clothing") then v.Transparency = Config.World.PlayerParts and 1 or 0 end
                    end
                end
            end
        end
    end)
end

-- 5. Deep Engine & Network Override
local function ApplyEngine()
    SafeEngineSetting(function()
        if Config.Engine.LowQuality then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Automatic
        end
    end)

    SafeEngineSetting(function()
        if Config.Engine.Network then
            settings().Network.IncomingReplicationLag = 100
        else
            settings().Network.IncomingReplicationLag = 0
        end
    end)

    SafeEngineSetting(function()
        if Config.Engine.Physics then
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
            settings().Physics.MaxPhysicsStepsPerFrame = 1
            settings().Physics.AllowSleep = true
        else
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
            settings().Physics.MaxPhysicsStepsPerFrame = 4
        end
    end)
end

-- 6. Aggressive Memory Cleanup
local function CleanMemory()
    pcall(function()
        -- Destroy unneeded debris
        for _, v in ipairs(Services.Workspace:GetDescendants()) do
            if v:IsA("Explosion") or (v:IsA("Sound") and not v.Playing) or v:IsA("Rocket") then
                v:Destroy()
            end
        end
        if Config.World.Terrain then Terrain:Clear() end
    end)
    -- Force Lua Garbage Collector
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 200)
end

-- 7. Camera FOV
local function ApplyFOV()
    if Camera then Camera.FieldOfView = Config.Memory.FOVValue end
end

-- [ EVENT LISTENERS ]
Services.Workspace.DescendantAdded:Connect(CullObject)
Services.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        ApplyPlayerCulling()
    end)
end)

-- Auto GC Loop (Prevents RAM overflow)
task.spawn(function()
    while task.wait(10) do
        if Config.Memory.AutoGC then CleanMemory() end
    end
end)

-- ==========================================
-- [ UI CONSTRUCTION (RAYFIELD) ]
-- ==========================================

-- Tab 1: Performance
local PerfTab = Window:CreateTab("Performance", 4483362458)
PerfTab:CreateSection("Real-time Culling")
PerfTab:CreateToggle({ Name = "Disable Shadows", CurrentValue = Config.Graphics.Shadows, Flag = "T_Shadow", Callback = function(v) Config.Graphics.Shadows = v; ApplyGraphics() end })
PerfTab:CreateToggle({ Name = "Disable Post-Effects (Bloom/DOF)", CurrentValue = Config.Graphics.PostEffects, Flag = "T_Post", Callback = function(v) Config.Graphics.PostEffects = v; ApplyGraphics() end })
PerfTab:CreateToggle({ Name = "Remove Textures/Decals", CurrentValue = Config.Graphics.Textures, Flag = "T_Tex", Callback = function(v) Config.Graphics.Textures = v; ApplyWorld() end })
PerfTab:CreateToggle({ Name = "Disable Particles & Effects", CurrentValue = Config.World.Particles, Flag = "T_Part", Callback = function(v) Config.World.Particles = v; ApplyWorld() end })
PerfTab:CreateToggle({ Name = "Optimize Terrain & Water", CurrentValue = Config.World.Terrain, Flag = "T_Terr", Callback = function(v) Config.World.Terrain = v; ApplyWorld() end })
PerfTab:CreateToggle({ Name = "Cull Player Accessories", CurrentValue = Config.World.PlayerParts, Flag = "T_Acc", Callback = function(v) Config.World.PlayerParts = v; ApplyPlayerCulling() end })

PerfTab:CreateSection("Quick Actions")
PerfTab:CreateButton({
    Name = "MAXIMUM PERFORMANCE MODE",
    Callback = function()
        Config.Graphics.Shadows = true; Config.Graphics.PostEffects = true; Config.Graphics.Textures = true
        Config.World.Particles = true; Config.World.Terrain = true; Config.World.PlayerParts = true
        Config.Engine.LowQuality = true; Config.Engine.Network = true; Config.Engine.Physics = true
        ApplyGraphics(); ApplyWorld(); ApplyPlayerCulling(); ApplyEngine(); CleanMemory()
        Rayfield:Notify({Title = "System", Content = "Max Performance Activated!", Duration = 4})
    end
})

-- Tab 2: Engine & System
local EngineTab = Window:CreateTab("Engine", 4483362458)
EngineTab:CreateSection("Engine Overrides (Mobile Safe)")
EngineTab:CreateToggle({ Name = "Force Low Quality Engine", CurrentValue = Config.Engine.LowQuality, Flag = "T_Eng", Callback = function(v) Config.Engine.LowQuality = v; ApplyEngine() end })
EngineTab:CreateToggle({ Name = "Network Lag Bypass", CurrentValue = Config.Engine.Network, Flag = "T_Net", Callback = function(v) Config.Engine.Network = v; ApplyEngine() end })
EngineTab:CreateToggle({ Name = "Physics Optimization (Reduce Heat)", CurrentValue = Config.Engine.Physics, Flag = "T_Phys", Callback = function(v) Config.Engine.Physics = v; ApplyEngine() end })

EngineTab:CreateSection("Camera Settings")
EngineTab:CreateSlider({ Name = "Field of View", Range = {50, 120}, Increment = 1, Suffix = "FOV", CurrentValue = Config.Memory.FOVValue, Flag = "S_FOV", Callback = function(v) Config.Memory.FOVValue = v; ApplyFOV() end })

-- Tab 3: Memory
local MemTab = Window:CreateTab("Memory", 4483362458)
MemTab:CreateSection("RAM & Heat Control")
MemTab:CreateToggle({ Name = "Auto Cleanup (Every 10s)", CurrentValue = Config.Memory.AutoGC, Flag = "T_GC", Callback = function(v) Config.Memory.AutoGC = v end })
MemTab:CreateButton({
    Name = "Force Clean Memory Now",
    Callback = function()
        CleanMemory()
        Rayfield:Notify({Title = "Memory", Content = "RAM Cleared Successfully", Duration = 3})
    end
})

-- Tab 4: Info
local InfoTab = Window:CreateTab("Info", 4483362458)
InfoTab:CreateLabel("NovaX Optimizer V6 | Premium Engine")
InfoTab:CreateLabel("Developer: Nhism")
InfoTab:CreateLabel("Status: Anti-Crash Active (Mobile Safe)")
InfoTab:CreateButton({ Name = "Copy Discord Link", Callback = function() if setclipboard then setclipboard("https://discord.gg/nhism") end end })

-- ==========================================
-- [ FIXED STANDALONE UI TOGGLE BUTTON ]
-- ==========================================
local function CreateUniversalToggle()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NovaX_UniversalToggle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999 -- Always on top
    
    -- Safe Parent
    local parentSuccess = pcall(function()
        if gethui then ScreenGui.Parent = gethui() 
        elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = Services.CoreGui
        else ScreenGui.Parent = Services.CoreGui end
    end)
    if not parentSuccess then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 55, 0, 55)
    Btn.Position = UDim2.new(1, -80, 0.5, -27)
    Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.Text = "N"
    Btn.TextColor3 = Color3.fromRGB(0, 170, 255)
    Btn.Font = Enum.Font.GothamBlack
    Btn.TextSize = 26
    Btn.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 170, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Btn
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217" -- Soft shadow
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ImageTransparency = 0.5
    Shadow.ZIndex = -1
    Shadow.Parent = Btn

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle Logic (Safe for Rayfield)
    Btn.MouseButton1Click:Connect(function()
        local toggleSuccess = pcall(function()
            Rayfield:Toggle()
        end)
        if not toggleSuccess then
            -- Fallback if Rayfield Toggle fails
            local mainGui = Services.CoreGui:FindFirstChild("Rayfield")
            if mainGui and mainGui:FindFirstChild("Main") then
                local mainFrame = mainGui.Main
                mainFrame.Visible = not mainFrame.Visible
            end
        end
    end)
end
CreateUniversalToggle()

-- Initial Application
ApplyGraphics()
Rayfield:Notify({
    Title = "NovaX V6 Loaded",
    Content = "Click the floating [N] button to open/close UI.",
    Duration = 5
})
