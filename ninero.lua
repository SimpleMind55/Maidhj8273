--[[

MM2 Script — WindUI

Silent Aim · ESP · Player · Fling · Buttons · Visuals · Misc

]]



local Players = game:GetService("Players") local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService") local ReplicatedStorage = game:GetService("ReplicatedStorage") local TweenService = game:GetService("TweenService") local HttpService = game:GetService("HttpService") local Lighting = game:GetService("Lighting") local CoreGui = game:GetService("CoreGui") local StarterGui = game:GetService("StarterGui") local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local Mouse = LocalPlayer:GetMouse()



-- ======================== CONFIG ========================

local CFG = {

Combat = {

SilentAim = false,

Wallbang = false,

Resolver = true,

AutoPrediction = true,

PredMultiplier = 0.135,

},

ESP = {

Enabled = false,

Mode = "Both", -- Outline / Fill / Both Transparency = 0.55,

TextSize = 14,

Names = true,

Distance = true,

Tracers = true,

Colors = {

Murderer = Color3.fromRGB(255, 55, 55),

Sheriff = Color3.fromRGB(55, 120, 255),

Innocent = Color3.fromRGB(70, 220, 100),

Hero = Color3.fromRGB(255, 220, 50),

None = Color3.fromRGB(200, 200, 200),

},

},

Player = {

Speed = 16,

SpeedEnabled = false,

Invis = false,

Spin = false,

SpinSpeed = 12,

},

Fling = {

AntiFling = false,

Target = nil,

},

Visuals = {

BulletTracer = false,

TracerColor = Color3.fromRGB(255, 80, 120),

Sky = "Default",

},

Buttons = {

Size = 48,

Color = Color3.fromRGB(40, 40, 50),

Transparency = 0.25,

Locked = false,

},

Misc = {

FPS = true,

UIKey = Enum.KeyCode.LeftControl,

},

}



local BG_URL = "https://i.imgur.com/lBBbRqg.png"



-- ======================== UTILS ========================

local function safe(fn, ...)

local ok, res = pcall(fn, ...)

return ok and res or nil

end



local function getHRP(char)

return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")) end



local function getHumanoid(char)

return char and char:FindFirstChildOfClass("Humanoid") end



local function isAlive(plr)

local char = plr.Character

local hum = getHumanoid(char)

return char and hum and hum.Health > 0

end



local function getPing()

local ok, ping = pcall(function() return LocalPlayer:GetNetworkPing() * 1000

end)

return (ok and ping) or 50

end



local function predictPos(part, vel, mult)

mult = mult or CFG.Combat.PredMultiplier

if CFG.Combat.AutoPrediction then

mult = math.clamp(getPing() / 1000 * 1.35, 0.05, 0.35) end

return part.Position + (vel * mult)

end



-- Role detection via tools / backpack / known MM2 patterns local function getRole(plr)

local char = plr.Character

if not char then return "None" end

local pack = plr:FindFirstChild("Backpack") local function hasTool(name)

name = string.lower(name)

for _, t in ipairs(char:GetChildren()) do

if t:IsA("Tool") and string.find(string.lower(t.Name), name) then return true end end

if pack then

for _, t in ipairs(pack:GetChildren()) do

if t:IsA("Tool") and string.find(string.lower(t.Name), name) then return true end end

end

return false

end

if hasTool("knife") then return "Murderer" end if hasTool("gun") or hasTool("revolver") or hasTool("pistol") then

-- Hero vs Sheriff: rough heuristic — if someone already died with gun, often Hero return "Sheriff"

end

-- Hero often has gun after pickup; treat gun holders as Sheriff/Hero for color return "Innocent"

end



local function getTargetForSilent()

local myRole = getRole(LocalPlayer)

local best, bestDist = nil, math.huge

for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and isAlive(plr) then

local role = getRole(plr)

local want = false

if myRole == "Murderer" then

want = (role == "Sheriff" or role == "Hero" or role == "Innocent") else

