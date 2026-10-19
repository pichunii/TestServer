--==================================================================
-- FARIAL HUB UI - MACOS EXTREME SMOOTH EDITION (ENGLISH)
-- Type: LocalScript
-- Location: StarterPlayer > StarterPlayerScripts
-- Author: Nhism Developer
-- Features: Smooth Corners, Drag-to-Select Tab Bar, Dynamic Island
--==================================================================

local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local SoundService       = game:GetService("SoundService")
local StarterGui         = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

--==================== CLEANUP & BLACK SCREEN FIX ====================
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
for _, gui in pairs(PlayerGui:GetChildren()) do
	if gui:IsA("ScreenGui") and (gui.Name == "FarialHubUI" or gui.Name == "LoadingUI") then
		gui:Destroy()
	end
end

--==================== MACOS THEME ====================
local Theme = {
	Background       = Color3.fromRGB(20, 20, 22),
	Surface          = Color3.fromRGB(36, 36, 38),
	SurfaceHover     = Color3.fromRGB(50, 50, 52),
	Stroke           = Color3.fromRGB(80, 80, 82),
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

--==================== UTILITIES ====================
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

local function PlayClick()
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://12221967"
	s.Volume = 0.1
	s.Parent = SoundService
	s:Play()
	game:GetService("Debris"):AddItem(s, 1)
end

--==================== SCREEN GUI & RESPONSIVE SCALE ====================
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
	if vp.X < 800 then scale = vp.X / 850
	elseif vp.X < 1400 then scale = vp.X / 1400
	else scale = vp.X / 1920 end
	MainScale.Scale = math.clamp(scale, 0.45, 1.1)
end
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateResponsiveScale)
UpdateResponsiveScale()

--==================== LOADING SCREEN ====================
local LoadGui = UIS.Create("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.2,
	ZIndex = 1000,
	Parent = ScreenGui,
})

local LoadCenter = UIS.Create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(200, 120),
	BackgroundTransparency = 1,
	ZIndex = 1001,
	Parent = LoadGui,
})

local LoadSpinner = UIS.Create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 0),
	Size = UDim2.fromOffset(32, 32),
	BackgroundTransparency = 1,
	ZIndex = 1002,
	Parent = LoadCenter,
})
local SpinnerArc = UIS.Create("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ZIndex = 1003,
	Parent = LoadSpinner,
})
UIS.Corner(999)
UIS.Create("UIStroke", { Color = Theme.Text, Thickness = 3, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = SpinnerArc })
local SpinnerMask = UIS.Create("Frame", { Size = UDim2.new(1, 10, 0.5, 10), Position = UDim2.fromScale(0, -0.1), BackgroundColor3 = Color3.fromRGB(0,0,0), BorderSizePixel = 0, ZIndex = 1004, Parent = LoadSpinner })

local LoadText = UIS.Create("TextLabel", {
	Position = UDim2.new(0, 0, 0, 50),
	Size = UDim2.new(1, 0, 0, 20),
	BackgroundTransparency = 1,
	Font = FontMedium,
	Text = "Loading...",
	TextSize = 14,
	TextColor3 = Theme.Text,
	ZIndex = 1002,
	Parent = LoadCenter,
})

local spinConn = RunService.RenderStepped:Connect(function(dt)
	SpinnerArc.Rotation = (SpinnerArc.Rotation + dt * 360) % 360
end)

task.spawn(function()
	task.wait(1.5)
	local tw1 = UIS.Tween(LoadGui, { BackgroundTransparency = 1 }, 0.4)
	UIS.Tween(LoadCenter, { BackgroundTransparency = 1 }, 0.3)
	UIS.Tween(LoadText, { TextTransparency = 1 }, 0.3)
	UIS.Tween(SpinnerArc:FindFirstChildOfClass("UIStroke"), { Transparency = 1 }, 0.3)
	UIS.Tween(SpinnerMask, { BackgroundTransparency = 1 }, 0.3)
	tw1.Completed:Connect(function()
		spinConn:Disconnect()
		LoadGui:Destroy()
	end)
end)

