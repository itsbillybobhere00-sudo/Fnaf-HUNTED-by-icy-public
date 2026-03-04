task.wait(2)

--------------------------------------------------
-- ACCOUNT LOCKED KEY SYSTEM
--------------------------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🔑 Keys locked to specific UserIds
-- Replace the numbers with the actual UserIds
local VALID_KEYS = {
	["jb123"] = 1359858241,   -- Only works for this UserId
	["ESPACCESS"] = 87654321,
	["FREEKEY"] = 11223344
}

local unlocked = false

-- Create Key GUI
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KeySystemGui"
KeyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 160)
Frame.Position = UDim2.new(0.5, -150, 0.5, -80)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BorderSizePixel = 0
Frame.Parent = KeyGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "Enter Key"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Parent = Frame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8,0,0,35)
KeyBox.Position = UDim2.new(0.1,0,0.4,0)
KeyBox.PlaceholderText = "Enter key here..."
KeyBox.Text = ""
KeyBox.TextScaled = true
KeyBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
KeyBox.TextColor3 = Color3.new(1,1,1)
KeyBox.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,0,0,25)
Status.Position = UDim2.new(0,0,0.75,0)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextScaled = true
Status.Parent = Frame

local Verify = Instance.new("TextButton")
Verify.Size = UDim2.new(0.6,0,0,30)
Verify.Position = UDim2.new(0.2,0,0.65,0)
Verify.Text = "Verify"
Verify.TextScaled = true
Verify.BackgroundColor3 = Color3.fromRGB(120,0,0)
Verify.TextColor3 = Color3.new(1,1,1)
Verify.Parent = Frame

Verify.MouseButton1Click:Connect(function()
	local key = KeyBox.Text
	local playerId = LocalPlayer.UserId
	
	if VALID_KEYS[key] and VALID_KEYS[key] == playerId then
		unlocked = true
		Status.Text = "Access Granted!"
		Status.TextColor3 = Color3.fromRGB(0,255,0)
		
		task.wait(0.8)
		KeyGui:Destroy()
	else
		Status.Text = "Invalid Key or Not Your Account!"
		Status.TextColor3 = Color3.fromRGB(255,0,0)
	end
end)

-- 🔒 HARD LOCK (stops entire script below from running)
repeat task.wait() until unlocked

--------------------------------------------------
-- UI SETUP
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0,50,0,50)
OpenButton.Position = UDim2.new(0,10,0.5,-25)
OpenButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
OpenButton.TextColor3 = Color3.fromRGB(255,255,255)
OpenButton.Text = "ESP"
OpenButton.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,200,0,230)
MainFrame.Position = UDim2.new(0,-210,0.5,-115)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0,5)

local isOpen = false
OpenButton.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	TweenService:Create(MainFrame, TweenInfo.new(0.3), {
		Position = isOpen and UDim2.new(0,70,0.5,-115) or UDim2.new(0,-210,0.5,-115)
	}):Play()
end)

local function createButton(text)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1,-10,0,35)
	button.BackgroundColor3 = Color3.fromRGB(120,0,0)
	button.TextColor3 = Color3.fromRGB(255,255,255)
	button.Text = text .. ": OFF"
	button.Parent = MainFrame
	return button
end

local function toggle(button, state)
	state = not state
	if state then
		button.BackgroundColor3 = Color3.fromRGB(0,120,0)
		button.Text = button.Text:gsub("OFF","ON")
	else
		button.BackgroundColor3 = Color3.fromRGB(120,0,0)
		button.Text = button.Text:gsub("ON","OFF")
	end
	return state
end

local PlayerESPButton = createButton("Player ESP")
local MonsterESPButton = createButton("Monster ESP")
local CageESPButton = createButton("Cage ESP")
local ComputerESPButton = createButton("Computer ESP")

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

local function removeAllHighlights(name)
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Highlight") and obj.Name == name then
			obj:Destroy()
		end
	end
end

--------------------------------------------------
-- SURVIVOR SYSTEM (Clean + Stable)
--------------------------------------------------

