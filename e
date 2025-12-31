--// CONFIG
local KEY = "KTA.2026"
local THEME = {
    Accent = Color3.fromRGB(110, 0, 255),
    Accent2 = Color3.fromRGB(0, 162, 255),
    Background = Color3.fromRGB(18, 20, 36),
    Panel = Color3.fromRGB(26, 28, 48),
    Text = Color3.fromRGB(230, 230, 255)
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer

--================================================--
--                UTILS
--================================================--
local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

--================================================--
--            KEY SYSTEM SCREEN
--================================================--
local KeyGui = Instance.new("ScreenGui", game.CoreGui)
KeyGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", KeyGui)
Frame.Size = UDim2.fromScale(0.28, 0.24)
Frame.Position = UDim2.fromScale(0.36, 0.35)
Frame.BackgroundColor3 = THEME.Panel
Frame.ClipsDescendants = true
Frame.Active = true
Frame.Draggable = true
Frame.BackgroundTransparency = 0.08

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,16)

local Glow = Instance.new("UIStroke", Frame)
Glow.Thickness = 2
Glow.Color = THEME.Accent

local Title = Instance.new("TextLabel", Frame)
Title.Text = "Enter Access Key"
Title.Size = UDim2.fromScale(1,0.28)
Title.BackgroundTransparency = 1
Title.TextColor3 = THEME.Text
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

local Box = Instance.new("TextBox", Frame)
Box.PlaceholderText = "Type here"
Box.Text = ""
Box.Size = UDim2.fromScale(0.85,0.28)
Box.Position = UDim2.fromScale(0.075,0.38)
Box.BackgroundColor3 = THEME.Background
Box.TextColor3 = THEME.Text
Box.Font = Enum.Font.Gotham
Box.TextScaled = true
Instance.new("UICorner",Box).CornerRadius = UDim.new(0,10)

local Button = Instance.new("TextButton", Frame)
Button.Text = "Continue"
Button.Size = UDim2.fromScale(0.6,0.25)
Button.Position = UDim2.fromScale(0.2,0.72)
Button.BackgroundColor3 = THEME.Accent
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.GothamBold
Button.TextScaled = true
Instance.new("UICorner",Button).CornerRadius = UDim.new(0,10)

-- Startup animation
Frame.Size = UDim2.fromScale(0,0)
tween(Frame,0.4,{Size=UDim2.fromScale(0.28,0.24)})

--================================================--
--            MAIN UI (LOCKED)
--================================================--
local MainGui = Instance.new("ScreenGui", game.CoreGui)
MainGui.Enabled = false

local Main = Instance.new("Frame", MainGui)
Main.Size = UDim2.fromScale(0.45,0.45)
Main.Position = UDim2.fromScale(0.28,0.22)
Main.BackgroundColor3 = THEME.Panel
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,16)

local Border = Instance.new("UIStroke", Main)
Border.Color = THEME.Accent2
Border.Thickness = 2

-- Titlebar
local Top = Instance.new("Frame", Main)
Top.Size = UDim2.fromScale(1,0.15)
Top.BackgroundColor3 = THEME.Background
Instance.new("UICorner",Top)

local Title2 = Instance.new("TextLabel", Top)
Title2.Text = "KTA Panel"
Title2.Size = UDim2.fromScale(0.7,1)
Title2.BackgroundTransparency = 1
Title2.TextXAlignment = Enum.TextXAlignment.Left
Title2.Position = UDim2.fromScale(0.05,0)
Title2.Font = Enum.Font.GothamBold
Title2.TextScaled = true
Title2.TextColor3 = THEME.Text

-- Minimize Button
local Min = Instance.new("TextButton", Top)
Min.Text = "-"
Min.Size = UDim2.fromScale(0.12,0.7)
Min.Position = UDim2.fromScale(0.83,0.15)
Min.BackgroundColor3 = THEME.Accent
Instance.new("UICorner",Min)
Min.TextScaled = true
Min.Font = Enum.Font.GothamBold
Min.TextColor3 = Color3.new(1,1,1)

--================================================--
--           LOGO (WHEN MINIMIZED)
--================================================--
local Logo = Instance.new("Frame", MainGui)
Logo.Visible = false
Logo.Size = UDim2.fromScale(0.055,0.1)
Logo.Position = UDim2.fromScale(0.03,0.85)
Logo.BackgroundColor3 = THEME.Panel
Logo.Active = true
Logo.Selectable = true
Instance.new("UICorner",Logo).CornerRadius = UDim.new(1,0)

local LText = Instance.new("TextLabel", Logo)
LText.Text = "KTA"
LText.BackgroundTransparency = 1
LText.Size = UDim2.fromScale(1,1)
LText.Font = Enum.Font.GothamBlack
LText.TextScaled = true
LText.TextColor3 = THEME.Accent2

local Logog = Instance.new("UIStroke", Logo)
Logog.Color = THEME.Accent
Logog.Thickness = 2

--================================================--
--                 TABS EXAMPLE
--================================================--
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.fromScale(0.25,0.85)
Tabs.Position = UDim2.fromScale(0,0.15)
Tabs.BackgroundColor3 = THEME.Background
Instance.new("UICorner",Tabs)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.fromScale(0.75,0.85)
Content.Position = UDim2.fromScale(0.25,0.15)
Content.BackgroundColor3 = THEME.Panel
Instance.new("UICorner",Content)

--================================================--
--           MINIMIZE / RESTORE ANIMATION
--================================================--
local minimized = false

local function minimize()
    minimized = true
    tween(Main,0.25,{Size=UDim2.fromScale(0,0),Transparency=1})
    task.wait(0.25)
    Main.Visible = false
    Logo.Visible = true
    tween(Logo,0.25,{Size=UDim2.fromScale(0.055,0.1)})
end

local function restore()
    minimized = false
    Logo.Visible = false
    Main.Visible = true
    Main.Size = UDim2.fromScale(0,0)
    tween(Main,0.25,{Size=UDim2.fromScale(0.45,0.45),Transparency=0})
end

Min.MouseButton1Click:Connect(function()
    if minimized then restore() else minimize() end
end)

Logo.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        restore()
    end
end)

--================================================--
--              KEY VALIDATION
--================================================--
Button.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        tween(Frame,0.35,{Size=UDim2.fromScale(0,0)})
        task.wait(0.35)
        KeyGui:Destroy()
        MainGui.Enabled = true
        restore()
    else
        tween(Box,0.1,{BackgroundColor3=Color3.fromRGB(120,0,0)})
        task.wait(0.12)
        tween(Box,0.2,{BackgroundColor3=THEME.Background})
    end
end)
