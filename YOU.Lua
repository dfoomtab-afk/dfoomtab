-- DELTA FLY GUI (High-Polish Roblox Lua - Delta Executor)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

-- Cleanup old GUI
pcall(function()
	if gethui then
		local old = gethui():FindFirstChild("DeltaFlyGUI")
		if old then old:Destroy() end
	end
	local oldCore = game:GetService("CoreGui"):FindFirstChild("DeltaFlyGUI")
	if oldCore then oldCore:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFlyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parented = false
pcall(function()
	if gethui then
		ScreenGui.Parent = gethui()
		parented = true
	end
end)
if not parented then
	pcall(function()
		ScreenGui.Parent = game:GetService("CoreGui")
		parented = true
	end)
end
if not parented then
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- State & Settings
local State = {
	FlightEnabled = false,
	SpeedEnabled = false,
	NoclipEnabled = false,
	SquashEnabled = true,
	LiftSpeed = 24,
	TargetSpeed = 50,
	ThemeColor = Color3.fromRGB(0, 130, 255),
	InSettings = false,
	ClosedPermanently = false,
	IsAnimating = false,
	HoldingJump = false,
	JumpPulseUntil = 0,
	OriginalWalkSpeed = nil,
}

local BV = nil
local Character, Humanoid, Root
local SavedCollideParts = {}

-- Character Helpers
local function GetCharacter()
	Character = Player.Character
	if not Character then return false end
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Root = Character:FindFirstChild("HumanoidRootPart")
	return Humanoid ~= nil and Root ~= nil and Humanoid.Health > 0
end

local function DestroyFlyMover()
	if Root then
		for _, child in ipairs(Root:GetChildren()) do
			if child.Name == "DeltaFlyBV" then
				child:Destroy()
			end
		end
	end
	BV = nil
end

local function EnsureFlyMover()
	if not GetCharacter() then return false end
	if not BV or BV.Parent ~= Root then
		DestroyFlyMover()
		BV = Instance.new("BodyVelocity")
		BV.Name = "DeltaFlyBV"
		BV.Velocity = Vector3.zero
		BV.Parent = Root
	end
	return true
end

-- Centered Squash & Stretch Helper
local function PlaySquash(obj, onComplete)
	if not obj or not obj.Parent then
		if onComplete then onComplete() end
		return
	end

	local origSize = obj:GetAttribute("OrigSize")
	if not origSize then
		origSize = obj.Size
		obj:SetAttribute("OrigSize", origSize)
	end

	if not State.SquashEnabled then
		obj.Size = origSize
		if onComplete then onComplete() end
		return
	end

	local s1 = UDim2.new(origSize.X.Scale, origSize.X.Offset * 1.13, origSize.Y.Scale, origSize.Y.Offset * 0.83)
	local s2 = UDim2.new(origSize.X.Scale, origSize.X.Offset * 0.95, origSize.Y.Scale, origSize.Y.Offset * 1.06)

	local t1 = TweenService:Create(obj, TweenInfo.new(0.085, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = s1 })
	local t2 = TweenService:Create(obj, TweenInfo.new(0.085, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = s2 })
	local t3 = TweenService:Create(obj, TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = origSize })

	t1:Play()
	t1.Completed:Connect(function()
		if obj.Parent then t2:Play() end
	end)
	t2.Completed:Connect(function()
		if obj.Parent then t3:Play() end
	end)
	t3.Completed:Connect(function()
		if onComplete then onComplete() end
	end)
end

-- Main Window (Centered AnchorPoint for CSS-like squash & drag)
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.Size = UDim2.new(0, 300, 0, 225)
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainWindow.BackgroundColor3 = Color3.fromRGB(12, 17, 29)
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.ClipsDescendants = true
MainWindow:SetAttribute("OrigSize", MainWindow.Size)
MainWindow.Parent = ScreenGui

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 24, 42)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 13, 23)),
})
MainGradient.Rotation = 135
MainGradient.Parent = MainWindow

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = State.ThemeColor
MainStroke.Thickness = 1.5
MainStroke.Parent = MainWindow

local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingTop = UDim.new(0, 10)
MainPadding.PaddingBottom = UDim.new(0, 10)
MainPadding.PaddingLeft = UDim.new(0, 14)
MainPadding.PaddingRight = UDim.new(0, 14)
MainPadding.Parent = MainWindow

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 34)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundTransparency = 1
Header.Parent = MainWindow

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -98, 1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DELTA FLY"
Title.TextColor3 = Color3.fromRGB(35, 165, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 1, -1)
Divider.BackgroundColor3 = Color3.fromRGB(40, 65, 95)
Divider.BackgroundTransparency = 0.25
Divider.BorderSizePixel = 0
Divider.Parent = Header

