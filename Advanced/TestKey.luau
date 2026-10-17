-- [[ HỆ THỐNG KEY UI MACOS LIQUID GLASS (V7.1 STANDALONE) ]]
-- Tác giả: Nhism
-- Bản vá lỗi Executor: Hỗ trợ CoreGui fallback, chống crash loadstring.

-- [ BẢO VỆ MÔI TRƯỜNG ]
if not getgenv then getgenv = function() return _G end end
if not getgenv().NhismLoadCount then getgenv().NhismLoadCount = 0 end
getgenv().NhismLoadCount = getgenv().NhismLoadCount + 1

if getgenv().NhismLoadCount >= 10 then
    game:GetService("Players").LocalPlayer:Kick("[Nhism Hub] Anti-Cheat: Executor Spam Detected.")
    return
end

if not game:IsLoaded() then game.Loaded:Wait() end

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService")
}

local Player = Services.Players.LocalPlayer
local IsMobile = Services.UserInputService.TouchEnabled and not Services.UserInputService.KeyboardEnabled
local ScreenGuiName = "NhismKeySystem_V7_1"
local JsonFileName = "Nhism_Config_V7.json"

-- [ CẤU HÌNH TỪ BÊN NGOÀI ]
local Config = {
    Key = getgenv().Key or "",
    ID = getgenv().id or "Unknown_ID",
    Script_Mode = getgenv().Script_Mode or "Main"
}

local AllowedIDs = { ["153601438942"] = true, ["129198757199"] = true }
local FreeKeys = {"NHISM-FREE-111", "NHISM-FREE-222"}
local PremiumKeys = {"NHISM-PREMIUM-999", "NHISM-PREMIUM-888"}

local SupportedGames = {
    [2753915549] = "Blox Fruits", [4442272183] = "Blox Fruits",
    [7449423635] = "Blox Fruits", [18437661052] = "Steal A Egg"
}
local CurrentGameName = SupportedGames[game.PlaceId]

-- [ KIỂM TRA GAME ]
if not CurrentGameName then
    Player:Kick("[Nhism Hub] Game Not Supported. Please play Blox Fruits or Steal A Egg.")
    return
end

-- [ HÀM CHẠY SCRIPT CHÍNH ]
local function ExecuteGameScript(isPremium)
    local ScriptURLs = {
        Main = "https://raw.githubusercontent.com/yourname/yourrepo/main/main.lua",
        Kaitun = "https://raw.githubusercontent.com/yourname/yourrepo/main/kaitun.lua",
        Aimbot = "https://raw.githubusercontent.com/yourname/yourrepo/main/aimbot.lua",
        Fixlag = "https://raw.githubusercontent.com/yourname/yourrepo/main/fixlag.lua"
    }
    
    local TargetURL = ScriptURLs[Config.Script_Mode] or ScriptURLs["Main"]

    if TargetURL ~= "" and TargetURL:find("http") then
        local success, err = pcall(function()
            if type(loadstring) == "function" then
                loadstring(game:HttpGet(TargetURL))()
            else
                warn("[Nhism Hub] Executor không hỗ trợ loadstring.")
            end
        end)
        if not success then warn("[Nhism Hub] Lỗi tải script: " .. tostring(err)) end
    else
        print("[Hệ Thống] Chưa cài đặt Link Script cho Mode: " .. Config.Script_Mode)
    end
end

-- [ KIỂM TRA CONFIG TỰ ĐỘNG ]
if Config.Key ~= "" then
    local isValid = false
    for _, k in ipairs(FreeKeys) do if Config.Key == k then isValid = true break end end
    if not isValid then for _, k in ipairs(PremiumKeys) do if Config.Key == k then isValid = true break end end end

    if isValid then
        if AllowedIDs[Config.ID] or Config.ID == "Unknown_ID" then
            ExecuteGameScript(Config.Key:find("PREM") ~= nil)
            return
        else
            Player:Kick("[Nhism Hub] Config ID Discord không hợp lệ.")
            return
        end
    else
        Player:Kick("[Nhism Hub] Config Key không hợp lệ.")
        return
    end
