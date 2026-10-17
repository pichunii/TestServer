--[[
    HỆ THỐNG KEY UI MACOS / LIQUID GLASS IOS 27 (UPDATE V2)
    Tác giả: Nhism
    Ngôn ngữ: Luau (Roblox)
    Chức năng: Xác thực Key, Config Support, Game Detection, UI Animation.
    Yêu cầu: Executor hỗ trợ UI Library, getclipboard, setclipboard, getgenv.
]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Player & Environment
local Player = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ScreenGuiName = "NhismKeySystem_UI_V2"

-- Cấu hình Config (Cho phép người dùng chỉnh sửa bên ngoài)
local Config = {
    Key = getgenv().Key or nil,
    ID = getgenv().id or "Unknown_ID",
    Script_Mode = getgenv().Script_Mode or "Main" -- "Main" hoặc "Kaitun"
}

-- Danh sách Game hỗ trợ
local SupportedGames = {
    [2753915549] = "Blox Fruits", -- Blox Fruits Main
    [4442272183] = "Blox Fruits", -- Blox Fruits 2
    [7449423635] = "Blox Fruits", -- Blox Fruits 3
    [18437661052] = "Steal A Egg" -- Placeholder ID cho Steal A Egg
}

local CurrentGameName = SupportedGames[game.PlaceId]

-- Kiểm tra Game hỗ trợ (Quy tắc 2: Kick nếu không support)
if not CurrentGameName then
    Player:Kick("[Nhism Hub] Game Not Supported. Please play Blox Fruits or Steal A Egg.")
    return
end

-- Hàm thực thi Script Game (Mô phỏng)
local function ExecuteGameScript(keyType)
    print(string.format("[Hệ thống] Đang tải Script cho %s | Mode: %s | Key: %s", CurrentGameName, Config.Script_Mode, keyType))
    -- TẠI ĐÂY: Thêm logic loadstring cho từng game dựa vào Config.Script_Mode và Key.
    -- VD: 
    -- if CurrentGameName == "Blox Fruits" then
    --    if Config.Script_Mode == "Kaitun" then loadstring(game:HttpGet("URL_KAITUN"))() else loadstring(game:HttpGet("URL_MAIN"))() end
    -- end
end

-- Kiểm tra Auto-Run từ Config (Quy tắc 5)
if Config.Key and Config.Key ~= "" then
    -- Giả lập kiểm tra key tự động
    if Config.Key:find("NHISM-") then
        ExecuteGameScript("Config_Auto")
        return -- Dừng script, không hiện UI
    end
end

-- Dọn dẹp UI cũ
if CoreGui:FindFirstChild(ScreenGuiName) then
    CoreGui:FindFirstChild(ScreenGuiName):Destroy()
end

-- Khởi tạo UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

-- Hiệu ứng Blur nền
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 20
BlurEffect.Parent = Lighting

-- Hàm tạo Liquid Glass Style
local function ApplyGlass(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = element
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = element
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0.95)
    }
    gradient.Rotation = 45
    gradient.Parent = element
end

-- Main Window (MacOS Style)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 680, 0, 440)
MainFrame.Position = UDim2.new(0.5, -340, 1.5, 0) -- Bắt đầu từ dưới màn hình để tạo animation
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
ApplyGlass(MainFrame, 16)

-- Tối ưu Mobile (Quy tắc 6)
local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = IsMobile and 0.65 or 1

-- Animation Trượt Lên (Quy tắc 4)
local SlideIn = TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -340, 0.5, -220)
})
SlideIn:Play()

-- Title Bar (MacOS Dots)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

for i, color in ipairs({Color3.fromRGB(255, 95, 86), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)}) do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 15 + (i * 18), 0.5, -5)
    dot.BackgroundColor3 = color
    dot.Parent = TitleBar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = dot
end

-- Kéo thả UI
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar (MacOS Layout)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 200, 1, -60)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Sidebar.BackgroundTransparency = 0.4
Sidebar.Parent = MainFrame
ApplyGlass(Sidebar, 12)