local function MakeHeaderBtn(text, xCenterOffset, bgColor, txtColor, borderColor)
	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.Size = UDim2.new(0, 29, 0, 29)
	btn.Position = UDim2.new(1, xCenterOffset, 0.5, -1)
	btn.BackgroundColor3 = bgColor
	btn.Text = text
	btn.TextColor3 = txtColor
	btn.TextSize = 15
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = false
	btn:SetAttribute("OrigSize", btn.Size)
	btn.Parent = Header

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local st = Instance.new("UIStroke")
	st.Color = borderColor
	st.Thickness = 1
	st.Transparency = 0.2
	st.Parent = btn
	return btn, st
end

local SettingsBtn, SettingsStroke = MakeHeaderBtn(
	"⚙", -78.5,
	Color3.fromRGB(20, 38, 60),
	Color3.fromRGB(80, 185, 255),
	State.ThemeColor
)
local MinimizeBtn, MinimizeStroke = MakeHeaderBtn(
	"-", -47.5,
	Color3.fromRGB(20, 38, 60),
	Color3.fromRGB(80, 185, 255),
	State.ThemeColor
)
local CloseBtn, _ = MakeHeaderBtn(
	"X", -16.5,
	Color3.fromRGB(43, 22, 34),
	Color3.fromRGB(255, 123, 141),
	Color3.fromRGB(255, 90, 110)
)

-- Scrollable Pages Container
local function MakeScrollPage(visible)
	local sf = Instance.new("ScrollingFrame")
	sf.Size = UDim2.new(1, 0, 1, -68)
	sf.Position = UDim2.new(0, 0, 0, 41)
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel = 0
	sf.ScrollBarThickness = 0
	sf.ScrollingDirection = Enum.ScrollingDirection.Y
	sf.CanvasSize = UDim2.new(0, 0, 0, 0)
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	sf.Visible = visible
	sf.Parent = MainWindow

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = sf

	return sf
end

local MainPage = MakeScrollPage(true)
local SettingsPage = MakeScrollPage(false)

-- Status Footer
local StatusDivider = Instance.new("Frame")
StatusDivider.Size = UDim2.new(1, 0, 0, 1)
StatusDivider.Position = UDim2.new(0, 0, 1, -24)
StatusDivider.BackgroundColor3 = Color3.fromRGB(40, 65, 95)
StatusDivider.BackgroundTransparency = 0.35
StatusDivider.BorderSizePixel = 0
StatusDivider.Parent = MainWindow

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 1, -21)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
StatusLabel.Parent = MainWindow

-- UI Component Builders
local function MakeRowBox(parent, labelText, order)
	local box = Instance.new("Frame")
	box.LayoutOrder = order
	box.Size = UDim2.new(1, 0, 0, 46)
	box.BackgroundColor3 = Color3.fromRGB(20, 30, 48)
	box.BorderSizePixel = 0
	box.Parent = parent

	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 11)
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(55, 82, 120)
	boxStroke.Transparency = 0.72
	boxStroke.Thickness = 1
	boxStroke.Parent = box

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.55, 0, 1, 0)
	lbl.Position = UDim2.new(0, 11, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextSize = 14
	lbl.Font = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = box

	return box
end

local function MakeToggle(parent, initialOn, xPos)
	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.Size = UDim2.new(0, 50, 0, 26)
	btn.Position = UDim2.new(1, xPos + 25, 0.5, 0)
	btn.BackgroundColor3 = initialOn and State.ThemeColor or Color3.fromRGB(55, 60, 75)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn:SetAttribute("OrigSize", btn.Size)
	btn.Parent = parent

	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 20, 0, 20)
	circle.Position = initialOn and UDim2.new(0, 27, 0, 3) or UDim2.new(0, 3, 0, 3)
	circle.BackgroundColor3 = Color3.new(1, 1, 1)
	circle.BorderSizePixel = 0
	circle.Parent = btn

	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	local function SetVisual(isOn, animate)
		local targetBg = isOn and State.ThemeColor or Color3.fromRGB(55, 60, 75)
		local targetPos = isOn and UDim2.new(0, 27, 0, 3) or UDim2.new(0, 3, 0, 3)
		if animate and State.SquashEnabled then
			TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Sine), { BackgroundColor3 = targetBg }):Play()
			TweenService:Create(circle, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Position = targetPos }):Play()
		else
			btn.BackgroundColor3 = targetBg
			circle.Position = targetPos
		end
	end

	return btn, SetVisual