end

-- [ HÀM HỖ TRỢ FILE JSON AN TOÀN ]
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
    if writefile then pcall(function() writefile(fileName, content) end) end
end

local SavedKey = ""
local fileData = SafeReadFile(JsonFileName)
if fileData then
    local success, result = pcall(function() return Services.HttpService:JSONDecode(fileData) end)
    if success and result and result.Key then SavedKey = result.Key end
end

-- [ XÁC ĐỊNH PARENT CHO UI (CHỐNG LỖI EXECUTOR CHẶN COREGUI) ]
local ParentGui = Services.CoreGui
if gethui then
    local success, hui = pcall(gethui)
    if success and hui then ParentGui = hui end
elseif Player:FindFirstChild("PlayerGui") then
    ParentGui = Player.PlayerGui
end

if ParentGui:FindFirstChild(ScreenGuiName) then
    ParentGui:FindFirstChild(ScreenGuiName):Destroy()
end

-- [ KHỞI TẠO UI ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.5
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local GlassGradient = Instance.new("UIGradient")
GlassGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 230, 255))
}
GlassGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(1, 0.95)
}
GlassGradient.Rotation = 45
GlassGradient.Parent = MainFrame

local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = IsMobile and 0.75 or 1

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
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

-- Kéo thả
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
Services.UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -60)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Sidebar.BackgroundTransparency = 0.4
Sidebar.Parent = MainFrame
local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

-- Profile
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
    btn.Size = UDim2.new(1, -20, 0, 35)
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
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    return btn
end

local KeyTabBtn = CreateTabButton("KeyTabBtn", "[*] Key System", 10)
local InfoTabBtn = CreateTabButton("InfoTabBtn", "[i] Information", 55)

-- Content Area
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -200, 1, -60)
ContentContainer.Position = UDim2.new(0, 190, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Key Page
local KeyPage = Instance.new("Frame")
KeyPage.Size = UDim2.new(1, 0, 1, 0)
KeyPage.BackgroundTransparency = 1
KeyPage.Parent = ContentContainer

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Authentication"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
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
    if TitleGradient then TitleGradient.Rotation = (tick() * 80) % 360 end
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

local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -20, 0, 42)
InputFrame.Position = UDim2.new(0, 0, 0, 60)
InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InputFrame.BackgroundTransparency = 0.3
InputFrame.Parent = KeyPage
local InCorner = Instance.new("UICorner")
InCorner.CornerRadius = UDim.new(0, 10)
InCorner.Parent = InputFrame
local InStroke = Instance.new("UIStroke")
InStroke.Color = Color3.fromRGB(255, 255, 255)
InStroke.Transparency = 0.4
InStroke.Parent = InputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -90, 1, 0)
KeyInput.Position = UDim2.new(0, 12, 0, 0)
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
PasteBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PasteBtn.BackgroundTransparency = 0.5
PasteBtn.Text = "Paste"
PasteBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
PasteBtn.Font = Enum.Font.GothamBold
PasteBtn.TextSize = 12
PasteBtn.Parent = InputFrame
local PasteCorner = Instance.new("UICorner")
PasteCorner.CornerRadius = UDim.new(0, 8)
PasteCorner.Parent = PasteBtn

PasteBtn.MouseButton1Click:Connect(function()
    if getclipboard then
        local success, clip = pcall(getclipboard)
        if success and clip then KeyInput.Text = clip end
    end
end)

local function CreateButton(text, pos, color, textColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -5, 0, 42)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = KeyPage
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = btn
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.5
    s.Parent = btn
    return btn
end

