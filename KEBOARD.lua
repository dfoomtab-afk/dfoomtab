-- ==========================================
-- الإعدادات المتغيرة
-- ==========================================
local MOVE_SPEED = 50        -- السرعة التي تحددها
local TARGET_Y = 361         -- الارتفاع الثابت المطلق
local isRunning = true

local waypoints = {
    Vector3.new(-200, TARGET_Y, -783),
    Vector3.new(99, TARGET_Y, -783),
    Vector3.new(437, TARGET_Y, -783),
    Vector3.new(785, TARGET_Y, -785),
    Vector3.new(933, TARGET_Y, -761),
    Vector3.new(1180, TARGET_Y, -759),
    Vector3.new(1364, TARGET_Y, -705),
    Vector3.new(1559, TARGET_Y, -752),
    Vector3.new(1559, TARGET_Y, -735)
}

-- إنشاء الواجهة الرسومية (GUI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("SmoothAirWalkGui") then
    PlayerGui.SmoothAirWalkGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmoothAirWalkGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- النافذة الرئيسية
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 160)
mainFrame.Position = UDim2.new(0.5, -110, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- عنوان الواجهة
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "Air Walk + Noclip"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- زر التصغير (-)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -30, 0, 5)
minimizeBtn.Text = "-"
minimizeBtn.TextSize = 20
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
minimizeBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 5)
btnCorner.Parent = minimizeBtn

-- الدائرة التي تظهر عند التصغير
local circleBtn = Instance.new("TextButton")
circleBtn.Size = UDim2.new(0, 50, 0, 50)
circleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
circleBtn.Text = "AIR"
circleBtn.TextSize = 14
circleBtn.Font = Enum.Font.SourceSansBold
circleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
circleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
circleBtn.Visible = false
circleBtn.Active = true
circleBtn.Draggable = true
circleBtn.Parent = screenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circleBtn

-- خانة إدخال السرعة
local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.9, 0, 0, 30)
speedInput.Position = UDim2.new(0.05, 0, 0.28, 0)
speedInput.PlaceholderText = "السرعة (حالياً: " .. MOVE_SPEED .. ")"
speedInput.Text = tostring(MOVE_SPEED)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 5)
inputCorner.Parent = speedInput

-- زر التشغيل والإيقاف
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
toggleBtn.Text = "الحالة: شغال"
toggleBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 15
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 5)
toggleCorner.Parent = toggleBtn

-- ==========================================
-- الأحداث والتحكم بالواجهة
-- ==========================================

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    circleBtn.Visible = true
end)

circleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    circleBtn.Visible = false
end)

speedInput.FocusLost:Connect(function()
    local val = tonumber(speedInput.Text)
    if val then
        MOVE_SPEED = val
    else
        speedInput.Text = tostring(MOVE_SPEED)
    end
end)

local function cleanupPhysics(char)
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "الحالة: شغال"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
    else
        toggleBtn.Text = "الحالة: متوقف"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(178, 34, 34)
        local char = LocalPlayer.Character
        cleanupPhysics(char)
    end
end)

-- ==========================================
-- نظام اختراق الجدران (Noclip Loop)
-- ==========================================
RunService.Stepped:Connect(function()
    if isRunning then
        local char = LocalPlayer.Character
        if char then
            for _, child in ipairs(char:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CanCollide = false
                end
            end
        end
    end
end)

-- ==========================================
-- حلقة الحركة الفيزيائية السلسة
-- ==========================================
task.spawn(function()
    while true do
        if isRunning then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if hrp and humanoid and humanoid.Health > 0 then
                local bv = hrp:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity")
                bv.Name = "FlyVelocity"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = hrp

                local bg = hrp:FindFirstChild("FlyGyro") or Instance.new("BodyGyro")
                bg.Name = "FlyGyro"
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 9000
                bg.Parent = hrp

                for _, targetPos in ipairs(waypoints) do
                    if not isRunning then break end

                    while isRunning and hrp and humanoid and humanoid.Health > 0 do
                        local currentPos = hrp.Position
                        local destination = Vector3.new(targetPos.X, TARGET_Y, targetPos.Z)
                        local direction = (destination - currentPos)
                        local distance = direction.Magnitude

                        if distance <= 3 then
                            break
                        end

                        bv.Velocity = direction.Unit * MOVE_SPEED
                        bg.CFrame = CFrame.new(currentPos, destination)

                        task.wait(0.02)
                    end
                end
            end
        else
            local char = LocalPlayer.Character
            cleanupPhysics(char)
        end
        task.wait(0.1)
    end
end)
