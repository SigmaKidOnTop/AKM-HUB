-- Load the UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/memejames/elerium-v2-ui-library/main/Library", true))()

-- Get player's display name
local displayname = game:GetService("Players").LocalPlayer.DisplayName

-- Create the main window
local window = library:AddWindow("👑 Victory 👑 - Welcome " .. displayname, {
    main_color = Color3.fromRGB(106, 0, 255),
    min_size = Vector2.new(400, 700),
    can_resize = false,
})

-- Create and SHOW the main tab
local Killer = window:AddTab("👑 Kill Them All")
Killer:show()  -- THIS IS CRITICAL - without this, nothing will appear!

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Global variables
local playerWhitelist = {}
local targetPlayerNames = {}
local targetPlayerName = ""
local autoGoodKarma = false
local autoBadKarma = false
local autoKill = false
local killTarget = false
local spying = false
local autoEquipPunch = false
local autoPunchNoAnim = false
local friendWhitelistActive = false

-- Helper: Get hand (works for both R6 and R15)
local function getHand(char, handName)
    return char:FindFirstChild(handName) or char:FindFirstChild(handName == "RightHand" and "Right Arm" or "Left Arm")
end

-- === FEATURES ===

-- Anti Knockback
Killer:AddSwitch("Anti Knockback", function(bool)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local bv = rootPart:FindFirstChild("AntiKnockbackBV")

    if bool then
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "AntiKnockbackBV"
            bv.MaxForce = Vector3.new(100000, 0, 100000)
            bv.Velocity = Vector3.zero
            bv.P = 1250
            bv.Parent = rootPart
        end
    else
        if bv then bv:Destroy() end
    end
end):Set(true)

-- Hide Stats Frames
Killer:AddSwitch("Hide All Frames", function(bool)
    local blockedFrames = {"strengthFrame", "durabilityFrame", "agilityFrame", "evilKarmaFrame", "goodKarmaFrame"}
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    for _, frameName in ipairs(blockedFrames) do
        local frame = playerGui:FindFirstChild(frameName, true)
        if frame and frame:IsA("GuiObject") then
            frame.Visible = not bool
        end
    end

    if bool then
        if not _G.frameMonitor then
            _G.frameMonitor = playerGui.DescendantAdded:Connect(function(child)
                if table.find(blockedFrames, child.Name) and child:IsA("GuiObject") then
                    child.Visible = false
                end
            end)
        end
    else
        if _G.frameMonitor then
            _G.frameMonitor:Disconnect()
            _G.frameMonitor = nil
        end
    end
end)

-- Anti Lag
local effectsRemoved = false
local originalLighting = {}
Killer:AddSwitch("Anti Lag", function(bool)
    if bool then
        if effectsRemoved then return end
        originalLighting = {
            Brightness = Lighting.Brightness,
            GlobalShadows = Lighting.GlobalShadows,
            FogEnd = Lighting.FogEnd,
            ClockTime = Lighting.ClockTime,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Ambient = Lighting.Ambient
        }

        -- Remove effects
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj:Destroy()
            end
        end
        for _, eff in pairs(Lighting:GetChildren()) do
            if eff:IsA("PostEffect") or eff:IsA("Sky") or eff:IsA("Atmosphere") then
                eff:Destroy()
            end
        end

        Lighting.Brightness = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        Lighting.ClockTime = 12
        effectsRemoved = true
    else
        if not effectsRemoved then return end
        for k, v in pairs(originalLighting) do
            Lighting[k] = v
        end
        effectsRemoved = false
    end
end)

