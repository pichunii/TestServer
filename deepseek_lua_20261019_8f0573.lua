--==================================================================
-- FARIAL HUB UI - CHUẨN MACOS TÍCH HỢP DYNAMIC ISLAND
-- Loại: LocalScript
-- Vị trí: StarterPlayer > StarterPlayerScripts
-- Tác giả: Nhism Developer
-- Tối ưu: Chống đen màn hình, Responsive PC/Mobile, Dynamic Island
--==================================================================

local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local Lighting           = game:GetService("Lighting")
local GuiService         = game:GetService("GuiService")
local SoundService       = game:GetService("SoundService")
local StarterGui         = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

--==================== DỌN DẸP GUI CŨ (FIX LỖI ĐEN MÀN HÌNH) ====================
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) -- Khôi phục CoreGui đề phòng bị tắt
end)

for _, gui in pairs(PlayerGui:GetChildren()) do
	if gui:IsA("ScreenGui") and (gui.Name == "FarialHubUI" or gui.Name == "LoadingUI") then
		gui:Destroy()
	end
end

--==================== BẢNG MÀU & FONT ====================
local Theme = {
	Background       = Color3.fromRGB(24, 24, 26),
	Surface          = Color3.fromRGB(36, 36, 38),
	SurfaceHover     = Color3.fromRGB(50, 50, 52),
	Stroke           = Color3.fromRGB(70, 70, 72),
	Text             = Color3.fromRGB(245, 245, 247),
	TextSecondary    = Color3.fromRGB(152, 152, 157),
	Accent           = Color3.fromRGB(10, 132, 255),
	Success          = Color3.fromRGB(48, 209, 88),
	Warning          = Color3.fromRGB(255, 159, 10),
	Danger           = Color3.fromRGB(255, 69, 58),
	Shadow           = Color3.fromRGB(0, 0, 0),
}

local Font       = Enum.Font.Gotham
local FontMedium = Enum.Font.GothamMedium
local FontBold   = Enum.Font.GothamBold

--==================== MODULE TIỆN ÍCH ====================
local UIS = {}

function UIS.Create(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do obj[k] = v end
	for _, child in ipairs(children or {}) do child.Parent = obj end
	return obj
end

function UIS.Tween(obj, props, time, style, dir)
	local info = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

function UIS.Corner(radius)
	return UIS.Create("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

function UIS.Stroke(color, thickness, transparency)
	return UIS.Create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0.3,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function UIS.Ripple(button, color)
	button.ClipsDescendants = true
	button.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local ripple = UIS.Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(input.Position.X - button.AbsolutePosition.X, input.Position.Y - button.AbsolutePosition.Y),
			Size = UDim2.fromOffset(0, 0),
			BackgroundColor3 = color or Theme.Text,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			ZIndex = button.ZIndex + 2,
			Parent = button,
		})
		UIS.Corner(999)
		local tw = UIS.Tween(ripple, { Size = UDim2.fromOffset(button.AbsoluteSize.X * 2.5, button.AbsoluteSize.X * 2.5), BackgroundTransparency = 1 }, 0.5)
		tw.Completed:Connect(function() ripple:Destroy() end)
	end)
end

local function PlayClick()
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://12221967"
	s.Volume = 0.1
	s.Parent = SoundService
	s:Play()
	game:GetService("Debris"):AddItem(s, 1)
end

--==================== SCREEN GUI GỐC & RESPONSIVE SCALE ====================
local ScreenGui = UIS.Create("ScreenGui", {
	Name = "FarialHubUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
	Parent = PlayerGui,
})

local MainScale = UIS.Create("UIScale", { Scale = 1, Parent = ScreenGui })

local function UpdateResponsiveScale()
	local vp = Camera.ViewportSize
	local scale = 1
	if vp.X < 800 then -- Mobile
		scale = vp.X / 850
	elseif vp.X < 1400 then -- Tablet / Small PC
		scale = vp.X / 1400
	else -- PC Lớn
		scale = vp.X / 1920
	end
	MainScale.Scale = math.clamp(scale, 0.45, 1.1)
