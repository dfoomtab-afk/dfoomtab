-- DELTA FLY GUI - Complete Runnable Roblox Lua Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Parent GUI safely for mobile executors (Delta) or Studio
local function getGuiParent()
	local ok, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and coreGui then
		local testOk = pcall(function()
			local f = Instance.new("Folder")
			f.Name = "_DeltaGuiTest"
			f.Parent = coreGui
			f:Destroy()
		end)
		if testOk then
			return coreGui
		end
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
local existing = guiParent:FindFirstChild("DeltaFlyGui")
if existing then
	existing:Destroy()
end

-- Translations
local TRANSLATIONS = {
	en = {
		appTitle = "DELTA FLY",
		settingsTitle = "SETTINGS",
		flight = "FLIGHT",
		speed = "SPEED",
		jump = "JUMP",
		noclip = "NOCLIP",
		respawn = "RESPAWN",
		resetPosBtn = "RESET POS",
		respawnedStatus = "POSITION RESET",
		coords = "COORDS",
		copy = "COPY",
		copied = "COPIED!",
		coordsPlaceholder = "Enter Coords: X, Y, Z",
		teleportBtn = "TELEPORT TO COORDS",
		teleportedBtn = "TELEPORTED!",
		invalidCoordsBtn = "INVALID COORDS",
		invalidCoordsStatus = "USE FORMAT: X, Y, Z",
		stopAllBtn = "STOP ALL",
		langLabel = "LANGUAGE",
		currentLangName = "English",
		themeLabel = "THEME COLOR",
		opacityLabel = "BG OPACITY",
		squashLabel = "SMOOTH SQUASH",
		showCoordsLabel = "SHOW COORDS",
		confirmCloseLabel = "CONFIRM CLOSE",
		zoomLabel = "WINDOW SCALE",
		resetLabel = "RESET DEFAULTS",
		resetBtn = "RESET",
		resetDoneBtn = "DONE!",
		confirmClosePrompt = "CLICK X AGAIN TO CLOSE",
		backToMenu = "BACK TO MENU",
		reopenMenu = "OPEN MENU",
		statusOff = "STATUS: OFF",
		statusOnPrefix = "STATUS: ON — ",
		coordsPrefix = "POS: ",
		copiedStatusPrefix = "COPIED: ",
		tpStatusPrefix = "TP TO: ",
		noCharStatus = "CHARACTER NOT FOUND"
	},
	ar = {
		appTitle = "دلتا فلاي",
		settingsTitle = "الإعدادات",
		flight = "الطيران",
		speed = "السرعة",
		jump = "القفز",
		noclip = "اختراق الجدران",
		respawn = "إعادة تموضع",
		resetPosBtn = "إعادة ضبط",
		respawnedStatus = "تمت إعادة التموضع",
		coords = "الإحداثيات",
		copy = "نسخ",
		copied = "تم النسخ!",
		coordsPlaceholder = "أدخل الإحداثيات: X, Y, Z",
		teleportBtn = "انتقال إلى الإحداثيات",
		teleportedBtn = "تم الانتقال!",
		invalidCoordsBtn = "إحداثيات غير صالحة",
		invalidCoordsStatus = "استخدم الصيغة: X, Y, Z",
		stopAllBtn = "إيقاف الكل",
		langLabel = "اللغة",
		currentLangName = "العربية",
		themeLabel = "لون الواجهة",
		opacityLabel = "شفافية الخلفية",
		squashLabel = "تأثير التضاغط",
		showCoordsLabel = "إظهار الإحداثيات",
		confirmCloseLabel = "تأكيد الإغلاق",
		zoomLabel = "تكبير النافذة",
		resetLabel = "استعادة الافتراضي",
		resetBtn = "إعادة",
		resetDoneBtn = "تم!",
		confirmClosePrompt = "اضغط X مرة أخرى للتأكيد",
		backToMenu = "العودة للقائمة",
		reopenMenu = "فتح القائمة",
		statusOff = "الحالة: متوقف",
		statusOnPrefix = "الحالة: مفعل — ",
		coordsPrefix = "الموقع: ",
		copiedStatusPrefix = "تم النسخ: ",
		tpStatusPrefix = "انتقال إلى: ",
		noCharStatus = "الشخصية غير موجودة"
	}
}

local THEME_PRESETS = {
	Color3.fromRGB(0, 130, 255),
	Color3.fromRGB(220, 38, 68),
	Color3.fromRGB(139, 92, 246),
	Color3.fromRGB(16, 185, 129),
	Color3.fromRGB(245, 158, 11)
}

local ZOOM_LEVELS = {0.85, 1.0, 1.15, 1.3}

-- State
local state = {
	lang = "en",
	themeIndex = 1,
	accent = THEME_PRESETS[1],
	bgOpacity = 1.0,
	zoomIndex = 2,
	squash = true,
	showCoords = false,
	confirmClose = false,
	armedClose = false,
	inSettings = false,
	closedPermanently = false,
	flightOn = false,
	speedOn = false,
	jumpOn = false,
	noclipOn = false,
	liftSpeed = 24,
	walkSpeed = 50,
	jumpPower = 100,
	spawnCFrame = nil,
	lastCopied = nil,
	lastTp = nil,
	lastError = false,
	lastInfo = nil
}

local function t()
	return TRANSLATIONS[state.lang]
end

local function brighten(c, amt)
	return Color3.new(
		math.clamp(c.R + amt, 0, 1),
		math.clamp(c.G + amt, 0, 1),
		math.clamp(c.B + amt, 0, 1)
	)
