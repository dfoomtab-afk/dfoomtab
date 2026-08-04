-- Delta Executor Script
-- Map: قوة المعول (Pickaxe Power)
-- Feature: Smooth Walking to Coordinates with Adjustable Speed

local TweenService = game:GetService("TweenService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "قوة المعول 🔴",
   LoadingTitle = "جاري تحميل السكربت...",
   LoadingSubtitle = "By Fumia Design",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Theme = "DarkRed"
})

-- Variables / المتغيرات
local AutoWalk = false
local WalkSpeed = 30 -- السرعة الافتراضية للمشي التلقائي
local TargetLocation = Vector3.new(1764, 5, 848)
local CurrentTween = nil

-- Main Tab / التبويب الرئيسي
local MainTab = Window:CreateTab("الرئيسية 🎮", 4483362458)

MainTab:CreateSection("تحكم المشي التلقائي")

-- 1. زر المشي التلقائي (تشغيل / إيقاف)
local WalkToggle = MainTab:CreateToggle({
   Name = "مشي تلقائي للإحداثيات 🚶‍♂️",
   CurrentValue = false,
   Flag = "AutoWalkToggle",
   Callback = function(Value)
      AutoWalk = Value
      if not AutoWalk and CurrentTween then
         CurrentTween:Cancel() -- إيقاف المشي فوراً عند تعطيل الزر
      end
   end,
})

-- 2. شريط التحكم بسرعه المشي (Slider)
MainTab:CreateSlider({
   Name = "سرعة المشي التلقائي ⚡",
   Range = {10, 150},
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = 30,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      WalkSpeed = Value
   end,
})

-- Loop Logic: حساب المسافة والمشي السلس تجاه الهدف وإعادة التكرار
task.spawn(function()
   while task.wait(0.5) do
      if AutoWalk then
         pcall(function()
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local root = player.Character.HumanoidRootPart
               local distance = (TargetLocation - root.Position).Magnitude
               
               -- إذا كان اللاعب بعيداً عن الهدف، يتم البدء بالمشي
               if distance > 3 then
                  local travelTime = distance / WalkSpeed
                  local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
                  
                  CurrentTween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(TargetLocation)})
                  CurrentTween:Play()
                  CurrentTween.Completed:Wait() -- الانتظار حتى يصل للمكان
                  
                  task.wait(0.5) -- استراحة بسيطة بعد الوصول قبل التكرار عند إعادة التعيين/الربح
               end
            end
         end)
      end
   end
end)

MainTab:CreateSection("إدارة الواجهة")

-- 3. زر تصغير السكربت
MainTab:CreateButton({
   Name = "تصغير السكربت 🔲",
   Callback = function()
      Rayfield:Minimize()
   end,
})

-- 4. زر إغلاق السكربت
MainTab:CreateButton({
   Name = "إغلاق السكربت ❌",
   Callback = function()
      if CurrentTween then CurrentTween:Cancel() end
      Rayfield:Destroy()
   end,
})
