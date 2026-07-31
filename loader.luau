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

-- UI 변수
local RageEnabled = false
local VoidSpamEnabled = false
local RageDelay = 1
local VoidDelay = 0.5

-- Rage UI
local RageGroup = Tabs.Main:AddLeftGroupbox("Rage")

RageGroup:AddToggle("RageToggle", {
    Text = "Enable RageBot",
    Default = false,
    Callback = function(v)
        RageEnabled = v
        if v then
            if Env.RageBot then
                Env.RageBot:Start()
            end
        else
            if Env.RageBot then
                Env.RageBot:Stop()
            end
        end
    end
})

RageGroup:AddToggle("VoidSpamToggle", {
    Text = "Enable Void Spam",
    Default = false,
    Callback = function(v)
        VoidSpamEnabled = v
        if v and Env.RageBot then
            Env.RageBot:StartVoidSpam(RageDelay, VoidDelay)
        elseif Env.RageBot then
            Env.RageBot:StopVoidSpam()
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
        if VoidSpamEnabled and Env.RageBot then
            Env.RageBot:UpdateVoidSpam(RageDelay, VoidDelay)
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
        if VoidSpamEnabled and Env.RageBot then
            Env.RageBot:UpdateVoidSpam(RageDelay, VoidDelay)
        end
    end
})

local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Visuals")
VisualsGroup:AddLabel("ESP Options Coming Soon")

local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc")
MiscGroup:AddLabel("Misc Options Coming Soon")

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function() 
    if Env.RageBot then
        Env.RageBot:Stop()
        Env.RageBot = nil
    end
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
-- RAGEBOT (게임 나가면 자동 종료)
-- ============================================

task.wait(0.5)

local Env = getgenv()

-- RageBot 초기화 (항상 새로 시작)
Env.RageBot = {}

do
    local RageBot = Env.RageBot
    local isRunning = false
    
    function RageBot:Start()
        if isRunning then return end
        isRunning = true
        print("RageBot Started!")
        
        self.Active = true
        self.Target = nil
        self.DesyncActive = false
        self.RageMode = true
        self.VoidSpamActive = false
        self.RageDelay = 1
        self.VoidDelay = 0.5
        self.HeartbeatConn = nil
        self.DesyncConn = nil
        self.RenderConn = nil
        self.DelayTask = nil
        self.VoidTask = nil
        self.OriginalFuncs = {}
        
        self:SetupWeaponHooks()
        self:SetupHeartbeat()
        self:SetupRageMode()
    end
    
    function RageBot:Stop()
        if not isRunning then return end
        isRunning = false
        print("RageBot Stopped!")
        
        self.Active = false
        self.RageMode = false
        self.VoidSpamActive = false
        
        if self.HeartbeatConn then
            self.HeartbeatConn:Disconnect()
            self.HeartbeatConn = nil
        end
        if self.DesyncConn then
            self.DesyncConn:Disconnect()
            self.DesyncConn = nil
        end
        if self.RenderConn then
            self.RenderConn:Disconnect()
            self.RenderConn = nil
        end
        if self.VoidTask then
            task.cancel(self.VoidTask)
            self.VoidTask = nil
        end
        if self.DelayTask then
            task.cancel(self.DelayTask)
            self.DelayTask = nil
        end
        
        pcall(function()
            RunService:UnbindFromRenderStep("RestoreDesync")
            RunService:UnbindFromRenderStep("RestoreRage")
            RunService:UnbindFromRenderStep("RestoreVoid")
        end)
        
        -- 원본 함수 복원
        for FuncName, OriginalFunc in pairs(self.OriginalFuncs) do
            local WeaponName = FuncName:gsub("_.*$", "")
            local MethodName = FuncName:match("_(.*)$") or "StartShooting"
            local ItemTypes = PlayerScripts.Modules:FindFirstChild("ItemTypes")
            if ItemTypes then
                local WeaponModule = ItemTypes:FindFirstChild(WeaponName)
                if WeaponModule then
                    local Success, Weapon = pcall(require, WeaponModule)
                    if Success and Weapon[MethodName] then
                        Weapon[MethodName] = OriginalFunc
                    end
                end
            end
        end
        self.OriginalFuncs = {}
    end
    
    -- 나머지 함수들 (SetupWeaponHooks, HookWeapon, FindTarget, SetupHeartbeat, StartDesync, StopDesync, SetupRageMode, StartVoidSpam, StopVoidSpam, UpdateVoidSpam)
    -- 여기에 전에 있던 함수들 모두 넣기...
    
end

-- 게임 나갈 때 자동 종료
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    if Env.RageBot then
        Env.RageBot:Stop()
        Env.RageBot = nil
    end
end)

game:GetService("CoreGui").ChildRemoved:Connect(function()
    if Env.RageBot then
        Env.RageBot:Stop()
        Env.RageBot = nil
    end
end)

print("RageBot Loaded! Use UI to control.")
