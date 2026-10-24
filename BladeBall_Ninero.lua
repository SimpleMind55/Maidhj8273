--[[
    Blade Ball — Ninero
    WindUI · Auto Parry (velocity / ETA / ping) · Player ESP · Ability ESP
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ======================== CONFIG ========================
local CFG = {
    Parry = {
        Enabled = true,
        PingBased = true,
        PingOffset = 0.55,
        ETAThreshold = 0.28,      -- seconds until impact to trigger
        EmergencyDist = 8,        -- always parry inside this
        MinDot = 0.12,            -- ball must be moving toward you
        MaxDist = 220,
        MinSpeed = 5,
        SpamClose = true,         -- multi-parry when very close
        SpamDist = 14,
        SpamCount = 4,
        SpamDelay = 0.018,
        Cooldown = 0.03,          -- min time between parry bursts
        Method = "All",           -- Key / Remote / All
        ParryKey = Enum.KeyCode.F,
        VisualBall = true,
    },
    ESP = {
        Players = true,
        Abilities = true,
        Names = true,
        Distance = true,
        TextSize = 14,
        PlayerFill = 0.55,
        PlayerColor = Color3.fromRGB(80, 200, 255),
        AbilityColor = Color3.fromRGB(255, 120, 255),
        BallColor = Color3.fromRGB(255, 70, 70),
    },
}

local lastParry = 0
local parryBusy = false

-- ======================== UTILS ========================
local function notify(t, m)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = t or "BB", Text = m or "", Duration = 3 })
    end)
end

local function getHRP(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
end

local function getHum(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function alive(plr)
    local c = plr.Character
    local h = getHum(c)
    return c and h and h.Health > 0
end

local function getPing()
    local ok, p = pcall(function()
        return LocalPlayer:GetNetworkPing()
    end)
    return (ok and p) or 0.05
end

-- ======================== BALL FINDER ========================
local function getBalls()
    local list = {}
    local folders = {
        workspace:FindFirstChild("Balls"),
        workspace:FindFirstChild("balls"),
        workspace:FindFirstChild("Ball"),
        workspace,
    }
    for _, root in ipairs(folders) do
        if not root then continue end
        for _, obj in ipairs(root:GetChildren()) do
            local n = string.lower(obj.Name)
            if string.find(n, "ball") or string.find(n, "slash") or n == "part" then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                if part and part.AssemblyLinearVelocity.Magnitude > 0.5 then
                    table.insert(list, part)
                end
            end
        end
        -- also scan descendants once if empty
        if #list == 0 and root == workspace then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if (string.find(n, "ball") or string.find(n, "sphere")) and obj.AssemblyLinearVelocity.Magnitude > 2 then
                        table.insert(list, obj)
                    end
                end
                if #list > 8 then break end
            end
        end
    end
    return list
end

local function isBallTargetingMe(ball, hrp)
    if not ball or not hrp then return false, 0, 0, 0 end
    local pos = ball.Position
    local vel = ball.AssemblyLinearVelocity
    local speed = vel.Magnitude
    local toPlayer = hrp.Position - pos
    local dist = toPlayer.Magnitude
    if dist < 0.05 or speed < CFG.Parry.MinSpeed then
        return false, dist, speed, math.huge
    end
    local toUnit = toPlayer.Unit
    local vUnit = vel.Unit
    local dot = vUnit:Dot(toUnit)
    if dot < CFG.Parry.MinDot then
        return false, dist, speed, math.huge
    end
    local closing = vel:Dot(toUnit)
    if closing <= 0 then
        return false, dist, speed, math.huge
    end
    local eta = dist / closing
    return true, dist, speed, eta, dot
end

-- ======================== PARRY SEND ========================
local cachedRemotes = {}
local function findParryRemotes()
    if next(cachedRemotes) then return cachedRemotes end
    local names = { "Parry", "parry", "Block", "block", "SlashParry", "UseParry", "ParryButtonPress", "ParryRemote" }
    local function scan(root, depth)
        if depth > 5 or not root then return end
        for _, c in ipairs(root:GetChildren()) do
            if c:IsA("RemoteEvent") or c:IsA("RemoteFunction") then
                local n = string.lower(c.Name)
                for _, k in ipairs(names) do
                    if string.find(n, string.lower(k)) then
                        table.insert(cachedRemotes, c)
                        break
                    end
                end
            end
            if c:IsA("Folder") or c:IsA("ModuleScript") or c.ClassName == "Configuration" then
                scan(c, depth + 1)
            end
        end
    end
    pcall(scan, ReplicatedStorage, 0)
    pcall(scan, LocalPlayer:FindFirstChild("PlayerScripts"), 0)
    -- also Packages / Controllers common in BB
    local packages = ReplicatedStorage:FindFirstChild("Packages") or ReplicatedStorage:FindFirstChild("Shared")
    pcall(scan, packages, 0)
    return cachedRemotes
end

local function pressParryKey()
    local key = CFG.Parry.ParryKey
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
    pcall(function()
        if keypress and keyrelease then
            keypress(0x46) -- F
            task.wait()
            keyrelease(0x46)
        end
    end)
    pcall(function()
        mouse1click()
    end)
end

local function fireParryRemotes()
    local rems = findParryRemotes()
    for _, r in ipairs(rems) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer()
                pcall(function() r:FireServer(0.5) end)
                pcall(function() r:FireServer(true) end)
            elseif r:IsA("RemoteFunction") then
                r:InvokeServer()
            end
        end)
    end
    -- common BB pattern: Remotes.Parry
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r then
            local p = r:FindFirstChild("Parry") or r:FindFirstChild("parry")
            if p and p.FireServer then p:FireServer() end
        end
    end)