want = (role == "Murderer")

end

if want then

local hrp = getHRP(plr.Character)

if hrp then

local d = (hrp.Position - Camera.CFrame.Position).Magnitude if d < bestDist then

bestDist = d

best = plr

end

end

end

end

end

-- Prefer Murderer if we are not murderer

if myRole ~= "Murderer" then

for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and isAlive(plr) and getRole(plr) == "Murderer" then return plr

end

end

end

return best

end



local function getVisiblePart(char, origin)

local parts = {"Head", "HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

local closest, closestDist = nil, math.huge

local params = RaycastParams.new()

params.FilterType = Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances = {LocalPlayer.Character, char}



for _, name in ipairs(parts) do

local p = char:FindFirstChild(name)

if p and p:IsA("BasePart") then

local dir = p.Position - origin

if CFG.Combat.Wallbang then

local d = dir.Magnitude

if d < closestDist then

closestDist = d

closest = p

end

else

local result = workspace:Raycast(origin, dir.Unit * dir.Magnitude, params) if not result or result.Instance:IsDescendantOf(char) then

local d = dir.Magnitude if d < closestDist then

closestDist = d

closest = p

end

end

end

end

end

return closest or getHRP(char)

end



-- ======================== SILENT AIM ========================

local silentConn

local function fireSilent()

local target = getTargetForSilent()

if not target or not isAlive(target) then return end local char = target.Character

local origin = Camera.CFrame.Position

local part = getVisiblePart(char, origin)

if not part then return end



local vel = Vector3.zero

if CFG.Combat.Resolver then

-- simple resolver: use root velocity, damp spikes local hrp = getHRP(char)

if hrp then

vel = hrp.AssemblyLinearVelocity

if vel.Magnitude > 80 then vel = vel.Unit * 40 end end

else

local hrp = getHRP(char)

if hrp then vel = hrp.AssemblyLinearVelocity end end



local aimPos = predictPos(part, vel)

local cf = CFrame.lookAt(origin, aimPos)



-- Redirect camera briefly + try tool activation local old = Camera.CFrame

Camera.CFrame = cf

local tool = LocalPlayer.Character and

LocalPlayer.Character:FindFirstChildOfClass("Tool") if tool then

pcall(function()

tool:Activate()

end)

end

-- mouse click fallback

pcall(function()

mouse1click()

end)

task.defer(function()

Camera.CFrame = old

end)

end



-- metatable silent for ongoing (optional hold) — one-shot button uses fireSilent local mtHooked = false

local function hookSilentMeta()

if mtHooked or not hookmetamethod then return end mtHooked = true

local old

old = hookmetamethod(game, "__namecall", function(self, ...) local method = getnamecallmethod()

if CFG.Combat.SilentAim and method == "FindPartOnRayWithIgnoreList" or method ==

"Raycast" then

-- leave for advanced; primary is button fire end

return old(self, ...)

end)

end

pcall(hookSilentMeta)



-- ======================== ESP ========================

local espFolder = Instance.new("Folder") espFolder.Name = "MM2ESP"

espFolder.Parent = CoreGui



local drawings = {} -- [player] = {box, name, dist, tracer}



local function clearESP(plr)

local d = drawings[plr]

if not d then return end

for _, v in pairs(d) do

if typeof(v) == "Instance" then v:Destroy() elseif type(v) == "table" and v.Remove then v:Remove() end end

drawings[plr] = nil

end



local function makeBillboard(adornee, size)

local bb = Instance.new("BillboardGui") bb.Adornee = adornee

bb.Size = UDim2.fromOffset(size or 120, 40)

bb.AlwaysOnTop = true

bb.StudsOffset = Vector3.new(0, 2.6, 0) bb.Parent = espFolder

return bb

end



local function updateESP()

if not CFG.ESP.Enabled then

for plr in pairs(drawings) do clearESP(plr) end return

end

for _, plr in ipairs(Players:GetPlayers()) do if plr == LocalPlayer or not isAlive(plr) then clearESP(plr)

else

local char = plr.Character

local hrp = getHRP(char)

local head = char:FindFirstChild("Head") if not hrp then clearESP(plr) continue end



local role = getRole(plr)

local col = CFG.ESP.Colors[role] or CFG.ESP.Colors.None local d = drawings[plr]

if not d then

d = {}

drawings[plr] = d

-- highlight-style box via SelectionBox / Highlight local hl = Instance.new("Highlight") hl.Adornee = char

hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop hl.Parent = espFolder

d.hl = hl



local bb = makeBillboard(head or hrp, 140)

local nameL = Instance.new("TextLabel") nameL.BackgroundTransparency = 1

nameL.Size = UDim2.new(1, 0, 0.5, 0)

nameL.Font = Enum.Font.GothamBold

nameL.TextStrokeTransparency = 0.4

nameL.Parent = bb

d.name = nameL

d.bb = bb



local distL = Instance.new("TextLabel") distL.BackgroundTransparency = 1

distL.Size = UDim2.new(1, 0, 0.5, 0)

distL.Position = UDim2.new(0, 0, 0.5, 0)

distL.Font = Enum.Font.Gotham

distL.TextStrokeTransparency = 0.5

distL.Parent = bb d.dist = distL



local line = Drawing.new("Line")

line.Thickness = 1.2

line.Visible = false

d.tracer = line

end



local mode = CFG.ESP.Mode

local fillT = CFG.ESP.Transparency

if mode == "Outline" then

d.hl.FillTransparency = 1

d.hl.OutlineTransparency = 0

elseif mode == "Fill" then

d.hl.FillTransparency = fillT

d.hl.OutlineTransparency = 1

else

d.hl.FillTransparency = fillT

d.hl.OutlineTransparency = 0

end

d.hl.FillColor = col

d.hl.OutlineColor = col



d.name.TextSize = CFG.ESP.TextSize

d.dist.TextSize = math.max(10, CFG.ESP.TextSize - 2) d.name.TextColor3 = col

d.dist.TextColor3 = Color3.new(1, 1, 1)



if CFG.ESP.Names then

d.name.Text = plr.Name .. " [" .. role .. "]"

d.name.Visible = true

else

d.name.Visible = false

end



local distStuds = (hrp.Position - Camera.CFrame.Position).Magnitude if CFG.ESP.Distance then

d.dist.Text = string.format("%.0f studs", distStuds) d.dist.Visible = true

else

d.dist.Visible = false

end



if CFG.ESP.Tracers and d.tracer then

local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position) d.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) d.tracer.To = Vector2.new(sp.X, sp.Y)

