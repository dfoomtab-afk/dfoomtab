-- Delta Auto-Walk Ultra Luxury (Deep Glowing Crimson Theme + Infinite Jump)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variables
local TARGET_Y = 361
local isRunning = false
local infJumpEnabled = false
local moveSpeed = 50

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

-- Infinite Jump Mechanics
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Cleanup Old UI
if game:GetService("CoreGui"):FindFirstChild("LuxuryAutoWalk") then
    game:GetService("CoreGui").LuxuryAutoWalk:Destroy()
end

-- Screen UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LuxuryAutoWalk"

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 8, 10)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Position = UDim2.new(0.08, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 330, 0, 280) -- تم تكبير الصفحة لاستيعاب الزر الجديد
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(180, 20, 40)
MainStroke.Thickness = 2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Title Bar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.Size = UDim2.new(0.65, 0, 0, 40)
TitleLabel.Position = UDim2.new(0.06, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "👑 AUTO WALK PRO"
TitleLabel.TextColor3 = Color3.fromRGB(255, 230, 235)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.BackgroundColor3 = Color3.fromRGB(110, 15, 25)
CloseBtn.BackgroundTransparency = 0.15
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Parent = CloseBtn
CloseStroke.Color = Color3.fromRGB(200, 30, 50)
CloseStroke.Thickness = 1.2

-- Minimize Button (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = MainFrame
MinimizeBtn.Position = UDim2.new(0.72, 0, 0.05, 0)
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
MinimizeBtn.BackgroundTransparency = 0.15
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 22
MinimizeBtn.Font = Enum.Font.GothamBold

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 8)
MiniCorner.Parent = MinimizeBtn

local MiniBtnStroke = Instance.new("UIStroke")
MiniBtnStroke.Parent = MinimizeBtn
MiniBtnStroke.Color = Color3.fromRGB(80, 40, 50)
MiniBtnStroke.Thickness = 1

-- Floating Ball UI
local MiniBall = Instance.new("TextButton")
MiniBall.Name = "MiniBall"
MiniBall.Parent = ScreenGui
MiniBall.Position = MainFrame.Position
MiniBall.Size = UDim2.new(0, 55, 0, 55)
MiniBall.BackgroundColor3 = Color3.fromRGB(15, 8, 10)
MiniBall.BackgroundTransparency = 0.2
MiniBall.Text = "👑"
MiniBall.TextSize = 24
MiniBall.Visible = false
MiniBall.Active = true
MiniBall.Draggable = true

local BallCorner = Instance.new("UICorner")
BallCorner.CornerRadius = UDim.new(1, 0)
BallCorner.Parent = MiniBall

local BallStroke = Instance.new("UIStroke")
BallStroke.Parent = MiniBall
BallStroke.Color = Color3.fromRGB(180, 20, 40)
BallStroke.Thickness = 2.5

-- Speed Input Frame
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Parent = MainFrame
SpeedFrame.Position = UDim2.new(0.06, 0, 0.20, 0)
SpeedFrame.Size = UDim2.new(0.88, 0, 0, 42)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(25, 12, 16)
SpeedFrame.BackgroundTransparency = 0.3

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 10)
SpeedCorner.Parent = SpeedFrame

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Parent = SpeedFrame
SpeedStroke.Color = Color3.fromRGB(100, 20, 35)
SpeedStroke.Thickness = 1

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = SpeedFrame
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 0)
SpeedLabel.Size = UDim2.new(0.5, 0, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚡ Speed:"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 230, 235)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = SpeedFrame
SpeedInput.Position = UDim2.new(0.55, 0, 0.16, 0)
SpeedInput.Size = UDim2.new(0.4, 0, 0.68, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(45, 18, 25)
SpeedInput.BackgroundTransparency = 0.2
SpeedInput.Text = tostring(moveSpeed)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.TextSize = 14
SpeedInput.Font = Enum.Font.GothamBold

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = SpeedInput

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val > 0 then
        moveSpeed = val
    else
        SpeedInput.Text = tostring(moveSpeed)
    end
end)

-- AUTO WALK TOGGLE BUTTON
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = MainFrame
ToggleButton.Position = UDim2.new(0.06, 0, 0.43, 0)
ToggleButton.Size = UDim2.new(0.88, 0, 0, 46)
ToggleButton.BackgroundColor3 = Color3.fromRGB(120, 15, 25)
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.Text = "AUTO WALK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = ToggleButton

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Parent = ToggleButton
BtnStroke.Color = Color3.fromRGB(220, 30, 50)
BtnStroke.Thickness = 1.8

-- INFINITE JUMP TOGGLE BUTTON (NEW)
local JumpButton = Instance.new("TextButton")
JumpButton.Parent = MainFrame
JumpButton.Position = UDim2.new(0.06, 0, 0.66, 0)
JumpButton.Size = UDim2.new(0.88, 0, 0, 46)
JumpButton.BackgroundColor3 = Color3.fromRGB(120, 15, 25)
JumpButton.BackgroundTransparency = 0.1
JumpButton.Text = "INF JUMP: OFF"
JumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpButton.TextSize = 14
JumpButton.Font = Enum.Font.GothamBold

local JumpCorner = Instance.new("UICorner")
JumpCorner.CornerRadius = UDim.new(0, 10)
JumpCorner.Parent = JumpButton

local JumpStroke = Instance.new("UIStroke")
JumpStroke.Parent = JumpButton
JumpStroke.Color = Color3.fromRGB(220, 30, 50)
JumpStroke.Thickness = 1.8

-- Noclip & Movement Execution
local noclipConn = nil
local currentTween = nil

local function enableNoclip(char)
    if not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            if isRunning and char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function disableNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

local function startWalking()
    task.spawn(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        enableNoclip(char)

        while isRunning do
            for i, targetPos in ipairs(waypoints) do
                if not isRunning then break end

                local destination = Vector3.new(targetPos.X, TARGET_Y, targetPos.Z)
                local distance = (destination - hrp.Position).Magnitude
                local duration = distance / moveSpeed

                hrp.CFrame = CFrame.new(hrp.Position, destination)

                local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                currentTween = TweenService:Create(hrp, tweenInfo, {
                    CFrame = CFrame.new(destination, destination + (destination - hrp.Position).Unit)
                })

                currentTween:Play()

                local completed = false
                local conn
                conn = currentTween.Completed:Connect(function()
                    completed = true
                    if conn then conn:Disconnect() end
                end)

                while not completed and isRunning do
                    task.wait(0.05)
                end

                if not isRunning then
                    if currentTween then currentTween:Cancel() end
                    break
                end
            end

            if isRunning then
                local firstWaypoint = waypoints[1]
                hrp.CFrame = CFrame.new(firstWaypoint.X, TARGET_Y, firstWaypoint.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero
                task.wait(0.1)
            end
        end

        disableNoclip()
    end)
end

-- Auto Walk Handler
ToggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 110, 50)}):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 215, 95)}):Play()
        ToggleButton.Text = "AUTO WALK: ON"
        startWalking()
    else
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(120, 15, 25)}):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(220, 30, 50)}):Play()
        ToggleButton.Text = "AUTO WALK: OFF"
        if currentTween then currentTween:Cancel() end
        disableNoclip()
    end
end)

-- Inf Jump Handler
JumpButton.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        TweenService:Create(JumpButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 110, 50)}):Play()
        TweenService:Create(JumpStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 215, 95)}):Play()
        JumpButton.Text = "INF JUMP: ON"
    else
        TweenService:Create(JumpButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(120, 15, 25)}):Play()
        TweenService:Create(JumpStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(220, 30, 50)}):Play()
        JumpButton.Text = "INF JUMP: OFF"
    end
end)

-- Minimize Event
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniBall.Position = MainFrame.Position
    MiniBall.Visible = true
end)

MiniBall.MouseButton1Click:Connect(function()
    MiniBall.Visible = false
    MainFrame.Position = MiniBall.Position
    MainFrame.Visible = true
end)

-- Close Event
CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    infJumpEnabled = false
    if currentTween then currentTween:Cancel() end
    disableNoclip()
    ScreenGui:Destroy()
end)