--==================== MENU BAR (TOP) ====================
local MenuBar = UIS.Create("Frame", {
	Name = "MenuBar",
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.3,
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
	while task.wait(1) do TimeLabel.Text = os.date("%a %b %d  %I:%M %p") end
end)

--==================== DYNAMIC ISLAND (FIXED) ====================
local IslandContainer = UIS.Create("Frame", {
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
UIS.Corner(999)

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
	Parent = IslandContainer,
})

-- Invisible button for reliable mobile/PC interaction
local IslandBtn = UIS.Create("TextButton", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	ZIndex = 152,
	Parent = IslandContainer,
})

local islandExpanded = false
local function ToggleIsland(state)
	islandExpanded = state
	if islandExpanded then
		UIS.Tween(IslandContainer, { Size = UDim2.fromOffset(220, 34), BackgroundColor3 = Theme.Surface }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		UIS.Tween(IslandContent, { TextTransparency = 0, TextSize = 12 }, 0.3)
	else
		UIS.Tween(IslandContainer, { Size = UDim2.fromOffset(110, 26), BackgroundColor3 = Color3.fromRGB(0,0,0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		UIS.Tween(IslandContent, { TextTransparency = 1, TextSize = 10 }, 0.3)
	end
end

IslandBtn.MouseEnter:Connect(function() if not islandExpanded then ToggleIsland(true) end end)
IslandBtn.MouseLeave:Connect(function() if islandExpanded then ToggleIsland(false) end end)
IslandBtn.MouseButton1Click:Connect(function() ToggleIsland(not islandExpanded) end)

local startTime = tick()
task.spawn(function()
	while task.wait(1) do
		local uptime = math.floor(tick() - startTime)
		IslandContent.Text = string.format("Uptime: %02d:%02d:%02d", math.floor(uptime/3600), math.floor((uptime%3600)/60), uptime%60)
	end
end)

--==================== MAIN WINDOW ====================
local WindowRoot = UIS.Create("Frame", {
	Name = "WindowRoot",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, -20),
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
UIS.Corner(16)
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

-- Title Bar
local TitleBar = UIS.Create("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	ZIndex = 11,
	Parent = MainWindow,
})
UIS.Corner(16)
UIS.Create("Frame", { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 11, Parent = TitleBar })

-- Traffic Lights
local TrafficLights = UIS.Create("Frame", { Position = UDim2.fromOffset(16, 0), Size = UDim2.fromOffset(60, 40), BackgroundTransparency = 1, ZIndex = 12, Parent = TitleBar })
UIS.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), Parent = TrafficLights })

local btnClose = UIS.Create("TextButton", { Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.fromRGB(255, 95, 86), Text = "", AutoButtonColor = false, ZIndex = 13, Parent = TrafficLights })
local btnMin = UIS.Create("TextButton", { Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.fromRGB(255, 189, 46), Text = "", AutoButtonColor = false, ZIndex = 13, Parent = TrafficLights })
local btnMax = UIS.Create("TextButton", { Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.fromRGB(39, 201, 63), Text = "", AutoButtonColor = false, ZIndex = 13, Parent = TrafficLights })
for _, b in ipairs({btnClose, btnMin, btnMax}) do UIS.Corner(999) end

UIS.Create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(200, 20),
	BackgroundTransparency = 1,
	Font = FontBold,
	Text = "Night Hub (MacOS Mode)",
	TextSize = 13,
	TextColor3 = Theme.TextSecondary,
	ZIndex = 12,
	Parent = TitleBar,
})

-- Sidebar
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

-- Profile Card
local ProfileCard = UIS.Create("Frame", { Position = UDim2.fromOffset(12, 12), Size = UDim2.new(1, -24, 0, 60), BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 12, Parent = Sidebar })
UIS.Corner(10)

