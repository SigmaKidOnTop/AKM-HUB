local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/memejames/elerium-v2-ui-library/main/Library", true))()

local displayname = game:GetService("Players").LocalPlayer.DisplayName


local window = library:AddWindow("👑Victory👑 - Welcome "..displayname, {
    main_color = Color3.fromRGB(106, 0, 255),
    min_size = Vector2.new(400, 700),
    can_resize = false,
})




local Killer = window:AddTab("👑Kill Them All")
KillerTab:Show()

local antiKnockbackSwitch = KillerTab:AddSwitch("Anti Knockback", function(bool)
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

local frameSwitch = KillerTab:AddSwitch("Hide All Frames", function(bool)
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

local antiLagSwitch = KillerTab:AddSwitch("Anti Lag", function(bool)
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



local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local playerWhitelist = {}
local targetPlayerNames = {}
local autoGoodKarma = false
local autoBadKarma = false
local autoKill = false
local killTarget = false
local spying = false
local autoEquipPunch = false
local autoPunchNoAnim = false
local targetDropdownItems = {}
local availableTargets = {}

Killer:AddSwitch("Auto Good Karma", function(bool)
    autoGoodKarma = bool
    task.spawn(function()
        while autoGoodKarma do
            local playerChar = LocalPlayer.Character
            local rightHand = playerChar and playerChar:FindFirstChild("RightHand")
            local leftHand = playerChar and playerChar:FindFirstChild("LeftHand")
            if playerChar and rightHand and leftHand then
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer then
                        local evilKarma = target:FindFirstChild("evilKarma")
                        local goodKarma = target:FindFirstChild("goodKarma")
                        if evilKarma and goodKarma and evilKarma:IsA("IntValue") and goodKarma:IsA("IntValue") and evilKarma.Value > goodKarma.Value then
                            local rootPart = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                            if rootPart then
                                firetouchinterest(rightHand, rootPart, 1)
                                firetouchinterest(leftHand, rootPart, 1)
                                firetouchinterest(rightHand, rootPart, 0)
                                firetouchinterest(leftHand, rootPart, 0)
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
            local playerChar = LocalPlayer.Character
            local rightHand = playerChar and playerChar:FindFirstChild("RightHand")
            local leftHand = playerChar and playerChar:FindFirstChild("LeftHand")
            if playerChar and rightHand and leftHand then
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer then
                        local evilKarma = target:FindFirstChild("evilKarma")
                        local goodKarma = target:FindFirstChild("goodKarma")
                        if evilKarma and goodKarma and evilKarma:IsA("IntValue") and goodKarma:IsA("IntValue") and goodKarma.Value > evilKarma.Value then
                            local rootPart = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                            if rootPart then
                                firetouchinterest(rightHand, rootPart, 1)
                                firetouchinterest(leftHand, rootPart, 1)
                                firetouchinterest(rightHand, rootPart, 0)
                                firetouchinterest(leftHand, rootPart, 0)
                            end
                        end
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local friendWhitelistActive = false

Killer:AddSwitch("Auto Whitelist Friends", function(state)
    friendWhitelistActive = state

    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and LocalPlayer:IsFriendsWith(player.UserId) then
                playerWhitelist[player.Name] = true
            end
        end

        Players.PlayerAdded:Connect(function(player)
            if friendWhitelistActive and player ~= LocalPlayer and LocalPlayer:IsFriendsWith(player.UserId) then
                playerWhitelist[player.Name] = true
            end
        end)
    else
        for name in pairs(playerWhitelist) do
            local friend = Players:FindFirstChild(name)
            if friend and LocalPlayer:IsFriendsWith(friend.UserId) then
                playerWhitelist[name] = nil
            end
        end
    end
end)

Killer:AddTextBox("Whitelist", function(text)
    local target = Players:FindFirstChild(text)
    if target then
        playerWhitelist[target.Name] = true
    end
end)

Killer:AddTextBox("UnWhitelist", function(text)
    local target = Players:FindFirstChild(text)
    if target then
        playerWhitelist[target.Name] = nil
    end
end)

Killer:AddSwitch("Auto Kill", function(bool)
    autoKill = bool

    task.spawn(function()
        while autoKill do
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local rightHand = character:FindFirstChild("RightHand")
            local leftHand = character:FindFirstChild("LeftHand")

            local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
            if punch and not character:FindFirstChild("Punch") then
                punch.Parent = character
            end

            if rightHand and leftHand then
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= LocalPlayer and not playerWhitelist[target.Name] then
                        local targetChar = target.Character
                        local rootPart = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            pcall(function()
                                firetouchinterest(rightHand, rootPart, 1)
                                firetouchinterest(leftHand, rootPart, 1)
                                firetouchinterest(rightHand, rootPart, 0)
                                firetouchinterest(leftHand, rootPart, 0)
                            end)
                        end
                    end
                end
            end

            task.wait(0.05)
        end
    end)
end)

local targetDropdown = Killer:AddDropdown("Select Target", function(name)
    if name and not table.find(targetPlayerNames, name) then
        table.insert(targetPlayerNames, name)
    end
end)

Killer:AddTextBox("Remove Target", function(name)
    for i, v in ipairs(targetPlayerNames) do
        if v == name then
            table.remove(targetPlayerNames, i)
            break
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        targetDropdown:Add(player.Name)
        targetDropdownItems[player.Name] = true
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        targetDropdown:Add(player.Name)
        targetDropdownItems[player.Name] = true
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if targetDropdownItems[player.Name] then
        targetDropdownItems[player.Name] = nil
        targetDropdown:Clear()
        for name in pairs(targetDropdownItems) do
            targetDropdown:Add(name)
        end
    end

    for i = #targetPlayerNames, 1, -1 do
        if targetPlayerNames[i] == player.Name then
            table.remove(targetPlayerNames, i)
        end
    end
end)

Killer:AddSwitch("Start Kill Target", function(state)
    killTarget = state

    task.spawn(function()
        while killTarget do
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
            if punch and not character:FindFirstChild("Punch") then
                punch.Parent = character
            end

            local rightHand = character:WaitForChild("RightHand", 5)
            local leftHand = character:WaitForChild("LeftHand", 5)

            if rightHand and leftHand then
                for _, name in ipairs(targetPlayerNames) do
                    local target = Players:FindFirstChild(name)
                    if target and target ~= LocalPlayer then
                        local rootPart = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            pcall(function()
                                firetouchinterest(rightHand, rootPart, 1)
                                firetouchinterest(leftHand, rootPart, 1)
                                firetouchinterest(rightHand, rootPart, 0)
                                firetouchinterest(leftHand, rootPart, 0)
                            end)
                        end
                    end
                end
            end

            task.wait(0.05)
        end
    end)
end)

local spyTargetDropdown = Killer:AddDropdown("Select View Target", function(name)
    targetPlayerName = name
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        spyTargetDropdown:Add(player.Name)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        spyTargetDropdown:Add(player.Name)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player ~= LocalPlayer then
        spyTargetDropdown:Clear()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                spyTargetDropdown:Add(plr.Name)
            end
        end
    end
end)

Killer:AddSwitch("View Player", function(bool)
    spying = bool
    if not spying then
        local cam = workspace.CurrentCamera
        cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer
        return
    end
    task.spawn(function()
        while spying do
            local target = Players:FindFirstChild(targetPlayerName)
            if target and target ~= LocalPlayer then
                local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
                if humanoid then
                    workspace.CurrentCamera.CameraSubject = humanoid
                end
            end
            task.wait(0.1)
        end
    end)
end)

local button = Killer:AddButton("Remove Punch Anim", function()
    local blockedAnimations = {
        ["rbxassetid://3638729053"] = true,
        ["rbxassetid://3638767427"] = true,
    }

    local function setupAnimationBlocking()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("Humanoid") then return end

        local humanoid = char:FindFirstChild("Humanoid")

        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Animation then
                local animId = track.Animation.AnimationId
                local animName = track.Name:lower()

                if blockedAnimations[animId] or
                    animName:match("punch") or
                    animName:match("attack") or
                    animName:match("right") then
                    track:Stop()
                end
            end
        end

        if not _G.AnimBlockConnection then
            local connection = humanoid.AnimationPlayed:Connect(function(track)
                if track.Animation then
                    local animId = track.Animation.AnimationId
                    local animName = track.Name:lower()

                    if blockedAnimations[animId] or
                        animName:match("punch") or
                        animName:match("attack") or
                        animName:match("right") then
                        track:Stop()
                    end
                end
            end)

            _G.AnimBlockConnection = connection
        end
    end

    setupAnimationBlocking()

    local function overrideToolActivation()
        local function processTool(tool)
            if tool and (tool.Name == "Punch" or tool.Name:match("Attack") or tool.Name:match("Right")) then
                if not tool:GetAttribute("ActivatedOverride") then
                    tool:SetAttribute("ActivatedOverride", true)

                    local connection = tool.Activated:Connect(function()
                        task.wait(0.05)

                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                                if track.Animation then
                                    local animId = track.Animation.AnimationId
                                    local animName = track.Name:lower()

                                    if blockedAnimations[animId] or
                                        animName:match("punch") or
                                        animName:match("attack") or
                                        animName:match("right") then
                                        track:Stop()
                                    end
                                end
                            end
                        end
                    end)

                    if not _G.ToolConnections then
                        _G.ToolConnections = {}
                    end
                    _G.ToolConnections[tool] = connection
                end
            end
        end

        for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            processTool(tool)
        end

        local char = game.Players.LocalPlayer.Character
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    processTool(tool)
                end
            end
        end

        if not _G.BackpackAddedConnection then
            _G.BackpackAddedConnection = game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    task.wait(0.1)
                    processTool(child)
                end
            end)
        end

        if not _G.CharacterToolAddedConnection and char then
            _G.CharacterToolAddedConnection = char.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    task.wait(0.1)
                    processTool(child)
                end
            end)
        end
    end

    overrideToolActivation()

    if not _G.AnimMonitorConnection then
        _G.AnimMonitorConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if tick() % 0.5 < 0.01 then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                        if track.Animation then
                            local animId = track.Animation.AnimationId
                            local animName = track.Name:lower()

                            if blockedAnimations[animId] or
                                animName:match("punch") or
                                animName:match("attack") or
                                animName:match("right") then
                                track:Stop()
                            end
                        end
                    end
                end
            end
        end)
    end

    if not _G.CharacterAddedConnection then
        _G.CharacterAddedConnection = game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(1)
            setupAnimationBlocking()
            overrideToolActivation()

            if _G.CharacterToolAddedConnection then
                _G.CharacterToolAddedConnection:Disconnect()
            end

            _G.CharacterToolAddedConnection = newChar.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    task.wait(0.1)
                    processTool(child)
                end
            end)
        end)
    end
end)

