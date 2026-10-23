--[[
    Violence District — Ninero
    Dev · ESP · Player · Survivor · Killer · Misc · Visual · Settings
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ======================== CONFIG ========================
local CFG = {
    ESP = {
        Survivor = true,
        Killer = true,
        Names = true,
        Distance = true,
        Items = true, -- flashlight etc
        Windows = true,
        Generators = true,
        Pallets = true,
        Gates = true,
        TextSize = 14,
        FillTransparency = 0.55,
        OutlineThickness = 0.08, -- visual density proxy via outline
        SurvivorMode = "Outline", -- Outline / Fill / Both
        KillerMode = "Fill",
        Colors = {
            Survivor = Color3.fromRGB(70, 220, 120),
            Killer = Color3.fromRGB(255, 60, 60),
            Item = Color3.fromRGB(255, 220, 80),
            Generator = Color3.fromRGB(80, 180, 255),
            Pallet = Color3.fromRGB(200, 140, 60),
            Window = Color3.fromRGB(180, 120, 255),
            Gate = Color3.fromRGB(255, 160, 40),
        },
    },
    Player = {
        WalkSpeed = 16,
        SpeedEnabled = false,
        Noclip = false,
        AntiAFK = true,
        AutoParry = false,
        Godmode = false,
    },
    Survivor = {
        AutoSkillCheck = false,
        NoSkillCheck = false,
    },
    Killer = {
        KillAll = false,
        AutoAttack = false,
        AutoAttackRange = 12,
    },
    Misc = {
        FOV = 70,
        HitboxExpand = false,
        HitboxSize = 6,
        FlingTarget = nil,
        Flinging = false,
        AntiFling = false,
        InfPistol = false,
        SilentAim = false,
        SilentAimFOV = 180,
    },
    Visual = {
        NoFog = false,
        NoShadows = false,
        FullBright = false,
        Sky = "Default", -- Default / Orange / Red / Blue / Green / Mimi
    },
    Settings = {
        UIScale = 1,
        Theme = "SoftDark",
    },
}

local MIMI_URL = "https://i.imgur.com/fi1qPEh.png"
local TG_URL = "https://t.me/NineroTood"
local CONFIG_FOLDER = "VD_Ninero_Configs"

-- ======================== UTILS ========================
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "VD",
            Text = text or "",
            Duration = dur or 3,
        })
    end)
end

