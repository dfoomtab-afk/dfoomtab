-- Roblox Fly Script for Delta Executor
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local flying = false
local flySpeed = 50 -- السرعة الافتراضية
local bodyGyro, bodyVelocity
local guiVisible = true

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaFlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 190)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, -95)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "Fly Menu | Delta"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Close Button (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -28, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- Toggle Fly Button
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -20, 0, 35)
flyBtn.Position = UDim2.new(0, 10, 0, 40)
flyBtn.Text = "تشغيل الطيران"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.BackgroundColor3 = Color3.fromRGB(45, 125, 245)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 14
flyBtn.Parent = mainFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 6)
flyCorner.Parent = flyBtn

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 85)
speedLabel.Text = "السرعة: 50"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.SourceSans
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = mainFrame

-- Speed Input (TextBox)
local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(1, -20, 0, 35)
speedInput.Position = UDim2.new(0, 10, 0, 110)
speedInput.PlaceholderText = "أدخل السرعة (مثال: 500 أو 5000)"
speedInput.Text = "50"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
speedInput.Font = Enum.Font.SourceSans
speedInput.TextSize = 14
speedInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = speedInput

-- Open/Hide Floating Button
local toggleGuiBtn = Instance.new("TextButton")
toggleGuiBtn.Size = UDim2.new(0, 45, 0, 45)
toggleGuiBtn.Position = UDim2.new(0, 15, 0.5, -22)
toggleGuiBtn.Text = "FLY"
toggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggleGuiBtn.Font = Enum.Font.SourceSansBold
toggleGuiBtn.TextSize = 14
toggleGuiBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleGuiBtn

-- Fly Mechanics
local function startFlying()
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local root = character.HumanoidRootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 9e4
	bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.cframe = root.CFrame
	bodyGyro.Parent = root

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.velocity = Vector3.new(0, 0.1, 0)
	bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.Parent = root

	character:FindFirstChildOfClass("Humanoid").PlatformStand = true

	task.spawn(function()
		while flying and character and character:FindFirstChild("HumanoidRootPart") do
			RunService.RenderStepped:Wait()
			bodyGyro.cframe = Camera.CFrame
			
			local moveVector = Vector3.new()
			local hum = character:FindFirstChildOfClass("Humanoid")
			if hum then
				moveVector = hum.MoveDirection
			end
			
			if moveVector.Magnitude > 0 then
				bodyVelocity.velocity = Camera.CFrame:VectorToWorldSpace(Vector3.new(moveVector.X, 0, moveVector.Z)) * flySpeed
			else
				bodyVelocity.velocity = Vector3.new(0, 0, 0)
			end
		end
	end)
end

local function stopFlying()
	local character = LocalPlayer.Character
	if character then
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
	end
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
	flying = false
end

-- Events
flyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		flyBtn.Text = "إيقاف الطيران"
		flyBtn.BackgroundColor3 = Color3.fromRGB(225, 60, 60)
		startFlying()
	else
		flyBtn.Text = "تشغيل الطيران"
		flyBtn.BackgroundColor3 = Color3.fromRGB(45, 125, 245)
		stopFlying()
	end
end)

speedInput.FocusLost:Connect(function()
	local val = tonumber(speedInput.Text)
	if val then
		flySpeed = val
		speedLabel.Text = "السرعة: " .. tostring(val)
	else
		speedInput.Text = tostring(flySpeed)
	end
end)

toggleGuiBtn.MouseButton1Click:Connect(function()
	guiVisible = not guiVisible
	mainFrame.Visible = guiVisible
end)

closeBtn.MouseButton1Click:Connect(function()
	stopFlying()
	screenGui:Destroy()
end)
