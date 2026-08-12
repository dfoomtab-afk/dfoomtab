-- Delta Ultra-Compatible Teleport Script
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- حذف أي واجهة قديمة لمنع التداخل
if CoreGui:FindFirstChild("DeltaTeleportUI") then
    CoreGui.DeltaTeleportUI:Destroy()
end

local targetCFrame = CFrame.new(3200, 3275, -846)

-- إنشاء الواجهة داخل CoreGui مباشرة لتجاوز حظر الماب
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaTeleportUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999 -- إظهار الواجهة فوق كل عناصر اللعبة
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 190, 0, 95)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
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
Title.Text = "التنقل المستمر (Delta)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local ActionBtn = Instance.new("TextButton")
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

local isLooping = false
local loopThread = nil

local function startTeleportLoop()
    if loopThread then task.cancel(loopThread) end
    loopThread = task.spawn(function()
        while isLooping do
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                if hrp then
                    hrp.CFrame = targetCFrame
                end
            end
            task.wait(0.05)
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