end

local function MakeNumberBox(parent, defaultText, placeholderText, xPos, width)
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(0, width or 58, 0, 27)
	tb.Position = UDim2.new(1, xPos, 0.5, -13.5)
	tb.BackgroundColor3 = Color3.fromRGB(12, 19, 32)
	tb.Text = defaultText
	tb.PlaceholderText = placeholderText or ""
	tb.PlaceholderColor3 = Color3.fromRGB(83, 106, 138)
	tb.TextColor3 = Color3.fromRGB(107, 196, 255)
	tb.TextSize = 13
	tb.Font = Enum.Font.GothamBold
	tb.ClearTextOnFocus = false
	tb.Parent = parent

	Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
	local st = Instance.new("UIStroke")
	st.Color = State.ThemeColor
	st.Thickness = 1
	st.Transparency = 0.45
	st.Parent = tb

	return tb, st
end

local function StyleActionButton(btn, topColor, bottomColor)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, topColor),
		ColorSequenceKeypoint.new(1, bottomColor),
	})
	grad.Rotation = 90
	grad.Parent = btn
	return grad
end

-- Build Main Page Rows
local FlightBox = MakeRowBox(MainPage, "FLIGHT", 1)
local FlightToggle, SetFlightVisual = MakeToggle(FlightBox, false, -61)

local SpeedBox = MakeRowBox(MainPage, "SPEED", 2)
local SpeedInput, SpeedInputStroke = MakeNumberBox(SpeedBox, "50", "50", -126, 58)
local SpeedToggle, SetSpeedVisual = MakeToggle(SpeedBox, false, -61)

local NoclipBox = MakeRowBox(MainPage, "NOCLIP", 3)
local NoclipToggle, SetNoclipVisual = MakeToggle(NoclipBox, false, -61)

local CoordsBox = MakeRowBox(MainPage, "COORDS", 4)
local CopyCoordsBtn = Instance.new("TextButton")
CopyCoordsBtn.AnchorPoint = Vector2.new(0.5, 0.5)
CopyCoordsBtn.Size = UDim2.new(0, 72, 0, 28)
CopyCoordsBtn.Position = UDim2.new(1, -47, 0.5, 0)
CopyCoordsBtn.BackgroundColor3 = Color3.fromRGB(14, 56, 102)
CopyCoordsBtn.Text = "COPY"
CopyCoordsBtn.TextColor3 = Color3.fromRGB(124, 202, 255)
CopyCoordsBtn.TextSize = 11.5
CopyCoordsBtn.Font = Enum.Font.GothamBold
CopyCoordsBtn.AutoButtonColor = false
CopyCoordsBtn:SetAttribute("OrigSize", CopyCoordsBtn.Size)
CopyCoordsBtn.Parent = CoordsBox
Instance.new("UICorner", CopyCoordsBtn).CornerRadius = UDim.new(0, 8)
local CopyStroke = Instance.new("UIStroke")
CopyStroke.Color = State.ThemeColor
CopyStroke.Thickness = 1
CopyStroke.Transparency = 0.25
CopyStroke.Parent = CopyCoordsBtn

-- Wide Coords Input + Teleport Button
local TeleportBox = Instance.new("Frame")
TeleportBox.LayoutOrder = 5
TeleportBox.Size = UDim2.new(1, 0, 0, 79)
TeleportBox.BackgroundColor3 = Color3.fromRGB(20, 30, 48)
TeleportBox.BorderSizePixel = 0
TeleportBox.Parent = MainPage
Instance.new("UICorner", TeleportBox).CornerRadius = UDim.new(0, 11)
local tpBoxStroke = Instance.new("UIStroke")
tpBoxStroke.Color = Color3.fromRGB(55, 82, 120)
tpBoxStroke.Transparency = 0.72
tpBoxStroke.Thickness = 1
tpBoxStroke.Parent = TeleportBox

