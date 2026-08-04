-- Delta Executor Script
-- Map: قوة المعول (Pickaxe Power)
-- Theme: Dark Red & Black

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "قوة المعول 🔴",
   LoadingTitle = "جاري تحميل السكربت...",
   LoadingSubtitle = "By Fumia Design",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false,
   Theme = "DarkRed" -- ألوان حمراء وسوداء فخمة
})

-- Variables / المتغيرات
local AutoFarm = false
local TargetLocation = CFrame.new(1764, 5, 848)

-- Main Tab / التبويب الرئيسي
local MainTab = Window:CreateTab("الرئيسية 🎮", 4483362458)

MainTab:CreateSection("خيارات التنقيب والتجميع")

-- 1. زر التجميع التلقائي (تشغيل / إيقاف)
local FarmToggle = MainTab:CreateToggle({
   Name = "تجميع تلقائي ⛏️",
   CurrentValue = false,
   Flag = "PickaxeAutoFarm",
   Callback = function(Value)
      AutoFarm = Value
      if AutoFarm then
         Rayfield:Notify({
            Title = "التجميع التلقائي",
            Content = "تم تفعيل الانتقال المستمر لمكان المعول!",
            Duration = 2.5,
            Image = 4483362458,
         })
      end
   end,
})

-- Loop Logic: نقل مستمر ومكرر كل 1.5 ثانية إلى الاحداثيات المحددة
task.spawn(function()
   while task.wait(1.5) do
      if AutoFarm then
         pcall(function()
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               -- ينقلك مباشرة وإجبارياً إلى الإحداثيات الجديدة
               player.Character.HumanoidRootPart.CFrame = TargetLocation
            end
         end)
      end
   end
end)

-- 2. زر النقل الفوري (Teleport Button)
MainTab:CreateButton({
   Name = "نقل سريع للمكان",
   Callback = function()
      pcall(function()
         local player = game.Players.LocalPlayer
         if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = TargetLocation
         end
      end)
      Rayfield:Notify({
         Title = "نقل سريع",
         Content = "تم الانتقال إلى الاحداثيات بنجاح!",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

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
      Rayfield:Destroy()
   end,
})