function RecoveryPunch()
    if _G.AnimBlockConnection then
        _G.AnimBlockConnection:Disconnect()
        _G.AnimBlockConnection = nil
    end
    if _G.AnimMonitorConnection then
        _G.AnimMonitorConnection:Disconnect()
        _G.AnimMonitorConnection = nil
    end
    if _G.ToolConnections then
        for _, conn in pairs(_G.ToolConnections) do
            if conn then conn:Disconnect() end
        end
        _G.ToolConnections = nil
    end
    if _G.BackpackAddedConnection then
        _G.BackpackAddedConnection:Disconnect()
        _G.BackpackAddedConnection = nil
    end
    if _G.CharacterToolAddedConnection then
        _G.CharacterToolAddedConnection:Disconnect()
        _G.CharacterToolAddedConnection = nil
    end
    if _G.CharacterAddedConnection then
        _G.CharacterAddedConnection:Disconnect()
        _G.CharacterAddedConnection = nil
    end
end

Killer:AddButton("Recover Punch Anim", function()
    RecoveryPunch()
end)

Killer:AddSwitch("Auto Equip Punch", function(state)
	autoEquipPunch = state
	task.spawn(function()
		while autoEquipPunch do
			local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
			if punch then
				punch.Parent = LocalPlayer.Character
			end
			task.wait(0.1)
		end
	end)
end)

