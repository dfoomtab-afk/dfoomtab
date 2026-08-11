-- Key System + Auto Loop Teleport Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local targetCFrame = CFrame.new(-6, 68, 1669)

-- إنشاء الشاشة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeyTeleportGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------
-- 1. واجهة إدخال المفتاح (Key System GUI)
---------------------------------------------------------
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 260, 0, 150)
KeyFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
KeyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 8)
KeyCorner.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "نظام التحقق من المفتاح"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 14
KeyTitle.Font = Enum.Font.SourceSansBold
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -30, 0, 35)
KeyInput.Position = UDim2.new(0, 15, 0, 45)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.PlaceholderText = "أدخل المفتاح هنا..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 13
KeyInput.Font = Enum.Font.SourceSans
KeyInput.Parent = KeyFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = KeyInput

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(1, -30, 0, 35)
SubmitBtn.Position = UDim2.new(0, 15, 0, 95)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
SubmitBtn.Text = "تأكيد المفتاح"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 13
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.Parent = KeyFrame

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 5)
SubmitCorner.Parent = SubmitBtn

---------------------------------------------------------
-- 2. واجهة التنقل المستمر (Main Script GUI)
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false -- مخفية حتى يتم إدخال المفتاح
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "التنقل التلقائي المستمر"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Size = UDim2.new(1, 0, 0, 20)
TimerLabel.Position = UDim2.new(0, 0, 0, 30)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Text = "الوقت المتبقي: --:--"
TimerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimerLabel.TextSize = 11
TimerLabel.Font = Enum.Font.SourceSans
TimerLabel.Parent = MainFrame

local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -20, 0, 40)
ActionBtn.Position = UDim2.new(0, 10, 0, 60)
ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ActionBtn.Text = "التنقل المستمر: OFF"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.TextSize = 12
ActionBtn.Font = Enum.Font.SourceSansBold
ActionBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ActionBtn

---------------------------------------------------------
-- 3. البرمجة والمنطق
---------------------------------------------------------
local isLooping = false
local loopThread = nil
local timeRemaining = 0

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

LocalPlayer.CharacterAdded:Connect(function()
    if isLooping then
        task.wait(0.5)
        startTeleportLoop()
    end
end)

-- مؤقت إغلاق السكربت عند انتهاء الصلاحية
local function startKeyTimer(durationSeconds)
    timeRemaining = durationSeconds
    
    task.spawn(function()
        while timeRemaining > 0 do
            local hours = math.floor(timeRemaining / 3600)
            local mins = math.floor((timeRemaining % 3600) / 60)
            local secs = timeRemaining % 60
            
            if hours > 0 then
                TimerLabel.Text = string.format("المتبقي: %02d:%02d:%02d", hours, mins, secs)
            else
                TimerLabel.Text = string.format("المتبقي: %02d:%02d", mins, secs)
            end
            
            task.wait(1)
            timeRemaining = timeRemaining - 1
        end
        
        -- إغلاق وإلغاء السكربت عند انتهاء الوقت
        isLooping = false
        if loopThread then task.cancel(loopThread) end
        ScreenGui:Destroy()
    end)
end

-- زر التحقق من المفتاح
SubmitBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text
    
    if enteredKey == "saif" then
        KeyFrame.Visible = false
        MainFrame.Visible = true
        startKeyTimer(30 * 60) -- 30 دقيقة (1800 ثانية)
    elseif enteredKey == "dfoomtab" then
        KeyFrame.Visible = false
        MainFrame.Visible = true
        startKeyTimer(24 * 60 * 60) -- يوم كامل (86400 ثانية)
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "مفتاح خاطئ! حاول مجدداً"
    end
end)
