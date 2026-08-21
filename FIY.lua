-- Roblox Hold-Jump Fly Script with Minimize Button (Delta Mobile)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local flySpeed = 100 -- السرعة الافتراضية
local guiVisible = true
local isMinimized = false

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JumpFlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 150)
mainFrame.Position = UDim2.new(0.5, -115, 0.4, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 10, 0, 3)
title.Text = "Jump Fly | Delta"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.SourceSansBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Minimize Button (-)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -54, 0, 5)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
minimizeBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = minimizeBtn

-- Close Button (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -27, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- Content Frame (المحتوى الذي يتم تصغيره)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 5)
speedLabel.Text = "سرعة الطيران: 100"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.SourceSans
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = contentFrame

-- Speed Input (TextBox)
local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(1, -20, 0, 35)
speedInput.Position = UDim2.new(0, 10, 0, 30)
speedInput.PlaceholderText = "اكتب السرعة هنا (مثل 500 أو 5000)"
speedInput.Text = "100"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
speedInput.Font = Enum.Font.SourceSans
speedInput.TextSize = 14
speedInput.Parent = contentFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = speedInput

-- Toggle Floating Button (HIDE / SHOW)
local toggleGuiBtn = Instance.new("TextButton")
toggleGuiBtn.Size = UDim2.new(0, 45, 0, 45)
toggleGuiBtn.Position = UDim2.new(0, 15, 0.5, -22)
toggleGuiBtn.Text = "HIDE"
toggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleGuiBtn.Font = Enum.Font.SourceSansBold
toggleGuiBtn.TextSize = 12
toggleGuiBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleGuiBtn

-- Jump Hold Logic
RunService.Heartbeat:Connect(function()
	local character = LocalPlayer.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local root = character.HumanoidRootPart
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		
		if humanoid and (UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump) then
			root.Velocity = Camera.CFrame.LookVector * flySpeed
		end
	end
end)

-- UI Handlers
speedInput.FocusLost:Connect(function()
	local val = tonumber(speedInput.Text)
	if val then
		flySpeed = val
		speedLabel.Text = "سرعة الطيران: " .. tostring(val)
	else
		speedInput.Text = tostring(flySpeed)
	end
end)

minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		mainFrame:TweenSize(UDim2.new(0, 230, 0, 34), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		contentFrame.Visible = false
		minimizeBtn.Text = "+"
	else
		mainFrame:TweenSize(UDim2.new(0, 230, 0, 150), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		contentFrame.Visible = true
		minimizeBtn.Text = "-"
	end
end)

toggleGuiBtn.MouseButton1Click:Connect(function()
	guiVisible = not guiVisible
	mainFrame.Visible = guiVisible
	toggleGuiBtn.Text = guiVisible and "HIDE" or "SHOW"
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)