task.spawn(function()
	while true do
		if PlayerESPEnabled then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then

					local role = plr:GetAttribute("Role")
					local highlight = plr.Character:FindFirstChild("SurvivorHighlight")

					if role == "Survivor" then
						if not highlight then
							highlight = Instance.new("Highlight")
							highlight.Name = "SurvivorHighlight"
							highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							highlight.Parent = plr.Character
						end

						local beingCarried = plr:GetAttribute("BeingCarried")

						if beingCarried then
							highlight.FillColor = Color3.fromRGB(255,0,255)
							highlight.OutlineColor = Color3.fromRGB(255,0,255)
						else
							highlight.FillColor = Color3.fromRGB(0,255,0)
							highlight.OutlineColor = Color3.fromRGB(0,255,0)
						end

					else
						if highlight then
							highlight:Destroy()
						end
					end

				end
			end
		end

		task.wait(0.5) -- light refresh, no lag
	end
end)

--------------------------------------------------
-- COMPUTER SYSTEM (Large Nametag + Proper Toggle)
--------------------------------------------------

local function monitorComputer(obj)
	if monitoredComputers[obj] then return end
	monitoredComputers[obj] = true

	local function getMainPart()
		for _, v in pairs(obj:GetDescendants()) do
			if v:IsA("BasePart") then
				return v
			end
		end
	end

	local function createBar()
		local mainPart = getMainPart()
		if not mainPart then return end
		if mainPart:FindFirstChild("ComputerBar") then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ComputerBar"
		billboard.Size = UDim2.new(6, 0, 1.2, 0) -- BIGGER
		billboard.StudsOffset = Vector3.new(0, 7, 0) -- Higher
		billboard.AlwaysOnTop = true
		billboard.MaxDistance = 200
		billboard.Parent = mainPart

		local background = Instance.new("Frame")
		background.Name = "Background"
		background.Size = UDim2.new(1, 0, 1, 0)
		background.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		background.BorderSizePixel = 0
		background.Parent = billboard

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
		fill.BorderSizePixel = 0
		fill.Parent = background
	end

	local function removeVisuals()
		local highlight = obj:FindFirstChild("ComputerHighlight")
		if highlight then highlight:Destroy() end

		local mainPart = getMainPart()
		if mainPart then
			local bar = mainPart:FindFirstChild("ComputerBar")
			if bar then bar:Destroy() end
		end
	end

	local function update()
		local mainPart = getMainPart()
		if not mainPart then return end

		if not ComputerESPEnabled then
			removeVisuals()
			return
		end

		local progress = obj:GetAttribute("Progress") or 0
		local completed = obj:GetAttribute("Completed")

		-- Highlight
		local highlight = obj:FindFirstChild("ComputerHighlight")
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "ComputerHighlight"
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = obj
		end

		if completed then
			highlight.FillColor = Color3.fromRGB(128,0,128)
			highlight.OutlineColor = Color3.fromRGB(128,0,128)
		else
			highlight.FillColor = Color3.fromRGB(0,170,255)
			highlight.OutlineColor = Color3.fromRGB(0,170,255)
		end

		-- Progress bar
		createBar()

		local bar = mainPart:FindFirstChild("ComputerBar")
		if bar then
			local background = bar:FindFirstChild("Background")
			local fill = background and background:FindFirstChild("Fill")

			if fill then
				local target = UDim2.new(math.clamp(progress / 100, 0, 1), 0, 1, 0)
				fill:TweenSize(target, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
			end
		end
	end

	obj:GetAttributeChangedSignal("Progress"):Connect(update)
	obj:GetAttributeChangedSignal("Completed"):Connect(update)

	update()
end

--------------------------------------------------
-- CLEANUP LOOP (Fix Toggle Issue)
--------------------------------------------------

task.spawn(function()
	while true do
		task.wait(0.5)
		if not ComputerESPEnabled then
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("Model") and obj.Name == "Computer" then
					local highlight = obj:FindFirstChild("ComputerHighlight")
					if highlight then highlight:Destroy() end

					for _, part in pairs(obj:GetDescendants()) do
						if part:IsA("BasePart") then
							local bar = part:FindFirstChild("ComputerBar")
							if bar then bar:Destroy() end
						end
					end
				end
			end
		end
	end
end)

--------------------------------------------------
-- MONSTER SYSTEM (Neon Pink + Clean Refresh)
--------------------------------------------------

local function updateMonsters()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then

			local role = plr:GetAttribute("Role")
			local highlight = plr.Character:FindFirstChild("MonsterHighlight")

			if role == "Monster" then
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "MonsterHighlight"
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Parent = plr.Character
				end

				-- ULTRA NEON PINK
				highlight.FillColor = Color3.fromRGB(255, 0, 200)
				highlight.OutlineColor = Color3.fromRGB(255, 0, 255)

				highlight.FillTransparency = 0.15   -- very solid glow
				highlight.OutlineTransparency = 0   -- strong outline

			else
				if highlight then
					highlight:Destroy()
				end
			end

		end
	end
end

-- 15 second refresh loop (only one)
task.spawn(function()
	while true do
		if MonsterESPEnabled then
			updateMonsters()
		end
		task.wait(15)
	end
end)

--------------------------------------------------
-- CAGE SYSTEM (instant + 10s update)
--------------------------------------------------

local function scanCages()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name == "Hooks" then
			for _, cage in pairs(obj:GetChildren()) do
				if not cage:FindFirstChild("CageHighlight") then
					local h = Instance.new("Highlight")
					h.Name = "CageHighlight"
					h.FillColor = Color3.fromRGB(255,255,0)
					h.OutlineColor = Color3.fromRGB(255,255,0)
					h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					h.Parent = cage
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		if CageESPEnabled then
			scanCages()
		end
		task.wait(10)
	end
end)