local AvatarFrame = UIS.Create("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = Theme.SurfaceHover, BorderSizePixel = 0, ZIndex = 13, Parent = ProfileCard })
UIS.Corner(999)
local AvatarImg = UIS.Create("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "", ZIndex = 14, Parent = AvatarFrame })
UIS.Corner(999)
task.spawn(function()
	local ok, url = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
	if ok and url then AvatarImg.Image = url end
end)

UIS.Create("TextLabel", { Position = UDim2.fromOffset(62, 12), Size = UDim2.new(1, -70, 0, 16), BackgroundTransparency = 1, Font = FontBold, Text = LocalPlayer.DisplayName, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13, Parent = ProfileCard })
UIS.Create("TextLabel", { Position = UDim2.fromOffset(62, 30), Size = UDim2.new(1, -70, 0, 14), BackgroundTransparency = 1, Font = Font, Text = "Plan: Pro - Lifetime", TextSize = 10, TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13, Parent = ProfileCard })

-- Content Area
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

local pages = {}
local function CreatePage(name)
	local page = UIS.Create("ScrollingFrame", {
		Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Stroke,
		CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false, ZIndex = 12, Parent = ContentArea,
	})
	UIS.Create("UIPadding", { PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingTop = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20), Parent = page })
	UIS.Create("UIListLayout", { Padding = UDim.new(0, 12), Parent = page })
	pages[name] = page
	return page
end

local homePage = CreatePage("Home")
local function CreateStatusCard(title, desc, icon, order)
	local card = UIS.Create("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0.2, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 13, Parent = homePage })
	UIS.Corner(12)
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

--==================== FLOATING TAB BAR (BOTTOM) ====================
local TabBarContainer = UIS.Create("Frame", {
	Name = "TabBarContainer",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -20),
	Size = UDim2.fromOffset(320, 56),
	BackgroundColor3 = Theme.Surface,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	ZIndex = 100,
	Parent = ScreenGui,
})
UIS.Corner(999)
UIS.Stroke(Theme.Stroke, 1, 0.5)

local Slider = UIS.Create("Frame", {
	Name = "Slider",
	Size = UDim2.fromOffset(70, 44),
	Position = UDim2.fromOffset(6, 6),
	BackgroundColor3 = Theme.Accent,
	BackgroundTransparency = 0.8,
	BorderSizePixel = 0,
	ZIndex = 101,
	Parent = TabBarContainer,
})
UIS.Corner(999)

local tabData = {
	{ name = "Home", icon = "⌂" },
	{ name = "Scripts", icon = "⚡" },
	{ name = "Settings", icon = "⚙" },
	{ name = "Shop", icon = "🛒" }
}

local TabButtons = {}
local TabCount = #tabData
local TabWidth = 70
local Spacing = 6

for i, data in ipairs(tabData) do
	local btn = UIS.Create("TextButton", {
		Name = data.name,
		Size = UDim2.fromOffset(TabWidth, 44),
		Position = UDim2.fromOffset(Spacing + (i-1)*(TabWidth + Spacing), 6),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 102,
		Parent = TabBarContainer,
	})
	
	UIS.Create("TextLabel", {
		Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1, Font = FontBold, Text = data.icon,
		TextSize = 18, TextColor3 = Theme.TextSecondary, ZIndex = 103, Parent = btn,
	})
	
	UIS.Create("TextLabel", {
		Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1, Font = FontMedium, Text = data.name,
		TextSize = 10, TextColor3 = Theme.TextSecondary, ZIndex = 103, Parent = btn,
	})
	
	TabButtons[i] = btn
end

local activeTabIndex = 1
local function SwitchTab(index)
	if activeTabIndex == index then return end
	activeTabIndex = index
	
	UIS.Tween(Slider, {
		Position = UDim2.fromOffset(Spacing + (index-1)*(TabWidth + Spacing), 6)
	}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	
	for i, btn in ipairs(TabButtons) do
		local isActive = (i == index)
		local iconLabel = btn:GetChildren()[1]
		local nameLabel = btn:GetChildren()[2]
		UIS.Tween(iconLabel, { TextColor3 = isActive and Color3.new(1,1,1) or Theme.TextSecondary }, 0.2)
		UIS.Tween(nameLabel, { TextColor3 = isActive and Color3.new(1,1,1) or Theme.TextSecondary }, 0.2)
	end
	
	for i, data in ipairs(tabData) do
		local pageName = data.name
		if pages[pageName] then
			if i == index then
				pages[pageName].Visible = true
				pages[pageName].Position = UDim2.fromOffset(0, 10)
				UIS.Tween(pages[pageName], { Position = UDim2.fromOffset(0, 0) }, 0.2)
			else
				pages[pageName].Visible = false
			end
		end
	end
end

for i, btn in ipairs(TabButtons) do
	btn.MouseButton1Click:Connect(function()
		PlayClick()
		SwitchTab(i)
	end)
end

-- Drag to Select Logic
local isDraggingTab = false
local dragStartX = 0
local hasDragged = false

TabBarContainer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDraggingTab = true
		hasDragged = false
		dragStartX = UserInputService:GetMouseLocation().X
	end
end)

TabBarContainer.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if isDraggingTab then
			isDraggingTab = false
			if hasDragged then
				-- Snap to nearest tab on release
				local mouseX = UserInputService:GetMouseLocation().X - TabBarContainer.AbsolutePosition.X
				local closestIndex = 1
				local minDist = math.huge
				
				for i = 1, TabCount do
					local tabCenter = Spacing + (i-1)*(TabWidth + Spacing) + TabWidth/2
					local dist = math.abs(mouseX - tabCenter)
					if dist < minDist then
						minDist = dist
						closestIndex = i
					end
				end
				SwitchTab(closestIndex)
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if isDraggingTab then
		local mouseX = UserInputService:GetMouseLocation().X - TabBarContainer.AbsolutePosition.X
		
		-- Check drag threshold
		if math.abs(mouseX + TabBarContainer.AbsolutePosition.X - dragStartX) > 10 then
			hasDragged = true
		end
		
		if hasDragged then
			local targetX = math.clamp(mouseX - TabWidth/2, Spacing, Spacing + (TabCount-1)*(TabWidth+Spacing))
			Slider.Position = UDim2.fromOffset(targetX, 6)
		end
	end
end)

