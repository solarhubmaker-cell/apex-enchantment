local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
	Title = "Title",
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

-- Main 탭 그룹박스 예시
local MainLeftGroup = Tabs.Main:AddLeftGroupbox("Left Group")
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
