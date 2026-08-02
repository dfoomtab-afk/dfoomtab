-- Roblox Speed Controller GUI (Arabic Interface)
-- Design: Dark Purple Theme with Circle Toggle Button

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
end)

-- 1. إنشاء واجهة المستخدم (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedControllerArabic_GUI"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- الإطار الرئيسي (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 190)
MainFrame.Position = UDim2.new(0.5, -155, 0.4, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- حدود إطار بنفسجية نيون
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(150, 45, 245)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.1
MainStroke.Parent = MainFrame

-- شريط العنوان العلوي (Top Bar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 14)
TopBarCorner.Parent = TopBar

-- زر الإغلاق النهائي (❌)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(0, 10, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- زر التصغير / الإخفاء (➖)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(0, 42, 0, 7)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 6)
MiniCorner.Parent = MinimizeBtn

-- النص الموجود على اليمين "القفز القرد"
local RightTitle = Instance.new("TextLabel")
RightTitle.Name = "RightTitle"
RightTitle.Size = UDim2.new(0, 150, 1, 0)
RightTitle.Position = UDim2.new(1, -160, 0, 0)
RightTitle.BackgroundTransparency = 1
RightTitle.Text = "القفز القرد"
RightTitle.TextColor3 = Color3.fromRGB(245, 245, 255)
RightTitle.TextSize = 16
RightTitle.Font = Enum.Font.SourceSansBold
RightTitle.TextXAlignment = Enum.TextXAlignment.Right
RightTitle.Parent = TopBar

-- 2. عناصر التحكم بالسرعة

-- مربع كتابة السرعة المباشر
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 65, 0, 28)
SpeedInput.Position = UDim2.new(0.05, 0, 0.32, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
SpeedInput.Text = "16"
SpeedInput.TextColor3 = Color3.fromRGB(160, 60, 255)
SpeedInput.TextSize = 14
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = SpeedInput

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(150, 45, 245)
InputStroke.Thickness = 1
InputStroke.Parent = SpeedInput

-- عنوان شريط السرعة
local SliderTitle = Instance.new("TextLabel")
SliderTitle.Size = UDim2.new(0.6, 0, 0, 28)
SliderTitle.Position = UDim2.new(0.35, 0, 0.32, 0)
SliderTitle.BackgroundTransparency = 1
SliderTitle.Text = "سرعة المشي (16 - 500):"
SliderTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
SliderTitle.TextSize = 13
SliderTitle.Font = Enum.Font.SourceSansBold
SliderTitle.TextXAlignment = Enum.TextXAlignment.Right
SliderTitle.Parent = MainFrame

-- شريط السحب (Slider Background)
local SliderFrame = Instance.new("Frame")
SliderFrame.Name = "SliderFrame"
SliderFrame.Size = UDim2.new(0.9, 0, 0, 8)
SliderFrame.Position = UDim2.new(0.05, 0, 0.58, 0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = SliderFrame

-- جزء شريط السحب الملون (Slider Fill)
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(150, 45, 245)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderFrame

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

-- زر إعادة الضبط للسرعة العادية
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.9, 0, 0, 36)
ResetBtn.Position = UDim2.new(0.05, 0, 0.74, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(150, 45, 245)
ResetBtn.Text = "إعادة الضبط للسرعة الافتراضية (50)"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 13
ResetBtn.Font = Enum.Font.SourceSansBold
ResetBtn.Parent = MainFrame

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 8)
ResetCorner.Parent = ResetBtn

-- 3. الزر الدائري البنفسجي لإظهار الواجهة عند التصغير
local CircleToggleBtn = Instance.new("TextButton")
CircleToggleBtn.Name = "CircleToggleBtn"
CircleToggleBtn.Size = UDim2.new(0, 50, 0, 50)
CircleToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
CircleToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CircleToggleBtn.Text = "🏃"
CircleToggleBtn.TextSize = 22
CircleToggleBtn.Visible = false
CircleToggleBtn.Active = true
CircleToggleBtn.Draggable = true
CircleToggleBtn.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0) -- يجعله دائرياً بالكامل
CircleCorner.Parent = CircleToggleBtn

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(150, 45, 245)
CircleStroke.Thickness = 2.5
CircleStroke.Parent = CircleToggleBtn

-- 4. برمجة المنطق والفعاليات (Logic)

local MinSpeed = 16
local MaxSpeed = 500
local IsDragging = false

local function SetSpeed(Value)
    Value = math.clamp(Value, MinSpeed, MaxSpeed)
    if Humanoid then
        Humanoid.WalkSpeed = Value
    end
    
    SpeedInput.Text = tostring(math.floor(Value))
    
    local Percentage = (Value - MinSpeed) / (MaxSpeed - MinSpeed)
    TweenService:Create(SliderFill, TweenInfo.new(0.08), {Size = UDim2.new(Percentage, 0, 1, 0)}):Play()
end

local function UpdateSlider(Input)
    local SliderPos = SliderFrame.AbsolutePosition.X
    local SliderSize = SliderFrame.AbsoluteSize.X
    local MousePos = Input.Position.X
    local RelativeX = math.clamp(MousePos - SliderPos, 0, SliderSize)
    local Percentage = RelativeX / SliderSize
    local CalculatedSpeed = MinSpeed + (Percentage * (MaxSpeed - MinSpeed))
    
    SetSpeed(CalculatedSpeed)
end

SliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = true
        UpdateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = false
    end
end)

SpeedInput.FocusLost:Connect(function()
    local Num = tonumber(SpeedInput.Text)
    if Num then
        SetSpeed(Num)
    else
        SpeedInput.Text = tostring(math.floor(Humanoid and Humanoid.WalkSpeed or 16))
    end
end)

ResetBtn.MouseButton1Click:Connect(function()
    SetSpeed(16)
end)

-- أزرار التصغير والإظهار الدائرية
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    CircleToggleBtn.Visible = true
end)

CircleToggleBtn.MouseButton1Click:Connect(function()
    CircleToggleBtn.Visible = false
    MainFrame.Visible = true
end)

-- زر الإغلاق النهائي
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- تعيين السرعة الافتراضية عند البداية
SetSpeed(50)
