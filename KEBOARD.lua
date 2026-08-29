-- ==========================================
-- الإعدادات المتغيرة
-- ==========================================
local MOVE_SPEED = 30        -- سرعة المشي الطبيعية (الافتراضية في روبلوكس 16)
local isRunning = true

local waypoints = {
    Vector3.new(-200, 361, -783),
    Vector3.new(99, 361, -783),
    Vector3.new(437, 361, -783),
    Vector3.new(785, 361, -785),
    Vector3.new(933, 361, -761),
    Vector3.new(1180, 361, -759),
    Vector3.new(1364, 361, -705),
    Vector3.new(1559, 361, -752),
    Vector3.new(1559, 361, -735)
}

-- إنشاء الواجهة الرسومية (GUI)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("AutoWalkGui") then
    PlayerGui.AutoWalkGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoWalkGui"
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
title.Text = "Auto Walk"
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
circleBtn.Text = "WALK"
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
-- الأحداث والتحكم
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

toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "الحالة: شغال"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
    else
        toggleBtn.Text = "الحالة: متوقف"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(178, 34, 34)
    end
end)

-- ==========================================
-- حلقة المشي الطبيعي (Pathing Loop)
-- ==========================================

task.spawn(function()
    while true do
        if isRunning then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 then
                humanoid.WalkSpeed = MOVE_SPEED

                for _, targetPos in ipairs(waypoints) do
                    if not isRunning then break end
                    
                    local charCheck = LocalPlayer.Character
                    local humCheck = charCheck and charCheck:FindFirstChildOfClass("Humanoid")
                    
                    if humCheck and humCheck.Health > 0 then
                        humCheck.WalkSpeed = MOVE_SPEED
                        
                        -- توجيه اللاعب للمشي نحو النقطة
                        humCheck:MoveTo(targetPos)
                        
                        -- الانتظار حتى يصل اللاعب للنقطة أو تنتهي مهلة (8 ثوانٍ) لمنع التجميد إذا علق اللاعب
                        local reached = false
                        local conn = humCheck.MoveToFinished:Connect(function()
                            reached = true
                        end)
                        
                        local timeout = 0
                        while not reached and timeout < 8 and isRunning do
                            task.wait(0.1)
                            timeout = timeout + 0.1
                        end
                        
                        conn:Disconnect()
                    else
                        break
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)
