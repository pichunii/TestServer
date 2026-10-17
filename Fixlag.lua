-- [[ NOVAX OPTIMIZER - FIX LAG ULTIMATE ]]
-- Tác giả: Nhism
-- UI: x2zu Stellar (Dummy UI)

if not game:IsLoaded() then game.Loaded:Wait() end
if not getgenv then getgenv = function() return _G end end

local Services = {
    Players = game:GetService("Players"),
    Lighting = game:GetService("Lighting"),
    Workspace = game:GetService("Workspace"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Terrain = Services.Workspace.Terrain
local ConfigFile = "NovaX_Optimizer_Config.json"

-- [ CẤU HÌNH TRẠNG THÁI ]
local Config = {
    DisableShadows = false,
    DisableParticles = false,
    DisableTextures = false,
    DisableLightingEffects = false,
    OptimizeTerrain = false,
    UltraFPS = false,
    WaterTransparency = false
}

-- [ HÀM XỬ LÝ FIX LAG ]
local function ApplyShadows()
    Services.Lighting.GlobalShadows = not Config.DisableShadows
end

local function ApplyParticles()
    for _, v in pairs(Services.Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = not Config.DisableParticles
        end
    end
end

local function ApplyTextures()
    for _, v in pairs(Services.Workspace:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = Config.DisableTextures and 1 or 0
        end
    end
end

local function ApplyLightingEffects()
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            v.Enabled = not Config.DisableLightingEffects
        end
    end
    if Config.DisableLightingEffects then
        Services.Lighting.FogEnd = 1e10
        Services.Lighting.Brightness = 1
    end
end

local function ApplyTerrain()
    Terrain.WaterWaveSize = Config.OptimizeTerrain and 0 or 0.15
    Terrain.WaterWaveSpeed = Config.OptimizeTerrain and 0 or 10
    Terrain.WaterReflectance = Config.OptimizeTerrain and 0 or 0.1
    if Config.OptimizeTerrain then
        -- Xoá cỏ và hiệu ứng địa hình nặng
        Terrain:Clear()
    end
end

local function ApplyWater()
    Terrain.WaterTransparency = Config.WaterTransparency and 1 or 0.3
end

local function ApplyUltraFPS()
    if Config.UltraFPS then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    else
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
    end
end

-- Tự động áp dụng lại khi có vật thể mới spawn
Services.Workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
        if Config.DisableParticles then v.Enabled = false end
    elseif v:IsA("Decal") or v:IsA("Texture") then
        if Config.DisableTextures then v.Transparency = 1 end
    end
end)

-- [ HÀM LƯU / TẢI CONFIG ]
local function LoadConfig()
    if isfile and readfile and isfile(ConfigFile) then
        local success, data = pcall(function() return Services.HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and data then
            for k, v in pairs(data) do
                if Config[k] ~= nil then Config[k] = v end
            end
            -- Áp dụng ngay khi load
            ApplyShadows(); ApplyParticles(); ApplyTextures(); ApplyLightingEffects(); ApplyTerrain(); ApplyWater(); ApplyUltraFPS()
        end
    end
end

local function SaveConfig()
    if writefile then
        pcall(function() writefile(ConfigFile, Services.HttpService:JSONEncode(Config)) end)
    end
end

-- [ KHỞI TẠO UI ]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local Window = Library:Window({
    Title = "NovaX Optimizer",
    Desc = "By Nhism | Fix Lag Ultimate",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = { Enabled = true, Text = "NovaX" }
})

-- ==========================================
-- TAB: HOME (CHỨC NĂNG FIX LAG)
-- ==========================================
local HomeTab = Window:Tab({Title = "Home", Icon = "home"}) do
    HomeTab:Section({Title = "Cấu Hình Fix Lag Cơ Bản"})

    HomeTab:Toggle({
        Title = "Tắt Bóng Đổ (Disable Shadows)",
        Desc = "Giảm tải GPU đáng kể, tăng FPS",
        Value = Config.DisableShadows,
        Callback = function(v)
            Config.DisableShadows = v
            ApplyShadows()
        end
    })

    HomeTab:Toggle({
        Title = "Tắt Hiệu Ứng Hạt (Disable Particles)",
        Desc = "Ẩn khói, lửa, tia lửa gây lag",
        Value = Config.DisableParticles,
        Callback = function(v)
            Config.DisableParticles = v
            ApplyParticles()
        end
    })

    HomeTab:Toggle({
        Title = "Tắt Hình Ảnh/Decal (Disable Textures)",
        Desc = "Ẩn texture trên tường, đất, nhân vật",
        Value = Config.DisableTextures,
        Callback = function(v)
            Config.DisableTextures = v
            ApplyTextures()
        end
    })

    HomeTab:Toggle({
        Title = "Tắt Hiệu Ứng Ánh Sáng (Disable Post-Effects)",
        Desc = "Tắt Bloom, Blur, DOF, ColorCorrection",
        Value = Config.DisableLightingEffects,
        Callback = function(v)
            Config.DisableLightingEffects = v
            ApplyLightingEffects()
        end
    })

    HomeTab:Section({Title = "Tối Ưu Đồ Hoạ Nâng Cao"})

    HomeTab:Toggle({
        Title = "Tối Ưu Địa Hình & Nước (Terrain Optimize)",
        Desc = "Xoá cỏ, giảm sóng nước, tăng FPS mạnh",
        Value = Config.OptimizeTerrain,
        Callback = function(v)
            Config.OptimizeTerrain = v
            ApplyTerrain()
        end
    })

    HomeTab:Toggle({
        Title = "Nước Trong Suốt (Clear Water)",
        Desc = "Giảm render nước, nhìn xuyên thấu",
        Value = Config.WaterTransparency,
        Callback = function(v)
            Config.WaterTransparency = v
            ApplyWater()
        end
    })

    HomeTab:Toggle({
        Title = "ULTRA FPS BOOST",
        Desc = "Ép chất lượng đồ hoạ xuống mức thấp nhất (Level 01)",
        Value = Config.UltraFPS,
        Callback = function(v)
            Config.UltraFPS = v
            ApplyUltraFPS()
            Window:Notify({Title = "Hệ Thống", Desc = v and "Đã bật Ultra FPS!" or "Đã tắt Ultra FPS!", Time = 3})
        end
    })

    HomeTab:Button({
        Title = "Kích Hoạt Toàn Bộ Fix Lag",
        Desc = "Bật tất cả tính năng tối ưu cùng lúc",
        Callback = function()
            Config.DisableShadows = true; ApplyShadows()
            Config.DisableParticles = true; ApplyParticles()
            Config.DisableTextures = true; ApplyTextures()
            Config.DisableLightingEffects = true; ApplyLightingEffects()
            Config.OptimizeTerrain = true; ApplyTerrain()
            Config.WaterTransparency = true; ApplyWater()
            Config.UltraFPS = true; ApplyUltraFPS()
            
            -- Cập nhật UI (Yêu cầu người dùng bật lại toggle thủ công nếu UI không tự update)
            Window:Notify({Title = "Tối Ưu Hoá", Desc = "Đã áp dụng toàn bộ cấu hình Fix Lag.", Time = 4})
        end
    })
end

-- ==========================================
-- TAB: SETTING (LƯU / TẢI CONFIG)
-- ==========================================
local SettingTab = Window:Tab({Title = "Settings", Icon = "wrench"}) do
    SettingTab:Section({Title = "Quản Lý Cấu Hình"})

    SettingTab:Button({
        Title = "Lưu Cấu Hình (Save Config)",
        Desc = "Lưu trạng thái hiện tại vào file JSON",
        Callback = function()
            SaveConfig()
            Window:Notify({Title = "Config", Desc = "Đã lưu cấu hình thành công!", Time = 3})
        end
    })

    SettingTab:Button({
        Title = "Tải Cấu Hình (Load Config)",
        Desc = "Tải lại cấu hình đã lưu trước đó",
        Callback = function()
            LoadConfig()
            Window:Notify({Title = "Config", Desc = "Đã tải cấu hình!", Time = 3})
        end
    })
end

-- ==========================================
-- TAB: INFO (THÔNG TIN)
-- ==========================================
local InfoTab = Window:Tab({Title = "Info", Icon = "info"}) do
    InfoTab:Section({Title = "Thông Tin Script"})
    
    InfoTab:Textbox({
        Title = "Phiên Bản",
        Desc = "NovaX Optimizer V1.0.0",
        Placeholder = "1.0.0",
        Value = "1.0.0",
        ClearTextOnFocus = false,
        Callback = function() end
    })
    
    InfoTab:Textbox({
        Title = "Tác Giả",
        Desc = "Nhism",
        Placeholder = "Nhism",
        Value = "Nhism",
        ClearTextOnFocus = false,
        Callback = function() end
    })
    
    InfoTab:Section({Title = "Liên Kết"})
    
    InfoTab:Button({
        Title = "Copy Link Discord",
        Desc = "discord.gg/nhism",
        Callback = function()
            if setclipboard then setclipboard("https://discord.gg/nhism") end
            Window:Notify({Title = "Copied", Desc = "Đã copy link Discord.", Time = 3})
        end
    })
    
    InfoTab:Button({
        Title = "Copy Link Website",
        Desc = "nhism.com",
        Callback = function()
            if setclipboard then setclipboard("https://nhism.com") end
            Window:Notify({Title = "Copied", Desc = "Đã copy link Website.", Time = 3})
        end
    })
end

-- Tải cấu hình tự động khi khởi động
LoadConfig()
Window:Notify({
    Title = "NovaX Optimizer",
    Desc = "Đã tải thành công. Nhấn LeftControl để mở/đóng UI.",
    Time = 5
})
