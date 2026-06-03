local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local originalCF = hrp.CFrame

-- === Default Positions ===
local remingtonCF = CFrame.new(820.152161, 100.735336, 2229.32764, 0.998268962, 0, 0.0588140972, 0, 1, 0, -0.0588140972, 0, 0.998268962)
local mp5CF = CFrame.new(813.612366, 100.735336, 2229.425537, 0.999381, 0, -0.035189, 0, 1, 0, 0.035189, 0, 0.999381)
local prisonCF = CFrame.new(412.567932, 90.199669, 2388.806885, -0.199368, 0, -0.979925, 0, 1, 0, 0.979925, 0, -0.199368)
local ak47CF = CFrame.new(-932.074158, 94.368423, 2038.996338, 0.999050, 0, -0.043574, 0, 1, 0, 0.043574, 0, 0.999050)

local customTeleports = {}  -- name = CFrame

-- ==================== MAIN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProTPHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = plr:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Teleport Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamSemibold
Title.TextSize = 16
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tab System
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 36)
TabFrame.Position = UDim2.new(0, 10, 0, 50)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local DefaultTab = Instance.new("TextButton")
DefaultTab.Size = UDim2.new(0.5, -5, 1, 0)
DefaultTab.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
DefaultTab.Text = "Default"
DefaultTab.TextColor3 = Color3.fromRGB(255, 255, 255)
DefaultTab.Font = Enum.Font.GothamSemibold
DefaultTab.TextSize = 14
DefaultTab.Parent = TabFrame

local CustomTab = Instance.new("TextButton")
CustomTab.Size = UDim2.new(0.5, -5, 1, 0)
CustomTab.Position = UDim2.new(0.5, 5, 0, 0)
CustomTab.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CustomTab.Text = "Custom Teleports"
CustomTab.TextColor3 = Color3.fromRGB(180, 180, 180)
CustomTab.Font = Enum.Font.GothamSemibold
CustomTab.TextSize = 14
CustomTab.Parent = TabFrame

local DefaultCorner = Instance.new("UICorner", DefaultTab)
DefaultCorner.CornerRadius = UDim.new(0, 8)
local CustomCorner = Instance.new("UICorner", CustomTab)
CustomCorner.CornerRadius = UDim.new(0, 8)

-- Content Frames
local DefaultContent = Instance.new("ScrollingFrame")
DefaultContent.Size = UDim2.new(1, -20, 1, -100)
DefaultContent.Position = UDim2.new(0, 10, 0, 95)
DefaultContent.BackgroundTransparency = 1
DefaultContent.ScrollBarThickness = 4
DefaultContent.Parent = MainFrame

local CustomContent = Instance.new("ScrollingFrame")
CustomContent.Size = UDim2.new(1, -20, 1, -140)
CustomContent.Position = UDim2.new(0, 10, 0, 95)
CustomContent.BackgroundTransparency = 1
CustomContent.ScrollBarThickness = 4
CustomContent.Visible = false
CustomContent.Parent = MainFrame

-- Teleport Function
local function executeTeleport(targetCFrame)
    originalCF = hrp.CFrame
    hrp.CFrame = targetCFrame
    task.wait(0.15)

    local leftPoint = hrp.Position + (hrp.CFrame.RightVector * -0.1)
    hum:MoveTo(leftPoint)
    hum.MoveToFinished:Wait()

    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait(0.25)

    hrp.CFrame = originalCF
end

-- Button Creator
local function createButton(parent, text, cframe)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 46)
    btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        executeTeleport(cframe)
    end)

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255) end)

    return btn
end

-- Default Buttons
createButton(DefaultContent, "Get Remington 870", remingtonCF)
createButton(DefaultContent, "Get MP5", mp5CF)
createButton(DefaultContent, "Escape Prison", prisonCF)
createButton(DefaultContent, "Get AK-47", ak47CF)

-- CFrame Copier
local CopierBtn = Instance.new("TextButton")
CopierBtn.Size = UDim2.new(1, -10, 0, 46)
CopierBtn.Position = UDim2.new(0, 5, 0, 200)
CopierBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
CopierBtn.Text = "Copy Current CFrame"
CopierBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopierBtn.Font = Enum.Font.GothamBold
CopierBtn.TextSize = 14
CopierBtn.Parent = DefaultContent

local copyCorner = Instance.new("UICorner", CopierBtn)
copyCorner.CornerRadius = UDim.new(0, 8)

CopierBtn.MouseButton1Click:Connect(function()
    local cf = hrp.CFrame
    local formatted = string.format("CFrame.new(%.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f, %.6f)",
        cf.X, cf.Y, cf.Z,
        cf.XVector.X, cf.XVector.Y, cf.XVector.Z,
        cf.YVector.X, cf.YVector.Y, cf.YVector.Z,
        cf.ZVector.X, cf.ZVector.Y, cf.ZVector.Z
    )
    setclipboard(formatted)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Copied!",
        Text = "CFrame copied to clipboard",
        Duration = 3
    })
end)

