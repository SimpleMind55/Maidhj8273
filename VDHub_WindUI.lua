--[[
  x adra — WindUI · Mobile
  Only: Auto Parry suite from SWAGA CRACK
]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local winSize = isMobile and UDim2.fromOffset(300, 380) or UDim2.fromOffset(360, 420)

-- ─── helpers (SWAGA) ───
local function isSurvivorTeam()
    local team = LP.Team
    if not team then return false end
    local n = team.Name:lower()
    return n:find("survivor") ~= nil or n == "survivors"
end

local function isPlayerKiller(p)
    if not p or not p.Character then return false end
    local char = p.Character
    local name = p.Name:lower()
    if name:find("killer") or name:find("hunter") or name:find("murderer") or name:find("slasher") then
        return true
    end
    for _, w in ipairs({ "Knife", "Axe", "Sword", "Parrying Dagger", "Machete", "Bat", "Weapon" }) do
        if char:FindFirstChild(w) or char:FindFirstChild(w:lower()) then
            return true
        end
    end
    local total, dark = 0, 0
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            total += 1
            local c = v.Color
            if c.R < 0.3 and c.G < 0.3 and c.B < 0.3 then
                dark += 1
            end
        end
    end
    return total > 0 and (dark / total) > 0.5
end

local function getRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
end

local function getHumanoid(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function doParryClick()
    -- SWAGA: M2 at 0,0
    VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0)
    task.spawn(function()
        task.wait()
        VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end)
end

local function doParryClickV2()
    local cam = workspace.CurrentCamera
    if not cam then
        doParryClick()
        return
    end
    local vs = cam.ViewportSize
    VIM:SendMouseButtonEvent(vs.X / 2, vs.Y / 2, 1, true, game, 1)
    task.delay(0.1, function()
        VIM:SendMouseButtonEvent(vs.X / 2, vs.Y / 2, 1, false, game, 1)
    end)
end

-- SWAGA attack animation ids
local PARRY_ANIMS = {}
for _, id in ipairs({
    "rbxassetid://110355011987939",
    "rbxassetid://139369275981139",
    "rbxassetid://117042998468241",
    "rbxassetid://133963973694098",
    "rbxassetid://113255068724446",
    "rbxassetid://74968262036854",
    "rbxassetid://118907603246885",
    "rbxassetid://78432063483146",
    "rbxassetid://129784271201071",
    "rbxassetid://122812055447896",
    "rbxassetid://138720291317243",
    "rbxassetid://106871536134254",
    "rbxassetid://109402730355822",
    "rbxassetid://111920872708571",
    "rbxassetid://105374834496520",
}) do
    PARRY_ANIMS[id] = true
end

-- ─── state ───
local AP = {
    Enabled = false,
    Range = 10,
    SpamActive = false,
    AnimConnections = {},
    PlayerAddedConn = nil,
    PlayerRemovingConn = nil,
    TeamConns = {},
}

local AP2 = {
    Enabled = false,
    Range = 20,
    LastArmPos = nil,
    LastDelta = 0,
    LastCheckTime = 0,
    OnCooldown = false,
    Connection = nil,
    TeamConns = {},
}

local FakeParry = {
    Enabled = false,
    AnimTrack = nil,
}

local ParryCircle = {
    Enabled = false,
    Gui = nil,
    Connection = nil,
}

-- ─── Auto Parry V1 (anim ids + range) ───
local function clearPlayer(player)
    local list = AP.AnimConnections[player]
    if list then
        for _, c in ipairs(list) do
            pcall(function() c:Disconnect() end)
        end
    end
    AP.AnimConnections[player] = nil
end

local function tryParry()
    if AP.SpamActive then return end
    AP.SpamActive = true
    doParryClick()
    task.spawn(function()
        task.wait()
        AP.SpamActive = false
    end)
end

local function hookCharacter(player, character)
    if player == LP then return end
    clearPlayer(player)
    AP.AnimConnections[player] = {}

    local function onAnim(track)
        if not AP.Enabled or not isSurvivorTeam() then return end
        local anim = track.Animation
        local id = anim and anim.AnimationId
        if not id or not PARRY_ANIMS[id] then return end
        local myRoot = getRoot(LP.Character)
        local theirRoot = getRoot(character)
        if not myRoot or not theirRoot then return end
        if (myRoot.Position - theirRoot.Position).Magnitude > AP.Range then return end
        tryParry()
    end

    local hum = getHumanoid(character)
    if not hum then return end

    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        local c = animator.AnimationPlayed:Connect(onAnim)
        table.insert(AP.AnimConnections[player], c)
    else
        local c = hum.ChildAdded:Connect(function(child)
            if child:IsA("Animator") then
                local c2 = child.AnimationPlayed:Connect(onAnim)
                table.insert(AP.AnimConnections[player], c2)
            end
        end)
        table.insert(AP.AnimConnections[player], c)
        -- also AnimationPlayed on humanoid as fallback
        local c3 = hum.AnimationPlayed:Connect(onAnim)
        table.insert(AP.AnimConnections[player], c3)
    end
end

local function stopAP()
    for p, _ in pairs(AP.AnimConnections) do
        clearPlayer(p)
    end
    AP.AnimConnections = {}
    if AP.PlayerAddedConn then AP.PlayerAddedConn:Disconnect() AP.PlayerAddedConn = nil end
    if AP.PlayerRemovingConn then AP.PlayerRemovingConn:Disconnect() AP.PlayerRemovingConn = nil end
    for _, c in ipairs(AP.TeamConns) do pcall(function() c:Disconnect() end) end
    AP.TeamConns = {}
end

local function startAP()
    stopAP()
    if not AP.Enabled then return end

    local function refresh()
        stopAP()
        if not AP.Enabled or not isSurvivorTeam() then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                if p.Character then hookCharacter(p, p.Character) end
                local c = p.CharacterAdded:Connect(function(ch)
                    task.wait(0.1)
                    if AP.Enabled then hookCharacter(p, ch) end
                end)
                AP.AnimConnections[p] = AP.AnimConnections[p] or {}
                table.insert(AP.AnimConnections[p], c)
            end
        end
        AP.PlayerAddedConn = Players.PlayerAdded:Connect(function(p)
            local c = p.CharacterAdded:Connect(function(ch)
                task.wait(0.1)
                if AP.Enabled then hookCharacter(p, ch) end
            end)
            AP.AnimConnections[p] = { c }
        end)
        AP.PlayerRemovingConn = Players.PlayerRemoving:Connect(clearPlayer)
    end

    table.insert(AP.TeamConns, LP:GetPropertyChangedSignal("Team"):Connect(refresh))
    table.insert(AP.TeamConns, LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        refresh()
    end))
    refresh()
