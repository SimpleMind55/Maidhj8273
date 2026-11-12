--[[
  x adra · Degrade
  PlaceId: 129437813830973
  WindUI · ESP / Combat / Visual
]]

local PLACE_ID = 129437813830973

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- soft place check (warn only)
pcall(function()
	if game.PlaceId ~= PLACE_ID then
		warn("[x adra] PlaceId differs from Degrade target — script still runs")
	end
end)

local WindUI = loadstring(game:HttpGetAsync("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------
local S = {
	ESP = {
		Enabled = false,
		MaxDist = 400,
		ShowName = true,
		TextSize = 14,
		ShowTool = true,
		ShowSkeleton = true,
		TeamCheck = false,
	},
	Combat = {
		Aimbot = false,
		Silent = false,
		FOV = 120,
		ShowFOV = true,
		Smooth = 0.18,
		TeamCheck = true,
		AimPart = "Head",
	},
	Visual = {
		Fullbright = false,
		Potato = false,
	},
}

local ESPStore = {} -- [player] = { billboard, lines, highlight }
local FOVCircle = nil
local Connections = {}
local LightingBackup = nil
local PotatoApplied = false

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
local function safe(fn, ...)
	local ok, a, b = pcall(fn, ...)
	if ok then return a, b end
	return nil
end

local function getChar(plr)
	return plr and plr.Character
end

local function getHum(char)
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot(char)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

local function getPart(char, name)
	if not char then return nil end
	return char:FindFirstChild(name)
end

local function isAlive(plr)
	local char = getChar(plr)
	local hum = getHum(char)
	return char and hum and hum.Health > 0 and getRoot(char) ~= nil
end

local function sameTeam(plr)
	if not S.Combat.TeamCheck and not S.ESP.TeamCheck then return false end
	if not LP.Team or not plr.Team then return false end
	return LP.Team == plr.Team
end

local function worldToScreen(pos)
	local v, on = Camera:WorldToViewportPoint(pos)
	return Vector2.new(v.X, v.Y), on, v.Z
end

local function equippedToolName(char)
	if not char then return nil end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then return tool.Name end
	local ok, inv = pcall(function()
		return LP:FindFirstChild("Backpack")
	end)
	return nil
end

local function equippedOf(plr)
	local char = getChar(plr)
	if not char then return "—" end
	local tool = char:FindFirstChildOfClass("Tool")
	return tool and tool.Name or "—"
end

local function aimTargetPart(char)
	local prefer = S.Combat.AimPart or "Head"
	return getPart(char, prefer) or getPart(char, "Head") or getRoot(char)
end

----------------------------------------------------------------------
-- FOV circle (Drawing if available, else ScreenGui fallback)
----------------------------------------------------------------------
local function destroyFOV()
	if FOVCircle then
		pcall(function() FOVCircle:Remove() end)
		pcall(function() FOVCircle:Destroy() end)
		FOVCircle = nil
	end
	local g = CoreGui:FindFirstChild("xadra_fov")
	if g then g:Destroy() end
	local pg = LP:FindFirstChild("PlayerGui")
	if pg then
		local g2 = pg:FindFirstChild("xadra_fov")
		if g2 then g2:Destroy() end
	end
end

local function ensureFOV()
	destroyFOV()
	if not S.Combat.ShowFOV then return end

	if Drawing and typeof(Drawing.new) == "function" then
		local c = Drawing.new("Circle")
		c.Thickness = 1.5
		c.NumSides = 64
		c.Radius = S.Combat.FOV
		c.Filled = false
		c.Transparency = 0.85
		c.Color = Color3.fromRGB(120, 200, 255)
		c.Visible = true
		FOVCircle = c
		return
	end

	-- ScreenGui ring fallback
	local parent = (gethui and gethui()) or CoreGui
	local sg = Instance.new("ScreenGui")
	sg.Name = "xadra_fov"
	sg.IgnoreGuiInset = true
	sg.ResetOnSpawn = false
	sg.Parent = parent

	local ring = Instance.new("Frame")
	ring.Name = "Ring"
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Position = UDim2.fromScale(0.5, 0.5)
	ring.BackgroundTransparency = 1
	ring.Parent = sg
	Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
	local st = Instance.new("UIStroke", ring)
	st.Color = Color3.fromRGB(120, 200, 255)
	st.Thickness = 1.5
	st.Transparency = 0.35
	FOVCircle = sg
end

local function updateFOV()
	if not S.Combat.ShowFOV then
		destroyFOV()
		return
	end
	if not FOVCircle then ensureFOV() end
	if not FOVCircle then return end

	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X / 2, vp.Y / 2)

	if typeof(FOVCircle) == "Instance" then
		local ring = FOVCircle:FindFirstChild("Ring")
		if ring then
			local d = S.Combat.FOV * 2
			ring.Size = UDim2.fromOffset(d, d)
			ring.Position = UDim2.fromOffset(center.X, center.Y)
		end
	else
		-- Drawing
		pcall(function()
			FOVCircle.Position = center
			FOVCircle.Radius = S.Combat.FOV
			FOVCircle.Visible = true
		end)
	end
end

----------------------------------------------------------------------
-- ESP
----------------------------------------------------------------------
local SKELETON = {
	{ "Head", "UpperTorso" },
	{ "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" },
	{ "LeftUpperArm", "LeftLowerArm" },
	{ "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" },
	{ "RightUpperArm", "RightLowerArm" },
	{ "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" },
	{ "LeftUpperLeg", "LeftLowerLeg" },
	{ "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" },
	{ "RightUpperLeg", "RightLowerLeg" },
	{ "RightLowerLeg", "RightFoot" },
	-- R6 fallbacks handled if parts missing
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Torso", "Right Arm" },
	{ "Torso", "Left Leg" },
	{ "Torso", "Right Leg" },
}

local function clearESP(plr)
	local pack = ESPStore[plr]
	if not pack then return end
	if pack.billboard then pcall(function() pack.billboard:Destroy() end) end
	if pack.highlight then pcall(function() pack.highlight:Destroy() end) end
	if pack.lines then
		for _, ln in ipairs(pack.lines) do
			pcall(function() ln:Remove() end)
			pcall(function() ln:Destroy() end)
		end
	end
	ESPStore[plr] = nil
end

local function clearAllESP()
	for plr in pairs(ESPStore) do
		clearESP(plr)
	end
end

local function makeESP(plr)
	clearESP(plr)
	if plr == LP then return end

	local char = getChar(plr)
	if not char then return end

	local pack = { lines = {} }

	-- soft highlight (depth)
	local hl = Instance.new("Highlight")
	hl.Name = "xa_hl"
	hl.Adornee = char
	hl.FillTransparency = 0.85
	hl.OutlineTransparency = 0.35
	hl.FillColor = Color3.fromRGB(90, 160, 255)
	hl.OutlineColor = Color3.fromRGB(180, 220, 255)
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = char
	pack.highlight = hl

	-- name / tool billboard
	local root = getRoot(char) or char:FindFirstChild("Head")
	if root then
		local bb = Instance.new("BillboardGui")
		bb.Name = "xa_bb"
		bb.Adornee = root
		bb.Size = UDim2.fromOffset(200, 40)
		bb.StudsOffset = Vector3.new(0, 3.2, 0)
		bb.AlwaysOnTop = true
		bb.MaxDistance = S.ESP.MaxDist
		bb.Parent = char

		local label = Instance.new("TextLabel")
		label.Name = "Txt"
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamMedium
		label.TextSize = S.ESP.TextSize
		label.TextColor3 = Color3.fromRGB(235, 240, 255)
		label.TextStrokeTransparency = 0.5
		label.Text = plr.Name
		label.Parent = bb
		pack.billboard = bb
		pack.label = label
	end

	-- skeleton lines (Drawing)
	if Drawing and S.ESP.ShowSkeleton then
		for _ = 1, 18 do
			local ln = Drawing.new("Line")
			ln.Thickness = 1
			ln.Color = Color3.fromRGB(160, 210, 255)
			ln.Transparency = 0.3
			ln.Visible = false
			table.insert(pack.lines, ln)
		end
	end

	ESPStore[plr] = pack
end

local function refreshESPPlayer(plr)
	if not S.ESP.Enabled then
		clearESP(plr)
		return
	end
	if plr == LP or not isAlive(plr) then
		clearESP(plr)
		return
	end
	if S.ESP.TeamCheck and sameTeam(plr) then
		clearESP(plr)
		return
	end
	local myRoot = getRoot(getChar(LP))
	local theirRoot = getRoot(getChar(plr))
	if myRoot and theirRoot then
		if (myRoot.Position - theirRoot.Position).Magnitude > S.ESP.MaxDist then
			clearESP(plr)
			return
		end
	end
	if not ESPStore[plr] then
		makeESP(plr)
	end
end

local function updateESPFrame()
	if not S.ESP.Enabled then return end
	local myRoot = getRoot(getChar(LP))

	for plr, pack in pairs(ESPStore) do
		if not isAlive(plr) then
			clearESP(plr)
			continue
		end
		local char = getChar(plr)
		local root = getRoot(char)
		if not root then
			clearESP(plr)
			continue
		end

		local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
		if dist > S.ESP.MaxDist then
			clearESP(plr)
			continue
		end

		-- billboard text
		if pack.label then
			local parts = {}
			if S.ESP.ShowName then
				table.insert(parts, plr.DisplayName ~= plr.Name and (plr.DisplayName .. " (@" .. plr.Name .. ")") or plr.Name)
			end
			if S.ESP.ShowTool then
				table.insert(parts, equippedOf(plr))
			end
			table.insert(parts, string.format("[%dm]", math.floor(dist)))
			pack.label.Text = table.concat(parts, " · ")
			pack.label.TextSize = S.ESP.TextSize
			if pack.billboard then
				pack.billboard.MaxDistance = S.ESP.MaxDist
			end
		end

		-- skeleton
		if S.ESP.ShowSkeleton and pack.lines and #pack.lines > 0 then
			local idx = 1
			for _, pair in ipairs(SKELETON) do
				local a = getPart(char, pair[1])
				local b = getPart(char, pair[2])
				local ln = pack.lines[idx]
				if ln and a and b then
					local pa, oa = worldToScreen(a.Position)
					local pb, ob = worldToScreen(b.Position)
					if oa and ob then
						ln.From = pa
						ln.To = pb
						ln.Visible = true
					else
						ln.Visible = false
					end
					idx += 1
				end
			end
			for i = idx, #pack.lines do
				pack.lines[i].Visible = false
			end
		elseif pack.lines then
			for _, ln in ipairs(pack.lines) do
				ln.Visible = false
			end
		end
	end
end

----------------------------------------------------------------------
-- Combat: target selection + aim
----------------------------------------------------------------------
local function getBestTarget()
	local best, bestScore = nil, math.huge
	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X / 2, vp.Y / 2)
	local fov = S.Combat.FOV

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and isAlive(plr) then
			if not (S.Combat.TeamCheck and sameTeam(plr)) then
				local part = aimTargetPart(getChar(plr))
				if part then
					local sp, onScreen, depth = worldToScreen(part.Position)
					if onScreen and depth > 0 then
						local dist2d = (sp - center).Magnitude
						if dist2d <= fov then
							-- prefer closer to crosshair, then closer in world
							local score = dist2d + depth * 0.02
							if score < bestScore then
								bestScore = score
								best = part
							end
						end
					end
				end
			end
		end
	end
	return best
