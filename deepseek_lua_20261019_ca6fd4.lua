--==================================================================
-- FARIAL HUB UI - PHONG CÁCH MACOS
-- Loại: LocalScript
-- Vị trí: StarterPlayer > StarterPlayerScripts
-- Tác giả: Nhism Developer
--==================================================================

--==================== DỊCH VỤ HỆ THỐNG ====================
local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local GuiService         = game:GetService("GuiService")
local SoundService       = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--==================== XÓA GUI CŨ ====================
local old = PlayerGui:FindFirstChild("FarialHubUI")
if old then old:Destroy() end

--==================== BẢNG MÀU (MACOS THEME) ====================
local Theme = {
	Background       = Color3.fromRGB(28, 28, 30),
	Surface          = Color3.fromRGB(44, 44, 46),
	SurfaceHover     = Color3.fromRGB(58, 58, 60),
	SurfaceActive    = Color3.fromRGB(68, 68, 70),
	Stroke           = Color3.fromRGB(72, 72, 74),
	Text             = Color3.fromRGB(245, 245, 247),
	TextSecondary    = Color3.fromRGB(152, 152, 157),
	Accent           = Color3.fromRGB(10, 132, 255),
	AccentDark       = Color3.fromRGB(0, 99, 204),
	Success          = Color3.fromRGB(48, 209, 88),
	Warning          = Color3.fromRGB(255, 159, 10),
	Danger           = Color3.fromRGB(255, 69, 58),
	Shadow           = Color3.fromRGB(0, 0, 0),
}

local Font       = Enum.Font.Gotham
local FontMedium = Enum.Font.GothamMedium
local FontBold   = Enum.Font.GothamBold

--==================== HÀM TIỆN ÍCH ====================
local UIS = {}

function UIS.Create(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	for _, child in ipairs(children or {}) do
		child.Parent = obj
	end
	return obj
end

function UIS.Tween(obj, props, time, style, dir)
	local info = TweenInfo.new(
		time or 0.25,
		style or Enum.EasingStyle.Quart,
		dir or Enum.EasingDirection.Out
	)
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

function UIS.Padding(p, l, t, r, b)
	return UIS.Create("UIPadding", {
		PaddingLeft   = UDim.new(0, l or p or 0),
		PaddingTop    = UDim.new(0, t or p or 0),
		PaddingRight  = UDim.new(0, r or p or 0),
		PaddingBottom = UDim.new(0, b or p or 0),
	})
end

function UIS.Shadow(parent, transparency)
	local s = Instance.new("ImageLabel")
	s.Name = "Shadow"
	s.AnchorPoint = Vector2.new(0.5, 0.5)
	s.Position = UDim2.fromScale(0.5, 0.5)
	s.Size = UDim2.new(1, 80, 1, 80)
	s.BackgroundTransparency = 1
	s.Image = "rbxassetid://6014261993"
	s.ImageColor3 = Theme.Shadow
	s.ImageTransparency = transparency or 0.4
	s.ScaleType = Enum.ScaleType.Slice
	s.SliceCenter = Rect.new(49, 49, 450, 450)
	s.ZIndex = -1
	s.Parent = parent
	return s
end

--==================== SCREEN GUI GỐC ====================
local ScreenGui = UIS.Create("ScreenGui", {
	Name = "FarialHubUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 100,
	Parent = PlayerGui,
})

--==================== HỆ THỐNG ÂM THANH UI ====================
local function PlayClick()
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://12221967"
	s.Volume = 0.15
	s.Parent = SoundService
	s:Play()
	game:GetService("Debris"):AddItem(s, 2)
end

--==================== HIỆU ỨNG RIPPLE (SÓNG NƯỚC) ====================
local function AddRipple(button, color)
	button.ClipsDescendants = true
	button.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then return end

		local ripple = UIS.Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(
				input.Position.X - button.AbsolutePosition.X,
				input.Position.Y - button.AbsolutePosition.Y
			),
			Size = UDim2.fromOffset(0, 0),
			BackgroundColor3 = color or Theme.Text,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0,
			ZIndex = button.ZIndex + 2,
			Parent = button,
		})
		UIS.Corner(999)
		local tw = UIS.Tween(ripple, {
			Size = UDim2.fromOffset(button.AbsoluteSize.X * 2.2, button.AbsoluteSize.X * 2.2),
			BackgroundTransparency = 1,
		}, 0.55)
		tw.Completed:Connect(function() ripple:Destroy() end)
	end)