end
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateResponsiveScale)
UpdateResponsiveScale()

--==================== LOADING SCREEN ====================
local LoadGui = UIS.Create("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(10, 10, 12),
	ZIndex = 1000,
	Parent = ScreenGui,
})

local LoadLogo = UIS.Create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.45),
	Size = UDim2.fromOffset(300, 40),
	BackgroundTransparency = 1,
	Font = FontBold,
	Text = "FARIAL HUB",
	TextSize = 32,
	TextColor3 = Theme.Text,
	ZIndex = 1001,
	Parent = LoadGui,
})

local LoadBarBg = UIS.Create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.55),
	Size = UDim2.fromOffset(200, 4),
	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,
	ZIndex = 1001,
	Parent = LoadGui,
})
UIS.Corner(99)

local LoadBarFill = UIS.Create("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = Theme.Accent,
	BorderSizePixel = 0,
	ZIndex = 1002,
	Parent = LoadBarBg,
})
UIS.Corner(99)

task.spawn(function()
	task.wait(0.2)
	UIS.Tween(LoadBarFill, { Size = UDim2.fromScale(1, 1) }, 1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	task.wait(1.4)
	UIS.Tween(LoadGui, { BackgroundTransparency = 1 }, 0.4)
	UIS.Tween(LoadLogo, { TextTransparency = 1 }, 0.3)
	UIS.Tween(LoadBarBg, { BackgroundTransparency = 1 }, 0.3)
	UIS.Tween(LoadBarFill, { BackgroundTransparency = 1 }, 0.3)
	task.wait(0.4)
	LoadGui:Destroy()
end)

--==================== MENU BAR (TOP) ====================
local MenuBar = UIS.Create("Frame", {
	Name = "MenuBar",
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	ZIndex = 100,
	Parent = ScreenGui,
})
UIS.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder, Parent = MenuBar })
UIS.Create("UIPadding", { PaddingLeft = UDim.new(0, 16), Parent = MenuBar })

UIS.Create("TextLabel", { Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1, Font = FontBold, Text = "", TextSize = 16, TextColor3 = Theme.Text, LayoutOrder = 1, Parent = MenuBar })
UIS.Create("TextLabel", { Size = UDim2.fromOffset(100, 16), BackgroundTransparency = 1, Font = FontBold, Text = "Farial Hub", TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = MenuBar })

local TimeLabel = UIS.Create("TextLabel", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -16, 0.5, 0),
	Size = UDim2.fromOffset(150, 16),
	BackgroundTransparency = 1,
	Font = FontMedium,
	Text = "",
	TextSize = 11,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Right,
	Parent = MenuBar,
})

task.spawn(function()
	while task.wait(1) do
		TimeLabel.Text = os.date("%a %b %d  %I:%M %p")
	end
end)

--==================== DYNAMIC ISLAND (HIỂN THỊ THỜI GIAN SỬ DỤNG) ====================
local DynamicIsland = UIS.Create("Frame", {
	Name = "DynamicIsland",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 32),
	Size = UDim2.fromOffset(110, 26),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 150,
	Parent = ScreenGui,
})
UIS.Corner(99)

local IslandContent = UIS.Create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Font = FontMedium,
	Text = "",
	TextSize = 10,
	TextColor3 = Theme.Success,
	TextTransparency = 1,
	ZIndex = 151,
	Parent = DynamicIsland,
})