local function getHRP(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
end

local function getHumanoid(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isAlive(plr)
    local c = plr.Character
    local h = getHumanoid(c)
    return c and h and h.Health > 0
end

-- Role heuristic: killer often larger / has knife-like tools / team tags
local function getRole(plr)
    local char = plr.Character
    if not char then return "Unknown" end
    local pack = plr:FindFirstChild("Backpack")
    local function hasName(str)
        str = string.lower(str)
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and string.find(string.lower(t.Name), str) then return true end
        end
        if pack then
            for _, t in ipairs(pack:GetChildren()) do
                if t:IsA("Tool") and string.find(string.lower(t.Name), str) then return true end
            end
        end
        return false
    end
    -- common killer markers
    if hasName("knife") or hasName("axe") or hasName("machete") or hasName("claw") or hasName("scythe") or hasName("blade") then
        return "Killer"
    end
    -- attribute / value if game exposes
    local roleVal = char:FindFirstChild("Role") or plr:FindFirstChild("Role")
    if roleVal and roleVal:IsA("StringValue") then
        local r = string.lower(roleVal.Value)
        if string.find(r, "kill") then return "Killer" end
        if string.find(r, "surv") then return "Survivor" end
    end
    -- team name
    if plr.Team then
        local tn = string.lower(plr.Team.Name)
        if string.find(tn, "kill") then return "Killer" end
        if string.find(tn, "surv") then return "Survivor" end
    end
    return "Survivor" -- default majority
end

local function isKiller(plr)
    return getRole(plr) == "Killer"
end

local function isSurvivor(plr)
    return getRole(plr) == "Survivor"
end

-- ======================== ESP ========================
local espFolder = Instance.new("Folder")
espFolder.Name = "VD_ESP"
pcall(function()
    if gethui then espFolder.Parent = gethui() else espFolder.Parent = CoreGui end
end)
if not espFolder.Parent then espFolder.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local playerESP = {} -- [plr] = {hl, bb, name, dist}
local worldESP = {}  -- [inst] = {hl, bb, label}

local function clearPlayerESP(plr)
    local d = playerESP[plr]
    if not d then return end
    for _, v in pairs(d) do
        if typeof(v) == "Instance" then v:Destroy() end
    end
    playerESP[plr] = nil
end

local function clearWorldESP(inst)
    local d = worldESP[inst]
    if not d then return end
    for _, v in pairs(d) do
        if typeof(v) == "Instance" then v:Destroy() end
    end
    worldESP[inst] = nil
end

local function makeBillboard(adornee, sizeY)
    local bb = Instance.new("BillboardGui")
    bb.Adornee = adornee
    bb.Size = UDim2.fromOffset(140, sizeY or 40)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 2.8, 0)
    bb.Parent = espFolder
    return bb
end

local function applyMode(hl, mode, col, fillT)
    hl.OutlineColor = col
    hl.FillColor = col
    if mode == "Outline" then
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
    elseif mode == "Fill" then
        hl.FillTransparency = fillT
        hl.OutlineTransparency = 1
    else
        hl.FillTransparency = fillT
        hl.OutlineTransparency = 0
    end
end

local function updatePlayerESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not isAlive(plr) then
            clearPlayerESP(plr)
        else
            local role = getRole(plr)
            local show = (role == "Killer" and CFG.ESP.Killer) or (role == "Survivor" and CFG.ESP.Survivor)
            if not show then
                clearPlayerESP(plr)
            else
                local char = plr.Character
                local hrp = getHRP(char)
                local head = char:FindFirstChild("Head")
                if not hrp then clearPlayerESP(plr) else
                    local d = playerESP[plr]
                    if not d then
                        d = {}
                        playerESP[plr] = d
                        local hl = Instance.new("Highlight")
                        hl.Adornee = char
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = espFolder
                        d.hl = hl
                        local bb = makeBillboard(head or hrp, 44)
                        local nameL = Instance.new("TextLabel")
                        nameL.BackgroundTransparency = 1
                        nameL.Size = UDim2.new(1, 0, 0.5, 0)
                        nameL.Font = Enum.Font.GothamBold
                        nameL.TextStrokeTransparency = 0.35
                        nameL.Parent = bb
                        d.name = nameL
                        local distL = Instance.new("TextLabel")
                        distL.BackgroundTransparency = 1
                        distL.Size = UDim2.new(1, 0, 0.5, 0)
                        distL.Position = UDim2.new(0, 0, 0.5, 0)
                        distL.Font = Enum.Font.Gotham
                        distL.TextStrokeTransparency = 0.45
                        distL.Parent = bb
                        d.dist = distL
                        d.bb = bb
                    end
                    local col = (role == "Killer") and CFG.ESP.Colors.Killer or CFG.ESP.Colors.Survivor
                    local mode = (role == "Killer") and CFG.ESP.KillerMode or CFG.ESP.SurvivorMode
                    applyMode(d.hl, mode, col, CFG.ESP.FillTransparency)
                    d.name.TextSize = CFG.ESP.TextSize
                    d.dist.TextSize = math.max(10, CFG.ESP.TextSize - 2)
                    d.name.TextColor3 = col
                    d.dist.TextColor3 = Color3.new(1, 1, 1)
                    if CFG.ESP.Names then
                        d.name.Text = plr.Name .. " [" .. role .. "]"
                        d.name.Visible = true
                    else
                        d.name.Visible = false
                    end
                    if CFG.ESP.Distance then
                        local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
                        d.dist.Text = string.format("%.0f m", dist)
                        d.dist.Visible = true
                    else
                        d.dist.Visible = false
                    end
                end
            end
        end
    end
end

-- Only Models, one ESP per model (no double labels on Gen + child parts)
local WORLD_KEYS = {
    { key = "Generators", names = {"generator"}, color = function() return CFG.ESP.Colors.Generator end, enabled = function() return CFG.ESP.Generators end, label = "Generator" },
    { key = "Pallets", names = {"pallet"}, color = function() return CFG.ESP.Colors.Pallet end, enabled = function() return CFG.ESP.Pallets end, label = "Pallet" },
    { key = "Windows", names = {"window", "vault"}, color = function() return CFG.ESP.Colors.Window end, enabled = function() return CFG.ESP.Windows end, label = "Window" },
    { key = "Gates", names = {"gate", "exitgate", "exit_gate"}, color = function() return CFG.ESP.Colors.Gate end, enabled = function() return CFG.ESP.Gates end, label = "Gate" },
    { key = "Items", names = {"flashlight", "bandage", "medkit", "dagger", "tracker", "pistol", "gun", "revolver"}, color = function() return CFG.ESP.Colors.Item end, enabled = function() return CFG.ESP.Items end, label = "Item" },
}

local function nameMatches(instName, list)
    local n = string.lower(instName)
    for _, k in ipairs(list) do
        if n == k or string.find(n, k, 1, true) then return true end
    end
    return false
end

local function scanWorldESP()
    local seen = {}
    local count = 0
    local function consider(inst)
        if not inst:IsA("Model") then return end
        -- skip player characters
        if Players:GetPlayerFromCharacter(inst) then return end
        local part = inst.PrimaryPart or inst:FindFirstChild("HumanoidRootPart") or inst:FindFirstChildWhichIsA("BasePart", true)
        if not part then return end
        for _, w in ipairs(WORLD_KEYS) do
            if w.enabled() and nameMatches(inst.Name, w.names) then
                seen[inst] = true
                count = count + 1
                local d = worldESP[inst]
                if not d then
                    d = {}
                    worldESP[inst] = d
                    local hl = Instance.new("Highlight")
                    hl.Adornee = inst
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = espFolder
                    d.hl = hl
                    local bb = makeBillboard(part, 28)
                    local lab = Instance.new("TextLabel")
                    lab.BackgroundTransparency = 1
                    lab.Size = UDim2.new(1, 0, 1, 0)
                    lab.Font = Enum.Font.GothamBold
                    lab.TextStrokeTransparency = 0.4
                    lab.TextSize = math.max(11, CFG.ESP.TextSize - 1)
                    lab.Parent = bb
                    d.label = lab
                    d.bb = bb
                end
                local col = w.color()
                applyMode(d.hl, "Both", col, CFG.ESP.FillTransparency)
                d.label.TextColor3 = col
                d.label.Text = w.label
                break
            end
        end
    end
    for _, inst in ipairs(workspace:GetDescendants()) do
        if count > 250 then break end
        consider(inst)
    end
    for inst in pairs(worldESP) do
        if not seen[inst] or not inst.Parent then
            clearWorldESP(inst)
        end
    end
end

local worldScanClock = 0
RunService.RenderStepped:Connect(function(dt)
    updatePlayerESP()
    worldScanClock = worldScanClock + dt
    if worldScanClock >= 1.25 then
        worldScanClock = 0
        pcall(scanWorldESP)
    end
end)

Players.PlayerRemoving:Connect(clearPlayerESP)

-- ======================== PLAYER ========================
local noclipConn
local function setNoclip(on)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if not on then return end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end)
end