-- Save New CFrame
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(1, -10, 0, 46)
SaveBtn.Position = UDim2.new(0, 5, 0, 255)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
SaveBtn.Text = "Save New CFrame"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 14
SaveBtn.Parent = DefaultContent

local saveCorner = Instance.new("UICorner", SaveBtn)
saveCorner.CornerRadius = UDim.new(0, 8)

-- Prompt for Save
local function showSavePrompt()
    local Prompt = Instance.new("Frame")
    Prompt.Size = UDim2.new(0, 260, 0, 180)
    Prompt.Position = UDim2.new(0.5, -130, 0.5, -90)
    Prompt.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Prompt.Parent = ScreenGui
    
    local pCorner = Instance.new("UICorner", Prompt)
    pCorner.CornerRadius = UDim.new(0, 12)

    local pTitle = Instance.new("TextLabel")
    pTitle.Size = UDim2.new(1, 0, 0, 40)
    pTitle.BackgroundTransparency = 1
    pTitle.Text = "Save New Teleport"
    pTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    pTitle.Font = Enum.Font.GothamSemibold
    pTitle.TextSize = 16
    pTitle.Parent = Prompt

    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(0.9, 0, 0, 32)
    nameBox.Position = UDim2.new(0.05, 0, 0.32, 0)
    nameBox.PlaceholderText = "Enter Name (e.g. My Base)"
    nameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 14
    nameBox.Parent = Prompt
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 6)

    local cfBox = Instance.new("TextBox")
    cfBox.Size = UDim2.new(0.9, 0, 0, 32)
    cfBox.Position = UDim2.new(0.05, 0, 0.55, 0)
    cfBox.PlaceholderText = "Paste CFrame here"
    cfBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    cfBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    cfBox.Font = Enum.Font.Gotham
    cfBox.TextSize = 13
    cfBox.Parent = Prompt
    Instance.new("UICorner", cfBox).CornerRadius = UDim.new(0, 6)

    local Confirm = Instance.new("TextButton")
    Confirm.Size = UDim2.new(0.45, 0, 0, 36)
    Confirm.Position = UDim2.new(0.05, 0, 0.78, 0)
    Confirm.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
    Confirm.Text = "Save"
    Confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
    Confirm.Font = Enum.Font.GothamBold
    Confirm.Parent = Prompt
    Instance.new("UICorner", Confirm).CornerRadius = UDim.new(0, 8)

    local Cancel = Instance.new("TextButton")
    Cancel.Size = UDim2.new(0.45, 0, 0, 36)
    Cancel.Position = UDim2.new(0.5, 0, 0.78, 0)
    Cancel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Cancel.Text = "Cancel"
    Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
    Cancel.Font = Enum.Font.GothamBold
    Cancel.Parent = Prompt
    Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 8)

    Confirm.MouseButton1Click:Connect(function()
        if nameBox.Text ~= "" and cfBox.Text ~= "" then
            local success, newCF = pcall(function()
                return loadstring("return " .. cfBox.Text)()
            end)
            if success and typeof(newCF) == "CFrame" then
                customTeleports[nameBox.Text] = newCF
                refreshCustomList()
            end
        end
        Prompt:Destroy()
    end)

    Cancel.MouseButton1Click:Connect(function()
        Prompt:Destroy()
    end)
end

SaveBtn.MouseButton1Click:Connect(showSavePrompt)

-- Refresh Custom List
local function refreshCustomList()
    for _, child in ipairs(CustomContent:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local yOffset = 0
    for name, cframe in pairs(customTeleports) do
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -10, 0, 50)
        container.Position = UDim2.new(0, 5, 0, yOffset)
        container.BackgroundTransparency = 1
        container.Parent = CustomContent

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.78, 0, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            executeTeleport(cframe)
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.2, 0, 1, 0)
        delBtn.Position = UDim2.new(0.8, 0, 0, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        delBtn.Text = "Delete"
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 13
        delBtn.Parent = container
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 8)

        delBtn.MouseButton1Click:Connect(function()
            if not container:FindFirstChild("Confirm") then
                local confirm = Instance.new("TextButton")
                confirm.Name = "Confirm"
                confirm.Size = UDim2.new(1, 0, 1, 0)
                confirm.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
                confirm.Text = "Are you sure?"
                confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
                confirm.Font = Enum.Font.GothamBold
                confirm.Parent = container
                Instance.new("UICorner", confirm).CornerRadius = UDim.new(0, 8)
                
                confirm.MouseButton1Click:Connect(function()
                    customTeleports[name] = nil
                    refreshCustomList()
                end)
            end
        end)

        yOffset += 55
    end
    CustomContent.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

-- Tab Switching
DefaultTab.MouseButton1Click:Connect(function()
    DefaultContent.Visible = true
    CustomContent.Visible = false
    DefaultTab.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    CustomTab.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end)

CustomTab.MouseButton1Click:Connect(function()
    DefaultContent.Visible = false
    CustomContent.Visible = true
    DefaultTab.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    CustomTab.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    refreshCustomList()
end)

-- Initial setup
DefaultContent.CanvasSize = UDim2.new(0, 0, 0, 320)
