-- سكربت لمعرفة موقعك الحالي وطباعته
local char = game:GetService("Players").LocalPlayer.Character
if char and char:FindFirstChild("HumanoidRootPart") then
    local pos = char.HumanoidRootPart.Position
    local x = math.floor(pos.X)
    local y = math.floor(pos.Y)
    local z = math.floor(pos.Z)
    
    print("Coordinates: " .. x .. ", " .. y .. ", " .. z)
    
    -- نسخت الإحداثيات للحافظة إذا كان المشغل يدعم ذلك
    if setclipboard then
        setclipboard(x .. ", " .. y .. ", " .. z)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "تم نسخ الإحداثيات!";
            Text = x .. ", " .. y .. ", " .. z;
            Duration = 5;
        })
    end
end
