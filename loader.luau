if (getgenv().UC_LOADED) then
    return;
end;
getgenv().UC_LOADED = true;

if (identifyexecutor() == "Wave") then
    getgenv().gethui = function()
        return game:GetService("CoreGui");
    end;    
end;

if (game.GameId == 6035872082) then
    loadstring(game:HttpGet("https://pastebin.com/raw/kCnUz3x4"))();
end;
