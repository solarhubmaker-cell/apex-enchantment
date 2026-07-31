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
