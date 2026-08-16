-- Custom Coordinates + Fly + Speed Hack (Delta Compatible)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- تنظيف الواجهات القديمة إن وجدت
if CoreGui:FindFirstChild("MultiToolUI") then
    CoreGui.MultiToolUI:Destroy()
end

-- إنشاء الواجهة البرمجية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MultiToolUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 290)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
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
Title.Text = "قائمة التحكم والتنقل"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

---------------------------------------------------------
-- 1. قسم الأحداثيات والتنقل الفوري
---------------------------------------------------------
local CoordInput = Instance.new("TextBox")
CoordInput.Size = UDim2.new(1, -20, 0, 35)
CoordInput.Position = UDim2.new(0, 10, 0, 40)
CoordInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CoordInput.PlaceholderText = "أدخل الأحداثيات: X, Y, Z"
CoordInput.Text = ""
CoordInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CoordInput.TextSize = 12
CoordInput.Font = Enum.Font.SourceSans
CoordInput.Parent = MainFrame

local CoordCorner = Instance.new("UICorner")
CoordCorner.CornerRadius = UDim.new(0, 6)
CoordCorner.Parent = CoordInput

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Size = UDim2.new(1, -20, 0, 35)
TeleportBtn.Position = UDim2.new(0, 10, 0, 80)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
TeleportBtn.Text = "تنقل فوري للأحداثيات"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 12
TeleportBtn.Font = Enum.Font.SourceSansBold
TeleportBtn.Parent = MainFrame

local TPBtnCorner = Instance.new("UICorner")
TPBtnCorner.CornerRadius = UDim.new(0, 6)
TPBtnCorner.Parent = TeleportBtn

---------------------------------------------------------
-- 2. قسم سرعة المشي (WalkSpeed)
---------------------------------------------------------
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(1, -20, 0, 35)
SpeedInput.Position = UDim2.new(0, 10, 0, 130)
SpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedInput.PlaceholderText = "سرعة المشي (الافتراضي 16)"
SpeedInput.Text = "16"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 12
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedInput

---------------------------------------------------------
-- 3. قسم الطيران عند القفز (Infinite Jump / Fly)
---------------------------------------------------------
local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(1, -20, 0, 35)
FlyBtn.Position = UDim2.new(0, 10, 0, 180)
FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
FlyBtn.Text = "الطيران بالقفز: OFF"
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.TextSize = 12
FlyBtn.Font = Enum.Font.SourceSansBold
FlyBtn.Parent = MainFrame

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 6)
FlyCorner.Parent = FlyBtn

---------------------------------------------------------
-- البرمجة والمنطق
---------------------------------------------------------

-- 1. دالة التنقل الفوري
TeleportBtn.MouseButton1Click:Connect(function()
    local text = CoordInput.Text
    local x, y, z = text:match("([%-?%d%.]+)%s*,%s*([%-?%d%.]+)%s*,%s*([%-?%d%.]+)")
    
    if x and y and z then
        local targetCFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            if hrp then
                hrp.CFrame = targetCFrame
            end
        end
    else
        CoordInput.Text = ""
        CoordInput.PlaceholderText = "صيغة خاطئة! استخدم: X, Y, Z"
    end
end)

-- 2. دالة تعديل سرعة المشي
SpeedInput.FocusLost:Connect(function()
    local speedVal = tonumber(SpeedInput.Text)
    if speedVal then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = speedVal
        end
    end
end)

-- 3. دالة الطيران المستمر عن طريق القفز في الهواء
local infiniteJumpEnabled = false

FlyBtn.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    if infiniteJumpEnabled then
        FlyBtn.Text = "الطيران بالقفز: ON"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    else
        FlyBtn.Text = "الطيران بالقفز: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- إعادة تطبيق السرعة عند الترسيبن
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 3)
    if hum and tonumber(SpeedInput.Text) then
        hum.WalkSpeed = tonumber(SpeedInput.Text)
    end
end)