d.tracer.Color = col d.tracer.Visible = onScreen and sp.Z > 0

elseif d.tracer then

d.tracer.Visible = false

end

end

end

end



Players.PlayerRemoving:Connect(clearESP)



-- ======================== PLAYER MODS ========================

local spinAngle = 0

RunService.RenderStepped:Connect(function(dt) if CFG.Player.SpeedEnabled and LocalPlayer.Character then local hum = getHumanoid(LocalPlayer.Character) if hum then hum.WalkSpeed = CFG.Player.Speed end end

if CFG.Player.Spin and LocalPlayer.Character then local hrp = getHRP(LocalPlayer.Character)

if hrp then

spinAngle = spinAngle + CFG.Player.SpinSpeed * dt * 60

hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)

end

end

if CFG.Player.Invis and LocalPlayer.Character then for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = 1

end

end

end

updateESP()

end)



-- Anti-fling

local antiFlingConn

local function setAntiFling(on)

if antiFlingConn then antiFlingConn:Disconnect() antiFlingConn = nil end if not on then return end

antiFlingConn = RunService.Heartbeat:Connect(function() local char = LocalPlayer.Character

local hrp = getHRP(char)

if not hrp then return end

if hrp.AssemblyLinearVelocity.Magnitude > 120 then hrp.AssemblyLinearVelocity = Vector3.zero

hrp.AssemblyAngularVelocity = Vector3.zero

end

for _, p in ipairs(char:GetDescendants()) do

if p:IsA("BasePart") and p.CanCollide then

-- soft lock velocity

end

end

end)

