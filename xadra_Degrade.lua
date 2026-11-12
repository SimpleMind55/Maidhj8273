--[[
  x adra · Degrade (Mobile optimized)
  PlaceId: 129437813830973
]]

local PLACE_ID = 129437813830973

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled
-- some executors report both; prefer touch-primary
if UIS.TouchEnabled and UIS.GyroscopeEnabled then
	IS_MOBILE = true
end

pcall(function()
	if game.PlaceId ~= PLACE_ID then
		warn("[x adra] different PlaceId — still running")
	end
end)

local WindUI = loadstring(game:HttpGetAsync("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------
local S = {
	ESP = {
		Enabled = false,
		MaxDist = IS_MOBILE and 500 or 800,
		ShowName = true,
		TextSize = IS_MOBILE and 16 or 14,
		ShowTool = true,
		ShowSkeleton = false, -- Drawing lines often crash mobile
		TeamCheck = false,
		FocusName = "", -- substring / exact name → red label
	},
	Combat = {
		Aimbot = false,
		Silent = false,
		FOV = IS_MOBILE and 90 or 120,
		ShowFOV = true,
		Smooth = 0.22,
		TeamCheck = true,
		AimPart = "Head",
		MaxDist = 300, -- aimbot / silent max world distance
	},
	Visual = {
		Fullbright = false,
		Potato = false,
	},
}

local ESPStore = {}
local FOVGui = nil
local LightingBackup = nil
local SilentTarget = nil
local SilentHooked = false
local espTick = 0

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
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
	return char and char:FindFirstChild(name)
end

local function isAlive(plr)
	local char = getChar(plr)
	local hum = getHum(char)
	return char and hum and hum.Health > 0 and getRoot(char) ~= nil
end

local function sameTeam(plr)
	if not LP.Team or not plr.Team then return false end
	return LP.Team == plr.Team
end

local function worldToScreen(pos)
	local v, on = Camera:WorldToViewportPoint(pos)
	return Vector2.new(v.X, v.Y), on and v.Z > 0, v.Z
end

local function equippedOf(plr)
	local char = getChar(plr)
	if not char then return "—" end
	local tool = char:FindFirstChildOfClass("Tool")
	return tool and tool.Name or "—"
end

local function aimPart(char)
	local n = S.Combat.AimPart or "Head"
	return getPart(char, n) or getPart(char, "Head") or getRoot(char)
end

local function guiParent()
	local ok, h = pcall(function()
		return gethui and gethui()
	end)
	if ok and h then return h end
	return CoreGui
end

----------------------------------------------------------------------
-- FOV circle (ScreenGui only — safe on mobile)
----------------------------------------------------------------------
local function destroyFOV()
	if FOVGui then
		pcall(function() FOVGui:Destroy() end)
		FOVGui = nil
	end
end

local function ensureFOV()
	destroyFOV()
	if not S.Combat.ShowFOV then return end

	local sg = Instance.new("ScreenGui")
	sg.Name = "xa_fov"
	sg.IgnoreGuiInset = true
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 100
	sg.Parent = guiParent()

	local ring = Instance.new("Frame")
	ring.Name = "Ring"
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.BackgroundTransparency = 1
	ring.Parent = sg
	Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
	local st = Instance.new("UIStroke", ring)
	st.Name = "Stroke"
	st.Color = Color3.fromRGB(120, 200, 255)
	st.Thickness = IS_MOBILE and 2 or 1.5
	st.Transparency = 0.4

	FOVGui = sg
end

local function updateFOV()
	if not S.Combat.ShowFOV then
		if FOVGui then destroyFOV() end
		return
	end
	if not FOVGui then ensureFOV() end
	if not FOVGui then return end
	local ring = FOVGui:FindFirstChild("Ring")
	if not ring then return end
	local vp = Camera.ViewportSize
	local d = math.clamp(S.Combat.FOV * 2, 40, math.min(vp.X, vp.Y) * 0.95)
	ring.Size = UDim2.fromOffset(d, d)
	ring.Position = UDim2.fromOffset(vp.X * 0.5, vp.Y * 0.5)
end

----------------------------------------------------------------------
-- ESP (Highlight + Billboard, no Drawing on mobile)
----------------------------------------------------------------------
local function clearESP(plr)
	local pack = ESPStore[plr]
	if not pack then return end
	pcall(function() if pack.bb then pack.bb:Destroy() end end)
	pcall(function() if pack.hl then pack.hl:Destroy() end end)
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

	local pack = {}
	local hl = Instance.new("Highlight")
	hl.Adornee = char
	hl.FillTransparency = 0.88
	hl.OutlineTransparency = 0.4
	hl.FillColor = Color3.fromRGB(90, 160, 255)
	hl.OutlineColor = Color3.fromRGB(180, 220, 255)
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = char
	pack.hl = hl

	local root = getRoot(char) or getPart(char, "Head")
	if root then
		local bb = Instance.new("BillboardGui")
		bb.Adornee = root
		bb.Size = UDim2.fromOffset(IS_MOBILE and 220 or 200, IS_MOBILE and 48 or 40)
		bb.StudsOffset = Vector3.new(0, 3.2, 0)
		bb.AlwaysOnTop = true
		bb.MaxDistance = S.ESP.MaxDist
		bb.Parent = char

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamMedium
		label.TextSize = S.ESP.TextSize
		label.TextColor3 = Color3.fromRGB(235, 240, 255)
		label.TextStrokeTransparency = 0.45
		label.Text = plr.Name
		label.Parent = bb
		pack.bb = bb
		pack.label = label
	end

	ESPStore[plr] = pack
end

local function refreshESPPlayer(plr)
	if not S.ESP.Enabled or plr == LP or not isAlive(plr) then
		clearESP(plr)
		return
	end
	if S.ESP.TeamCheck and sameTeam(plr) then
		clearESP(plr)
		return
	end
	local myRoot = getRoot(getChar(LP))
	local their = getRoot(getChar(plr))
	if myRoot and their and (myRoot.Position - their.Position).Magnitude > S.ESP.MaxDist then
		clearESP(plr)
		return
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
		else
			local char = getChar(plr)
			local root = getRoot(char)
			if not root then
				clearESP(plr)
			else
				local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
				if dist > S.ESP.MaxDist then
					clearESP(plr)
				elseif pack.label then
					local parts = {}
					if S.ESP.ShowName then
						table.insert(parts, plr.Name)
					end
					if S.ESP.ShowTool then
						table.insert(parts, equippedOf(plr))
					end
					table.insert(parts, string.format("%dm", math.floor(dist)))
					pack.label.Text = table.concat(parts, " · ")
					pack.label.TextSize = S.ESP.TextSize
					-- focus player → red name
					local focus = (S.ESP.FocusName or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
					local isFocus = false
					if focus ~= "" then
						local n = plr.Name:lower()
						local d = (plr.DisplayName or ""):lower()
						if n == focus or d == focus or n:find(focus, 1, true) or d:find(focus, 1, true) then
							isFocus = true
						end
					end
					if isFocus then
						pack.label.TextColor3 = Color3.fromRGB(255, 60, 60)
						pack.label.TextStrokeTransparency = 0.2
						if pack.hl then
							pack.hl.OutlineColor = Color3.fromRGB(255, 50, 50)
							pack.hl.FillColor = Color3.fromRGB(255, 80, 80)
							pack.hl.FillTransparency = 0.75
						end
					else
						pack.label.TextColor3 = Color3.fromRGB(235, 240, 255)
						pack.label.TextStrokeTransparency = 0.45
						if pack.hl then
							pack.hl.OutlineColor = Color3.fromRGB(180, 220, 255)
							pack.hl.FillColor = Color3.fromRGB(90, 160, 255)
							pack.hl.FillTransparency = 0.88
						end
					end
					if pack.bb then
						pack.bb.MaxDistance = S.ESP.MaxDist
					end
				end
			end
		end
	end
end

----------------------------------------------------------------------
-- Combat targeting
----------------------------------------------------------------------
local function getBestTarget()
	local best, bestScore = nil, math.huge
	local vp = Camera.ViewportSize
	local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	local fov = S.Combat.FOV
	local maxDist = S.Combat.MaxDist
	local myRoot = getRoot(getChar(LP))

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and isAlive(plr) then
			if not (S.Combat.TeamCheck and sameTeam(plr)) then
				local part = aimPart(getChar(plr))
				if part then
					if myRoot then
						local wd = (myRoot.Position - part.Position).Magnitude
						if wd > maxDist then
							part = nil
						end
					end
				end
				if part then
					local sp, onScreen, depth = worldToScreen(part.Position)
					if onScreen then
						local dist2d = (sp - center).Magnitude
						if dist2d <= fov then
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

local function applyAimbot(dt)
	if not S.Combat.Aimbot then return end
	local target = SilentTarget
	if not target or not target.Parent then return end
	local origin = Camera.CFrame.Position
	local goal = CFrame.lookAt(origin, target.Position)
	local alpha = math.clamp((1 - (S.Combat.Smooth or 0.22)) * (dt * 60), 0.04, 1)
	Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
end

----------------------------------------------------------------------
-- Silent aim — mobile-safe hooks
-- Prefer hookmetamethod; avoid double namecall crash on mobile
----------------------------------------------------------------------
local function installSilentHooks()
	if SilentHooked then return true end

	local function wrap(fn)
		if type(newcclosure) == "function" then
			local ok, r = pcall(newcclosure, fn)
			if ok and r then return r end
		end
		return fn
	end

	local function indexHook(self, key)
		if S.Combat.Silent and SilentTarget and SilentTarget.Parent then
			if self == Mouse then
				if key == "Hit" then
					return SilentTarget.CFrame
				elseif key == "Target" then
					return SilentTarget
				elseif key == "UnitRay" then
					local origin = Camera.CFrame.Position
					local dir = SilentTarget.Position - origin
					if dir.Magnitude < 0.05 then
						dir = Camera.CFrame.LookVector * 2048
					else
						dir = dir.Unit * 2048
					end
					return Ray.new(origin, dir)
				end
			end
		end
		return nil -- signal miss
	end

	-- Method A: hookmetamethod (most executors, safer)
	if type(hookmetamethod) == "function" then
		local ok = pcall(function()
			local oldIndex
			oldIndex = hookmetamethod(game, "__index", wrap(function(self, key)
				local hit = indexHook(self, key)
				if hit ~= nil then return hit end
				return oldIndex(self, key)
			end))
		end)
		if ok then
			SilentHooked = true
			print("[x adra] silent: hookmetamethod __index")
			-- optional raycast redirect (skip on weak mobile if fails)
			pcall(function()
				local oldNc
				oldNc = hookmetamethod(game, "__namecall", wrap(function(self, ...)
					local method = getnamecallmethod()
					if S.Combat.Silent and SilentTarget and SilentTarget.Parent and method == "Raycast" and self == workspace then
						local a = { ... }
						if typeof(a[1]) == "Vector3" and typeof(a[2]) == "Vector3" then
							local mag = a[2].Magnitude
							if mag < 1 then mag = 1000 end
							local d = SilentTarget.Position - a[1]
							if d.Magnitude > 0.05 then
								a[2] = d.Unit * mag
							end
							return oldNc(self, table.unpack(a))
						end
					end
					return oldNc(self, ...)
				end))
			end)
			return true
		end
	end

	-- Method B: getrawmetatable (desktop fallback)
	if type(getrawmetatable) == "function" and not IS_MOBILE then
		local ok = pcall(function()
			local mt = getrawmetatable(game)
			local oldIndex = mt.__index
			if setreadonly then setreadonly(mt, false) end
			mt.__index = wrap(function(self, key)
				local hit = indexHook(self, key)
				if hit ~= nil then return hit end
				return oldIndex(self, key)
			end)
		end)
		if ok then
			SilentHooked = true
			print("[x adra] silent: getrawmetatable __index")
			return true
		end
	end

	warn("[x adra] silent hooks unavailable on this executor")
	return false
end

----------------------------------------------------------------------
-- Visual
----------------------------------------------------------------------
local function setFullbright(on)
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
	elseif LightingBackup then
		for k, v in pairs(LightingBackup) do
			pcall(function() Lighting[k] = v end)
		end
	end
end

local function setPotato(on)
	if on then
		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 200
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") then
				pcall(function() v.Enabled = false end)
			end
		end
	else
		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
		end)
	end
end

----------------------------------------------------------------------
-- Players bind
----------------------------------------------------------------------
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

for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LP then
		plr.CharacterAdded:Connect(function()
			task.wait(0.5)
			if S.ESP.Enabled then refreshESPPlayer(plr) end
		end)
		plr.CharacterRemoving:Connect(function()
			clearESP(plr)
		end)
	end
end
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5)
		if S.ESP.Enabled then refreshESPPlayer(plr) end
	end)
	plr.CharacterRemoving:Connect(function()
		clearESP(plr)
	end)