-- Hiệu ứng hover mở rộng
DynamicIsland.MouseEnter:Connect(function()
	UIS.Tween(DynamicIsland, { Size = UDim2.fromOffset(220, 34), BackgroundColor3 = Theme.Background }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	UIS.Tween(IslandContent, { TextTransparency = 0, TextSize = 12 }, 0.3)
end)
DynamicIsland.MouseLeave:Connect(function()
	UIS.Tween(DynamicIsland, { Size = UDim2.fromOffset(110, 26), BackgroundColor3 = Color3.fromRGB(0,0,0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	UIS.Tween(IslandContent, { TextTransparency = 1, TextSize = 10 }, 0.3)
end)

-- Logic đếm thời gian sử dụng (Uptime)
local startTime = tick()
task.spawn(function()
	while task.wait(1) do
		local uptime = math.floor(tick() - startTime)
		local hours = math.floor(uptime / 3600)
		local mins = math.floor((uptime % 3600) / 60)
		local secs = uptime % 60
		IslandContent.Text = string.format("Uptime: %02d:%02d:%02d", hours, mins, secs)
	end
end)

--==================== DOCK (BOTTOM) ====================
local DockContainer = UIS.Create("Frame", {
	Name = "DockContainer",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -10),
	Size = UDim2.new(0, 0, 0, 64),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	ZIndex = 100,
	Parent = ScreenGui,
})
UIS.Corner(16)
UIS.Stroke(Theme.Stroke, 1, 0.6)
UIS.Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = DockContainer })
UIS.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 8), Parent = DockContainer })

local function CreateDockIcon(name, color)
	local btn = UIS.Create("TextButton", {
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 101,
		Parent = DockContainer,
	})
	UIS.Corner(12)
	UIS.Ripple(btn, Color3.new(1,1,1))
	UIS.Create("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = FontBold, Text = name:sub(1,1), TextSize = 24, TextColor3 = Color3.new(1,1,1), ZIndex = 102, Parent = btn })
	
	local originalSize = btn.Size
	btn.MouseEnter:Connect(function()
		UIS.Tween(btn, { Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0, 0, 0, -8), BackgroundTransparency = 0 }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
	btn.MouseLeave:Connect(function()
		UIS.Tween(btn, { Size = originalSize, Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.1 }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end)
	return btn
end

CreateDockIcon("Blox Fruits", Theme.Danger)
CreateDockIcon("Scripts", Theme.Accent)
CreateDockIcon("Settings", Theme.Warning)
CreateDockIcon("Trash", Theme.SurfaceHover)

--==================== CỬA SỔ CHÍNH (WINDOW) ====================
local WindowRoot = UIS.Create("Frame", {
	Name = "WindowRoot",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.fromOffset(800, 500),
	BackgroundTransparency = 1,
	ZIndex = 10,
	Parent = ScreenGui,
})

local MainWindow = UIS.Create("Frame", {
	Name = "MainWindow",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.Background,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 10,
	Parent = WindowRoot,
})
UIS.Corner(12)
UIS.Stroke(Theme.Stroke, 1, 0.4)

local Shadow = UIS.Create("ImageLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, 60, 1, 60),
	BackgroundTransparency = 1,
	Image = "rbxassetid://6014261993",
	ImageColor3 = Theme.Shadow,
	ImageTransparency = 0.5,
	ScaleType = Enum.ScaleType.Slice,
	SliceCenter = Rect.new(49, 49, 450, 450),
	ZIndex = 9,
	Parent = WindowRoot,
})

-- Thanh Tiêu Đề (Title Bar)
local TitleBar = UIS.Create("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	ZIndex = 11,
	Parent = MainWindow,
})
UIS.Corner(12)
UIS.Create("Frame", { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 11, Parent = TitleBar })

-- Nút điều khiển (Traffic Lights)
local TrafficLights = UIS.Create("Frame", { Position = UDim2.fromOffset(16, 0), Size = UDim2.fromOffset(60, 40), BackgroundTransparency = 1, ZIndex = 12, Parent = TitleBar })
UIS.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), Parent = TrafficLights })