end



-- Fling target

local function flingPlayer(plr)

if not plr or not isAlive(plr) then return end local char = LocalPlayer.Character

local hrp = getHRP(char)

local th = getHRP(plr.Character)

if not hrp or not th then return end

local old = hrp.CFrame

for i = 1, 25 do

hrp.CFrame = th.CFrame * CFrame.new(0, 0, 1)

hrp.AssemblyLinearVelocity = Vector3.new(0, 9e4, 0) hrp.AssemblyAngularVelocity = Vector3.new(9e4, 9e4, 9e4) RunService.Heartbeat:Wait()

end

hrp.AssemblyLinearVelocity = Vector3.zero

hrp.AssemblyAngularVelocity = Vector3.zero

hrp.CFrame = old

end



-- Get dropped gun

local function getDroppedGun()

local gun = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Gun") if not gun then

for _, v in ipairs(workspace:GetDescendants()) do if v.Name == "GunDrop" or (v:IsA("Tool") and string.find(string.lower(v.Name), "gun")) then

gun = v

break

end

end

end

if not gun then return end

local hrp = getHRP(LocalPlayer.Character)

if not hrp then return end

local handle = gun:IsA("BasePart") and gun or gun:FindFirstChild("Handle") or gun:FindFirstChildWhichIsA("BasePart") if handle then

hrp.CFrame = handle.CFrame + Vector3.new(0, 3, 0) task.wait(0.15)

-- touch pickup usually automatic in MM2

end

end



-- Kill All (murderer)

local function killAll()

if getRole(LocalPlayer) ~= "Murderer" then return end local tool = LocalPlayer.Character and

LocalPlayer.Character:FindFirstChildOfClass("Tool") for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and isAlive(plr) then

local th = getHRP(plr.Character)

local hrp = getHRP(LocalPlayer.Character)

if th and hrp then

hrp.CFrame = th.CFrame * CFrame.new(0, 0, 2)

if tool then pcall(function() tool:Activate() end) end task.wait(0.12)

end

end

end

end



-- ======================== VISUALS ========================

local skyBackup = {}

local function setSky(name)

local sky = Lighting:FindFirstChildOfClass("Sky") if not sky then

sky = Instance.new("Sky")

sky.Parent = Lighting

end

if name == "Default" then

for k, v in pairs(skyBackup) do sky[k] = v end return

end

if not next(skyBackup) then

skyBackup.SkyboxBk = sky.SkyboxBk

skyBackup.SkyboxDn = sky.SkyboxDn

skyBackup.SkyboxFt = sky.SkyboxFt

skyBackup.SkyboxLf = sky.SkyboxLf

skyBackup.SkyboxRt = sky.SkyboxRt

skyBackup.SkyboxUp = sky.SkyboxUp

end

-- solid-ish via color correction + sky black local colors = {

Black = Color3.new(0, 0, 0),

Red = Color3.fromRGB(180, 20, 20),

Blue = Color3.fromRGB(20, 40, 160),

Yellow = Color3.fromRGB(200, 180, 30),

Orange = Color3.fromRGB(220, 100, 20),

}

local c = colors[name] or Color3.new(0, 0, 0) for _, face in ipairs({"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt",

"SkyboxUp"}) do

sky[face] = ""

end

local cc = Lighting:FindFirstChild("MM2CC") or Instance.new("ColorCorrectionEffect") cc.Name = "MM2CC"

cc.TintColor = c

cc.Brightness = -0.1

cc.Parent = Lighting

end



-- Bullet tracer (simple on tool activate)

local function makeTracer(from, to, color)

local p = Instance.new("Part")

p.Anchored = true

p.CanCollide = false

p.Material = Enum.Material.Neon

p.Color = color

