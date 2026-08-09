-- Delta Teleport & God Mode GUI Script (New Coordinates)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- إنشاء الشاشة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGui_v2"
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
Title.Text = "قائمة التنقل (10 مواقع)"
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

-- زر عدم الموت والحماية
local GodBtn = Instance.new("TextButton")
GodBtn.Name = "GodBtn"
GodBtn.Size = UDim2.new(1, -20, 0, 35)
GodBtn.Position = UDim2.new(0, 10, 0, 40)
GodBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
GodBtn.Text = "حماية من الموت والسقوط: OFF"
GodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GodBtn.TextSize = 12
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

-- جدول الأحداثيات الـ 10 الجديدة
local locations = {
    Vector3.new(5, 15, 48),
    Vector3.new(5, 15, 227),
    Vector3.new(5, 15, 409),
    Vector3.new(5, 15, 600),
    Vector3.new(5, 15, 778),
    Vector3.new(5, 15, 951),
    Vector3.new(5, 68, 1153),
    Vector3.new(5, 68, 1349),
    Vector3.new(5, 68, 1490),
    Vector3.new(5, 68, 1664)
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

-- نظام الحماية وعدم الموت
local godModeActive = false
local touchConnections = {}

local function protectCharacter(char)
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local conn = part.Touched:Connect(function(hit)
                if godModeActive and hit and (hit.Name:lower():find("kill") or hit.Name:lower():find("lava") or hit.Name:lower():find("dead")) then
                    part.CanCollide = false
                end
            end)
            table.insert(touchConnections, conn)
        end
    end
    
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        
        humanoid.HealthChanged:Connect(function()
            if godModeActive and humanoid.Health < 100 then
                humanoid.Health = 100
            end
        end)
    end
end

-- حماية السقوط
task.spawn(function()
    while task.wait(0.1) do
        if godModeActive then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                if hrp.AssemblyLinearVelocity.Y < -50 then
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -10, hrp.AssemblyLinearVelocity.Z)
                end
                if hrp.Position.Y < -10 then
                    teleportTo(locations[1])
                end
            end
        end
    end
end)

GodBtn.MouseButton1Click:Connect(function()
    godModeActive = not godModeActive
    if godModeActive then
        GodBtn.Text = "حماية من الموت والسقوط: ON"
        GodBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        
        for _, conn in ipairs(touchConnections) do conn:Disconnect() end
        touchConnections = {}
        
        if LocalPlayer.Character then
            protectCharacter(LocalPlayer.Character)
        end
    else
        GodBtn.Text = "حماية من الموت والسقوط: OFF"
        GodBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        
        for _, conn in ipairs(touchConnections) do conn:Disconnect() end
        touchConnections = {}
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if godModeActive then
        task.wait(0.5)
        protectCharacter(char)
    end
end)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- وظيفة تصغير/تكبير القائمة
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