local btnClose = UIS.Create("TextButton", { Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.fromRGB(255, 95, 86), Text = "", AutoButtonColor = false, ZIndex = 13, Parent = TrafficLights })
local btnMin = UIS.Create("TextButton", { Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.fromRGB(255, 189, 46), Text = "", AutoButtonColor = false, ZIndex = 13, Parent = TrafficLights })
local btnMax = UIS.Create("TextButton", { Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.fromRGB(39, 201, 63), Text = "", AutoButtonColor = false, ZIndex = 13, Parent = TrafficLights })
for _, b in ipairs({btnClose, btnMin, btnMax}) do UIS.Corner(99) end

UIS.Create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(200, 20),
	BackgroundTransparency = 1,
	Font = FontBold,
	Text = "Night Hub (Beta V2)",
	TextSize = 13,
	TextColor3 = Theme.TextSecondary,
	ZIndex = 12,
	Parent = TitleBar,
})

-- Thanh Bên (Sidebar)
local Sidebar = UIS.Create("Frame", {
	Name = "Sidebar",
	Position = UDim2.fromOffset(0, 40),
	Size = UDim2.new(0, 200, 1, -40),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	ZIndex = 11,
	Parent = MainWindow,
})
UIS.Create("UIStroke", { Color = Theme.Stroke, Transparency = 0.7, ApplyStrokeMode = Enum.ApplyStrokeMode.Right, Parent = Sidebar })

-- Profile
local ProfileCard = UIS.Create("Frame", { Position = UDim2.fromOffset(12, 12), Size = UDim2.new(1, -24, 0, 60), BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 12, Parent = Sidebar })
UIS.Corner(8)

local AvatarFrame = UIS.Create("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = Theme.SurfaceHover, BorderSizePixel = 0, ZIndex = 13, Parent = ProfileCard })
UIS.Corner(99)
local AvatarImg = UIS.Create("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "", ZIndex = 14, Parent = AvatarFrame })
UIS.Corner(99)
task.spawn(function()
	local ok, url = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
	if ok and url then AvatarImg.Image = url end
end)

UIS.Create("TextLabel", { Position = UDim2.fromOffset(62, 12), Size = UDim2.new(1, -70, 0, 16), BackgroundTransparency = 1, Font = FontBold, Text = LocalPlayer.DisplayName, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13, Parent = ProfileCard })
UIS.Create("TextLabel", { Position = UDim2.fromOffset(62, 30), Size = UDim2.new(1, -70, 0, 14), BackgroundTransparency = 1, Font = Font, Text = "Plan: Pro - Lifetime", TextSize = 10, TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13, Parent = ProfileCard })

-- Tabs Container
local TabContainer = UIS.Create("ScrollingFrame", {
	Position = UDim2.fromOffset(12, 84),
	Size = UDim2.new(1, -24, 1, -96),
	BackgroundTransparency = 1,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Theme.Stroke,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ZIndex = 12,
	Parent = Sidebar,
})
UIS.Create("UIListLayout", { Padding = UDim.new(0, 4), Parent = TabContainer })

local tabs = {
	{ name = "Status Server", icon = "📊" },
	{ name = "Configuration", icon = "⚙" },
	{ name = "Farming", icon = "🌾" },
	{ name = "Stack Farming", icon = "📦" },
	{ name = "Items Farming", icon = "⚔" },
	{ name = "Quests", icon = "📜" },
	{ name = "Raid & Fruit", icon = "🍎" },
	{ name = "Stats", icon = "📈" },
}

local activeTab = nil
local pages = {}

-- Khu vực nội dung
local ContentArea = UIS.Create("Frame", {
	Name = "ContentArea",
	Position = UDim2.fromOffset(200, 40),
	Size = UDim2.new(1, -200, 1, -40),
	BackgroundColor3 = Theme.Background,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	ZIndex = 11,
	Parent = MainWindow,
})

local function SwitchTab(tabName)
	if activeTab == tabName then return end
	activeTab = tabName
	
	for _, child in pairs(TabContainer:GetChildren()) do
		if child:IsA("TextButton") then
			local isActive = (child.Name == tabName)
			UIS.Tween(child, { BackgroundColor3 = isActive and Theme.Accent or Theme.Surface, BackgroundTransparency = isActive and 0 or 1 }, 0.2)
			local label = child:FindFirstChildOfClass("TextLabel")
			if label then
				UIS.Tween(label, { TextColor3 = isActive and Color3.new(1,1,1) or Theme.Text }, 0.2)
			end
		end
	end
	
	for name, page in pairs(pages) do
		if name == tabName then
			page.Visible = true
			page.Position = UDim2.fromOffset(0, 10)
			UIS.Tween(page, { Position = UDim2.fromOffset(0, 0), BackgroundTransparency = 0 }, 0.2)
		else
			page.Visible = false
		end
	end
end

local function CreatePage(name)
	local page = UIS.Create("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Stroke,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 12,
		Parent = ContentArea,
	})
	UIS.Create("UIPadding", { PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingTop = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20), Parent = page })
	UIS.Create("UIListLayout", { Padding = UDim.new(0, 12), Parent = page })
	pages[name] = page
	return page
