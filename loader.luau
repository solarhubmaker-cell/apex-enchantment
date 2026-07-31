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
local VoidGroup = Tabs.Main:AddRightGroupbox("Void Spam")

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
            if Env.RageBot then
                Env.RageBot.RageMode = true
                Env.RageBot.Active = true
                print("RageBot ON")
            end
        else
            if Env.RageBot then
                Env.RageBot.RageMode = false
                Env.RageBot.Active = false
                Env.RageBot:Shutdown()
                print("RageBot OFF")
            end
        end
    end
})

VoidGroup:AddToggle("VoidToggle", {
    Text = "Enable Void Spam",
    Default = false,
    Callback = function(v)
        VoidEnabled = v
        if v then
            if Env.RageBot then
                Env.RageBot:StartVoidSpam(RageDelay, VoidDelay)
            end
        else
            if Env.RageBot then
                Env.RageBot:StopVoidSpam()
            end
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
    end
})

VoidGroup:AddSlider("VoidDelay", {
    Text = "Void Delay (sec)",
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(v)
        VoidDelay = v
        if VoidEnabled and Env.RageBot then
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
        Env.RageBot:Shutdown()
        Env.RageBot:StopVoidSpam()
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
-- RAGEBOT + VOID SPAM (RIVALS)
-- ============================================

task.wait(0.5)

local Env = getgenv()

if Env.RageBot then
    pcall(function()
        Env.RageBot:Shutdown()
        Env.RageBot:StopVoidSpam()
    end)
    Env.RageBot = nil
    task.wait(0.3)
end

local Services = setmetatable({}, {
    __index = function(_, ServiceName)
        local Success, Service = pcall(function()
            return game:GetService(ServiceName)
        end)
        return Success and cloneref(Service) or nil
    end
})

local Players = Services.Players
local RunService = Services.RunService
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace = Services.Workspace
local UserInputService = Services.UserInputService

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerScripts = LocalPlayer.PlayerScripts

local Utility = nil
pcall(function()
    Utility = require(ReplicatedStorage.Modules.Utility)
end)

local CharacterParts = setmetatable({}, {
    __index = function(_, PartName)
        local Character = LocalPlayer.Character
        if not Character then return nil end
        if PartName == "Root" then
            return Character:FindFirstChild("HumanoidRootPart")
        elseif PartName == "Head" then
            return Character:FindFirstChild("Head")
        end
        return nil
    end
})

Env.RageBot = {}

do
    local RageBot = Env.RageBot

    function RageBot:Initialize()
        self.Active = true
        self.Target = nil
        self.DesyncActive = false
        self.RageMode = false
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
    end

    function RageBot:SetupWeaponHooks()
        local ItemTypes = PlayerScripts.Modules:FindFirstChild("ItemTypes")
        if not ItemTypes then 
            print("ItemTypes not found!")
            return 
        end

        local WeaponList = {
            "Gun", "Slingshot", "Bow", "Daggers", "Crossbow",
            "RPG", "Shotgun", "Sniper", "Flare Gun", "Spray"
        }

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
                
                if not Module.ClientFighter or not Module.ClientFighter.IsLocalPlayer then
                    return unpack(Results)
                end

                local TargetData = Results[3]
                if not TargetData or typeof(TargetData) ~= "table" then
                    return unpack(Results)
                end

                Results[4] = true

                local TargetPlayer = self.Target
                if not self.Active or not self.RageMode or not TargetPlayer or not TargetPlayer.Character then
                    return unpack(Results)
                end

                if not self.DesyncActive or self.CurrentTarget ~= TargetPlayer then
                    self:StartDesync(TargetPlayer)
                    task.wait(0.1)
                end

                if self.DelayTask then
                    task.cancel(self.DelayTask)
                    self.DelayTask = nil
                end

                local TargetHead = TargetPlayer.Character:FindFirstChild("Head")
                if not TargetHead then return unpack(Results) end

                if Utility and Utility.EncodeCFrame then
                    local HeadPos = TargetHead.Position
                    local AimPos = HeadPos - Vector3.new(0, 5, 0)
                    local AimCFrame = CFrame.lookAt(AimPos, HeadPos)
                    local RandomOffset = TargetHead.CFrame:ToObjectSpace(
                        CFrame.new(HeadPos + Vector3.new(math.random(), math.random(), math.random()))
                    )

                    TargetData[utf8.char(0)] = Utility:EncodeCFrame(CFrame.new(AimPos, HeadPos) * CFrame.Angles(AimCFrame:ToOrientation()))
                    TargetData[utf8.char(1)] = Utility:EncodeCFrame(CFrame.new(HeadPos) * CFrame.Angles(AimCFrame:ToOrientation()))
                    TargetData[utf8.char(2)] = TargetHead
                    TargetData[utf8.char(3)] = Utility:EncodeCFrame(RandomOffset)
                end

                self.DelayTask = task.delay(0.15, function()
                    self:StopDesync()
                end)

                return unpack(Results)
            end
        end

        if Weapon.Fire then
            self.OriginalFuncs[WeaponName .. "_Fire"] = Weapon.Fire

            Weapon.Fire = function(Module, ...)
                local Results = {self.OriginalFuncs[WeaponName .. "_Fire"](Module, ...)}
                
                if not Module.ClientFighter or not Module.ClientFighter.IsLocalPlayer then
                    return unpack(Results)
                end

                local TargetPlayer = self.Target
                if self.Active and self.RageMode and TargetPlayer and TargetPlayer.Character then
                    if not self.DesyncActive or self.CurrentTarget ~= TargetPlayer then
                        self:StartDesync(TargetPlayer)
                    end
                    if self.DelayTask then
                        task.cancel(self.DelayTask)
                        self.DelayTask = nil
                    end
                    self.DelayTask = task.delay(0.15, function()
                        self:StopDesync()
                    end)
                end

                return unpack(Results)
            end
        end

        if Weapon.Swing then
            self.OriginalFuncs[WeaponName .. "_Swing"] = Weapon.Swing

            Weapon.Swing = function(Module, ...)
                local TargetPlayer = self.Target
                if self.Active and self.RageMode and TargetPlayer and TargetPlayer.Character then
                    if not self.DesyncActive or self.CurrentTarget ~= TargetPlayer then
                        self:StartDesync(TargetPlayer)
                    end
                    if self.DelayTask then
                        task.cancel(self.DelayTask)
                        self.DelayTask = nil
                    end
                    self.DelayTask = task.delay(0.15, function()
                        self:StopDesync()
                    end)
                end
                return self.OriginalFuncs[WeaponName .. "_Swing"](Module, ...)
            end
        end

        if Weapon.Activate then
            self.OriginalFuncs[WeaponName .. "_Activate"] = Weapon.Activate

            Weapon.Activate = function(Module, ...)
                local TargetPlayer = self.Target
                if self.Active and self.RageMode and TargetPlayer and TargetPlayer.Character then
                    if not self.DesyncActive or self.CurrentTarget ~= TargetPlayer then
                        self:StartDesync(TargetPlayer)
                    end
                    if self.DelayTask then
                        task.cancel(self.DelayTask)
                        self.DelayTask = nil
                    end
                    self.DelayTask = task.delay(0.15, function()
                        self:StopDesync()
                    end)
                end
                return self.OriginalFuncs[WeaponName .. "_Activate"](Module, ...)
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
        if self.HeartbeatConn then
            self.HeartbeatConn:Disconnect()
            self.HeartbeatConn = nil
        end
        
        self.HeartbeatConn = RunService.Heartbeat:Connect(function()
            if not self.Active or not self.RageMode then return end
            self.Target = self:FindTarget()
        end)
    end

    function RageBot:StartDesync(TargetPlayer)
        if self.DesyncConn then
            self.DesyncConn:Disconnect()
        end

        self.DesyncActive = true
        self.CurrentTarget = TargetPlayer

        self.DesyncConn = RunService.Heartbeat:Connect(function()
            if not self.DesyncActive then return end

            local MyRoot = CharacterParts.Root
            if not MyRoot then return end

            local TargetRoot = TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not TargetRoot then
                self:StopDesync()
                return
            end

            local OldCFrame = MyRoot.CFrame
            local OldVelocity = MyRoot.Velocity
            local OldRotVelocity = MyRoot.RotVelocity

            MyRoot.CFrame = TargetRoot.CFrame * CFrame.new(0, -5, 0)

            RunService:BindToRenderStep("RestoreDesync", 101, function()
                MyRoot.CFrame = OldCFrame
                MyRoot.Velocity = OldVelocity
                MyRoot.RotVelocity = OldRotVelocity
                RunService:UnbindFromRenderStep("RestoreDesync")
            end)
        end)
    end

    function RageBot:StopDesync()
        self.DesyncActive = false
        self.CurrentTarget = nil

        if self.DesyncConn then
            self.DesyncConn:Disconnect()
            self.DesyncConn = nil
        end
        
        RunService:UnbindFromRenderStep("RestoreDesync")
    end

    function RageBot:SetupRageMode()
        if self.RenderConn then
            self.RenderConn:Disconnect()
            self.RenderConn = nil
        end
        
        self.RenderConn = RunService.RenderStepped:Connect(function()
            if not self.Active or not self.RageMode then return end
            if not self.Target or not self.Target.Character then return end

            local MyRoot = CharacterParts.Root
            if not MyRoot then return end

            local TargetRoot = self.Target.Character:FindFirstChild("HumanoidRootPart")
            if not TargetRoot then return end

            local OldCFrame = MyRoot.CFrame
            local OldVelocity = MyRoot.Velocity

            local Height = 10 + math.random(0, 3)
            local OffsetX = (math.random() - 0.5) * 5
            local OffsetZ = (math.random() - 0.5) * 5

            local TeleportPos = TargetRoot.Position + Vector3.new(OffsetX, Height, OffsetZ)

            MyRoot.CFrame = CFrame.new(TeleportPos)
            MyRoot.Velocity = Vector3.new(
                (math.random() - 0.5) * 200,
                math.random(100, 200),
                (math.random() - 0.5) * 200
            )

            RunService:BindToRenderStep("RestoreRage", 101, function()
                MyRoot.CFrame = OldCFrame
                MyRoot.Velocity = OldVelocity
                RunService:UnbindFromRenderStep("RestoreRage")
            end)
        end)
    end

    function RageBot:StartVoidSpam(rageDelay, voidDelay)
        if self.VoidSpamActive then return end
        self.VoidSpamActive = true
        self.RageDelay = rageDelay or 1
        self.VoidDelay = voidDelay or 0.5
        
        print("Void Spam Started! Rage: " .. self.RageDelay .. "s, Void: " .. self.VoidDelay .. "s")
        
        self.VoidTask = task.spawn(function()
            while self.VoidSpamActive do
                local MyRoot = CharacterParts.Root
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
        if not self.VoidSpamActive then return end
        self.VoidSpamActive = false
        
        if self.VoidTask then
            task.cancel(self.VoidTask)
            self.VoidTask = nil
        end
        
        RunService:UnbindFromRenderStep("RestoreVoid")
        print("Void Spam Stopped!")
    end

    function RageBot:UpdateVoidSpam(rageDelay, voidDelay)
        if not self.VoidSpamActive then return end
        self.RageDelay = rageDelay or self.RageDelay
        self.VoidDelay = voidDelay or self.VoidDelay
        print("Updated: Rage " .. self.RageDelay .. "s, Void " .. self.VoidDelay .. "s")
    end

    function RageBot:ToggleRageMode()
        self.RageMode = not self.RageMode
        return self.RageMode
    end

    function RageBot:Shutdown()
        self.Active = false
        self.RageMode = false
        self:StopVoidSpam()
        self:StopDesync()

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
        if self.DelayTask then 
            task.cancel(self.DelayTask) 
            self.DelayTask = nil
        end
        
        pcall(function()
            RunService:UnbindFromRenderStep("RestoreDesync")
            RunService:UnbindFromRenderStep("RestoreRage")
            RunService:UnbindFromRenderStep("RestoreVoid")
        end)

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
        print("RageBot Shutdown Complete!")
    end

    RageBot:Initialize()
    RageBot:SetupHeartbeat()
    RageBot:SetupRageMode()
end

_G.ToggleRage = function()
    return Env.RageBot:ToggleRageMode()
end

_G.ForceStopRage = function()
    if Env and Env.RageBot then
        pcall(function()
            Env.RageBot:Shutdown()
            Env.RageBot = nil
            print("RageBot Force Stopped!")
        end)
    end
end

pcall(function()
    LocalPlayer.OnTeleport:Connect(function()
        if Env.RageBot then
            Env.RageBot:Shutdown()
            Env.RageBot = nil
        end
    end)
end)

print("All Loaded! Use UI to control RageBot and Void Spam.")
print("RightShift to open menu.")
print("Toggle RageBot ON to activate.")