end

local function darken(c, factor)
	return Color3.new(
		math.clamp(c.R * factor, 0, 1),
		math.clamp(c.G * factor, 0, 1),
		math.clamp(c.B * factor, 0, 1)
	)
end

-- Character helpers
local function getCharParts()
	local char = LocalPlayer.Character
	if not char then
		return nil, nil, nil
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then
		return char, hum, hrp
	end
	return char, hum, hrp
end

local function getCoordsString()
	local _, _, hrp = getCharParts()
	if not hrp then
		return "0.0, 0.0, 0.0"
	end
	local p = hrp.Position
	return string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
end

local function captureSpawnIfNeeded()
	local _, hum, hrp = getCharParts()
	if char ~= nil and hum and hrp and hum.Health > 0 and not state.spawnCFrame then
		state.spawnCFrame = hrp.CFrame
	end
end

-- ScreenGui Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaFlyGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = guiParent

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.fromOffset(300, 232)
mainWindow.Position = UDim2.new(0.5, -150, 0.5, -116)
mainWindow.BackgroundColor3 = Color3.fromRGB(12, 17, 29)
mainWindow.BackgroundTransparency = 0
mainWindow.BorderSizePixel = 0
mainWindow.Active = true
mainWindow.Parent = screenGui

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0, 18)
winCorner.Parent = mainWindow

local winStroke = Instance.new("UIStroke")
winStroke.Color = state.accent
winStroke.Thickness = 1.6
winStroke.Parent = mainWindow

local winScale = Instance.new("UIScale")
winScale.Scale = ZOOM_LEVELS[state.zoomIndex]
winScale.Parent = mainWindow

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 34)
header.Position = UDim2.fromOffset(0, 8)
header.BackgroundTransparency = 1
header.Parent = mainWindow

local headerPad = Instance.new("UIPadding")
headerPad.PaddingLeft = UDim.new(0, 14)
headerPad.PaddingRight = UDim.new(0, 14)
headerPad.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0.65, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = t().appTitle
titleLabel.TextColor3 = brighten(state.accent, 0.22)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 17
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local actionsFrame = Instance.new("Frame")
actionsFrame.Size = UDim2.new(0.35, 0, 1, 0)
actionsFrame.Position = UDim2.fromScale(0.65, 0)
actionsFrame.BackgroundTransparency = 1
actionsFrame.Parent = header

local actionsLayout = Instance.new("UIListLayout")
actionsLayout.FillDirection = Enum.FillDirection.Horizontal
actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
actionsLayout.Padding = UDim.new(0, 5)
actionsLayout.Parent = actionsFrame

local function makeHeaderBtn(name, text, isDanger)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.fromOffset(28, 28)
	btn.BackgroundColor3 = isDanger and Color3.fromRGB(43, 22, 34) or Color3.fromRGB(20, 38, 60)
	btn.Text = text
	btn.TextColor3 = isDanger and Color3.fromRGB(255, 123, 141) or brighten(state.accent, 0.22)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.BorderSizePixel = 0
	btn.Parent = actionsFrame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	local s = Instance.new("UIStroke")
	s.Color = isDanger and Color3.fromRGB(255, 90, 110) or state.accent
	s.Thickness = 1
	s.Parent = btn

	return btn
end

local settingsBtn = makeHeaderBtn("SettingsBtn", "⚙", false)
local minimizeBtn = makeHeaderBtn("MinimizeBtn", "-", false)
local closeBtn = makeHeaderBtn("CloseBtn", "X", true)

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -28, 0, 1)
headerLine.Position = UDim2.fromOffset(14, 46)
headerLine.BackgroundColor3 = Color3.fromRGB(40, 65, 95)
headerLine.BorderSizePixel = 0
headerLine.Parent = mainWindow

-- Pages Container
local function makePage(name)
	local sf = Instance.new("ScrollingFrame")
	sf.Name = name
	sf.Size = UDim2.new(1, -24, 1, -80)
	sf.Position = UDim2.fromOffset(12, 52)
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel = 0
	sf.ScrollBarThickness = 0
	sf.CanvasSize = UDim2.fromOffset(0, 0)
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.Parent = mainWindow

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 7)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = sf

	local pad = Instance.new("UIPadding")
	pad.PaddingBottom = UDim.new(0, 4)
	pad.Parent = sf

	return sf
end

local mainPage = makePage("MainPage")
local settingsPage = makePage("SettingsPage")
settingsPage.Visible = false

-- Status Bar
local statusLine = Instance.new("Frame")
statusLine.Size = UDim2.new(1, -28, 0, 1)
statusLine.Position = UDim2.new(0, 14, 1, -25)
statusLine.BackgroundColor3 = Color3.fromRGB(40, 65, 95)
statusLine.BorderSizePixel = 0
statusLine.Parent = mainWindow

local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, -24, 0, 20)
statusText.Position = UDim2.new(0, 12, 1, -22)
statusText.BackgroundTransparency = 1
statusText.Text = t().statusOff
statusText.TextColor3 = Color3.fromRGB(150, 160, 180)
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 11
statusText.TextTruncate = Enum.TextTruncate.AtEnd
statusText.Parent = mainWindow

