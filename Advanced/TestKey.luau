--[[
    HỆ THỐNG KEY UI MACOS LIGHT (V5 - BẢN HOÀN CHỈNH)
    Tác giả: Nhism

    [ CÁCH SỬ DỤNG CONFIG CHUẨN XÁC - ĐỌC KỸ ]
    Lỗi "Không Thể Executor" ở bản trước do cú pháp loadstring của bạn bị lồng sai.
    Để chạy tự động qua Config, hãy copy ĐÚNG đoạn code dưới đây vào Executor:

    getgenv().Key = "NHISM-PREMIUM-999"
    getgenv().id = "153601438942"
    getgenv().Script_Mode = "Main" -- Hoặc "Kaitun"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/pichunii/TestServer/refs/heads/main/Advanced/TestKey.luau"))()

    [ LƯU Ý ]
    - Nếu bạn điền Key sai trong Config, hệ thống sẽ tự động Kick.
    - Nếu bạn để trống Config Key (hoặc không chạy Config), UI sẽ hiện lên để nhập.
    - Script đã được bọc pcall toàn diện để chống crash Executor nếu thiếu hàm (như isfile, writefile).
]]

-- Kiểm tra môi trường Executor
if not game:IsLoaded() then game.Loaded:Wait() end

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService"),
    Lighting = game:GetService("Lighting")
}

local Player = Services.Players.LocalPlayer
local IsMobile = Services.UserInputService.TouchEnabled and not Services.UserInputService.KeyboardEnabled
local ScreenGuiName = "NhismKeySystem_V5"
local JsonFileName = "Nhism_Config_V5.json"

-- [ CẤU HÌNH HỆ THỐNG TỪ BÊN NGOÀI ]
local Config = {
    Key = getgenv().Key or "",
    ID = getgenv().id or "Unknown_ID",
    Script_Mode = getgenv().Script_Mode or "Main"
}

-- [ DANH SÁCH ID DISCORD ĐƯỢC PHÉP (WHITELIST) ]
local AllowedIDs = {
    ["153601438942"] = true,
    ["129198757199"] = true
}

-- [ DATABASE KEY ]
local FreeKeys = {"NHISM-FREE-111", "NHISM-FREE-222"}
local PremiumKeys = {"NHISM-PREMIUM-999", "NHISM-PREMIUM-888"}

-- [ DANH SÁCH GAME HỖ TRỢ ]
local SupportedGames = {
    [2753915549] = "Blox Fruits", 
    [4442272183] = "Blox Fruits",
    [7449423635] = "Blox Fruits",
    [18437661052] = "Steal A Egg"
}
local CurrentGameName = SupportedGames[game.PlaceId]

-- [ LOGIC KICK GAME KHÔNG HỖ TRỢ ]
if not CurrentGameName then
    Player:Kick("[Nhism Hub] Unsupported Game. Please play Blox Fruits or Steal A Egg.")
    return
end

-- [ HÀM CHẠY SCRIPT CHÍNH ]
local function ExecuteGameScript(isPremium)
    -- THAY LINK SCRIPT RAW CỦA BẠN VÀO ĐÂY
    local MainScriptURL = "https://raw.githubusercontent.com/yourname/yourrepo/main/main.lua"
    local KaitunScriptURL = "https://raw.githubusercontent.com/yourname/yourrepo/main/kaitun.lua"
    
    local TargetURL = (Config.Script_Mode == "Kaitun") and KaitunScriptURL or MainScriptURL

    if TargetURL ~= "" and TargetURL:find("http") then
        local success, err = pcall(function()
            loadstring(game:HttpGet(TargetURL))()
        end)
        if not success then
            warn("[Nhism Hub] Lỗi tải script: " .. tostring(err))
        end
    else
        print("[Hệ Thống] Chưa cài đặt Link Script trong ExecuteGameScript.")
    end
end

-- [ KIỂM TRA CONFIG TỰ ĐỘNG (QUY TẮC 6) ]
if Config.Key ~= "" then
    local isValid = false
    for _, k in ipairs(FreeKeys) do if Config.Key == k then isValid = true break end end
    if not isValid then for _, k in ipairs(PremiumKeys) do if Config.Key == k then isValid = true break end end end

    if isValid then
        if AllowedIDs[Config.ID] or Config.ID == "Unknown_ID" then
            ExecuteGameScript(Config.Key:find("PREM") ~= nil)
            return -- Chạy thẳng script, không hiện UI
        else
            Player:Kick("[Nhism Hub] Config ID Discord không hợp lệ.")
            return
        end
    else
        Player:Kick("[Nhism Hub] Config Key không hợp lệ.")
        return
    end
end

-- [ HÀM HỖ TRỢ FILE JSON AN TOÀN (CHỐNG CRASH EXECUTOR) ]
local function SafeReadFile(fileName)
    if isfile and readfile then
        local success, result = pcall(function()
            if isfile(fileName) then return readfile(fileName) end
        end)
        if success and result then return result end
    end
    return nil
