local KTA = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local THEME = {
	Accent  = Color3.fromRGB(110, 0, 255),
	Accent2 = Color3.fromRGB(0, 162, 255),
	Background = Color3.fromRGB(18,20,36),
	Panel = Color3.fromRGB(28,30,48),
	Text = Color3.fromRGB(235,235,255)
}

local function tween(o,t,p)
	TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play()
end

--========================================================
--  PUBLIC
--========================================================
function KTA:Create(cfg)
	cfg = cfg or {}
	cfg.Key = cfg.Key or "KTA.2026"
	cfg.Title = cfg.Title or "KTA Panel"

	local self = {}
	self.Tabs = {}

	--====================================================
	-- KEY SCREEN
	--====================================================
	local gui = Instance.new("ScreenGui")
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = plr:WaitForChild("PlayerGui")

	local keyframe = Instance.new("Frame",gui)
	keyframe.Size = UDim2.fromScale(.3,.23)
	keyframe.Position = UDim2.fromScale(.35,.38)
	keyframe.BackgroundColor3 = THEME.Panel
	keyframe.ClipsDescendants = true
	keyframe.Active = true
	keyframe.Draggable = true
	Instance.new("UICorner",keyframe).CornerRadius = UDim.new(0,16)

	local stroke = Instance.new("UIStroke",keyframe)
	stroke.Color = THEME.Accent
	stroke.Thickness = 2

	local title = Instance.new("TextLabel",keyframe)
	title.Size = UDim2.fromScale(1,.28)
	title.BackgroundTransparency = 1
	title.Text = "Enter Access Key"
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = THEME.Text
	title.TextScaled = true

	local box = Instance.new("TextBox",keyframe)
	box.Size = UDim2.fromScale(.85,.27)
	box.Position = UDim2.fromScale(.075,.4)
	box.PlaceholderText = "Type here"
	box.Text = ""
	box.BackgroundColor3 = THEME.Background
	box.TextColor3 = THEME.Text
	box.Font = Enum.Font.Gotham
	box.TextScaled = true
	Instance.new("UICorner",box).CornerRadius = UDim.new(0,10)

	local go = Instance.new("TextButton",keyframe)
	go.Size = UDim2.fromScale(.55,.23)
	go.Position = UDim2.fromScale(.23,.73)
	go.Text = "Continue"
	go.Font = Enum.Font.GothamBold
	go.TextScaled = true
	go.TextColor3 = Color3.new(1,1,1)
	go.BackgroundColor3 = THEME.Accent
	Instance.new("UICorner",go).CornerRadius = UDim.new(0,10)

	-- LOADER BAR
	local loadbar = Instance.new("Frame",keyframe)
	loadbar.Size = UDim2.fromScale(0,.05)
	loadbar.Position = UDim2.fromScale(.075,.9)
	loadbar.BackgroundColor3 = THEME.Accent2
	loadbar.Visible = false
	Instance.new("UICorner",loadbar)

	keyframe.Size = UDim2.fromScale(0,0)
	tween(keyframe,.35,{Size=UDim2.fromScale(.3,.23)})

	--====================================================
	-- MAIN UI (LOCKED)
	--====================================================
	local main = Instance.new("Frame",gui)
	main.Visible = false
	main.Size = UDim2.fromScale(.43,.45)
	main.Position = UDim2.fromScale(.285,.24)
	main.BackgroundColor3 = THEME.Panel
	main.Active = true
	main.Draggable = true
	main.ClipsDescendants = true
	Instance.new("UICorner",main).CornerRadius = UDim.new(0,16)

	local bar = Instance.new("Frame",main)
	bar.Size = UDim2.fromScale(1,.14)
	bar.BackgroundColor3 = THEME.Background
	Instance.new("UICorner",bar)

	local head = Instance.new("TextLabel",bar)
	head.Text = cfg.Title
	head.Size = UDim2.fromScale(.7,1)
	head.BackgroundTransparency = 1
	head.Position = UDim2.fromScale(.05,0)
	head.Font = Enum.Font.GothamBold
	head.TextScaled = true
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.TextColor3 = THEME.Text

	local min = Instance.new("TextButton",bar)
	min.Text = "-"
	min.Size = UDim2.fromScale(.12,.72)
	min.Position = UDim2.fromScale(.83,.14)
	min.BackgroundColor3 = THEME.Accent
	Instance.new("UICorner",min)
	min.Font = Enum.Font.GothamBold
	min.TextScaled = true
	min.TextColor3 = Color3.new(1,1,1)

	local tabs = Instance.new("Frame",main)
	tabs.Size = UDim2.fromScale(.25,.86)
	tabs.Position = UDim2.fromScale(0,.14)
	tabs.BackgroundColor3 = THEME.Background
	Instance.new("UICorner",tabs)

	local content = Instance.new("Frame",main)
	content.Size = UDim2.fromScale(.75,.86)
	content.Position = UDim2.fromScale(.25,.14)
	content.BackgroundColor3 = THEME.Panel
	Instance.new("UICorner",content)

	--====================================================
	-- MINIMIZE LOGO
	--====================================================
	local logo = Instance.new("Frame",gui)
	logo.Visible = false
	logo.Size = UDim2.fromScale(.06,.1)
	logo.Position = UDim2.fromScale(.03,.84)
	logo.BackgroundColor3 = THEME.Panel
	Instance.new("UICorner",logo).CornerRadius = UDim.new(1,0)

	local lg = Instance.new("TextLabel",logo)
	lg.Text = "KTA"
	lg.Size = UDim2.fromScale(1,1)
	lg.BackgroundTransparency = 1
	lg.TextScaled = true
	lg.Font = Enum.Font.GothamBlack
	lg.TextColor3 = THEME.Accent2

	local minimized = false
	local function minimize()
		minimized = true
		tween(main,.25,{Size=UDim2.fromScale(0,0),Transparency=1})
		task.wait(.25)
		main.Visible = false
		logo.Visible = true
	end
	local function restore()
		minimized = false
		logo.Visible = false
		main.Visible = true
		main.Size = UDim2.fromScale(0,0)
		tween(main,.25,{Size=UDim2.fromScale(.43,.45),Transparency=0})
	end

	min.MouseButton1Click:Connect(function()
		if minimized then restore() else minimize() end
	end)

	logo.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then
			if minimized then restore() end
		end
	end)

	--====================================================
	-- KEY VALIDATION + LOADER
	--====================================================
	go.MouseButton1Click:Connect(function()
		if box.Text ~= cfg.Key then
			tween(box,.1,{BackgroundColor3=Color3.fromRGB(120,0,0)})
			task.wait(.15)
			tween(box,.15,{BackgroundColor3=THEME.Background})
			return
		end

		loadbar.Visible = true
		tween(loadbar,.7,{Size=UDim2.fromScale(.85,.05)})
		task.wait(.75)

		tween(keyframe,.3,{Size=UDim2.fromScale(0,0)})
		task.wait(.28)
		keyframe:Destroy()

		restore()
	end)

	--====================================================
	-- SIMPLE TAB API
	--====================================================
	function self:AddTab(name)
		local btn = Instance.new("TextButton",tabs)
		btn.Text = name
		btn.Size = UDim2.fromScale(1,0.12)
		btn.BackgroundTransparency = .1
		btn.BackgroundColor3 = THEME.Panel
		btn.Font = Enum.Font.Gotham
		btn.TextScaled = true
		btn.TextColor3 = THEME.Text
		Instance.new("UICorner",btn).CornerRadius = UDim.new(0,10)

		local page = Instance.new("Frame",content)
		page.Size = UDim2.fromScale(1,1)
		page.BackgroundTransparency = 1
		page.Visible = false

		btn.MouseButton1Click:Connect(function()
			for _,v in ipairs(content:GetChildren()) do
				if v:IsA("Frame") then v.Visible=false end
			end
			page.Visible = true
		end)

		local api = {}
		function api:AddLabel(text)
			local l = Instance.new("TextLabel",page)
			l.Text = text
			l.Size = UDim2.fromScale(.9,.12)
			l.Position = UDim2.fromScale(.05,.05)
			l.BackgroundTransparency = 1
			l.TextScaled = true
			l.Font = Enum.Font.GothamSemibold
			l.TextColor3 = THEME.Text
			return l
		end

		page.Visible = (#self.Tabs==0)
		table.insert(self.Tabs,api)
		return api
	end

	return self
end

return KTA