end

local function doParry(spam)
    local now = tick()
    if now - lastParry < CFG.Parry.Cooldown and not spam then return end
    lastParry = now
    local method = CFG.Parry.Method
    if method == "Key" or method == "All" then
        pressParryKey()
    end
    if method == "Remote" or method == "All" then
        fireParryRemotes()
    end
    if spam and CFG.Parry.SpamClose then
        task.spawn(function()
            for i = 1, CFG.Parry.SpamCount do
                task.wait(CFG.Parry.SpamDelay)
                if method == "Key" or method == "All" then pressParryKey() end
                if method == "Remote" or method == "All" then fireParryRemotes() end
            end
        end)
    end
end

-- ======================== AUTO PARRY LOOP ========================
local ballHighlight
local function ensureBallHL(part)
    if not CFG.Parry.VisualBall then
        if ballHighlight then ballHighlight:Destroy() ballHighlight = nil end
        return
    end
    if not ballHighlight then
        ballHighlight = Instance.new("Highlight")
        ballHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        ballHighlight.FillTransparency = 0.4
        ballHighlight.OutlineTransparency = 0
        ballHighlight.FillColor = CFG.ESP.BallColor
        ballHighlight.OutlineColor = CFG.ESP.BallColor
        ballHighlight.Parent = CoreGui
    end
    ballHighlight.Adornee = part
end

RunService.Heartbeat:Connect(function()
    if not CFG.Parry.Enabled then
        if ballHighlight then ballHighlight.Adornee = nil end
        return
    end
    local char = LocalPlayer.Character
    local hrp = getHRP(char)
    if not hrp then return end

    local balls = getBalls()
    local best, bestETA, bestDist, bestSpeed = nil, math.huge, math.huge, 0

    for _, ball in ipairs(balls) do
        local ok, dist, speed, eta = isBallTargetingMe(ball, hrp)
        if ok and dist <= CFG.Parry.MaxDist and eta < bestETA then
            best = ball
            bestETA = eta
            bestDist = dist
            bestSpeed = speed
        end
    end

    if not best then
        if ballHighlight then ballHighlight.Adornee = nil end
        return
    end

    ensureBallHL(best)

    local threshold = CFG.Parry.ETAThreshold
    if CFG.Parry.PingBased then
        threshold = threshold + getPing() * CFG.Parry.PingOffset
    end
    -- faster balls → slightly earlier
    if bestSpeed > 120 then
        threshold = threshold + 0.04
    elseif bestSpeed > 200 then
        threshold = threshold + 0.08
    end

    local should = false
    local spam = false
    if bestDist <= CFG.Parry.EmergencyDist then
        should = true
        spam = bestDist <= CFG.Parry.SpamDist
    elseif bestETA <= threshold then
        should = true
        spam = bestDist <= CFG.Parry.SpamDist
    end

    if should then
        doParry(spam)
    end
end)

