-- Delta Executor Script
-- Feature: Auto Rebirth when reaching Target Level
-- Theme: Dark Red & Black

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "سكربت إعادة الولادة التلقائية 🔴",
   LoadingTitle = "جاري تحميل السكربت...",
   LoadingSubtitle = "By Fumia Design",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Theme = "DarkRed"
})

-- Variables / المتغيرات
local AutoRebirth = false
local TargetLevel = 100 -- المستوى المطلوب افتراضياً
local CurrentLevel = 0
local RebirthRemoteName = "Rebirth" -- الاسم الافتراضي لريموت الريبيرث

-- Tabs / التبويبات
local MainTab = Window:CreateTab("الرئيسية 🎮", 4483362458)
local SettingsTab = Window:CreateTab("الإعدادات ⚙️", 4483362458)

-- ==================== TAB 1: الرئيسية ====================
MainTab:CreateSection("إعادة الولادة التلقائية (Auto Rebirth)")

-- 1. عرض المستوى الحالي (Label)
local LevelLabel = MainTab:CreateLabel("المستوى الحالي: جاري القراءة...")

-- 2. زر تفعيل إعادة الولادة التلقائية
MainTab:CreateToggle({
   Name = "تفعيل إعادة الولادة التلقائية 🔄",
   CurrentValue = false,
   Flag = "AutoRebirthToggle",
   Callback = function(Value)
      AutoRebirth = Value
      if AutoRebirth then
         Rayfield:Notify({
            Title = "إعادة الولادة التلقائية",
            Content = "تم التفعيل! سيعاد التعيين فور الوصول للمستوى: " .. tostring(TargetLevel),
            Duration = 2.5,
            Image = 4483362458,
         })
      end
   end,
})

-- 3. تحديد المستوى المطلوب لإعادة الولادة
MainTab:CreateSlider({
   Name = "المستوى المطلوب للـ Rebirth 🎯",
   Range = {1, 10000},
   Increment = 1,
   Suffix = " Level",
   CurrentValue = TargetLevel,
   Flag = "TargetLevelSlider",
   Callback = function(Value)
      TargetLevel = Value
   end,
})

MainTab:CreateSection("إدارة الواجهة")

MainTab:CreateButton({
   Name = "تصغير السكربت 🔲",
   Callback = function()
      Rayfield:Minimize()
   end,
})

MainTab:CreateButton({
   Name = "إغلاق السكربت ❌",
   Callback = function()
      AutoRebirth = false
      Rayfield:Destroy()
   end,
})

-- ==================== TAB 2: الإعدادات ====================
SettingsTab:CreateSection("إعدادات الريموت (Remote Event)")

SettingsTab:CreateInput({
   Name = "اسم ريموت الـ Rebirth في الماب",
   PlaceholderText = "Rebirth / AutoRebirth / DoRebirth",
   RemoveTextOnFocus = false,
   Callback = function(Text)
      if Text and Text ~= "" then
         RebirthRemoteName = Text
      end
   end,
})

-- دالة للبحث عن مستوى اللاعب وقراءته من leaderstats
local function GetPlayerLevel()
   local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
   if leaderstats then
      -- بحث عن الخانة المسؤولة عن المستوى (Level أو Stage أو Lvl)
      local levelStat = leaderstats:FindFirstChild("Level") 
         or leaderstats:FindFirstChild("Stage") 
         or leaderstats:FindFirstChild("Lvl")
         or leaderstats:FindFirstChild("مستوى")
      
      if levelStat then
         return levelStat.Value
      end
   end
   return 0
end

-- دالة إرسال أمر إعادة الولادة للعبة
local function TriggerRebirth()
   pcall(function()
      -- البحث عن الريموت داخل ReplicatedStorage
      local remote = ReplicatedStorage:FindFirstChild(RebirthRemoteName, true)
      if remote and remote:IsA("RemoteEvent") then
         remote:FireServer()
      elseif remote and remote:IsA("RemoteFunction") then
         remote:InvokeServer()
      end
   end)
end

-- Loop Logic: المراقبة المستمرة للمستوى
task.spawn(function()
   while task.wait(0.5) do
      CurrentLevel = GetPlayerLevel()
      
      -- تحديث النص في الواجهة
      if LevelLabel then
         LevelLabel:Set("المستوى الحالي: " .. tostring(CurrentLevel))
      end
      
      -- التحقق من وصول المستوى المطلوب للتفعيل
      if AutoRebirth and CurrentLevel >= TargetLevel then
         TriggerRebirth()
         task.wait(1) -- مهلة لمنع التكرار السريع جداً أثناء تنفيذ الريبيرث
      end
   end
end)