p.Size = Vector3.new(0.12, 0.12, (to - from).Magnitude) p.CFrame = CFrame.lookAt(from, to) * CFrame.new(0, 0, -p.Size.Z / 2) p.Transparency = 0.2

p.Parent = workspace

task.delay(0.35, function() p:Destroy() end)

end



-- ======================== FLOATING BUTTONS + FPS



========================

local gui = Instance.new("ScreenGui")

gui.Name = "MM2Overlay"

gui.ResetOnSpawn = false

gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling pcall(function() gui.Parent = gethui and gethui() or CoreGui end) if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end local function makeFloatBtn(name, pos, callback) local btn = Instance.new("TextButton") btn.Name = name

btn.Size = UDim2.fromOffset(CFG.Buttons.Size, CFG.Buttons.Size) btn.Position = pos

btn.BackgroundColor3 = CFG.Buttons.Color

btn.BackgroundTransparency = CFG.Buttons.Transparency btn.Text = name

btn.TextColor3 = Color3.new(1, 1, 1)

btn.Font = Enum.Font.GothamBold

btn.TextSize = 11

btn.AutoButtonColor = true btn.Parent = gui

local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10)

corner.Parent = btn



local dragging, dragStart, startPos

btn.InputBegan:Connect(function(input)

if CFG.Buttons.Locked then

if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then callback()

end

return

end

if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType

== Enum.UserInputType.Touch then

dragging = true

dragStart = input.Position

startPos = btn.Position

input.Changed:Connect(function()

if input.UserInputState == Enum.UserInputState.End then dragging = false

-- short click = action

if (input.Position - dragStart).Magnitude < 6 then callback()

end

end

end)

end

end)

UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart

btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end

end)

return btn

end



local btnSilent = makeFloatBtn("SAIM", UDim2.new(0.85, 0, 0.4, 0), function() fireSilent()

end)

local btnESP = makeFloatBtn("ESP", UDim2.new(0.85, 0, 0.48, 0), function() CFG.ESP.Enabled = not CFG.ESP.Enabled

end)

local btnGun = makeFloatBtn("GUN", UDim2.new(0.85, 0, 0.56, 0), function() getDroppedGun()

end)



local fpsLabel = Instance.new("TextLabel") fpsLabel.Size = UDim2.fromOffset(90, 28)

fpsLabel.Position = UDim2.new(0, 12, 0, 8)

fpsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 28) fpsLabel.BackgroundTransparency = 0.35

fpsLabel.TextColor3 = Color3.fromRGB(180, 255, 180) fpsLabel.Font = Enum.Font.GothamBold

fpsLabel.TextSize = 14

fpsLabel.Text = "FPS --"

fpsLabel.Parent = gui

Instance.new("UICorner", fpsLabel).CornerRadius = UDim.new(0, 6) do

local dragging, dragStart, startPos

fpsLabel.InputBegan:Connect(function(input)

if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType

== Enum.UserInputType.Touch then

dragging = true

dragStart = input.Position

startPos = fpsLabel.Position

input.Changed:Connect(function()

if input.UserInputState == Enum.UserInputState.End then dragging = false end end)

end

end)

UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart

fpsLabel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end

end)

end



local fpsFrames, fpsLast = 0, tick()

RunService.RenderStepped:Connect(function()

fpsFrames += 1

if tick() - fpsLast >= 1 then

if CFG.Misc.FPS then

fpsLabel.Visible = true

fpsLabel.Text = "FPS " .. tostring(fpsFrames) else

fpsLabel.Visible = false

end

fpsFrames = 0

fpsLast = tick()

end

end)



local function applyButtonStyle()

for _, b in ipairs({btnSilent, btnESP, btnGun}) do b.Size = UDim2.fromOffset(CFG.Buttons.Size, CFG.Buttons.Size) b.BackgroundColor3 = CFG.Buttons.Color

b.BackgroundTransparency = CFG.Buttons.Transparency end

end