-- ======================== ESP ========================
local espFolder = Instance.new("Folder")
espFolder.Name = "BB_ESP"
pcall(function()
    espFolder.Parent = (gethui and gethui()) or CoreGui
end)
if not espFolder.Parent then
    espFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local playerESP = {}
local abilityESP = {}

local function clearESP(map, key)
    local d = map[key]
    if not d then return end
    for _, v in pairs(d) do
        if typeof(v) == "Instance" then v:Destroy() end
    end
    map[key] = nil
end

local function makeBB(adornee, h)
    local bb = Instance.new("BillboardGui")
    bb.Adornee = adornee
    bb.Size = UDim2.fromOffset(140, h or 40)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    bb.Parent = espFolder
    return bb
end

local function updatePlayerESP()
    if not CFG.ESP.Players then
        for plr in pairs(playerESP) do clearESP(playerESP, plr) end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not alive(plr) then
            clearESP(playerESP, plr)
        else
            local char = plr.Character
            local hrp = getHRP(char)
            local head = char:FindFirstChild("Head")
            if not hrp then clearESP(playerESP, plr) else
                local d = playerESP[plr]
                if not d then
                    d = {}
                    playerESP[plr] = d
                    local hl = Instance.new("Highlight")
                    hl.Adornee = char
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillColor = CFG.ESP.PlayerColor
                    hl.OutlineColor = CFG.ESP.PlayerColor
                    hl.FillTransparency = CFG.ESP.PlayerFill
                    hl.OutlineTransparency = 0
                    hl.Parent = espFolder
                    d.hl = hl
                    local gui = makeBB(head or hrp, 40)
                    local nameL = Instance.new("TextLabel")
                    nameL.BackgroundTransparency = 1
                    nameL.Size = UDim2.new(1, 0, 0.5, 0)
                    nameL.Font = Enum.Font.GothamBold
                    nameL.TextStrokeTransparency = 0.4
                    nameL.TextColor3 = CFG.ESP.PlayerColor
                    nameL.Parent = gui
                    d.name = nameL
                    local distL = Instance.new("TextLabel")
                    distL.BackgroundTransparency = 1
                    distL.Size = UDim2.new(1, 0, 0.5, 0)
                    distL.Position = UDim2.new(0, 0, 0.5, 0)
                    distL.Font = Enum.Font.Gotham
                    distL.TextStrokeTransparency = 0.5
                    distL.TextColor3 = Color3.new(1, 1, 1)
                    distL.Parent = gui
                    d.dist = distL
                    d.bb = gui
                end
                d.hl.FillTransparency = CFG.ESP.PlayerFill
                d.hl.FillColor = CFG.ESP.PlayerColor
                d.hl.OutlineColor = CFG.ESP.PlayerColor
                d.name.TextSize = CFG.ESP.TextSize
                d.dist.TextSize = math.max(10, CFG.ESP.TextSize - 2)
                if CFG.ESP.Names then
                    d.name.Text = plr.Name
                    d.name.Visible = true
                else
                    d.name.Visible = false
                end
                if CFG.ESP.Distance then
                    d.dist.Text = string.format("%.0f", (hrp.Position - Camera.CFrame.Position).Magnitude)
                    d.dist.Visible = true
                else
                    d.dist.Visible = false
                end
            end
        end
    end
end

-- Ability ESP: highlight tools / ability FX on other players
local ABILITY_KEYS = {
    "ability", "slash", "dash", "phantom", "infinity", "pull", "singularity",
    "time", "raging", "deflection", "force", "hole", "scythe", "katana",
}

local function isAbilityRelated(name)
    local n = string.lower(name)
    for _, k in ipairs(ABILITY_KEYS) do
        if string.find(n, k) then return true end
    end
    return false