-- Reopen Floating Button
local reopenBtn = Instance.new("TextButton")
reopenBtn.Name = "ReopenBtn"
reopenBtn.Size = UDim2.fromOffset(112, 38)
reopenBtn.Position = UDim2.fromOffset(16, 220)
reopenBtn.BackgroundColor3 = darken(state.accent, 0.9)
reopenBtn.Text = t().reopenMenu
reopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
reopenBtn.Font = Enum.Font.GothamBold
reopenBtn.TextSize = 12
reopenBtn.Visible = false
reopenBtn.BorderSizePixel = 0
reopenBtn.ZIndex = 20
reopenBtn.Parent = screenGui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 10)
reopenCorner.Parent = reopenBtn

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = state.accent
reopenStroke.Thickness = 1.2
reopenStroke.Parent = reopenBtn

-- UI Builders
local allBoxes = {}
local allAccentButtons = {}
local allAccentStrokes = {}

local function makeBox(parent, labelText)
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 42)
	box.BackgroundColor3 = Color3.fromRGB(20, 30, 48)
	box.BorderSizePixel = 0
	box.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = box

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.46, 0, 1, 0)
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.Parent = box

	table.insert(allBoxes, box)
	return box, lbl
end

local function makeToggle(parent, initialOn)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(48, 25)
	btn.BackgroundColor3 = initialOn and state.accent or Color3.fromRGB(55, 60, 75)
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = btn

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(19, 19)
	knob.Position = initialOn and UDim2.fromOffset(26, 3) or UDim2.fromOffset(3, 3)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = btn

	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	local function setVisual(isOn)
		btn.BackgroundColor3 = isOn and state.accent or Color3.fromRGB(55, 60, 75)
		knob.Position = isOn and UDim2.fromOffset(26, 3) or UDim2.fromOffset(3, 3)
	end

	return btn, setVisual
end

local function attachAutoClear(tb, keepPlaceholderWhenEmpty)
	local prevVal = tb.Text
	tb.Focused:Connect(function()
		if tb.Text ~= "" then
			prevVal = tb.Text
			if not keepPlaceholderWhenEmpty then
				tb.PlaceholderText = prevVal
			end
			tb.Text = ""
		end
	end)
	tb.FocusLost:Connect(function()
		if tb.Text == "" then
			if not keepPlaceholderWhenEmpty then
				tb.Text = prevVal
				tb.PlaceholderText = ""
			end
		else
			prevVal = tb.Text
			if not keepPlaceholderWhenEmpty then
				tb.PlaceholderText = ""
			end
		end
	end)
	return function()
		return tb.Text ~= "" and tb.Text or prevVal
	end
end

local function makeNumInput(parent, defaultStr)
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.fromOffset(54, 26)
	tb.BackgroundColor3 = Color3.fromRGB(12, 19, 32)
	tb.Text = defaultStr
	tb.PlaceholderText = ""
	tb.PlaceholderColor3 = Color3.fromRGB(95, 118, 150)
	tb.TextColor3 = brighten(state.accent, 0.22)
	tb.Font = Enum.Font.GothamBold
	tb.TextSize = 12
	tb.ClearTextOnFocus = false
	tb.BorderSizePixel = 0
	tb.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = tb

	local s = Instance.new("UIStroke")
	s.Color = state.accent
	s.Thickness = 1
	s.Parent = tb
	table.insert(allAccentStrokes, s)

	local getter = attachAutoClear(tb, false)
	return tb, getter
end

local function makeSmallBtn(parent, text, width)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(width or 68, 26)
	btn.BackgroundColor3 = Color3.fromRGB(14, 56, 102)
	btn.Text = text
	btn.TextColor3 = brighten(state.accent, 0.22)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.TextTruncate = Enum.TextTruncate.AtEnd
	btn.BorderSizePixel = 0
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = btn

	local s = Instance.new("UIStroke")
	s.Color = state.accent
	s.Thickness = 1
	s.Parent = btn
	table.insert(allAccentStrokes, s)
	table.insert(allAccentButtons, btn)

	return btn
end

local function makePrimaryBtn(parent, text, height)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, height or 30)
	btn.BackgroundColor3 = darken(state.accent, 0.9)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.BorderSizePixel = 0
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	local s = Instance.new("UIStroke")
	s.Color = brighten(state.accent, 0.22)
	s.Thickness = 1
	s.Parent = btn
	table.insert(allAccentButtons, btn)

	return btn
end

-- Main Page Controls
-- 1. FLIGHT + Lift Speed input
local flightBox, flightLabel = makeBox(mainPage, t().flight)
local flightRight = Instance.new("Frame")
flightRight.Size = UDim2.new(0.52, -10, 1, 0)
flightRight.Position = UDim2.new(0.48, 0, 0, 0)
flightRight.BackgroundTransparency = 1
flightRight.Parent = flightBox

local flightRightLayout = Instance.new("UIListLayout")
flightRightLayout.FillDirection = Enum.FillDirection.Horizontal
flightRightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
flightRightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
flightRightLayout.Padding = UDim.new(0, 6)
flightRightLayout.Parent = flightRight

local liftInput, getLiftStr = makeNumInput(flightRight, "24")
local flightToggle, setFlightVisual = makeToggle(flightRight, false)

-- 2. SPEED + Speed input
local speedBox, speedLabel = makeBox(mainPage, t().speed)
local speedRight = Instance.new("Frame")
speedRight.Size = UDim2.new(0.52, -10, 1, 0)
speedRight.Position = UDim2.new(0.48, 0, 0, 0)
speedRight.BackgroundTransparency = 1
speedRight.Parent = speedBox