end)
Players.PlayerRemoving:Connect(clearESP)

----------------------------------------------------------------------
-- Main loop (lighter on mobile)
----------------------------------------------------------------------
local ESP_INTERVAL = IS_MOBILE and 0.12 or 0.05

RunService.RenderStepped:Connect(function(dt)
	updateFOV()

	if S.Combat.Silent or S.Combat.Aimbot then
		SilentTarget = getBestTarget()
	else
		SilentTarget = nil
	end

	applyAimbot(dt)

	espTick += dt
	if S.ESP.Enabled then
		if espTick >= ESP_INTERVAL then
			espTick = 0
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LP and isAlive(plr) and not ESPStore[plr] then
					refreshESPPlayer(plr)
				end
			end
		end
		updateESPFrame()
	end
end)

----------------------------------------------------------------------
-- UI
----------------------------------------------------------------------
local winW = IS_MOBILE and 290 or 400
local winH = IS_MOBILE and 360 or 460

local Window = WindUI:CreateWindow({
	Title = "x adra",
	Icon = "crosshair",
	Author = IS_MOBILE and "Degrade · Mobile" or "Degrade",
	Folder = "xadra_degrade",
	Size = UDim2.fromOffset(winW, winH),
	Transparent = true,
	Theme = "Dark",
})

