local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

task.spawn(function()
    pcall(function()
        local rf = game:GetService("ReplicatedFirst")
        local lp = Players.LocalPlayer

        local fake = Instance.new("RemoteEvent")
        fake.Name = "ClientAlert"
        fake.Parent = lp

        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if not checkcaller() then
                if m == "WaitForChild" and select(1, ...) == "ClientAlert" then return fake end
                if self == lp and (m == "Kick" or m == "kick") then return end
                if m:lower():find("kick") or m == "Shutdown" then return end
                if m == "FireServer" and self == fake then return end
            end
            return oldNamecall(self, ...)
        end)

        local ls3 = rf:WaitForChild("LocalScript3", 10)
        for _, f in getgc(false) do
            if typeof(f) == "function" then
                local ok, e = pcall(getfenv, f)
                if ok and e then
                    local scr = rawget(e, "script")
                    if scr and (scr == ls3 or tostring(scr):find("LoadingScreen")) then
                        local ok2, cs = pcall(debug.getconstants, f)
                        if ok2 then
                            for _, k in cs do
                                if typeof(k) == "string" and (k:find("TakeTheL") or k:find("ban") or k:find("kick")) then
                                    hookfunction(f, function() end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end)

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
local ShootGroup = Tabs.Main:AddRightGroupbox("Shoot")

-- ============================================
-- RAGEBOT UI
-- ============================================

local RageEnabled = false
local VoidEnabled = false
local RageDelay = 1
local VoidDelay = 0.5
local TargetPart = "Head"
local Accuracy = 100

RageGroup:AddToggle("RageToggle", {
    Text = "Enable RageBot",
    Default = false,
    Callback = function(v)
        RageEnabled = v
        if v then
            _G.ToggleRage()
            print("RageBot ON")
        else
            if Env.RageBot then
                Env.RageBot:Shutdown()
                Env.RageBot.Active = false
                Env.RageBot.RageMode = false
                print("RageBot OFF")
            end
        end
    end
})

RageGroup:AddToggle("VoidToggle", {
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

RageGroup:AddSlider("VoidDelay", {
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

RageGroup:AddDropdown("TargetPartDropdown", {
    Text = "Aim Target",
    Values = {"Head", "Body", "Random"},
    Default = 1,
    Callback = function(v)
        TargetPart = v
    end
})

RageGroup:AddSlider("AccuracySlider", {
    Text = "Accuracy (%)",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        Accuracy = v
    end
})

-- ============================================
-- RAPID FIRE
-- ============================================

local RapidFireEnabled = false
local RapidFireSpeed = 0.05
local OriginalItems = {}

local function SaveOriginalItems()
    local Storage = game:GetService("ReplicatedStorage")
    local Items = require(Storage.Modules.ItemLibrary).Items
    for name, data in pairs(Items) do
        if typeof(data) == "table" then
            OriginalItems[name] = {}
            for key, value in pairs(data) do
                OriginalItems[name][key] = value
            end
        end
    end
end

local function RestoreItems()
    local Storage = game:GetService("ReplicatedStorage")
    local Items = require(Storage.Modules.ItemLibrary).Items
    for name, data in pairs(Items) do
        if typeof(data) == "table" and OriginalItems[name] then
            for key, value in pairs(OriginalItems[name]) do
                data[key] = value
            end
        end
    end
end

local function ModifyWeapons()
    local Storage = game:GetService("ReplicatedStorage")
    local Items = require(Storage.Modules.ItemLibrary).Items
    local gunExceptions = {
        ["Sniper"] = true,
        ["Crossbow"] = true,
        ["Bow"] = true,
        ["RPG"] = true,
    }
    for name, data in pairs(Items) do
        if typeof(data) == "table" then
            if typeof(data) == "table" and not gunExceptions[name] then
                if RapidFireEnabled then
                    if data.ShootCooldown then data.ShootCooldown = RapidFireSpeed end
                    if data.ShootBurstCooldown then data.ShootBurstCooldown = RapidFireSpeed end
                end
            end
            if RapidFireEnabled then
                if data.AttackCooldown then data.AttackCooldown = RapidFireSpeed end
                if data.SwingCooldown then data.SwingCooldown = RapidFireSpeed end
                if data.MeleeCooldown then data.MeleeCooldown = RapidFireSpeed end
                if data.Cooldown then data.Cooldown = RapidFireSpeed end
                if data.RecoveryTime then data.RecoveryTime = RapidFireSpeed end
                if data.ResetTime then data.ResetTime = RapidFireSpeed end
            end
        end
    end
end

_G.ToggleRapidFire = function()
    RapidFireEnabled = not RapidFireEnabled
    if RapidFireEnabled then
        SaveOriginalItems()
        ModifyWeapons()
    else
        RestoreItems()
    end
    return RapidFireEnabled
end

_G.SetRapidFireSpeed = function(speed)
    RapidFireSpeed = speed
    if RapidFireEnabled then
        ModifyWeapons()
    end
end

ShootGroup:AddToggle("RapidFireToggle", {
    Text = "Rapid Fire",
    Default = false,
    Callback = function(v)
        if v then
            _G.ToggleRapidFire()
        else
            _G.ToggleRapidFire()
        end
    end
})

ShootGroup:AddSlider("RapidFireSpeed", {
    Text = "Fire Speed (sec)",
    Default = 0.05,
    Min = 0.01,
    Max = 0.5,
    Rounding = 2,
    Callback = function(v)
        _G.SetRapidFireSpeed(v)
    end
})

-- ============================================
-- SKIN UNLOCKER (건들지 않음 - 그대로)
-- ============================================

local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Skin Unlocker")
local SkinActive = false
local SkinThread = nil

VisualsGroup:AddToggle("SkinUnlockerToggle", {
    Text = "Unlock All Skins",
    Default = false,
    Callback = function(v)
        SkinActive = v
        if v then
            -- AC Bypass
            local _stbl; _stbl = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
                if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
                    local tr = debug.traceback()
                    if tr:find("MiscellaneousController") then
                        return _stbl({1,2,3}, {})
                    end
                end
                return _stbl(tbl, mt)
            end))

            coroutine.wrap(function()
                pcall(function()
                    local function _proc(o)
                        pcall(function()
                            if o:IsA("LocalScript") or o:IsA("ModuleScript") then
                                local _s, nm = pcall(function() return o.Name:lower() end)
                                if not _s or not nm then return end
                                local _tags = {"anticheat","ac","detection","ban","kick","security","moderation"}
                                for _i = 1, #_tags do
                                    if nm:find(_tags[_i]) then
                                        pcall(function() o.Disabled = true end)
                                        break
                                    end
                                end
                            end
                        end)
                    end
                    pcall(function()
                        local _desc = game:GetDescendants()
                        for _i = 1, #_desc do _proc(_desc[_i]) end
                    end)
                    pcall(function() game.DescendantAdded:Connect(_proc) end)
                end)
                pcall(function()
                    local _nc = game:GetService("NetworkClient")
                    if not _nc then return end
                    _nc.ChildAdded:Connect(function(ch)
                        pcall(function()
                            local _ok, _n = pcall(function() return ch.Name:lower() end)
                            if _ok and _n then
                                if _n:find("anticheat") or _n:find("detection") then
                                    pcall(function() ch:Destroy() end)
                                end
                            end
                        end)
                    end)
                end)
            end)()

            task.wait(4)

            local _plrs = game:GetService("Players")
            local _rs = game:GetService("ReplicatedStorage")
            local _http = game:GetService("HttpService")
            local _lp = _plrs.LocalPlayer
            local _pscripts = _lp.PlayerScripts
            local _ctrl = _pscripts.Controllers
            local _mods = _rs:WaitForChild("Modules", 10)

            local _enumLib = require(_mods:WaitForChild("EnumLibrary", 10))
            if _enumLib then pcall(function() _enumLib:WaitForEnumBuilder() end) end

            local _cosLib = require(_mods:WaitForChild("CosmeticLibrary", 10))
            local _datCtrl = require(_ctrl:WaitForChild("PlayerDataController", 10))

            local _eq, _favs = {}, {}

            local _allTypes = {
                "Skin", "Wrap", "Charm", "Dance", "Emote",
                "Finisher", "FinisherEffect", "FinisherSound", "KillEffect"
            }

            local function _isAllType(cosObj)
                if not cosObj then return false end
                for _, t in ipairs(_allTypes) do
                    if cosObj.Type == t then return true end
                end
                return false
            end

            local _cfgFile = "rivals_unlocker_config.json"
            local _saveLock = false

            local function _mkCosmetic(nm, ctype)
                local _base = _cosLib.Cosmetics[nm]
                if not _base then return nil end
                local _d = {}
                for k, v in pairs(_base) do _d[k] = v end
                _d.Name = nm
                _d.Type = _d.Type or ctype
                _d.Seed = _d.Seed or math.random(1, 1000000)
                if _enumLib then
                    local _s, _eid = pcall(_enumLib.ToEnum, _enumLib, nm)
                    if _s and _eid then
                        _d.Enum = _eid
                        _d.ObjectID = _d.ObjectID or _eid
                    end
                end
                return _d
            end

            local function _loadCfg()
                if not isfile or not readfile then return end
                local _ok1, _ex = pcall(isfile, _cfgFile)
                if not _ok1 or not _ex then return end
                local _ok2, _raw = pcall(readfile, _cfgFile)
                if not _ok2 or not _raw or _raw == "" then return end
                local _ok3, _dec = pcall(_http.JSONDecode, _http, _raw)
                if not _ok3 or not _dec then return end
                if _dec.favorites then _favs = _dec.favorites end
                if _dec.equipped then
                    _eq = {}
                    for wn, cos in pairs(_dec.equipped) do
                        _eq[wn] = {}
                        for ct, sd in pairs(cos) do
                            if sd and sd.Name and _cosLib.Cosmetics[sd.Name] then
                                local _cloned = _mkCosmetic(sd.Name, ct)
                                if _cloned then _eq[wn][ct] = _cloned end
                            end
                        end
                        if not next(_eq[wn]) then _eq[wn] = nil end
                    end
                end
            end

            local function _saveCfg()
                if not writefile or _saveLock then return end
                _saveLock = true
                task.spawn(function()
                    task.wait(1)
                    local _out = {}
                    for wn, cos in pairs(_eq) do
                        _out[wn] = {}
                        for ct, cd in pairs(cos) do
                            if cd and cd.Name then _out[wn][ct] = { Name = cd.Name } end
                        end
                    end
                    local _ok, _enc = pcall(_http.JSONEncode, _http, { equipped = _out, favorites = _favs })
                    if _ok then pcall(writefile, _cfgFile, _enc) end
                    _saveLock = false
                end)
            end

            _loadCfg()

            _cosLib.OwnsCosmetic = function(self, inv, nm, wep)
                local c = _cosLib.Cosmetics[nm]
                if c and _isAllType(c) then return true end
                return false
            end

            _cosLib.OwnsCosmeticNormally = function(self, inv, nm, wep)
                local c = _cosLib.Cosmetics[nm]
                if c and _isAllType(c) then return true end
                return false
            end

            _cosLib.OwnsCosmeticUniversally = function(self, inv, nm, wep)
                local c = _cosLib.Cosmetics[nm]
                if c and _isAllType(c) then return true end
                return false
            end

            _cosLib.OwnsCosmeticForWeapon = function(self, inv, nm, wep)
                local c = _cosLib.Cosmetics[nm]
                if c and _isAllType(c) then return true end
                return false
            end

            local _origGet = _datCtrl.Get
            _datCtrl.Get = function(self, key)
                local _val = _origGet(self, key)
                if key == "CosmeticInventory" then
                    local _prx = {}
                    if _val then
                        for k, v in pairs(_val) do
                            local c = _cosLib.Cosmetics[k]
                            if c and _isAllType(c) then _prx[k] = v end
                        end
                    end
                    return setmetatable(_prx, {
                        __index = function(t, k)
                            local c = _cosLib.Cosmetics[k]
                            if c and _isAllType(c) then return true end
                            return nil
                        end
                    })
                end
                if key == "FavoritedCosmetics" then
                    local _res = _val and table.clone(_val) or {}
                    for wep, fv in pairs(_favs) do
                        _res[wep] = _res[wep] or {}
                        for nm, isFav in pairs(fv) do
                            local c = _cosLib.Cosmetics[nm]
                            if c and _isAllType(c) then _res[wep][nm] = isFav end
                        end
                    end
                    return _res
                end
                return _val
            end

            local _origGetWep = _datCtrl.GetWeaponData
            _datCtrl.GetWeaponData = function(self, wn)
                local _d = _origGetWep(self, wn)
                if not _d then return nil end
                local _m = {}
                for k, v in pairs(_d) do _m[k] = v end
                _m.Name = wn
                if _eq[wn] then
                    for ct, cd in pairs(_eq[wn]) do
                        _m[ct] = cd
                    end
                end
                return _m
            end

            if hookmetamethod then
                local _remotes = _rs:FindFirstChild("Remotes")
                local _dataRem = _remotes and _remotes:FindFirstChild("Data")
                local _equipRem = _dataRem and _dataRem:FindFirstChild("EquipCosmetic")
                local _favRem = _dataRem and _dataRem:FindFirstChild("FavoriteCosmetic")
                if _equipRem then
                    local _onc
                    _onc = hookmetamethod(game, "__namecall", function(self, ...)
                        if getnamecallmethod() ~= "FireServer" then
                            return _onc(self, ...)
                        end
                        local _a = {...}
                        if self == _equipRem then
                            local _wn = _a[1]
                            local _ct = _a[2]
                            local _cn = _a[3]
                            _eq[_wn] = _eq[_wn] or {}
                            if not _cn or _cn == "None" or _cn == "" then
                                _eq[_wn][_ct] = nil
                                if not next(_eq[_wn]) then _eq[_wn] = nil end
                            else
                                local _cloned = _mkCosmetic(_cn, _ct)
                                if _cloned then _eq[_wn][_ct] = _cloned end
                            end
                            _saveCfg()
                            return
                        end
                        if self == _favRem then
                            local _cos = _cosLib.Cosmetics[_a[2]]
                            if _cos and _isAllType(_cos) then
                                _favs[_a[1]] = _favs[_a[1]] or {}
                                _favs[_a[1]][_a[2]] = _a[3] or nil
                                _saveCfg()
                            end
                            return
                        end
                        return _onc(self, ...)
                    end)
                end
            end

            local _cliItem
            pcall(function()
                _cliItem = require(_lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
            end)

            if _cliItem and _cliItem._CreateViewModel then
                local _origCVM = _cliItem._CreateViewModel
                _cliItem._CreateViewModel = function(self, vmRef)
                    local _wn = self.Name
                    local _wp = self.ClientFighter and self.ClientFighter.Player
                    if _wp == _lp and _eq[_wn] then
                        local _dk = self:ToEnum("Data")
                        if vmRef[_dk] then
                            for ct, cd in pairs(_eq[_wn]) do
                                local _enum = self:ToEnum(ct)
                                if _enum then vmRef[_dk][_enum] = cd end
                            end
                            if _eq[_wn].Skin then
                                vmRef[_dk][self:ToEnum("Name")] = _eq[_wn].Skin.Name
                            end
                        elseif vmRef.Data then
                            for ct, cd in pairs(_eq[_wn]) do
                                vmRef.Data[ct] = cd
                            end
                        end
                    end
                    return _origCVM(self, vmRef)
                end
            end

            local _vmMod = _lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
            if _vmMod then
                local _CVM = require(_vmMod)
                local _origNew = _CVM.new
                _CVM.new = function(repData, cliItm)
                    local _wp = cliItm.ClientFighter and cliItm.ClientFighter.Player
                    local _wn = cliItm.Name
                    if _wp == _lp and _eq[_wn] then
                        local _RC = require(_rs.Modules.ReplicatedClass)
                        local _dk = _RC:ToEnum("Data")
                        repData[_dk] = repData[_dk] or {}
                        for ct, cd in pairs(_eq[_wn]) do
                            local _enum = _RC:ToEnum(ct)
                            if _enum then repData[_dk][_enum] = cd end
                        end
                    end
                    return _origNew(repData, cliItm)
                end
            end

            Library:Notify("All Skins Unlocked! ✅")
            print("✅ All Skins, Wraps, Charms, and FINISHERS unlocked!")
        else
            Library:Notify("Skin unlocker disabled. Rejoin to reset.")
            print("Skin Unlocker: OFF")
        end
    end
})

local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc")
MiscGroup:AddLabel("Misc Options Coming Soon")

-- ============================================
-- UI SETTINGS
-- ============================================

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function()
    if Env.RageBot then
        Env.RageBot:Shutdown()
        Env.RageBot:StopVoidSpam()
        Env.RageBot = nil
    end
    RapidFireEnabled = false
    RestoreItems()
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
-- RAGEBOT CORE (당신이 보낸 코드 - 그대로)
-- ============================================

task.wait(0.5)

local __a1b2c3 = setmetatable({}, {
    __index = function(__d4e5f6, __g7h8i9)
        local __j0k1l2, __m3n4o5 = pcall(function()
            return game:GetService(__g7h8i9)
        end)
        if __m3n4o5 then
            return cloneref(__m3n4o5)
        end
        return nil
    end
})

local __p6q7r8 = getgenv()
if __p6q7r8.__s9t0u1 then
    __p6q7r8.__s9t0u1:Shutdown()
end

local __v2w3x4 = __a1b2c3.Players
local __y5z6a7 = __a1b2c3.RunService
local __b8c9d0 = __a1b2c3.ReplicatedStorage
local __e1f2g3 = __a1b2c3.Workspace
local __h4i5j6 = __a1b2c3.UserInputService
local __k7l8m9 = __v2w3x4.LocalPlayer
local __n0o1p2 = __e1f2g3.CurrentCamera
local __q3r4s5 = __k7l8m9.PlayerScripts
local __t6u7v8 = require(__q3r4s5.Modules.ItemTypes.Gun)
local __w9x0y1 = require(__b8c9d0.Modules.Utility)

local __z2a3b4 = setmetatable({}, {
    __index = function(_, __c5d6e7)
        local __f8g9h0 = __k7l8m9.Character
        if not __f8g9h0 then return nil end
        if __c5d6e7 == "__root" then
            return __f8g9h0:FindFirstChild("HumanoidRootPart")
        elseif __c5d6e7 == "__head" then
            return __f8g9h0:FindFirstChild("Head")
        end
        return nil
    end
})

__p6q7r8.__s9t0u1 = {}

do
    local __i1j2k3 = __p6q7r8.__s9t0u1

    function __i1j2k3:__init()
        self.__active = true
        self.__target = nil
        self.__desync = false
        self.__conn1 = nil
        self.__conn2 = nil
        self.__task1 = nil
        self.__oldfunc = nil
        self:__setup()
    end

    function __i1j2k3:__setup()
        self.__conn1 = __y5z6a7.Heartbeat:Connect(function()
            if not self.__active then return end
            self.__target = self:__find()
        end)

        local __l4m5n6 = __t6u7v8.StartShooting
        self.__oldfunc = __l4m5n6
        __t6u7v8.StartShooting = function(__o7p8q9, ...)
            local __r0s1t2 = {__l4m5n6(__o7p8q9, ...)}
            if not __o7p8q9.ClientFighter or not __o7p8q9.ClientFighter.IsLocalPlayer then
                return unpack(__r0s1t2)
            end

            local __u3v4w5 = __r0s1t2[3]
            if not __u3v4w5 or typeof(__u3v4w5) ~= "table" then
                return unpack(__r0s1t2)
            end

            __r0s1t2[4] = true
            local __x6y7z8 = self.__target

            if not self.__active or not __x6y7z8 or not __x6y7z8.Character then
                return unpack(__r0s1t2)
            end

            if not self.__desync or self.__curr ~= __x6y7z8 then
                self:__desync_start(__x6y7z8)
                task.wait(0.1)
            end

            if self.__task1 then
                task.cancel(self.__task1)
                self.__task1 = nil
            end

            local __a9b0c1 = __x6y7z8.Character:FindFirstChild("Head")
            if not __a9b0c1 then return unpack(__r0s1t2) end

            local __d2e3f4 = __a9b0c1.Position
            local __g5h6i7 = __a9b0c1.CFrame
            local __j8k9l0 = __d2e3f4 - Vector3.new(0, 5, 0)
            local __m1n2o3 = CFrame.lookAt(__j8k9l0, __d2e3f4)
            local __p4q5r6 = __g5h6i7:ToObjectSpace(CFrame.new(__d2e3f4 + Vector3.new(math.random(), math.random(), math.random())))

            __u3v4w5[utf8.char(0)] = __w9x0y1:EncodeCFrame(CFrame.new(__j8k9l0, __d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
            __u3v4w5[utf8.char(1)] = __w9x0y1:EncodeCFrame(CFrame.new(__d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
            __u3v4w5[utf8.char(2)] = __a9b0c1
            __u3v4w5[utf8.char(3)] = __w9x0y1:EncodeCFrame(__p4q5r6)

            self.__task1 = task.delay(0.15, function()
                self:__desync_stop()
            end)

            return unpack(__r0s1t2)
        end
    end

    function __i1j2k3:__find()
        local myChar = __k7l8m9.Character
        if not myChar then return nil end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
       
        local closest = nil
        local closestDist = math.huge
        local MAX_DISTANCE = 99999999999

        for _, player in next, __v2w3x4:GetPlayers() do
            if player == __k7l8m9 then continue end
            if player:GetAttribute("TeamID") == __k7l8m9:GetAttribute("TeamID") then continue end
           
            local char = player.Character
            if not char then continue end

            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            
            if not (root and head and hum and hum.Health > 0) then continue end
           
            local dist = (myRoot.Position - root.Position).Magnitude
            
            if dist > MAX_DISTANCE then continue end
            
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
        
        return closest
    end

    function __i1j2k3:__desync_start(__c3d4e5)
        if self.__conn2 then self.__conn2:Disconnect() end
        self.__desync = true
        self.__curr = __c3d4e5

        self.__conn2 = __y5z6a7.Heartbeat:Connect(function()
            if not self.__desync then return end
            local __f6g7h8 = __z2a3b4.__root
            if not __f6g7h8 then return end

            local __i9j0k1 = __c3d4e5.Character and __c3d4e5.Character:FindFirstChild("HumanoidRootPart")
            if not __i9j0k1 then
                self:__desync_stop()
                return
            end

            local __l2m3n4 = __f6g7h8.CFrame
            local __o5p6q7 = __f6g7h8.Velocity
            local __r8s9t0 = __f6g7h8.RotVelocity

            __f6g7h8.CFrame = __i9j0k1.CFrame * CFrame.new(0, -5, 0)

            __y5z6a7:BindToRenderStep("__restore", 101, function()
                __f6g7h8.CFrame = __l2m3n4
                __f6g7h8.Velocity = __o5p6q7
                __f6g7h8.RotVelocity = __r8s9t0
                __y5z6a7:UnbindFromRenderStep("__restore")
            end)
        end)
    end

    function __i1j2k3:__desync_stop()
        self.__desync = false
        self.__curr = nil
        if self.__conn2 then
            self.__conn2:Disconnect()
            self.__conn2 = nil
        end
    end

    function __i1j2k3:Shutdown()
        self.__active = false
        if self.__conn1 then self.__conn1:Disconnect() end
        if self.__conn2 then self.__conn2:Disconnect() end
        if self.__task1 then task.cancel(self.__task1) end
        if self.__oldfunc then
            __t6u7v8.StartShooting = self.__oldfunc
        end
    end

    __i1j2k3:__init()
end

_G.ToggleRage = function()
    return __p6q7r8.__s9t0u1.__active
end

_G.ForceStopRage = function()
    if __p6q7r8 and __p6q7r8.__s9t0u1 then
        pcall(function()
            __p6q7r8.__s9t0u1:Shutdown()
            __p6q7r8.__s9t0u1 = nil
            print("RageBot Force Stopped!")
        end)
    end
end

print("All Loaded!")
print("RageBot, Void Spam, Rapid Fire, Skin Unlocker - ON/OFF from UI")
print("RightShift to open menu")