local speedRightLayout = Instance.new("UIListLayout")
speedRightLayout.FillDirection = Enum.FillDirection.Horizontal
speedRightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
speedRightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
speedRightLayout.Padding = UDim.new(0, 6)
speedRightLayout.Parent = speedRight

local speedInput, getSpeedStr = makeNumInput(speedRight, "50")
local speedToggle, setSpeedVisual = makeToggle(speedRight, false)

-- 3. JUMP + Jump input
local jumpBox, jumpLabel = makeBox(mainPage, t().jump)
local jumpRight = Instance.new("Frame")
jumpRight.Size = UDim2.new(0.52, -10, 1, 0)
jumpRight.Position = UDim2.new(0.48, 0, 0, 0)
jumpRight.BackgroundTransparency = 1
jumpRight.Parent = jumpBox

local jumpRightLayout = Instance.new("UIListLayout")
jumpRightLayout.FillDirection = Enum.FillDirection.Horizontal
jumpRightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
jumpRightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
jumpRightLayout.Padding = UDim.new(0, 6)
jumpRightLayout.Parent = jumpRight

local jumpInput, getJumpStr = makeNumInput(jumpRight, "100")
local jumpToggle, setJumpVisual = makeToggle(jumpRight, false)

-- 4. NOCLIP
local noclipBox, noclipLabel = makeBox(mainPage, t().noclip)
local noclipToggle, setNoclipVisual = makeToggle(noclipBox, false)
noclipToggle.Position = UDim2.new(1, -58, 0.5, -12.5)

-- 5. RESPAWN
local respawnBox, respawnLabel = makeBox(mainPage, t().respawn)
local respawnBtn = makeSmallBtn(respawnBox, t().resetPosBtn, 72)
respawnBtn.Position = UDim2.new(1, -82, 0.5, -13)

-- 6. COORDS COPY
local coordsBox, coordsLabel = makeBox(mainPage, t().coords)
local copyCoordsBtn = makeSmallBtn(coordsBox, t().copy, 72)
copyCoordsBtn.Position = UDim2.new(1, -82, 0.5, -13)

-- 7. TELEPORT BOX
local tpContainer = Instance.new("Frame")
tpContainer.Size = UDim2.new(1, 0, 0, 72)
tpContainer.BackgroundColor3 = Color3.fromRGB(20, 30, 48)
tpContainer.BorderSizePixel = 0
tpContainer.Parent = mainPage
table.insert(allBoxes, tpContainer)

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 10)
tpCorner.Parent = tpContainer

local coordsInput = Instance.new("TextBox")
coordsInput.Size = UDim2.new(1, -20, 0, 28)
coordsInput.Position = UDim2.fromOffset(10, 7)
coordsInput.BackgroundColor3 = Color3.fromRGB(12, 19, 32)
coordsInput.Text = ""
coordsInput.PlaceholderText = t().coordsPlaceholder
coordsInput.PlaceholderColor3 = Color3.fromRGB(83, 106, 138)
coordsInput.TextColor3 = brighten(state.accent, 0.22)
coordsInput.Font = Enum.Font.GothamBold
coordsInput.TextSize = 11
coordsInput.ClearTextOnFocus = false
coordsInput.BorderSizePixel = 0
coordsInput.Parent = tpContainer

local ciCorner = Instance.new("UICorner")
ciCorner.CornerRadius = UDim.new(0, 7)
ciCorner.Parent = coordsInput

local ciStroke = Instance.new("UIStroke")
ciStroke.Color = state.accent
ciStroke.Thickness = 1
ciStroke.Parent = coordsInput
table.insert(allAccentStrokes, ciStroke)

local getCoordsInputStr = attachAutoClear(coordsInput, true)

local teleportBtn = makePrimaryBtn(tpContainer, t().teleportBtn, 28)
teleportBtn.Size = UDim2.new(1, -20, 0, 28)
teleportBtn.Position = UDim2.fromOffset(10, 39)

-- 8. STOP ALL
local stopAllBtn = Instance.new("TextButton")
stopAllBtn.Size = UDim2.new(1, 0, 0, 28)
stopAllBtn.BackgroundColor3 = Color3.fromRGB(37, 20, 32)
stopAllBtn.Text = t().stopAllBtn
stopAllBtn.TextColor3 = Color3.fromRGB(255, 138, 155)
stopAllBtn.Font = Enum.Font.GothamBold
stopAllBtn.TextSize = 11
stopAllBtn.BorderSizePixel = 0
stopAllBtn.Parent = mainPage

local saCorner = Instance.new("UICorner")
saCorner.CornerRadius = UDim.new(0, 8)
saCorner.Parent = stopAllBtn

local saStroke = Instance.new("UIStroke")
saStroke.Color = Color3.fromRGB(255, 90, 110)
saStroke.Thickness = 1
saStroke.Parent = stopAllBtn

-- Settings Page Controls
-- 1. LANGUAGE cycle button (English / العربية)
local langBox, langLabel = makeBox(settingsPage, t().langLabel)
local langBtn = makeSmallBtn(langBox, t().currentLangName, 82)
langBtn.Position = UDim2.new(1, -92, 0.5, -13)

-- 2. THEME COLOR cycle button
local themeBox, themeLabel = makeBox(settingsPage, t().themeLabel)
local themeBtn = makeSmallBtn(themeBox, "BLUE", 72)
themeBtn.Position = UDim2.new(1, -82, 0.5, -13)