end

for i, tab in ipairs(tabs) do
	local btn = UIS.Create("TextButton", {
		Name = tab.name,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = i,
		ZIndex = 13,
		Parent = TabContainer,
	})
	UIS.Corner(6)
	UIS.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = btn })
	UIS.Create("TextLabel", { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(20, 32), BackgroundTransparency = 1, Font = FontMedium, Text = tab.icon, TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14, Parent = btn })
	UIS.Create("TextLabel", { Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -28, 1, 0), BackgroundTransparency = 1, Font = FontMedium, Text = tab.name, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14, Parent = btn })
	
	UIS.Ripple(btn, Color3.new(1,1,1))
	
	btn.MouseEnter:Connect(function() if activeTab ~= tab.name then UIS.Tween(btn, { BackgroundTransparency = 0.9, BackgroundColor3 = Theme.SurfaceHover }, 0.15) end end)
	btn.MouseLeave:Connect(function() if activeTab ~= tab.name then UIS.Tween(btn, { BackgroundTransparency = 1 }, 0.15) end end)
	btn.MouseButton1Click:Connect(function() PlayClick(); SwitchTab(tab.name) end)
end

-- Đổ dữ liệu vào trang "Status Server"
local statusPage = CreatePage("Status Server")
local function CreateStatusCard(title, desc, icon, order)
	local card = UIS.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0.2, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 13, Parent = statusPage })
	UIS.Corner(8)
	UIS.Padding(12, 16, 12, 16, 12)
	UIS.Create("TextLabel", { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(20, 50), BackgroundTransparency = 1, Font = FontBold, Text = icon, TextSize = 16, TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14, Parent = card })
	UIS.Create("TextLabel", { Position = UDim2.fromOffset(28, 4), Size = UDim2.new(1, -28, 0, 16), BackgroundTransparency = 1, Font = FontBold, Text = title, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14, Parent = card })
	UIS.Create("TextLabel", { Position = UDim2.fromOffset(28, 22), Size = UDim2.new(1, -28, 0, 14), BackgroundTransparency = 1, Font = Font, Text = desc, TextSize = 11, TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14, Parent = card })
end
CreateStatusCard("Server", "Sea3 | Players 8/12 | Uptime 00:03:37", "☁", 1)
CreateStatusCard("Server Time", "18:38 | Night | Day in 10:41", "🕒", 2)
CreateStatusCard("Moon", "Phase 2/8", "🌙", 3)
CreateStatusCard("Elite", "Not spawned | Killed 97", "💀", 4)
CreateStatusCard("Cake Prince", "15 mins left", "🎂", 5)
SwitchTab("Status Server")

