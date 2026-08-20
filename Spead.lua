-- 1. تفعيل حماية ضد الطرد أولاً
local rawmetatable = getrawmetatable(game)
local oldNamecall = rawmetatable.__namecall
setreadonly(rawmetatable, false)

rawmetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        return nil
    end
    return oldNamecall(self, ...)
end)
setreadonly(rawmetatable, true)

-- 2. تشغيل الواجهة وحسابات الحركة
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "معارك الجسر | آمن", HidePremium = false, SaveConfig = false})

local Tab = Window:MakeTab({
	Name = "الحركة الآمنة",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local SpeedBoost = 1.0
local SpeedToggle = false

Tab:AddToggle({
	Name = "تفعيل السرعة الذكية (CFrame)",
	Default = false,
	Callback = function(Value)
		SpeedToggle = Value
	end
})

Tab:AddSlider({
	Name = "نسبة الزيادة (موصى بـ 1.1 إلى 1.3)",
	Min = 1,
	Max = 2,
	Default = 1.2,
	Color = Color3.fromRGB(0, 255, 127),
	Increment = 0.1,
	ValueName = "x",
	Callback = function(Value)
		SpeedBoost = Value
	end    
})

game:GetService("RunService").RenderStepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if SpeedToggle and char and char:FindFirstChild("Humanoid") and char.Humanoid.MoveDirection.Magnitude > 0 then
        char:TranslateBy(char.Humanoid.MoveDirection * (SpeedBoost - 1) * 0.35)
    end
end)

OrionLib:Init()