local CoordsInput = Instance.new("TextBox")
CoordsInput.Size = UDim2.new(1, -22, 0, 32)
CoordsInput.Position = UDim2.new(0, 11, 0, 8)
CoordsInput.BackgroundColor3 = Color3.fromRGB(12, 19, 32)
CoordsInput.Text = ""
CoordsInput.PlaceholderText = "Enter Coords: X, Y, Z"
CoordsInput.PlaceholderColor3 = Color3.fromRGB(83, 106, 138)
CoordsInput.TextColor3 = Color3.fromRGB(124, 202, 255)
CoordsInput.TextSize = 12
CoordsInput.Font = Enum.Font.GothamBold
CoordsInput.ClearTextOnFocus = false
CoordsInput.Parent = TeleportBox
Instance.new("UICorner", CoordsInput).CornerRadius = UDim.new(0, 8)
local CoordsInputStroke = Instance.new("UIStroke")
CoordsInputStroke.Color = State.ThemeColor
CoordsInputStroke.Thickness = 1
CoordsInputStroke.Transparency = 0.45
CoordsInputStroke.Parent = CoordsInput

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.AnchorPoint = Vector2.new(0.5, 0.5)
TeleportBtn.Size = UDim2.new(1, -22, 0, 32)
TeleportBtn.Position = UDim2.new(0.5, 0, 0, 59)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 119, 230)
TeleportBtn.Text = "TELEPORT TO COORDS"
TeleportBtn.TextColor3 = Color3.new(1, 1, 1)
TeleportBtn.TextSize = 12
TeleportBtn.Font = Enum.Font.GothamBold
TeleportBtn.AutoButtonColor = false
TeleportBtn:SetAttribute("OrigSize", TeleportBtn.Size)
TeleportBtn.Parent = TeleportBox
Instance.new("UICorner", TeleportBtn).CornerRadius = UDim.new(0, 8)
StyleActionButton(
	TeleportBtn,
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(185, 195, 210)
)

-- Build Settings Page Rows
local ThemeBox = MakeRowBox(SettingsPage, "THEME COLOR", 1)
local ColorInput, ColorInputStroke = MakeNumberBox(ThemeBox, "#0082FF", "#0082FF", -86, 75)

local PresetsRow = Instance.new("Frame")
PresetsRow.LayoutOrder = 2
PresetsRow.Size = UDim2.new(1, 0, 0, 28)
PresetsRow.BackgroundTransparency = 1
PresetsRow.Parent = SettingsPage

local PresetLayout = Instance.new("UIListLayout")
PresetLayout.FillDirection = Enum.FillDirection.Horizontal
PresetLayout.Padding = UDim.new(0, 6)
PresetLayout.Parent = PresetsRow

local PresetColors = {
	Color3.fromRGB(0, 130, 255),
	Color3.fromRGB(255, 59, 92),
	Color3.fromRGB(34, 197, 94),
	Color3.fromRGB(168, 85, 247),
	Color3.fromRGB(245, 158, 11),
}

local LiftBox = MakeRowBox(SettingsPage, "LIFT SPEED", 3)
local LiftInput, LiftInputStroke = MakeNumberBox(LiftBox, "24", "24", -69, 58)

local SquashBox = MakeRowBox(SettingsPage, "SMOOTH SQUASH", 4)
local SquashToggle, SetSquashVisual = MakeToggle(SquashBox, true, -61)

local BackToMainBtn = Instance.new("TextButton")
BackToMainBtn.LayoutOrder = 5
BackToMainBtn.Size = UDim2.new(1, 0, 0, 34)
BackToMainBtn.BackgroundColor3 = Color3.fromRGB(0, 119, 230)
BackToMainBtn.Text = "BACK TO MENU"
BackToMainBtn.TextColor3 = Color3.new(1, 1, 1)
BackToMainBtn.TextSize = 12
BackToMainBtn.Font = Enum.Font.GothamBold
BackToMainBtn.AutoButtonColor = false
BackToMainBtn:SetAttribute("OrigSize", BackToMainBtn.Size)
BackToMainBtn.Parent = SettingsPage
Instance.new("UICorner", BackToMainBtn).CornerRadius = UDim.new(0, 8)
StyleActionButton(
	BackToMainBtn,
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(185, 195, 210)
)