-- 3. BG OPACITY (- / % / +)
local opacityBox, opacityLabel = makeBox(settingsPage, t().opacityLabel)
local opFrame = Instance.new("Frame")
opFrame.Size = UDim2.fromOffset(96, 26)
opFrame.Position = UDim2.new(1, -106, 0.5, -13)
opFrame.BackgroundTransparency = 1
opFrame.Parent = opacityBox

local opMinusBtn = makeSmallBtn(opFrame, "-", 24)
opMinusBtn.Position = UDim2.fromOffset(0, 0)

local opBadge = makeSmallBtn(opFrame, "100%", 42)
opBadge.Position = UDim2.fromOffset(27, 0)

local opPlusBtn = makeSmallBtn(opFrame, "+", 24)
opPlusBtn.Position = UDim2.fromOffset(72, 0)

-- 4. SMOOTH SQUASH
local squashBox, squashLabel = makeBox(settingsPage, t().squashLabel)
local squashToggle, setSquashVisual = makeToggle(squashBox, true)
squashToggle.Position = UDim2.new(1, -58, 0.5, -12.5)

-- 5. SHOW COORDS
local showCoordsBox, showCoordsLabel = makeBox(settingsPage, t().showCoordsLabel)
local showCoordsToggle, setShowCoordsVisual = makeToggle(showCoordsBox, false)
showCoordsToggle.Position = UDim2.new(1, -58, 0.5, -12.5)

-- 6. CONFIRM CLOSE
local confirmCloseBox, confirmCloseLabel = makeBox(settingsPage, t().confirmCloseLabel)
local confirmCloseToggle, setConfirmCloseVisual = makeToggle(confirmCloseBox, false)
confirmCloseToggle.Position = UDim2.new(1, -58, 0.5, -12.5)

-- 7. WINDOW SCALE (- / % / +)
local zoomBox, zoomLabel = makeBox(settingsPage, t().zoomLabel)
local zoomFrame = Instance.new("Frame")
zoomFrame.Size = UDim2.fromOffset(96, 26)
zoomFrame.Position = UDim2.new(1, -106, 0.5, -13)
zoomFrame.BackgroundTransparency = 1
zoomFrame.Parent = zoomBox

local zoomMinusBtn = makeSmallBtn(zoomFrame, "-", 24)
zoomMinusBtn.Position = UDim2.fromOffset(0, 0)

local zoomBadge = makeSmallBtn(zoomFrame, "100%", 42)
zoomBadge.Position = UDim2.fromOffset(27, 0)

local zoomPlusBtn = makeSmallBtn(zoomFrame, "+", 24)
zoomPlusBtn.Position = UDim2.fromOffset(72, 0)

-- 8. RESET DEFAULTS
local resetBox, resetLabel = makeBox(settingsPage, t().resetLabel)
local resetBtn = makeSmallBtn(resetBox, t().resetBtn, 72)
resetBtn.Position = UDim2.new(1, -82, 0.5, -13)

-- Back to Menu
local backBtn = makePrimaryBtn(settingsPage, t().backToMenu, 30)

-- Squash Animation Helper
local function squashAnim(obj, baseScale)
	if not state.squash or not obj then
		return
	end
	local sObj = obj:FindFirstChildOfClass("UIScale")
	if not sObj then
		sObj = Instance.new("UIScale")
		sObj.Parent = obj
	end
	baseScale = baseScale or sObj.Scale
	sObj.Scale = baseScale
	local t1 = TweenService:Create(sObj, TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = baseScale * 0.9
	})
	local t2 = TweenService:Create(sObj, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = baseScale
	})
	t1:Play()
	t1.Completed:Connect(function()
		t2:Play()
	end)
end

-- Update Status Text
local function updateStatus()
	local dict = t()
	if state.armedClose then
		statusText.Text = dict.confirmClosePrompt
		statusText.TextColor3 = Color3.fromRGB(255, 107, 122)
		return
	end
	if state.lastError then
		statusText.Text = dict.invalidCoordsStatus
		statusText.TextColor3 = Color3.fromRGB(255, 107, 122)
		return
	end
	if state.lastCopied then
		statusText.Text = dict.copiedStatusPrefix .. state.lastCopied
		statusText.TextColor3 = brighten(state.accent, 0.22)
		return
	end
	if state.lastTp then
		statusText.Text = dict.tpStatusPrefix .. state.lastTp
		statusText.TextColor3 = brighten(state.accent, 0.22)
		return
	end
	if state.lastInfo == "respawn" then
		statusText.Text = dict.respawnedStatus
		statusText.TextColor3 = brighten(state.accent, 0.22)
		return
	end

	local active = {}
	if state.flightOn then
		table.insert(active, string.format("%s (%s)", dict.flight, tostring(state.liftSpeed)))
	end
	if state.speedOn then
		table.insert(active, string.format("%s (%s)", dict.speed, tostring(state.walkSpeed)))
	end
	if state.jumpOn then
		table.insert(active, string.format("%s (%s)", dict.jump, tostring(state.jumpPower)))
	end
	if state.noclipOn then
		table.insert(active, dict.noclip)
	end

	if #active > 0 then
		local txt = dict.statusOnPrefix .. table.concat(active, " + ")
		if state.showCoords then
			txt = txt .. " | " .. dict.coordsPrefix .. getCoordsString()
		end
		statusText.Text = txt
		statusText.TextColor3 = brighten(state.accent, 0.22)
	elseif state.showCoords then
		statusText.Text = dict.coordsPrefix .. getCoordsString()
		statusText.TextColor3 = brighten(state.accent, 0.22)
	else
		statusText.Text = dict.statusOff
		statusText.TextColor3 = Color3.fromRGB(150, 160, 180)
	end