end

local function setAP(on)
    AP.Enabled = on
    if on then startAP() else stopAP() end
end

-- ─── Auto Parry V2 (arm swing) ───
local function stopAP2()
    if AP2.Connection then AP2.Connection:Disconnect() AP2.Connection = nil end
    AP2.LastArmPos = nil
    AP2.LastDelta = 0
    for _, c in ipairs(AP2.TeamConns) do pcall(function() c:Disconnect() end) end
    AP2.TeamConns = {}
end

local function startAP2()
    stopAP2()
    if not AP2.Enabled then return end

    local function loop()
        if not AP2.Enabled or not isSurvivorTeam() then return end
        local now = tick()
        if now - (AP2.LastCheckTime or 0) < 0.05 then return end
        AP2.LastCheckTime = now

        local myRoot = getRoot(LP.Character)
        if not myRoot then
            AP2.LastArmPos = nil
            return
        end

        local nearest, nearestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and isPlayerKiller(p) then
                local r = getRoot(p.Character)
                if r then
                    local d = (r.Position - myRoot.Position).Magnitude
                    if d < nearestDist then
                        nearestDist = d
                        nearest = p
                    end
                end
            end
        end

        if not nearest or not nearest.Character or nearestDist > AP2.Range then
            AP2.LastArmPos = nil
            return
        end

        local arm = nearest.Character:FindFirstChild("RightUpperArm")
            or nearest.Character:FindFirstChild("Right Arm")
        if not arm then
            AP2.LastArmPos = nil
            return
        end

        local pos = arm.Position
        if AP2.LastArmPos then
            local mag = (pos - AP2.LastArmPos).Magnitude
            local delta = mag - (AP2.LastDelta or 0)
            if mag > 0.01 and delta > 0.3 and not AP2.OnCooldown then
                AP2.OnCooldown = true
                doParryClickV2()
                task.delay(0.5, function() AP2.OnCooldown = false end)
            end
            AP2.LastDelta = mag
        else
            AP2.LastDelta = 0
        end
        AP2.LastArmPos = pos
    end

    local function refresh()
        if AP2.Connection then AP2.Connection:Disconnect() AP2.Connection = nil end
        if AP2.Enabled and isSurvivorTeam() then
            AP2.Connection = RunService.Heartbeat:Connect(loop)
        end
    end

    table.insert(AP2.TeamConns, LP:GetPropertyChangedSignal("Team"):Connect(refresh))
    table.insert(AP2.TeamConns, LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        refresh()
    end))
    refresh()