end

-- Silent-style: steer camera look toward target when in FOV (no remote hooks → less noisy)
local function applyAim(dt)
	if not (S.Combat.Aimbot or S.Combat.Silent) then return end
	local target = getBestTarget()
	if not target then return end

	local cam = Camera
	local origin = cam.CFrame.Position
	local goal = CFrame.lookAt(origin, target.Position)
	local alpha = S.Combat.Silent and 1 or math.clamp((S.Combat.Smooth > 0 and (1 - S.Combat.Smooth) or 0.85) * (dt * 60), 0.05, 1)

	if S.Combat.Silent then
		-- hard snap look (silent feel for hitscan / camera-based guns)
		cam.CFrame = goal
	elseif S.Combat.Aimbot then
		cam.CFrame = cam.CFrame:Lerp(goal, alpha)
	end
end

----------------------------------------------------------------------
-- Visual
----------------------------------------------------------------------
local function setFullbright(on)
	S.Visual.Fullbright = on
	if on then
		if not LightingBackup then
			LightingBackup = {
				Brightness = Lighting.Brightness,
				ClockTime = Lighting.ClockTime,
				FogEnd = Lighting.FogEnd,
				GlobalShadows = Lighting.GlobalShadows,
				Ambient = Lighting.Ambient,
				OutdoorAmbient = Lighting.OutdoorAmbient,
			}
		end
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 1e6
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(200, 200, 200)
		Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
	else
		if LightingBackup then
			for k, v in pairs(LightingBackup) do
				pcall(function() Lighting[k] = v end)
			end
		end
	end