-- ESP
local TabESP = Window:Tab({ Title = "ESP", Icon = "eye" })
TabESP:Section({ Title = "Players" })

TabESP:Toggle({
	Title = "Enable ESP",
	Value = false,
	Callback = function(v) setESPEnabled(v) end,
})

TabESP:Slider({
	Title = "Max Distance",
	Value = { Min = 50, Max = 2000, Default = S.ESP.MaxDist },
	Callback = function(v) S.ESP.MaxDist = v end,
})

TabESP:Toggle({
	Title = "Nickname",
	Value = true,
	Callback = function(v) S.ESP.ShowName = v end,
})

TabESP:Slider({
	Title = "Text Size",
	Value = { Min = 10, Max = 28, Default = S.ESP.TextSize },
	Callback = function(v) S.ESP.TextSize = v end,
})

TabESP:Toggle({
	Title = "Weapon in hand",
	Value = true,
	Callback = function(v) S.ESP.ShowTool = v end,
})

TabESP:Toggle({
	Title = "Team Check",
	Value = false,
	Callback = function(v) S.ESP.TeamCheck = v end,
})

TabESP:Input({
	Title = "Red Name (player)",
	Value = "",
	Placeholder = "username or display name",
	Callback = function(v)
		S.ESP.FocusName = tostring(v or "")
	end,
})