-- Draggable Reopen Button (OPEN MENU)
local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Name = "OpenMenuButton"
ReopenBtn.AnchorPoint = Vector2.new(0.5, 0.5)
ReopenBtn.Size = UDim2.new(0, 120, 0, 42)
ReopenBtn.Position = UDim2.new(0, 75, 0.5, 0)
ReopenBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 210)
ReopenBtn.Text = "OPEN MENU"
ReopenBtn.TextColor3 = Color3.new(1, 1, 1)
ReopenBtn.TextSize = 14
ReopenBtn.Font = Enum.Font.GothamBold
ReopenBtn.AutoButtonColor = false
ReopenBtn.Visible = false
ReopenBtn.Active = true
ReopenBtn:SetAttribute("OrigSize", ReopenBtn.Size)
ReopenBtn.Parent = ScreenGui
Instance.new("UICorner", ReopenBtn).CornerRadius = UDim.new(0, 10)
local ReopenStroke = Instance.new("UIStroke")
ReopenStroke.Color = State.ThemeColor
ReopenStroke.Thickness = 1.2
ReopenStroke.Parent = ReopenBtn
StyleActionButton(
	ReopenBtn,
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(190, 200, 215)
)

-- Theme Color Application
local function BrightenColor(c, addVal)
	return Color3.new(
		math.clamp(c.R + addVal, 0, 1),
		math.clamp(c.G + addVal, 0, 1),
		math.clamp(c.B + addVal, 0, 1)
	)
end

local function DarkenColor(c, mult)
	return Color3.new(
		math.clamp(c.R * mult, 0, 1),
		math.clamp(c.G * mult, 0, 1),
		math.clamp(c.B * mult, 0, 1)
	)
end

local function ApplyThemeColor(col)
	State.ThemeColor = col
	local bright = BrightenColor(col, 0.16)
	local darkBtn = DarkenColor(col, 0.72)

	MainStroke.Color = col
	Title.TextColor3 = bright
	SettingsStroke.Color = State.InSettings and bright or col
	MinimizeStroke.Color = col
	CopyStroke.Color = col
	CopyCoordsBtn.TextColor3 = bright
	TeleportBtn.BackgroundColor3 = col
	BackToMainBtn.BackgroundColor3 = col
	ReopenBtn.BackgroundColor3 = darkBtn
	ReopenStroke.Color = bright

	SpeedInput.TextColor3 = bright
	SpeedInputStroke.Color = col
	CoordsInput.TextColor3 = bright
	CoordsInputStroke.Color = col
	LiftInput.TextColor3 = bright
	LiftInputStroke.Color = col
	ColorInput.TextColor3 = bright
	ColorInputStroke.Color = col

	SetFlightVisual(State.FlightEnabled, false)
	SetSpeedVisual(State.SpeedEnabled, false)
	SetNoclipVisual(State.NoclipEnabled, false)
	SetSquashVisual(State.SquashEnabled, false)

	if StatusLabel.Text:find("^STATUS: ON") or StatusLabel.Text:find("^COPIED:") or StatusLabel.Text:find("^TP TO:") then
		StatusLabel.TextColor3 = bright
	end
end

for _, pCol in ipairs(PresetColors) do
	local sw = Instance.new("TextButton")
	sw.AnchorPoint = Vector2.new(0.5, 0.5)
	sw.Size = UDim2.new(0, 28, 0, 28)
	sw.Position = UDim2.new(0, 14, 0, 14)
	sw.BackgroundColor3 = pCol
	sw.Text = ""
	sw.AutoButtonColor = false
	sw:SetAttribute("OrigSize", sw.Size)
	sw.Parent = PresetsRow
	Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 7)
	local swSt = Instance.new("UIStroke")
	swSt.Color = Color3.new(1, 1, 1)
	swSt.Transparency = 0.75
	swSt.Thickness = 1
	swSt.Parent = sw

	sw.MouseButton1Click:Connect(function()
		PlaySquash(sw)
		local r = math.round(pCol.R * 255)
		local g = math.round(pCol.G * 255)
		local b = math.round(pCol.B * 255)
		ColorInput.Text = string.format("#%02X%02X%02X", r, g, b)
		ApplyThemeColor(pCol)
	end)
end

local function ParseHexColor(txt)
	local clean = txt:gsub("^%s*#", ""):gsub("%s*$", "")
	if #clean == 6 and clean:match("^[0-9A-Fa-f]+$") then
		local r = tonumber(clean:sub(1, 2), 16)
		local g = tonumber(clean:sub(3, 4), 16)
		local b = tonumber(clean:sub(5, 6), 16)
		return Color3.fromRGB(r, g, b)
	end
	return nil
end

