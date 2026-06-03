local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local plr = game.Players.LocalPlayer

local remingtonCF = CFrame.new(820.152161, 100.735336, 2229.32764, 0.998268962, 0, 0.0588140972, 0, 1, 0, -0.0588140972, 0, 0.998268962)
local mp5CF = CFrame.new(813.612366, 100.735336, 2229.425537, 0.999381, 0, -0.035189, 0, 1, 0, 0.035189, 0, 0.999381)
local prisonCF = CFrame.new(412.567932, 90.199669, 2388.806885, -0.199368, 0, -0.979925, 0, 1, 0, 0.979925, 0, -0.199368)
local ak47CF = CFrame.new(-932.074158, 94.368423, 2038.996338, 0.999050, 0, -0.043574, 0, 1, 0, 0.043574, 0, 0.999050)

local customTeleports = {}
local lastTeleport = 0
local COOLDOWN = 8 -- seconds between teleports

-- ==================== LINORIA LIB ====================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = 'PLT Overhaul v1.0',
    Center = true,
    AutoShow = true,
})

-- Disables Linoria's custom drawing mouse
Library.ShowCustomCursor = false

local Tabs = {
    Main = Window:AddTab('Main'),
    Custom = Window:AddTab('Custom Locations'),
    Settings = Window:AddTab('Settings')
}

-- ==================== TOGGLES / OPTIONS ====================
local Toggles = {}
local Options = {}

local function getChar()
    local char = plr.Character
    if not char then char = plr.CharacterAdded:Wait() end
    local hrp = char:WaitForChild("HumanoidRootPart", 3)
    local hum = char:WaitForChild("Humanoid", 3)
    return char, hrp, hum
end

local function performTween(char, hrp, tCF)
    local speed = Options.TweenSpeed and Options.TweenSpeed.Value or 45
    -- Instead of TweenService and Anchoring (which delays replication and causes instant-kick upon unanchoring),
    -- we use an incremental Heartbeat step to safely glide the character through the world.
    
    local dist = (hrp.Position - tCF.Position).Magnitude
    local timeToTake = dist / speed
    if timeToTake < 0.1 then timeToTake = 0.1 end
    
    local startTime = tick()
    local startCF = hrp.CFrame
    
    local noclipEvent = RunService.Stepped:Connect(function()
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end)
    
    local originalGravity = workspace.Gravity
    workspace.Gravity = 0
    
    -- Smoothly incrementally teleport frame-by-frame so the server accepts the position updates
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local alpha = math.clamp(elapsed / timeToTake, 0, 1)
        hrp.CFrame = startCF:Lerp(tCF, alpha)
        
        -- To prevent falling/physics glitches, freeze velocity
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        
        if alpha >= 1 then
            connection:Disconnect()
        end
    end)
    
    repeat task.wait() until tick() - startTime >= timeToTake
    
    noclipEvent:Disconnect()
    workspace.Gravity = originalGravity
end

local function offsetCFrame(cf, offsetVec)
    return cf + offsetVec
end

local function grabItemLocally(char, hrp, hum, targetCFrame)
    local useStealth = Toggles.UnderMapStealth and Toggles.UnderMapStealth.Value
    local underOffset = Vector3.new(0, -25, 0) -- Safe distance below map, not hitting the void
    
    if useStealth then
        performTween(char, hrp, offsetCFrame(hrp.CFrame, underOffset))
        performTween(char, hrp, offsetCFrame(targetCFrame, underOffset))
        performTween(char, hrp, targetCFrame * CFrame.new(0, 3, 0))
    else
        performTween(char, hrp, targetCFrame * CFrame.new(0, 3, 0))
    end
    
    task.wait(0.1)
    local pickup = targetCFrame.Position + targetCFrame.LookVector * 1.5
    hum:MoveTo(pickup)
    hum.MoveToFinished:Wait()
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(0.4)
end