TabESP:Paragraph({
	Title = "Focus",
	Desc = "Игрок с этим ником/display name подсвечивается красным (ник + outline).",
})

-- Combat
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
	Callback = function(v)
		S.Combat.Silent = v
		if v then
			local ok = false
			pcall(function()
				ok = installSilentHooks()
			end)
			if not ok and not SilentHooked then
				S.Combat.Silent = false
				pcall(function()
					WindUI:Notify({
						Title = "Silent Aim",
						Content = "Hooks failed on this executor — try another build",
						Duration = 4,
					})
				end)
			end
		end
	end,
})

TabCombat:Slider({
	Title = "FOV Radius",
	Value = { Min = 30, Max = 350, Default = S.Combat.FOV },
	Callback = function(v)
		S.Combat.FOV = v
		updateFOV()
	end,
})

TabCombat:Slider({
	Title = "Aim Max Distance",
	Value = { Min = 50, Max = 800, Default = S.Combat.MaxDist },
	Callback = function(v)
		S.Combat.MaxDist = v
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
	Value = { Min = 0, Max = 90, Default = math.floor(S.Combat.Smooth * 100) },
	Callback = function(v) S.Combat.Smooth = v / 100 end,
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
	Title = "Silent",
	Desc = "Enemy in FOV circle + within Aim Max Distance → shots redirect without moving crosshair. Mobile uses safer hooks.",
})

-- Visual
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

if S.Combat.ShowFOV then
	ensureFOV()
end

pcall(function()
	WindUI:Notify({
		Title = "x adra",
		Content = IS_MOBILE and "Degrade · Mobile" or "Degrade loaded",
		Duration = 3,
	})
end)

print("[x adra] Degrade ready · mobile=", IS_MOBILE)