-- Anti AFK
task.spawn(function()
    while true do
        if CFG.Player.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
        task.wait(60)
    end
end)

RunService.RenderStepped:Connect(function()
    if CFG.Player.SpeedEnabled and LocalPlayer.Character then
        local hum = getHumanoid(LocalPlayer.Character)
        if hum then hum.WalkSpeed = CFG.Player.WalkSpeed end
    end
    if CFG.Player.Godmode and LocalPlayer.Character then
        local hum = getHumanoid(LocalPlayer.Character)
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
        end
    end
end)

-- Godmode: also block health drops
local godConn
local function setGodmode(on)
    if godConn then godConn:Disconnect() godConn = nil end
    if not on then
        local hum = getHumanoid(LocalPlayer.Character)
        if hum then hum.MaxHealth = 100 hum.Health = 100 end
        return
    end
    local function hookChar(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        godConn = hum.HealthChanged:Connect(function()
            if CFG.Player.Godmode then
                hum.Health = hum.MaxHealth
            end
        end)
    end
    if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        if CFG.Player.Godmode then task.wait(0.3) hookChar(c) end
    end)
end

-- Auto Parry: when dagger/parry tool equipped and killer close / attack cue → activate
local function hasParryTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local n = string.lower(t.Name)
            if string.find(n, "parry") or string.find(n, "dagger") or string.find(n, "block") or string.find(n, "shield") then
                return t
            end
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not CFG.Player.AutoParry then return end
    local tool = hasParryTool()
    if not tool then return end
    local myHRP = getHRP(LocalPlayer.Character)
    if not myHRP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and isKiller(plr) then
            local kHRP = getHRP(plr.Character)
            if kHRP and (kHRP.Position - myHRP.Position).Magnitude <= 14 then
                pcall(function() tool:Activate() end)
            end
        end
    end
end)

-- ======================== SURVIVOR: skillcheck ========================
-- Common pattern: skillcheck GUI with needle / progress; press Space / click in zone
local function pressSpace()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end

local skillConn
local function bindSkillCheck()
    if skillConn then skillConn:Disconnect() skillConn = nil end
    skillConn = RunService.RenderStepped:Connect(function()
        if not CFG.Survivor.AutoSkillCheck and not CFG.Survivor.NoSkillCheck then return end
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        for _, gui in ipairs(pg:GetDescendants()) do
            local n = string.lower(gui.Name)
            if string.find(n, "skill") or string.find(n, "check") or string.find(n, "qte") then
                if CFG.Survivor.NoSkillCheck then
                    -- hide / destroy skill UI
                    if gui:IsA("ScreenGui") or gui:IsA("Frame") then
                        pcall(function() gui.Enabled = false end)
                        pcall(function() gui.Visible = false end)
                    end
                elseif CFG.Survivor.AutoSkillCheck then
                    -- spam perfect input when skill UI present
                    if gui:IsA("Frame") or gui:IsA("ScreenGui") then
                        if gui.Visible or (gui:IsA("ScreenGui") and gui.Enabled) then
                            pressSpace()
                        end
                    end
                end
            end
        end
    end)
end
bindSkillCheck()