-- Profile Section (Quy tắc 3)
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, -20, 0, 60)
ProfileFrame.Position = UDim2.new(0, 10, 0, 10)
ProfileFrame.BackgroundTransparency = 1
ProfileFrame.Parent = Sidebar

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 45, 0, 45)
Avatar.Position = UDim2.new(0, 5, 0.5, -22)
Avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
Avatar.Parent = ProfileFrame
ApplyGlass(Avatar, 22)

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(1, -60, 0, 20)
NameLabel.Position = UDim2.new(0, 60, 0.5, -10)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = Player.DisplayName
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 14
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = ProfileFrame

local IdLabel = Instance.new("TextLabel")
IdLabel.Size = UDim2.new(1, -60, 0, 15)
IdLabel.Position = UDim2.new(0, 60, 0.5, 8)
IdLabel.BackgroundTransparency = 1
IdLabel.Text = "@" .. Player.Name
IdLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
IdLabel.Font = Enum.Font.Gotham
IdLabel.TextSize = 12
IdLabel.TextXAlignment = Enum.TextXAlignment.Left
IdLabel.Parent = ProfileFrame

-- Tab Buttons (Không dùng Emoji)
local function CreateTabButton(name, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.9
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.Parent = Sidebar
    ApplyGlass(btn, 8)
    return btn
end

local KeyTabBtn = CreateTabButton("KeyTabBtn", "[*] Key System", 80)
local InfoTabBtn = CreateTabButton("InfoTabBtn", "[i] Information", 125)

-- Container cho Content
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -220, 1, -60)
ContentContainer.Position = UDim2.new(0, 210, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Key Page
local KeyPage = Instance.new("Frame")
KeyPage.Size = UDim2.new(1, 0, 1, 0)
KeyPage.BackgroundTransparency = 1
KeyPage.Parent = ContentContainer

-- Rainbow Title (Quy tắc 1: Cải cách UI)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Authentication Required"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 26
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = KeyPage

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(128, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 128, 255))
}
TitleGradient.Parent = Title

-- Xoay màu Rainbow
RunService.RenderStepped:Connect(function()
    TitleGradient.Rotation = (tick() * 50) % 360
end)

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 40)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Please enter your key to proceed."
Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 14
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = KeyPage

-- Input Frame (iOS Style)
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -10, 0, 45)
InputFrame.Position = UDim2.new(0, 0, 0, 80)
InputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
InputFrame.BackgroundTransparency = 0.2
InputFrame.Parent = KeyPage
ApplyGlass(InputFrame, 10)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -100, 1, 0)
KeyInput.Position = UDim2.new(0, 15, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "Enter Key Here..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 15
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.Parent = InputFrame

local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(0, 70, 1, -10)
PasteBtn.Position = UDim2.new(1, -80, 0, 5)
PasteBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PasteBtn.Text = "Paste"
PasteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PasteBtn.Font = Enum.Font.GothamBold
PasteBtn.TextSize = 13
PasteBtn.Parent = InputFrame
ApplyGlass(PasteBtn, 8)

PasteBtn.MouseButton1Click:Connect(function()
    if getclipboard then KeyInput.Text = getclipboard() end
end)

-- Buttons Grid
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.5, -5, 0, 45)
GetKeyBtn.Position = UDim2.new(0, 0, 0, 140)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255) -- iOS Blue
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 15
GetKeyBtn.Parent = KeyPage
ApplyGlass(GetKeyBtn, 10)

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.5, -5, 0, 45)
SubmitBtn.Position = UDim2.new(0.5, 5, 0, 140)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89) -- iOS Green
SubmitBtn.Text = "Submit"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 15
SubmitBtn.Parent = KeyPage
ApplyGlass(SubmitBtn, 10)

-- Info Page
local InfoPage = Instance.new("Frame")
InfoPage.Size = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible = false
InfoPage.Parent = ContentContainer