--------------------------------------------------
-- INITIAL SCAN
--------------------------------------------------

-- Initial computer scan only
for _, obj in pairs(workspace:GetDescendants()) do
	if obj.Name == "Computer" and obj:IsA("Model") then
		monitorComputer(obj)
	end
end

--------------------------------------------------
-- BUTTON CONNECTIONS
--------------------------------------------------

PlayerESPButton.MouseButton1Click:Connect(function()
	PlayerESPEnabled = toggle(PlayerESPButton, PlayerESPEnabled)

	if not PlayerESPEnabled then
		removeAllHighlights("SurvivorHighlight")
	end
end)

MonsterESPButton.MouseButton1Click:Connect(function()
	MonsterESPEnabled = toggle(MonsterESPButton, MonsterESPEnabled)
	if MonsterESPEnabled then
		updateMonsters()
	else
		removeAllHighlights("MonsterHighlight")
	end
end)

CageESPButton.MouseButton1Click:Connect(function()
	CageESPEnabled = toggle(CageESPButton, CageESPEnabled)

	if CageESPEnabled then
		scanCages() -- instant first scan
	else
		removeAllHighlights("CageHighlight")
	end
end)

ComputerESPButton.MouseButton1Click:Connect(function()
	ComputerESPEnabled = toggle(ComputerESPButton, ComputerESPEnabled)

	if ComputerESPEnabled then
		-- Instant refresh of ALL computers
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj.Name == "Computer" and obj:IsA("Model") then
				
				local completed = obj:GetAttribute("Completed")

				local highlight = obj:FindFirstChild("ComputerHighlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "ComputerHighlight"
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Parent = obj
				end

				if completed == true then
					highlight.FillColor = Color3.fromRGB(128,0,128) -- finished
					highlight.OutlineColor = Color3.fromRGB(128,0,128)
				else
					highlight.FillColor = Color3.fromRGB(0,170,255) -- unfinished
					highlight.OutlineColor = Color3.fromRGB(0,170,255)
				end
			end
		end
	else
		removeAllHighlights("ComputerHighlight")
	end
end)

task.wait(5)
task.wait(2)
-- FLY GUI
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Mobile-Fly-gui-script-113269"))()

task.wait(2)
-- NOCLIP
-- icys menu - Noclip
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local noclipEnabled = false

local function applyNoclip()
	if player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not noclipEnabled
			end
		end
	end
end

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)

-- Set the frame size in pixels
frame.Size = UDim2.new(0, 200, 0, 50) -- 200px wide, 50px tall

-- Position it at the top-right of the parent GUI
frame.Position = UDim2.new(1, -200, 0, 0) -- scaleX=1 minus frame width, top=0

frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.Text = "Noclip - by icy"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1,-20,0,40)
button.Position = UDim2.new(0,10,0,50)
button.Text = "Noclip: Off"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(50,50,60)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Font = Enum.Font.Gotham

button.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	if noclipEnabled then
		button.Text = "Noclip: On"
	else
		button.Text = "Noclip: Off"
	end
	applyNoclip()
end)

RunService.Stepped:Connect(function()
	if noclipEnabled then
		applyNoclip()
	end
end)

-- Aplica no respawn
player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	if noclipEnabled then
		applyNoclip()
	end
end)