-- ======================== WINDUI ========================

local WindUI

local okUI, errUI = pcall(function()

WindUI =

loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/m ain.lua"))()

end)

if not okUI or not WindUI then

okUI, errUI = pcall(function()

WindUI =

loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/m ain.lua"))()

end)

end

if not WindUI then

warn("[MM2] WindUI load failed:", errUI) return

end



local Window = WindUI:CreateWindow({

Title = "MM2",

Icon = "crosshair",

Author = "Dexa",

Folder = "MM2_Dexa",

Size = UDim2.fromOffset(560, 420),

Transparent = true,

Theme = "Dark",

Resizable = true,

SideBarWidth = 150,

Background = BG_URL,

BackgroundImageTransparency = 0.55,

ToggleKey = CFG.Misc.UIKey,

})



-- soft default theme tint

pcall(function()

WindUI:SetTheme("Dark")

end)



local TabCombat = Window:Tab({ Title = "Combat", Icon = "swords" }) local TabESP = Window:Tab({ Title = "ESP", Icon = "eye" }) local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" }) local TabFling = Window:Tab({ Title = "Fling", Icon = "zap" }) local TabButtons = Window:Tab({ Title = "Buttons", Icon = "layout-grid" }) local TabVisuals = Window:Tab({ Title = "Visuals", Icon = "sparkles" }) local TabMisc = Window:Tab({ Title = "Misc", Icon = "settings" })



-- Combat

TabCombat:Toggle({

Title = "Silent Aim (enabled state)", Value = false,

Callback = function(v) CFG.Combat.SilentAim = v end,

})

TabCombat:Toggle({

Title = "Wallbang (through walls)", Value = false,

Callback = function(v) CFG.Combat.Wallbang = v end,

})

TabCombat:Toggle({

Title = "Anti-Aim Resolver",

Value = true,

Callback = function(v) CFG.Combat.Resolver = v end,

})

TabCombat:Toggle({

Title = "Auto Prediction (ping)",

Value = true,

Callback = function(v) CFG.Combat.AutoPrediction = v end,

})

TabCombat:Button({

Title = "Fire Silent Aim (once)",

Callback = function() fireSilent() end,

})

TabCombat:Button({

Title = "Kill All (Murderer only)", Callback = function() killAll() end,

})



-- ESP

TabESP:Toggle({

Title = "ESP Enabled",

Value = false,

Callback = function(v) CFG.ESP.Enabled = v end,

})

TabESP:Dropdown({

Title = "Mode",

Values = { "Outline", "Fill", "Both" }, Value = "Both",

Callback = function(v) CFG.ESP.Mode = v end,

})

TabESP:Slider({

Title = "Fill Transparency",

Value = { Min = 0, Max = 1, Default = 0.55 }, Callback = function(v) CFG.ESP.Transparency = v end,

})

TabESP:Slider({

Title = "Text Size",

Value = { Min = 10, Max = 28, Default = 14 }, Callback = function(v) CFG.ESP.TextSize = v end,

})

TabESP:Toggle({

Title = "Names + Role",

Value = true,

Callback = function(v) CFG.ESP.Names = v end,

})

TabESP:Toggle({

Title = "Distance",

Value = true,

Callback = function(v) CFG.ESP.Distance = v end,

})

TabESP:Toggle({

Title = "Tracers",

Value = true,

Callback = function(v) CFG.ESP.Tracers = v end,

})



-- Player

TabPlayer:Toggle({

Title = "Speed Enabled",

Value = false,

Callback = function(v) CFG.Player.SpeedEnabled = v end,

})

TabPlayer:Slider({

Title = "WalkSpeed",

Value = { Min = 16, Max = 120, Default = 16 }, Callback = function(v) CFG.Player.Speed = v end,

})

TabPlayer:Toggle({

Title = "Invisibility",

Value = false,

Callback = function(v)

CFG.Player.Invis = v

if not v and LocalPlayer.Character then

for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0

elseif p:IsA("Decal") then

p.Transparency = 0

end

end

end

end,

})