Killer:AddSwitch("Auto Punch [No Animation]", function(state)
	autoPunchNoAnim = state
	task.spawn(function()
		while autoPunchNoAnim do
			local punch = LocalPlayer.Backpack:FindFirstChild("Punch") or LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
			if punch then
				if punch.Parent ~= LocalPlayer.Character then
					punch.Parent = LocalPlayer.Character
				end
				LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
				LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
			else
				autoPunchNoAnim = false
			end
			task.wait(0.01)
		end
	end)
end)

Killer:AddSwitch("Auto Punch", function(state)
	_G.fastHitActive = state
	if state then
		task.spawn(function()
			while _G.fastHitActive do
				local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
				if punch then
					punch.Parent = LocalPlayer.Character
					if punch:FindFirstChild("attackTime") then
						punch.attackTime.Value = 0
					end
				end
				task.wait(0.1)
			end
		end)
		task.spawn(function()
			while _G.fastHitActive do
				local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
				if punch then
					punch:Activate()
				end
				task.wait(0.1)
			end
		end)
	else
		local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
		if punch then
			punch.Parent = LocalPlayer.Backpack
		end
	end
end)

Killer:AddSwitch("Fast Punch", function(state)
	_G.autoPunchActive = state
	if state then
		task.spawn(function()
			while _G.autoPunchActive do
				local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
				if punch then
					punch.Parent = LocalPlayer.Character
					if punch:FindFirstChild("attackTime") then
						punch.attackTime.Value = 0
					end
				end
				task.wait()
			end
		end)
		task.spawn(function()
			while _G.autoPunchActive do
				local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
				if punch then
					punch:Activate()
				end
				task.wait()
			end
		end)
	else
		local punch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Punch")
		if punch then
			punch.Parent = LocalPlayer.Backpack
		end
	end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


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
