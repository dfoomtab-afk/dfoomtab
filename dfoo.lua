-- Delta Executor Script
-- Feature: Fast Attack / Custom Sword Attack Speed
-- Theme: Dark Red & Black

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "سكربت سرعة الهجوم 🔴",
   LoadingTitle = "جاري تحميل السكربت...",
   LoadingSubtitle = "By Fumia Design",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Theme = "DarkRed"
})

-- Variables / المتغيرات
local FastAttack = false
local AutoClick = false
local AttackDelay = 0.1 -- التأخير بالثواني (كلما قلّ زادت السرعة)

-- Main Tab / التبويب الرئيسي
local MainTab = Window:CreateTab("الرئيسية 🎮", 4483362458)

MainTab:CreateSection("تحكم سرعة الضرب")

-- 1. زر تفعيل الهجوم السريع
MainTab:CreateToggle({
   Name = "هجوم سريع بالسيف ⚔️",
   CurrentValue = false,
   Flag = "FastAttackToggle",
   Callback = function(Value)
      FastAttack = Value
      if FastAttack then
         Rayfield:Notify({
            Title = "الهجوم السريع",
            Content = "تم تفعيل الهجوم السريع بالسيف!",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end,
})

-- 2. زر الضرب التلقائي (Auto Clicker)
MainTab:CreateToggle({
   Name = "ضرب تلقائي مستمر 🖱️",
   CurrentValue = false,
   Flag = "AutoClickToggle",
   Callback = function(Value)
      AutoClick = Value
   end,
})

-- 3. شريط التحكم بسرعه الهجوم (Slider)
MainTab:CreateSlider({
   Name = "سرعة الضرب (التأخير بالثواني) ⚡",
   Range = {0, 1},
   Increment = 0.01,
   Suffix = " ثانية",
   CurrentValue = 0.1,
   Flag = "AttackSpeedSlider",
   Callback = function(Value)
      AttackDelay = Value
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
      FastAttack = false
      AutoClick = false
      Rayfield:Destroy()
   end,
})

-- دالة لتسريع تفعيل السلاح (Tool Activation)
local function SpeedUpTool(tool)
   if tool and tool:IsA("Tool") then
      -- إلغاء مهلة الانتظار الافتراضية للضربة
      if tool:FindFirstChild("Cooldown") then
         tool.Cooldown.Value = AttackDelay
      end
      
      -- تفعيل السلاح إجبارياً
      tool:Activate()
   end
end

-- Loop Logic: الهجوم السريع والضرب التلقائي
task.spawn(function()
   while true do
      if FastAttack or AutoClick then
         pcall(function()
            local char = LocalPlayer.Character
            if char then
               local tool = char:FindFirstChildOfClass("Tool")
               if tool then
                  SpeedUpTool(tool)
                  
                  -- إذا كان الضرب التلقائي مفعلاً، يتم إرسال كليك شاشة تلقائي
                  if AutoClick then
                     VirtualUser:Button1Down(Vector2.new(0, 0))
                     task.wait(0.01)
                     VirtualUser:Button1Up(Vector2.new(0, 0))
                  end
               end
            end
         end)
         task.wait(AttackDelay)
      else
         task.wait(0.2)
      end
   end
end)