-- Auto Good/Bad Karma
Killer:AddSwitch("Auto Good Karma", function(bool)
    autoGoodKarma = bool
    task.spawn(function()
        while autoGoodKarma do
            local char = LocalPlayer.Character
            if char then
                local rightHand = getHand(char, "RightHand")
                local leftHand = getHand(char, "LeftHand")
                if rightHand and leftHand then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            local evil = plr:FindFirstChild("evilKarma")
                            local good = plr:FindFirstChild("goodKarma")
                            if evil and good and evil.Value > good.Value then
                                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    firetouchinterest(rightHand, hrp, 1)
                                    firetouchinterest(leftHand, hrp, 1)
                                    firetouchinterest(rightHand, hrp, 0)
                                    firetouchinterest(leftHand, hrp, 0)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end)

Killer:AddSwitch("Auto Bad Karma", function(bool)
    autoBadKarma = bool
    task.spawn(function()
        while autoBadKarma do
            local char = LocalPlayer.Character
            if char then
                local rightHand = getHand(char, "RightHand")
                local leftHand = getHand(char, "LeftHand")
                if rightHand and leftHand then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            local evil = plr:FindFirstChild("evilKarma")
                            local good = plr:FindFirstChild("goodKarma")
                            if good and evil and good.Value > evil.Value then
                                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    firetouchinterest(rightHand, hrp, 1)
                                    firetouchinterest(leftHand, hrp, 1)
                                    firetouchinterest(rightHand, hrp, 0)
                                    firetouchinterest(leftHand, hrp, 0)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end)

-- Whitelist Features
Killer:AddSwitch("Auto Whitelist Friends", function(state)
    friendWhitelistActive = state
    if state then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and LocalPlayer:IsFriendsWith(plr.UserId) then
                playerWhitelist[plr.Name] = true
            end
        end
        Players.PlayerAdded:Connect(function(plr)
            if friendWhitelistActive and LocalPlayer:IsFriendsWith(plr.UserId) then
                playerWhitelist[plr.Name] = true
            end
        end)
    end
end)

Killer:AddTextBox("Whitelist Player", function(text)
    local plr = Players:FindFirstChild(text)
    if plr then playerWhitelist[plr.Name] = true end
end)

Killer:AddTextBox("Unwhitelist Player", function(text)
    local plr = Players:FindFirstChild(text)
    if plr then playerWhitelist[plr.Name] = nil end
end)

-- Auto Kill Everyone
Killer:AddSwitch("Auto Kill Everyone", function(bool)
    autoKill = bool
    task.spawn(function()
        while autoKill do
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
            if punch and not char:FindFirstChild("Punch") then
                punch.Parent = char
            end
            local rightHand = getHand(char, "RightHand")
            local leftHand = getHand(char, "LeftHand")
            if rightHand and leftHand then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and not playerWhitelist[plr.Name] and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            firetouchinterest(rightHand, hrp, 1)
                            firetouchinterest(leftHand, hrp, 1)
                            firetouchinterest(rightHand, hrp, 0)
                            firetouchinterest(leftHand, hrp, 0)
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

-- Target Kill System
local targetDropdown = Killer:AddDropdown("Select Target to Kill", function(name)
    if not table.find(targetPlayerNames, name) then
        table.insert(targetPlayerNames, name)
    end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then targetDropdown:Add(plr.Name) end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then targetDropdown:Add(plr.Name) end
end)

Players.PlayerRemoving:Connect(function(plr)
    targetDropdown:Remove(plr.Name)
end)

Killer:AddTextBox("Remove Target", function(text)
    for i = #targetPlayerNames, 1, -1 do
        if targetPlayerNames[i] == text then table.remove(targetPlayerNames, i) end
    end
end)

Killer:AddSwitch("Kill Selected Targets", function(bool)
    killTarget = bool
    task.spawn(function()
        while killTarget do
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rightHand = getHand(char, "RightHand")
            local leftHand = getHand(char, "LeftHand")
            if rightHand and leftHand then
                for _, name in ipairs(targetPlayerNames) do
                    local plr = Players:FindFirstChild(name)
                    if plr and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            firetouchinterest(rightHand, hrp, 1)
                            firetouchinterest(leftHand, hrp, 1)
                            firetouchinterest(rightHand, hrp, 0)
                            firetouchinterest(leftHand, hrp, 0)
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

-- View Player
local viewDropdown = Killer:AddDropdown("Select Player to View", function(name)
    targetPlayerName = name
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then viewDropdown:Add(plr.Name) end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then viewDropdown:Add(plr.Name) end
end)

Players.PlayerRemoving:Connect(function(plr)
    viewDropdown:Remove(plr.Name)
end)

Killer:AddSwitch("View Selected Player", function(bool)
    spying = bool
    if not bool then
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        return
    end
    task.spawn(function()
        while spying do
            local target = Players:FindFirstChild(targetPlayerName)
            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                Workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
            end
            task.wait()
        end
    end)
end)

-- Auto Equip & Punch Features
Killer:AddSwitch("Auto Equip Punch", function(bool)
    autoEquipPunch = bool
    task.spawn(function()
        while autoEquipPunch do
            local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
            if punch and LocalPlayer.Character then
                punch.Parent = LocalPlayer.Character
            end
            task.wait(0.1)
        end
    end)
end)

Killer:AddSwitch("Auto Punch (No Anim)", function(bool)
    autoPunchNoAnim = bool
    task.spawn(function()
        while autoPunchNoAnim do
            local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
            if punch and LocalPlayer:FindFirstChild("muscleEvent") then
                LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
                LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
            end
            task.wait(0.01)
        end
    end)
end)

-- Success message (optional)
print("👑 Victory Hub Loaded Successfully! 👑")
