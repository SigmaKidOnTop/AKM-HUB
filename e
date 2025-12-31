-- Load your UI library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SigmaKidOnTop/AKM-HUB/refs/heads/main/e"))()

--// WINDOW
local Window = Library:CreateWindow({
    Title = "Allusive",
    SubTitle = "Example UI",
    Theme = "Dark" -- Or Light
})

--// THEMES (OPTIONAL SWITCHER)
Window:SetTheme({
    Background = Color3.fromRGB(20, 20, 20),
    Accent     = Color3.fromRGB(0, 136, 255),
    Text       = Color3.fromRGB(255,255,255)
})

--====================================================--
--                     HOME TAB
--====================================================--
local Home = Window:CreateTab("Home")

Home:CreateLabel("Welcome to the UI")

Home:CreateButton("Print Hello", function()
    print("Hello")
end)

--====================================================--
--                   MODULE TAB
--====================================================--
local Module = Window:CreateTab("Module")

-- Toggle Example
local ToggleState = false
Module:CreateToggle("God Mode", function(v)
    ToggleState = v
    print("Toggle:", v)
end)

-- Keybind Toggle Example
Module:CreateKeyToggle("Auto Punch", Enum.KeyCode.Space, function(v)
    print("Auto Punch:", v)
end)

-- Slider Example
Module:CreateSlider("Speed", 1, 100, 50, function(v)
    print("Speed:", v)
end)

-- Dropdown Example
Module:CreateDropdown("Mode", {"Silent", "Legit", "Rage"}, function(v)
    print("Selected:", v)
end)

-- Textbox Example
Module:CreateTextbox("Say Something", function(text)
    print("Typed:", text)
end)

--====================================================--
--                  SETTINGS TAB
--====================================================--
local Settings = Window:CreateTab("Settings")

Settings:CreateDropdown("Theme", {"Dark","Light","Red","Blue"}, function(v)
    print("Theme:", v)
end)

Settings:CreateSlider("UI Scale", 50,150,100,function(v)
    Library:SetScale(v/100)
end)

Settings:CreateToggle("Blur Background", function(v)
    print("Blur:", v)
end)

--====================================================--
--               NOTIFICATION TEST
--====================================================--
Window:Notify("UI Loaded", "Allusive Style UI Ready!")

