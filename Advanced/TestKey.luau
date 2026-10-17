--[[
    HỆ THỐNG KEY UI MACOS / LIQUID GLASS IOS 27
    Tác giả: Nhism
    Ngôn ngữ: Luau (Roblox)
    Chức năng: Xác thực Key Free/Premium, Nhận diện Game, Tối ưu Mobile/PC, Hủy UI sau khi chạy.
    Yêu cầu: Executor hỗ trợ UI Library, getclipboard, setclipboard.
]]

-- Khai báo Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Biến môi trường
local Player = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ScreenGuiName = "NhismKeySystem_UI"

-- Dọn dẹp UI cũ tránh lag (Quy tắc 6)
if CoreGui:FindFirstChild(ScreenGuiName) then
    CoreGui:FindFirstChild(ScreenGuiName):Destroy()
end

-- Cấu hình Key (Mô phỏng Server Database)
local KeyDatabase = {
    FreeKeys = {"NHISM-FREE-111", "NHISM-FREE-222"},
    PremiumKeys = {"NHISM-PREMIUM-999", "NHISM-PREMIUM-888"}
}

-- Nhận diện Game (Quy tắc 3)
local SupportedGames = {
    [2753915549] = "Blox Fruits",
    [6516141723] = "Doors",
    [1962086868] = "Tower of Hell"
}
local CurrentGameName = SupportedGames[game.PlaceId] or "Unknown Game"

-- Khởi tạo UI Chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

-- Hiệu ứng Kính khúc xạ (Blur) cho toàn màn hình
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 15
BlurEffect.Parent = game.Lighting

-- Hàm tạo hiệu ứng Liquid Glass
local function ApplyGlassStyle(element, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 16)
    corner.Parent = element
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.7
    stroke.Thickness = 1
    stroke.Parent = element
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 0.8)
    }
    gradient.Rotation = 45
    gradient.Parent = element
end

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
ApplyGlassStyle(MainFrame, 20)

-- Tối ưu Mobile
local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
if IsMobile then
    UIScale.Scale = 0.65 -- Thu nhỏ UI trên điện thoại
else
    UIScale.Scale = 1
end

-- Thanh Tiêu Đề (MacOS Style)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

-- Nút đỏ, vàng, xanh (MacOS)
for i, color in ipairs({Color3.fromRGB(255, 95, 86), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)}) do
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(0, 12, 0, 12)
    btn.Position = UDim2.new(0, 15 + (i * 20), 0.5, -6)
    btn.BackgroundColor3 = color
    btn.Parent = TitleBar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = btn
end

-- Logic Kéo Thả UI (Quy tắc 4)
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
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar (Menu Trái)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -60)
Sidebar.Position = UDim2.new(0, 10, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BackgroundTransparency = 0.5
Sidebar.Parent = MainFrame
ApplyGlassStyle(Sidebar, 12)

-- Container cho các Tab
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -200, 1, -60)
TabContainer.Position = UDim2.new(0, 190, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Hàm tạo Tab Button
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
    ApplyGlassStyle(btn, 8)
    return btn
end

-- Tạo các Tab
local KeyTabBtn = CreateTabButton("KeyTabBtn", "🔑 Key System", 10)
local InfoTabBtn = CreateTabButton("InfoTabBtn", "ℹ️ Information", 55)

-- Trang Key (Tab 1)
local KeyPage = Instance.new("Frame")
KeyPage.Name = "KeyPage"
KeyPage.Size = UDim2.new(1, 0, 1, 0)
KeyPage.BackgroundTransparency = 1
KeyPage.Parent = TabContainer

-- Tiêu đề trang Key
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "Nhập Key Để Tiếp Tục"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 24
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
KeyTitle.Parent = KeyPage

-- Khung Nhập Key
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -20, 0, 50)
InputFrame.Position = UDim2.new(0, 0, 0, 60)
InputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputFrame.BackgroundTransparency = 0.3
InputFrame.Parent = KeyPage
ApplyGlassStyle(InputFrame, 10)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -100, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "Nhập Key Free hoặc Premium..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 16
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.Parent = InputFrame

-- Nút Dán (Paste)
local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(0, 80, 1, -10)
PasteBtn.Position = UDim2.new(1, -85, 0, 5)
PasteBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PasteBtn.Text = "Dán"
PasteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PasteBtn.Font = Enum.Font.GothamBold
PasteBtn.TextSize = 14
PasteBtn.Parent = InputFrame
ApplyGlassStyle(PasteBtn, 8)
PasteBtn.MouseButton1Click:Connect(function()
    if getclipboard then
        KeyInput.Text = getclipboard()
    else
        KeyInput.Text = "Lỗi: Executor không hỗ trợ getclipboard"
    end
end)

-- Nút Get Key
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(1, -20, 0, 45)
GetKeyBtn.Position = UDim2.new(0, 0, 0, 130)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
GetKeyBtn.Text = "Lấy Key Tại Đây (Get Key)"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 16
GetKeyBtn.Parent = KeyPage
ApplyGlassStyle(GetKeyBtn, 10)
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://link-to-your-key-system.com")
    end
    -- Hiển thị thông báo (Sẽ tạo hàm sau)
    print("Đã copy link get key.")
