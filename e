local library =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/memejames/elerium-v2-ui-library/main/Library", true))()

local window = library:AddWindow("👑Evictor👑 - Welcome "..displayname, {
    main_color = Color3.fromRGB(106, 0, 255),
    min_size = Vector2.new(250, 400),
    can_resize = false,
})

local killingTab = window:AddTab("Killing")
killingTab:Show()

local antiKnockbackSwitch = killingTab:AddSwitch("Anti Knockback", function(bool)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
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
        if bv then
            bv:Destroy()
        end
    end
end)
antiKnockbackSwitch:Set(true)

local frameSwitch = killingTab:AddSwitch("Hide All Frames", function(bool)
    local blockedFrames = {
        "strengthFrame",
        "durabilityFrame",
        "agilityFrame",
        "evilKarmaFrame",
        "goodKarmaFrame"
    }

    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui") -- FIX

    for _, name in ipairs(blockedFrames) do
        local frame = playerGui:FindFirstChild(name, true) -- FIX
        if frame and frame:IsA("GuiObject") then
            frame.Visible = not bool
        end
    end

    if bool then
        if not _G.frameMonitorConnection then
            _G.frameMonitorConnection = playerGui.DescendantAdded:Connect(function(child) -- FIX
                if table.find(blockedFrames, child.Name) and child:IsA("GuiObject") then
                    child.Visible = false
                end
            end)
        end
    else
        if _G.frameMonitorConnection then
            _G.frameMonitorConnection:Disconnect()
            _G.frameMonitorConnection = nil
        end
    end
end)
frameSwitch:Set(false)

local originalLighting = {
    Brightness = nil,
    GlobalShadows = nil,
    FogEnd = nil,
    ClockTime = nil,
    OutdoorAmbient = nil,
    Ambient = nil
}
local originalQualityLevel = nil
local effectsRemoved = false

