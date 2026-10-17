-- [[ NOVAX OPTIMIZER V4 - EXTREME PERFORMANCE ]]
-- Author: Nhism
-- Purpose: Deep engine intervention, aggressive memory management, and graphical culling to reduce heat and maximize FPS.

if not game:IsLoaded() then game.Loaded:Wait() end
if not getgenv then getgenv = function() return _G end end

local Services = {
    Players = game:GetService("Players"),
    Lighting = game:GetService("Lighting"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService"),
    CoreGui = game:GetService("CoreGui")
}

local LocalPlayer = Services.Players.LocalPlayer
local Terrain = Services.Workspace.Terrain
local Camera = Services.Workspace.CurrentCamera

-- Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "NovaX Optimizer V4",
    SubTitle = "Extreme Performance Engine | By Nhism",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = false, -- Disabled for performance
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Performance = Window:AddTab({ Title = "Performance", Icon = "zap" }),
    Engine = Window:AddTab({ Title = "Engine & Network", Icon = "cpu" }),
    Memory = Window:AddTab({ Title = "Memory & Heat", Icon = "hard-drive" }),
    Info = Window:AddTab({ Title = "Info", Icon = "info" })
}

local Options = Fluent.Options

-- [ CONFIGURATION STATE ]
local Config = {
    GraphicsCulling = false,
    PlayerCulling = false,
    ParticleCulling = false,
    TerrainCulling = false,
    EngineTweaks = false,
    NetworkTweaks = false,
    AutoGC = true,
    HideOtherPlayers = false
}

-- [ CORE FUNCTIONS ]

-- 1. Deep Graphics Culling
local function ApplyGraphicsCulling()
    Services.Lighting.GlobalShadows = not Config.GraphicsCulling
    
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("Clouds") then
            v.Enabled = not Config.GraphicsCulling
        end
    end
    
    if Config.GraphicsCulling then
        Services.Lighting.FogEnd = 100000
        Services.Lighting.FogStart = 100000
        Services.Lighting.Brightness = 1
        Services.Lighting.EnvironmentDiffuseScale = 0
        Services.Lighting.EnvironmentSpecularScale = 0
    end
end

-- 2. Particle & Texture Culling (Dynamic)
local function CullInstance(inst)
    if inst:IsA("ParticleEmitter") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") or inst:IsA("Explosion") then
        if Config.ParticleCulling then inst.Enabled = false end
    elseif inst:IsA("Decal") or inst:IsA("Texture") then
        if Config.GraphicsCulling then inst.Transparency = 1 end
    end
end

-- 3. Terrain Culling
local function ApplyTerrainCulling()
    if Config.TerrainCulling then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        pcall(function() Terrain:Clear() end) -- Clears heavy grass/details
    end
end

-- 4. Player Culling (Hide accessories/clothes)
local function ApplyPlayerCulling()
    for _, plr in pairs(Services.Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, v in pairs(plr.Character:GetDescendants()) do
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") then
                    if v:IsA("BasePart") then v.LocalTransparencyModifier = Config.PlayerCulling and 1 or 0 end
                    if v:IsA("Clothing") then v.Transparency = Config.PlayerCulling and 1 or 0 end
                end
                if Config.HideOtherPlayers and v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.LocalTransparencyModifier = 1
                end
            end
        end
    end
end

-- 5. Engine Tweaks (Settings API)
local function ApplyEngineTweaks()
    pcall(function()
        if Config.EngineTweaks then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
            settings().Physics.MaxPhysicsStepsPerFrame = 1
            settings().Physics.AllowSleep = true
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Automatic
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
            settings().Physics.MaxPhysicsStepsPerFrame = 4
        end
    end)
end

-- 6. Network Tweaks (Reduce CPU Load)
local function ApplyNetworkTweaks()
    pcall(function()
        if Config.NetworkTweaks then
            settings().Network.IncomingReplicationLag = 100 -- Reduces network overhead / CPU spikes
        else
            settings().Network.IncomingReplicationLag = 0
        end
    end)
end

-- 7. Memory Cleanup (Garbage Collection & Cache Clear)
local function ForceCleanMemory()
    pcall(function()
        -- Destroy useless instances
        for _, v in ipairs(Services.Workspace:GetDescendants()) do
            if v:IsA("Explosion") or (v:IsA("Sound") and not v.Playing) then
                v:Destroy()
            end
        end
        -- Clear Terrain if culling is on
        if Config.TerrainCulling then
            Terrain:Clear()
        end
    end)
    -- Force Lua Garbage Collector
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 200)
end

-- [ EVENT LISTENERS ]
Services.Workspace.DescendantAdded:Connect(CullInstance)

Services.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1.5)
        ApplyPlayerCulling()
    end)
end)

-- Auto Cleanup Loop
task.spawn(function()
    while task.wait(20) do
        if Config.AutoGC then
            ForceCleanMemory()
        end
    end
end)

-- [ UI SETUP ]
Tabs.Performance:AddSection("Graphics Culling")
local T_Graphics = Tabs.Performance:AddToggle("T_Graphics", { Title = "Disable Shadows & Post-Effects", Description = "Disables Bloom, Blur, DOF, and Global Shadows.", Default = Config.GraphicsCulling })
T_Graphics:OnChanged(function(Value) Config.GraphicsCulling = Value; ApplyGraphicsCulling() end)

