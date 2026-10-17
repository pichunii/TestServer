-- [[ BAKHI UI LIBRARY - STANDALONE EXTRACTION ]]
-- Tách nguyên bản UI, hiệu ứng, âm thanh, animation.
-- Không chứa bất kỳ logic game nào (Farm, Aimbot, v.v.)

if not game:IsLoaded() then game.Loaded:Wait() end
local ps = game:GetService("Players")
repeat task.wait() until ps.LocalPlayer
local lp = ps.LocalPlayer

local ge = getgenv and getgenv() or _G

-- ==========================================
-- [ UI LIBRARY CORE (KHÔNG CHỈNH SỬA) ]
-- ==========================================
local L
L = (function()
local ps, uis, tws, gs, hs = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("GuiService"), game:GetService("HttpService")
local ge = getgenv and getgenv() or _G
local hx, wt = Color3.fromHex, Color3.new(1, 1, 1)
local c = {cr = hx("07101C"), sh = hx("8CDCFF"), ac = hx("4FD8FF"), a2 = hx("8FE3FF"), dm = hx("9FC6D6"), ok = hx("7DFFB0"), er = hx("FF5A6A"), r1 = hx("FF2A6A"), r2 = hx("2AF0FF"), hi = hx("BFF2FF")}
local bs = "rbxasset://fonts/families/BuilderSans.json"
local fn, fs, fb, fm, fj = Font.new(bs, Enum.FontWeight.Medium), Font.new(bs, Enum.FontWeight.SemiBold), Font.new(bs, Enum.FontWeight.Bold), Font.fromEnum(Enum.Font.Michroma), Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Bold)
local ir = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json")
local ww, wh, nw, th = 580, 340, 136, 48
local mb, tc, mm, kb = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.UserInputType.MouseMovement, Enum.UserInputType.Keyboard
local ti, tb2 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local L = {Flags = {}}

local function mk(k, p, ch)
	local o = Instance.new(k)
	for i, v in p do
		if i ~= "Parent" then o[i] = v end
	end
	for _, x in ch or {} do x.Parent = o end
	o.Parent = p.Parent
	return o
end

local function rc(r) return mk("UICorner", {CornerRadius = UDim.new(0, r)}) end
local function sk(t, col, w) return mk("UIStroke", {Color = col or wt, Transparency = t, Thickness = w or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}) end
local function pd(l, r, t, b) return mk("UIPadding", {PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r or l), PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or t or 0)}) end
local function ll(g) return mk("UIListLayout", {Padding = UDim.new(0, g), SortOrder = Enum.SortOrder.LayoutOrder}) end
local function tw(o, p, i) tws:Create(o, i or ti, p):Play() end
local function ns(t) local k = {}; for i = 1, #t, 2 do k[#k + 1] = NumberSequenceKeypoint.new(t[i], t[i + 1]) end; return NumberSequence.new(k) end

local function tl(p, ch)
	local d = {BackgroundTransparency = 1, FontFace = fn, TextColor3 = wt, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Text = ""}
	for i, v in p do d[i] = v end
	return mk("TextLabel", d, ch)
end

local function ig(p, ch)
	local d = {BackgroundTransparency = 1, FontFace = ir, TextColor3 = c.dm, TextSize = 14, Text = ""}
	for i, v in p do d[i] = v end
	return mk("TextLabel", d, ch)
end

local function bt(p, ch)
	local d = {BackgroundTransparency = 1, AutoButtonColor = false, Text = "", BorderSizePixel = 0}
	for i, v in p do d[i] = v end
	return mk("TextButton", d, ch)
end

local function rg(s, w, col, t, q)
	return mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(s, s), BackgroundTransparency = 1}, {rc(s), mk("UIStroke", {Color = col, Thickness = w, Transparency = t or 0}, {q and mk("UIGradient", {Transparency = ns(q)}) or nil})})
end

local function rx(p, s)
	local f = mk("Frame", {Size = UDim2.fromOffset(s, s), BackgroundTransparency = 1, Parent = p})
	local a = rg(s - 2, 2, c.ac, 0, {0, 0, 0.34, 0, 0.35, 1, 0.65, 1, 0.66, 0, 1, 0})
	local b = rg(math.round(s * 0.62), 1, c.a2, 0, {0, 0, 0.5, 0, 0.6, 1, 1, 1})
	a.Parent, b.Parent = f, f
	local d = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(math.round(s * 0.3), math.round(s * 0.3)), BackgroundColor3 = c.hi, BorderSizePixel = 0, Parent = f}, {rc(s), sk(0.4, c.ac, 2)})
	for _, x in {a, b, d} do
		x.Size = UDim2.fromScale(x.Size.X.Offset / s, x.Size.Y.Offset / s)
		x:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0.5, 0)
	end
	return f, a, b
end
L.Reactor = rx

local function gui()
	local sg = mk("ScreenGui", {Name = hs:GenerateGUID(false), IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999})
	if not pcall(function() sg.Parent = gethui and gethui() or game:GetService("CoreGui") end) then sg.Parent = ps.LocalPlayer:WaitForChild("PlayerGui") end
	return sg
end

local function fit(sg, f, sc)
	local s, i = sg.AbsoluteSize, gs:GetGuiInset().Y
	local v = math.clamp(math.min((s.X - 24) / ww, (s.Y - i - 24) / wh), 0.5, 1)
	sc.Scale = v
	f.Position = UDim2.fromOffset(s.X / 2, i + (s.Y - i) / 2)
	return v
end

local function cfn(s)
	if s == nil then return true end
	if type(s) ~= "string" or s == "" then return false end
	for sg in (s .. "/"):gmatch("([^/]*)/") do
		if not sg:match("^[%w _%-]+$") then return false end
	end
	return true
end

local function mkd(p)
	local d = ""
	for sg in p:gmatch("([^/]+)/") do
		d = d == "" and sg or d .. "/" .. sg
		if not isfolder(d) then makefolder(d) end
	end
end