--==================== LOGIC KÉO THẢ WINDOW (ĐÃ FIX LỖI SCALE) ====================
local dragging, dragStart, startPos = false, nil, nil

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = WindowRoot.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		-- Chia delta cho Scale để kéo chính xác trên mọi độ phân giải
		WindowRoot.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + (delta.X / MainScale.Scale), 
			startPos.Y.Scale, startPos.Y.Offset + (delta.Y / MainScale.Scale)
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Nút Đóng
btnClose.MouseButton1Click:Connect(function()
	PlayClick()
	local tw = UIS.Tween(WindowRoot, { Size = UDim2.fromOffset(0, 0) }, 0.3)
	tw.Completed:Connect(function() ScreenGui:Destroy() end)
end)

-- Nút Thu nhỏ
local minimized = false
local savedSize = WindowRoot.Size
btnMin.MouseButton1Click:Connect(function()
	PlayClick()
	minimized = not minimized
	if minimized then
		savedSize = WindowRoot.Size
		UIS.Tween(WindowRoot, { Size = UDim2.fromOffset(WindowRoot.AbsoluteSize.X / MainScale.Scale, 40) }, 0.3)
	else
		UIS.Tween(WindowRoot, { Size = savedSize }, 0.3)
	end
end)

-- Nút Phóng to
local maximized = false
btnMax.MouseButton1Click:Connect(function()
	PlayClick()
	maximized = not maximized
	if maximized then
		savedSize = WindowRoot.Size
		UIS.Tween(WindowRoot, { Size = UDim2.fromOffset((Camera.ViewportSize.X / MainScale.Scale) - 40, (Camera.ViewportSize.Y / MainScale.Scale) - 80) }, 0.3)
	else
		UIS.Tween(WindowRoot, { Size = savedSize }, 0.3)
	end
end)

-- Hiệu ứng mở Window
WindowRoot.Size = UDim2.fromOffset(600, 400)
UIS.Tween(WindowRoot, { Size = UDim2.fromOffset(800, 500) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

--==================== HỆ THỐNG THÔNG BÁO ====================
local NotifHolder = UIS.Create("Frame", {
	Name = "NotifHolder",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -20, 0, 40),
	Size = UDim2.fromOffset(300, 500),
	BackgroundTransparency = 1,
	ZIndex = 200,
	Parent = ScreenGui,
})
UIS.Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top, Parent = NotifHolder })

local Notify = {}
function Notify:Show(title, msg, type)
	local color = Theme.Accent
	if type == "success" then color = Theme.Success
	elseif type == "warning" then color = Theme.Warning
	elseif type == "error" then color = Theme.Danger end

	local notif = UIS.Create("Frame", { Size = UDim2.fromOffset(300, 60), BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 201, Parent = NotifHolder })
	UIS.Corner(10)
	UIS.Stroke(Theme.Stroke, 1, 0.5)
	
	UIS.Create("Frame", { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 202, Parent = notif })
	UIS.Create("TextLabel", { Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 16), BackgroundTransparency = 1, Font = FontBold, Text = title, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202, Parent = notif })
	UIS.Create("TextLabel", { Position = UDim2.fromOffset(12, 26), Size = UDim2.new(1, -24, 0, 24), BackgroundTransparency = 1, Font = Font, Text = msg, TextSize = 11, TextWrapped = true, TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202, Parent = notif })
	
	notif.Position = UDim2.fromOffset(320, 0)
	UIS.Tween(notif, { Position = UDim2.fromOffset(0, 0) }, 0.3)
	
	task.delay(4, function()
		if notif then
			local tw = UIS.Tween(notif, { Position = UDim2.fromOffset(320, 0), BackgroundTransparency = 1 }, 0.3)
			tw.Completed:Connect(function() notif:Destroy() end)
		end
	end)
end

task.delay(1, function()
	Notify:Show("Hệ thống", "Đã tải Farial Hub UI thành công.", "success")
end)