ColorInput.FocusLost:Connect(function()
	local parsed = ParseHexColor(ColorInput.Text)
	if parsed then
		ColorInput.Text = "#" .. ColorInput.Text:gsub("^%s*#", ""):upper()
		ApplyThemeColor(parsed)
	else
		local r = math.round(State.ThemeColor.R * 255)
		local g = math.round(State.ThemeColor.G * 255)
		local b = math.round(State.ThemeColor.B * 255)
		ColorInput.Text = string.format("#%02X%02X%02X", r, g, b)
	end
end)

-- Status Updater
local function UpdateStatus(overrideText, isError)
	if overrideText then
		StatusLabel.Text = overrideText
		StatusLabel.TextColor3 = isError and Color3.fromRGB(255, 107, 122) or BrightenColor(State.ThemeColor, 0.16)
		return
	end

	local active = {}
	if State.FlightEnabled then table.insert(active, "FLIGHT") end
	if State.SpeedEnabled then table.insert(active, "SPEED (" .. tostring(State.TargetSpeed) .. ")") end
	if State.NoclipEnabled then table.insert(active, "NOCLIP") end

	if #active > 0 then
		StatusLabel.Text = "STATUS: ON — " .. table.concat(active, " + ")
		StatusLabel.TextColor3 = BrightenColor(State.ThemeColor, 0.16)
	else
		StatusLabel.Text = "STATUS: OFF"
		StatusLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
	end
end

-- Feature Controllers
local function ApplySpeedState()
	if not GetCharacter() then return end
	if State.SpeedEnabled then
		if State.OriginalWalkSpeed == nil then
			State.OriginalWalkSpeed = Humanoid.WalkSpeed
		end
		Humanoid.WalkSpeed = State.TargetSpeed
	else
		if State.OriginalWalkSpeed ~= nil then
			Humanoid.WalkSpeed = State.OriginalWalkSpeed
			State.OriginalWalkSpeed = nil
		end
	end
end

local function RestoreNoclipParts()
	for part, oldCollide in pairs(SavedCollideParts) do
		if part and part.Parent then
			pcall(function()
				part.CanCollide = oldCollide
			end)
		end
	end
	table.clear(SavedCollideParts)
end

local function ApplyNoclipStep()
	if not GetCharacter() then
		RestoreNoclipParts()
		return
	end
	for _, obj in ipairs(Character:GetDescendants()) do
		if obj:IsA("BasePart") then
			if SavedCollideParts[obj] == nil then
				SavedCollideParts[obj] = obj.CanCollide
			end
			if obj.CanCollide then
				obj.CanCollide = false
			end
		end
	end
end

local function DisableAllFeatures()
	State.FlightEnabled = false
	State.SpeedEnabled = false
	State.NoclipEnabled = false
	State.HoldingJump = false
	State.JumpPulseUntil = 0

	DestroyFlyMover()
	RestoreNoclipParts()

	if GetCharacter() and State.OriginalWalkSpeed ~= nil then
		Humanoid.WalkSpeed = State.OriginalWalkSpeed
		State.OriginalWalkSpeed = nil
	end

	SetFlightVisual(false, true)
	SetSpeedVisual(false, true)
	SetNoclipVisual(false, true)
	UpdateStatus()
end

-- Jump Detection for Flight (No Camera Direction, Normal WalkSpeed Untouched)
UIS.JumpRequest:Connect(function()
	if State.FlightEnabled then
		State.JumpPulseUntil = os.clock() + 0.18
	end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if not State.FlightEnabled then return end
	if input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
		State.HoldingJump = true
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		State.HoldingJump = false
	end
end)

-- Main Runtime Loop
RunService.RenderStepped:Connect(function()
	if not GetCharacter() then
		DestroyFlyMover()
		return
	end

	if State.SpeedEnabled then
		if State.OriginalWalkSpeed == nil then
			State.OriginalWalkSpeed = Humanoid.WalkSpeed
		end
		if Humanoid.WalkSpeed ~= State.TargetSpeed then
			Humanoid.WalkSpeed = State.TargetSpeed
		end
	end

	if State.NoclipEnabled then
		ApplyNoclipStep()
	end

	-- Jump flight with natural WalkSpeed (no speed reduction)
	if State.FlightEnabled then
		local jumpingNow = State.HoldingJump or (os.clock() < State.JumpPulseUntil) or Humanoid.Jump
		if jumpingNow then
			if EnsureFlyMover() then
				local horizVel = Humanoid.MoveDirection * Humanoid.WalkSpeed
				BV.MaxForce = Vector3.new(1e5, 1e6, 1e5)
				BV.Velocity = Vector3.new(horizVel.X, State.LiftSpeed, horizVel.Z)
			end
		else
			DestroyFlyMover()
		end
	else
		DestroyFlyMover()
	end
end)