end

local function setAP2(on)
    AP2.Enabled = on
    if on then startAP2() else stopAP2() end
end

-- ─── Fake Parry ───
local function setFakeParry(on)
    FakeParry.Enabled = on
    if FakeParry.AnimTrack then
        pcall(function() FakeParry.AnimTrack:Stop() end)
        FakeParry.AnimTrack = nil
    end
    if not on or not isSurvivorTeam() then return end
    local hum = getHumanoid(LP.Character)
    if not hum then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://127096285501517"
    local track = hum:LoadAnimation(anim)
    FakeParry.AnimTrack = track
    track:Play()
    track.Stopped:Connect(function()
        FakeParry.AnimTrack = nil
    end)
end

-- ─── Parry Circle ───
local function setParryCircle(on)
    ParryCircle.Enabled = on
    if ParryCircle.Connection then ParryCircle.Connection:Disconnect() ParryCircle.Connection = nil end
    if ParryCircle.Gui then ParryCircle.Gui:Destroy() ParryCircle.Gui = nil end
    if not on then return end

    local parent = (gethui and gethui()) or game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "VD_ParryCircle"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = parent

    local ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.fromScale(0.5, 0.5)
    ring.BackgroundTransparency = 1
    ring.Parent = sg
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local st = Instance.new("UIStroke", ring)
    st.Color = Color3.fromRGB(100, 200, 255)
    st.Thickness = 1.5
    st.Transparency = 0.35

    ParryCircle.Gui = sg
    ParryCircle.Connection = RunService.RenderStepped:Connect(function()
        local r = math.clamp(AP.Range * 6, 40, 360)
        ring.Size = UDim2.fromOffset(r, r)
    end)
end

-- ─── WindUI ───
local Window = WindUI:CreateWindow({
    Title = "x adra",
    Icon = "shield",
    Author = "x adra",
    Folder = "xadra",
    Size = winSize,
    Transparent = true,
    Theme = "Dark",
})

local Tab = Window:Tab({ Title = "Auto Parry", Icon = "swords" })

Tab:Section({ Title = "SWAGA method · Survivor" })

Tab:Toggle({
    Title = "Auto Parry",
    Value = false,
    Callback = function(v)
        setAP(v)
        WindUI:Notify({ Title = "Auto Parry", Content = v and "ON" or "OFF", Duration = 1.5 })
    end,
})

Tab:Slider({
    Title = "AP Range",
    Value = { Min = 5, Max = 30, Default = 10 },
    Callback = function(v)
        AP.Range = v
    end,
})

Tab:Toggle({
    Title = "Auto Parry V2",
    Value = false,
    Callback = function(v)
        setAP2(v)
        WindUI:Notify({ Title = "Auto Parry V2", Content = v and "ON" or "OFF", Duration = 1.5 })
    end,
})

Tab:Slider({
    Title = "AP V2 Range",
    Value = { Min = 5, Max = 40, Default = 20 },
    Callback = function(v)
        AP2.Range = v
    end,
})

Tab:Toggle({
    Title = "Fake Parry",
    Value = false,
    Callback = function(v)
        setFakeParry(v)
    end,
})

Tab:Toggle({
    Title = "Parry Circle",
    Value = false,
    Callback = function(v)
        setParryCircle(v)
    end,
})

Tab:Paragraph({
    Title = "Info",
    Desc = "V1 = attack anim ids + range. V2 = killer arm swing. Mobile window "
        .. (isMobile and "300x380" or "360x420")
        .. ". Only SWAGA Auto Parry — nothing else.",
})

WindUI:Notify({
    Title = "x adra",
    Content = "WindUI · Auto Parry only",
    Duration = 3,
})

print("[x adra] WindUI Auto Parry loaded · mobile=", isMobile)