-- ======================== KILLER ========================
local function doKillAll()
    local myHRP = getHRP(LocalPlayer.Character)
    if not myHRP then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and isSurvivor(plr) then
            local th = getHRP(plr.Character)
            if th then
                myHRP.CFrame = th.CFrame * CFrame.new(0, 0, 2)
                if tool then pcall(function() tool:Activate() end) end
                pcall(function() if mouse1click then mouse1click() end end)
                task.wait(0.08)
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not CFG.Killer.AutoAttack then return end
    local myHRP = getHRP(LocalPlayer.Character)
    if not myHRP then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and isSurvivor(plr) then
            local th = getHRP(plr.Character)
            if th and (th.Position - myHRP.Position).Magnitude <= CFG.Killer.AutoAttackRange then
                if tool then pcall(function() tool:Activate() end) end
                pcall(function() if mouse1click then mouse1click() end end)
            end
        end
    end
end)

-- ======================== MISC: FOV / Hitbox / Fling ========================
local function setFOV(v)
    pcall(function() Camera.FieldOfView = v end)
end

local hitboxPart
local function setHitboxExpand(on, size)
    if hitboxPart then hitboxPart:Destroy() hitboxPart = nil end
    if not on then
        -- restore default sizes roughly
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    -- leave; expanding others is more aggressive
                end
            end
        end
        return
    end
    local hrp = getHRP(LocalPlayer.Character)
    if not hrp then return end
    hitboxPart = Instance.new("Part")
    hitboxPart.Name = "VD_HitboxVis"
    hitboxPart.Shape = Enum.PartType.Ball
    hitboxPart.Size = Vector3.new(size, size, size)
    hitboxPart.Transparency = 0.7
    hitboxPart.Color = Color3.fromRGB(255, 80, 80)
    hitboxPart.Material = Enum.Material.ForceField
    hitboxPart.CanCollide = false
    hitboxPart.Anchored = false
    hitboxPart.Massless = true
    hitboxPart.Parent = LocalPlayer.Character
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = hitboxPart
    weld.Parent = hitboxPart
    -- expand HRP size slightly for hit detection (client-side visual + some games read size)
    pcall(function()
        hrp.Size = Vector3.new(math.max(2, size * 0.35), math.max(2, size * 0.35), math.max(1, size * 0.25))
    end)
end

local flingStop = false
local function flingPlayer(plr)
    if not plr or not isAlive(plr) then return end
    flingStop = false
    CFG.Misc.Flinging = true
    local hrp = getHRP(LocalPlayer.Character)
    local th = getHRP(plr.Character)
    if not hrp or not th then CFG.Misc.Flinging = false return end
    local old = hrp.CFrame
    for i = 1, 40 do
        if flingStop then break end
        hrp.CFrame = th.CFrame * CFrame.new(0, 0, 1)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 9e4, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(9e4, 9e4, 9e4)
        RunService.Heartbeat:Wait()
    end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = old
    CFG.Misc.Flinging = false
end

local function flingKiller()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and isKiller(plr) then
            flingPlayer(plr)
            return
        end
    end
    notify("Fling", "Killer not found")
end

local function flingAll()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            flingPlayer(plr)
            if flingStop then break end
        end
    end
end

-- Anti-fling
local antiFlingConn
local function setAntiFling(on)
    if antiFlingConn then antiFlingConn:Disconnect() antiFlingConn = nil end
    if not on then return end
    antiFlingConn = RunService.Heartbeat:Connect(function()
        local hrp = getHRP(LocalPlayer.Character)
        if not hrp then return end
        if hrp.AssemblyLinearVelocity.Magnitude > 100 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        if hrp.AssemblyAngularVelocity.Magnitude > 50 then
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

-- ======================== PISTOL: silent aim + no fail ========================
local function isPistolTool(tool)
    if not tool then return false end
    local n = string.lower(tool.Name)
    return string.find(n, "pistol") or string.find(n, "gun") or string.find(n, "revolver") or string.find(n, "handgun")
end

local function getSilentTarget()
    local origin = Camera.CFrame.Position
    local best, bestAng = nil, CFG.Misc.SilentAimFOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            -- prefer killer when survivor; any when needed
            local hrp = getHRP(plr.Character)
            local head = plr.Character and plr.Character:FindFirstChild("Head")
            local part = head or hrp
            if part then
                local dir = (part.Position - origin).Unit
                local look = Camera.CFrame.LookVector
                local ang = math.deg(math.acos(math.clamp(look:Dot(dir), -1, 1)))
                if ang < bestAng then
                    bestAng = ang
                    best = part
                end
            end
        end
    end
    return best
end

local pistolSilentPos, pistolSilentPart = nil, nil
local pistolMouseHooked = false
local function hookPistolMouse()
    if pistolMouseHooked then return end
    pistolMouseHooked = true
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(Mouse) or getmetatable(Mouse)
        if not mt then return end
        if setreadonly then setreadonly(mt, false) end
        local oldIndex = mt.__index
        local function handler(self, key)
            if CFG.Misc.SilentAim and pistolSilentPos and (key == "Hit" or key == "hit") then
                return CFrame.new(pistolSilentPos)
            end
            if CFG.Misc.SilentAim and pistolSilentPart and (key == "Target" or key == "target") then
                return pistolSilentPart
            end
            if type(oldIndex) == "function" then return oldIndex(self, key) end
            return oldIndex[key]
        end
        mt.__index = newcclosure and newcclosure(handler) or handler
        if setreadonly then setreadonly(mt, true) end
    end)