end

local function updateAbilityESP()
    if not CFG.ESP.Abilities then
        for k in pairs(abilityESP) do clearESP(abilityESP, k) end
        return
    end
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        local char = plr.Character
        for _, obj in ipairs(char:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder")) and isAbilityRelated(obj.Name) then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    seen[obj] = true
                    local d = abilityESP[obj]
                    if not d then
                        d = {}
                        abilityESP[obj] = d
                        local hl = Instance.new("Highlight")
                        hl.Adornee = obj:IsA("Model") and obj or part
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = CFG.ESP.AbilityColor
                        hl.OutlineColor = CFG.ESP.AbilityColor
                        hl.FillTransparency = 0.45
                        hl.Parent = espFolder
                        d.hl = hl
                        local gui = makeBB(part, 24)
                        local lab = Instance.new("TextLabel")
                        lab.BackgroundTransparency = 1
                        lab.Size = UDim2.new(1, 0, 1, 0)
                        lab.Font = Enum.Font.GothamBold
                        lab.TextSize = math.max(11, CFG.ESP.TextSize - 1)
                        lab.TextColor3 = CFG.ESP.AbilityColor
                        lab.TextStrokeTransparency = 0.4
                        lab.Text = obj.Name
                        lab.Parent = gui
                        d.label = lab
                        d.bb = gui
                    end
                end
            end
        end
        -- equipped tool name as ability hint
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            seen[tool] = true
            local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
            if handle then
                local d = abilityESP[tool]
                if not d then
                    d = {}
                    abilityESP[tool] = d
                    local hl = Instance.new("Highlight")
                    hl.Adornee = tool
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillColor = CFG.ESP.AbilityColor
                    hl.OutlineColor = CFG.ESP.AbilityColor
                    hl.FillTransparency = 0.5
                    hl.Parent = espFolder
                    d.hl = hl
                    local gui = makeBB(handle, 22)
                    local lab = Instance.new("TextLabel")
                    lab.BackgroundTransparency = 1
                    lab.Size = UDim2.new(1, 0, 1, 0)
                    lab.Font = Enum.Font.GothamBold
                    lab.TextSize = 12
                    lab.TextColor3 = CFG.ESP.AbilityColor
                    lab.TextStrokeTransparency = 0.4
                    lab.Text = tool.Name
                    lab.Parent = gui
                    d.label = lab
                    d.bb = gui
                end
            end
        end
    end
    for k in pairs(abilityESP) do
        if not seen[k] or (typeof(k) == "Instance" and not k.Parent) then
            clearESP(abilityESP, k)
        end
    end
end

local ablClock = 0
RunService.RenderStepped:Connect(function(dt)
    updatePlayerESP()
    ablClock = ablClock + dt
    if ablClock >= 0.4 then
        ablClock = 0
        pcall(updateAbilityESP)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    clearESP(playerESP, plr)
end)

-- ======================== WINDUI ========================
local WindUI
pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not WindUI then
    pcall(function()
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
end
if not WindUI then
    warn("[BB] WindUI load failed")
    return
end

local Window = WindUI:CreateWindow({
    Title = "Blade Ball",
    Icon = "swords",
    Author = "Ninero",
    Folder = "BB_Ninero",
    Size = UDim2.fromOffset(520, 400),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 140,
    ToggleKey = Enum.KeyCode.LeftControl,
})

local TabParry = Window:Tab({ Title = "Parry", Icon = "shield" })
local TabESP = Window:Tab({ Title = "ESP", Icon = "eye" })
local TabMisc = Window:Tab({ Title = "Misc", Icon = "settings" })

-- PARRY
TabParry:Toggle({
    Title = "Auto Parry",
    Value = true,
    Callback = function(v) CFG.Parry.Enabled = v end,
})
TabParry:Toggle({
    Title = "Ping compensation",
    Value = true,
    Callback = function(v) CFG.Parry.PingBased = v end,
})
TabParry:Slider({
    Title = "ETA threshold (sec)",
    Value = { Min = 0.08, Max = 0.6, Default = 0.28 },
    Callback = function(v) CFG.Parry.ETAThreshold = v end,
})
TabParry:Slider({
    Title = "Ping offset",
    Value = { Min = 0.1, Max = 1.5, Default = 0.55 },
    Callback = function(v) CFG.Parry.PingOffset = v end,
})
TabParry:Slider({
    Title = "Emergency distance",
    Value = { Min = 3, Max = 20, Default = 8 },
    Callback = function(v) CFG.Parry.EmergencyDist = v end,
})
TabParry:Slider({
    Title = "Max track distance",
    Value = { Min = 50, Max = 300, Default = 220 },
    Callback = function(v) CFG.Parry.MaxDist = v end,
})
TabParry:Toggle({
    Title = "Close-range spam parry",
    Value = true,
    Callback = function(v) CFG.Parry.SpamClose = v end,
})
TabParry:Slider({
    Title = "Spam distance",
    Value = { Min = 6, Max = 25, Default = 14 },
    Callback = function(v) CFG.Parry.SpamDist = v end,
})
TabParry:Slider({
    Title = "Spam count",
    Value = { Min = 1, Max = 8, Default = 4 },
    Callback = function(v) CFG.Parry.SpamCount = v end,
})
TabParry:Dropdown({
    Title = "Parry method",
    Values = { "All", "Key", "Remote" },
    Value = "All",
    Callback = function(v) CFG.Parry.Method = v end,
})
TabParry:Toggle({
    Title = "Highlight ball",
    Value = true,
    Callback = function(v) CFG.Parry.VisualBall = v end,
})
TabParry:Paragraph({
    Title = "Tip",
    Desc = "Default is aggressive. If early-parries, raise ETA. If late, lower ETA / raise Ping offset.",
})

-- ESP
TabESP:Toggle({
    Title = "Player ESP",
    Value = true,
    Callback = function(v) CFG.ESP.Players = v end,
})
TabESP:Toggle({
    Title = "Ability ESP",
    Value = true,
    Callback = function(v) CFG.ESP.Abilities = v end,
})
TabESP:Toggle({
    Title = "Names",
    Value = true,
    Callback = function(v) CFG.ESP.Names = v end,
})
TabESP:Toggle({
    Title = "Distance",
    Value = true,
    Callback = function(v) CFG.ESP.Distance = v end,
})
TabESP:Slider({
    Title = "Text size",
    Value = { Min = 10, Max = 26, Default = 14 },
    Callback = function(v) CFG.ESP.TextSize = v end,
})
TabESP:Slider({
    Title = "Player fill transparency",
    Value = { Min = 0, Max = 1, Default = 0.55 },
    Callback = function(v) CFG.ESP.PlayerFill = v end,
})
TabESP:Colorpicker({
    Title = "Player color",
    Default = CFG.ESP.PlayerColor,
    Callback = function(c) CFG.ESP.PlayerColor = c end,
})
TabESP:Colorpicker({
    Title = "Ability color",
    Default = CFG.ESP.AbilityColor,
    Callback = function(c) CFG.ESP.AbilityColor = c end,
})
TabESP:Colorpicker({
    Title = "Ball color",
    Default = CFG.ESP.BallColor,
    Callback = function(c) CFG.ESP.BallColor = c end,
})

-- MISC
TabMisc:Button({
    Title = "Refresh parry remotes cache",
    Callback = function()
        table.clear(cachedRemotes)
        findParryRemotes()
        notify("Parry", "Remotes: " .. tostring(#cachedRemotes))
    end,
})
TabMisc:Button({
    Title = "Unload",
    Callback = function()
        CFG.Parry.Enabled = false
        CFG.ESP.Players = false
        CFG.ESP.Abilities = false
        for plr in pairs(playerESP) do clearESP(playerESP, plr) end
        for k in pairs(abilityESP) do clearESP(abilityESP, k) end
        if ballHighlight then ballHighlight:Destroy() end
        espFolder:Destroy()
        pcall(function() Window:Destroy() end)
    end,
})

WindUI:Notify({
    Title = "Blade Ball",
    Content = "Ninero · Auto Parry ON",
    Duration = 4,
})

print("[BB Ninero] ready")
