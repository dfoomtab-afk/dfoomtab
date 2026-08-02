-- Monkey Escape Auto Win Script with Dropdown & Circle Toggle
-- Theme: Dark Neon Purple with Arabic UI

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- 1. جدول الإحداثيات لكل مرحلة بالتفصيل
local StageWaypoints = {
    [0] = { CFrame.new(439, 27, 222) }, -- البداية
    [1] = { CFrame.new(-683, 24, -222), CFrame.new(-683, 24, 255) },
    [2] = { CFrame.new(-934, 24, -222), CFrame.new(-934, 24, 255) },
    [3] = { CFrame.new(-1213, 24, -222), CFrame.new(-1213, 24, 255) },
    [4] = { CFrame.new(-1213, 24, -222), CFrame.new(1213, 66, 222), CFrame.new(-1567, 66, -222), CFrame.new(-1567, 24, 255) },
    [5] = { CFrame.new(-1567, 150, -222), CFrame.new(-2183, 150, -222), CFrame.new(-2183, 119, 255) },
    [6] = { CFrame.new(-2183, 220, -222), CFrame.new(-3046, 220, -222), CFrame.new(-3046, 119, 255) }
}

local SelectedStage = 1 -- المرحلة المحددة افتراضياً

-- 2. إنشاء واجهة المستخدم (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonkeyAutoWin_GUI"
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
MainFrame.Size = UDim2.new(0, 310, 0, 200)
MainFrame.Position = UDim2.new(0.5, -155, 0.35, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(160, 50, 255)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.1
MainStroke.Parent = MainFrame

-- شريط العنوان العلوي
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 14)
TopBarCorner.Parent = TopBar

-- زر الإغلاق النهائي (❌)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(0, 8, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- زر الإخفاء / التصغير (➖)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(0, 40, 0, 7)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 6)
MiniCorner.Parent = MinimizeBtn

-- عنوان الواجهة
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(1, -210, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐒 هروب القرد السريع"
Title.TextColor3 = Color3.fromRGB(245, 245, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Right
Title.Parent = TopBar

-- 3. الخانة المنسدلة (Dropdown Box)
local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Name = "DropdownBtn"
DropdownBtn.Size = UDim2.new(0.9, 0, 0, 42)
DropdownBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
DropdownBtn.Text = "المرحلة الأولى (1)  ▼"
DropdownBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
DropdownBtn.TextSize = 14
DropdownBtn.Font = Enum.Font.SourceSansBold
DropdownBtn.Parent = MainFrame

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 8)
DropdownCorner.Parent = DropdownBtn

local DropdownStroke = Instance.new("UIStroke")
DropdownStroke.Color = Color3.fromRGB(160, 50, 255)
DropdownStroke.Thickness = 1
DropdownStroke.Parent = DropdownBtn

-- إطار خيارات القائمة المنسدلة
local DropdownFrame = Instance.new("Frame")
DropdownFrame.Name = "DropdownFrame"
DropdownFrame.Size = UDim2.new(0.9, 0, 0, 0)
DropdownFrame.Position = UDim2.new(0.05, 0, 0.51, 0)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
DropdownFrame.BorderSizePixel = 0
DropdownFrame.ClipsDescendants = true
DropdownFrame.Visible = false
DropdownFrame.ZIndex = 10
DropdownFrame.Parent = MainFrame

local DropFrameCorner = Instance.new("UICorner")
DropFrameCorner.CornerRadius = UDim.new(0, 8)
DropFrameCorner.Parent = DropdownFrame

local DropFrameStroke = Instance.new("UIStroke")
DropFrameStroke.Color = Color3.fromRGB(160, 50, 255)
DropFrameStroke.Thickness = 1
DropFrameStroke.Parent = DropdownFrame

local DropListLayout = Instance.new("UIListLayout")
DropListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropListLayout.Padding = UDim.new(0, 3)
DropListLayout.Parent = DropdownFrame

-- 4. زر AUTO WIN
local AutoWinBtn = Instance.new("TextButton")
AutoWinBtn.Name = "AutoWinBtn"
AutoWinBtn.Size = UDim2.new(0.9, 0, 0, 45)
AutoWinBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
AutoWinBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 255)
AutoWinBtn.Text = "AUTO WIN"
AutoWinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoWinBtn.TextSize = 16
AutoWinBtn.Font = Enum.Font.GothamBold
AutoWinBtn.Parent = MainFrame

local AutoWinCorner = Instance.new("UICorner")
AutoWinCorner.CornerRadius = UDim.new(0, 10)
AutoWinCorner.Parent = AutoWinBtn

-- 5. الزر الدائري البنفسجي عند الإخفاء (Circle Toggle Button)
local CircleToggleBtn = Instance.new("TextButton")
CircleToggleBtn.Size = UDim2.new(0, 52, 0, 52)
CircleToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
CircleToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
CircleToggleBtn.Text = "🐒"
CircleToggleBtn.TextSize = 24
CircleToggleBtn.Visible = false
CircleToggleBtn.Active = true
CircleToggleBtn.Draggable = true
CircleToggleBtn.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = CircleToggleBtn

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(160, 50, 255)
CircleStroke.Thickness = 2.5
CircleStroke.Parent = CircleToggleBtn

-- 6. إضافة الخيارات داخل الخانة المنسدلة
local StageNames = {
    [1] = "المرحلة الأولى (1)",
    [2] = "المرحلة الثانية (2)",
    [3] = "المرحلة الثالثة (3)",
    [4] = "المرحلة الرابعة (4)",
    [5] = "المرحلة الخامسة (5)",
    [6] = "المرحلة السادسة (6)"
}

local IsDropdownOpen = false

local function ToggleDropdown()
    IsDropdownOpen = not IsDropdownOpen
    if IsDropdownOpen then
        DropdownFrame.Visible = true
        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.9, 0, 0, 175)}):Play()
        DropdownBtn.Text = StageNames[SelectedStage] .. "  ▲"
    else
        local tween = TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.9, 0, 0, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            if not IsDropdownOpen then DropdownFrame.Visible = false end
        end)
        DropdownBtn.Text = StageNames[SelectedStage] .. "  ▼"
    end