local GetKeyBtn = CreateButton("Get Key", UDim2.new(0, 0, 0, 115), Color3.fromRGB(0, 122, 255), Color3.fromRGB(255, 255, 255))
local SubmitBtn = CreateButton("Submit", UDim2.new(0.5, 5, 0, 115), Color3.fromRGB(52, 199, 89), Color3.fromRGB(255, 255, 255))
local DiscordBtn = CreateButton("Discord", UDim2.new(0, 0, 0, 165), Color3.fromRGB(88, 101, 242), Color3.fromRGB(255, 255, 255))
local WebsiteBtn = CreateButton("Website", UDim2.new(0.5, 5, 0, 165), Color3.fromRGB(40, 40, 40), Color3.fromRGB(255, 255, 255))

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
InfTxt.Text = string.format("Time: %s\nMode: %s\nGame: %s\nVersion: 7.1.0\n\nDeveloper: Nhism", os.date("%H:%M:%S - %d/%m/%Y"), Config.Script_Mode, CurrentGameName)
InfTxt.TextColor3 = Color3.fromRGB(50, 50, 50)
InfTxt.Font = Enum.Font.Gotham
InfTxt.TextSize = 13
InfTxt.TextXAlignment = Enum.TextXAlignment.Left
InfTxt.TextYAlignment = Enum.TextYAlignment.Top
InfTxt.Parent = InfoPage

local function SwitchTab(showPage, hidePage, activeBtn, inactiveBtn)
    hidePage.Visible = false
    showPage.Visible = true
    showPage.Position = UDim2.new(0, 15, 0, 0)
    Services.TweenService:Create(showPage, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    Services.TweenService:Create(activeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.6, TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
    Services.TweenService:Create(inactiveBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(50, 50, 50)}):Play()
end

KeyTabBtn.MouseButton1Click:Connect(function() SwitchTab(KeyPage, InfoPage, KeyTabBtn, InfoTabBtn) end)
InfoTabBtn.MouseButton1Click:Connect(function() SwitchTab(InfoPage, KeyPage, InfoTabBtn, KeyTabBtn) end)

local function ShowNotification(title, text, isSuccess)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 65)
    Notif.AnchorPoint = Vector2.new(0.5, 0)
    Notif.Position = UDim2.new(0.5, 0, 0, -120)
    Notif.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Notif.BackgroundTransparency = 0.1
    Notif.Parent = ScreenGui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 32)
    c.Parent = Notif
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.3
    s.Thickness = 1
    s.Parent = Notif
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -50, 0, 25)
    NTitle.Position = UDim2.new(0, 20, 0, 10)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = isSuccess and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 59, 48)
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextSize = 14
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notif
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -50, 0, 25)
    NText.Position = UDim2.new(0, 20, 0, 30)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(50, 50, 50)
    NText.Font = Enum.Font.GothamMedium
    NText.TextSize = 12
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = Notif

    Services.TweenService:Create(Notif, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 20)}):Play()
    task.delay(3, function()
        local out = Services.TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -120)})
        out:Play()
        out.Completed:Wait()
        Notif:Destroy()
    end)
end

GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard("https://link-to-your-key-system.com") end) end
    ShowNotification("Copied", "Key link copied.", true)
end)

DiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard("https://discord.gg/nhism") end) end
    ShowNotification("Copied", "Discord link copied.", true)
end)

WebsiteBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard("https://nhism.com") end) end
    ShowNotification("Copied", "Website link copied.", true)
end)

SubmitBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text
    local isPremium = false
    local isValid = false
    
    for _, k in ipairs(FreeKeys) do if enteredKey == k then isValid = true; isPremium = false; break end end
    if not isValid then for _, k in ipairs(PremiumKeys) do if enteredKey == k then isValid = true; isPremium = true; break end end end

    if isValid then
        local jsonData = Services.HttpService:JSONEncode({Key = enteredKey})
        SafeWriteFile(JsonFileName, jsonData)
        
        ShowNotification("Authenticated", "Key is valid. Loading...", true)
        task.wait(1)
        
        local closeTween = Services.TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 1.5, 0)})
        closeTween:Play()
        closeTween.Completed:Wait()
        
        ScreenGui:Destroy()
        ExecuteGameScript(isPremium)
    else
        ShowNotification("Failed", "Invalid key.", false)
                KeyInput.Text = ""
        task.wait(1)
        Player:Kick("[Nhism Hub] Invalid Key Attempt.")
    end
end)

SwitchTab(KeyPage, InfoPage, KeyTabBtn, InfoTabBtn)
