-- Delta Multi-Tool V5 (Fly Speed + Minimize/Close)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("MultiToolUI") then
    CoreGui.MultiToolUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MultiToolUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 440)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- شريط العنوان والتحكم (Header)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "قائمة التحكم والتنقل"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- زر إغلاق الواجهة (Close)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- زر تصغير الواجهة (Minimize)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -60, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

-- حاوية العناصر الداخليـة (Content Container)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -35)
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

---------------------------------------------------------
-- 1. قسم الأحداثيات والتنقل الفوري
---------------------------------------------------------
local CoordInput = Instance.new("TextBox")
CoordInput.Size = UDim2.new(1, -20, 0, 32)
CoordInput.Position = UDim2.new(0, 10, 0, 10)
CoordInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CoordInput.PlaceholderText = "أدخل الأحداثيات: X, Y, Z"
CoordInput.Text = ""
CoordInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CoordInput.TextSize = 12
CoordInput.Font = Enum.Font.SourceSans
CoordInput.Parent = ContentFrame

local CoordCorner = Instance.new("UICorner")
CoordCorner.CornerRadius = UDim.new(0, 5)
CoordCorner.Parent = CoordInput

local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Size = UDim2.new(1, -20, 0, 32)
TeleportBtn.Position = UDim2.new(0, 10, 0, 47)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
TeleportBtn.Text = "تنقل فوري للأحداثيات"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.TextSize = 12
TeleportBtn.Font = Enum.Font.SourceSansBold
TeleportBtn.Parent = ContentFrame

local TPBtnCorner = Instance.new("UICorner")
TPBtnCorner.CornerRadius = UDim.new(0, 5)
TPBtnCorner.Parent = TeleportBtn

---------------------------------------------------------
-- 2. زر الاندفاع السريع للأمام (Dash)
---------------------------------------------------------
local DashBtn = Instance.new("TextButton")
DashBtn.Size = UDim2.new(1, -20, 0, 32)
DashBtn.Position = UDim2.new(0, 10, 0, 89)
DashBtn.BackgroundColor3 = Color3.fromRGB(220, 130, 30)
DashBtn.Text = "⚡ اندفاع سريع للأمام"
DashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DashBtn.TextSize = 12
DashBtn.Font = Enum.Font.SourceSansBold
DashBtn.Parent = ContentFrame

local DashCorner = Instance.new("UICorner")
DashCorner.CornerRadius = UDim.new(0, 5)
DashCorner.Parent = DashBtn

---------------------------------------------------------
-- 3. زر اختراق الجدران (Noclip)
---------------------------------------------------------
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(1, -20, 0, 32)
NoclipBtn.Position = UDim2.new(0, 10, 0, 131)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
NoclipBtn.Text = "اختراق الجدران: OFF"
NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipBtn.TextSize = 12
NoclipBtn.Font = Enum.Font.SourceSansBold
NoclipBtn.Parent = ContentFrame

local NoclipCorner = Instance.new("UICorner")
NoclipCorner.CornerRadius = UDim.new(0, 5)
NoclipCorner.Parent = NoclipBtn

---------------------------------------------------------
-- 4. سرعة المشي وسرعة الطيران
---------------------------------------------------------
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.5, -15, 0, 32)
SpeedInput.Position = UDim2.new(0, 10, 0, 173)
SpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedInput.PlaceholderText = "سرعة المشي"
SpeedInput.Text = "16"
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 11
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.Parent = ContentFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 5)
SpeedCorner.Parent = SpeedInput

local FlySpeedInput = Instance.new("TextBox")
FlySpeedInput.Size = UDim2.new(0.5, -15, 0, 32)
FlySpeedInput.Position = UDim2.new(0.5, 5, 0, 173)
FlySpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
FlySpeedInput.PlaceholderText = "سرعة الطيران (أقصى 600)"
FlySpeedInput.Text = "100"
FlySpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FlySpeedInput.TextSize = 11
FlySpeedInput.Font = Enum.Font.SourceSans
FlySpeedInput.Parent = ContentFrame

local FlySpeedCorner = Instance.new("UICorner")
FlySpeedCorner.CornerRadius = UDim.new(0, 5)
FlySpeedCorner.Parent = FlySpeedInput

---------------------------------------------------------
-- 5. زر تفعيل الطيران بالقفز
---------------------------------------------------------
local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(1, -20, 0, 35)
FlyBtn.Position = UDim2.new(0, 10, 0, 215)
FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
FlyBtn.Text = "الطيران بالقفز: OFF"
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.TextSize = 12
FlyBtn.Font = Enum.Font.SourceSansBold
FlyBtn.Parent = ContentFrame

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 5)
FlyCorner.Parent = FlyBtn

---------------------------------------------------------
-- البرمجة والمنطق
---------------------------------------------------------

-- أزرار الإغلاق والتصغير
local isMinimized = false

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 250, 0, 35)
        ContentFrame.Visible = false
        MinBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 250, 0, 440)
        ContentFrame.Visible = true
        MinBtn.Text = "-"
    end
end)

-- 1. اختراق الجدران (Noclip)
local noclipEnabled = false
NoclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    NoclipBtn.Text = noclipEnabled and "اختراق الجدران: ON" or "اختراق الجدران: OFF"
    NoclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- 2. الاندفاع السريع للأمام (Dash)
DashBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if hrp then
        local velocity = Instance.new("LinearVelocity")
        local attachment = Instance.new("Attachment")
        attachment.Parent = hrp
        velocity.MaxForce = 100000
        velocity.VectorVelocity = hrp.CFrame.LookVector * 250
        velocity.Attachment0 = attachment
        velocity.Parent = hrp
        task.wait(0.15)
        velocity:Destroy()
        attachment:Destroy()
    end
end)

-- 3. التنقل الفوري بالأحداثيات
TeleportBtn.MouseButton1Click:Connect(function()
    local text = CoordInput.Text
    local x, y, z = text:match("([%-?%d%.]+)%s*,%s*([%-?%d%.]+)%s*,%s*([%-?%d%.]+)")
    if x and y and z then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            if hrp then hrp.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z)) end
        end
    else
        CoordInput.Text = ""
        CoordInput.PlaceholderText = "خطأ! استخدم: X, Y, Z"
    end
end)

-- 4. تعديل سرعة المشي وسرعة الطيران
local currentFlySpeed = 100

SpeedInput.FocusLost:Connect(function()
    local speedVal = tonumber(SpeedInput.Text)
    if speedVal then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = speedVal
        end
    end
end)

FlySpeedInput.FocusLost:Connect(function()
    local val = tonumber(FlySpeedInput.Text)
    if val then
        if val > 600 then val = 600 end
        if val < 10 then val = 10 end
        currentFlySpeed = val
        FlySpeedInput.Text = tostring(val)
    else
        FlySpeedInput.Text = tostring(currentFlySpeed)
    end
end)

-- 5. الطيران بالقفز مع التحكم بالسرعة
local flyEnabled = false
FlyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    FlyBtn.Text = flyEnabled and "الطيران بالقفز: ON" or "الطيران بالقفز: OFF"
    FlyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

UserInputService.JumpRequest:Connect(function()
    if flyEnabled then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            local hum = char:FindFirstChild("Humanoid")
            if hrp and hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                -- تطبيق القوة بالسرعة المحددة عند الطيران
                hrp.Velocity = Vector3.new(hrp.Velocity.X, currentFlySpeed, hrp.Velocity.Z)
            end
        end
    end
end)
