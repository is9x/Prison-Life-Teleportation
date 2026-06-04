local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local plr = game.Players.LocalPlayer

-- ==================== FIXED CFrames ====================
local remingtonCF = CFrame.new(820.152161, 100.735336, 2229.32764, 0.998268962, 0, 0.0588140972, 0, 1, 0, -0.0588140972, 0, 0.998268962)
local mp5CF = CFrame.new(813.612366, 100.735336, 2229.425537, 0.999381, 0, -0.035189, 0, 1, 0, 0.035189, 0, 0.999381)
local prisonCF = CFrame.new(412.567932, 90.199669, 2388.806885, -0.199368, 0, -0.979925, 0, 1, 0, 0.979925, 0, -0.199368)

-- FIXED AK-47 TELEPORT
local ak47CF = CFrame.new(
    -931.850342, 94.368423, 2039.538940,
    0.999849, 0.000000, 0.017361,
    0.000000, 1.000000, 0.000000,
    -0.017361, 0.000000, 0.999849
)

local customTeleports = {}
local lastTeleport = 0
local COOLDOWN = 1

-- ==================== FILESYSTEM ====================
local CONFIG_FOLDER = "PLT"
local CONFIG_FILE = CONFIG_FOLDER .. "/custom_teleports.json"

if makefolder and not isfolder(CONFIG_FOLDER) then
    makefolder(CONFIG_FOLDER)
end

local function serializeCFrame(cf)
    return {
        cf:GetComponents()
    }
end

local function deserializeCFrame(tbl)
    return CFrame.new(unpack(tbl))
end

local function saveCustomTeleports()
    if not writefile then
        warn("Executor does not support writefile")
        return
    end

    local saveData = {}

    for name, cf in pairs(customTeleports) do
        saveData[name] = serializeCFrame(cf)
    end

    writefile(CONFIG_FILE, HttpService:JSONEncode(saveData))
end

local function loadCustomTeleports()
    if not (isfile and readfile and isfile(CONFIG_FILE)) then
        return
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)

    if success and type(data) == "table" then
        for name, components in pairs(data) do
            customTeleports[name] = deserializeCFrame(components)
        end
    end
end

loadCustomTeleports()

-- ==================== LINORIA LIB ====================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = 'PLT v1.1.1',
    Center = true,
    AutoShow = true,
})

Library.ShowCustomCursor = false

local Tabs = {
    Main = Window:AddTab('Main'),
    Custom = Window:AddTab('Custom Locations'),
    Settings = Window:AddTab('Settings')
}

local Toggles = {}
local Options = {}

local function getChar()
    local char = plr.Character
    if not char then
        char = plr.CharacterAdded:Wait()
    end

    local hrp = char:WaitForChild("HumanoidRootPart", 3)
    local hum = char:WaitForChild("Humanoid", 3)

    return char, hrp, hum
end

local function performTeleport(char, hrp, tCF)
    local targetPos = tCF.Position
    local ori = hrp.CFrame - hrp.CFrame.Position
    hrp.CFrame = CFrame.new(targetPos) * ori
end

local function grabItemLocally(char, hrp, hum, targetCFrame)
    performTeleport(char, hrp, targetCFrame * CFrame.new(0, 3, 0))

    task.wait(0.1)

    local pickup = targetCFrame.Position + targetCFrame.LookVector * 1.5

    hum:MoveTo(pickup)
    hum.MoveToFinished:Wait()

    hum:ChangeState(Enum.HumanoidStateType.Jumping)

    task.wait(0.4)
end

local function executeTeleport(targetCFrame, isFar, shouldReturn)
    if shouldReturn == nil then
        shouldReturn = true
    end

    if tick() - lastTeleport < COOLDOWN then
        Library:Notify('Cooldown active... Wait a bit', 3)
        return
    end

    local char, hrp, hum = getChar()

    if not hrp or not hum then
        return
    end

    lastTeleport = tick()

    local originalCF = hrp.CFrame
    local dist = (hrp.Position - targetCFrame.Position).Magnitude

    if isFar or dist > 100 then
        grabItemLocally(char, hrp, hum, targetCFrame)

        if shouldReturn then
            performTeleport(char, hrp, originalCF)
        end
    else
        hrp.CFrame = targetCFrame * CFrame.new(
            math.random(-1,1)/3,
            2.5,
            math.random(-1,1)/3
        )

        task.wait(0.25)

        local leftPoint = hrp.Position + (hrp.CFrame.RightVector * -0.15)

        hum:MoveTo(leftPoint)
        hum.MoveToFinished:Wait()

        hum:ChangeState(Enum.HumanoidStateType.Jumping)

        task.wait(0.3)

        if shouldReturn then
            hrp.CFrame = originalCF
        end
    end

    Library:Notify('Teleport Complete', 2)
end

local function executeCombo()
    if tick() - lastTeleport < COOLDOWN then
        Library:Notify('Cooldown active... Wait a bit', 3)
        return
    end

    local char, hrp, hum = getChar()

    if not hrp or not hum then
        return
    end

    lastTeleport = tick()

    local originalCF = hrp.CFrame

    grabItemLocally(char, hrp, hum, mp5CF)
    grabItemLocally(char, hrp, hum, remingtonCF)

    performTeleport(char, hrp, originalCF)

    Library:Notify('Combo Complete', 2)
end

