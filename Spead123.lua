-- Anti-Rubberband Speed Script for Delta Executor
-- Designed for strict Anticheat / Egg Hunt Maps

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuration Variables
local TargetSpeed = 50 -- السرعة الافتراضية (50 - 5000)
local MaxSpeed = 5000
local MinSpeed = 50
local SpeedEnabled = true

local function setSpeed(value)
    if typeof(value) == "number" then
        TargetSpeed = math.clamp(value, MinSpeed, MaxSpeed)
    end
end

-- Anti-Rubberband Logic using CFrame Step Displacement
RunService.RenderStepped:Connect(function(deltaTime)
    if not SpeedEnabled then return end

    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
        local humanoid = character.Humanoid
        local hrp = character.HumanoidRootPart

        -- إلغاء تأثير الفيزياء المحتسبة من الخادم للحد من الإرجاع
        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)

        -- إذا كان اللاعب يضغط أسهم الحركة للأمام/الجوانب
        if humanoid.MoveDirection.Magnitude > 0 then
            -- حساب المسافة بناءً على deltaTime لضمان سلاسة التنسيق وعدم القفز المفاجئ
            local moveDistance = humanoid.MoveDirection * (TargetSpeed * deltaTime)
            
            -- نقل الإحداثيات للأمام مباشرة دون تعديل WalkSpeed لمنع كشف Anti-Cheat الماب
            hrp.CFrame = hrp.CFrame + moveDistance
        end
    end
end)

-- UI Interface (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SpeedInput = Instance.new("TextBox")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Name = "AntiRubberbandGui"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 210, 0, 130)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "No-Bypass Speed (50 - 5000)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13.000
Title.Font = Enum.Font.SourceSansBold

SpeedInput.Parent = MainFrame
SpeedInput.Position = UDim2.new(0.1, 0, 0.3, 0)
SpeedInput.Size = UDim2.new(0.8, 0, 0.3, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedInput.Text = tostring(TargetSpeed)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 16.000
SpeedInput.Font = Enum.Font.SourceSans

ToggleButton.Parent = MainFrame
ToggleButton.Position = UDim2.new(0.1, 0, 0.65, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0.25, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.Text = "Status: ON"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14.000
ToggleButton.Font = Enum.Font.SourceSansBold

-- Event Handlers
SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val then
        setSpeed(val)
        SpeedInput.Text = tostring(TargetSpeed)
    else
        SpeedInput.Text = tostring(TargetSpeed)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        ToggleButton.Text = "Status: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        ToggleButton.Text = "Status: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)
