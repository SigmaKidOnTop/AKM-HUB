--// Allusive-Style UI Library
--// Creates tabs, sliders, dropdowns, checkboxes, textboxes + themes

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.Theme = {
    Background = Color3.fromRGB(20,20,20),
    Accent = Color3.fromRGB(120,70,255),
    Text = Color3.fromRGB(230,230,230),
    Secondary = Color3.fromRGB(30,30,30)
}

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local Main = Instance.new("Frame", gui)
Main.Size = UDim2.new(0,600,0,350)
Main.Position = UDim2.new(0.5,-300,0.5,-175)
Main.BackgroundColor3 = Library.Theme.Background
Main.Active = true
Main.Draggable = true
Main.BorderSizePixel = 0
Main.Name = "AllusiveUI"

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0,12)

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(0,140,1,0)
TabBar.BackgroundColor3 = Library.Theme.Secondary
TabBar.BorderSizePixel = 0

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,-150,1,-20)
Content.Position = UDim2.new(0,150,0,10)
Content.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", TabBar)
UIList.Padding = UDim.new(0,4)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Top

local Tabs = {}

function Library:SetTheme(t)
    for k,v in pairs(t) do
        Library.Theme[k] = v
    end
    Main.BackgroundColor3 = Library.Theme.Background
    TabBar.BackgroundColor3 = Library.Theme.Secondary
end

function Library:AddTab(name)
    local Tab = {}

    local Button = Instance.new("TextButton", TabBar)
    Button.Text = name
    Button.Size = UDim2.new(1,-10,0,30)
    Button.BackgroundColor3 = Library.Theme.Secondary
    Button.TextColor3 = Library.Theme.Text
    Button.BorderSizePixel = 0

    local TabFrame = Instance.new("ScrollingFrame", Content)
    TabFrame.Visible = false
    TabFrame.CanvasSize = UDim2.new(0,0,0,0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Size = UDim2.new(1,0,1,0)

    local Layout = Instance.new("UIListLayout", TabFrame)
    Layout.Padding = UDim.new(0,6)

    local function resize()
        TabFrame.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+10)
    end
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

    Button.MouseButton1Click:Connect(function()
        for _,t in pairs(Tabs) do
            t.Frame.Visible = false
        end
        TabFrame.Visible = true
    end)

    Tab.Frame = TabFrame
    table.insert(Tabs, Tab)

    -- ELEMENT APIs:

    function Tab:AddLabel(text)
        local L = Instance.new("TextLabel", TabFrame)
        L.Text = text
        L.TextColor3 = Library.Theme.Text
        L.BackgroundColor3 = Library.Theme.Secondary
        L.Size = UDim2.new(1,-10,0,28)
        L.BorderSizePixel = 0
    end

    function Tab:AddCheckbox(text, callback)
        local B = Instance.new("TextButton", TabFrame)
        B.Size = UDim2.new(1,-10,0,28)
        B.BackgroundColor3 = Library.Theme.Secondary
        B.TextColor3 = Library.Theme.Text
        B.Text = "[ ] "..text
        local state = false
        B.MouseButton1Click:Connect(function()
            state = not state
            B.Text = (state and "[✓] " or "[ ] ")..text
            if callback then callback(state) end
        end)
    end

    function Tab:AddSlider(text, min, max, default, callback)
        local F = Instance.new("Frame", TabFrame)
        F.Size = UDim2.new(1,-10,0,40)
        F.BackgroundColor3 = Library.Theme.Secondary
        F.BorderSizePixel = 0

        local Label = Instance.new("TextLabel", F)
        Label.Text = text.." : "..default
        Label.Size = UDim2.new(1,0,0,20)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Library.Theme.Text

        local Bar = Instance.new("Frame", F)
        Bar.Size = UDim2.new(1,-20,0,6)
        Bar.Position = UDim2.new(0,10,0,28)
        Bar.BackgroundColor3 = Library.Theme.Background

        local Fill = Instance.new("Frame", Bar)
        Fill.BackgroundColor3 = Library.Theme.Accent
        Fill.Size = UDim2.new((default-min)/(max-min),0,1,0)

        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = game:GetService("UserInputService").InputChanged:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement then
                        local pct = math.clamp((i.Position.X-Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
                        Fill.Size = UDim2.new(pct,0,1,0)
                        local val = math.floor(min + (max-min)*pct)
                        Label.Text = text.." : "..val
                        if callback then callback(val) end
                    end
                end)
                input:GetPropertyChangedSignal("UserInputState"):Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        conn:Disconnect()
                    end
                end)
            end
        end)
    end

    function Tab:AddDropdown(text, list, callback)
        local B = Instance.new("TextButton", TabFrame)
        B.Size = UDim2.new(1,-10,0,28)
        B.BackgroundColor3 = Library.Theme.Secondary
        B.TextColor3 = Library.Theme.Text
        B.Text = text.." ▼"

        local Open = false
        B.MouseButton1Click:Connect(function()
            Open = not Open
            if Open then
                for _,v in ipairs(list) do
                    local O = Instance.new("TextButton", TabFrame)
                    O.Size = UDim2.new(1,-10,0,24)
                    O.BackgroundColor3 = Library.Theme.Background
                    O.Text = "• "..v
                    O.TextColor3 = Library.Theme.Text
                    O.MouseButton1Click:Connect(function()
                        B.Text = text..": "..v
                        if callback then callback(v) end
                    end)
                end
            else
                for _,v in ipairs(TabFrame:GetChildren()) do
                    if v:IsA("TextButton") and v ~= B then v:Destroy() end
                end
            end
        end)
    end

    function Tab:AddTextbox(placeholder, callback)
        local T = Instance.new("TextBox", TabFrame)
        T.Size = UDim2.new(1,-10,0,28)
        T.PlaceholderText = placeholder
        T.BackgroundColor3 = Library.Theme.Secondary
        T.TextColor3 = Library.Theme.Text
        T.FocusLost:Connect(function()
            if callback then callback(T.Text) end
        end)
    end

    return Tab
end

return Library
