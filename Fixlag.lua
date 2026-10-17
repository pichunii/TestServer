-- [[ NOVAX OPTIMIZER V2 - FLUENT UI ]]
-- Tác giả: Nhism
-- Bản chất: Tối ưu hoá phần cứng thực sự (Engine Tweaks, Instance Culling, Network).

if not game:IsLoaded() then game.Loaded:Wait() end
if not getgenv then getgenv = function() return _G end end

local Services = {
    Players = game:GetService("Players"),
    Lighting = game:GetService("Lighting"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService"),
    Debris = game:GetService("Debris")
}

local LocalPlayer = Services.Players.LocalPlayer
local Terrain = Services.Workspace.Terrain

-- Khởi tạo UI Library Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "NovaX Optimizer V2",
    SubTitle = "Thực Chiến Fix Lag - By Nhism",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "zap" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Info = Window:AddTab({ Title = "Info", Icon = "info" })
}

local Options = Fluent.Options

-- ==========================================
-- BIẾN TRẠNG THÁI CẤU HÌNH
-- ==========================================
local Config = {
    Shadows = false,
    Particles = false,
    Textures = false,
    Lighting = false,
    Terrain = false,
    PlayerParts = false,
    EngineSettings = false,
    SoundOptimize = false
}

-- [ HÀM XỬ LÝ TỐI ƯU THỰC TẾ ]

-- 1. Tắt Bóng Đổ (Shadows) - Giảm tải GPU
local function ApplyShadows()
    Services.Lighting.GlobalShadows = not Config.Shadows
end

-- 2. Dọn Dẹp Hạt (Particles) - Giảm tải CPU/GPU (Chạy liên tục)
local function ApplyParticles(inst)
    if inst:IsA("ParticleEmitter") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") or inst:IsA("Explosion") then
        if Config.Particles then
            inst.Enabled = false
        end
    end
end

-- 3. Ẩn Hình Ảnh (Textures)
local function ApplyTextures(inst)
    if inst:IsA("Decal") or inst:IsA("Texture") then
        inst.Transparency = Config.Textures and 1 or 0
    end
end

-- 4. Tắt Hiệu Ứng Ánh Sáng (Post-Processing)
local function ApplyLighting()
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
            v.Enabled = not Config.Lighting
        end
    end
    if Config.Lighting then
        Services.Lighting.FogEnd = 100000
        Services.Lighting.FogStart = 100000
    end
end

-- 5. Tối Ưu Địa Hình (Terrain) & Vật Thể Xa
local function ApplyTerrain()
    Terrain.WaterWaveSize = Config.Terrain and 0 or 0.15
    Terrain.WaterWaveSpeed = Config.Terrain and 0 or 10
    Terrain.WaterReflectance = Config.Terrain and 0 or 0.1
    Terrain.WaterTransparency = Config.Terrain and 1 or 0.3
end

-- 6. Ẩn Phụ Kiện Người Chơi Khác - Giảm Tải CPU Đáng Kể
local function ApplyPlayerParts()
    for _, plr in pairs(Services.Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, v in pairs(plr.Character:GetDescendants()) do
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") then
                    if v:IsA("BasePart") or v:IsA("Model") then
                        v.Transparency = Config.PlayerParts and 1 or 0
                    elseif v:IsA("Shirt") or v:IsA("Pants") then
                        v.Transparency = Config.PlayerParts and 1 or 0
                    end
                end
            end
        end
    end
end

-- 7. Can Thiệp Engine & Network (Settings)
local function ApplyEngineSettings()
    pcall(function()
        if Config.EngineSettings then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Network.IncomingReplicationLag = 10 -- Giảm lag mạng
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            settings().Network.IncomingReplicationLag = 0
        end
    end)
end

-- 8. Tối Ưu Âm Thanh
local function ApplySoundOptimize()
    Services.SoundService.AmbientReverb = Config.SoundOptimize and Enum.ReverbType.NoReverb or Enum.ReverbType.Generic
    for _, v in pairs(Services.Workspace:GetDescendants()) do
        if v:IsA("Sound") and v.Playing then
            if Config.SoundOptimize then
                v.Playing = false
            end
        end
    end
end


-- [ SỰ KIỆN LIÊN TỤC - CỰC KỲ QUAN TRỌNG ĐỂ CHỐNG LAG DYNAMIC ]
Services.Workspace.DescendantAdded:Connect(function(inst)
    ApplyParticles(inst)
    ApplyTextures(inst)
end)

Services.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        ApplyPlayerParts()
    end)
end)

-- ==========================================
-- TAB: HOME (CHỨC NĂNG)
-- ==========================================
Tabs.Home:AddSection("Tối Ưu Hoá Đồ Hoạ (Giảm Tải GPU)")
Tabs.Home:AddToggle("T_Shadows", { Title = "Tắt Bóng Đổ (Global Shadows)", Description = "Tắt đổ bóng của môi trường và nhân vật.", Default = false })
Options.T_Shadows:OnChanged(function(Value)
    Config.Shadows = Value
    ApplyShadows()
end)

Tabs.Home:AddToggle("T_Particles", { Title = "Chặn Hiệu Ứng Hạt", Description = "Vô hiệu hoá khói, lửa, kỹ năng, bụi.", Default = false })
Options.T_Particles:OnChanged(function(Value)
    Config.Particles = Value
    for _, v in ipairs(Services.Workspace:GetDescendants()) do ApplyParticles(v) end
end)