end

--==================== MÀN HÌNH LOADING ====================
local function CreateLoadingScreen()
	local loadGui = UIS.Create("Frame", {
		Name = "LoadingOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(14, 14, 16),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 500,
		Parent = ScreenGui,
	})

	-- Hộp trung tâm
	local center = UIS.Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(320, 220),
		BackgroundTransparency = 1,
		ZIndex = 501,
		Parent = loadGui,
	})

	-- Logo
	local logo = UIS.Create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Font = FontBold,
		Text = "FARIAL HUB",
		TextSize = 28,
		TextColor3 = Theme.Text,
		TextTransparency = 1,
		ZIndex = 502,
		Parent = center,
	})

	local sub = UIS.Create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 46),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = FontMedium,
		Text = "Đang khởi tạo môi trường...",
		TextSize = 13,
		TextColor3 = Theme.TextSecondary,
		TextTransparency = 1,
		ZIndex = 502,
		Parent = center,
	})

	-- Vòng xoay loading
	local spinner = UIS.Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 20),
		Size = UDim2.fromOffset(64, 64),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		ZIndex = 502,
		Parent = center,
	})
	UIS.Corner(999)
	local spinStroke = UIS.Create("UIStroke", {
		Color = Theme.Accent,
		Thickness = 3,
		Transparency = 0.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = spinner,
	})
	-- Tạo hiệu ứng cung tròn bằng cách dùng nhiều Frame mảnh
	local arc = UIS.Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 502,
		Parent = spinner,
	})
	local arcStroke = UIS.Create("UIStroke", {
		Color = Theme.Text,
		Thickness = 3,
		Transparency = 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = arc,
	})
	UIS.Corner(999)
	-- Cắt bớt 1 phần bằng mask
	local mask = UIS.Create("Frame", {
		Size = UDim2.new(1, 10, 0.5, 10),
		Position = UDim2.fromScale(0, -0.1),
		BackgroundColor3 = Color3.fromRGB(14, 14, 16),
		BorderSizePixel = 0,
		ZIndex = 503,
		Parent = spinner,
	})

	-- Thanh tiến trình
	local barBg = UIS.Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -10),
		Size = UDim2.fromOffset(240, 6),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 502,
		Parent = center,
	})
	UIS.Corner(999)

	local barFill = UIS.Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 503,
		Parent = barBg,
	})
	UIS.Corner(999)

	local pct = UIS.Create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -22),
		Size = UDim2.fromOffset(240, 16),
		BackgroundTransparency = 1,
		Font = FontMedium,
		Text = "0%",
		TextSize = 12,
		TextColor3 = Theme.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 502,
		Parent = center,
	})

	-- Fade in logo
	UIS.Tween(logo, { TextTransparency = 0 }, 0.4)
	UIS.Tween(sub, { TextTransparency = 0 }, 0.5)
	UIS.Tween(pct, { TextTransparency = 0.3 }, 0.4)

	-- Animation xoay spinner
	local spinConnection
	spinConnection = RunService.RenderStepped:Connect(function(dt)
		if not spinner.Parent then spinConnection:Disconnect() return end
		arc.Rotation = (arc.Rotation + dt * 360) % 360
	end)

	-- Thanh tiến trình chạy
	task.spawn(function()
		local steps = {
			{0.15, "Đang tải module cốt lõi..."},
			{0.35, "Đang kết nối dịch vụ..."},
			{0.55, "Đang xác thực người dùng..."},
			{0.75, "Đang tải giao diện..."},
			{0.92, "Đang hoàn tất..."},
			{1.00, "Hoàn tất!"},
		}
		for _, step in ipairs(steps) do
			sub.Text = step[2]
			local tw = TweenService:Create(barFill, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(step[1], 1),
			})
			tw:Play()
			for i = 0, 100, 5 do
				if i / 100 > step[1] then break end
				pct.Text = math.floor(math.max(0, i / 100) * 100) .. "%"
				task.wait(0.008)
			end
			task.wait(0.25)
		end
		task.wait(0.3)

		-- Fade out toàn màn
		local fadeTw = UIS.Tween(loadGui, { BackgroundTransparency = 1 }, 0.5)
		UIS.Tween(logo, { TextTransparency = 1 }, 0.4)
		UIS.Tween(sub, { TextTransparency = 1 }, 0.4)
		UIS.Tween(pct, { TextTransparency = 1 }, 0.4)
		UIS.Tween(barBg, { BackgroundTransparency = 1 }, 0.4)
		UIS.Tween(barFill, { BackgroundTransparency = 1 }, 0.4)
		UIS.Tween(spinner, { BackgroundTransparency = 1 }, 0.4)
		UIS.Tween(arcStroke, { Transparency = 1 }, 0.4)
		UIS.Tween(mask, { BackgroundTransparency = 1 }, 0.4)

		fadeTw.Completed:Connect(function()
			if spinConnection then spinConnection:Disconnect() end
			loadGui:Destroy()
		end)
	end)