end

-- Apply Visuals (Theme, Opacity, Scale, Language)
local THEME_NAMES = {"BLUE", "RED", "PURPLE", "GREEN", "GOLD"}

local function applyVisuals()
	local dict = t()
	local bright = brighten(state.accent, 0.22)
	local btnBg = darken(state.accent, 0.85)
	local transp = math.clamp(1 - state.bgOpacity, 0, 0.85)

	mainWindow.BackgroundTransparency = transp
	winStroke.Color = state.accent
	titleLabel.TextColor3 = bright
	titleLabel.Text = state.inSettings and dict.settingsTitle or dict.appTitle

	for _, b in ipairs(allBoxes) do
		b.BackgroundTransparency = transp
	end

	for _, s in ipairs(allAccentStrokes) do
		s.Color = state.accent
	end

	for _, btn in ipairs(allAccentButtons) do
		if btn ~= teleportBtn then
			btn.BackgroundColor3 = btnBg
			btn.TextColor3 = bright
		elseif not teleportBtn:GetAttribute("stateMode") then
			btn.BackgroundColor3 = btnBg
		end
	end

	settingsBtn.BackgroundColor3 = state.inSettings and btnBg or Color3.fromRGB(20, 38, 60)
	settingsBtn.TextColor3 = state.inSettings and Color3.fromRGB(255, 255, 255) or bright
	minimizeBtn.TextColor3 = bright

	reopenBtn.BackgroundColor3 = btnBg
	reopenBtn.Text = dict.reopenMenu
	reopenStroke.Color = state.accent

	winScale.Scale = ZOOM_LEVELS[state.zoomIndex]
	zoomBadge.Text = tostring(math.round(ZOOM_LEVELS[state.zoomIndex] * 100)) .. "%"
	opBadge.Text = tostring(math.round(state.bgOpacity * 100)) .. "%"
	themeBtn.Text = THEME_NAMES[state.themeIndex] or "BLUE"
	langBtn.Text = dict.currentLangName

	flightLabel.Text = dict.flight
	speedLabel.Text = dict.speed
	jumpLabel.Text = dict.jump
	noclipLabel.Text = dict.noclip
	respawnLabel.Text = dict.respawn
	respawnBtn.Text = dict.resetPosBtn
	coordsLabel.Text = dict.coords
	if copyCoordsBtn.Text ~= dict.copied then
		copyCoordsBtn.Text = dict.copy
	end
	coordsInput.PlaceholderText = dict.coordsPlaceholder
	if not teleportBtn:GetAttribute("stateMode") then
		teleportBtn.Text = dict.teleportBtn
	end
	stopAllBtn.Text = dict.stopAllBtn

	langLabel.Text = dict.langLabel
	themeLabel.Text = dict.themeLabel
	opacityLabel.Text = dict.opacityLabel
	squashLabel.Text = dict.squashLabel
	showCoordsLabel.Text = dict.showCoordsLabel
	confirmCloseLabel.Text = dict.confirmCloseLabel
	zoomLabel.Text = dict.zoomLabel
	resetLabel.Text = dict.resetLabel
	if resetBtn.Text ~= dict.resetDoneBtn then
		resetBtn.Text = dict.resetBtn
	end
	backBtn.Text = dict.backToMenu

	setFlightVisual(state.flightOn)
	setSpeedVisual(state.speedOn)
	setJumpVisual(state.jumpOn)
	setNoclipVisual(state.noclipOn)
	setSquashVisual(state.squash)
	setShowCoordsVisual(state.showCoords)
	setConfirmCloseVisual(state.confirmClose)

	updateStatus()
end

-- Movement / Physics Engine
local flightBV = nil
local flightBG = nil

local function stopFlightPhysics()
	if flightBV then
		flightBV:Destroy()
		flightBV = nil
	end
	if flightBG then
		flightBG:Destroy()
		flightBG = nil
	end
	local _, hum = getCharParts()
	if hum then
		hum.PlatformStand = false
	end
end

local function ensureFlightPhysics(hrp, hum)
	hum.PlatformStand = true
	if not flightBV or flightBV.Parent ~= hrp then
		if flightBV then flightBV:Destroy() end
		flightBV = Instance.new("BodyVelocity")
		flightBV.Name = "DeltaFlyVelocity"
		flightBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		flightBV.Velocity = Vector3.zero
		flightBV.Parent = hrp
	end
	if not flightBG or flightBG.Parent ~= hrp then
		if flightBG then flightBG:Destroy() end
		flightBG = Instance.new("BodyGyro")
		flightBG.Name = "DeltaFlyGyro"
		flightBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		flightBG.P = 3000
		flightBG.CFrame = hrp.CFrame
		flightBG.Parent = hrp
	end
end

local function applyPlayerStats()
	local _, hum = getCharParts()
	if not hum then
		return
	end
	if state.speedOn then
		hum.WalkSpeed = state.walkSpeed
	end
	if state.jumpOn then
		if hum.UseJumpPower then
			hum.JumpPower = state.jumpPower
		else
			hum.JumpHeight = math.clamp(state.jumpPower * 0.14, 7.2, 200)
		end
	end
end

local function applyNoclip(char)
	if not char then
		return
	end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

local function stopAllFeatures()
	state.flightOn = false
	state.speedOn = false
	state.jumpOn = false
	state.noclipOn = false
	state.lastCopied = nil
	state.lastTp = nil
	state.lastError = false
	state.lastInfo = nil
	stopFlightPhysics()
	applyVisuals()
