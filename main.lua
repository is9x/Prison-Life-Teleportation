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
    Title = 'PLT v0.0.6',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Default = Window:AddTab('Default'),
    Custom = Window:AddTab('Custom Teleports')
}

local function getChar()
    local char = plr.Character
    if not char then char = plr.CharacterAdded:Wait() end
    local hrp = char:WaitForChild("HumanoidRootPart", 3)
    local hum = char:WaitForChild("Humanoid", 3)
    return char, hrp, hum
end

-- Stealthier Teleport
local function executeTeleport(targetCFrame, isFar)
    if tick() - lastTeleport < COOLDOWN then
        Library:Notify('Cooldown active... Wait a bit', 3)
        return
    end
    
    local _, hrp, hum = getChar()
    if not hrp or not hum then return end

    lastTeleport = tick()
    local originalCF = hrp.CFrame

    if isFar then
        -- Very stealthy long distance
        hrp.CFrame = targetCFrame * CFrame.new(math.random(-2,2), 4 + math.random(), math.random(-2,2))
        task.wait(0.4 + math.random(1,3)/10)
        
        local pickup = targetCFrame.Position + targetCFrame.LookVector * (0.8 + math.random()) + targetCFrame.RightVector * (-0.3 + math.random(-2,2)/10)
        hum:MoveTo(pickup)
        hum.MoveToFinished:Wait()
        
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.45 + math.random())
        
        -- Smooth return with slight variation
        hrp.CFrame = originalCF * CFrame.new(math.random(-1,1)/5, 0, math.random(-1,1)/5)
    else
        -- Close range stealth
        hrp.CFrame = targetCFrame * CFrame.new(math.random(-1,1)/3, 2.5, math.random(-1,1)/3)
        task.wait(0.25 + math.random(1,4)/10)
        
        local leftPoint = hrp.Position + (hrp.CFrame.RightVector * -0.15) + Vector3.new(math.random(-8,8)/100, 0, math.random(-8,8)/100)
        hum:MoveTo(leftPoint)
        hum.MoveToFinished:Wait()
        
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.3 + math.random(1,5)/10)
        
        hrp.CFrame = originalCF * CFrame.new(math.random(-6,6)/100, 0, math.random(-6,6)/100)
    end
    
    Library:Notify('Teleport Complete', 2)
end

-- ==================== UI ====================
local DefaultGroup = Tabs.Default:AddLeftGroupbox('Gun Teleports')

DefaultGroup:AddButton({ Text = 'Get Remington 870', Func = function() executeTeleport(remingtonCF, false) end })
DefaultGroup:AddButton({ Text = 'Get MP5', Func = function() executeTeleport(mp5CF, false) end })
DefaultGroup:AddButton({ Text = 'Escape Prison', Func = function() executeTeleport(prisonCF, false) end })
DefaultGroup:AddButton({ Text = 'Get AK-47', Func = function() executeTeleport(ak47CF, true) end })

DefaultGroup:AddButton({
    Text = 'Load Silent Aim',
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SpyTA/s/refs/heads/main/SilentAim.lua"))()
        Library:Notify('Silent Aim Loaded', 4)
    end
})

DefaultGroup:AddButton({
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

-- Save System
local SaveGroup = Tabs.Default:AddLeftGroupbox('Save Location')
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

local function refreshCustom()
    for _, v in ipairs(CustomGroup.Container:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    CustomGroup:AddButton({ Text = '🔄 Refresh List', Func = refreshCustom })
    for name, cf in pairs(customTeleports) do
        CustomGroup:AddButton({ Text = name, Func = function() executeTeleport(cf, false) end })
    end
end

refreshCustom()

Library:Notify('PLT v0.0.6 - Stealth Mode Loaded', 6)