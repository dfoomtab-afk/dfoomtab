-- Delta Speed Teleport & Fly Script
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("SpeedTeleportUI") then
    CoreGui.SpeedTeleportUI:Destroy()
end

local targetPosition = Vector3.new(3200, 3275, -846)
local currentSpeed = 250 -- السرعة الافتراضية
local isMoving = false
local currentTween = nil

-- الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedTeleportUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 170)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "التنقل السريع المخصص"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- زر التفعيل والتعطيل
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -20, 0, 35)
ActionBtn.Position = UDim2.new(0, 10, 0, 40)
ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ActionBtn.Text = "بدء التنقل السريع: OFF"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.TextSize = 12
ActionBtn.Font = Enum.Font.SourceSansBold
ActionBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ActionBtn

-- مربع إدخال السرعة
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 85)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "السرعة الحالية (حد أقصى 600):"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 11
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.Parent = MainFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(1, -20, 0, 35)
SpeedInput.Position = UDim2.new(0, 10, 0, 110)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.Text = "250"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 14
SpeedInput.Font = Enum.Font.SourceSansBold
SpeedInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = SpeedInput

-- دالة الحركة بالسرعة المحددة
local function startSpeedMovement()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not hrp then return end

    -- حساب المسافة والوقت المطلوب بناءً على السرعة
    local distance = (targetPosition - hrp.Position).Magnitude
    local duration = distance / currentSpeed

    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    currentTween:Play()

    currentTween.Completed:Connect(function()
        if isMoving then
            isMoving = false
            ActionBtn.Text = "بدء التنقل السريع: OFF"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        end
    end)
end

-- التحكم بزر التشغيل
ActionBtn.MouseButton1Click:Connect(function()
    isMoving = not isMoving
    if isMoving then
        ActionBtn.Text = "التنقل جاري... (إيقاف)"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        startSpeedMovement()
    else
        ActionBtn.Text = "بدء التنقل السريع: OFF"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        if currentTween then
            currentTween:Cancel()
        end
    end
end)

-- تحديث وتحديد السرعة (حد أقصى 600)
SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val then
        if val > 600 then val = 600 end
        if val < 10 then val = 10 end
        currentSpeed = val
        SpeedInput.Text = tostring(val)
    else
        SpeedInput.Text = tostring(currentSpeed)
    end
end)