end
pcall(hookPistolMouse)

RunService.RenderStepped:Connect(function()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if CFG.Misc.SilentAim and isPistolTool(tool) then
        local part = getSilentTarget()
        if part then
            pistolSilentPart = part
            pistolSilentPos = part.Position
        else
            pistolSilentPart, pistolSilentPos = nil, nil
        end
    else
        pistolSilentPart, pistolSilentPos = nil, nil
    end
end)

-- Infinite ammo / no self-fail: keep tool ready, block common fail cooldowns client-side
RunService.Heartbeat:Connect(function()
    if not CFG.Misc.InfPistol then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not isPistolTool(tool) then return end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local n = string.lower(v.Name)
            if string.find(n, "ammo") or string.find(n, "clip") or string.find(n, "bullet") then
                if v.Value < 1 then v.Value = 99 end
            end
            if string.find(n, "cooldown") or string.find(n, "cd") then
                if v.Value > 0 then v.Value = 0 end
            end
        end
        if v:IsA("BoolValue") and (string.find(string.lower(v.Name), "fail") or string.find(string.lower(v.Name), "jam")) then
            v.Value = false
        end
    end
end)

-- ======================== VISUAL ========================
local skyBackup = {}
local mimiAsset = nil

local function loadMimiAsset()
    if mimiAsset then return mimiAsset end
    local ok, result = pcall(function()
        local data
        if request then
            local res = request({ Url = MIMI_URL, Method = "GET" })
            data = res and res.Body
        elseif http_request then
            local res = http_request({ Url = MIMI_URL, Method = "GET" })
            data = res and res.Body
        elseif syn and syn.request then
            local res = syn.request({ Url = MIMI_URL, Method = "GET" })
            data = res and res.Body
        end
        if data and writefile and getcustomasset then
            local path = "vd_mimi_sky.png"
            writefile(path, data)
            return getcustomasset(path)
        end
        return nil
    end)
    if ok and result then
        mimiAsset = result
        return mimiAsset
    end
    return nil
end