end

local function setPotato(on)
	S.Visual.Potato = on
	if on then
		PotatoApplied = true
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		pcall(function()
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 250
			Lighting.Brightness = 1
		end)
		-- strip heavy effects
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect")
				or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
				pcall(function() v.Enabled = false end)
			end
		end
	else
		if PotatoApplied then
			pcall(function()
				settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
			end)
		end
	end
end

----------------------------------------------------------------------
-- Bind loops
----------------------------------------------------------------------
local function bindPlayers()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			plr.CharacterAdded:Connect(function()
				task.wait(0.4)
				if S.ESP.Enabled then refreshESPPlayer(plr) end
			end)
			plr.CharacterRemoving:Connect(function()
				clearESP(plr)
			end)
		end
	end
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
			task.wait(0.4)
			if S.ESP.Enabled then refreshESPPlayer(plr) end
		end)
		plr.CharacterRemoving:Connect(function()
			clearESP(plr)
		end)
	end)
	Players.PlayerRemoving:Connect(function(plr)
		clearESP(plr)
	end)
end

local function setESPEnabled(on)
	S.ESP.Enabled = on
	if on then
		for _, plr in ipairs(Players:GetPlayers()) do
			refreshESPPlayer(plr)
		end
	else
		clearAllESP()
	end
