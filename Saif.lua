-- Modern Speed Changer Script with Sleek GUI
-- Works on Mobile & PC Executors

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- تحديث الشخصية تلقائياً عند الموت أو إعادة الإرسال
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
end)

-- 1. إنشاء واجهة المستخدم (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomSpeedGUI"
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
MainFrame.Size = UDim2.new(0, 320, 0, 180)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- شريط العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "SPEED CONTROLLER"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- إدخال رقم السرعة مباشرة (TextBox)
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0, 60, 0, 25)
SpeedInput.Position = UDim2.new(1, -70, 0, 10)
SpeedInput.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
SpeedInput.Text = "16"
SpeedInput.TextColor3 = Color3.fromRGB(0, 170, 255)
SpeedInput.TextSize = 13
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = SpeedInput

-- شريط السحب (Slider Background)
local SliderFrame = Instance.new("Frame")
SliderFrame.Name = "SliderFrame"
SliderFrame.Size = UDim2.new(1, -30, 0, 8)
SliderFrame.Position = UDim2.new(0, 15, 0, 80)
SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = SliderFrame

-- شريط التقدم الملون (Slider Fill)
local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderFrame

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

-- المقبض (Knob)
local Knob = Instance.new("Frame")
Knob.Size = UDim2.new(0, 18, 0, 18)
Knob.Position = UDim2.new(0, -9, 0.5, -9)
Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Knob.BorderSizePixel = 0
Knob.Parent = SliderFill

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = Knob

-- زر إعادة الضبط (Reset)
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(1, -30, 0, 38)
ResetBtn.Position = UDim2.new(0, 15, 0, 120)
ResetBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ResetBtn.Text = "RESET TO DEFAULT (16)"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 12
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Parent = MainFrame

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 8)
ResetCorner.Parent = ResetBtn

-- 2. منطق ومعالجة حركة السلايدر والسرعة
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

-- التفاعل بالسحب بالماوس أو اللمس
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

-- إدخال السرعة يدوياً عبر الـ TextBox
SpeedInput.FocusLost:Connect(function()
    local Num = tonumber(SpeedInput.Text)
    if Num then
        SetSpeed(Num)
    else
        SpeedInput.Text = tostring(math.floor(Humanoid and Humanoid.WalkSpeed or 16))
    end
end)

-- إعادة الضبط
ResetBtn.MouseButton1Click:Connect(function()
    SetSpeed(16)
end)

-- تعيين السرعة الافتراضية عند التشغيل
SetSpeed(16)
