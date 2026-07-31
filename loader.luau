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

-- RageBot 토글
RageGroup:AddToggle("RageToggle", {
    Text = "Enable RageBot",
    Default = false,
    Callback = function(v)
        RageEnabled = v
        if v then
            _G.ToggleRage()
        else
            if Env.RageBot then
                Env.RageBot:Shutdown()
            end
        end
    end
})

-- Void Spam 토글
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

-- Rage 딜레이 슬라이더
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

-- Void 딜레이 슬라이더
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
local MainRightGroup = Tabs.Main:AddRightGroupbox("Right Group")

-- Visuals 탭 그룹박스 예시
local VisualsLeftGroup = Tabs.Visuals:AddLeftGroupbox("Visuals")

-- Misc 탭 그룹박스 예시
local MiscLeftGroup = Tabs.Misc:AddLeftGroupbox("Misc")

-- UI Settings (설정 및 언로드 메뉴)
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddButton("Unload", function() 
	Library:Unload() 
end)

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { 
	Default = "RightShift", 
	NoUI = true, 
	Text = "Menu keybind" 
})

Library.ToggleKeybind = Options.MenuKeybind

-- 테마 및 설정 저장소 로드
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()
-- ============================================
-- RAGEBOT + VOID SPAM CODE
-- ============================================
task.spawn(function()
if getgenv(). RageBot and getgenv(). RageBot., getgenv().RageBot: Shutdown() getgenv(). RageBot. Active = false getgenv(). RageBot. RageMode = false print("Previous RageBot stopped!")

end

local Services = setmetatable({}, {
    __index = function(_, ServiceName)
        local Success, Service = pcall(function()
            return game:GetService(ServiceName)
        end)
        return Success and cloneref(Service) or nil
    end
})

local Env = getgenv()
if Env.RageBot then
    Env.RageBot:Shutdown()
end

local Players = Services.Players
local RunService = Services.RunService
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace = Services.Workspace
local UserInputService = Services.UserInputService

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerScripts = LocalPlayer.PlayerScripts
local Utility = require(ReplicatedStorage.Modules.Utility)

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
        if not ItemTypes then return end

        local WeaponList = {
            "Gun", "Slingshot", "Bow", "Daggers", "Crossbow",
            "RPG", "Shotgun", "Sniper", "Flare Gun", "Spray"
        }

        for _, WeaponName in ipairs(WeaponList) do
            self:HookWeapon(WeaponName)
        end
    end

    function RageBot:HookWeapon(WeaponName)
        local ItemTypes = PlayerScripts.Modules:FindFirstChild("ItemTypes")
        if not ItemTypes then return end

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
                if not self.Active or not TargetPlayer or not TargetPlayer.Character then
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
                if self.Active and TargetPlayer and TargetPlayer.Character then
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
                if self.Active and TargetPlayer and TargetPlayer.Character then
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
                if self.Active and TargetPlayer and TargetPlayer.Character then
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
            if Dist >= ClosestDist then continue end

            ClosestDist = Dist
            ClosestPlayer = Player
        end

        return ClosestPlayer
    end

    function RageBot:SetupHeartbeat()
        self.HeartbeatConn = RunService.Heartbeat:Connect(function()
            if not self.Active then return end
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
    end

    function RageBot:SetupRageMode()
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
            Env.RageBot.Active = false
            Env.RageBot.RageMode = false
            print("RageBot Force Stopped!")
        end)
    end
end

print("RageBot + Void Spam Loaded!")
print("Use UI to control delays")
print("Type _G.ForceStopRage() to force stop")