TabPlayer:Toggle({

Title = "Spin",

Value = false,

Callback = function(v) CFG.Player.Spin = v end,

})

TabPlayer:Slider({

Title = "Spin Speed",

Value = { Min = 1, Max = 40, Default = 12 },

Callback = function(v) CFG.Player.SpinSpeed = v end,

})



-- Fling

local flingDropdown

local function refreshFlingList()

local names = {}

for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then table.insert(names, plr.Name) end end

return names

end



TabFling:Dropdown({

Title = "Target",

Values = refreshFlingList(),

Value = nil,

Callback = function(v)

CFG.Fling.Target = Players:FindFirstChild(v)

end,

})

TabFling:Button({

Title = "Refresh player list",

Callback = function()

-- WindUI may not hot-reload values; user reopens dropdown WindUI:Notify({ Title = "Fling", Content = "Re-open Target dropdown after players join", Duration = 2 })

end,

})

TabFling:Button({

Title = "Fling Target",

Callback = function()

if CFG.Fling.Target then flingPlayer(CFG.Fling.Target) end end,

})

TabFling:Toggle({

Title = "Anti-Fling",

Value = false,

Callback = function(v)

CFG.Fling.AntiFling = v

setAntiFling(v)

end,

})



-- Buttons

TabButtons:Slider({

Title = "Button Size",

Value = { Min = 32, Max = 80, Default = 48 }, Callback = function(v) CFG.Buttons.Size = v applyButtonStyle() end,

})

TabButtons:Colorpicker({

Title = "Button Color",

Default = CFG.Buttons.Color,

Callback = function(c) CFG.Buttons.Color = c applyButtonStyle() end,

})

TabButtons:Slider({

Title = "Button Transparency",

Value = { Min = 0, Max = 0.9, Default = 0.25 }, Callback = function(v) CFG.Buttons.Transparency = v applyButtonStyle() end,

})

TabButtons:Toggle({

Title = "Lock positions (no drag)", Value = false,

Callback = function(v) CFG.Buttons.Locked = v end,

})

TabButtons:Button({

Title = "Silent Aim (same as SAIM)", Callback = function() fireSilent() end,

})

TabButtons:Button({

Title = "Toggle ESP",

Callback = function() CFG.ESP.Enabled = not CFG.ESP.Enabled end,

})

TabButtons:Button({

Title = "Get Dropped Gun",

Callback = function() getDroppedGun() end,

})



-- Visuals

TabVisuals:Toggle({

Title = "Bullet Tracer",

Value = false,

Callback = function(v) CFG.Visuals.BulletTracer = v end,

})

TabVisuals:Colorpicker({

Title = "Tracer Color",

Default = CFG.Visuals.TracerColor,

Callback = function(c) CFG.Visuals.TracerColor = c end,

})

TabVisuals:Dropdown({

Title = "Sky",

Values = { "Default", "Black", "Red", "Blue", "Yellow", "Orange" }, Value = "Default",

Callback = function(v)

CFG.Visuals.Sky = v

setSky(v)

end,

})



-- Misc

TabMisc:Toggle({

Title = "FPS block",

Value = true,

Callback = function(v) CFG.Misc.FPS = v end,

})

TabMisc:Dropdown({

Title = "Theme",

Values = { "Dark", "Light", "Rose", "Indigo", "Sky", "Violet", "Amber" }, Value = "Dark",

Callback = function(v)

pcall(function() WindUI:SetTheme(v) end)

end,

})

TabMisc:Button({

Title = "Unload",

Callback = function()

CFG.ESP.Enabled = false

for plr in pairs(drawings) do clearESP(plr) end gui:Destroy()

espFolder:Destroy()

pcall(function() Window:Destroy() end)

end,

})



WindUI:Notify({

Title = "MM2",

Content = "Loaded. Soft theme + custom background.", Duration = 4,

})



print("[MM2 ninero] ready")