-- Button Connections
FlightToggle.MouseButton1Click:Connect(function()
	if State.ClosedPermanently then return end
	State.FlightEnabled = not State.FlightEnabled
	if not State.FlightEnabled then
		State.HoldingJump = false
		State.JumpPulseUntil = 0
		DestroyFlyMover()
	end
	PlaySquash(FlightToggle)
	SetFlightVisual(State.FlightEnabled, true)
	UpdateStatus()
end)

SpeedToggle.MouseButton1Click:Connect(function()
	if State.ClosedPermanently then return end
	local val = tonumber(SpeedInput.Text)
	if val and val > 0 then
		State.TargetSpeed = val
	end
	State.SpeedEnabled = not State.SpeedEnabled
	PlaySquash(SpeedToggle)
	SetSpeedVisual(State.SpeedEnabled, true)
	ApplySpeedState()
	UpdateStatus()
end)

SpeedInput.FocusLost:Connect(function()
	local val = tonumber(SpeedInput.Text)
	if val and val > 0 then
		State.TargetSpeed = val
		SpeedInput.Text = tostring(val)
		if State.SpeedEnabled then
			ApplySpeedState()
			UpdateStatus()
		end
	else
		SpeedInput.Text = tostring(State.TargetSpeed)
	end
end)

LiftInput.FocusLost:Connect(function()
	local val = tonumber(LiftInput.Text)
	if val and val > 0 then
		State.LiftSpeed = val
		LiftInput.Text = tostring(val)
	else
		LiftInput.Text = tostring(State.LiftSpeed)
	end
end)

SquashToggle.MouseButton1Click:Connect(function()
	State.SquashEnabled = not State.SquashEnabled
	SetSquashVisual(State.SquashEnabled, true)
	if State.SquashEnabled then
		PlaySquash(SquashToggle)
	end
end)

NoclipToggle.MouseButton1Click:Connect(function()
	if State.ClosedPermanently then return end
	State.NoclipEnabled = not State.NoclipEnabled
	if not State.NoclipEnabled then
		RestoreNoclipParts()
	end
	PlaySquash(NoclipToggle)
	SetNoclipVisual(State.NoclipEnabled, true)
	UpdateStatus()
end)

CopyCoordsBtn.MouseButton1Click:Connect(function()
	if State.ClosedPermanently then return end
	PlaySquash(CopyCoordsBtn)
	if not GetCharacter() then
		UpdateStatus("NO CHARACTER FOUND", true)
		return
	end

	local p = Root.Position
	local formatted = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
	pcall(function()
		if setclipboard then
			setclipboard(formatted)
		elseif toclipboard then
			toclipboard(formatted)
		end
	end)

	CopyCoordsBtn.Text = "COPIED!"
	CopyCoordsBtn.BackgroundColor3 = Color3.fromRGB(18, 59, 38)
	CopyCoordsBtn.TextColor3 = Color3.fromRGB(110, 231, 183)
	CopyStroke.Color = Color3.fromRGB(34, 197, 94)
	UpdateStatus("COPIED: " .. formatted, false)

	task.delay(1.5, function()
		if CopyCoordsBtn and CopyCoordsBtn.Parent then
			CopyCoordsBtn.Text = "COPY"
			CopyCoordsBtn.BackgroundColor3 = Color3.fromRGB(14, 56, 102)
			CopyCoordsBtn.TextColor3 = BrightenColor(State.ThemeColor, 0.16)
			CopyStroke.Color = State.ThemeColor
			UpdateStatus()
		end
	end)
end)

