-- Keyboard Map World 3 Loop Teleport Script
-- Aspect Ratio: ~3:2 Window Design

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- 1. جدول إحداثيات مراحل العالم 3
local StageCoordinates = {
    [1] = CFrame.new(-1482, -70, -517),
    [2] = CFrame.new(-1482, -58, -16),
    [3] = CFrame.new(-1482, 214, 331),
    [4] = CFrame.new(-1432, 532, 760),
    [5] = CFrame.new(-1432, 532, 1328),
    [6] = CFrame.new(-2053, 442, 1469)
}

local SelectedStage = 1
local IsLooping = false

-- 2. إنشاء الواجهة (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeyboardWorld3_GUI"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- الإطار الرئيسي (بأبعاد 300x200 تناسب نسبة 3:2)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.35, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(160, 50, 255)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.1
MainStroke.Parent = MainFrame

-- شريط العنوان
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

-- زر الإغلاق (❌)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(0, 8, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- زر التصغير (➖)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(0, 38, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 6)
MiniCorner.Parent = MinimizeBtn

-- عنوان النافذة
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(1, -210, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⌨️ كيبورد - العالم 3"
Title.TextColor3 = Color3.fromRGB(245, 245, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Right
Title.Parent = TopBar

-- 3. القائمة المنسدلة (Dropdown)
local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Name = "DropdownBtn"
DropdownBtn.Size = UDim2.new(0.9, 0, 0, 40)
DropdownBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
DropdownBtn.Text = "مرحلة (1)  ▼"
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

local DropdownFrame = Instance.new("Frame")
DropdownFrame.Name = "DropdownFrame"
DropdownFrame.Size = UDim2.new(0.9, 0, 0, 0)
DropdownFrame.Position = UDim2.new(0.05, 0, 0.50, 0)
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
DropListLayout.Padding = UDim.new(0, 2)
DropListLayout.Parent = DropdownFrame

-- 4. زر التشغيل والإيقاف المدمج
local ToggleActionBtn = Instance.new("TextButton")
ToggleActionBtn.Name = "ToggleActionBtn"
ToggleActionBtn.Size = UDim2.new(0.9, 0, 0, 42)
ToggleActionBtn.Position = UDim2.new(0.05, 0, 0.68, 0)
ToggleActionBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
ToggleActionBtn.Text = "إيقاف"
ToggleActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleActionBtn.TextSize = 15
ToggleActionBtn.Font = Enum.Font.GothamBold
ToggleActionBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleActionBtn

-- 5. الزر الدائري البنفسجي للإظهار عند الإخفاء
local CircleToggleBtn = Instance.new("TextButton")
CircleToggleBtn.Size = UDim2.new(0, 52, 0, 52)
CircleToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
CircleToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
CircleToggleBtn.Text = "⌨️"
CircleToggleBtn.TextSize = 22
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

-- 6. إنشاء خيارات القائمة المنسدلة
local StageNames = {
    [1] = "مرحلة (1)",
    [2] = "مرحلة (2)",
    [3] = "مرحلة (3)",
    [4] = "مرحلة (4)",
    [5] = "مرحلة (5)",
    [6] = "مرحلة (6)"
}

local IsDropdownOpen = false

local function ToggleDropdown()
    IsDropdownOpen = not IsDropdownOpen
    if IsDropdownOpen then
        DropdownFrame.Visible = true
        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.9, 0, 0, 160)}):Play()
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
    OptionBtn.Size = UDim2.new(1, 0, 0, 24)
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

-- 7. حلقة التنقل المكرر مع الاستراحة (2 ثانية)
task.spawn(function()
    while true do
        if IsLooping then
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local targetCFrame = StageCoordinates[SelectedStage]
                    if targetCFrame then
                        character.HumanoidRootPart.CFrame = targetCFrame
                    end
                end
            end)
            task.wait(2) -- الاستراحة بين التنقلات
        else
            task.wait(0.2)
        end
    end
end)

ToggleActionBtn.MouseButton1Click:Connect(function()
    IsLooping = not IsLooping
    if IsLooping then
        ToggleActionBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        ToggleActionBtn.Text = "تشغيل"
    else
        ToggleActionBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
        ToggleActionBtn.Text = "إيقاف"
    end
end)

-- 8. أزرار النافذة (الإخفاء/الإظهار والإغلاق)
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    CircleToggleBtn.Visible = true
end)

CircleToggleBtn.MouseButton1Click:Connect(function()
    CircleToggleBtn.Visible = false
    MainFrame.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    IsLooping = false
    ScreenGui:Destroy()
end)
