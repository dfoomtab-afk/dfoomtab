-- Delta Executor Script
-- Map: Escape Obby / هروب اوبي للارتداد الخلفي
-- Feature: Infinite Teleport to Trophy Spot (Auto Re-teleport after win/reset)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ماب الانكماش 🔴",
   LoadingTitle = "جاري تحميل السكربت...",
   LoadingSubtitle = "By Fumia Design",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false,
   Theme = "DarkRed"
})

-- Variables / المتغيرات
local AutoTrophy = false
local TrophyLocation = CFrame.new(5160, -8, 1460)

-- Main Tab / التبويب الرئيسي
local MainTab = Window:CreateTab("الرئيسية 🎮", 4483362458)

MainTab:CreateSection("تجميع الكأس المستمر")

-- 1. زر تجميع الكأس (تشغيل / إيقاف)
local TrophyToggle = MainTab:CreateToggle({
   Name = "تجميع الكأس 🏆",
   CurrentValue = false,
   Flag = "AutoTrophyLoop",
   Callback = function(Value)
      AutoTrophy = Value
      if AutoTrophy then
         Rayfield:Notify({
            Title = "تجميع الكأس",
            Content = "تم تفعيل النقل المستمر للكأس!",
            Duration = 2.5,
            Image = 4483362458,
         })
      end
   end,
})

-- Loop Logic: نقل مستمر ومكرر كل 1.5 ثانية حتى لو أعادتك اللعبة للربح/البداية
task.spawn(function()
   while task.wait(1.5) do
      if AutoTrophy then
         pcall(function()
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               -- ينقلك مباشرة وإجبارياً إلى موقع الكأس
               player.Character.HumanoidRootPart.CFrame = TrophyLocation
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
            player.Character.HumanoidRootPart.CFrame = TrophyLocation
         end
      end)
      Rayfield:Notify({
         Title = "Auto Win",
         Content = "تم الانتقال إلى الكأس!",
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