-- Stealthier Teleport (Anti-Cheat Bypass)
local function executeTeleport(targetCFrame, isFar, shouldReturn)
    if shouldReturn == nil then shouldReturn = true end
    if tick() - lastTeleport < COOLDOWN then
        Library:Notify('Cooldown active... Wait a bit', 3)
        return
    end
    
    local char, hrp, hum = getChar()
    if not hrp or not hum then return end

    lastTeleport = tick()
    local originalCF = hrp.CFrame
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    local useStealth = Toggles.UnderMapStealth and Toggles.UnderMapStealth.Value

    if isFar or dist > 100 or useStealth then
        grabItemLocally(char, hrp, hum, targetCFrame)
        
        if shouldReturn then
            if useStealth then
                local underOffset = Vector3.new(0, -25, 0)
                performTween(char, hrp, offsetCFrame(hrp.CFrame, underOffset))
                performTween(char, hrp, offsetCFrame(originalCF, underOffset))
                performTween(char, hrp, originalCF)
            else
                performTween(char, hrp, originalCF)
            end
        end
    else
        -- Close range (stealth logic)
        hrp.CFrame = targetCFrame * CFrame.new(math.random(-1,1)/3, 2.5, math.random(-1,1)/3)
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
    if not hrp or not hum then return end

    lastTeleport = tick()
    local originalCF = hrp.CFrame
    local useStealth = Toggles.UnderMapStealth and Toggles.UnderMapStealth.Value
    
    grabItemLocally(char, hrp, hum, mp5CF)
    grabItemLocally(char, hrp, hum, remingtonCF)
    
    if useStealth then
        local underOffset = Vector3.new(0, -25, 0)
        performTween(char, hrp, offsetCFrame(hrp.CFrame, underOffset))
        performTween(char, hrp, offsetCFrame(originalCF, underOffset))
        performTween(char, hrp, originalCF)
    else
        performTween(char, hrp, originalCF)
    end
    Library:Notify('Combo Complete', 2)
end

-- ==================== UI ====================
local DefaultGroup = Tabs.Main:AddLeftGroupbox('Gun Teleports')

DefaultGroup:AddButton({ Text = 'Get Remington 870', Func = function() executeTeleport(remingtonCF, false) end })
DefaultGroup:AddButton({ Text = 'Get MP5', Func = function() executeTeleport(mp5CF, false) end })
DefaultGroup:AddButton({ Text = 'Get MP5 + Remington 870', Func = executeCombo })
DefaultGroup:AddButton({ Text = 'Escape Prison', Func = function() executeTeleport(prisonCF, false) end })
DefaultGroup:AddButton({ Text = 'Get AK-47 (Safe)', Func = function() executeTeleport(ak47CF, true) end })

local UtilGroup = Tabs.Main:AddRightGroupbox('Utilities')

UtilGroup:AddButton({
    Text = 'Load Silent Aim',
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SpyTA/s/refs/heads/main/SilentAim.lua"))()
        Library:Notify('Silent Aim Loaded', 4)
    end
})

UtilGroup:AddButton({
    Text = 'Copy Current CFrame',
    Func = function()
        local _, hrp = getChar()
        if hrp then
            local cf = hrp.CFrame
            local str = string.format("CFrame.new(%.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f)", 
                cf.X, cf.Y, cf.Z, cf.XVector.X, cf.XVector.Y, cf.XVector.Z,
                cf.YVector.X, cf.YVector.Y, cf.YVector.Z, cf.ZVector.X, cf.ZVector.Y, cf.ZVector.Z)
            setclipboard(str)
            Library:Notify('CFrame Copied', 3)
        end
    end
})

-- Settings Tab
local SettingsGroup = Tabs.Settings:AddLeftGroupbox('Teleport Settings')

SettingsGroup:AddSlider('TweenSpeed', {
    Text = 'Tween Speed',
    Default = 45,
    Min = 20,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Tooltip = 'Speed of long-distance teleports (Lower = safer from kicks)'
})

SettingsGroup:AddToggle('UnderMapStealth', {
    Text = 'Under-Map Stealth',
    Default = true,
    Tooltip = 'Tweens you perfectly under the map before popping up to grab the item.'
})

-- Save System
local SaveGroup = Tabs.Custom:AddLeftGroupbox('Save Location')
local NameInput = SaveGroup:AddInput('NameInput', {Text = 'Name', Placeholder = 'e.g. My Base'})
local CFrameInput = SaveGroup:AddInput('CFrameInput', {Text = 'CFrame', Placeholder = 'Paste CFrame'})

SaveGroup:AddButton({
    Text = 'Save New CFrame',
    Func = function()
        local name = NameInput.Value
        local cfText = CFrameInput.Value
        if name and name ~= "" and cfText and cfText ~= "" then
            local success, newCF = pcall(function() return loadstring("return "..cfText)() end)
            if success and typeof(newCF) == "CFrame" then
                customTeleports[name] = newCF
                Library:Notify('Saved: '..name, 4)
                NameInput:SetValue('')
                CFrameInput:SetValue('')
            else
                Library:Notify('Invalid CFrame!', 4)
            end
        end
    end
})

-- Custom Tab
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
    CustomDropdown:SetValues(names)
end

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
            executeTeleport(customTeleports[selected], false, AutoReturnToggle.Value)
        else
            Library:Notify('No custom teleport selected!', 2)
        end
    end
})

refreshCustom()

Library:Notify('PLT Overhaul v1.0 - Stealth Mode Loaded', 6)