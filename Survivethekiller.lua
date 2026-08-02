-- Survive the Killer Ultimate Script
-- Modern UI with Arabic Control Options

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- 1. إنشاء واجهة المستخدم (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SurviveTheKiller_GUI"
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
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.3, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
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
Title.Size = UDim2.new(0, 220, 1, 0)
Title.Position = UDim2.new(1, -230, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔪 Survive The Killer VIP"
Title.TextColor3 = Color3.fromRGB(245, 245, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Right
Title.Parent = TopBar

-- 2. قائمة التمرير للأزرار (Scrolling Frame)
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0.94, 0, 0.82, 0)
ScrollList.Position = UDim2.new(0.03, 0, 0.15, 0)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 4
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(160, 50, 255)
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollList

-- الزر الدائري البنفسجي عند الإخفاء
local CircleToggleBtn = Instance.new("TextButton")
CircleToggleBtn.Size = UDim2.new(0, 52, 0, 52)
CircleToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
CircleToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
CircleToggleBtn.Text = "🔪"
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

-- 3. دالة مساعدة لإنشاء أزرار التفعيل والتعطيل (Toggle Buttons)
local function CreateToggleButton(text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.96, 0, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 36)
    Frame.Parent = ScrollList

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 8)
    FrameCorner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Position = UDim2.new(0.32, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 245)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Right
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
    ToggleBtn.Position = UDim2.new(0.04, 0, 0.15, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
    ToggleBtn.Text = "إيقاف"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn

    local state = false
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
            ToggleBtn.Text = "تشغيل"
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
            ToggleBtn.Text = "إيقاف"
        end
        callback(state)
    end)
end

-- 4. ميزات وسكربتات اللعبة

-- [1] انقاذ الأصدقاء تلقائياً (Auto Revive)
local AutoReviveEnabled = false
CreateToggleButton("إنقاذ الأصدقاء تلقائياً 🚑", function(state)
    AutoReviveEnabled = state
end)

task.spawn(function()
    while task.wait(0.5) do
        if AutoReviveEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local targetChar = player.Character
                            -- التحقق من حالة اللاعب المصاب داخل الماب
                            if targetChar:FindFirstChild("Downed") or targetChar:FindFirstChild("RevivePrompt") then
                                local root = targetChar:FindFirstChild("HumanoidRootPart")
                                if root then
                                    char.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, 2)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- [2] سرعة المشي (Speed Hack)
local SpeedEnabled = false
local NormalSpeed = 16
local FastSpeed = 28

CreateToggleButton("زيادة سرعة المشي ⚡", function(state)
    SpeedEnabled = state
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = state and FastSpeed or NormalSpeed
    end
end)

RunService.RenderStepped:Connect(function()
    if SpeedEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            if char.Humanoid.WalkSpeed ~= FastSpeed then
                char.Humanoid.WalkSpeed = FastSpeed
            end
        end
    end
end)

-- [3] كشف القاتل واللاعبين (ESP Players & Killer)
local ESPEnabled = false
local Highlights = {}

CreateToggleButton("رؤية القاتل واللاعبين خلف الجدران 👁️", function(state)
    ESPEnabled = state
    if not state then
        for _, hl in pairs(Highlights) do
            hl:Destroy()
        end
        Highlights = {}
    end
end)

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                if not Highlights[player] or not Highlights[player].Parent then
                    local hl = Instance.new("Highlight")
                    hl.Name = "ESPHighlight"
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    
                    -- تمييز القاتل باللون الأحمر واللاعبين باللون الأخضر
                    if char:FindFirstChild("Knife") or char:FindFirstChild("Killer") or player.Name:lower():find("killer") then
                        hl.FillColor = Color3.fromRGB(255, 30, 30)
                    else
                        hl.FillColor = Color3.fromRGB(30, 255, 100)
                    end
                    
                    hl.Adornee = char
                    hl.Parent = char
                    Highlights[player] = hl
                end
            end
        end
    end
end)

-- [4] كشف الصناديق والمسروقات (ESP Loot & Chests)
local ChestESPEnabled = false
local ChestHighlights = {}

CreateToggleButton("كشف الصناديق والكنوز 📦", function(state)
    ChestESPEnabled = state
    if not state then
        for _, hl in pairs(ChestHighlights) do
            hl:Destroy()
        end
        ChestHighlights = {}
    end
end)

task.spawn(function()
    while task.wait(1) do
        if ChestESPEnabled then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("chest") or obj.Name:lower():find("loot") then
                        if not ChestHighlights[obj] or not ChestHighlights[obj].Parent then
                            local hl = Instance.new("Highlight")
                            hl.FillColor = Color3.fromRGB(255, 215, 0)
                            hl.FillTransparency = 0.4
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Adornee = obj
                            hl.Parent = obj
                            ChestHighlights[obj] = hl
                        end
                    end
                end
            end)
        end
    end
end)

-- [5] الانتقال السريع للمخرج (Teleport to Exit)
local ExitBtnFrame = Instance.new("Frame")
ExitBtnFrame.Size = UDim2.new(0.96, 0, 0, 42)
ExitBtnFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 36)
ExitBtnFrame.Parent = ScrollList

local ExitCorner = Instance.new("UICorner")
ExitCorner.CornerRadius = UDim.new(0, 8)
ExitCorner.Parent = ExitBtnFrame

local ExitLabel = Instance.new("TextLabel")
ExitLabel.Size = UDim2.new(0.65, 0, 1, 0)
ExitLabel.Position = UDim2.new(0.32, 0, 0, 0)
ExitLabel.BackgroundTransparency = 1
ExitLabel.Text = "الانتقال السريع لبوابة الخروج 🚪"
ExitLabel.TextColor3 = Color3.fromRGB(230, 230, 245)
ExitLabel.TextSize = 14
ExitLabel.Font = Enum.Font.SourceSansBold
ExitLabel.TextXAlignment = Enum.TextXAlignment.Right
ExitLabel.Parent = ExitBtnFrame

local ExitActionBtn = Instance.new("TextButton")
ExitActionBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
ExitActionBtn.Position = UDim2.new(0.04, 0, 0.15, 0)
ExitActionBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 255)
ExitActionBtn.Text = "انتقال"
ExitActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitActionBtn.TextSize = 12
ExitActionBtn.Font = Enum.Font.GothamBold
ExitActionBtn.Parent = ExitBtnFrame

local ExitActionCorner = Instance.new("UICorner")
ExitActionCorner.CornerRadius = UDim.new(0, 6)
ExitActionCorner.Parent = ExitActionBtn

ExitActionBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("exit") or obj.Name:lower():find("escape") then
                    if obj:IsA("BasePart") then
                        char.HumanoidRootPart.CFrame = obj.CFrame * CFrame.new(0, 3, 0)
                        break
                    end
                end
            end
        end
    end)
end)

-- ضبط ارتفاع قائمة التمرير
ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)

-- 5. أزرار التحكم بالواجهة (التصغير والإغلاق)
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