end

--==================== CỬA SỔ CHÍNH ====================
local function CreateMainWindow()
	-- Container gốc để scale animation
	local root = UIS.Create("Frame", {
		Name = "MainRoot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(820, 540),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = ScreenGui,
	})

	-- Khung chính
	local window = UIS.Create("Frame", {
		Name = "Window",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 10,
		Parent = root,
	})
	UIS.Corner(14)
	UIS.Stroke(Theme.Stroke, 1, 0.6)
	UIS.Shadow(window, 0.45)

	-- Thanh tiêu đề (drag bar)
	local titleBar = UIS.Create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 11,
		Parent = window,
	})
	UIS.Corner(14)
	-- che góc dưới
	local cornerMask = UIS.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, -14),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 11,
		Parent = titleBar,
	})
	UIS.Create("UIStroke", {
		Color = Theme.Stroke,
		Thickness = 1,
		Transparency = 0.7,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Bottom,
		Parent = titleBar,
	})

	-- Nút điều khiển (traffic lights)
	local btnContainer = UIS.Create("Frame", {
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.fromOffset(70, 44),
		BackgroundTransparency = 1,
		ZIndex = 12,
		Parent = titleBar,
	})
	local list = UIS.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = btnContainer,
	})

	local colors = {
		{Theme.Danger,  "Đóng"},
		{Theme.Warning, "Thu nhỏ"},
		{Theme.Success, "Phóng to"},
	}

	local trafficButtons = {}
	for i, data in ipairs(colors) do
		local b = UIS.Create("TextButton", {
			Name = "Traffic" .. i,
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = data[1],
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 12,
			Parent = btnContainer,
		})
		UIS.Corner(999)
		UIS.Stroke(data[1], 1, 0.6)
		trafficButtons[i] = b

		b.MouseEnter:Connect(function()
			UIS.Tween(b, { BackgroundTransparency = 0 }, 0.15)
		end)
		b.MouseLeave:Connect(function()
			UIS.Tween(b, { BackgroundTransparency = 0.15 }, 0.15)
		end)
	end

	-- Tiêu đề giữa
	local titleLabel = UIS.Create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(300, 20),
		BackgroundTransparency = 1,
		Font = FontMedium,
		Text = "Farial Hub  ·  Phiên bản 2.0",
		TextSize = 13,
		TextColor3 = Theme.TextSecondary,
		ZIndex = 12,
		Parent = titleBar,
	})

	-- Thanh điều hướng bên trái (sidebar)
	local sidebar = UIS.Create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(0, 210, 1, -44),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 11,
		Parent = window,
	})
	UIS.Create("UIStroke", {
		Color = Theme.Stroke,
		Thickness = 1,
		Transparency = 0.7,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Right,
		Parent = sidebar,
	})

	-- Hồ sơ người dùng (Profile Card)
	local profileCard = UIS.Create("Frame", {
		Position = UDim2.fromOffset(12, 14),
		Size = UDim2.new(1, -24, 0, 84),
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		ZIndex = 12,
		Parent = sidebar,
	})
	UIS.Corner(10)

	-- Avatar
	local avatarFrame = UIS.Create("Frame", {
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(64, 64),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ZIndex = 13,
		Parent = profileCard,
	})
	UIS.Corner(8)

	local avatarImg = UIS.Create("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = "",
		ZIndex = 14,
		Parent = avatarFrame,
	})
	UIS.Corner(8)

	-- Tải avatar Roblox
	task.spawn(function()
		local ok, url = pcall(function()
			return Players:GetUserThumbnailAsync(
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)
		end)
		if ok and url then
			avatarImg.Image = url
		end
	end)

	-- Tên + level
	local nameLabel = UIS.Create("TextLabel", {
		Position = UDim2.fromOffset(84, 14),
		Size = UDim2.new(1, -94, 0, 18),
		BackgroundTransparency = 1,
		Font = FontBold,
		Text = LocalPlayer.DisplayName,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 13,
		Parent = profileCard,
	})

	local userTag = UIS.Create("TextLabel", {
		Position = UDim2.fromOffset(84, 32),
		Size = UDim2.new(1, -94, 0, 14),
		BackgroundTransparency = 1,
		Font = Font,
		Text = "@" .. LocalPlayer.Name,
		TextSize = 11,
		TextColor3 = Theme.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 13,
		Parent = profileCard,
	})

	-- Badge Premium
	local badge = UIS.Create("Frame", {
		Position = UDim2.fromOffset(84, 50),
		Size = UDim2.fromOffset(70, 20),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		ZIndex = 13,
		Parent = profileCard,
	})
	UIS.Corner(6)
	UIS.Stroke(Theme.Accent, 1, 0.4)
	UIS.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = FontBold,
		Text = "PREMIUM",
		TextSize = 9,
		TextColor3 = Theme.Accent,
		ZIndex = 14,
		Parent = badge,
	})

	-- Danh sách điều hướng
	local navContainer = UIS.Create("Frame", {
		Position = UDim2.fromOffset(12, 112),
		Size = UDim2.new(1, -24, 1, -130),
		BackgroundTransparency = 1,
		ZIndex = 12,
		Parent = sidebar,
	})
	UIS.Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = navContainer,
	})

	local navItems = {
		{ name = "Trang chủ",     icon = "🏠", key = "home" },
		{ name = "Scripts",       icon = "📜", key = "scripts" },
		{ name = "Công cụ",       icon = "🛠", key = "tools" },
		{ name = "Cài đặt",       icon = "⚙", key = "settings" },
		{ name = "Giới thiệu",    icon = "ℹ", key = "about" },
	}

	local navButtons = {}
	local activeKey = nil

	-- Khu vực nội dung
	local content = UIS.Create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(210, 44),
		Size = UDim2.new(1, -210, 1, -44),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ZIndex = 11,
		Parent = window,
	})

	-- Hàm chuyển tab
	local pages = {}
	local function SwitchTab(key)
		if activeKey == key then return end
		activeKey = key

		-- Hiệu ứng nav active
		for k, btn in pairs(navButtons) do
			local isActive = (k == key)
			UIS.Tween(btn, {
				BackgroundTransparency = isActive and 0 or 1,
				BackgroundColor3 = Theme.Accent,
			}, 0.2)
			local label = btn:FindFirstChild("NavLabel")
			local icon = btn:FindFirstChild("NavIcon")
			if label then
				UIS.Tween(label, {
					TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Theme.Text,
				}, 0.2)
			end
			if icon then
				UIS.Tween(icon, {
					TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Theme.Text,
				}, 0.2)
			end
		end

		-- Ẩn tất cả page
		for k, page in pairs(pages) do
			if k ~= key then
				UIS.Tween(page, {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 20),
				}, 0.15)
				task.delay(0.16, function()
					if activeKey ~= k then page.Visible = false end
				end)
			end
		end

		-- Hiển thị page mới
		local page = pages[key]
		if page then
			page.Visible = true
			page.BackgroundTransparency = 1
			page.Position = UDim2.fromOffset(0, -20)
			UIS.Tween(page, {
				BackgroundTransparency = 0,
				Position = UDim2.fromOffset(0, 0),
			}, 0.25)
		end
	end

	-- Hàm tạo page
	local function CreatePage(key, order)
		local page = UIS.Create("ScrollingFrame", {
			Name = key,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Background,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Theme.Stroke,
			CanvasSize = UDim2.fromOffset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = 12,
			Parent = content,
		})
		UIS.Padding(18, 22, 18, 22, 18)
		UIS.Create("UIListLayout", {
			Padding = UDim.new(0, 14),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page,
		})
		pages[key] = page
		return page
	end

	-- Hàm tạo thẻ card chuẩn
	local function CreateCard(parent, title, desc, order)
		local card = UIS.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Surface,
			BorderSizePixel = 0,
			LayoutOrder = order or 1,
			ZIndex = 13,
			Parent = parent,
		})
		UIS.Corner(10)
		UIS.Stroke(Theme.Stroke, 1, 0.6)
		UIS.Padding(14, 16, 14, 16, 14)
		UIS.Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			Parent = card,
		})

		UIS.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Font = FontBold,
			Text = title,
			TextSize = 14,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			ZIndex = 14,
			Parent = card,
		})
		UIS.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Font,
			Text = desc,
			TextSize = 12,
			TextWrapped = true,
			TextColor3 = Theme.TextSecondary,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 2,
			ZIndex = 14,
			Parent = card,
		})
		return card
	end

	-- Tạo nội dung cho từng trang
	-- TRANG CHỦ
	do
		local page = CreatePage("home", 1)
		CreateCard(page, "Chào mừng trở lại, " .. LocalPlayer.DisplayName .. "!",
			"Đây là bảng điều khiển trung tâm của Farial Hub. Sử dụng thanh bên trái để điều hướng giữa các tính năng. Mọi thao tác đều được tối ưu hóa và bảo mật.", 1)
		CreateCard(page, "Trạng thái hệ thống",
			"• Kết nối: Đã ổn định\n• Phiên bản: v2.0.0 (ổn định)\n• Máy chủ: Roblox Live\n• Chế độ: An toàn", 2)
		CreateCard(page, "Thông tin nhanh",
			"Thời gian hoạt động: " .. math.floor(os.time()) ..
			"\nNgười chơi trực tuyến: " .. #Players:GetPlayers() ..
			"\nID máy chủ: " .. game.JobId, 3)
	end

	-- SCRIPTS
	do
		local page = CreatePage("scripts", 2)
		CreateCard(page, "Thư viện script",
			"Tổng số script khả dụng: 0\nĐang tải từ máy chủ...\nNhấn nút bên dưới để làm mới danh sách.", 1)
		CreateCard(page, "Gợi ý",
			"Bạn có thể thêm script tùy chỉnh bằng cách kéo thả file vào thư mục workspace/scripts của hub.", 2)
	end

	-- CÔNG CỤ
	do
		local page = CreatePage("tools", 3)
		CreateCard(page, "Công cụ có sẵn",
			"• Trình kiểm tra hiệu năng\n• Trình xem log\n• Bộ điều khiển camera\n• Quản lý keybind", 1)
	end

	-- CÀI ĐẶT
	do
		local page = CreatePage("settings", 4)
		CreateCard(page, "Giao diện",
			"Chủ đề: Tối (MacOS)\nBo góc: 10px\nFont: Gotham\nHiệu ứng: Bật", 1)

		-- Hàng toggle mẫu
		local toggleCard = UIS.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundColor3 = Theme.Surface,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			ZIndex = 13,
			Parent = page,
		})
		UIS.Corner(10)
		UIS.Stroke(Theme.Stroke, 1, 0.6)

		UIS.Create("TextLabel", {
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -100, 1, 0),
			BackgroundTransparency = 1,
			Font = FontMedium,
			Text = "Hiệu ứng chuyển động",
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 14,
			Parent = toggleCard,
		})

		local toggleBg = UIS.Create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -16, 0.5, 0),
			Size = UDim2.fromOffset(44, 24),
			BackgroundColor3 = Theme.Success,
			BorderSizePixel = 0,
			ZIndex = 14,
			Parent = toggleCard,
		})
		UIS.Corner(999)

		local knob = UIS.Create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -2, 0.5, 0),
			Size = UDim2.fromOffset(20, 20),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 15,
			Parent = toggleBg,
		})
		UIS.Corner(999)

		local toggleBtn = UIS.Create("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 16,
			Parent = toggleCard,
		})
		local state = true
		toggleBtn.MouseButton1Click:Connect(function()
			state = not state
			PlayClick()
			UIS.Tween(toggleBg, {
				BackgroundColor3 = state and Theme.Success or Theme.SurfaceHover,
			}, 0.2)
			UIS.Tween(knob, {
				Position = state and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			}, 0.2)
		end)
	end

	-- GIỚI THIỆU
	do
		local page = CreatePage("about", 5)
		CreateCard(page, "Farial Hub",
			"Phiên bản: 2.0.0\nTác giả: Nhism Developer\nNgôn ngữ: Lua / Roblox Luau\nGiấy phép: Miễn phí sử dụng cá nhân", 1)
		CreateCard(page, "Lời cảm ơn",
			"Cảm ơn bạn đã tin tưởng và sử dụng Farial Hub. Chúc bạn có những trải nghiệm tuyệt vời!", 2)
	end

	-- Tạo nav buttons
	for i, item in ipairs(navItems) do
		local btn = UIS.Create("TextButton", {
			Name = item.key,
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = i,
			ZIndex = 13,
			Parent = navContainer,
		})
		UIS.Corner(8)
		UIS.Padding(0, 12, 0, 12, 0)

		local iconLabel = UIS.Create("TextLabel", {
			Name = "NavIcon",
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(24, 38),
			BackgroundTransparency = 1,
			Font = FontBold,
			Text = item.icon,
			TextSize = 16,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 14,
			Parent = btn,
		})
		local nameLabel = UIS.Create("TextLabel", {
			Name = "NavLabel",
			Position = UDim2.fromOffset(32, 0),
			Size = UDim2.new(1, -32, 1, 0),
			BackgroundTransparency = 1,
			Font = FontMedium,
			Text = item.name,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 14,
			Parent = btn,
		})

		navButtons[item.key] = btn

		btn.MouseEnter:Connect(function()
			if activeKey ~= item.key then
				UIS.Tween(btn, { BackgroundTransparency = 0.85, BackgroundColor3 = Theme.SurfaceHover }, 0.15)
			end
		end)
		btn.MouseLeave:Connect(function()
			if activeKey ~= item.key then
				UIS.Tween(btn, { BackgroundTransparency = 1 }, 0.15)
			end
		end)
		btn.MouseButton1Click:Connect(function()
			PlayClick()
			SwitchTab(item.key)
		end)
	end

	-- Kích hoạt trang đầu tiên
	SwitchTab("home")

	--==================== LOGIC KÉO CỬA SỔ ====================
	local dragging, dragStart, startPos = false, nil, nil

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = root.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	--==================== NÚT ĐÓNG ====================
	trafficButtons[1].MouseButton1Click:Connect(function()
		PlayClick()
		local tw = UIS.Tween(root, {
			Size = UDim2.fromOffset(820, 0),
			BackgroundTransparency = 1,
		}, 0.3)
		UIS.Tween(window, { BackgroundTransparency = 1 }, 0.25)
		task.delay(0.3, function()
			ScreenGui:Destroy()
		end)
	end)

	--==================== NÚT THU NHỎ ====================
	local minimized = false
	local savedSize = UDim2.fromOffset(820, 540)
	trafficButtons[2].MouseButton1Click:Connect(function()
		PlayClick()
		minimized = not minimized
		if minimized then
			savedSize = root.Size
			local tw = TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(root.AbsoluteSize.X, 44),
			})
			tw:Play()
			UIS.Tween(sidebar, { BackgroundTransparency = 1 }, 0.25)
			UIS.Tween(content, { BackgroundTransparency = 1 }, 0.25)
		else
			local tw = TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = savedSize,
			})
			tw:Play()
			UIS.Tween(sidebar, { BackgroundTransparency = 0 }, 0.25)
			UIS.Tween(content, { BackgroundTransparency = 0 }, 0.25)
		end
	end)

	--==================== NÚT PHÓNG TO ====================
	local maximized = false
	trafficButtons[3].MouseButton1Click:Connect(function()
		PlayClick()
		maximized = not maximized
		if maximized then
			local tw = TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(1100, 680),
			})
			tw:Play()
		else
			local tw = TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(820, 540),
			})
			tw:Play()
		end
	end)

	--==================== HIỆU ỨNG MỞ CỬA SỔ ====================
	root.Size = UDim2.fromOffset(600, 380)
	local openTw = TweenService:Create(root, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(820, 540),
	})
	openTw:Play()

	return root