local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, 0, 0, 40)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "System Information"
InfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextSize = 22
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.Parent = InfoPage

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, 0, 1, -40)
InfoText.Position = UDim2.new(0, 0, 0, 40)
InfoText.BackgroundTransparency = 1
InfoText.Text = string.format([[
    Time: %s
    Language: Luau (English)
    Region: Global
    Key Status: Online (Server: Beta)
    Version: 2.0.0 (Liquid Glass)
    Developer: Nhism
    Discord: discord.gg/nhism
    Website: nhism.com
    
    Game Detected: %s
    Script Mode: %s
]], os.date("%H:%M:%S - %d/%m/%Y"), CurrentGameName, Config.Script_Mode)
InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 14
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Parent = InfoPage

-- Logic Chuyển Tab & Animation
local function SwitchTab(showPage, hidePage, activeBtn, inactiveBtn)
    hidePage.Visible = false
    showPage.Visible = true
    showPage.Position = UDim2.new(0, 20, 0, 0) -- Bắt đầu hơi lệch
    showPage.BackgroundTransparency = 1
    
    TweenService:Create(showPage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    TweenService:Create(activeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
    TweenService:Create(inactiveBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
end

KeyTabBtn.MouseButton1Click:Connect(function() SwitchTab(KeyPage, InfoPage, KeyTabBtn, InfoTabBtn) end)
InfoTabBtn.MouseButton1Click:Connect(function() SwitchTab(InfoPage, KeyPage, InfoTabBtn, KeyTabBtn) end)

-- Hệ thống Thông báo (IOS 27 Style)
local function ShowNotification(title, text, isSuccess)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 320, 0, 70)
    Notif.Position = UDim2.new(0.5, -160, 0, -100)
    Notif.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Notif.BackgroundTransparency = 0.15
    Notif.Parent = ScreenGui
    ApplyGlass(Notif, 16)
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -20, 0, 25)
    NTitle.Position = UDim2.new(0, 15, 0, 10)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = isSuccess and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 59, 48)
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextSize = 16
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notif
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -20, 0, 30)
    NText.Position = UDim2.new(0, 15, 0, 35)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(30, 30, 30)
    NText.Font = Enum.Font.GothamMedium
    NText.TextSize = 14
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.TextWrapped = true
    NText.Parent = Notif

    -- iOS Spring Animation
    Notif.Position = UDim2.new(0.5, -160, 0, -100)
    TweenService:Create(Notif, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -160, 0, 20)}):Play()
    
    task.delay(3, function()
        local out = TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -160, 0, -100)})
        out:Play()
        out.Completed:Wait()
        Notif:Destroy()
    end)
end

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard("https://link-to-your-key-system.com") end
    ShowNotification("Success", "Key link copied to clipboard.", true)
end)

-- Logic Submit & Tắt UI (Quy tắc 1, 5, 6)
SubmitBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text
    local isPremium = false
    local isValid = false
    
    -- Giả lập Database
    local FreeKeys = {"NHISM-FREE-111"}
    local PremiumKeys = {"NHISM-PREMIUM-999"}
    
    for _, k in ipairs(FreeKeys) do if enteredKey == k then isValid = true; isPremium = false; break end end
    if not isValid then for _, k in ipairs(PremiumKeys) do if enteredKey == k then isValid = true; isPremium = true; break end end end

    if isValid then
        ShowNotification("Authenticated", "Key is valid. Loading script...", true)
        task.wait(1.2) -- Chờ thông báo
        
        -- Animation Khi Thực Thi (Quy tắc 1)
        local FadeOut = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -340, 1.5, 0),
            BackgroundTransparency = 1
        })
        FadeOut:Play()
        
        local BlurOut = TweenService:Create(BlurEffect, TweenInfo.new(0.4), {Size = 0})
        BlurOut:Play()
        
        FadeOut.Completed:Wait()
        
        -- Tắt hẵn UI (Quy tắc 6)
        BlurEffect:Destroy()
        ScreenGui:Destroy()
        
        -- Gọi hàm chạy script
        ExecuteGameScript(isPremium and "Premium" or "Free")
    else
        ShowNotification("Authentication Failed", "Invalid key. Please try again.", false)
        KeyInput.Text = ""
    end
end)