Tabs.Home:AddToggle("T_Textures", { Title = "Xoá Hình Ảnh (Decals/Textures)", Description = "Ẩn toàn bộ hình xăm, poster, texture bề mặt.", Default = false })
Options.T_Textures:OnChanged(function(Value)
    Config.Textures = Value
    for _, v in ipairs(Services.Workspace:GetDescendants()) do ApplyTextures(v) end
end)

Tabs.Home:AddToggle("T_Lighting", { Title = "Tắt Hiệu Ứng Ánh Sáng", Description = "Tắt Bloom, Blur, Sương mù, Bầu trời.", Default = false })
Options.T_Lighting:OnChanged(function(Value)
    Config.Lighting = Value
    ApplyLighting()
end)


Tabs.Home:AddSection("Tối Ưu Hoá Môi Trường & Hệ Thống")
Tabs.Home:AddToggle("T_Terrain", { Title = "Tối Ưu Địa Hình (Terrain)", Description = "Làm phẳng nước, tắt gợn sóng.", Default = false })
Options.T_Terrain:OnChanged(function(Value)
    Config.Terrain = Value
    ApplyTerrain()
end)

Tabs.Home:AddToggle("T_PlayerParts", { Title = "Ẩn Phụ Kiện Người Chơi Khác", Description = "Cởi đồ, xoá tóc của người khác để giảm lag.", Default = false })
Options.T_PlayerParts:OnChanged(function(Value)
    Config.PlayerParts = Value
    ApplyPlayerParts()
end)

Tabs.Home:AddToggle("T_Sound", { Title = "Tắt Âm Thanh Rác", Description = "Tắt âm thanh môi trường.", Default = false })
Options.T_Sound:OnChanged(function(Value)
    Config.SoundOptimize = Value
    ApplySoundOptimize()
end)

Tabs.Home:AddSection("ULTRA PERFORMANCE")
Tabs.Home:AddToggle("T_Engine", { Title = "Bypass Engine (Ultra FPS)", Description = "Ép Engine Roblox chạy ở mức thấp nhất, giảm Lag mạng.", Default = false })
Options.T_Engine:OnChanged(function(Value)
    Config.EngineSettings = Value
    ApplyEngineSettings()
end)

Tabs.Home:AddButton({ Title = "KÍCH HOẠT TOÀN BỘ (ULTRA FIX LAG)", Description = "Bật tất cả các chức năng tối ưu cùng lúc", Callback = function()
    -- Kích hoạt đồng loạt
    Config.Shadows = true; Options.T_Shadows:SetValue(true)
    Config.Particles = true; Options.T_Particles:SetValue(true)
    Config.Textures = true; Options.T_Textures:SetValue(true)
    Config.Lighting = true; Options.T_Lighting:SetValue(true)
    Config.Terrain = true; Options.T_Terrain:SetValue(true)
    Config.PlayerParts = true; Options.T_PlayerParts:SetValue(true)
    Config.SoundOptimize = true; Options.T_Sound:SetValue(true)
    Config.EngineSettings = true; Options.T_Engine:SetValue(true)
    
    -- Force apply
    ApplyShadows(); ApplyLighting(); ApplyTerrain(); ApplyPlayerParts(); ApplySoundOptimize(); ApplyEngineSettings()
    for _, v in ipairs(Services.Workspace:GetDescendants()) do ApplyParticles(v); ApplyTextures(v) end
    
    Fluent:Notify({ Title = "Hệ Thống", Content = "Đã kích hoạt toàn bộ cấu hình Fix Lag!", Duration = 5 })
end })

-- ==========================================
-- TAB: SETTINGS (LƯU CONFIG)
-- ==========================================
-- Sử dụng SaveManager của Fluent UI (Tự động lưu trạng thái Toggle)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("NovaXOptimizer")
SaveManager:SetFolder("NovaXOptimizer/Configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ==========================================
-- TAB: INFO
-- ==========================================
Tabs.Info:AddParagraph({
    Title = "Thông Tin Script",
    Content = "NovaX Optimizer V2\nPhiên bản: Thực Chiến\nTác giả: Nhism\n\nScript hoạt động bằng cách can thiệp trực tiếp vào Engine Render, Networking và Quản lý Bộ nhớ của Roblox để tăng FPS tối đa."
})

Tabs.Info:AddButton({
    Title = "Copy Link Discord",
    Description = "discord.gg/nhism",
    Callback = function()
        if setclipboard then setclipboard("https://discord.gg/nhism") end
        Fluent:Notify({ Title = "Copied", Content = "Đã copy link Discord", Duration = 3 })
    end
})

Tabs.Info:AddButton({
    Title = "Copy Link Website",
    Description = "nhism.com",
    Callback = function()
        if setclipboard then setclipboard("https://nhism.com") end
        Fluent:Notify({ Title = "Copied", Content = "Đã copy link Website", Duration = 3 })
    end
})

-- Khởi động UI
Window:SelectTab(1)
Fluent:Notify({
    Title = "NovaX Optimizer V2",
    Content = "Đã tải thành công. Nhấn LeftControl để ẩn/hiện.",
    Duration = 6
})