end

local function SafeWriteFile(fileName, content)
    if writefile then
        pcall(function() writefile(fileName, content) end)
    end
end

-- Tải Key đã lưu
local SavedKey = ""
local fileData = SafeReadFile(JsonFileName)
if fileData then
    local success, result = pcall(function() return Services.HttpService:JSONDecode(fileData) end)
    if success and result and result.Key then
        SavedKey = result.Key
    end
end

-- Dọn dẹp UI cũ
if Services.CoreGui:FindFirstChild(ScreenGuiName) then
    Services.CoreGui:FindFirstChild(ScreenGuiName):Destroy()
end

-- [ KHỞI TẠO UI - MACOS LIGHT THEME ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Services.CoreGui

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Neo giữa màn hình
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(200, 200, 200)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = IsMobile and 0.75 or 1

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

for i, color in ipairs({Color3.fromRGB(255, 95, 86), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)}) do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 15 + ((i-1) * 20), 0.5, -6)
    dot.BackgroundColor3 = color
    dot.Parent = TitleBar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = dot
end

-- [ LOGIC KÉO THẢ FIX LỖI HOÀN TOÀN ]
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
Services.UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
Sidebar.Parent = MainFrame
local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

-- Profile (Dưới bên trái)
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, -20, 0, 50)
ProfileFrame.AnchorPoint = Vector2.new(0, 1)
ProfileFrame.Position = UDim2.new(0, 10, 1, -10)
ProfileFrame.BackgroundTransparency = 1
ProfileFrame.Parent = Sidebar

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 36, 0, 36)
Avatar.Position = UDim2.new(0, 5, 0.5, -18)
Avatar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
Avatar.Parent = ProfileFrame
local AvaCorner = Instance.new("UICorner")
AvaCorner.CornerRadius = UDim.new(1, 0)
AvaCorner.Parent = Avatar

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(1, -50, 0, 20)
NameLabel.Position = UDim2.new(0, 50, 0.5, -10)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = Player.DisplayName
NameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 13
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = ProfileFrame

local IdLabel = Instance.new("TextLabel")
IdLabel.Size = UDim2.new(1, -50, 0, 15)
IdLabel.Position = UDim2.new(0, 50, 0.5, 8)
IdLabel.BackgroundTransparency = 1
IdLabel.Text = "@" .. Player.Name
IdLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
IdLabel.Font = Enum.Font.Gotham
IdLabel.TextSize = 11
IdLabel.TextXAlignment = Enum.TextXAlignment.Left
IdLabel.Parent = ProfileFrame

-- Tab Buttons
local function CreateTabButton(name, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.Parent = Sidebar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local KeyTabBtn = CreateTabButton("KeyTabBtn", "[*] Key System", 10)
local InfoTabBtn = CreateTabButton("InfoTabBtn", "[i] Information", 50)

-- Content Area
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -200, 1, -50)
ContentContainer.Position = UDim2.new(0, 190, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Key Page
local KeyPage = Instance.new("Frame")
KeyPage.Size = UDim2.new(1, 0, 1, 0)
KeyPage.BackgroundTransparency = 1
KeyPage.Parent = ContentContainer

-- [ RAINBOW TITLE ]
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Authentication"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = KeyPage

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(128, 0, 255)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 128, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128))
}
TitleGradient.Parent = Title

Services.RunService.RenderStepped:Connect(function()
    if TitleGradient then
        TitleGradient.Rotation = (tick() * 80) % 360
    end
end)

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 30)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Enter your key to load the script."
Subtitle.TextColor3 = Color3.fromRGB(100, 100, 100)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = KeyPage

-- Input Frame
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -20, 0, 40)
InputFrame.Position = UDim2.new(0, 0, 0, 70)
InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InputFrame.Parent = KeyPage
local InCorner = Instance.new("UICorner")
InCorner.CornerRadius = UDim.new(0, 8)
InCorner.Parent = InputFrame
local InStroke = Instance.new("UIStroke")
InStroke.Color = Color3.fromRGB(200, 200, 200)
InStroke.Parent = InputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -90, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = SavedKey
KeyInput.PlaceholderText = "Enter Key Here..."
KeyInput.TextColor3 = Color3.fromRGB(0, 0, 0)
KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.Parent = InputFrame

local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(0, 70, 1, -10)
PasteBtn.Position = UDim2.new(1, -75, 0, 5)
PasteBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
PasteBtn.Text = "Paste"
PasteBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
PasteBtn.Font = Enum.Font.GothamBold
PasteBtn.TextSize = 12
PasteBtn.Parent = InputFrame
local PasteCorner = Instance.new("UICorner")
PasteCorner.CornerRadius = UDim.new(0, 6)
PasteCorner.Parent = PasteBtn

