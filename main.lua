local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local originalCF = hrp.CFrame

-- Positions
local remingtonCF = CFrame.new(820.152161, 100.735336, 2229.32764, 0.998268962, 0, 0.0588140972, 0, 1, 0, -0.0588140972, 0, 0.998268962)
local mp5CF = CFrame.new(813.612366, 100.735336, 2229.425537, 0.999381, 0, -0.035189, 0, 1, 0, 0.035189, 0, 0.999381)
local prisonCF = CFrame.new(412.567932, 90.199669, 2388.806885, -0.199368, 0, -0.979925, 0, 1, 0, 0.979925, 0, -0.199368)
local ak47CF = CFrame.new(-932.074158, 94.368423, 2038.996338, 0.999050, 0, -0.043574, 0, 1, 0, 0.043574, 0, 0.999050)

local customTeleports = {}

-- ==================== LINORIA LIB ====================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local Window = Library:CreateWindow({
    Title = 'Teleport Hub',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Default = Window:AddTab('Default'),
    Custom = Window:AddTab('Custom Teleports')
}

-- Improved Safer Teleport Function
local function executeTeleport(targetCFrame, isFar)
    originalCF = hrp.CFrame
    
    if isFar then
        -- Safer method for long distance (less anomaly flags)
        hrp.CFrame = targetCFrame * CFrame.new(0, 5, 0)  -- Slight height offset
        task.wait(0.2)
        
        local leftPoint = hrp.Position + (hrp.CFrame.RightVector * -0.15)
        hum:MoveTo(leftPoint)
        hum.MoveToFinished:Wait()
        
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.35)
        
        -- Smooth return
        hrp.CFrame = originalCF
    else
        -- Normal fast method for close positions
        hrp.CFrame = targetCFrame
        task.wait(0.15)

        local leftPoint = hrp.Position + (hrp.CFrame.RightVector * -0.1)
        hum:MoveTo(leftPoint)
        hum.MoveToFinished:Wait()

        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.25)

        hrp.CFrame = originalCF
    end
end

-- ==================== DEFAULT TAB ====================
local DefaultGroup = Tabs.Default:AddLeftGroupbox('Gun Teleports')

DefaultGroup:AddButton({
    Text = 'Get Remington 870',
    Func = function() executeTeleport(remingtonCF, false) end
})

DefaultGroup:AddButton({
    Text = 'Get MP5',
    Func = function() executeTeleport(mp5CF, false) end
})

DefaultGroup:AddButton({
    Text = 'Escape Prison',
    Func = function() executeTeleport(prisonCF, false) end
})

DefaultGroup:AddButton({
    Text = 'Get AK-47',
    Func = function() executeTeleport(ak47CF, true) end   -- Uses safer method
})

DefaultGroup:AddButton({
    Text = 'Copy Current CFrame',
    Func = function()
        local cf = hrp.CFrame
        local formatted = string.format("CFrame.new(%.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f)",
            cf.X, cf.Y, cf.Z, cf.XVector.X, cf.XVector.Y, cf.XVector.Z,
            cf.YVector.X, cf.YVector.Y, cf.YVector.Z, cf.ZVector.X, cf.ZVector.Y, cf.ZVector.Z)
        setclipboard(formatted)
        Library:Notify('CFrame copied!', 3)
    end
})

DefaultGroup:AddButton({
    Text = 'Save New CFrame',
    Func = function()
        Library:Prompt({
            Title = 'Save New Location',
            Content = '',
            Placeholder1 = 'Teleport Name',
            Placeholder2 = 'CFrame Here',
            Callback = function(name, cfText)
                if name and cfText then
                    local success, newCF = pcall(function() return loadstring("return "..cfText)() end)
                    if success and typeof(newCF) == "CFrame" then
                        customTeleports[name] = newCF
                        Library:Notify('Saved: '..name, 3)
                    else
                        Library:Notify('Invalid CFrame format!', 3)
                    end
                end
            end
        })
    end
})

-- Custom Tab
local CustomGroup = Tabs.Custom:AddLeftGroupbox('Saved Teleports')

local function refreshCustom()
    CustomGroup:Clear()
    for name, cframe in pairs(customTeleports) do
        CustomGroup:AddButton({
            Text = name,
            Func = function() executeTeleport(cframe, false) end
        })
    end
end

Tabs.Custom.TabButton.MouseButton1Click:Connect(refreshCustom)

Library:Notify('PLT v0.0.3', 5)
