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
-- RAGEBOT (Desync 포함)
-- ============================================

local RageEnabled = false
local VoidEnabled = false
local RageDelay = 1
local VoidDelay = 0.5
local RageBotActive = false
local DesyncActive = false
local HeartbeatConn = nil
local DesyncConn = nil
local Target = nil
local CurrentTarget = nil
local OriginalFuncs = {}
local DelayTask = nil
local VoidTask = nil
local VoidActive = false
local TargetPart = "Head"
local Accuracy = 100

RageGroup:AddToggle("RageToggle", {
    Text = "Enable RageBot",
    Default = false,
    Callback = function(v)
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
-- VISUALS TAB - SKIN UNLOCKER (내가 준 코드 그대로)
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
            -- 내가 준 코드 그대로 실행
            SkinThread = coroutine.wrap(function()
                -- ============================================
                -- 여기부터 내가 준 코드 그대로 붙여넣기
                -- ============================================
                
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

                -- Unlock All Skins / Wraps / Charms / FINISHERS
                local _plrs    = game:GetService("Players")
                local _rs      = game:GetService("ReplicatedStorage")
                local _http    = game:GetService("HttpService")
                local _run     = game:GetService("RunService")
                local _ws      = game:GetService("Workspace")
                local _lp      = _plrs.LocalPlayer
                local _pscripts = _lp.PlayerScripts
                local _ctrl    = _pscripts.Controllers
                local _mods    = _rs:WaitForChild("Modules", 10)

                local _enumLib = require(_mods:WaitForChild("EnumLibrary", 10))
                if _enumLib then pcall(function() _enumLib:WaitForEnumBuilder() end) end

                local _cosLib  = require(_mods:WaitForChild("CosmeticLibrary", 10))
                local _itmLib  = require(_mods:WaitForChild("ItemLibrary", 10))
                local _datCtrl = require(_ctrl:WaitForChild("PlayerDataController", 10))

                local _eq, _favs = {}, {}
                local _buildingWep, _viewProf = nil, nil
                local _lastWep = nil
                local _fakeInv = {}

                -- ★ 추가: 피니셔 언락을 위한 확장 ★
                local _finisherTypes = {"Finisher", "FinisherEffect", "FinisherSound"}

                local function _isFinisher(cosObj)
                    if not cosObj then return false end
                    for _, t in ipairs(_finisherTypes) do
                        if cosObj.Type == t then return true end
                    end
                    return false
                end

                local function _mkCosmetic(nm, ctype, opts)
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
                    if opts then
                        if opts.inverted ~= nil then _d.Inverted = opts.inverted end
                        if opts.favoritesOnly ~= nil then _d.OnlyUseFavorites = opts.favoritesOnly end
                    end
                    return _d
                end

                local _cfgFile = "rivals_unlocker_config.json"
                local _saveLock = false

                local function _stripForSave()
                    local _out = {}
                    for wn, cos in pairs(_eq) do
                        _out[wn] = {}
                        for ct, cd in pairs(cos) do
                            if cd and cd.Name then
                                _out[wn][ct] = {
                                    Name = cd.Name,
                                    Inverted = cd.Inverted,
                                    OnlyUseFavorites = cd.OnlyUseFavorites
                                }
                            end
                        end
                    end
                    return { equipped = _out, favorites = _favs }
                end

                local function _loadCfg()
                    if not isfile or not readfile then return end
                    local _ok1, _ex = pcall(isfile, _cfgFile)
                    if not _ok1 or not _ex then return end
                    local _ok2, _raw = pcall(readfile, _cfgFile)
                    if not _ok2 or not _raw or _raw == "" then return end
                    local _ok3, _dec = pcall(_http.JSONDecode, _http, _raw)
                    if not _ok3 or not _dec then return end
                    if _dec.favorites then
                        _favs = _dec.favorites
                    end
                    if _dec.equipped then
                        _eq = {}
                        local _cnt = 0
                        for wn, cos in pairs(_dec.equipped) do
                            _eq[wn] = {}
                            for ct, sd in pairs(cos) do
                                if sd and sd.Name then
                                    if _cosLib.Cosmetics[sd.Name] then
                                        local _cloned = _mkCosmetic(sd.Name, ct, {
                                            inverted = sd.Inverted,
                                            favoritesOnly = sd.OnlyUseFavorites
                                        })
                                        if _cloned then
                                            _eq[wn][ct] = _cloned
                                            _cnt += 1
                                        end
                                    end
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
                        local _payload = _stripForSave()
                        local _ok, _enc = pcall(_http.JSONEncode, _http, _payload)
                        if _ok then
                            pcall(writefile, _cfgFile, _enc)
                        end
                        _saveLock = false
                    end)
                end

                _loadCfg()

                -- ★ 수정: 코스메틱 타입에 피니셔 계열 추가 ★
                local _cosTypes = {"Skin","Wrap","Charm","Dance","Emote","Finisher","FinisherEffect","FinisherSound","KillEffect"}

                local function _isCosType(cosObj)
                    if not cosObj then return false end
                    for _, t in ipairs(_cosTypes) do
                        if cosObj.Type == t then return true end
                    end
                    return false
                end

                _cosLib.OwnsCosmeticNormally = function(self, inv, nm, wep)
                    local c = _cosLib.Cosmetics[nm]
                    if c and (c.Type == "Skin" or c.Type == "Finisher" or c.Type == "FinisherEffect" or c.Type == "FinisherSound" or c.Type == "KillEffect") then 
                        return true 
                    end
                    return false
                end

                _cosLib.OwnsCosmeticUniversally = function(self, inv, nm, wep)
                    local c = _cosLib.Cosmetics[nm]
                    if c and (c.Type == "Skin" or c.Type == "Finisher" or c.Type == "FinisherEffect" or c.Type == "FinisherSound" or c.Type == "KillEffect") then 
                        return true 
                    end
                    return false
                end

                _cosLib.OwnsCosmeticForWeapon = function(self, inv, nm, wep)
                    local c = _cosLib.Cosmetics[nm]
                    if c and (c.Type == "Skin" or c.Type == "Finisher" or c.Type == "FinisherEffect" or c.Type == "FinisherSound" or c.Type == "KillEffect") then 
                        return true 
                    end
                    return false
                end

                local _origOwns = _cosLib.OwnsCosmetic
                _cosLib.OwnsCosmetic = function(self, inv, nm, wep)
                    if nm:find("MISSING_") or nm == "Bubble Gun" then
                        return _origOwns(self, inv, nm, wep)
                    end
                    local c = _cosLib.Cosmetics[nm]
                    if c and _isCosType(c) then return true end
                    return _origOwns(self, inv, nm, wep)
                end

                local _origGet = _datCtrl.Get
                _datCtrl.Get = function(self, key)
                    local _val = _origGet(self, key)
                    if key == "CosmeticInventory" then
                        local _prx = {}
                        if _val then
                            for k, v in pairs(_val) do
                                local c = _cosLib.Cosmetics[k]
                                if c and _isCosType(c) then _prx[k] = v end
                            end
                        end
                        return setmetatable(_prx, {
                            __index = function(t, k)
                                local c = _cosLib.Cosmetics[k]
                                if c and _isCosType(c) then return true end
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
                                if c and _isCosType(c) then
                                    _res[wep][nm] = isFav
                                end
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

                local _fightCtrl
                pcall(function()
                    _fightCtrl = require(_ctrl:WaitForChild("FighterController", 10))
                end)

                if hookmetamethod then
                    local _remotes   = _rs:FindFirstChild("Remotes")
                    local _dataRem   = _remotes and _remotes:FindFirstChild("Data")
                    local _equipRem  = _dataRem and _dataRem:FindFirstChild("EquipCosmetic")
                    local _favRem    = _dataRem and _dataRem:FindFirstChild("FavoriteCosmetic")
                    local _repRem    = _remotes and _remotes:FindFirstChild("Replication")
                    local _fightRem  = _repRem and _repRem:FindFirstChild("Fighter")
                    local _useItmRem = _fightRem and _fightRem:FindFirstChild("UseItem")

                    if _equipRem then
                        local _onc
                        _onc = hookmetamethod(game, "__namecall", function(self, ...)
                            if getnamecallmethod() ~= "FireServer" then
                                return _onc(self, ...)
                            end
                            local _a = {...}

                            if _useItmRem and self == _useItmRem then
                                local _oid = _a[1]
                                if _fightCtrl then
                                    pcall(function()
                                        local _f = _fightCtrl:GetFighter(_lp)
                                        if _f and _f.Items then
                                            for _, itm in pairs(_f.Items) do
                                                if itm:Get("ObjectID") == _oid then
                                                    _lastWep = itm.Name
                                                    break
                                                end
                                            end
                                        end
                                    end)
                                end
                            end

                            if self == _equipRem then
                                local _wn   = _a[1]
                                local _ct   = _a[2]
                                local _cn   = _a[3]
                                local _opts = _a[4] or {}
                                if _cn and _cn ~= "None" and _cn ~= "" then
                                    local _inv = _datCtrl:Get("CosmeticInventory")
                                    if _inv and rawget(_inv, _cn) then
                                        return _onc(self, ...)
                                    end
                                end
                                _eq[_wn] = _eq[_wn] or {}
                                if not _cn or _cn == "None" or _cn == "" then
                                    _eq[_wn][_ct] = nil
                                    if not next(_eq[_wn]) then _eq[_wn] = nil end
                                else
                                    local _cloned = _mkCosmetic(_cn, _ct, {
                                        inverted = _opts.IsInverted,
                                        favoritesOnly = _opts.OnlyUseFavorites
                                    })
                                    if _cloned then _eq[_wn][_ct] = _cloned end
                                end
                                task.defer(function()
                                    pcall(function() _datCtrl.CurrentData:Replicate("WeaponInventory") end)
                                end)
                                _saveCfg()
                                return
                            end

                            if self == _favRem then
                                local _cos = _cosLib.Cosmetics[_a[2]]
                                if _cos then
                                    _favs[_a[1]] = _favs[_a[1]] or {}
                                    _favs[_a[1]][_a[2]] = _a[3] or nil
                                    task.spawn(function()
                                        pcall(function() _datCtrl.CurrentData:Replicate("FavoritedCosmetics") end)
                                    end)
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
                        local _wn  = self.Name
                        local _wp  = self.ClientFighter and self.ClientFighter.Player
                        _buildingWep = (_wp == _lp) and _wn or nil
                        if _wp == _lp and _eq[_wn] then
                            local _dk = self:ToEnum("Data")
                            if vmRef[_dk] then
                                if _eq[_wn].Skin then
                                    vmRef[_dk][self:ToEnum("Skin")] = _eq[_wn].Skin
                                    vmRef[_dk][self:ToEnum("Name")] = _eq[_wn].Skin.Name
                                end
                                if _eq[_wn].Charm then vmRef[_dk][self:ToEnum("Charm")] = _eq[_wn].Charm end
                                if _eq[_wn].Wrap  then vmRef[_dk][self:ToEnum("Wrap")]  = _eq[_wn].Wrap  end
                                if _eq[_wn].Finisher then vmRef[_dk][self:ToEnum("Finisher")] = _eq[_wn].Finisher end
                                if _eq[_wn].KillEffect then vmRef[_dk][self:ToEnum("KillEffect")] = _eq[_wn].KillEffect end
                            elseif vmRef.Data then
                                if _eq[_wn].Skin  then vmRef.Data.Skin  = _eq[_wn].Skin; vmRef.Data.Name = _eq[_wn].Skin.Name end
                                if _eq[_wn].Charm then vmRef.Data.Charm = _eq[_wn].Charm end
                                if _eq[_wn].Wrap  then vmRef.Data.Wrap  = _eq[_wn].Wrap  end
                                if _eq[_wn].Finisher then vmRef.Data.Finisher = _eq[_wn].Finisher end
                                if _eq[_wn].KillEffect then vmRef.Data.KillEffect = _eq[_wn].KillEffect end
                            end
                        end
                        local _r = _origCVM(self, vmRef)
                        _buildingWep = nil
                        return _r
                    end
                end

                local _vmMod = _lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
                if _vmMod then
                    local _CVM = require(_vmMod)
                    local _origNew = _CVM.new
                    _CVM.new = function(repData, cliItm)
                        local _wp  = cliItm.ClientFighter and cliItm.ClientFighter.Player
                        local _wn  = _buildingWep or cliItm.Name
                        if _wp == _lp and _eq[_wn] then
                            local _RC  = require(_rs.Modules.ReplicatedClass)
                            local _dk  = _RC:ToEnum("Data")
                            repData[_dk] = repData[_dk] or {}
                            local _cos = _eq[_wn]
                            if _cos.Skin  then repData[_dk][_RC:ToEnum("Skin")]  = _cos.Skin  end
                            if _cos.Charm then repData[_dk][_RC:ToEnum("Charm")] = _cos.Charm end
                            if _cos.Wrap  then repData[_dk][_RC:ToEnum("Wrap")]  = _cos.Wrap  end
                            if _cos.Finisher then repData[_dk][_RC:ToEnum("Finisher")] = _cos.Finisher end
                            if _cos.KillEffect then repData[_dk][_RC:ToEnum("KillEffect")] = _cos.KillEffect end
                        end
                        return _origNew(repData, cliItm)
                    end
                end

                print("✅ All Skins, Wraps, Charms, and FINISHERS unlocked!")
                Library:Notify("All Skins Unlocked! ✅")
                
                -- ============================================
                -- 내가 준 코드 끝
                -- ============================================
            end)
            SkinThread()
        else
            -- OFF: 알림만 표시 (재접속 시 리셋)
            Library:Notify("Skin unlocker disabled. Rejoin to reset.")
            print("Skin Unlocker: Disabled")
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
    StopRageBot()
    StopVoidSpam()
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

print("UI Loaded!")

-- ============================================
-- RAGEBOT CORE (생략 - 동일)
-- ============================================

-- (RageBot 코드는 이전과 동일하게 유지)

print("All Loaded!")
print("RightShift to open menu")
