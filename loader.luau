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

local RageEnabled = false
local VoidSpamEnabled = false
local RageDelay = 1
local VoidDelay = 0.5

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

print("UI Loaded! Loading RageBot...")

-- ============================================
-- RAGEBOT + VOID SPAM (RIVALS 전용)
-- ============================================

task.wait(0.5)

local Env = getgenv()

if Env.RageBot then
    pcall(function()
        Env.RageBot:Stop()
    end)
    Env.RageBot = nil
    task.wait(0.3)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerScripts = LocalPlayer.PlayerScripts

local Utility = nil
pcall(function()
    Utility = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utility"))
end)

local CharacterParts = {
    Root = function()
        local char = LocalPlayer.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end,
    Head = function()
        local char = LocalPlayer.Character
        return char and char:FindFirstChild("Head")
    end
}

Env.RageBot = {}

do
    local RageBot = Env.RageBot
    local isRunning = false
    local isVoidRunning = false
    
    function RageBot:Start()
        if isRunning then return end
        isRunning = true
        print("RageBot Started!")
        
        self.Active = true
        self.RageMode = true
        self.Target = nil
        self.HeartbeatConn = nil
        self.OriginalFuncs = {}
        
        self:SetupWeaponHooks()
        self:SetupHeartbeat()
    end
    
    function RageBot:Stop()
        if not isRunning then return end
        isRunning = false
        print("RageBot Stopped!")
        
        self.Active = false
        self.RageMode = false
        self.Target = nil
        
        if self.HeartbeatConn then
            self.HeartbeatConn:Disconnect()
            self.HeartbeatConn = nil
        end
        
        -- 원본 함수 복원
        for FuncName, OriginalFunc in pairs(self.OriginalFuncs) do
            local WeaponName = FuncName:gsub("_.*$", "")
            local MethodName = FuncName:match("_(.*)$") or "StartShooting"
            local ItemTypes = PlayerScripts:FindFirstChild("Modules")
            if ItemTypes then
                ItemTypes = ItemTypes:FindFirstChild("ItemTypes")
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
        end
        self.OriginalFuncs = {}
    end
    
    function RageBot:SetupWeaponHooks()
        local Modules = PlayerScripts:FindFirstChild("Modules")
        if not Modules then 
            print("Modules not found!")
            return 
        end
        
        local ItemTypes = Modules:FindFirstChild("ItemTypes")
        if not ItemTypes then 
            print("ItemTypes not found!")
            return 
        end
        
        local WeaponList = {"Gun", "Slingshot", "Bow", "Daggers", "Crossbow", "RPG", "Shotgun", "Sniper", "Flare Gun", "Spray"}
        
        for _, WeaponName in ipairs(WeaponList) do
            self:HookWeapon(WeaponName, ItemTypes)
        end
    end
    
    function RageBot:HookWeapon(WeaponName, ItemTypes)
        local WeaponModule = ItemTypes:FindFirstChild(WeaponName)
        if not WeaponModule then return end
        
        local Success, Weapon = pcall(require, WeaponModule)
        if not Success then return end
        
        if Weapon.StartShooting then
            self.OriginalFuncs[WeaponName .. "_StartShooting"] = Weapon.StartShooting
            Weapon.StartShooting = function(Module, ...)
                local Results = {self.OriginalFuncs[WeaponName .. "_StartShooting"](Module, ...)}
                
                if not self.Active or not self.RageMode then
                    return unpack(Results)
                end
                
                local TargetPlayer = self.Target
                if not TargetPlayer or not TargetPlayer.Character then
                    return unpack(Results)
                end
                
                local TargetHead = TargetPlayer.Character:FindFirstChild("Head")
                if not TargetHead then return unpack(Results) end
                
                Results[4] = true
                
                if Utility and Utility.EncodeCFrame then
                    local HeadPos = TargetHead.Position
                    local AimPos = HeadPos - Vector3.new(0, 5, 0)
                    local AimCFrame = CFrame.lookAt(AimPos, HeadPos)
                    
                    local TargetData = Results[3]
                    if TargetData and typeof(TargetData) == "table" then
                        TargetData[utf8.char(0)] = Utility:EncodeCFrame(CFrame.new(AimPos, HeadPos) * CFrame.Angles(AimCFrame:ToOrientation()))
                        TargetData[utf8.char(1)] = Utility:EncodeCFrame(CFrame.new(HeadPos) * CFrame.Angles(AimCFrame:ToOrientation()))
                        TargetData[utf8.char(2)] = TargetHead
                    end
                end
                
                return unpack(Results)
            end
        end
    end
    
    function RageBot:FindTarget()
        local MyCharacter = LocalPlayer.Character
        if not MyCharacter then return nil end
        
        local MyRoot = MyCharacter:FindFirstChild("HumanoidRootPart")
        if not MyRoot then return nil end
        
        local ClosestPlayer = nil
        local ClosestDist = math.huge
        
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player == LocalPlayer then continue end
            if Player:GetAttribute("TeamID") == LocalPlayer:GetAttribute("TeamID") then continue end
            
            local Character = Player.Character
            if not Character then continue end
            
            local Root = Character:FindFirstChild("HumanoidRootPart")
            local Head = Character:FindFirstChild("Head")
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            
            if not Root or not Head or not Humanoid or Humanoid.Health <= 0 then continue end
            
            local Dist = (MyRoot.Position - Root.Position).Magnitude
            if Dist < ClosestDist then
                ClosestDist = Dist
                ClosestPlayer = Player
            end
        end
        
        return ClosestPlayer
    end
    
    function RageBot:SetupHeartbeat()
        self.HeartbeatConn = RunService.Heartbeat:Connect(function()
            if not self.Active or not self.RageMode then return end
            self.Target = self:FindTarget()
        end)
    end
    
    function RageBot:StartVoidSpam(rageDelay, voidDelay)
        if isVoidRunning then return end
        isVoidRunning = true
        
        self.RageDelay = rageDelay or 1
        self.VoidDelay = voidDelay or 0.5
        self.VoidSpamActive = true
        
        print("Void Spam Started! Rage: " .. self.RageDelay .. "s, Void: " .. self.VoidDelay .. "s")
        
        self.VoidTask = task.spawn(function()
            while self.VoidSpamActive do
                local MyRoot = CharacterParts.Root()
                if not MyRoot then
                    task.wait(0.5)
                    continue
                end
                
                task.wait(self.RageDelay)
                
                local voidPos = Vector3.new(999999999999, 99999999999, 999999999999)
                local OldCFrame = MyRoot.CFrame
                local OldVelocity = MyRoot.Velocity
                local OldRotVelocity = MyRoot.RotVelocity
                
                MyRoot.CFrame = CFrame.new(voidPos)
                MyRoot.Velocity = Vector3.new(0, 0, 0)
                MyRoot.RotVelocity = Vector3.new(0, 0, 0)
                
                RunService:BindToRenderStep("RestoreVoid", 101, function()
                    MyRoot.CFrame = OldCFrame
                    MyRoot.Velocity = OldVelocity
                    MyRoot.RotVelocity = OldRotVelocity
                    RunService:UnbindFromRenderStep("RestoreVoid")
                end)
                
                task.wait(self.VoidDelay)
            end
        end)
    end
    
    function RageBot:StopVoidSpam()
        if not isVoidRunning then return end
        isVoidRunning = false
        self.VoidSpamActive = false
        
        if self.VoidTask then
            task.cancel(self.VoidTask)
            self.VoidTask = nil
        end
        
        print("Void Spam Stopped!")
    end
    
    function RageBot:UpdateVoidSpam(rageDelay, voidDelay)
        if not self.VoidSpamActive then return end
        self.RageDelay = rageDelay or self.RageDelay
        self.VoidDelay = voidDelay or self.VoidDelay
        print("Updated: Rage " .. self.RageDelay .. "s, Void " .. self.VoidDelay .. "s")
    end
end

-- 게임 나가면 자동 종료
pcall(function()
    LocalPlayer.OnTeleport:Connect(function()
        if Env.RageBot then
            Env.RageBot:Stop()
            Env.RageBot:StopVoidSpam()
            Env.RageBot = nil
        end
    end)
end)

print("RageBot Loaded! Use UI to control.")
print("Enable RageBot toggle to activate.")