local function applySky(name)
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    if name == "Default" then
        for k, v in pairs(skyBackup) do pcall(function() sky[k] = v end) end
        local cc = Lighting:FindFirstChild("VD_CC")
        if cc then cc:Destroy() end
        return
    end
    if not next(skyBackup) then
        for _, f in ipairs({"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}) do
            skyBackup[f] = sky[f]
        end
    end
    if name == "Mimi" then
        local asset = loadMimiAsset()
        if asset then
            for _, f in ipairs({"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}) do
                sky[f] = asset
            end
        else
            -- fallback soft pink tint if custom asset unavailable
            for _, f in ipairs({"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}) do
                sky[f] = ""
            end
        end
        local cc = Lighting:FindFirstChild("VD_CC") or Instance.new("ColorCorrectionEffect")
        cc.Name = "VD_CC"
        cc.TintColor = Color3.fromRGB(255, 210, 225)
        cc.Brightness = 0.12
        cc.Contrast = 0.05
        cc.Saturation = 0.1
        cc.Parent = Lighting
        return
    end
    -- soft light gradients
    local map = {
        Orange = Color3.fromRGB(255, 200, 150),
        Red = Color3.fromRGB(255, 160, 160),
        Blue = Color3.fromRGB(160, 200, 255),
        Green = Color3.fromRGB(170, 230, 190),
    }
    local c = map[name] or Color3.fromRGB(200, 200, 200)
    for _, f in ipairs({"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}) do
        sky[f] = ""
    end
    local cc = Lighting:FindFirstChild("VD_CC") or Instance.new("ColorCorrectionEffect")
    cc.Name = "VD_CC"
    cc.TintColor = c
    cc.Brightness = 0.15
    cc.Saturation = 0.2
    cc.Contrast = 0.05
    cc.Parent = Lighting
    Lighting.Ambient = c:Lerp(Color3.new(1, 1, 1), 0.5)
    Lighting.OutdoorAmbient = c:Lerp(Color3.new(1, 1, 1), 0.4)
end

local function setNoFog(on)
    if on then
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
    else
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
    end
end

local function setNoShadows(on)
    Lighting.GlobalShadows = not on
end

local function setFullBright(on)
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end

local function tryEscape()
    -- walk / tp toward gate-like objects
    local hrp = getHRP(LocalPlayer.Character)
    if not hrp then return end
    local best, bestD = nil, math.huge
    for _, inst in ipairs(workspace:GetDescendants()) do
        local n = string.lower(inst.Name)
        if (string.find(n, "gate") or string.find(n, "exit") or string.find(n, "escape")) and (inst:IsA("BasePart") or inst:IsA("Model")) then
            local p = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
            if p then
                local d = (p.Position - hrp.Position).Magnitude
                if d < bestD then bestD = d best = p end
            end
        end
    end
    if best then
        hrp.CFrame = best.CFrame + Vector3.new(0, 3, 0)
        notify("Escape", "Moved to exit/gate")
    else
        notify("Escape", "No gate found")
    end
end

-- ======================== WINDUI ========================
local WindUI
local okUI = pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not okUI or not WindUI then
    pcall(function()
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
end
if not WindUI then
    warn("[VD] WindUI failed to load")
    return
end

-- soft gradient themes via WindUI SetTheme when available
local Window = WindUI:CreateWindow({
    Title = "Violence District",
    Icon = "skull",
    Author = "Ninero",
    Folder = "VD_Ninero",
    Size = UDim2.fromOffset(580, 440),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 150,
    Background = MIMI_URL,
    BackgroundImageTransparency = 0.55,
    ToggleKey = Enum.KeyCode.LeftControl,
})

local TabDev = Window:Tab({ Title = "Dev", Icon = "code" })
local TabESP = Window:Tab({ Title = "ESP", Icon = "eye" })
local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" })
local TabSurv = Window:Tab({ Title = "Survivor", Icon = "heart" })
local TabKiller = Window:Tab({ Title = "Killer", Icon = "swords" })
local TabTP = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local TabMisc = Window:Tab({ Title = "Misc", Icon = "wrench" })
local TabVisual = Window:Tab({ Title = "Visual", Icon = "sparkles" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

-- DEV
TabDev:Button({
    Title = "TG Channel",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard(TG_URL) end
        end)
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow(TG_URL)
        end)
        notify("Dev", "t.me/NineroTood (copied if supported)")
    end,
})
TabDev:Paragraph({
    Title = "Ninero",
    Desc = "Violence District hub · t.me/NineroTood",
})

-- ESP toggles
TabESP:Toggle({ Title = "ESP Survivors", Value = true, Callback = function(v) CFG.ESP.Survivor = v end })
TabESP:Toggle({ Title = "ESP Killer", Value = true, Callback = function(v) CFG.ESP.Killer = v end })
TabESP:Toggle({ Title = "ESP Names", Value = true, Callback = function(v) CFG.ESP.Names = v end })
TabESP:Toggle({ Title = "ESP Distance", Value = true, Callback = function(v) CFG.ESP.Distance = v end })
TabESP:Toggle({ Title = "ESP Items (flashlight…)", Value = true, Callback = function(v) CFG.ESP.Items = v end })
TabESP:Toggle({ Title = "ESP Windows", Value = true, Callback = function(v) CFG.ESP.Windows = v end })
TabESP:Toggle({ Title = "ESP Generators", Value = true, Callback = function(v) CFG.ESP.Generators = v end })
TabESP:Toggle({ Title = "ESP Pallets", Value = true, Callback = function(v) CFG.ESP.Pallets = v end })
TabESP:Toggle({ Title = "ESP Gates", Value = true, Callback = function(v) CFG.ESP.Gates = v end })

TabESP:Dropdown({
    Title = "Survivor ESP mode",
    Values = { "Outline", "Fill", "Both" },
    Value = "Outline",
    Callback = function(v) CFG.ESP.SurvivorMode = v end,
})
TabESP:Dropdown({
    Title = "Killer ESP mode",
    Values = { "Outline", "Fill", "Both" },
    Value = "Fill",
    Callback = function(v) CFG.ESP.KillerMode = v end,
})
TabESP:Slider({
    Title = "Fill transparency (density)",
    Value = { Min = 0, Max = 1, Default = 0.55 },
    Callback = function(v) CFG.ESP.FillTransparency = v end,
})
TabESP:Slider({
    Title = "Text size (names/distance)",
    Value = { Min = 10, Max = 28, Default = 14 },
    Callback = function(v) CFG.ESP.TextSize = v end,
})
TabESP:Colorpicker({
    Title = "Survivor color",
    Default = CFG.ESP.Colors.Survivor,
    Callback = function(c) CFG.ESP.Colors.Survivor = c end,
})
TabESP:Colorpicker({
    Title = "Killer color",
    Default = CFG.ESP.Colors.Killer,
    Callback = function(c) CFG.ESP.Colors.Killer = c end,
})
TabESP:Colorpicker({
    Title = "Generator color",
    Default = CFG.ESP.Colors.Generator,
    Callback = function(c) CFG.ESP.Colors.Generator = c end,
})
TabESP:Colorpicker({
    Title = "Pallet color",
    Default = CFG.ESP.Colors.Pallet,
    Callback = function(c) CFG.ESP.Colors.Pallet = c end,
})

-- PLAYER
TabPlayer:Toggle({
    Title = "Custom WalkSpeed",
    Value = false,
    Callback = function(v) CFG.Player.SpeedEnabled = v end,
})
TabPlayer:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 50, Default = 16 },
    Callback = function(v) CFG.Player.WalkSpeed = v end,
})
TabPlayer:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(v)
        CFG.Player.Noclip = v
        setNoclip(v)
    end,
})
TabPlayer:Toggle({
    Title = "Anti AFK",
    Value = true,
    Callback = function(v) CFG.Player.AntiAFK = v end,
})
TabPlayer:Toggle({
    Title = "Auto Parry (dagger when killer hits)",
    Value = false,
    Callback = function(v) CFG.Player.AutoParry = v end,
})
TabPlayer:Toggle({
    Title = "Godmode",
    Value = false,
    Callback = function(v)
        CFG.Player.Godmode = v
        setGodmode(v)
    end,
})

-- TELEPORT
local tpTargetName = nil
TabTP:Dropdown({
    Title = "Player",
    Values = (function()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(t, p.Name) end
        end
        if #t == 0 then table.insert(t, "none") end
        return t
    end)(),
    Value = nil,
    Callback = function(name) tpTargetName = name end,
})
TabTP:Button({
    Title = "TP to selected player",
    Callback = function()
        local plr = tpTargetName and Players:FindFirstChild(tpTargetName)
        local th = plr and getHRP(plr.Character)
        local hrp = getHRP(LocalPlayer.Character)
        if th and hrp then
            hrp.CFrame = th.CFrame + Vector3.new(0, 3, 0)
        else
            notify("TP", "Player not found")
        end
    end,
})
TabTP:Button({
    Title = "TP to Killer",
    Callback = function()
        local hrp = getHRP(LocalPlayer.Character)
        if not hrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) and isKiller(plr) then
                local th = getHRP(plr.Character)
                if th then
                    hrp.CFrame = th.CFrame + Vector3.new(0, 3, 0)
                    return
                end
            end
        end
        notify("TP", "Killer not found")
    end,
})

-- SURVIVOR
TabSurv:Toggle({
    Title = "Auto SkillCheck (perfect)",
    Value = false,
    Callback = function(v)
        CFG.Survivor.AutoSkillCheck = v
        if v then CFG.Survivor.NoSkillCheck = false end
    end,
})
TabSurv:Toggle({
    Title = "No SkillCheck (hide checks)",
    Value = false,
    Callback = function(v)
        CFG.Survivor.NoSkillCheck = v
        if v then CFG.Survivor.AutoSkillCheck = false end
    end,
})

-- KILLER
TabKiller:Button({
    Title = "Kill All",
    Callback = function() doKillAll() end,
})
TabKiller:Toggle({
    Title = "Auto Attack (nearby survivors)",
    Value = false,
    Callback = function(v) CFG.Killer.AutoAttack = v end,
})
TabKiller:Slider({
    Title = "Auto Attack range",
    Value = { Min = 6, Max = 25, Default = 12 },
    Callback = function(v) CFG.Killer.AutoAttackRange = v end,
})

-- MISC
TabMisc:Slider({
    Title = "FOV",
    Value = { Min = 50, Max = 120, Default = 70 },
    Callback = function(v)
        CFG.Misc.FOV = v
        setFOV(v)
    end,
})
TabMisc:Toggle({
    Title = "Hitbox Expand (+ visual circle)",
    Value = false,
    Callback = function(v)
        CFG.Misc.HitboxExpand = v
        setHitboxExpand(v, CFG.Misc.HitboxSize)
    end,
})
TabMisc:Slider({
    Title = "Hitbox size",
    Value = { Min = 3, Max = 14, Default = 6 },
    Callback = function(v)
        CFG.Misc.HitboxSize = v
        if CFG.Misc.HitboxExpand then setHitboxExpand(true, v) end
    end,
})
TabMisc:Button({
    Title = "Fling Killer",
    Callback = function() flingKiller() end,
})
TabMisc:Button({
    Title = "Fling All",
    Callback = function() flingAll() end,
})
TabMisc:Dropdown({
    Title = "Fling selected player",
    Values = (function()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(t, p.Name) end
        end
        if #t == 0 then table.insert(t, "none") end
        return t
    end)(),
    Value = nil,
    Callback = function(name)
        CFG.Misc.FlingTarget = Players:FindFirstChild(name)
    end,
})
TabMisc:Button({
    Title = "Fling Selected",
    Callback = function()
        if CFG.Misc.FlingTarget then flingPlayer(CFG.Misc.FlingTarget)
        else notify("Fling", "Select a player") end
    end,
})
TabMisc:Button({
    Title = "Stop Fling",
    Callback = function()
        flingStop = true
        CFG.Misc.Flinging = false
    end,
})
TabMisc:Toggle({
    Title = "Anti-Fling",
    Value = false,
    Callback = function(v)
        CFG.Misc.AntiFling = v
        setAntiFling(v)
    end,
})
TabMisc:Toggle({
    Title = "Infinite Pistol (no fail / ammo)",
    Value = false,
    Callback = function(v) CFG.Misc.InfPistol = v end,
})
TabMisc:Toggle({
    Title = "Pistol Silent Aim",
    Value = false,
    Callback = function(v) CFG.Misc.SilentAim = v end,
})
TabMisc:Slider({
    Title = "Silent Aim FOV",
    Value = { Min = 30, Max = 360, Default = 180 },
    Callback = function(v) CFG.Misc.SilentAimFOV = v end,
})

-- VISUAL
TabVisual:Toggle({
    Title = "No Fog",
    Value = false,
    Callback = function(v) CFG.Visual.NoFog = v setNoFog(v) end,
})
TabVisual:Toggle({
    Title = "No Shadows",
    Value = false,
    Callback = function(v) CFG.Visual.NoShadows = v setNoShadows(v) end,
})
TabVisual:Toggle({
    Title = "Full Bright",
    Value = false,
    Callback = function(v) CFG.Visual.FullBright = v setFullBright(v) end,
})
TabVisual:Button({
    Title = "Escape (TP to gate)",
    Callback = function() tryEscape() end,
})
TabVisual:Dropdown({
    Title = "Sky",
    Values = { "Default", "Orange", "Red", "Blue", "Green", "Mimi" },
    Value = "Default",
    Callback = function(v)
        CFG.Visual.Sky = v
        applySky(v)
    end,
})

-- SETTINGS: configs + theme + UI size
local function ensureFolder()
    if isfolder and not isfolder(CONFIG_FOLDER) then
        pcall(makefolder, CONFIG_FOLDER)
    end
end

local function saveConfig(name)
    ensureFolder()
    name = name or "default"
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, CFG)
    if ok and writefile then
        writefile(path, encoded)
        notify("Config", "Saved: " .. name)
    else
        notify("Config", "writefile not available")
    end
end

local function loadConfig(name)
    name = name or "default"
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if not isfile or not isfile(path) then
        notify("Config", "Not found: " .. name)
        return
    end
    local raw = readfile(path)
    local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do
            if type(v) == "table" and type(CFG[k]) == "table" then
                for k2, v2 in pairs(v) do CFG[k][k2] = v2 end
            else
                CFG[k] = v
            end
        end
        setFOV(CFG.Misc.FOV)
        setNoclip(CFG.Player.Noclip)
        setHitboxExpand(CFG.Misc.HitboxExpand, CFG.Misc.HitboxSize)
        setNoFog(CFG.Visual.NoFog)
        setNoShadows(CFG.Visual.NoShadows)
        setFullBright(CFG.Visual.FullBright)
        applySky(CFG.Visual.Sky)
        notify("Config", "Loaded: " .. name)
    end
end

local function deleteConfig(name)
    name = name or "default"
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if isfile and isfile(path) and delfile then
        delfile(path)
        notify("Config", "Deleted: " .. name)
    end
end

local configName = "default"

TabSettings:Dropdown({
    Title = "Theme",
    Values = { "Dark", "Light", "Rose", "Indigo", "Sky", "Violet", "Amber", "SoftDark" },
    Value = "Dark",
    Callback = function(v)
        CFG.Settings.Theme = v
        pcall(function() WindUI:SetTheme(v == "SoftDark" and "Dark" or v) end)
    end,
})
TabSettings:Slider({
    Title = "UI Scale",
    Value = { Min = 0.75, Max = 1.35, Default = 1 },
    Callback = function(v)
        CFG.Settings.UIScale = v
        pcall(function() Window:SetUIScale(v) end)
    end,
})
TabSettings:Button({
    Title = "Save config (default)",
    Callback = function() saveConfig(configName) end,
})
TabSettings:Button({
    Title = "Load config (default)",
    Callback = function() loadConfig(configName) end,
})
TabSettings:Button({
    Title = "Delete config (default)",
    Callback = function() deleteConfig(configName) end,
})
TabSettings:Button({
    Title = "Unload",
    Callback = function()
        setNoclip(false)
        setHitboxExpand(false)
        for plr in pairs(playerESP) do clearPlayerESP(plr) end
        for inst in pairs(worldESP) do clearWorldESP(inst) end
        espFolder:Destroy()
        pcall(function() Window:Destroy() end)
    end,
})

WindUI:Notify({
    Title = "Violence District",
    Content = "Ninero loaded · t.me/NineroTood",
    Duration = 4,
})

print("[VD Ninero] ready")