local function hv(f, st)
	f.MouseEnter:Connect(function()
		if not uis.MouseEnabled then return end
		tw(f, {BackgroundColor3 = c.ac, BackgroundTransparency = 0.93})
		tw(st, {Color = c.ac, Transparency = 0.67})
	end)
	f.MouseLeave:Connect(function()
		tw(f, {BackgroundColor3 = wt, BackgroundTransparency = 0.957})
		tw(st, {Color = wt, Transparency = 0.92})
	end)
	f.MouseButton1Down:Connect(function() tw(f, {BackgroundColor3 = c.ac, BackgroundTransparency = 0.85}, TweenInfo.new(0.05)) end)
	f.MouseButton1Up:Connect(function() tw(f, {BackgroundColor3 = uis.MouseEnabled and c.ac or wt, BackgroundTransparency = uis.MouseEnabled and 0.93 or 0.957}) end)
end

local function bx(p, w)
	local b = bt({AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(w or 150, 28), BackgroundColor3 = wt, BackgroundTransparency = 0.937, Parent = p}, {rc(8), sk(0.81, c.ac)})
	return b, b:FindFirstChildOfClass("UIStroke")
end

function L:Window(o)
	o = o or {}
	if not cfn(o.Config) then error("Window Failed: Bad Config", 0) end
	if ge.__BkW then pcall(ge.__BkW.Destroy, ge.__BkW) end
	local W = {Tabs = {}, Current = nil, cn = {}, key = o.Key == nil and Enum.KeyCode.LeftControl or o.Key, kw = false, fc = nil, sv = 1, gd = 0.82, hc = false, ag = 0, op = true, ln = false}
	local sg = gui()
	W.Gui = sg
	local mn = mk("Frame", {Name = "Main", Size = UDim2.fromOffset(ww, wh), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Parent = sg})
	W.Main = mn
	local sc = mk("UIScale", {Parent = mn})
	local shl = mk("Frame", {Name = "Shell", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), BackgroundColor3 = c.sh, BackgroundTransparency = 0.88, BorderSizePixel = 0, Parent = mn}, {rc(24), mk("UIStroke", {Color = wt, Thickness = 1.4}, {mk("UIGradient", {Rotation = 60, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, wt), ColorSequenceKeypoint.new(0.35, wt), ColorSequenceKeypoint.new(0.65, c.ac), ColorSequenceKeypoint.new(1, c.hi)}), Transparency = ns({0, 0, 0.35, 0.81, 0.65, 0.87, 1, 0.13})})})})
	local bks = {}
	for i, a in {{0, 0}, {1, 0}, {0, 1}, {1, 1}} do
		local x, y = a[1], a[2]
		local f = mk("Frame", {AnchorPoint = Vector2.new(x, y), Position = UDim2.new(x, x == 0 and -6 or 6, y, y == 0 and -6 or 6), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, ZIndex = 3, Name = "Bk" .. i, Parent = mn})
		mk("Frame", {AnchorPoint = Vector2.new(x, y), Position = UDim2.fromScale(x, y), Size = UDim2.fromOffset(20, 2), BackgroundColor3 = c.ac, BorderSizePixel = 0, ZIndex = 3, Parent = f})
		mk("Frame", {AnchorPoint = Vector2.new(x, y), Position = UDim2.fromScale(x, y), Size = UDim2.fromOffset(2, 20), BackgroundColor3 = c.ac, BorderSizePixel = 0, ZIndex = 3, Parent = f})
		bks[i] = {f, f.Position, UDim2.new(x, x == 0 and -36 or 36, y, y == 0 and -36 or 36)}
	end
	local cr = mk("Frame", {Name = "Core", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -14, 1, -14), BackgroundColor3 = c.cr, BackgroundTransparency = 1 - W.gd, BorderSizePixel = 0, ClipsDescendants = true, Parent = mn}, {rc(18), sk(0.81, c.ac)})
	W.Core = cr
	local bgh = mk("Frame", {Name = "Fx", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = cr})
	local tb = mk("Frame", {Size = UDim2.new(1, 0, 0, th), BackgroundTransparency = 1, Parent = cr})
	local re, ra, rb = rx(tb, 30)
	re.Position = UDim2.fromOffset(16, 9)
	local ttx = tostring(o.Title or "BAKHI HUB")
	local tt = tl({Text = ttx, FontFace = fm, TextSize = 14, Position = UDim2.fromOffset(57, 8), Size = UDim2.new(1, -250, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = tb})
	local t1 = tl({Text = ttx, FontFace = fm, TextSize = 14, TextColor3 = c.r1, TextTransparency = 0.45, Position = UDim2.fromOffset(56, 8), Size = tt.Size, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = tb})
	local t2 = tl({Text = ttx, FontFace = fm, TextSize = 14, TextColor3 = c.r2, TextTransparency = 0.45, Position = UDim2.fromOffset(58, 8), Size = tt.Size, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = tb})
	W.tt = {tt, t1, t2}
	local sbt = tl({Text = tostring(o.Subtitle or ""), FontFace = fj, TextSize = 10, TextColor3 = c.a2, Position = UDim2.fromOffset(57, 28), Size = UDim2.new(1, -250, 0, 12), TextTruncate = Enum.TextTruncate.AtEnd, Parent = tb})
	local function sst(s, a) W.ss.Text = `SYS <font color="#{c.ok:ToHex()}" transparency="{a or 0}">{s}</font>` end
	W.ss = tl({Text = `SYS <font color="#{c.ok:ToHex()}">ONLINE</font>`, RichText = true, FontFace = fj, TextSize = 10, TextColor3 = c.a2, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -84, 0, 0), Size = UDim2.fromOffset(100, th), Parent = tb})
	local function cap(x, g)
		local b = bt({Size = UDim2.fromOffset(28, 24), Position = UDim2.new(1, x, 0, 12), BackgroundColor3 = wt, Parent = tb}, {rc(6)})
		local i = ig({Text = g, Size = UDim2.fromScale(1, 1), Parent = b})
		b.MouseEnter:Connect(function() if uis.MouseEnabled then tw(b, {BackgroundTransparency = 0.9}) end end)
		b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = 1}) end)
		return b, i
	end
	local xb, xi = cap(-42, "x")
	local nb = cap(-74, "minus")
	local tsf = mk("Frame", {AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -12), Size = UDim2.fromOffset(300, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 100, Parent = sg}, {ll(8)})

	function W:Notify(n)
		n = n or {}
		if n.Title == nil and n.Text == nil then error("Notify Failed: No Text", 0) end
		local t = n.Time == nil and 4 or n.Time
		if type(t) ~= "number" or t ~= t or t <= 0 then error("Notify Failed: Bad Time", 0) end
		local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = c.cr, BackgroundTransparency = 0.08, BorderSizePixel = 0, ZIndex = 100, Parent = tsf}, {rc(12), sk(0.6, n.Error and c.er or c.ac), pd(20, 14, 10, 10)})
		mk("Frame", {Position = UDim2.fromOffset(-12, 2), Size = UDim2.new(0, 3, 1, -4), BackgroundColor3 = n.Error and c.er or c.ac, BorderSizePixel = 0, ZIndex = 101, Parent = f}, {rc(2)})
		local ly = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 101, Parent = f}, {ll(2)})
		tl({Text = tostring(n.Title or "BaKhi Hub"), FontFace = fb, Size = UDim2.new(1, 0, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 102, LayoutOrder = 1, Parent = ly})
		if n.Text ~= nil then tl({Text = tostring(n.Text), TextSize = 13, TextColor3 = c.dm, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, ZIndex = 102, LayoutOrder = 2, Parent = ly}) end
		local us = mk("UIScale", {Scale = 0.9, Parent = f})
		tw(us, {Scale = 1}, tb2)
		task.delay(t, function() if f.Parent then f:Destroy() end end)
		return f
	end

	local function run(f, ...)
		if not f then return end
		local ok, e = pcall(f, ...)
		if ok then return end
		warn("Callback Failed: " .. tostring(e))
		W:Notify({Title = "Callback Failed", Text = tostring(e), Error = true})
	end

	local cp, cd, dirty, pend, dead = o.Config and `BaKhi/Configs/{o.Config}.json`, {}, false, false, false
	if cp and isfile and isfile(cp) then
		local ok, d = pcall(function() return hs:JSONDecode(readfile(cp)) end)
		if ok and type(d) == "table" then cd = d else
			pcall(function() writefile(cp .. ".bad", readfile(cp)); delfile(cp) end)
			W:Notify({Title = "Config Load Failed", Text = "Invalid Json", Error = true})
		end
	end
	local function save()
		if not cp or not dirty then return end
		dirty = false
		pcall(function()
			mkd(cp)
			writefile(cp, hs:JSONEncode(cd))
		end)
	end
	local function put(e, v)
		if not e.Flag then return end
		L.Flags[e.Flag] = v
		if not cp then return end
		if e.sv then cd[e.Flag] = e.sv(v) else cd[e.Flag] = v end
		dirty = true
		if pend or dead then return end
		pend = true
		task.delay(0.5, function() pend = false; save() end)
	end
	local function done(e)
		if not e.Flag then return end
		L.Flags[e.Flag] = e:Get()
		local s = cd[e.Flag]
		if s == nil then return end
		pcall(function()
			if e.ld then s = e.ld(s) end
			e:Set(s)
		end)
	end

	local nv = mk("Frame", {Name = "Nav", Position = UDim2.fromOffset(12, th), Size = UDim2.new(0, nw, 1, -(th + 12)), BackgroundColor3 = wt, BackgroundTransparency = 0.969, BorderSizePixel = 0, Parent = cr}, {rc(14), pd(6, 6, 6, 6)})
	local tf = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = nv})
	local ind = mk("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = c.ac, BorderSizePixel = 0, Visible = false, Parent = tf}, {rc(10), sk(0.53, c.ac), mk("UIGradient", {Transparency = ns({0, 0.69, 1, 0.92})})})
	mk("Frame", {Position = UDim2.fromOffset(0, 8), Size = UDim2.fromOffset(3, 16), BackgroundColor3 = c.ac, BorderSizePixel = 0, ZIndex = 2, Parent = ind}, {rc(2)})
	local pa = mk("Frame", {Name = "Pages", Position = UDim2.fromOffset(nw + 22, th), Size = UDim2.new(1, -(nw + 34), 1, -(th + 12)), BackgroundTransparency = 1, ClipsDescendants = true, Parent = cr})
	local ov = bt({Name = "Overlay", Size = UDim2.fromScale(1, 1), ZIndex = 50, Visible = false, Parent = mn})
	ov.Activated:Connect(function() if W.fc then W.fc() end end)

	local fl = bt({Name = "Float", Size = UDim2.fromOffset(44, 44), BackgroundColor3 = c.cr, BackgroundTransparency = 0.15, Parent = sg}, {rc(22), sk(0.45, c.ac)})
	local fr, fa, fq = rx(fl, 26)
	fr.AnchorPoint, fr.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
	for _, x in fr:GetDescendants() do
		if x:IsA("GuiObject") then x.Active = false end
	end

	local function fx()
		W.sv = fit(sg, mn, sc)
		fl.Position = UDim2.fromOffset(16, gs:GetGuiInset().Y + 8)
	end
	fx()
	table.insert(W.cn, sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(fx))

	local lv = {Full = true, Light = true, Off = true}
	W.fx, W.ba, W.on, W.bk = lv[cd.fx] and cd.fx or ((uis.TouchEnabled and not uis.MouseEnabled) and "Light" or "Full"), cd.ba ~= false, false, false
	if type(cd.gd) == "number" and cd.gd == cd.gd then W.gd = math.clamp(cd.gd, 40, 95) / 100 end
	cr.BackgroundTransparency = 1 - W.gd
	local hr = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -65, 1, -55), Size = UDim2.fromOffset(250, 250), BackgroundTransparency = 1, Parent = bgh})
	local hl, pt = {}, {}
	for _, d in {{236, 1, 0.55, {0, 0, 0.3, 0, 0.31, 1, 0.45, 1, 0.46, 0, 1, 0}, 20}, {214, 5, 0.78, {0, 0, 0.6, 0, 0.61, 1, 1, 1}, -12}, {176, 2, 0.6, {0, 1, 0.2, 1, 0.21, 0, 0.5, 0, 0.51, 1, 0.75, 1, 0.76, 0, 1, 0}, -40}, {128, 1, 0.65}, {100, 3, 0.55, {0, 0, 0.25, 0, 0.26, 1, 1, 1}, 72}} do
		local r = rg(d[1], d[2], c.ac, d[3], d[4])
		r.Parent = hr
		if d[5] then hl[#hl + 1] = {r, d[5]} end
	end
	for i = 1, 12 do
		pt[i] = {f = mk("Frame", {Size = UDim2.fromOffset(3, 3), BackgroundColor3 = c.ac, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = bgh}, {rc(2)}), t = math.random(), d = 5 + math.random() * 7, x = math.random(), y = 0.6 + math.random() * 0.45}
	end
	local swp = mk("Frame", {Name = "Sweep", Size = UDim2.fromScale(1, 1), BackgroundColor3 = wt, BorderSizePixel = 0, ZIndex = 40, Parent = cr}, {rc(18)})
	local sgd = mk("UIGradient", {Rotation = 20, Offset = Vector2.new(-1, 0), Transparency = ns({0, 1, 0.42, 1, 0.47, 0.82, 0.5, 0.74, 0.53, 0.82, 0.58, 1, 1, 1}), Parent = swp})
	local ru = game:GetService("RunService")
	local s0, b0 = 3, 0
	local function hb(dt)
		for _, x in {{ra, 164}, {rb, -90}, {fa, 164}, {fq, -90}} do x[1].Rotation = (x[1].Rotation + x[2] * dt) % 360 end
		if W.fx == "Full" then
			for _, x in hl do x[1].Rotation = (x[1].Rotation + x[2] * dt) % 360 end
			for _, q in pt do
				q.t += dt / q.d
				if q.t >= 1 then q.t, q.x, q.y, q.d = 0, math.random(), 0.6 + math.random() * 0.45, 5 + math.random() * 7 end
				q.f.Position, q.f.BackgroundTransparency = UDim2.new(q.x, 0, q.y, -q.t * 260), 1 - (q.t < 0.15 and q.t / 0.15 or (1 - q.t) / 0.85) * 0.8
			end
		end
		s0 += dt
		if s0 >= (W.fx == "Full" and 6 or 12) then
			s0, sgd.Offset = 0, Vector2.new(-1, 0)
			tw(sgd, {Offset = Vector2.new(1, 0)}, TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
		end
		b0 += dt
		if W.on and b0 >= 0.7 then
			b0, W.bk = 0, not W.bk
			sst("ONLINE", W.bk and 0.65 or 0)
		end
	end
	function W.up()
		local on = mn.Visible and W.fx ~= "Off" and not dead
		if on and not W.hc then W.hc = ru.Heartbeat:Connect(hb) elseif not on and W.hc then W.hc:Disconnect(); W.hc = false end
		hr.Visible = W.fx == "Full"
		for _, q in pt do q.f.Visible = W.fx == "Full" end
		if W.fx == "Off" and W.on then sst("ONLINE") end
	end
	function W:Effects(v)
		if not lv[v] then error("Effects Failed: Bad Level", 0) end
		W.fx = v
		W.up()
	end
	local function fl2(f)
		if W.fx == "Off" then return end
		f.BackgroundColor3, f.BackgroundTransparency = c.ac, 0.75
		tw(f, {BackgroundColor3 = wt, BackgroundTransparency = 0.957}, TweenInfo.new(0.5))
	end
	local function rpl(a)
		if W.fx == "Off" then return end
		local r = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(), BackgroundTransparency = 1, ZIndex = 5, Parent = a}, {rc(200), sk(0, c.ac, 2)})
		tw(r, {Size = UDim2.fromOffset(120, 120)}, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		tw(r:FindFirstChildOfClass("UIStroke"), {Transparency = 1}, TweenInfo.new(0.6))
		task.delay(0.65, function() r:Destroy() end)
	end
	local function scn(f, d)
		if W.fx == "Off" or not f:IsA("GuiButton") then return end
		local s = mk("Frame", {Position = UDim2.fromOffset(-94, 0), Size = UDim2.new(0, 60, 1, 0), BackgroundColor3 = c.ac, BorderSizePixel = 0, ZIndex = 4, Parent = f}, {mk("UIGradient", {Transparency = ns({0, 1, 0.5, 0.6, 1, 1})})})
		task.delay(d, function() if s.Parent then tw(s, {Position = UDim2.new(1, 20, 0, 0)}, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)) end end)
		task.delay(d + 0.75, function() s:Destroy() end)
	end
	local function glt(p)
		if W.fx == "Off" then return end
		for i, q in {{4, 52, 62}, {-3, 59, 53}, {0, 56, 58}} do
			task.delay((i - 1) * 0.09, function()
				p.Position = UDim2.fromOffset(q[1], 0)
				t1.Position, t2.Position = UDim2.fromOffset(q[2], 8), UDim2.fromOffset(q[3], 8)
			end)
		end
		for i, e in W.Current.Rows do scn(e.Row, 0.05 + (i - 1) * 0.06) end
	end
	local function ty(ls, sp, g)
		local n = utf8.len(ls[1].Text) or #ls[1].Text
		for i = 0, n do
			if dead or W.ag ~= g then return end
			for _, l in ls do l.MaxVisibleGraphemes = i end
			task.wait(sp)
		end
		for _, l in ls do l.MaxVisibleGraphemes = -1 end
	end
	local t0 = TweenInfo.new(0)
	local function lnf(w)
		if W.ln then W.ln:Destroy() end
		W.ln = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(w, 0, 0, 2), BackgroundColor3 = wt, BorderSizePixel = 0, ZIndex = 6, Parent = mn}, {mk("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c.ac), ColorSequenceKeypoint.new(0.5, wt), ColorSequenceKeypoint.new(1, c.ac)}), Transparency = ns({0, 1, 0.2, 0, 0.8, 0, 1, 1})})})
		return W.ln
	end
	local function whole()
		if W.ln then W.ln:Destroy(); W.ln = false end
		tw(shl, {Size = UDim2.fromScale(1, 1)}, t0)
		cr.Visible = true
		for _, b in bks do
			b[1].Visible = true
			tw(b[1], {Position = b[2]}, t0)
		end
		for _, l in {tt, t1, t2, sbt} do l.MaxVisibleGraphemes = -1 end
		for _, T in W.Tabs do tw(T.nm, {TextTransparency = 0}, t0) end
		ind.Visible = W.Current ~= nil
		W.on = true
		sst("ONLINE")
	end
	local function boot(g)
		local k = W.fx == "Light" and 0.4 or 1
		W.on = false
		sst("BOOT")
		local ln = lnf(0)
		tw(shl, {Size = UDim2.new(1, 0, 0, 2)}, t0)
		cr.Visible = false
		for _, b in bks do
			b[1].Visible = false
			tw(b[1], {Position = b[3]}, t0)
		end
		for _, l in {tt, t1, t2, sbt} do l.MaxVisibleGraphemes = 0 end
		task.spawn(function()
			local function z(s) task.wait(s * k); return dead or W.ag ~= g end
			tw(ln, {Size = UDim2.new(1, 0, 0, 2)}, TweenInfo.new(0.35 * k, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
			if z(0.35) then return end
			tw(ln, {BackgroundTransparency = 1}, TweenInfo.new(0.4 * k))
			tw(shl, {Size = UDim2.fromScale(1, 1)}, TweenInfo.new(0.45 * k, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
			if z(0.4) then return end
			for _, T in W.Tabs do tw(T.nm, {TextTransparency = 1}, t0) end
			ind.Visible = false
			for _, s in {0.06, 0.05, 0.07, 0.04, 0.08, 0.05} do
				cr.Visible = not cr.Visible
				if z(s) then return end
			end
			cr.Visible = true
			if W.ln == ln then ln:Destroy(); W.ln = false end
			for _, b in bks do
				b[1].Visible = true
				tw(b[1], {Position = b[2]}, TweenInfo.new(0.45 * k, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
			end
			task.spawn(ty, {tt, t1, t2}, 0.055 * k, g)
			task.delay(0.4 * k, ty, {sbt}, 0.022 * k, g)
			if z(0.25) then return end
			for i, T in W.Tabs do task.delay((i - 1) * 0.07 * k, function() if W.ag == g then tw(T.nm, {TextTransparency = 0}) end end) end
			if z(0.2) then return end
			ind.Visible = W.Current ~= nil
			for i, e in W.Current and W.Current.Rows or {} do scn(e.Row, (i - 1) * 0.08 * k) end
			if z(0.6) then return end
			W.on = true
			sst("ONLINE")
		end)
	end
	local function fold(g)
		local k = W.fx == "Light" and 0.4 or 1
		local function z(s) task.wait(s * k); return dead or W.ag ~= g end
		W.on = false
		sst("OFFLINE")
		for _, b in bks do tw(b[1], {Position = b[3]}, TweenInfo.new(0.2 * k, Enum.EasingStyle.Quad, Enum.EasingDirection.In)) end
		if z(0.15) then return end
		for _, b in bks do b[1].Visible = false end
		for _, s in {0.04, 0.05, 0.03, 0.05} do
			cr.Visible = not cr.Visible
			if z(s) then return end
		end
		cr.Visible = false
		local ln = lnf(1)
		tw(shl, {Size = UDim2.new(1, 0, 0, 2)}, TweenInfo.new(0.25 * k, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
		if z(0.25) then return end
		tw(ln, {Size = UDim2.new(0, 0, 0, 2)}, TweenInfo.new(0.2 * k, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
		if z(0.2) then return end
		if W.ln == ln then ln:Destroy(); W.ln = false end
		mn.Visible = false
		W.up()
	end
	local function an2() return W.ba and W.fx ~= "Off" end

	function W:Show()
		W.ag += 1
		W.op, mn.Visible, sc.Scale = true, true, W.sv
		W.up()
		if an2() then boot(W.ag) else whole() end
	end
	function W:Hide()
		W.ag += 1
		W.op = false
		if an2() and mn.Visible then task.spawn(fold, W.ag); return end
		whole()
		mn.Visible = false
		W.up()
	end
	local function tg() if W.op then W:Hide() else W:Show() end end
	fl.Activated:Connect(tg)
	nb.Activated:Connect(function() W:Hide() end)
	local arm, an = false, 0
	xb.Activated:Connect(function()
		if arm then W:Destroy(); return end
		arm, an = true, an + 1
		local n = an
		tw(xb, {BackgroundColor3 = c.er, BackgroundTransparency = 0})
		xi.TextColor3 = wt
		task.delay(3, function()
			if an ~= n or not arm then return end
			arm = false
			tw(xb, {BackgroundColor3 = wt, BackgroundTransparency = 1})
			xi.TextColor3 = c.dm
		end)
	end)

	local dr
	table.insert(W.cn, tb.InputBegan:Connect(function(i)
		if i.UserInputType ~= mb and i.UserInputType ~= tc then return end
		local p0, d0 = mn.Position, i.Position
		dr = {i = i, mv = function(p)
			local s, n, hw, hh = sg.AbsoluteSize, gs:GetGuiInset().Y, mn.AbsoluteSize.X / 2, mn.AbsoluteSize.Y / 2
			mn.Position = UDim2.fromOffset(math.clamp(p0.X.Offset + p.X - d0.X, hw, s.X - hw), math.clamp(p0.Y.Offset + p.Y - d0.Y, n + hh, s.Y - hh))
		end}
	end))
	table.insert(W.cn, uis.InputChanged:Connect(function(i)
		if not dr or (i.UserInputType ~= mm and i ~= dr.i) then return end
		dr.mv(i.Position)
	end))
	table.insert(W.cn, uis.InputEnded:Connect(function(i)
		if not dr or (i ~= dr.i and i.UserInputType ~= mb) then return end
		if dr.up then dr.up() end
		dr = nil
	end))
	table.insert(W.cn, uis.InputBegan:Connect(function(i)
		if i.UserInputType ~= kb or W.kw or not W.key or i.KeyCode ~= W.key or uis:GetFocusedTextBox() then return end
		tg()
	end))

	function W:Tab(t)
		t = t or {}
		local T = {Rows = {}, Name = tostring(t.Name or "Tab"), W = W, n = 0, sec = nil, i = #W.Tabs + 1}
		local b = bt({Position = UDim2.fromOffset(0, (T.i - 1) * 36), Size = UDim2.new(1, 0, 0, 32), ZIndex = 2, Parent = tf})
		local nm = tl({Text = T.Name, FontFace = fs, TextSize = 13, TextColor3 = c.dm, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -16, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = b})
		local p = mk("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = c.a2, ScrollBarImageTransparency = 0.4, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Parent = pa}, {ll(6), pd(1, 8, 1, 4)})
		T.Page, T.Btn, T.nm = p, b, nm
		function T.pt(on) tw(nm, {TextColor3 = on and wt or c.dm}) end
		b.MouseEnter:Connect(function() if uis.MouseEnabled and W.Current ~= T then tw(nm, {TextColor3 = c.a2}) end end)
		b.MouseLeave:Connect(function() if W.Current ~= T then tw(nm, {TextColor3 = c.dm}) end end)
		function T:Select()
			if W.Current == T then return end
			local f = W.Current == nil
			if W.Current then W.Current.Page.Visible = false; W.Current.pt(false) end
			W.Current, p.Visible = T, true
			T.pt(true)
			local y = UDim2.fromOffset(0, (T.i - 1) * 36)
			if f then ind.Position, ind.Visible = y, true else tw(ind, {Position = y}, tb2); glt(p) end
		end
		b.Activated:Connect(function() T:Select() end)
		table.insert(W.Tabs, T)
		if not W.Current then T:Select() end

		local function add(e)
			T.n += 1
			e.Row.LayoutOrder = T.n
			table.insert(T.Rows, e)
			return e
		end
		local function row(k, r)
			if type(r.Name) ~= "string" then error(`{k} Failed: Bad Name`, 0) end
			if r.Flag ~= nil and type(r.Flag) ~= "string" then error(`{k} Failed: Bad Flag`, 0) end
			local f = bt({Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = wt, BackgroundTransparency = 0.957, ClipsDescendants = true, Parent = p}, {rc(12), sk(0.92), pd(14, 14)})
			hv(f, f:FindFirstChildOfClass("UIStroke"))
			local l = tl({Text = r.Name, FontFace = fs, Size = UDim2.new(0.5, 0, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = f})
			local e = {Row = f, Kind = k, Name = r.Name, Flag = r.Flag, Tab = T, Sec = T.sec, Label = l}
			function e:Get() return (e :: any).v end
			return add(e), f, l
		end
		local function txt(e, l, u)
			local s0 = l.Text
			function e:Set(s) s0 = tostring(s); l.Text = u and s0:upper() or s0 end
			function e:Get() return s0 end
			e:Set(s0)
			return e
		end

		function T:Section(r)
			r = r or {}
			local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = p})
			local l = tl({Text = tostring(r.Name or ""), FontFace = fj, TextSize = 11, TextColor3 = c.a2, Position = UDim2.fromOffset(4, 10), Size = UDim2.new(0, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.X, Parent = f})
			local ln = mk("Frame", {AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = c.ac, BorderSizePixel = 0, Parent = f}, {mk("UIGradient", {Transparency = ns({0, 0.6, 1, 1})})})
			local function lay() ln.Position, ln.Size = UDim2.fromOffset(l.AbsoluteSize.X / math.max(sc.Scale, 0.01) + 12, 17), UDim2.new(1, -(l.AbsoluteSize.X / math.max(sc.Scale, 0.01) + 16), 0, 1) end
			l:GetPropertyChangedSignal("AbsoluteSize"):Connect(lay)
			lay()
			T.sec = r.Name and tostring(r.Name) or ""
			return txt(add({Row = f, Kind = "Section", Name = T.sec, Tab = T}), l, true)
		end

		function T:Label(r)
			r = r or {}
			local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = wt, BackgroundTransparency = 0.957, BorderSizePixel = 0, Parent = p}, {rc(12), sk(0.92), pd(14, 14, 10, 10)})
			local l = tl({Text = tostring(r.Text or ""), TextSize = 13, TextColor3 = c.dm, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, Parent = f})
			return txt(add({Row = f, Kind = "Label", Name = l.Text, Tab = T, Sec = T.sec}), l)
		end

		function T:Button(r)
			r = r or {}
			local e, f, l = row("Button", r)
			ig({Text = "chevron-small-right", TextColor3 = c.a2, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(16, 40), Parent = f})
			f.Activated:Connect(function()
				fl2(f)
				run(r.Callback)
			end)
			return txt(e, l)
		end

		function T:Toggle(r)
			r = r or {}
			local e, f = row("Toggle", r)
			local sw = mk("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(42, 22), BackgroundColor3 = wt, BackgroundTransparency = 0.84, BorderSizePixel = 0, Parent = f}, {rc(11)})
			local kn = mk("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = hx("D6E6EE"), BorderSizePixel = 0, Parent = sw}, {rc(9)})
			e.sw, e.v, e.ld = sw, r.Default == true, function(s) return s == true end
			local function draw(a)
				local on = e.v
				local q = {sw, {BackgroundColor3 = on and c.ac or wt, BackgroundTransparency = on and 0 or 0.84}, kn, {Position = UDim2.new(0, on and 22 or 2, 0.5, 0), BackgroundColor3 = on and wt or hx("D6E6EE")}}
				for i = 1, #q, 2 do
					if a then tw(q[i], q[i + 1], i == 3 and tb2 or ti) else for k, v in q[i + 1] do q[i][k] = v end end
				end
			end
			draw(false)
			function e:Set(v)
				v = v == true
				if v == e.v then return end
				e.v = v
				draw(true)
				put(e, v)
				run(r.Callback, v)
			end
			f.Activated:Connect(function()
				e:Set(not e.v)
				rpl(sw)
				fl2(f)
			end)
			done(e)
			return e
		end

		function T:Slider(r)
			r = r or {}
			local lo, hi, st = tonumber(r.Min), tonumber(r.Max), r.Step == nil and 1 or tonumber(r.Step)
			if not (lo and hi and hi > lo) then error("Slider Failed: Bad Range", 0) end
			if not (st and st > 0) then error("Slider Failed: Bad Step", 0) end
			local e, f = row("Slider", r)
			local vl = tl({Text = "", FontFace = fj, TextSize = 12, TextColor3 = c.a2, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(40, 40), TextXAlignment = Enum.TextXAlignment.Right, Parent = f})
			local hit = bt({AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -52, 0.5, 0), Size = UDim2.fromOffset(110, 28), Parent = f})
			local tr = mk("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 5), BackgroundColor3 = wt, BackgroundTransparency = 0.84, BorderSizePixel = 0, Parent = hit}, {rc(3)})
			local fi = mk("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = c.ac, BorderSizePixel = 0, Parent = tr}, {rc(3)})
			local kn = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = wt, BorderSizePixel = 0, Parent = hit}, {rc(8), sk(0.55, c.ac, 3)})
			local function q(v) return math.clamp(lo + math.round((v - lo) / st) * st, lo, hi) end
			local d0 = r.Default
			e.v, e.ld = q(type(d0) == "number" and d0 == d0 and d0 or lo), tonumber
			local function draw()
				local a = (e.v - lo) / (hi - lo)
				fi.Size, kn.Position, vl.Text = UDim2.new(a, 0, 1, 0), UDim2.new(a, 0, 0.5, 0), ("%g"):format(e.v)
			end
			draw()
			function e:Set(v)
				if type(v) ~= "number" or v ~= v then error("Slider Set Failed: Not A Number", 0) end
				v = q(v)
				if v == e.v then return end
				e.v = v
				draw()
				put(e, v)
				run(r.Callback, v)
			end
			local function at(x) e:Set(lo + math.clamp((x - hit.AbsolutePosition.X) / hit.AbsoluteSize.X, 0, 1) * (hi - lo)) end
			hit.InputBegan:Connect(function(i)
				if i.UserInputType ~= mb and i.UserInputType ~= tc then return end
				p.ScrollingEnabled = false
				dr = {i = i, mv = function(v) at(v.X) end, up = function() p.ScrollingEnabled = true end}
				at(i.Position.X)
			end)
			done(e)
			return e
		end

		function T:Dropdown(r)
			r = r or {}
			if type(r.Options) ~= "table" then error("Dropdown Failed: Bad Options", 0) end
			local e, f = row("Dropdown", r)
			local mu = r.Multi == true
			e.Options = {}
			local function opts(l)
				local seen = {}
				e.Options = {}
				for _, s in l do
					if type(s) == "string" and not seen[s] then seen[s] = true; table.insert(e.Options, s) end
				end
			end
			opts(r.Options)
			local box = bx(f)
			local bl = tl({Text = "", FontFace = fs, TextSize = 12, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -34, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = box})
			local ch = ig({Text = "chevron-small-down", TextColor3 = c.a2, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 0), Size = UDim2.fromOffset(16, 28), Parent = box})
			local function norm(v)
				if mu then
					if type(v) ~= "table" then error("Dropdown Set Failed: Not A Table", 0) end
					local wn, out = {}, {}
					for _, s in v do wn[s] = true end
					for _, s in e.Options do
						if wn[s] then table.insert(out, s) end
					end
					return out
				end
				if v == nil then return nil end
				if table.find(e.Options, v) then return v end
				error("Dropdown Set Failed: Unknown Option", 0)
			end
			local function same(a, b)
				if not mu then return a == b end
				if #a ~= #b then return false end
				for i, s in a do
					if b[i] ~= s then return false end
				end
				return true
			end
			e.v = if mu then (if type(r.Default) == "table" then norm(r.Default) else {}) else (if table.find(e.Options, r.Default) then r.Default else nil)
			if mu then e.ld = function(s) return type(s) == "table" and s or {} end else e.sv, e.ld = function(v) return if v == nil then false else v end, function(s) return s ~= false and s or nil end end
			local function has(s) return mu and table.find(e.v, s) ~= nil or not mu and e.v == s end
			local function draw()
				local an = mu and #e.v > 0 or not mu and e.v ~= nil
				bl.Text, bl.TextColor3 = an and (mu and table.concat(e.v, ", ") or e.v) or "None", an and wt or c.dm
			end
			draw()
			function e:Get() return mu and table.clone(e.v) or e.v end
			local function emit(v)
				e.v = v
				draw()
				put(e, e:Get())
				run(r.Callback, e:Get())
			end
			function e:Set(v)
				v = norm(v)
				if same(v, e.v) then return end
				emit(v)
			end
			function e:Refresh(l)
				if type(l) ~= "table" then error("Dropdown Refresh Failed: Bad Options", 0) end
				opts(l)
				local v = mu and norm(e.v) or (table.find(e.Options, e.v) and e.v or nil)
				if not same(v, e.v) then emit(v) end
				draw()
			end
			local fy
			local function close()
				if not fy then return end
				fy:Destroy()
				fy, ov.Visible, ch.Text, W.fc = nil, false, "chevron-small-down", nil
			end
			local function open()
				if fy then close(); return end
				if W.fc then W.fc() end
				W.fc, ov.Visible, ch.Text = close, true, "chevron-small-up"
				local s, bp = sc.Scale, (box.AbsolutePosition - mn.AbsolutePosition) / sc.Scale
				local h = math.max(math.min(#e.Options, 5), 1) * 30 + 8
				local y = bp.Y + 32
				if y + h > wh - 8 then y = bp.Y - h - 4 end
				fy = mk("Frame", {Position = UDim2.fromOffset(bp.X, y), Size = UDim2.fromOffset(box.AbsoluteSize.X / s, h), BackgroundColor3 = c.cr, BackgroundTransparency = 0.05, BorderSizePixel = 0, Parent = ov}, {rc(10), sk(0.6, c.ac), pd(4, 4, 4, 4)})
				local ls = mk("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = c.a2, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, Parent = fy}, {ll(0)})
				if #e.Options == 0 then tl({Text = "No Options", TextSize = 12, TextColor3 = c.dm, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -10, 0, 30), Parent = ls}) end
				for n, s in e.Options do
					local sl = has(s)
					local b = bt({Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = c.ac, BackgroundTransparency = sl and 0.8 or 1, LayoutOrder = n, Parent = ls}, {rc(6)})
					tl({Text = s, FontFace = fs, TextSize = 12, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -36, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = b})
					local ck = ig({Text = "check", TextColor3 = c.ac, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(16, 30), Visible = sl, Parent = b})
					b.MouseEnter:Connect(function() if uis.MouseEnabled then tw(b, {BackgroundTransparency = 0.88}) end end)
					b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = has(s) and 0.8 or 1}) end)
					b.Activated:Connect(function()
						if not mu then e:Set(s); close(); return end
						local v, i = e:Get(), table.find(e.v, s)
						if i then table.remove(v, i) else table.insert(v, s) end
						e:Set(v)
						ck.Visible = has(s)
						tw(b, {BackgroundTransparency = ck.Visible and 0.8 or 1})
					end)
				end
			end
			box.Activated:Connect(open)
			done(e)
			return e
		end

		function T:TextBox(r)
			r = r or {}
			local e, f = row("TextBox", r)
			local b, st = bx(f)
			b.ClipsDescendants = true
			local x = mk("TextBox", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), FontFace = fs, TextSize = 12, TextColor3 = wt, PlaceholderText = tostring(r.Placeholder or ""), PlaceholderColor3 = c.dm, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Text = type(r.Default) == "string" and r.Default or "", Parent = b})
			e.v, e.ld = x.Text, tostring
			function e:Set(v)
				v = tostring(v)
				x.Text = v
				if v == e.v then return end
				e.v = v
				put(e, v)
				run(r.Callback, v)
			end
			x.Focused:Connect(function() tw(st, {Transparency = 0}) end)
			x.FocusLost:Connect(function()
				tw(st, {Transparency = 0.81})
				e:Set(x.Text)
			end)
			done(e)
			return e
		end

		local function kc(v)
			if v == nil then return nil end
			if typeof(v) == "EnumItem" and v.EnumType == Enum.KeyCode then return v end
			return false
		end

		function T:Keybind(r)
			r = r or {}
			local d = kc(r.Default)
			if d == false then error("Keybind Failed: Bad Key", 0) end
			local e, f = row("Keybind", r)
			local cb, st = bx(f, 0)
			cb.Size, cb.AutomaticSize = UDim2.fromOffset(0, 24), Enum.AutomaticSize.X
			pd(10, 10).Parent = cb
			local kl = tl({Text = "", FontFace = fj, TextSize = 11, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, TextXAlignment = Enum.TextXAlignment.Center, Parent = cb})
			local wk = false
			e.v, e.sv, e.ld = d, function(v) return v and v.Name or false end, function(s) return type(s) == "string" and Enum.KeyCode[s] or nil end
			local function draw()
				kl.Text, kl.TextColor3 = wk and "..." or (e.v and e.v.Name:upper() or "NONE"), (wk or e.v) and wt or c.dm
				st.Transparency = wk and 0 or 0.81
			end
			draw()
			function e:Set(v)
				local k = kc(v)
				if k == false then error("Keybind Set Failed: Bad Key", 0) end
				if k == e.v then return end
				e.v = k
				draw()
				put(e, k)
			end
			cb.Activated:Connect(function()
				wk = not wk
				W.kw = wk
				draw()
			end)
			table.insert(W.cn, uis.InputBegan:Connect(function(i, gp)
				if i.UserInputType ~= kb then return end
				if wk then
					wk, W.kw = false, false
					if i.KeyCode == Enum.KeyCode.Backspace then e:Set(nil) elseif i.KeyCode ~= Enum.KeyCode.None then e:Set(i.KeyCode) end
					draw()
					return
				end
				if gp or not e.v or i.KeyCode ~= e.v or uis:GetFocusedTextBox() then return end
				run(r.Callback)
			end))
			done(e)
			return e
		end

		return T
	end

	function W:Interface(T)
		T:Section({Name = "Interface"})
		T:Dropdown({Name = "Effects", Options = {"Full", "Light", "Off"}, Default = W.fx, Flag = "fx", Callback = function(v) W:Effects(v or "Full") end})
		T:Slider({Name = "Glass Density", Min = 40, Max = 95, Step = 1, Default = math.round(W.gd * 100), Flag = "gd", Callback = function(v)
			W.gd = v / 100
			cr.BackgroundTransparency = 1 - W.gd
		end})
		T:Toggle({Name = "Boot Animation", Default = W.ba, Flag = "ba", Callback = function(v) W.ba = v end})
	end

	function W:Destroy()
		dead = true
		for _, x in W.cn do x:Disconnect() end
		W.cn = {}
		if W.hc then W.hc:Disconnect(); W.hc = false end
		save()
		sg:Destroy()
		if ge.__BkW == W then ge.__BkW = nil end
	end

	if an2() then boot(W.ag) else whole() end
	W.up()
	ge.__BkW = W
	return W
end
return L
end)()

-- ==========================================
-- [ KHỞI TẠO UI MẪU (DEMO) ]
-- ==========================================
local W = L:Window({
    Title = "BAKHI HUB", 
    Subtitle = "Custom UI Extracted", 
    Config = "BaKhi_Test/Config"
})

local Tab1 = W:Tab({Name = "General", Icon = "egg"})
Tab1:Section({Name = "UI Components Test"})

Tab1:Toggle({
    Name = "Test Toggle", 
    Default = false, 
    Flag = "test_toggle", 
    Callback = function(v) 
        print("Toggle state:", v) 
    end
})

Tab1:Slider({
    Name = "Test Slider", 
    Min = 0, 
    Max = 100, 
    Step = 1, 
    Default = 50, 
    Flag = "test_slider", 
    Callback = function(v) 
        print("Slider value:", v) 
    end
})

Tab1:Dropdown({
    Name = "Test Dropdown", 
    Options = {"Option 1", "Option 2", "Option 3"}, 
    Default = "Option 1",
    Flag = "test_dropdown",
    Callback = function(v) 
        print("Dropdown selected:", v) 
    end
})

Tab1:Button({
    Name = "Test Button", 
    Callback = function() 
        W:Notify({Title = "Notification", Text = "Button clicked successfully!"})
    end
})

Tab1:Keybind({
    Name = "Test Keybind",
    Default = Enum.KeyCode.E,
    Flag = "test_keybind",
    Callback = function()
        print("Keybind pressed!")
    end
})

local Tab2 = W:Tab({Name = "Settings", Icon = "gear"})
W:Interface(Tab2) -- Tự động tạo cài đặt hiệu ứng UI (Full, Light, Off)