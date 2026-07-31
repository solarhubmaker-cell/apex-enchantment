local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Apex Enchantment",
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    UnlockMouseWhileOpen = true,
    NotifySide = "Left",
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab("Main"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

local RageGroup = Tabs.Main:AddLeftGroupbox("Rage")

local RageEnabled = false
local VoidEnabled = false
local RageDelay = 1
local VoidDelay = 0.5

RageGroup:AddToggle("RageToggle", {
    Text = "Enable RageBot",
    Default = false,
    Callback = function(v)
        RageEnabled = v
        if v then
            StartRageBot()
        else
            StopRageBot()
        end
    end
})

RageGroup:AddToggle("VoidToggle", {
    Text = "Enable Void Spam",
    Default = false,
    Callback = function(v)
        VoidEnabled = v
        if v then
            StartVoidSpam()
        else
            StopVoidSpam()
        end
    end
})

RageGroup:AddSlider("RageDelay", {
    Text = "Rage Delay (sec)",
    Default = 1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(v)
        RageDelay = v
        if VoidEnabled then
            UpdateVoidSpam()
        end
    end
})

RageGroup:AddSlider("VoidDelay", {
    Text = "Void Delay (sec)",
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(v)
        VoidDelay = v
        if VoidEnabled then
            UpdateVoidSpam()
        end
    end
})

local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Visuals")
VisualsGroup:AddLabel("ESP Coming Soon")

local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc")
MiscGroup:AddLabel("Misc Coming Soon")

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function() 
    StopRageBot()
    StopVoidSpam()
    Library:Unload() 
end)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("ApexEnchantment")
SaveManager:SetFolder("ApexEnchantment/Rivals")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

print("UI Loaded!")

-- ============================================
-- RAGEBOT CORE
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local RageBotActive = false
local VoidActive = false
local VoidTask = nil
local Target = nil
local HeartbeatConn = nil
local OriginalFuncs = {}

-- Find Target
local function FindTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local closest = nil
    local closestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if player:GetAttribute("TeamID") == LocalPlayer:GetAttribute("TeamID") then continue end
        
        local pChar = player.Character
        if not pChar then continue end
        
        local pRoot = pChar:FindFirstChild("HumanoidRootPart")
        local pHead = pChar:FindFirstChild("Head")
        local pHumanoid = pChar:FindFirstChildWhichIsA("Humanoid")
        
        if not pRoot or not pHead or not pHumanoid or pHumanoid.Health <= 0 then continue end
        
        local dist = (root.Position - pRoot.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = player
        end
    end
    
    return closest
end

-- Setup Heartbeat
local function SetupHeartbeat()
    if HeartbeatConn then
        HeartbeatConn:Disconnect()
        HeartbeatConn = nil
    end
    
    HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not RageBotActive then return end
        Target = FindTarget()
    end)
end

-- Hook Weapons
local function HookWeapons()
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    if not ps then return end
    
    local modules = ps:FindFirstChild("Modules")
    if not modules then return end
    
    local itemTypes = modules:FindFirstChild("ItemTypes")
    if not itemTypes then return end
    
    local weapons = {"Gun", "Slingshot", "Bow", "Daggers", "Crossbow", "RPG", "Shotgun", "Sniper", "Flare Gun", "Spray"}
    
    for _, name in ipairs(weapons) do
        local module = itemTypes:FindFirstChild(name)
        if module then
            local success, weapon = pcall(require, module)
            if success and weapon and weapon.StartShooting then
                local key = name .. "_StartShooting"
                OriginalFuncs[key] = weapon.StartShooting
                
                weapon.StartShooting = function(self, ...)
                    local results = {OriginalFuncs[key](self, ...)}
                    
                    if RageBotActive and Target and Target.Character then
                        local head = Target.Character:FindFirstChild("Head")
                        if head then
                            results[4] = true
                        end
                    end
                    
                    return unpack(results)
                end
            end
        end
    end
end

-- Start RageBot
function StartRageBot()
    if RageBotActive then return end
    RageBotActive = true
    print("RageBot Started!")
    
    HookWeapons()
    SetupHeartbeat()
end

-- Stop RageBot
function StopRageBot()
    if not RageBotActive then return end
    RageBotActive = false
    Target = nil
    print("RageBot Stopped!")
    
    if HeartbeatConn then
        HeartbeatConn:Disconnect()
        HeartbeatConn = nil
    end
    
    -- Restore original functions
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    if ps then
        local modules = ps:FindFirstChild("Modules")
        if modules then
            local itemTypes = modules:FindFirstChild("ItemTypes")
            if itemTypes then
                for key, func in pairs(OriginalFuncs) do
                    local name = key:gsub("_StartShooting", "")
                    local module = itemTypes:FindFirstChild(name)
                    if module then
                        local success, weapon = pcall(require, module)
                        if success then
                            weapon.StartShooting = func
                        end
                    end
                end
            end
        end
    end
    OriginalFuncs = {}
end

-- Start Void Spam
function StartVoidSpam()
    if VoidActive then return end
    VoidActive = true
    print("Void Spam Started!")
    
    VoidTask = task.spawn(function()
        while VoidActive do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                task.wait(RageDelay)
                
                local oldCF = root.CFrame
                local oldVel = root.Velocity
                local oldRot = root.RotVelocity
                
                root.CFrame = CFrame.new(999999999999, 99999999999, 999999999999)
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
                
                RunService:BindToRenderStep("RestoreVoid", 101, function()
                    root.CFrame = oldCF
                    root.Velocity = oldVel
                    root.RotVelocity = oldRot
                    RunService:UnbindFromRenderStep("RestoreVoid")
                end)
                
                task.wait(VoidDelay)
            else
                task.wait(0.5)
            end
        end
    end)
end

-- Stop Void Spam
function StopVoidSpam()
    if not VoidActive then return end
    VoidActive = false
    
    if VoidTask then
        task.cancel(VoidTask)
        VoidTask = nil
    end
    
    RunService:UnbindFromRenderStep("RestoreVoid")
    print("Void Spam Stopped!")
end

-- Update Void Spam
function UpdateVoidSpam()
    print("Updated: Rage " .. RageDelay .. "s, Void " .. VoidDelay .. "s")
end

-- Auto stop on game exit
pcall(function()
    LocalPlayer.OnTeleport:Connect(function()
        StopRageBot()
        StopVoidSpam()
    end)
end)

-- Force stop function
_G.ForceStop = function()
    StopRageBot()
    StopVoidSpam()
    print("All stopped!")
end

print("RageBot + Void Spam Loaded!")
print("Use UI to control. Type _G.ForceStop() to force stop.")