end

-- Button Connections
settingsBtn.MouseButton1Click:Connect(function()
	squashAnim(settingsBtn)
	state.inSettings = not state.inSettings
	mainPage.Visible = not state.inSettings
	settingsPage.Visible = state.inSettings
	applyVisuals()
end)

backBtn.MouseButton1Click:Connect(function()
	squashAnim(backBtn)
	state.inSettings = false
	mainPage.Visible = true
	settingsPage.Visible = false
	applyVisuals()
end)

minimizeBtn.MouseButton1Click:Connect(function()
	if state.closedPermanently then return end
	squashAnim(minimizeBtn)
	mainWindow.Visible = false
	reopenBtn.Visible = true
	squashAnim(reopenBtn)
end)

reopenBtn.MouseButton1Click:Connect(function()
	if state.closedPermanently then return end
	reopenBtn.Visible = false
	mainWindow.Visible = true
	squashAnim(mainWindow, ZOOM_LEVELS[state.zoomIndex])
end)

closeBtn.MouseButton1Click:Connect(function()
	if state.closedPermanently then return end
	squashAnim(closeBtn)
	if state.confirmClose and not state.armedClose then
		state.armedClose = true
		updateStatus()
		task.delay(3, function()
			if state.armedClose then
				state.armedClose = false
				updateStatus()
			end
		end)
		return
	end
	state.armedClose = false
	state.closedPermanently = true
	stopAllFeatures()
	mainWindow.Visible = false
	reopenBtn.Visible = false
end)

flightToggle.MouseButton1Click:Connect(function()
	squashAnim(flightToggle)
	state.liftSpeed = tonumber(getLiftStr()) or 24
	state.flightOn = not state.flightOn
	state.lastCopied = nil
	state.lastTp = nil
	state.lastInfo = nil
	if not state.flightOn then
		stopFlightPhysics()
	end
	applyVisuals()
end)

speedToggle.MouseButton1Click:Connect(function()
	squashAnim(speedToggle)
	state.walkSpeed = tonumber(getSpeedStr()) or 50
	state.speedOn = not state.speedOn
	state.lastCopied = nil
	state.lastTp = nil
	state.lastInfo = nil
	applyPlayerStats()
	applyVisuals()
end)

jumpToggle.MouseButton1Click:Connect(function()
	squashAnim(jumpToggle)
	state.jumpPower = tonumber(getJumpStr()) or 100
	state.jumpOn = not state.jumpOn
	state.lastCopied = nil
	state.lastTp = nil
	state.lastInfo = nil
	applyPlayerStats()
	applyVisuals()
end)

noclipToggle.MouseButton1Click:Connect(function()
	squashAnim(noclipToggle)
	state.noclipOn = not state.noclipOn
	state.lastCopied = nil
	state.lastTp = nil
	state.lastInfo = nil
	applyVisuals()
end)

liftInput.FocusLost:Connect(function()
	state.liftSpeed = tonumber(getLiftStr()) or 24
	updateStatus()
end)

speedInput.FocusLost:Connect(function()
	state.walkSpeed = tonumber(getSpeedStr()) or 50
	applyPlayerStats()
	updateStatus()
end)

jumpInput.FocusLost:Connect(function()
	state.jumpPower = tonumber(getJumpStr()) or 100
	applyPlayerStats()
	updateStatus()
end)

respawnBtn.MouseButton1Click:Connect(function()
	squashAnim(respawnBtn)
	local _, _, hrp = getCharParts()
	if hrp and state.spawnCFrame then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.CFrame = state.spawnCFrame
	end
	state.lastCopied = nil
	state.lastTp = nil
	state.lastError = false
	state.lastInfo = "respawn"
	updateStatus()
	task.delay(1.4, function()
		if state.lastInfo == "respawn" then
			state.lastInfo = nil
			updateStatus()
		end
	end)
end)

copyCoordsBtn.MouseButton1Click:Connect(function()
	squashAnim(copyCoordsBtn)
	local cStr = getCoordsString()
	state.lastCopied = cStr
	state.lastTp = nil
	state.lastError = false
	state.lastInfo = nil

	pcall(function()
		if setclipboard then
			setclipboard(cStr)
		end
	end)

	copyCoordsBtn.Text = t().copied
	updateStatus()
	task.delay(1.5, function()
		state.lastCopied = nil
		copyCoordsBtn.Text = t().copy
		updateStatus()
	end)
end)

teleportBtn.MouseButton1Click:Connect(function()
	squashAnim(teleportBtn)
	local raw = tostring(getCoordsInputStr() or "")
	local nums = {}
	for numStr in string.gmatch(raw, "[-+]?%d*%.?%d+") do
		table.insert(nums, tonumber(numStr))
	end

	local _, _, hrp = getCharParts()
	if #nums >= 3 and nums[1] and nums[2] and nums[3] and hrp then
		local target = Vector3.new(nums[1], nums[2], nums[3])
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
		local fmt = string.format("%.1f, %.1f, %.1f", nums[1], nums[2], nums[3])
		state.lastTp = fmt
		state.lastCopied = nil
		state.lastError = false
		state.lastInfo = nil
		teleportBtn:SetAttribute("stateMode", "ok")
		teleportBtn.BackgroundColor3 = Color3.fromRGB(22, 163, 74)
		teleportBtn.Text = t().teleportedBtn
	else
		state.lastTp = nil
		state.lastCopied = nil
		state.lastInfo = nil
		state.lastError = true
		teleportBtn:SetAttribute("stateMode", "err")
		teleportBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
		teleportBtn.Text = t().invalidCoordsBtn
	end

	updateStatus()
	task.delay(1.6, function()
		state.lastTp = nil
		state.lastError = false
		teleportBtn:SetAttribute("stateMode", nil)
		teleportBtn.BackgroundColor3 = darken(state.accent, 0.85)
		teleportBtn.Text = t().teleportBtn
		updateStatus()
	end)
end)