PasteBtn.MouseButton1Click:Connect(function()
    if getclipboard then
        local success, clip = pcall(getclipboard)
        if success and clip then KeyInput.Text = clip end
    end
end)

-- Buttons
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.5, -5, 0, 40)
GetKeyBtn.Position = UDim2.new(0, 0, 0, 125)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 14
GetKeyBtn.Parent = KeyPage
local GetCorner = Instance.new("UICorner")
GetCorner.CornerRadius = UDim.new(0, 8)
GetCorner.Parent = GetKeyBtn

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.5, -5, 0, 40)
SubmitBtn.Position = UDim2.new(0.5, 5, 0, 125)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
SubmitBtn.Text = "Submit"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 14
SubmitBtn.Parent = KeyPage
local SubCorner = Instance.new("UICorner")
SubCorner.CornerRadius = UDim.new(0, 8)
SubCorner.Parent = SubmitBtn

-- Info Page
local InfoPage = Instance.new("Frame")
InfoPage.Size = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible = false
InfoPage.Parent = ContentContainer

local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, 0, 0, 30)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "Information"
InfoTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextSize = 20
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.Parent = InfoPage

local InfTxt = Instance.new("TextLabel")
InfTxt.Size = UDim2.new(1, 0, 1, -30)
InfTxt.Position = UDim2.new(0, 0, 0, 30)
InfTxt.BackgroundTransparency = 1
InfTxt.Text = string.format([[
    Time: %s
    Mode: %s
    Game: %s
    Version: 5.0.0
    
    Developer: Nhism
    Discord: discord.gg/nhism
]], os.date("%H:%M:%S - %d/%m/%Y"), Config.Script_Mode, CurrentGameName)
InfTxt.TextColor3 = Color3.fromRGB(50, 50, 50)
InfTxt.Font = Enum.Font.Gotham
InfTxt.TextSize = 13
InfTxt.TextXAlignment = Enum.TextXAlignment.Left
InfTxt.TextYAlignment = Enum.TextYAlignment.Top
InfTxt.Parent = InfoPage

-- Tab Switching
local function SwitchTab(showPage, hidePage, activeBtn, inactiveBtn)
    hidePage.Visible = false
    showPage.Visible = true
    Services.TweenService:Create(activeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    Services.TweenService:Create(inactiveBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end

KeyTabBtn.MouseButton1Click:Connect(function() SwitchTab(KeyPage, InfoPage, KeyTabBtn, InfoTabBtn) end)
InfoTabBtn.MouseButton1Click:Connect(function() SwitchTab(InfoPage, KeyPage, InfoTabBtn, KeyTabBtn) end)

-- Notification System
local function ShowNotification(title, text, isSuccess)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 60)
    Notif.AnchorPoint = Vector2.new(0.5, 0)
    Notif.Position = UDim2.new(0.5, 0, 0, -100)
    Notif.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Notif.Parent = ScreenGui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = Notif
    local s = Instance.new("UIStroke")
    s.Color = isSuccess and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 59, 48)
    s.Parent = Notif
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -20, 0, 25)
    NTitle.Position = UDim2.new(0, 10, 0, 5)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = s.Color
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextSize = 14
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notif
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -20, 0, 25)
    NText.Position = UDim2.new(0, 10, 0, 25)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(50, 50, 50)
    NText.Font = Enum.Font.Gotham
    NText.TextSize = 12
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = Notif

    Services.TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 20)}):Play()
    
    task.delay(3, function()
        local out = Services.TweenService:Create(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -100)})
        out:Play()
        out.Completed:Wait()
        Notif:Destroy()
    end)
end

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then 
        pcall(function() setclipboard("https://link-to-your-key-system.com") end)
    end
    ShowNotification("Copied", "Key link copied to clipboard.", true)
end)

-- [ LOGIC SUBMIT VÀ LƯU JSON ]
SubmitBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text
    local isPremium = false
    local isValid = false
    
    for _, k in ipairs(FreeKeys) do if enteredKey == k then isValid = true; isPremium = false; break end end
    if not isValid then for _, k in ipairs(PremiumKeys) do if enteredKey == k then isValid = true; isPremium = true; break end end end

    if isValid then
        local jsonData = Services.HttpService:JSONEncode({Key = enteredKey})
        SafeWriteFile(JsonFileName, jsonData)
        
        ShowNotification("Authenticated", "Key is valid. Loading script...", true)
        task.wait(1)
        ScreenGui:Destroy()
        ExecuteGameScript(isPremium)
    else
        ShowNotification("Authentication Failed", "Invalid key.", false)
        KeyInput.Text = ""
        task.wait(1)
        Player:Kick("[Nhism Hub] Invalid Key Attempt.")
    end
end)

SwitchTab(KeyPage, InfoPage, KeyTabBtn, InfoTabBtn)