end

-- main heartbeat (throttled pieces)
local acc = 0
Connections.hb = RunService.RenderStepped:Connect(function(dt)
	updateFOV()
	applyAim(dt)
	acc += dt
	if acc >= 0.05 then
		acc = 0
		if S.ESP.Enabled then
			-- periodic rebuild check
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LP and isAlive(plr) and not ESPStore[plr] then
					refreshESPPlayer(plr)
				end
			end
			updateESPFrame()
		end
	else
		if S.ESP.Enabled then
			updateESPFrame()
		end
	end
end)

bindPlayers()

----------------------------------------------------------------------
-- WindUI
----------------------------------------------------------------------
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local winSize = isMobile and UDim2.fromOffset(300, 400) or UDim2.fromOffset(420, 480)

local Window = WindUI:CreateWindow({
	Title = "x adra",
	Icon = "crosshair",
	Author = "Degrade",
	Folder = "xadra_degrade",
	Size = winSize,
	Transparent = true,
	Theme = "Dark",
})

-- ESP tab
local TabESP = Window:Tab({ Title = "ESP", Icon = "eye" })
TabESP:Section({ Title = "Players" })

TabESP:Toggle({
	Title = "Enable ESP",
	Value = false,
	Callback = function(v) setESPEnabled(v) end,
})