stopAllBtn.MouseButton1Click:Connect(function()
	squashAnim(stopAllBtn)
	stopAllFeatures()
end)

langBtn.MouseButton1Click:Connect(function()
	squashAnim(langBtn)
	state.lang = (state.lang == "en") and "ar" or "en"
	applyVisuals()
end)

themeBtn.MouseButton1Click:Connect(function()
	squashAnim(themeBtn)
	state.themeIndex = (state.themeIndex % #THEME_PRESETS) + 1
	state.accent = THEME_PRESETS[state.themeIndex]
	applyVisuals()
end)

opMinusBtn.MouseButton1Click:Connect(function()
	squashAnim(opMinusBtn)
	state.bgOpacity = math.clamp(state.bgOpacity - 0.1, 0.25, 1.0)
	applyVisuals()
end)

opPlusBtn.MouseButton1Click:Connect(function()
	squashAnim(opPlusBtn)
	state.bgOpacity = math.clamp(state.bgOpacity + 0.1, 0.25, 1.0)
	applyVisuals()
end)

opBadge.MouseButton1Click:Connect(function()
	squashAnim(opBadge)
	state.bgOpacity = 1.0
	applyVisuals()
end)

squashToggle.MouseButton1Click:Connect(function()
	state.squash = not state.squash
	squashAnim(squashToggle)
	applyVisuals()
end)

showCoordsToggle.MouseButton1Click:Connect(function()
	squashAnim(showCoordsToggle)
	state.showCoords = not state.showCoords
	applyVisuals()
end)

confirmCloseToggle.MouseButton1Click:Connect(function()
	squashAnim(confirmCloseToggle)
	state.confirmClose = not state.confirmClose
	state.armedClose = false
	applyVisuals()
end)

zoomMinusBtn.MouseButton1Click:Connect(function()
	squashAnim(zoomMinusBtn)
	state.zoomIndex = math.clamp(state.zoomIndex - 1, 1, #ZOOM_LEVELS)
	applyVisuals()
end)

zoomPlusBtn.MouseButton1Click:Connect(function()
	squashAnim(zoomPlusBtn)
	state.zoomIndex = math.clamp(state.zoomIndex + 1, 1, #ZOOM_LEVELS)
	applyVisuals()
end)

zoomBadge.MouseButton1Click:Connect(function()
	squashAnim(zoomBadge)
	state.zoomIndex = (state.zoomIndex % #ZOOM_LEVELS) + 1
	applyVisuals()
end)

resetBtn.MouseButton1Click:Connect(function()
	squashAnim(resetBtn)
	state.themeIndex = 1
	state.accent = THEME_PRESETS[1]
	state.bgOpacity = 1.0
	state.zoomIndex = 2
	state.squash = true
	state.showCoords = false
	state.confirmClose = false
	state.armedClose = false
	resetBtn.Text = t().resetDoneBtn
	applyVisuals()
	task.delay(1.2, function()
		resetBtn.Text = t().resetBtn
	end)
end)

-- Dragging support for Main Window & Reopen Button
local function makeDraggable(dragTarget)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	dragTarget.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = dragTarget.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragTarget.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			dragTarget.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggable(mainWindow)
makeDraggable(reopenBtn)

-- RenderStepped Loop for Flight, Speed, Jump & Noclip
RunService.RenderStepped:Connect(function()
	captureSpawnIfNeeded()
	local char, hum, hrp = getCharParts()

	if state.noclipOn and char then
		applyNoclip(char)
	end

	if state.speedOn or state.jumpOn then
		applyPlayerStats()
	end

	if state.flightOn and hrp and hum then
		ensureFlightPhysics(hrp, hum)
		local moveDir = hum.MoveDirection
		local camCF = Camera and Camera.CFrame or hrp.CFrame
		local vel = Vector3.zero

		if moveDir.Magnitude > 0.05 then
			local forwardAmt = moveDir:Dot(camCF.LookVector)
			local rightAmt = moveDir:Dot(camCF.RightVector)
			local dirVec = (camCF.LookVector * forwardAmt + camCF.RightVector * rightAmt)
			if dirVec.Magnitude > 0.01 then
				dirVec = dirVec.Unit * moveDir.Magnitude
			end
			vel = dirVec * math.max(state.walkSpeed, 28)
		end

		local vertical = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			vertical = vertical + 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
			vertical = vertical - 1
		end
		if vertical ~= 0 then
			vel = Vector3.new(vel.X, vertical * state.liftSpeed, vel.Z)
		end

		flightBV.Velocity = vel
		flightBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + camCF.LookVector)
	else
		stopFlightPhysics()
	end

	if state.showCoords and not state.lastCopied and not state.lastTp and not state.lastError and not state.armedClose and not state.lastInfo then
		updateStatus()
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	state.spawnCFrame = nil
	stopFlightPhysics()
	task.wait(0.2)
	captureSpawnIfNeeded()
	applyPlayerStats()
end)

applyVisuals()