SwitchTab(1)

--==================== WINDOW DRAG LOGIC ====================
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

btnClose.MouseButton1Click:Connect(function()
	PlayClick()
	local tw = UIS.Tween(WindowRoot, { Size = UDim2.fromOffset(0, 0) }, 0.3)
	tw.Completed:Connect(function() ScreenGui:Destroy() end)
end)

--==================== MACOS NOTIFICATION SYSTEM (FIXED) ====================
local NotifHolder = UIS.Create("Frame", {
	Name = "NotifHolder",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -20, 0, 40),
	Size = UDim2.fromOffset(300, 500),
	BackgroundTransparency = 1,
	ZIndex = 200,
	Parent = ScreenGui,
})
-- UIListLayout stacked vertically
UIS.Create("UIListLayout", { 
	Padding = UDim.new(0, 10), 
	SortOrder = Enum.SortOrder.LayoutOrder, 
	VerticalAlignment = Enum.VerticalAlignment.Top, 
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Parent = NotifHolder 
})

local Notify = {}
function Notify:Show(title, msg, type)
	local color = Theme.Accent
	if type == "success" then color = Theme.Success
	elseif type == "warning" then color = Theme.Warning
	elseif type == "error" then color = Theme.Danger end

	local notif = UIS.Create("Frame", { 
		Size = UDim2.fromOffset(300, 64), 
		BackgroundColor3 = Theme.Surface, 
		BackgroundTransparency = 0.05, 
		BorderSizePixel = 0, 
		ZIndex = 201, 
		Parent = NotifHolder 
	})
	UIS.Corner(16)
	UIS.Stroke(Theme.Stroke, 1, 0.5)
	
	local bar = UIS.Create("Frame", { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 202, Parent = notif })
	UIS.Corner(99)
	
	UIS.Create("TextLabel", { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 0, 16), BackgroundTransparency = 1, Font = FontBold, Text = title, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202, Parent = notif })
	UIS.Create("TextLabel", { Position = UDim2.fromOffset(16, 28), Size = UDim2.new(1, -32, 0, 28), BackgroundTransparency = 1, Font = Font, Text = msg, TextSize = 11, TextWrapped = true, TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202, Parent = notif })
	
	-- Initial state for slide-in
	notif.Position = UDim2.fromOffset(320, 0)
	UIS.Tween(notif, { Position = UDim2.fromOffset(0, 0) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	
	-- Auto dismiss
	task.delay(4, function()
		if notif and notif.Parent then
			local tw = UIS.Tween(notif, { Position = UDim2.fromOffset(320, 0), BackgroundTransparency = 1 }, 0.3)
			tw.Completed:Connect(function() notif:Destroy() end)
		end
	end)
end

task.delay(0.5, function()
	Notify:Show("System", "Farial Hub initialized successfully.", "success")
end)