local T_Particles = Tabs.Performance:AddToggle("T_Particles", { Title = "Disable Particles & Textures", Description = "Stops rendering Smoke, Fire, and Decals.", Default = Config.ParticleCulling })
T_Particles:OnChanged(function(Value) Config.ParticleCulling = Value; for _, v in ipairs(Services.Workspace:GetDescendants()) do CullInstance(v) end end)

local T_Terrain = Tabs.Performance:AddToggle("T_Terrain", { Title = "Flat Terrain & Water", Description = "Clears terrain details to save massive GPU/CPU usage.", Default = Config.TerrainCulling })
T_Terrain:OnChanged(function(Value) Config.TerrainCulling = Value; ApplyTerrainCulling() end)

Tabs.Performance:AddSection("Entity Culling")
local T_PlayerCull = Tabs.Performance:AddToggle("T_PlayerCull", { Title = "Cull Player Accessories", Description = "Hides hats, clothes, and meshes of other players.", Default = Config.PlayerCulling })
T_PlayerCull:OnChanged(function(Value) Config.PlayerCulling = Value; ApplyPlayerCulling() end)

local T_HidePlayers = Tabs.Performance:AddToggle("T_HidePlayers", { Title = "Hide Other Players (Rendering)", Description = "Makes other players completely invisible to save FPS.", Default = Config.HideOtherPlayers })
T_HidePlayers:OnChanged(function(Value) Config.HideOtherPlayers = Value; ApplyPlayerCulling() end)

Tabs.Performance:AddButton({ Title = "MAXIMUM PERFORMANCE OVERRIDE", Description = "Enables ALL graphical and engine optimizations instantly.", Callback = function()
    T_Graphics:SetValue(true); T_Particles:SetValue(true); T_Terrain:SetValue(true)
    T_PlayerCull:SetValue(true); T_HidePlayers:SetValue(true); Options.T_Engine:SetValue(true)
    Options.T_Network:SetValue(true)
    Fluent:Notify({ Title = "System", Content = "Maximum Performance Mode Activated!", Duration = 5 })
end })

-- TAB: ENGINE
Tabs.Engine:AddSection("Roblox Engine Tweaks")
local T_Engine = Tabs.Engine:AddToggle("T_Engine", { Title = "Force Low Quality Engine", Description = "Overrides Roblox rendering limits (Level 01).", Default = Config.EngineTweaks })
T_Engine:OnChanged(function(Value) Config.EngineTweaks = Value; ApplyEngineTweaks() end)

Tabs.Engine:AddSection("Network Optimization")
local T_Network = Tabs.Engine:AddToggle("T_Network", { Title = "Network Replication Lag Bypass", Description = "Reduces server-to-client data load to prevent CPU spikes.", Default = Config.NetworkTweaks })
T_Network:OnChanged(function(Value) Config.NetworkTweaks = Value; ApplyNetworkTweaks() end)

Tabs.Engine:AddButton({ Title = "Apply Engine Overrides", Description = "Pushes all engine settings immediately.", Callback = function()
    ApplyEngineTweaks()
    ApplyNetworkTweaks()
    Fluent:Notify({ Title = "System", Content = "Engine Overrides Applied.", Duration = 3 })
end })

-- TAB: MEMORY
Tabs.Memory:AddSection("Memory Management")
local T_AutoGC = Tabs.Memory:AddToggle("T_AutoGC", { Title = "Auto RAM Cleanup", Description = "Clears garbage memory and useless instances every 20s.", Default = Config.AutoGC })
T_AutoGC:OnChanged(function(Value) Config.AutoGC = Value end)

Tabs.Memory:AddButton({ Title = "Force Memory Cleanup Now", Description = "Triggers Garbage Collector and clears cache.", Callback = function()
    ForceCleanMemory()
    Fluent:Notify({ Title = "Memory", Content = "RAM Cleared Successfully!", Duration = 3 })
end })

-- TAB: INFO
Tabs.Info:AddParagraph({
    Title = "NovaX Optimizer V4",
    Content = "Deep System Intervention Script.\nAuthor: Nhism\n\nThis script deeply modifies the Roblox engine, rendering pipeline, and memory management to drastically lower CPU/GPU temperatures, prevent RAM overflow, and maximize FPS across all games."
})

Tabs.Info:AddButton({ Title = "Copy Discord Link", Description = "discord.gg/nhism", Callback = function()
    if setclipboard then setclipboard("https://discord.gg/nhism") end
    Fluent:Notify({Title="Copied", Content="Discord link copied.", Duration=3})
end })

-- [ FLOATING TOGGLE BUTTON ]
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "NovaXToggleUI"
ToggleGui.ResetOnSpawn = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.Parent = Services.CoreGui

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(1, -70, 0.5, -25)
FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatBtn.Text = "N"
FloatBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 24
FloatBtn.Parent = ToggleGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(0, 170, 255)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn

-- Drag Logic for Floating Button
local dragging, dragInput, dragStart, startPos
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
FloatBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
Services.UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle Logic
FloatBtn.MouseButton1Click:Connect(function()
    if Window.RootFrame.Visible then
        Window:Minimize()
    else
        Window:Restore()
    end
end)

-- [ STARTUP ]
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("NovaXOptimizerV4")
SaveManager:SetFolder("NovaXOptimizerV4/Configs")
InterfaceManager:BuildInterfaceSection(Tabs.Info)
SaveManager:BuildConfigSection(Tabs.Info)

Window:SelectTab(1)
Fluent:Notify({
    Title = "NovaX Optimizer V4",
    Content = "Loaded. Press [RightShift] or click the [N] button to toggle UI.",
    Duration = 6
})
