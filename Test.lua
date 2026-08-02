-- Touch Fling Script with UI
-- Works on standard Roblox Executors

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local FlingEnabled = false
local Connection

-- 1. إنشاء واجهة المستخدم (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TouchFlingGUI"
ScreenGui.ResetOnSpawn = false

-- التأكد من إلحاق الواجهة بالمكان المناسب
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- الإطار الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 110)
MainFrame.Position = UDim2.new(0.5, -100, 0.4, -55)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- إمكانية سحب الواجهة
MainFrame.Parent = ScreenGui

-- حواف دائرية للإطار
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Touch Fling"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- زر التفعيل والتعطيل
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 45)
ToggleButton.Position = UDim2.new(0.075, 0, 0.45, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

-- 2. وظيفة الـ Touch Fling
local function EnableFling()
    Connection = RunService.Stepped:Connect(function()
        if not FlingEnabled then return end
        
        local Character = LocalPlayer.Character
        if not Character then return end
        
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then return end

        -- تطبيق سرعات عالية جداً على أجزاء الجسم لإحداث قذف عند التصادم
        for _, part in ipairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                -- الاحتفاظ بالسرعة دون فقدان السيطرة على حركة الشخصية الأساسية
                local OldVelocity = part.AssemblyLinearVelocity
                part.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
                RunService.RenderStepped:Wait()
                part.AssemblyLinearVelocity = OldVelocity
            end
        end
    end)
end

local function DisableFling()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

-- 3. الربط بزر الواجهة
ToggleButton.MouseButton1Click:Connect(function()
    FlingEnabled = not FlingEnabled
    if FlingEnabled then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
        EnableFling()
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        DisableFling()
    end
end)