TeleportBtn.MouseButton1Click:Connect(function()
	if State.ClosedPermanently then return end
	PlaySquash(TeleportBtn)
	if not GetCharacter() then
		UpdateStatus("NO CHARACTER FOUND", true)
		return
	end

	local nums = {}
	for numStr in CoordsInput.Text:gmatch("[-+]?%d*%.?%d+") do
		local n = tonumber(numStr)
		if n then
			table.insert(nums, n)
		end
	end

	if #nums >= 3 then
		local targetPos = Vector3.new(nums[1], nums[2], nums[3])
		Root.CFrame = CFrame.new(targetPos)

		TeleportBtn.Text = "TELEPORTED!"
		TeleportBtn.BackgroundColor3 = Color3.fromRGB(22, 163, 74)
		UpdateStatus(string.format("TP TO: %.1f, %.1f, %.1f", nums[1], nums[2], nums[3]), false)
	else
		TeleportBtn.Text = "INVALID COORDS"
		TeleportBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
		UpdateStatus("USE FORMAT: X, Y, Z", true)
	end

	task.delay(1.6, function()
		if TeleportBtn and TeleportBtn.Parent then
			TeleportBtn.Text = "TELEPORT TO COORDS"
			TeleportBtn.BackgroundColor3 = State.ThemeColor
			UpdateStatus()
		end
	end)
end)

-- Settings Page Toggle
local function SetSettingsOpen(open)
	State.InSettings = open
	MainPage.Visible = not open
	SettingsPage.Visible = open
	Title.Text = open and "SETTINGS" or "DELTA FLY"
	SettingsBtn.BackgroundColor3 = open and State.ThemeColor or Color3.fromRGB(20, 38, 60)
	SettingsBtn.TextColor3 = open and Color3.new(1, 1, 1) or BrightenColor(State.ThemeColor, 0.16)
	PlaySquash(MainWindow)
end

SettingsBtn.MouseButton1Click:Connect(function()
	if State.ClosedPermanently then return end
	PlaySquash(SettingsBtn)
	SetSettingsOpen(not State.InSettings)
end)

BackToMainBtn.MouseButton1Click:Connect(function()
	PlaySquash(BackToMainBtn)
	SetSettingsOpen(false)
end)

-- Minimize (-) and Permanent Close (X)
local function CloseWindow(permanent)
	if State.IsAnimating or State.ClosedPermanently then return end
	State.IsAnimating = true

	if permanent then
		State.ClosedPermanently = true
		DisableAllFeatures()
	end

	local function Finish()
		MainWindow.Visible = false
		State.IsAnimating = false
		if not permanent then
			ReopenBtn.Visible = true
			PlaySquash(ReopenBtn)
		end
	end

	if State.SquashEnabled then
		local origSize = MainWindow:GetAttribute("OrigSize") or MainWindow.Size
		local shrink = UDim2.new(0, origSize.X.Offset * 0.65, 0, origSize.Y.Offset * 0.65)
		local tw = TweenService:Create(MainWindow, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = shrink })
		tw:Play()
		tw.Completed:Connect(function()
			MainWindow.Size = origSize
			Finish()
		end)
	else
		Finish()
	end
end

MinimizeBtn.MouseButton1Click:Connect(function()
	PlaySquash(MinimizeBtn)
	CloseWindow(false)
end)

CloseBtn.MouseButton1Click:Connect(function()
	PlaySquash(CloseBtn)
	CloseWindow(true)
end)

-- Draggable OPEN MENU Button
local dragging = false
local dragMoved = false
local dragStartPos, btnStartPos

ReopenBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragMoved = false
		dragStartPos = input.Position
		btnStartPos = ReopenBtn.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStartPos
		if delta.Magnitude > 5 then
			dragMoved = true
		end
		local newX = math.clamp(btnStartPos.X.Offset + delta.X, ReopenBtn.AbsoluteSize.X * 0.5, CameraSafeWidth() - ReopenBtn.AbsoluteSize.X * 0.5)
		local newY = math.clamp(btnStartPos.Y.Offset + delta.Y, ReopenBtn.AbsoluteSize.Y * 0.5, CameraSafeHeight() - ReopenBtn.AbsoluteSize.Y * 0.5)
		ReopenBtn.Position = UDim2.new(0, newX, 0, newY)
	end
end)

UIS.InputEnded:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
		if not dragMoved then
			ReopenBtn.Visible = false
			MainWindow.Visible = true
			PlaySquash(MainWindow)
		end
	end
end)

function CameraSafeWidth()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize.X or 1280
end

function CameraSafeHeight()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize.Y or 720
end

-- Character Respawn Cleanup
Player.CharacterAdded:Connect(function()
	DestroyFlyMover()
	RestoreNoclipParts()
	State.OriginalWalkSpeed = nil
	State.HoldingJump = false
	State.JumpPulseUntil = 0
	task.wait(0.25)
	if State.SpeedEnabled then
		ApplySpeedState()
	end
end)

-- Initial Entrance Squash
PlaySquash(MainWindow)
print("DELTA FLY GUI LOADED")