TabESP:Slider({
	Title = "Max Distance",
	Value = { Min = 50, Max = 1000, Default = 400 },
	Callback = function(v)
		S.ESP.MaxDist = v
	end,
})

TabESP:Toggle({
	Title = "Nickname",
	Value = true,
	Callback = function(v) S.ESP.ShowName = v end,
})

TabESP:Slider({
	Title = "Text Size",
	Value = { Min = 10, Max = 28, Default = 14 },
	Callback = function(v) S.ESP.TextSize = v end,
})

TabESP:Toggle({
	Title = "Weapon in hand",
	Value = true,
	Callback = function(v) S.ESP.ShowTool = v end,
})

TabESP:Toggle({
	Title = "Skeleton",
	Value = true,
	Callback = function(v)
		S.ESP.ShowSkeleton = v
		-- rebuild to recreate lines
		if S.ESP.Enabled then
			clearAllESP()
			for _, plr in ipairs(Players:GetPlayers()) do
				refreshESPPlayer(plr)
			end
		end
	end,
})

TabESP:Toggle({
	Title = "Team Check",
	Value = false,
	Callback = function(v) S.ESP.TeamCheck = v end,
})

-- Combat tab
local TabCombat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
TabCombat:Section({ Title = "Aim" })

TabCombat:Toggle({
	Title = "Aimbot",
	Value = false,
	Callback = function(v) S.Combat.Aimbot = v end,
})

TabCombat:Toggle({
	Title = "Silent Aim",
	Value = false,
	Callback = function(v) S.Combat.Silent = v end,
})

TabCombat:Slider({
	Title = "FOV Radius",
	Value = { Min = 20, Max = 400, Default = 120 },
	Callback = function(v)
		S.Combat.FOV = v
		updateFOV()
	end,
})

TabCombat:Toggle({
	Title = "Show FOV Circle",
	Value = true,
	Callback = function(v)
		S.Combat.ShowFOV = v
		if v then ensureFOV() else destroyFOV() end
	end,
})

TabCombat:Slider({
	Title = "Aimbot Smooth",
	Value = { Min = 0, Max = 90, Default = 18 },
	Callback = function(v)
		S.Combat.Smooth = v / 100
	end,
})

TabCombat:Dropdown({
	Title = "Aim Part",
	Values = { "Head", "HumanoidRootPart", "UpperTorso" },
	Value = "Head",
	Callback = function(v) S.Combat.AimPart = v end,
})

TabCombat:Toggle({
	Title = "Team Check",
	Value = true,
	Callback = function(v) S.Combat.TeamCheck = v end,
})

TabCombat:Paragraph({
	Title = "Note",
	Desc = "Silent = hard camera lock in FOV. Aimbot = smooth lock. Works best with camera-based / hitscan weapons.",
})

-- Visual tab
local TabVis = Window:Tab({ Title = "Visual", Icon = "sun" })
TabVis:Section({ Title = "World" })

TabVis:Toggle({
	Title = "Fullbright",
	Value = false,
	Callback = function(v) setFullbright(v) end,
})

TabVis:Toggle({
	Title = "Potato Mode",
	Value = false,
	Callback = function(v) setPotato(v) end,
})

TabVis:Paragraph({
	Title = "Potato",
	Desc = "Low quality + disables heavy lighting effects for FPS.",
})

-- init FOV
if S.Combat.ShowFOV then
	ensureFOV()
end

pcall(function()
	WindUI:Notify({
		Title = "x adra",
		Content = "Degrade · ESP / Combat / Visual",
		Duration = 3,
	})
end)

print("[x adra] Degrade loaded")