end

--==================== HỆ THỐNG THÔNG BÁO ====================
local notifHolder
local function CreateNotifHolder()
	notifHolder = UIS.Create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 20),
		Size = UDim2.fromOffset(340, 600),
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = ScreenGui,
	})
	UIS.Create("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Parent = notifHolder,
	})
end

local Notify = {}
Notify.__queue = {}

function Notify:Show(config)
	config = config or {}
	local title    = config.Title or "Thông báo"
	local message  = config.Message or ""
	local duration = config.Duration or 4
	local kind     = config.Type or "info"

	local iconMap = {
		info    = { icon = "ℹ",  color = Theme.Accent },
		success = { icon = "✓", color = Theme.Success },
		warning = { icon = "⚠", color = Theme.Warning },
		error   = { icon = "✕", color = Theme.Danger },
		loading = { icon = "◌", color = Theme.TextSecondary },
	}
	local style = iconMap[kind] or iconMap.info

	local notif = UIS.Create("Frame", {
		Size = UDim2.fromOffset(340, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		BackgroundTransparency = 0.05,
		ZIndex = 201,
		ClipsDescendants = true,
		Parent = notifHolder,
	})
	UIS.Corner(12)
	UIS.Stroke(Theme.Stroke, 1, 0.5)
	UIS.Padding(12, 14, 12, 14, 12)

	-- Thanh màu bên trái
	local bar = UIS.Create("Frame", {
		Position = UDim2.new(0, -14, 0, -12),
		Size = UDim2.fromOffset(4, 60),
		BackgroundColor3 = style.color,
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = notif,
	})
	UIS.Corner(999)

	-- Icon
	local iconBg = UIS.Create("Frame", {
		Position = UDim2.fromOffset(0, 4),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = style.color,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = notif,
	})
	UIS.Corner(8)
	local iconLabel = UIS.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = FontBold,
		Text = style.icon,
		TextSize = 16,
		TextColor3 = style.color,
		ZIndex = 203,
		Parent = iconBg,
	})

	-- Nếu là loading, xoay icon
	local spinConn
	if kind == "loading" then
		spinConn = RunService.RenderStepped:Connect(function(dt)
			if not iconLabel.Parent then spinConn:Disconnect() return end
			iconLabel.Rotation = (iconLabel.Rotation + dt * 360) % 360
		end)
	end

	-- Tiêu đề
	UIS.Create("TextLabel", {
		Position = UDim2.fromOffset(38, 4),
		Size = UDim2.new(1, -38, 0, 18),
		BackgroundTransparency = 1,
		Font = FontBold,
		Text = title,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 202,
		Parent = notif,
	})

	-- Nội dung
	local msgLabel = UIS.Create("TextLabel", {
		Position = UDim2.fromOffset(38, 24),
		Size = UDim2.new(1, -38, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Font,
		Text = message,
		TextSize = 12,
		TextWrapped = true,
		TextColor3 = Theme.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 202,
		Parent = notif,
	})

	-- Thanh tiến trình đếm ngược
	local progressBg = UIS.Create("Frame", {
		Position = UDim2.new(0, -14, 1, 10),
		Size = UDim2.new(1, 28, 0, 3),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = notif,
	})
	UIS.Corner(999)
	local progressFill = UIS.Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = style.color,
		BorderSizePixel = 0,
		ZIndex = 203,
		Parent = progressBg,
	})
	UIS.Corner(999)

	-- Hiệu ứng trượt vào
	notif.Position = UDim2.fromOffset(400, 0)
	UIS.Tween(notif, { Position = UDim2.fromOffset(0, 0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	-- Tự ẩn
	if kind ~= "loading" and duration > 0 then
		UIS.Tween(progressFill, { Size = UDim2.fromScale(0, 1) }, duration, Enum.EasingStyle.Linear)
		task.delay(duration, function()
			if notif.Parent then
				Notify:Close(notif)
			end
		end)
	end

	return {
		Frame = notif,
		Close = function() Notify:Close(notif) end,
		SetText = function(txt) msgLabel.Text = txt end,
		SetTitle = function(txt) end,
	}
end

function Notify:Close(notif)
	if not notif or not notif.Parent then return end
	UIS.Tween(notif, {
		Position = UDim2.fromOffset(400, 0),
		BackgroundTransparency = 1,
	}, 0.25)
	task.delay(0.28, function()
		if notif then notif:Destroy() end
	end)
end

--==================== KHỞI CHẠY ====================
CreateNotifHolder()
CreateLoadingScreen()

-- Đợi loading xong rồi tạo cửa sổ chính
task.wait(3.2)
CreateMainWindow()

-- Ví dụ phát thông báo
task.wait(0.4)
Notify:Show({
	Title = "Khởi động thành công",
	Message = "Farial Hub đã sẵn sàng. Chúc bạn chơi game vui vẻ!",
	Type = "success",
	Duration = 4,
})

task.wait(1)
Notify:Show({
	Title = "Đang tải script",
	Message = "Đang đồng bộ thư viện từ máy chủ...",
	Type = "loading",
	Duration = 0,
})

task.wait(2)
Notify:Show({
	Title = "Cập nhật",
	Message = "Phiên bản 2.0.0 đã được cài đặt. Xem chi tiết trong mục Giới thiệu.",
	Type = "info",
	Duration = 5,
})

--==================== API CÔNG KHAI ====================
-- _G.FarialHub.Notify:Show({...})
_G.FarialHub = _G.FarialHub or {}
_G.FarialHub.Notify = Notify