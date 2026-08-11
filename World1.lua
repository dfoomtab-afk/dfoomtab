-- Delta Teleport & God Mode GUI Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- إنشاء الشاشة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- الإطار الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 360)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- العنوان
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -35, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "قائمة التنقل والحماية"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- زر التصغير / التكبير
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 25, 0, 25)
ToggleBtn.Position = UDim2.new(1, -30, 0, 5)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ToggleBtn.Text = "-"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 4)
ToggleCorner.Parent = ToggleBtn

-- زر عدم الموت (God Mode)
local GodBtn = Instance.new("TextButton")
GodBtn.Name = "GodBtn"
GodBtn.Size = UDim2.new(1, -20, 0, 35)
GodBtn.Position = UDim2.new(0, 10, 0, 40)
GodBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
GodBtn.Text = "تفعيل عدم الموت: OFF"
GodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GodBtn.TextSize = 13
GodBtn.Font = Enum.Font.SourceSansBold
GodBtn.Parent = MainFrame

local GodCorner = Instance.new("UICorner")
GodCorner.CornerRadius = UDim.new(0, 6)
GodCorner.Parent = GodBtn

-- قائمة التمرير لأزرار التنقل
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "ScrollList"
Scroll.Size = UDim2.new(1, -20, 1, -90)
Scroll.Position = UDim2.new(0, 10, 0, 80)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 4
Scroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Scroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

-- جدول الأحداثيات (تم تعديل الزر الـ 14 بنجاح)
local locations = {
    Vector3.new(5, 15, 17),
    Vector3.new(5, 15, 115),
    Vector3.new(5, 15, 225),
    Vector3.new(5, 15, 337),
    Vector3.new(5, 47, 473),
    Vector3.new(5, 47, 567),
    Vector3.new(5, 47, 710),
    Vector3.new(5, 47, 821),
    Vector3.new(5, 47, 943),
    Vector3.new(5, 47, 1120),
    Vector3.new(5, 47, 1252),
    Vector3.new(5, 100, 1469),
    Vector3.new(5, 100, 1620),
    Vector3.new(5, 100, 1815) -- الزر الـ 14 بعد المعاكسة
}

-- دالة التنقل الفوري
local function teleportTo(coords)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if character and character:FindFirstChild("HumanoidRootPart") then
        character:PivotTo(CFrame.new(coords))
    end
end

-- إنشاء أزرار التنقل
for i, pos in ipairs(locations) do
    local Btn = Instance.new("TextButton")
    Btn.Name = "Teleport_" .. i
    Btn.Size = UDim2.new(1, -6, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = "زر " .. i .. " (" .. pos.X .. ", " .. pos.Y .. ", " .. pos.Z .. ")"
    Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.SourceSans
    Btn.Parent = Scroll

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        teleportTo(pos)
    end)
end

-- نظام عدم الموت (God Mode + Anti-Void)
local godModeActive = false

local function applyGodMode(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        humanoid.HealthChanged:Connect(function()
            if godModeActive then
                humanoid.Health = math.huge
            end
        end)
        
        humanoid.StateChanged:Connect(function(_, newState)
            if godModeActive and newState == Enum.HumanoidStateType.Dead then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                humanoid.Health = math.huge
            end
        end)
    end
end

-- حماية من السقوط في الفراغ
task.spawn(function()
    while task.wait(0.5) do
        if godModeActive then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if char.HumanoidRootPart.Position.Y < -50 then
                    teleportTo(locations[1])
                end
            end
        end
    end
end)

GodBtn.MouseButton1Click:Connect(function()
    godModeActive = not godModeActive
    if godModeActive then
        GodBtn.Text = "تفعيل عدم الموت: ON"
        GodBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        if LocalPlayer.Character then
            applyGodMode(LocalPlayer.Character)
        end
    else
        GodBtn.Text = "تفعيل عدم الموت: OFF"
        GodBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.MaxHealth = 100
            LocalPlayer.Character.Humanoid.Health = 100
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if godModeActive then
        task.wait(0.5)
        applyGodMode(char)
    end
end)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- تصغير/تكبير القائمة
local minimized = false
ToggleBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Scroll.Visible = false
        GodBtn.Visible = false
        MainFrame.Size = UDim2.new(0, 220, 0, 35)
        ToggleBtn.Text = "+"
    else
        Scroll.Visible = true
        GodBtn.Visible = true
        MainFrame.Size = UDim2.new(0, 220, 0, 360)
        ToggleBtn.Text = "-"
    end
end)