local function unloadAllInstances()
    local playerGui = plr:FindFirstChildOfClass("PlayerGui")
    local coreGui = game:GetService("CoreGui")

    local function destroyMatching(container)
        for _, child in ipairs(container:GetChildren()) do
            local lowerName = child.Name:lower()

            if child:IsA("ScreenGui") and (
                lowerName:find("plt")
                or lowerName:find("linoria")
                or lowerName:find("multisaveloadgui")
            ) then
                pcall(function()
                    child:Destroy()
                end)
            end
        end
    end

    if playerGui then
        destroyMatching(playerGui)
    end

    destroyMatching(coreGui)

    pcall(function()
        script:Destroy()
    end)
end

-- ==================== UI ====================
local DefaultGroup = Tabs.Main:AddLeftGroupbox('Gun Teleports')

DefaultGroup:AddButton({
    Text = 'Get Remington 870',
    Func = function()
        executeTeleport(remingtonCF, false)
    end
})

DefaultGroup:AddButton({
    Text = 'Get MP5',
    Func = function()
        executeTeleport(mp5CF, false)
    end
})

DefaultGroup:AddButton({
    Text = 'Get MP5 + Remington 870',
    Func = executeCombo
})

DefaultGroup:AddButton({
    Text = 'Escape Prison',
    Func = function()
        executeTeleport(prisonCF, false)
    end
})

DefaultGroup:AddButton({
    Text = 'Get AK-47 (Risky)',
    Func = function()
        executeTeleport(ak47CF, true)
    end
})

local UtilGroup = Tabs.Main:AddRightGroupbox('Utilities')

UtilGroup:AddButton({
    Text = 'Load Silent Aim',
    Func = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/SpyTA/s/refs/heads/main/SilentAim.lua"
        ))()

        Library:Notify('Silent Aim Loaded', 4)
    end
})

UtilGroup:AddButton({
    Text = 'Copy Current CFrame',
    Func = function()
        local _, hrp = getChar()

        if hrp then
            local cf = hrp.CFrame

            local str = string.format(
                "CFrame.new(%.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f)",
                cf.X,
                cf.Y,
                cf.Z,
                cf.XVector.X,
                cf.XVector.Y,
                cf.XVector.Z,
                cf.YVector.X,
                cf.YVector.Y,
                cf.YVector.Z,
                cf.ZVector.X,
                cf.ZVector.Y,
                cf.ZVector.Z
            )

            setclipboard(str)

            Library:Notify('CFrame Copied', 3)
        end
    end
})

-- ==================== SETTINGS ====================
local SettingsGroup = Tabs.Settings:AddLeftGroupbox('Teleport Settings')

SettingsGroup:AddButton({
    Text = 'Unload All Instances',
    Func = unloadAllInstances,
    Tooltip = 'Destroys the script GUI and matching instances.'
})

-- ==================== SAVE SYSTEM ====================
local SaveGroup = Tabs.Custom:AddLeftGroupbox('Save Location')

local NameInput = SaveGroup:AddInput('NameInput', {
    Text = 'Name',
    Placeholder = 'e.g. My Base'
})

local CFrameInput = SaveGroup:AddInput('CFrameInput', {
    Text = 'CFrame',
    Placeholder = 'Paste CFrame'
})

-- ==================== CUSTOM TP ====================
local CustomGroup = Tabs.Custom:AddLeftGroupbox('Saved Teleports')

local AutoReturnToggle = CustomGroup:AddToggle('AutoReturn', {
    Text = 'Auto-Return',
    Default = true,
    Tooltip = 'Enable/Disable automatically teleporting back.'
})

local CustomDropdown = CustomGroup:AddDropdown('CustomTeleportSelect', {
    Values = {},
    Default = 0,
    Multi = false,
    Text = 'Select Teleport',
})

local function refreshCustom()
    local names = {}

    for name, _ in pairs(customTeleports) do
        table.insert(names, name)
    end

    table.sort(names)

    CustomDropdown:SetValues(names)
end

SaveGroup:AddButton({
    Text = 'Save New CFrame',
    Func = function()
        local name = NameInput.Value
        local cfText = CFrameInput.Value

        if name and name ~= "" and cfText and cfText ~= "" then
            local success, newCF = pcall(function()
                return loadstring("return " .. cfText)()
            end)

            if success and typeof(newCF) == "CFrame" then
                customTeleports[name] = newCF

                saveCustomTeleports()
                refreshCustom()

                Library:Notify('Saved: ' .. name, 4)

                NameInput:SetValue('')
                CFrameInput:SetValue('')
            else
                Library:Notify('Invalid CFrame!', 4)
            end
        end
    end
})

CustomGroup:AddButton({
    Text = '🔄 Refresh List',
    Func = function()
        refreshCustom()
        Library:Notify('List Refreshed', 2)
    end
})

CustomGroup:AddButton({
    Text = '🚀 Teleport',
    Func = function()
        local selected = CustomDropdown.Value

        if selected and customTeleports[selected] then
            executeTeleport(
                customTeleports[selected],
                false,
                AutoReturnToggle.Value
            )
        else
            Library:Notify('No custom teleport selected!', 2)
        end
    end
})

CustomGroup:AddButton({
    Text = '🗑 Delete Selected',
    Func = function()
        local selected = CustomDropdown.Value

        if selected and customTeleports[selected] then
            customTeleports[selected] = nil

            saveCustomTeleports()
            refreshCustom()

            Library:Notify('Deleted: ' .. selected, 3)
        else
            Library:Notify('No teleport selected!', 2)
        end
    end
})

refreshCustom()

Library:Notify('PLT Overhaul v1.1.1 Loaded', 6)