end

DropdownBtn.MouseButton1Click:Connect(ToggleDropdown)

for i = 1, 6 do
    local OptionBtn = Instance.new("TextButton")
    OptionBtn.Size = UDim2.new(1, 0, 0, 26)
    OptionBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    OptionBtn.BackgroundTransparency = 0.2
    OptionBtn.Text = StageNames[i]
    OptionBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
    OptionBtn.TextSize = 13
    OptionBtn.Font = Enum.Font.SourceSansBold
    OptionBtn.ZIndex = 11
    OptionBtn.Parent = DropdownFrame

    OptionBtn.MouseButton1Click:Connect(function()
        SelectedStage = i
        ToggleDropdown()
    end)
end

-- 7. منطق الـ AUTO WIN والتنقل التتابعي
local IsTeleporting = false

AutoWinBtn.MouseButton1Click:Connect(function()
    if IsTeleporting then return end
    IsTeleporting = true
    
    AutoWinBtn.Text = "RUNNING..."
    AutoWinBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 30)

    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local HumanoidRootPart = Character.HumanoidRootPart

        -- المرور التتابعي من البداية وحتى المرحلة المختارة
        for stage = 0, SelectedStage do
            local waypoints = StageWaypoints[stage]
            if waypoints then
                for _, cframePos in ipairs(waypoints) do
                    HumanoidRootPart.CFrame = cframePos
                    task.wait(0.25)
                end
            end
        end
    end

    AutoWinBtn.Text = "AUTO WIN"
    AutoWinBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 255)
    IsTeleporting = false
end)

-- 8. أزرار الإخفاء والإظهار والإغلاق
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    CircleToggleBtn.Visible = true
end)

CircleToggleBtn.MouseButton1Click:Connect(function()
    CircleToggleBtn.Visible = false
    MainFrame.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