local antiLagSwitch = killingTab:AddSwitch("Anti Lag", function(bool)
    local lighting = game:GetService("Lighting")

    if bool then
        if effectsRemoved then return end

        originalLighting.Brightness = lighting.Brightness
        originalLighting.GlobalShadows = lighting.GlobalShadows
        originalLighting.FogEnd = lighting.FogEnd
        originalLighting.ClockTime = lighting.ClockTime
        originalLighting.OutdoorAmbient = lighting.OutdoorAmbient
        originalLighting.Ambient = lighting.Ambient

        pcall(function() -- FIX
            originalQualityLevel = settings().Rendering.QualityLevel
        end)

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or
               obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or
               obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") or
               obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            end
        end

        for _, v in pairs(lighting:GetDescendants()) do
            if v:IsA("Sky") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or
               v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("Atmosphere") then
                v:Destroy()
            end
        end

        local darkSky = Instance.new("Sky")
        darkSky.Name = "AntiLagDarkSky"
        darkSky.SkyboxBk = "rbxassetid://0"
        darkSky.SkyboxDn = "rbxassetid://0"
        darkSky.SkyboxFt = "rbxassetid://0"
        darkSky.SkyboxLf = "rbxassetid://0"
        darkSky.SkyboxRt = "rbxassetid://0"
        darkSky.SkyboxUp = "rbxassetid://0"
        darkSky.Parent = lighting

        lighting.Brightness = 1
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.ClockTime = 12
        lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        lighting.Ambient = Color3.fromRGB(100, 100, 100)

        pcall(function() -- FIX
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        effectsRemoved = true
    else
        if not effectsRemoved then return end

        if originalLighting.Brightness ~= nil then
            lighting.Brightness = originalLighting.Brightness
            lighting.GlobalShadows = originalLighting.GlobalShadows
            lighting.FogEnd = originalLighting.FogEnd
            lighting.ClockTime = originalLighting.ClockTime
            lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            lighting.Ambient = originalLighting.Ambient
        end

        local darkSky = lighting:FindFirstChild("AntiLagDarkSky")
        if darkSky then
            darkSky:Destroy()
        end

        pcall(function() -- FIX
            if originalQualityLevel then
                settings().Rendering.QualityLevel = originalQualityLevel
            end
        end)

        effectsRemoved = false
    end
end)
antiLagSwitch:Set(false)

killingTab:AddLabel("------Auto Kill Everyone-------")

local whitelist = {}
local autoKillActive = false
local killMethod = "Teleport"

local function equipTool(name)
    local player = game.Players.LocalPlayer
    local tool = player.Backpack:FindFirstChild(name)
    if tool and player.Character then
        player.Character.Humanoid:EquipTool(tool)
    end
end

local function makePlayerInvisible(char)
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        end
    end
    if char:FindFirstChild("Head") then
        char.Head.Transparency = 1
        local face = char.Head:FindFirstChild("face")
        if face then face.Transparency = 1 end
    end
end

local function disableNameGui(char)
    if not char then return end
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            obj.Enabled = false
        end
    end
end

local function getHand(char, name) -- FIX (R6/R15)
    return char:FindFirstChild(name) or char:FindFirstChild(name == "RightHand" and "Right Arm" or "Left Arm")
end

local function startNoTeleportKill()
    autoKillActive = true
    equipTool("Punch")

    task.spawn(function()
        while autoKillActive do
            local player = game.Players.LocalPlayer
            if player:FindFirstChild("muscleEvent") then
                player.muscleEvent:FireServer("punch", "rightHand")
                player.muscleEvent:FireServer("punch", "leftHand")
            end

            local myChar = player.Character or player.CharacterAdded:Wait()
            local leftHand = getHand(myChar, "LeftHand") -- FIX
            if not leftHand then task.wait() continue end

            for _, otherPlayer in pairs(game.Players:GetPlayers()) do
                if otherPlayer ~= player and not table.find(whitelist, otherPlayer.Name) then
                    local char = otherPlayer.Character
                    if char and char:FindFirstChild("Head") then
                        makePlayerInvisible(char)
                        disableNameGui(char)

                        char.Head.CFrame = leftHand.CFrame
                        if char:FindFirstChild("sweatPart") then
                            char.sweatPart.CFrame = leftHand.CFrame
                        end
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name == "Handle" then
                                part.CFrame = leftHand.CFrame
                            end
                        end
                    end
                end
            end
            task.wait()
        end
    end)
end

local function startTeleportKill()
    autoKillActive = true
    equipTool("Punch")

    task.spawn(function()
        while autoKillActive do
            local player = game.Players.LocalPlayer
            local myChar = player.Character or player.CharacterAdded:Wait()
            local hrp = myChar:WaitForChild("HumanoidRootPart")

            for _, otherPlayer in pairs(game.Players:GetPlayers()) do
                if otherPlayer ~= player and not table.find(whitelist, otherPlayer.Name) then
                    local char = otherPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local root = char.HumanoidRootPart

                        makePlayerInvisible(char)
                        disableNameGui(char)

                        root.Size = Vector3.new(30, 30, 30)
                        root.Transparency = 1
                        root.CanCollide = false
                        root.CFrame = CFrame.new(1955.3785, 1.7816, 6170.521)

                        local tool = myChar:FindFirstChild("Punch")
                        if tool then tool:Activate() end
                    end
                end
            end

            hrp.CFrame = CFrame.new(1953.2662, 1.7816, 6186.1226)
            task.wait(0.01)
        end
    end)
end

local autoKillSwitch = killingTab:AddSwitch("Enable Auto Kill", function(state)
    autoKillActive = state

    if state then
        if killMethod == "Teleport" then
            startTeleportKill()
        else
            startNoTeleportKill()
        end
    end
end)
autoKillSwitch:Set(false)

local dropdownKillMethod = killingTab:AddDropdown("Kill Method", function(method)
    killMethod = method
end)
dropdownKillMethod:Add("Teleport")
dropdownKillMethod:Add("No Teleport")
dropdownKillMethod:Set("Teleport")

local dropdownWhitelist = killingTab:AddDropdown("Whitelist (Toggle)", function(name)
    local i = table.find(whitelist, name)
    if i then
        table.remove(whitelist, i)
    else
        table.insert(whitelist, name)
    end
end)

for _, p in pairs(game.Players:GetPlayers()) do
    if p ~= game.Players.LocalPlayer then
        dropdownWhitelist:Add(p.Name)
    end
end

game.Players.PlayerAdded:Connect(function(p)
    if p ~= game.Players.LocalPlayer then
        dropdownWhitelist:Add(p.Name)
    end
end)

game.Players.PlayerRemoving:Connect(function(p)
    dropdownWhitelist:Remove(p.Name)
    for i, v in pairs(whitelist) do
        if v == p.Name then table.remove(whitelist, i) end
    end
end)

killingTab:AddLabel("------Auto Kill One Person-------")

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local targetPlayerName = ""
local killTarget = false
local viewing = false

killingTab:AddTextBox("Player Username", function(text)
    targetPlayerName = text
end)

killingTab:AddSwitch("Auto Kill Player", function(bool)
    killTarget = bool

    if killTarget then
        task.spawn(function()
            while killTarget do
                local target = Players:FindFirstChild(targetPlayerName)

                if target and target ~= player then
                    local targetChar = target.Character
                    local rootPart = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

                    if rootPart then
                        local myChar = player.Character
                        local rightHand = myChar and getHand(myChar, "RightHand") -- FIX
                        local leftHand = myChar and getHand(myChar, "LeftHand")   -- FIX

                        if rightHand and leftHand then
                            firetouchinterest(rightHand, rootPart, 1)
                            firetouchinterest(leftHand, rootPart, 1)
                            firetouchinterest(rightHand, rootPart, 0)
                            firetouchinterest(leftHand, rootPart, 0)
                        end
                    end

                    if viewing and targetChar and targetChar:FindFirstChild("Humanoid") then
                        camera.CameraSubject = targetChar.Humanoid
                    end
                end

                task.wait(0.05)
            end
        end)

        task.spawn(function()
            while killTarget do
                if player:FindFirstChild("muscleEvent") then
                    player.muscleEvent:FireServer("punch", "rightHand")
                    player.muscleEvent:FireServer("punch", "leftHand")
                end
                task.wait(0.35)
            end
        end)

    else
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
        end
    end
end)

killingTab:AddSwitch("View Player", function(Value)
    viewing = Value

    if not viewing then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
        end
    end
end)
