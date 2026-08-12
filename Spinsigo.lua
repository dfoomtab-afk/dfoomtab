-- Direct Auto Loop Teleport Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- الأحداثية المطلوبة
local targetCFrame = CFrame.new(3200, 3275, -846)

-- إنشاء الشاشة والواجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DirectTeleportGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 180, 0, 90)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "التنقل التلقائي المستمر"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- زر التفعيل والتعطيل
local ActionBtn = Instance.new("TextButton")
ActionBtn.Name = "ActionBtn"
ActionBtn.Size = UDim2.new(1, -20, 0, 40)
ActionBtn.Position = UDim2.new(0, 10, 0, 40)
ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ActionBtn.Text = "التنقل المستمر: OFF"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.TextSize = 12
ActionBtn.Font = Enum.Font.SourceSansBold
ActionBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ActionBtn

-- متغيرات التحكم بالنظام
local isLooping = false
local loopThread = nil

-- دالة التنقل والتثبيت
local function startTeleportLoop()
    loopThread = task.spawn(function()
        while isLooping do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character:PivotTo(targetCFrame)
            end
            task.wait(0.1)
        end
    end)
end

-- تشغيل وإيقاف الزر
ActionBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    if isLooping then
        ActionBtn.Text = "التنقل المستمر: ON"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        startTeleportLoop()
    else
        ActionBtn.Text = "التنقل المستمر: OFF"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        if loopThread then
            task.cancel(loopThread)
            loopThread = nil
        end
    end
end)

-- إعادة التفعيل التلقائي عند الموت
LocalPlayer.CharacterAdded:Connect(function()
    if isLooping then
        task.wait(0.5)
        startTeleportLoop()
    end
end)