end)

-- Nút Submit
local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(1, -20, 0, 45)
SubmitBtn.Position = UDim2.new(0, 0, 0, 190)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
SubmitBtn.Text = "Xác Nhận (Submit)"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 16
SubmitBtn.Parent = KeyPage
ApplyGlassStyle(SubmitBtn, 10)

-- Trang Info (Tab 2)
local InfoPage = Instance.new("Frame")
InfoPage.Name = "InfoPage"
InfoPage.Size = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible = false
InfoPage.Parent = TabContainer

-- Text Info
local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, 0, 1, 0)
InfoText.BackgroundTransparency = 1
InfoText.Text = string.format([[
    THÔNG TIN HỆ THỐNG

    - Thời Gian: %s
    - Ngôn Ngữ: Tiếng Việt (Luau)
    - Vùng: Global
    - Trạng Thái Key: Online (Server: Beta)
    - Phiên Bản: v1.0.0
    - Tạo Bởi: Nhism
    - Cập Nhật: Hệ thống UI Liquid Glass IOS 27
    
    [ LIÊN KẾT ]
    - Discord: discord.gg/nhism
    - Website: nhism.com
]], os.date("%H:%M:%S - %d/%m/%Y"))
InfoText.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 14
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Parent = InfoPage

-- Logic Chuyển Tab & Animation
local function SwitchTab(pageToShow, pageToHide, activeBtn, inactiveBtn)
    pageToHide.Visible = false
    pageToShow.Visible = true
    
    TweenService:Create(activeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
    TweenService:Create(inactiveBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
end

KeyTabBtn.MouseButton1Click:Connect(function() SwitchTab(KeyPage, InfoPage, KeyTabBtn, InfoTabBtn) end)
InfoTabBtn.MouseButton1Click:Connect(function() SwitchTab(InfoPage, KeyPage, InfoTabBtn, KeyTabBtn) end)

-- Hệ Thống Thông Báo (Liquid Glass IOS Style) (Quy tắc 5)
local function ShowNotification(title, text, isSuccess)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 80)
    Notif.Position = UDim2.new(0.5, -150, 0, -100) -- Bắt đầu từ trên màn hình
    Notif.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Notif.BackgroundTransparency = 0.2
    Notif.Parent = ScreenGui
    ApplyGlassStyle(Notif, 16)
    
    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -20, 0, 30)
    NotifTitle.Position = UDim2.new(0, 10, 0, 10)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = title
    NotifTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextSize = 16
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Parent = Notif
    
    local NotifText = Instance.new("TextLabel")
    NotifText.Size = UDim2.new(1, -20, 0, 40)
    NotifText.Position = UDim2.new(0, 10, 0, 35)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = text
    NotifText.TextColor3 = isSuccess and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 59, 48)
    NotifText.Font = Enum.Font.GothamMedium
    NotifText.TextSize = 14
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    NotifText.TextWrapped = true
    NotifText.Parent = Notif

    -- Animation Nảy (iOS Style)
    Notif.Position = UDim2.new(0.5, -150, 0, -100)
    local tweenIn = TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0, 20)})
    tweenIn:Play()
    
    task.delay(3, function()
        local tweenOut = TweenService:Create(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -150, 0, -100)})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        Notif:Destroy()
    end)
end

-- Logic Xử Lý Submit (Quy tắc 2 & 6)
SubmitBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text
    local isPremium = false
    local isValid = false
    
    -- Kiểm tra Key Free
    for _, key in ipairs(KeyDatabase.FreeKeys) do
        if enteredKey == key then
            isValid = true
            isPremium = false
            break
        end
    end
    
    -- Kiểm tra Key Premium
    if not isValid then
        for _, key in ipairs(KeyDatabase.PremiumKeys) do
            if enteredKey == key then
                isValid = true
                isPremium = true
                break
            end
        end
    end

    if isValid then
        ShowNotification("Thành Công", "Đã xác thực Key " .. (isPremium and "Premium" or "Free") .. "!", true)
        task.wait(1) -- Chờ thông báo
        
        -- Tắt hẵn UI (Quy tắc 6)
        BlurEffect:Destroy()
        ScreenGui:Destroy()
        
        -- Thực thi Script dựa vào Game
        task.spawn(function()
            if CurrentGameName ~= "Unknown Game" then
                print("Đang tải Script cho: " .. CurrentGameName .. " | Loại: " .. (isPremium and "Premium" or "Free"))
                -- TẠI ĐÂY: GỌI HÀM LOAD SCRIPT TƯƠNG ỨNG VỚI GAME VÀ KEY
                -- Ví dụ: loadstring(game:HttpGet("link_script_" .. CurrentGameName .. "_" .. (isPremium and "prem" or "free"))))()
            else
                print("Game không được hỗ trợ.")
            end
        end)
    else
        ShowNotification("Lỗi", "Key không hợp lệ. Vui lòng thử lại!", false)
        KeyInput.Text = "" -- Xóa key
        -- Kick người dùng (nếu cần thiết theo yêu cầu)
        -- Player:Kick("Key Sai!") 
    end
end)
