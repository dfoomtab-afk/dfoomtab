-- Delta Executor Script
-- Map: Escape Obby / هروب اوبي للارتداد الخلفي
-- Theme: Dark Red & Black

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "هروب اوبي للارتداد الخلفي 🔴",
   LoadingTitle = "جاري تحميل السكربت...",
   LoadingSubtitle = "By Fumia Design",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false,
   Theme = "DarkRed" -- الطابع باللون الأحمر والأسود الفخم
})

-- Variables / المتغيرات
local AutoFarm = false
local TargetCFrame = CFrame.new(21177, 62, -765)

-- Main Tab / التبويب الرئيسي
local MainTab = Window:CreateTab("الرئيسية 🎮", 4483362458)

-- Section Title
MainTab:CreateSection("خيارات التجميع والفوز")

-- 1. زر تجميع 5K (تشغيل / إيقاف)
local FarmToggle = MainTab:CreateToggle({
   Name = "تجميع 5K",
   CurrentValue = false,
   Flag = "FarmToggle5K",
   Callback = function(Value)
      AutoFarm = Value
      if AutoFarm then
         Rayfield:Notify({
            Title = "تجميع 5K",
            Content = "تم تفعيل التجميع التلقائي بنجاح!",
            Duration = 2.5,
            Image = 4483362458,
         })
      end
   end,
})

-- Loop logic for Teleportation with 1.5 second delay
task.spawn(function()
   while task.wait(1.5) do
      if AutoFarm then
         pcall(function()
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               player.Character.HumanoidRootPart.CFrame = TargetCFrame
            end
         end)
      end
   end
end)

-- 2. زر Auto Win
MainTab:CreateButton({
   Name = "Auto Win",
   Callback = function()
      pcall(function()
         local player = game.Players.LocalPlayer
         if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = TargetCFrame
         end
      end)
      Rayfield:Notify({
         Title = "Auto Win",
         Content = "تم التكرار والذهاب لنقطة الفوز!",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

MainTab:CreateSection("إدارة الواجهة")

-- 3. زر تصغير السكربت (أيقونة عائمة)
MainTab:CreateButton({
   Name = "تصغير السكربت 🔲",
   Callback = function()
      Rayfield:Minimize()
   end,
})

-- 4. زر إغلاق السكربت بالكامل
MainTab:CreateButton({
   Name = "إغلاق السكربت ❌",
   Callback = function()
      Rayfield:Destroy()
   end,
})
