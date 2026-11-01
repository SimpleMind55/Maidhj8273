-- https://discord.gg/ndxRJ3vR68
Players = game:GetService("Players")
RunService = game:GetService("RunService")
TweenService = game:GetService("TweenService")
Workspace = game:GetService("Workspace")
Lighting = game:GetService("Lighting")
UserInputService = game:GetService("UserInputService")
GuiService = game:GetService("GuiService")
activeTouchInputs = {}
activeTouchCount = 0
function addTwoBubbles(parent, size)
    local tbl = {}
    for i = 1, 2 do
        local frame = Instance.new("Frame")
        frame.Name = "Bubble" .. i
        frame.Size = UDim2.fromOffset(size, size)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 0
        frame.ZIndex = parent.ZIndex + 1
        frame.Parent = parent
        local uICorner = Instance.new("UICorner")
        uICorner.CornerRadius = UDim.new(1, 0)
        uICorner.Parent = frame
        local uIStroke = Instance.new("UIStroke")
        uIStroke.Thickness = 1
        uIStroke.Transparency = 0.35
        uIStroke.Parent = frame
        table.insert(tbl, frame)
    end
    local function fn(arg2, startX, delayTime)
        task.spawn(function()
            task.wait(delayTime)
            while arg2.Parent do
                arg2.Position = UDim2.new(0, startX, 1, 2)
                arg2.BackgroundTransparency = 0.15
                local var51 = TweenService:Create(arg2, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0, startX + 3, 0, -10), BackgroundTransparency = 1})
                var51:Play()
                var51.Completed:Wait()
                task.wait(0.15)
            end
        end)
    end
    fn(tbl[1], math.floor(parent.AbsoluteSize.X * 0.32), 0)
    fn(tbl[2], math.floor(parent.AbsoluteSize.X * 0.58), 0.65)
end
function hasMultipleTouches()
    local var54, touches = pcall(function()
        return UserInputService:GetTouches()
    end)
    if var54 and touches then
        return #touches >= 2
    end
    return activeTouchCount >= 2
end
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        if not activeTouchInputs[input] then
            activeTouchInputs[input] = true
            activeTouchCount = activeTouchCount + 1
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and activeTouchInputs[input] then
        activeTouchInputs[input] = nil
        activeTouchCount = math.max(0, activeTouchCount - 1)
    end
end)
SoundService = game:GetService("SoundService")
localPlayer = Players.LocalPlayer
if not localPlayer then
    repeat
        task.wait()
        localPlayer = Players.LocalPlayer
    until localPlayer
end
PlayerGui = localPlayer:WaitForChild("PlayerGui")
function refreshLocalPlayerReferences()
    local localPlayer2 = Players.LocalPlayer
    if localPlayer2 and localPlayer2 ~= localPlayer then
        localPlayer = localPlayer2
    end
    if localPlayer then
        local playerGui = localPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            PlayerGui = playerGui
        end
    end
end
Players.PlayerAdded:Connect(function(arg3)
    task.defer(function()
        refreshLocalPlayerReferences()
    end)
end)
RoundRoleEndAt = 0
RoundTimerState = {
    enabled = false,
    duration = 0,
    endAt = 0,
    gui = nil,
    panel = nil,
    label = nil,
    statsLabel = nil,
    fps = 0,
    fpsFrames = 0,
    fpsLast = 0,
    phase = "WAITING",
    startedAt = 0,
}
local function fn2()
    local var61, value = pcall(function()
        return Workspace:GetServerTimeNow()
    end)
    if var61 and type(value) == "number" then
        return value
    end
    return time()
end
local function fn3()
    local var64, value = pcall(function()
        local Stats = game:GetService("Stats")
        local network = Stats:FindFirstChild("Network")
        local var62 = network and network:FindFirstChild("ServerStatsItem")
        local var63 = var62 and var62:FindFirstChild("Data Ping")
        if var63 then
            return math.floor(var63:GetValue() + 0.5)
        end
        return 0
    end)
    if var64 and type(value) == "number" then
        return math.max(0, value)
    end
    return 0
end
local function fn4(visible)
    if RoundTimerState.gui then
        RoundTimerState.gui.Enabled = visible == true
    end
end
local function fn5()
    if RoundTimerState.gui and RoundTimerState.gui.Parent then
        return
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "BolongRoundTimer"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    gui.Enabled = true
    gui.Parent = PlayerGui
    local panel = Instance.new("Frame")
    panel.Name = "RoundTimerPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0)
    panel.Position = UDim2.new(0.5, 0, 0, 12)
    panel.Size = UDim2.fromOffset(150, 40)
    panel.BackgroundColor3 = Color3.fromRGB(40, 190, 255)
    panel.BackgroundTransparency = 0.77
    panel.BorderSizePixel = 0
    panel.Visible = RoundTimerState.enabled
    panel.Parent = gui
    panel.ClipsDescendants = true
    local uIGradient = Instance.new("UIGradient")
    uIGradient.Rotation = 90
    uIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 205, 255)),
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(40, 190, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 155, 235)),
    })
    uIGradient.Parent = panel
    local uICorner2 = Instance.new("UICorner")
    uICorner2.CornerRadius = UDim.new(0, 11)
    uICorner2.Parent = panel
    local uIStroke2 = Instance.new("UIStroke")
    uIStroke2.Color = Color3.fromRGB(0, 195, 255)
    uIStroke2.Thickness = 1.5
    uIStroke2.Transparency = 0.12
    uIStroke2.Parent = panel
    local label = Instance.new("TextLabel")
    label.Name = "RoundTimer"
    label.Position = UDim2.fromOffset(5, 3)
    label.Size = UDim2.new(1, -10, 0, 21)
    label.BackgroundTransparency = 1
    label.Text = "0:00"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeColor3 = Color3.fromRGB(0, 100, 180)
    label.TextStrokeTransparency = 0.55
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Active = false
    label.Selectable = false
    label.ZIndex = 5
    label.Active = false
    label.Selectable = false
    label.Parent = panel
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "ClientStats"
    statsLabel.Position = UDim2.fromOffset(5, 24)
    statsLabel.Size = UDim2.new(1, -10, 0, 12)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "FPS 60    Ping 0ms"
    statsLabel.TextColor3 = Color3.new(1, 1, 1)
    statsLabel.TextStrokeColor3 = Color3.fromRGB(0, 100, 180)
    statsLabel.TextStrokeTransparency = 0.65
    statsLabel.Font = Enum.Font.GothamSemibold
    statsLabel.TextSize = 10
    statsLabel.TextXAlignment = Enum.TextXAlignment.Center
    statsLabel.TextYAlignment = Enum.TextYAlignment.Center
    statsLabel.ZIndex = 5
    statsLabel.Active = false
    statsLabel.Selectable = false
    statsLabel.Parent = panel
    local frame2 = Instance.new("Frame")
    frame2.Name = "Bubbles"
    frame2.Size = UDim2.fromScale(1, 1)
    frame2.BackgroundTransparency = 1
    frame2.ClipsDescendants = true
    frame2.ZIndex = 2
    frame2.Parent = panel
    local tbl2 = {
        {x = 0.18, y = 0.72, size = 5, delay = 0, duration = 1.8},
        {x = 0.38, y = 0.84, size = 4, delay = 0.45, duration = 1.6},
        {x = 0.67, y = 0.68, size = 6, delay = 0.9, duration = 1.9},
        {x = 0.84, y = 0.82, size = 4, delay = 1.25, duration = 1.7},
    }
    for i2, v in ipairs(tbl2) do
        local frame3 = Instance.new("Frame")
        frame3.Name = "Bubble" .. i2
        frame3.Size = UDim2.fromOffset(v.size, v.size)
        frame3.Position = UDim2.fromScale(v.x, v.y)
        frame3.AnchorPoint = Vector2.new(0.5, 0.5)
        frame3.BackgroundColor3 = Color3.fromRGB(235, 250, 255)
        frame3.BackgroundTransparency = 0.25
        frame3.BorderSizePixel = 0
        frame3.ZIndex = 2
        frame3.Parent = frame2
        local uICorner3 = Instance.new("UICorner")
        uICorner3.CornerRadius = UDim.new(1, 0)
        uICorner3.Parent = frame3
        task.spawn(function()
            task.wait(v.delay)
            while frame3.Parent do
                frame3.Position = UDim2.fromScale(v.x, 0.92)
                frame3.Size = UDim2.fromOffset(v.size, v.size)
                frame3.BackgroundTransparency = 0.15
                local var81 = TweenService:Create(frame3, TweenInfo.new(v.duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Position = UDim2.fromScale(v.x + 0.025, 0.08),
                    Size = UDim2.fromOffset(v.size + 2, v.size + 2),
                    BackgroundTransparency = 0.78,
                })
                var81:Play()
                var81.Completed:Wait()
                task.wait(0.12)
            end
        end)
    end
    RoundTimerState.gui = gui
    RoundTimerState.panel = panel
    RoundTimerState.label = label
    RoundTimerState.statsLabel = statsLabel
    RoundTimerState.ball = nil
    RoundTimerState.bubbleContainer = frame2
    RoundTimerState.fpsLast = time()
    local flag = false
    local var86 = nil
    local var88 = nil
    local var89 = nil
    panel.Active = true
    panel.InputBegan:Connect(function(input)
        if flag then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            flag = true
            var86 = input
            var88 = input.Position
            var89 = panel.Position
            uiPanelTouchActive = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if flag and input == var86 then
            local var91 = input.Position - var88
            panel.Position = UDim2.new(var89.X.Scale, var89.X.Offset + var91.X, var89.Y.Scale, var89.Y.Offset + var91.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if flag and input == var86 then
            flag = false
            var86 = nil
            uiPanelTouchActive = activeTouchCount > 0
        end
    end)
end
local function fn6(seconds)
    seconds = math.max(0, math.ceil(seconds))
    local var95 = math.floor(seconds / 60)
    local var96 = seconds % 60
    return string.format("%d:%02d", var95, var96)
end
local function fn7(duration)
    duration = tonumber(duration)
    if not duration or duration <= 0 then
        duration = 180
    end
    RoundTimerState.phase = "RUNNING"
    RoundTimerState.duration = duration
    RoundTimerState.startedAt = fn2()
    RoundTimerState.endAt = RoundTimerState.startedAt + duration
    RoundRoleEndAt = RoundTimerState.endAt
    refreshLocalPlayerReferences()
    fn5()
    if RoundTimerState.gui then
        RoundTimerState.gui.Enabled = true
    end
    if RoundTimerState.enabled then
        RoundTimerState.gui.Enabled = true
        RoundTimerState.panel.Visible = true
        RoundTimerState.label.Text = fn6(duration)
    end
end
local function fn8()
    RoundTimerState.phase = "ENDED"
    RoundTimerState.endAt = 0
    RoundTimerState.startedAt = 0
    RoundRoleEndAt = 0
    fn5()
    if RoundTimerState.panel then
        RoundTimerState.panel.Visible = RoundTimerState.enabled
    end
    if RoundTimerState.label then
        RoundTimerState.label.Text = "0:00"
    end
end
local var107
local var108
local flag2 = false
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local gameplay = remotes:WaitForChild("Gameplay")
    local roundStart = gameplay:WaitForChild("RoundStart")
    if roundStart:IsA("RemoteEvent") then
        roundStart.OnClientEvent:Connect(function(roundDuration, _roundPlayerData)
            if not flag2 then
                return
            end
            RoundTimerState.enabled = true
            fn7(roundDuration)
            autoFarmRoundActive = true
            autoFarmWaitingForRoundStart = false
            roleVisualsAllowed = true
            autoShootShotCooldownUntil = 0
            autoFarmRoundToken = (tonumber(autoFarmRoundToken) or 0) + 1
            autoFarmCoinsCollected = 0
            autoFarmFullActionDone = false
            autoFarmMapCache = nil
            if type(var107) == "function" then
                var107()
            end
            if autoFarmActive and type(startAutoFarm) == "function" then
                task.defer(function()
                    if autoFarmActive and type(startAutoFarm) == "function" then
                        startAutoFarm()
                    end
                end)
            end
        end)
    end
    local roundEndFade = gameplay:WaitForChild("RoundEndFade")
    if roundEndFade:IsA("RemoteEvent") then
        roundEndFade.OnClientEvent:Connect(function(isEnding)
            if not flag2 or isEnding ~= true then
                return
            end
            roleVisualSource = "FADE"
            roleVisualsAllowed = false
            fn8()
            autoFarmRoundActive = false
            autoFarmWaitingForRoundStart = true
            autoShootShotCooldownUntil = 0
            autoFarmRoundToken = (tonumber(autoFarmRoundToken) or 0) + 1
            autoFarmCoinsRunning = false
            autoFarmCoinsCollected = 0
            autoFarmFullActionDone = false
            autoFarmMapCache = nil
            if autoFarmCurrentTween then
                pcall(function()
                    autoFarmCurrentTween:Cancel()
                end)
                autoFarmCurrentTween = nil
            end
            if type(var107) == "function" then
                var107()
            end
            if type(var108) == "function" then
                var108()
            end
            roleRebuildQueued = {}
            resetRoundRoles()
            clearAllRoleBoxes()
        end)
    end
end)
RunService.Heartbeat:Connect(function(deltaTime)
    if not roleVisualsAllowed and next(roleBoxes or {}) ~= nil then
        clearAllRoleBoxes()
    end
    local var109 = fn2()
    if RoundRoleEndAt > 0 and var109 >= RoundRoleEndAt then
        RoundRoleEndAt = 0
    end
    if RoundTimerState.enabled then
        fn5()
        if RoundTimerState.gui then
            RoundTimerState.gui.Enabled = true
        end
        if RoundTimerState.phase == "RUNNING" and RoundTimerState.endAt > 0 then
            RoundTimerState.panel.Visible = true
            local var110 = math.max(0, RoundTimerState.endAt - var109)
            RoundTimerState.label.Text = fn6(var110)
        elseif RoundTimerState.phase == "MIDGAME" then
            RoundTimerState.panel.Visible = true
            RoundTimerState.label.Text = "0:00"
        elseif RoundTimerState.phase == "ENDED" then
            RoundTimerState.panel.Visible = true
            RoundTimerState.label.Text = "0:00"
        else
            RoundTimerState.panel.Visible = true
            RoundTimerState.label.Text = "0:00"
        end
    end
    RoundTimerState.fpsFrames = RoundTimerState.fpsFrames + 1
    local var111 = time()
    local var112 = var111 - RoundTimerState.fpsLast
    if var112 >= 0.25 then
        RoundTimerState.fps = math.floor(RoundTimerState.fpsFrames / var112 + 0.5)
        RoundTimerState.fpsFrames = 0
        RoundTimerState.fpsLast = var111
        if RoundTimerState.enabled and RoundTimerState.statsLabel then
            local var113 = fn3()
            RoundTimerState.statsLabel.Text = string.format("FPS %d    Ping %dms", RoundTimerState.fps, var113)
        end
    end
end)
local var114
do
    local var115, var116 = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/RillBoys/bolong.catui/main/b0lngUi.lua"))()
    end)
    if var115 and var116 then
        var114 = var116
    else
        error("Library file not found: b0lngUi.lua")
    end
end
ACCENT_COLOR = Color3.fromRGB(0, 180, 255)
function PlaySoundAsset(soundId, volume)
    task.spawn(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(soundId)
        sound.Volume = volume or 1
        sound.Parent = SoundService
        SoundService:PlayLocalSound(sound)
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end
function PlayOpenSound()
    PlaySoundAsset(134699420140804, 1)
end
AutoShootEnabled = false
autoShootShotCooldownUntil = 0
ShootKeybind = Enum.KeyCode.E
MobilePanelEnabled = false
hitboxExpandEnabled = false
hitboxSize = 8
hitboxOriginals = setmetatable({}, {__mode = "k"})
autoShootVariant = "Auto"
autoShootFlickBusy = false
invisibleEnabled = false
invisibleFeatureEnabled = false
invisibleTransparencyOriginals = {}
InvisiblePanel = nil
InvisibleLabel = nil
InvisiblePanelStroke = nil
invisibleDragging = false
invisibleDragInput = nil
invisibleDragStart = nil
invisibleStartPos = nil
invisibleDragMoved = false
invisibleTouchStartTime = 0
removeInvisibleBarrierEnabled = false
removeInvisibleBarrierOriginals = {}
removeInvisibleBarrierConnection = nil
lowDetailsEnabled = false
lowDetailsOriginal = nil
disableFootstepEnabled = false
footstepConnection = nil
footstepBackups = {}
selectedFlingPlayerName = nil
selectedFlingEnabled = false
selectedFlingThread = nil
selectedFlingInProgress = false
PanelScale = 15
EspEnabled = false
EspTransparency = 0.5
WalkSpeedEnabled = false
WalkSpeedValue = 16
JumpPowerEnabled = false
JumpPowerValue = 50
NoclipEnabled = false
InfiniteJumpEnabled = false
RoleColors = {
    Innocent = Color3.fromRGB(0, 190, 0),
    Hero = Color3.fromRGB(202, 182, 0),
    Sheriff = Color3.fromRGB(0, 45, 200),
    Murderer = Color3.fromRGB(205, 0, 0),
    Lobby = Color3.fromRGB(105, 105, 115),
}
roleCache = {}
roleCacheByUserId = {}
roleRoundActive = false
roleVisualsAllowed = true
roleVisualSource = "FALLBACK"
firstGunHolderName = nil
roleRoundSerial = 0
local tbl3 = {}
local tbl4 = {}
local flag3 = false
local var129 = nil
local flag4 = false
local var131 = nil
local flag5 = false
local flag6 = false
local var132 = nil
local function fn9()
    if flag5 or not roleVisualsAllowed or roleVisualSource ~= "FALLBACK" or roleRoundActive then
        return
    end
    local var135 = nil
    local var137 = nil
    for _, v2 in ipairs(Players:GetPlayers()) do
        if v2 ~= localPlayer then
            roleCache[v2.Name] = "Innocent"
            roleCacheByUserId[v2.UserId] = "Innocent"
        end
    end
    for _, v3 in ipairs(Players:GetPlayers()) do
        if v3 ~= localPlayer then
            local character = v3.Character
            local backpack = v3:FindFirstChildOfClass("Backpack")
            local var138 = (character and character:FindFirstChild("Knife")) ~= nil or (backpack and backpack:FindFirstChild("Knife")) ~= nil
            local var141 = (character and character:FindFirstChild("Gun")) ~= nil or (backpack and backpack:FindFirstChild("Gun")) ~= nil
            if var138 and not var135 then
                var135 = v3
            end
            if var141 and not var137 then
                var137 = v3
            end
        end
    end
    if var135 then
        roleCache[var135.Name] = "Murderer"
        roleCacheByUserId[var135.UserId] = "Murderer"
        flag4 = true
        var131 = var135
    end
    if var137 then
        roleCache[var137.Name] = "Sheriff"
        roleCacheByUserId[var137.UserId] = "Sheriff"
        firstGunHolderName = var137.Name
        flag6 = true
        var132 = var137
    end
    if var135 or var137 then
        flag5 = true
        roleRoundActive = true
        roleRoundSerial = roleRoundSerial + 1
        if EspEnabled then
            for _, v4 in ipairs(Players:GetPlayers()) do
                if v4 ~= localPlayer and v4.Character then
                    buildRoleBoxes(v4)
                end
            end
        end
    end
end
task.defer(function()
    fn9()
    for i3 = 1, 20 do
        if flag5 or roleVisualSource ~= "FALLBACK" then
            break
        end
        task.wait(0.15)
        fn9()
    end
end)
local function fn10(arg4)
    if not arg4 then
        return
    end
    local var146 = roleBoxes and roleBoxes[arg4]
    if not var146 then
        return
    end
    local var147 = GetPlayerRoleMM2(arg4)
    local var148 = roleRoundActive and not tbl3[arg4] and (var147 == "Murderer" or var147 == "Sheriff" or var147 == "Hero" or var147 == "Innocent")
    local var149 = getRoleColor(var147)
    for _, v5 in ipairs(var146) do
        if v5 and v5.Parent then
            if v5.Color3 ~= var149 then
                v5.Color3 = var149
            end
            local var150 = EspEnabled and var148
            if v5.Visible ~= var150 then
                v5.Visible = var150
            end
        end
    end
end
local function fn11(arg5, character2)
    if not arg5 or arg5 == localPlayer or not character2 then
        return
    end
    local var152 = tbl4[arg5]
    if var152 then
        pcall(function()
            var152:Disconnect()
        end)
    end
    tbl4[arg5] = nil
    local humanoid = character2:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character2:WaitForChild("Humanoid", 5)
    end
    if not humanoid then
        return
    end
    tbl3[arg5] = humanoid.Health <= 0
    tbl4[arg5] = humanoid.Died:Connect(function()
        tbl3[arg5] = true
        if firstGunHolderName == arg5.Name then
            flag3 = true
            var129 = arg5.Name
        end
        fn10(arg5)
    end)
end
function clearAllRoleBoxes()
    for k in pairs(roleBoxes or {}) do
        clearRoleBoxes(k)
    end
    for _, v6 in ipairs(Players:GetPlayers()) do
        if v6 ~= localPlayer and v6.Character then
            for _, v7 in ipairs(ROLE_PART_NAMES or {}) do
                local var156 = v6.Character:FindFirstChild(v7)
                if var156 then
                    local bolongRolePartBox = var156:FindFirstChild("BolongRolePartBox")
                    while bolongRolePartBox do
                        pcall(function()
                            bolongRolePartBox:Destroy()
                        end)
                        bolongRolePartBox = var156:FindFirstChild("BolongRolePartBox")
                    end
                end
            end
        end
    end
end
local function fn12(arg6, player)
    if type(arg6) ~= "string" or type(player) ~= "table" then
        return
    end
    local role = player.Role
    if role ~= "Murderer" and role ~= "Sheriff" and role ~= "Hero" and role ~= "Innocent" then
        return
    end
    roleCache[arg6] = role
    local var158 = tonumber(player.UserId)
    if var158 then
        roleCacheByUserId[var158] = role
    end
end
task.spawn(function()
    local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
    local remotes2 = ReplicatedStorage2:WaitForChild("Remotes")
    local gameplay2 = remotes2:WaitForChild("Gameplay")
    local fade = gameplay2:WaitForChild("Fade")
    if fade and fade:IsA("RemoteEvent") then
        fade.OnClientEvent:Connect(function(roundPlayers)
            if type(roundPlayers) ~= "table" then
                return
            end
            roleVisualSource = "FADE"
            roleVisualsAllowed = true
            clearAllRoleBoxes()
            roleCache = {}
            roleCacheByUserId = {}
            tbl3 = {}
            roleRoundActive = true
            flag4 = false
            var131 = nil
            flag6 = false
            var132 = nil
            flag3 = false
            var129 = nil
            firstGunHolderName = nil
            roleRoundSerial = roleRoundSerial + 1
            RoundRoleEndAt = 0
            for k2, v8 in pairs(roundPlayers) do
                fn12(k2, v8)
                if type(v8) == "table" then
                    local var159 = tonumber(v8.UserId)
                    local var160 = Players:FindFirstChild(k2)
                    if var159 then
                        roleCacheByUserId[var159] = v8.Role
                    elseif var160 then
                        roleCacheByUserId[var160.UserId] = v8.Role
                    end
                    if v8.Role == "Sheriff" then
                        firstGunHolderName = k2
                    end
                end
            end
            if EspEnabled then
                for _, v9 in ipairs(Players:GetPlayers()) do
                    if v9 ~= localPlayer and v9.Character then
                        buildRoleBoxes(v9)
                    end
                end
            else
                for k3 in pairs(roleBoxes or {}) do
                    fn10(k3)
                end
            end
        end)
    end
end)
function resetRoundRoles()
    roleCache = {}
    roleCacheByUserId = {}
    tbl3 = {}
    roleRoundActive = false
    flag4 = false
    var131 = nil
    flag6 = false
    var132 = nil
    flag3 = false
    var129 = nil
    firstGunHolderName = nil
    clearAllRoleBoxes()
end
function GetPlayerRoleMM2(player2)
    if not player2 then
        return "Lobby"
    end
    local var165 = roleCache[player2.Name]
    if var165 then
        return var165
    end
    local var166 = tonumber(player2.UserId)
    if var166 then
        var165 = roleCacheByUserId[var166]
        if var165 then
            return var165
        end
    end
    return "Lobby"
end
TargetLimbNames = {
    {Name = "Head", Size = Vector3.new(1.25, 1.25, 1.25)},
    {Name = "Torso", Size = Vector3.new(2.1, 2.1, 1.1)},
    {Name = "Left Arm", Size = Vector3.new(1.1, 2.1, 1.1)},
    {Name = "Right Arm", Size = Vector3.new(1.1, 2.1, 1.1)},
    {Name = "Left Leg", Size = Vector3.new(1.1, 2.1, 1.1)},
    {Name = "Right Leg", Size = Vector3.new(1.1, 2.1, 1.1)},
    {Name = "UpperTorso", Size = Vector3.new(2.1, 1.1, 1.1)},
    {Name = "LowerTorso", Size = Vector3.new(2, 1, 1)},
    {Name = "LeftUpperArm", Size = Vector3.new(1.1, 1.1, 1.1)},
    {Name = "LeftLowerArm", Size = Vector3.new(1, 1.1, 1)},
    {Name = "RightUpperArm", Size = Vector3.new(1.1, 1.1, 1.1)},
    {Name = "RightLowerArm", Size = Vector3.new(1, 1.1, 1)},
    {Name = "LeftUpperLeg", Size = Vector3.new(1.1, 1.1, 1.1)},
    {Name = "LeftLowerLeg", Size = Vector3.new(1, 1.1, 1)},
    {Name = "RightUpperLeg", Size = Vector3.new(1.1, 1.1, 1.1)},
    {Name = "RightLowerLeg", Size = Vector3.new(1, 1.1, 1)},
    {Name = "LeftFoot", Size = Vector3.new(1, 0.8, 1)},
    {Name = "RightFoot", Size = Vector3.new(1, 0.8, 1)},
}
currentSpeed = 16
currentJump = 50
currentGravity = workspace.Gravity
infJumpEnabled = false
noclipEnabled = false
speedOverrideApplied = false
jumpOverrideApplied = false
movementOriginals = setmetatable({}, {__mode = "k"})
gravityOriginal = workspace.Gravity
fovOriginal = 70
cameraFovCaptured = false
function getHumanoid()
    local character3 = localPlayer.Character
    return character3 and character3:FindFirstChildOfClass("Humanoid")
end
function captureMovementOriginals(arg7)
    if not arg7 or movementOriginals[arg7] then
        return
    end
    movementOriginals[arg7] = {
        WalkSpeed = arg7.WalkSpeed,
        JumpPower = arg7.JumpPower,
        UseJumpPower = arg7.UseJumpPower,
        AutoRotate = arg7.AutoRotate,
    }
end
function restoreWalkSpeed(arg8)
    local var170 = arg8 and movementOriginals[arg8]
    if arg8 and var170 then
        arg8.WalkSpeed = var170.WalkSpeed
    end
end
function restoreJumpPower(arg9)
    local var174 = arg9 and movementOriginals[arg9]
    if arg9 and var174 then
        arg9.UseJumpPower = var174.UseJumpPower
        arg9.JumpPower = var174.JumpPower
    end
end
function ApplyMovement()
    local var175 = getHumanoid()
    if not var175 then
        return
    end
    captureMovementOriginals(var175)
    if currentSpeed ~= 16 then
        var175.WalkSpeed = currentSpeed
        speedOverrideApplied = true
    elseif speedOverrideApplied then
        restoreWalkSpeed(var175)
        speedOverrideApplied = false
    end
    if currentJump ~= 50 then
        var175.UseJumpPower = true
        var175.JumpPower = currentJump
        jumpOverrideApplied = true
    elseif jumpOverrideApplied then
        restoreJumpPower(var175)
        jumpOverrideApplied = false
    end
end
noclipParts = {}
noclipPartSet = {}
noclipOriginalCanCollide = {}
noclipDescAddedConnection = nil
noclipDescRemovingConnection = nil
noclipCharacter = nil
function removeNoclipPart(arg10)
    noclipOriginalCanCollide[arg10] = nil
    if not noclipPartSet[arg10] then
        return
    end
    noclipPartSet[arg10] = nil
    for i4 = #noclipParts, 1, -1 do
        if noclipParts[i4] == arg10 then
            table.remove(noclipParts, i4)
            break
        end
    end
end
function trackNoclipPart(obj)
    if obj and obj:IsA("BasePart") and not noclipPartSet[obj] then
        noclipPartSet[obj] = true
        noclipParts[#noclipParts + 1] = obj
        noclipOriginalCanCollide[obj] = obj.CanCollide
        if NoclipEnabled then
            obj.CanCollide = false
        end
    end
end
function clearNoclipPartCache()
    table.clear(noclipParts)
    table.clear(noclipPartSet)
    table.clear(noclipOriginalCanCollide)
end
function setupNoclipCharacter(arg11)
    if noclipDescAddedConnection then
        pcall(function()
            noclipDescAddedConnection:Disconnect()
        end)
        noclipDescAddedConnection = nil
    end
    if noclipDescRemovingConnection then
        pcall(function()
            noclipDescRemovingConnection:Disconnect()
        end)
        noclipDescRemovingConnection = nil
    end
    clearNoclipPartCache()
    noclipCharacter = arg11
    if not arg11 then
        return
    end
    local function fn13(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            trackNoclipPart(obj)
            fn13(obj)
        end
    end
    fn13(arg11)
    noclipDescAddedConnection = arg11.DescendantAdded:Connect(function(obj)
        trackNoclipPart(obj)
    end)
    noclipDescRemovingConnection = arg11.DescendantRemoving:Connect(function(obj)
        removeNoclipPart(obj)
    end)
end
function SetNoclip(arg12)
    NoclipEnabled = arg12 == true
    noclipEnabled = NoclipEnabled
    if noclipCharacter ~= localPlayer.Character then
        setupNoclipCharacter(localPlayer.Character)
    end
    for i5 = #noclipParts, 1, -1 do
        local obj = noclipParts[i5]
        if obj and obj.Parent and obj:IsA("BasePart") then
            if NoclipEnabled then
                obj.CanCollide = false
            else
                local var185 = noclipOriginalCanCollide[obj]
                if var185 ~= nil then
                    obj.CanCollide = var185
                end
            end
        else
            removeNoclipPart(obj)
        end
    end
end
function ApplyNoclip()
    if not NoclipEnabled then
        return
    end
    if noclipCharacter ~= localPlayer.Character then
        setupNoclipCharacter(localPlayer.Character)
    end
    for i6 = #noclipParts, 1, -1 do
        local var186 = noclipParts[i6]
        if var186 and var186.Parent and var186:IsA("BasePart") then
            var186.CanCollide = false
        else
            removeNoclipPart(var186)
        end
    end
end
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled or infJumpEnabled then
        local var189 = getHumanoid()
        if var189 then
            var189:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
local function fn14(character4)
    if not character4 then
        return
    end
    task.spawn(function()
        local var190 = character4:FindFirstChildOfClass("Humanoid") or character4:WaitForChild("Humanoid", 5)
        if not var190 then
            return
        end
        var190.Died:Connect(function()
            if autoFarmActive and autoFarmRoundActive then
                autoFarmRoundActive = false
                autoFarmWaitingForRoundStart = true
                if type(var108) == "function" then
                    var108()
                else
                    autoFarmCoinsRunning = false
                end
            end
        end)
    end)
end
if localPlayer.Character then
    fn14(localPlayer.Character)
end
localPlayer.CharacterAdded:Connect(function(character5)
    fn14(character5)
    if NoclipEnabled then
        setupNoclipCharacter(character5)
    end
    if autoFarmActive and autoFarmRoundActive then
        if autoFarmCoinsThread then
            task.cancel(autoFarmCoinsThread)
            autoFarmCoinsThread = nil
        end
        task.defer(function()
            if autoFarmActive and autoFarmRoundActive and localPlayer.Character == character5 then
                startAutoFarm()
            end
        end)
    end
    task.spawn(function()
        local humanoid2 = character5:WaitForChild("Humanoid", 5)
        if humanoid2 then
            movementOriginals[humanoid2] = {
                WalkSpeed = humanoid2.WalkSpeed,
                JumpPower = humanoid2.JumpPower,
                UseJumpPower = humanoid2.UseJumpPower,
                AutoRotate = humanoid2.AutoRotate,
            }
            task.wait(0.15)
            if currentSpeed ~= 16 or currentJump ~= 50 then
                ApplyMovement()
            end
            if NoclipEnabled then
                ApplyNoclip()
            end
        end
    end)
end)
task.spawn(function()
    while task.wait(0.12) do
        if currentSpeed ~= 16 or currentJump ~= 50 or currentGravity ~= 196.2 then
            ApplyMovement()
        end
        if noclipEnabled then
            ApplyNoclip()
        end
    end
end)
Camera = workspace.CurrentCamera
viewEnabled = false
selectedViewPlayer = localPlayer.Name
autoFarmActive = false
autoFarmCoinsRunning = false
autoFarmCoinsThread = nil
autoFarmSpeed = 12
autoFarmCollectDelay = 1
autoFarmVariant = "Normal"
coinReachEnabled = false
coinReachUserEnabled = false
autoFarmOwnsCoinReach = false
autoFarmRoundActive = false
autoFarmWaitingForRoundStart = true
coinReachRange = 4
coinReachOriginals = {}
coinReachConnection = nil
coinReachRemovingConnection = nil
coinReachPending = {}
coinReachGeneration = 0
antiAFKEnabled = false
autoPickupGunActive = false
pickupPanelInteracting = false
uiPanelTouchActive = false
VirtualUser = game:GetService("VirtualUser")
fakeBombJumpEnabled = false
fakeBombAutoJumpEnabled = true
fakeBombVariant = "Auto"
fakeBombMouseLockActive = false
fakeBombCooldownTime = 21
fakeBombCooldownUntil = 0
fakeBombJumpReady = true
fakeBombScreenTouchJumpConnection = nil
fakeBombScreenTouchSuppress = false
fakeBombManualInputConnection = nil
FakeBombJumpPanel = nil
FakeBombJumpLabel = nil
fakeBombPanelDragging = false
fakeBombPanelDragInput = nil
fakeBombPanelDragStart = nil
fakeBombPanelStartPos = nil
fakeBombPanelDragMoved = false
fakeBombPanelTouchStart = 0
fakeBombToolConnections = {}
fakeBombCharacterConnection = nil
fakeBombBackpackConnection = nil
fakeBombMouseLockConnection = nil
fakeBombLastPointer = nil
localPlayer.Idled:Connect(function()
    if not antiAFKEnabled then
        return
    end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)
aimbotActive = false
aimlockEngaged = false
aimbotFOV = 30
AimbotPanelScale = 8
AIMLOCK_FOV_RADIUS = 30
aimbotFOVVisible = false
autoShootActive = false
killAuraActive = false
killAuraDistance = 15
AutoShootEnabled = false
ShootKeybind = Enum.KeyCode.E
MobilePanelEnabled = false
PanelScale = 15
droppedGunEspEnabled = false
showDroppedGunEspNameEnabled = false
espHighlights = {}
function getPlayerList()
    local tbl5 = {}
    for _, v10 in ipairs(Players:GetPlayers()) do
        table.insert(tbl5, v10.Name)
    end
    if #tbl5 == 0 then
        table.insert(tbl5, localPlayer.Name)
    end
    table.sort(tbl5)
    return tbl5
end
function getRole(player3)
    if not player3 then
        return "Lobby"
    end
    local var203 = roleCacheByUserId and roleCacheByUserId[player3.UserId]
    if var203 then
        return var203
    end
    var203 = roleCache and roleCache[player3.Name]
    if var203 then
        return var203
    end
    return "Lobby"
end
function getRoleColor(arg13)
    return RoleColors[arg13] or RoleColors.Lobby
end
function getToolByName(player4, arg14)
    if not player4 then
        return nil
    end
    local character6 = player4.Character
    if character6 then
        local var205 = character6:FindFirstChild(arg14)
        if var205 and var205:IsA("Tool") then
            return var205
        end
    end
    local backpack2 = player4:FindFirstChildOfClass("Backpack")
    if backpack2 then
        local var207 = backpack2:FindFirstChild(arg14)
        if var207 and var207:IsA("Tool") then
            return var207
        end
    end
    return nil
end
function getKnife()
    return getToolByName(localPlayer, "Knife") or (function()
        local character7 = localPlayer.Character
        local backpack3 = localPlayer:FindFirstChildOfClass("Backpack")
        local tbl6 = {character7, backpack3}
        for _, v11 in ipairs(tbl6) do
            if v11 then
                for _, obj in ipairs(v11:GetChildren()) do
                    if obj:IsA("Tool") then
                        local var208 = string.lower(obj.Name)
                        if var208:find("knife") or var208:find("blade") or var208:find("dagger") then
                            return obj
                        end
                    end
                end
            end
        end
    end)()
end
function getGunForBolong()
    local var209 = getToolByName(localPlayer, "Gun")
    if var209 then
        return var209
    end
    local character8 = localPlayer.Character
    local backpack4 = localPlayer:FindFirstChildOfClass("Backpack")
    for _, v12 in ipairs({character8, backpack4}) do
        if v12 then
            for _, obj in ipairs(v12:GetChildren()) do
                if obj:IsA("Tool") then
                    local var211 = string.lower(obj.Name)
                    if var211 == "gun" or var211:find("revolver") or var211:find("pistol") or var211:find("gun") then
                        return obj
                    end
                end
            end
        end
    end
end
function refreshGunHolderRole(player5)
    if not player5 or player5 == localPlayer or not player5.Parent then
        return
    end
    if not roleRoundActive then
        return
    end
    local var213 = getToolByName(player5, "Gun")
    if not var213 then
        return
    end
    local var214 = GetPlayerRoleMM2(player5)
    if var214 == "Sheriff" then
        firstGunHolderName = player5.Name
        flag6 = false
        var132 = nil
        fn10(player5)
        return
    end
    if firstGunHolderName and firstGunHolderName == player5.Name then
        roleCache[player5.Name] = "Sheriff"
        roleCacheByUserId[player5.UserId] = "Sheriff"
        flag6 = false
        var132 = nil
        fn10(player5)
        return
    end
    if firstGunHolderName and flag3 then
        roleCache[player5.Name] = "Hero"
        roleCacheByUserId[player5.UserId] = "Hero"
        flag6 = false
        var132 = nil
        fn10(player5)
        return
    end
    for _, v13 in pairs(roleCache) do
        if v13 == "Sheriff" then
            return
        end
    end
    firstGunHolderName = player5.Name
    roleCache[player5.Name] = "Sheriff"
    roleCacheByUserId[player5.UserId] = "Sheriff"
    flag6 = false
    var132 = nil
    fn10(player5)
end
function bindGunRoleWatcher(arg15, arg16)
    if not arg15 or arg15 == localPlayer or not arg16 then
        return
    end
    arg16.ChildAdded:Connect(function(arg17)
        if arg17:IsA("Tool") and string.lower(arg17.Name) == "gun" then
            task.defer(function()
                refreshGunHolderRole(arg15)
            end)
        end
    end)
    local backpack5 = arg15:FindFirstChildOfClass("Backpack")
    if backpack5 then
        backpack5.ChildAdded:Connect(function(arg18)
            if arg18:IsA("Tool") and string.lower(arg18.Name) == "gun" then
                task.defer(function()
                    refreshGunHolderRole(arg15)
                end)
            end
        end)
    end
end
for _, v14 in ipairs(Players:GetPlayers()) do
    if v14 ~= localPlayer then
        if v14.Character then
            bindGunRoleWatcher(v14, v14.Character)
        end
        v14.CharacterAdded:Connect(function(arg19)
            task.defer(function()
                bindGunRoleWatcher(v14, arg19)
                refreshGunHolderRole(v14)
            end)
        end)
    end
end
Players.PlayerAdded:Connect(function(player6)
    if player6 == localPlayer then
        return
    end
    player6.CharacterAdded:Connect(function(arg20)
        task.defer(function()
            bindGunRoleWatcher(player6, arg20)
            refreshGunHolderRole(player6)
        end)
    end)
end)
function equipTool(arg21)
    local character9 = localPlayer.Character
    local var218 = character9 and character9:FindFirstChildOfClass("Humanoid")
    if arg21 and var218 and arg21.Parent ~= character9 then
        pcall(function()
            var218:EquipTool(arg21)
        end)
    end
end
cachedGunDrop = nil
function getGunDrop()
    if cachedGunDrop and cachedGunDrop.Parent then
        return cachedGunDrop
    end
    local obj = Workspace:FindFirstChild("GunDrop", true)
    if obj and obj:IsA("BasePart") then
        cachedGunDrop = obj
        return obj
    elseif obj and obj:IsA("Model") then
        local var221 = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if var221 then
            cachedGunDrop = var221
            return var221
        end
    end
    cachedGunDrop = nil
    return nil
end
RunService.Heartbeat:Connect(function()
    if noclipEnabled then
        ApplyNoclip()
    end
    if currentGravity ~= 196.2 then
        if workspace.Gravity ~= currentGravity then
            workspace.Gravity = currentGravity
        end
    elseif workspace.Gravity ~= gravityOriginal then
        workspace.Gravity = gravityOriginal
    end
end)
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local var222 = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if var222 then
            var222:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
RunService.Heartbeat:Connect(function()
    if viewEnabled then
        local var223 = Players:FindFirstChild(selectedViewPlayer)
        if var223 and var223.Character then
            local humanoid3 = var223.Character:FindFirstChildOfClass("Humanoid")
            if humanoid3 then
                Camera.CameraSubject = humanoid3
            end
        end
    end
end)
roleBoxes = {}
roleCharacterConnections = {}
roleRebuildQueued = {}
ROLE_PART_NAMES = {
    "Head",
    "UpperTorso",
    "LowerTorso",
    "Torso",
    "Waist",
    "LeftUpperArm",
    "LeftLowerArm",
    "LeftHand",
    "Left Arm",
    "RightUpperArm",
    "RightLowerArm",
    "RightHand",
    "Right Arm",
    "LeftUpperLeg",
    "LeftLowerLeg",
    "LeftFoot",
    "Left Leg",
    "RightUpperLeg",
    "RightLowerLeg",
    "RightFoot",
    "Right Leg",
}
local function fn15(arg22)
    for _, v15 in ipairs(ROLE_PART_NAMES) do
        if v15 == arg22 then
            return true
        end
    end
    return false
end
local function fn16(player7, arg23)
    if not EspEnabled or not roleVisualsAllowed or not player7 or not arg23 or player7.Character ~= arg23 then
        return
    end
    if roleRebuildQueued[player7] then
        return
    end
    roleRebuildQueued[player7] = true
    task.delay(0.08, function()
        roleRebuildQueued[player7] = nil
        if EspEnabled and roleVisualsAllowed and player7.Parent and player7.Character == arg23 then
            buildRoleBoxes(player7)
        end
    end)
end
local function fn17(arg24, arg25)
    if not arg24 or not arg25 then
        return
    end
    local var231 = roleCharacterConnections[arg24]
    if var231 then
        for _, v16 in ipairs(var231) do
            pcall(function()
                v16:Disconnect()
            end)
        end
    end
    local tbl7 = {}
    roleCharacterConnections[arg24] = tbl7
    table.insert(tbl7, arg25.ChildAdded:Connect(function(arg26)
        if arg26:IsA("BasePart") and fn15(arg26.Name) then
            fn16(arg24, arg25)
        end
    end))
    table.insert(tbl7, arg25.ChildRemoved:Connect(function(arg27)
        if arg27:IsA("BasePart") and fn15(arg27.Name) then
            fn16(arg24, arg25)
        end
    end))
end
function clearRoleBoxes(arg28)
    local var236 = roleBoxes[arg28]
    if var236 then
        for _, v17 in ipairs(var236) do
            pcall(function()
                v17:Destroy()
            end)
        end
        roleBoxes[arg28] = nil
    end
end
function getRoleParts(arg29)
    local tbl8, seen = {}, {}
    for _, v18 in ipairs(ROLE_PART_NAMES) do
        local var239 = arg29:FindFirstChild(v18)
        if var239 and var239:IsA("BasePart") and not seen[var239] then
            seen[var239] = true
            table.insert(tbl8, var239)
        end
    end
    return tbl8
end
function buildRoleBoxes(player8)
    clearRoleBoxes(player8)
    if not roleVisualsAllowed then
        return
    end
    if not roleRoundActive and not flag4 and not flag6 then
        return
    end
    local character10 = player8.Character
    if not character10 then
        return
    end
    local tbl9 = {}
    local var243 = getRoleColor(GetPlayerRoleMM2(player8))
    fn17(player8, character10)
    fn11(player8, character10)
    for _, v19 in ipairs(getRoleParts(character10)) do
        local boxHandleAdornment = Instance.new("BoxHandleAdornment")
        boxHandleAdornment.Name = "BolongRolePartBox"
        boxHandleAdornment.Adornee = v19
        boxHandleAdornment.Size = v19.Size
        boxHandleAdornment.Color3 = var243
        boxHandleAdornment.Transparency = 0.64
        boxHandleAdornment.AlwaysOnTop = true
        boxHandleAdornment.ZIndex = 1
        boxHandleAdornment.Visible = (roleRoundActive or flag4 or flag6) and not tbl3[player8] and GetPlayerRoleMM2(player8) ~= "Lobby"
        boxHandleAdornment.Parent = v19
        table.insert(tbl9, boxHandleAdornment)
    end
    roleBoxes[player8] = tbl9
end
task.spawn(function()
    while task.wait(0.25) do
        if EspEnabled then
            if roleVisualSource == "FALLBACK" and not flag5 then
                fn9()
            end
            for k4 in pairs(roleBoxes) do
                fn10(k4)
            end
        end
    end
end)
Players.PlayerRemoving:Connect(function(arg30)
    clearRoleBoxes(arg30)
    tbl3[arg30] = nil
    local var249 = tbl4[arg30]
    if var249 then
        pcall(function()
            var249:Disconnect()
        end)
        tbl4[arg30] = nil
    end
    local var250 = roleCharacterConnections[arg30]
    if var250 then
        for _, v20 in ipairs(var250) do
            pcall(function()
                v20:Disconnect()
            end)
        end
        roleCharacterConnections[arg30] = nil
    end
    roleRebuildQueued[arg30] = nil
end)
Players.PlayerAdded:Connect(function(player9)
    if player9 == localPlayer then
        return
    end
    local function fn18(character11)
        clearRoleBoxes(player9)
        character11:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.25)
        if player9.Parent and player9.Character == character11 then
            fn17(player9, character11)
            if EspEnabled and roleVisualsAllowed then
                buildRoleBoxes(player9)
            end
        end
    end
    if player9.Character then
        task.spawn(fn18, player9.Character)
    end
    player9.CharacterAdded:Connect(function(arg31)
        task.spawn(fn18, arg31)
    end)
end)
for _, v21 in ipairs(Players:GetPlayers()) do
    if v21 ~= localPlayer then
        v21.CharacterAdded:Connect(function(arg32)
            clearRoleBoxes(v21)
            fn17(v21, arg32)
            task.wait(0.25)
            if EspEnabled and roleVisualsAllowed and v21.Parent and v21.Character == arg32 then
                buildRoleBoxes(v21)
            end
        end)
    end
end
droppedGunBlock = nil
droppedGunNameBillboard = nil
function clearDroppedGunESPName()
    if droppedGunNameBillboard then
        pcall(function()
            droppedGunNameBillboard:Destroy()
        end)
    end
    droppedGunNameBillboard = nil
end
function clearDroppedGunESP()
    if droppedGunBlock then
        pcall(function()
            droppedGunBlock:Destroy()
        end)
    end
    droppedGunBlock = nil
end
function setGunDrop(obj)
    if obj and obj.Name == "GunDrop" and obj:IsA("BasePart") then
        cachedGunDrop = obj
    end
end
initialGunDrop = Workspace:FindFirstChild("GunDrop", true)
if initialGunDrop then
    if initialGunDrop:IsA("BasePart") then
        setGunDrop(initialGunDrop)
    elseif initialGunDrop:IsA("Model") then
        local var256 = initialGunDrop.PrimaryPart or initialGunDrop:FindFirstChildWhichIsA("BasePart")
        if var256 then
            setGunDrop(var256)
        end
    end
end
Workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "GunDrop" then
        if obj:IsA("BasePart") then
            setGunDrop(obj)
        elseif obj:IsA("Model") then
            local var257 = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if var257 then
                setGunDrop(var257)
            end
        end
    end
end)
Workspace.DescendantRemoving:Connect(function(obj)
    if obj == cachedGunDrop then
        cachedGunDrop = nil
        clearDroppedGunESP()
    end
end)
function updateDroppedGunESP()
    if not cachedGunDrop or not cachedGunDrop.Parent then
        clearDroppedGunESP()
        clearDroppedGunESPName()
        return
    end
    if droppedGunEspEnabled then
        if not droppedGunBlock or droppedGunBlock.Adornee ~= cachedGunDrop then
            clearDroppedGunESP()
            local boxHandleAdornment2 = Instance.new("BoxHandleAdornment")
            boxHandleAdornment2.Name = "BolongDroppedGun3D"
            boxHandleAdornment2.Adornee = cachedGunDrop
            boxHandleAdornment2.Size = cachedGunDrop.Size + Vector3.new(1.2, 1.2, 1.2)
            boxHandleAdornment2.Color3 = Color3.fromRGB(0, 45, 15)
            boxHandleAdornment2.Transparency = 0.63
            boxHandleAdornment2.AlwaysOnTop = true
            boxHandleAdornment2.ZIndex = 1
            boxHandleAdornment2.Parent = cachedGunDrop
            droppedGunBlock = boxHandleAdornment2
        end
    else
        clearDroppedGunESP()
    end
    if showDroppedGunEspNameEnabled then
        if not droppedGunNameBillboard or droppedGunNameBillboard.Adornee ~= cachedGunDrop then
            clearDroppedGunESPName()
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "BolongDroppedGunName"
            billboardGui.Adornee = cachedGunDrop
            billboardGui.Size = UDim2.fromOffset(140, 28)
            billboardGui.StudsOffset = Vector3.new(0, math.max(1.5, cachedGunDrop.Size.Y * 0.5 + 1.2), 0)
            billboardGui.AlwaysOnTop = true
            billboardGui.Parent = cachedGunDrop
            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "DroppedGun"
            textLabel.Size = UDim2.fromScale(1, 1)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "Dropped Gun"
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextSize = 16
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextStrokeTransparency = 0.2
            textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            textLabel.Parent = billboardGui
            droppedGunNameBillboard = billboardGui
        end
    else
        clearDroppedGunESPName()
    end
end
task.spawn(function()
    while task.wait(0.12) do
        updateDroppedGunESP()
    end
end)
local function fn19()
    local tbl10 = {}
    local function fn20(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                table.insert(tbl10, obj)
            end
            fn20(obj)
        end
    end
    fn20(Workspace)
    return tbl10
end
local function fn21(obj)
    if not coinReachEnabled or not obj or not obj.Parent then
        return
    end
    if obj.Name ~= "Coin_Server" or not obj:IsA("BasePart") then
        return
    end
    if not coinReachOriginals[obj] then
        coinReachOriginals[obj] = obj.Size
    end
    local var266 = coinReachOriginals[obj]
    if var266 then
        local var269 = autoFarmOwnsCoinReach and 5 or coinReachRange
        pcall(function()
            obj.Size = var266 * var269
        end)
    end
end
local function fn22(obj, arg33)
    if not coinReachEnabled or not obj or obj.Name ~= "Coin_Server" or not obj:IsA("BasePart") then
        return
    end
    fn21(obj)
    if coinReachPending[obj] then
        return
    end
    coinReachPending[obj] = true
    task.defer(function()
        coinReachPending[obj] = nil
        if not coinReachEnabled or arg33 ~= coinReachGeneration or not obj.Parent then
            return
        end
        fn21(obj)
        task.delay(0.01, function()
            if coinReachEnabled and arg33 == coinReachGeneration and obj.Parent then
                fn21(obj)
            end
        end)
        task.delay(0.05, function()
            if coinReachEnabled and arg33 == coinReachGeneration and obj.Parent then
                fn21(obj)
            end
        end)
    end)
end
local function fn23(arg34)
    arg34 = arg34 == true
    if arg34 == coinReachEnabled then
        if arg34 then
            local var271 = autoFarmOwnsCoinReach and 5 or coinReachRange
            for obj, v22 in pairs(coinReachOriginals) do
                if obj and obj.Parent and v22 then
                    pcall(function()
                        obj.Size = v22 * var271
                    end)
                end
            end
        end
        return
    end
    coinReachEnabled = arg34
    coinReachGeneration = coinReachGeneration + 1
    local var273 = coinReachGeneration
    coinReachPending = {}
    if coinReachConnection then
        coinReachConnection:Disconnect()
        coinReachConnection = nil
    end
    if coinReachRemovingConnection then
        coinReachRemovingConnection:Disconnect()
        coinReachRemovingConnection = nil
    end
    if coinReachEnabled then
        coinReachOriginals = {}
        coinReachConnection = Workspace.DescendantAdded:Connect(function(obj)
            if coinReachEnabled and var273 == coinReachGeneration then
                fn22(obj, var273)
            end
        end)
        coinReachRemovingConnection = Workspace.DescendantRemoving:Connect(function(obj)
            coinReachOriginals[obj] = nil
            coinReachPending[obj] = nil
        end)
        for _, obj in ipairs(fn19()) do
            fn22(obj, var273)
        end
    else
        for obj, v23 in pairs(coinReachOriginals) do
            if obj and obj.Parent and v23 then
                pcall(function()
                    obj.Size = v23
                end)
            end
        end
        coinReachOriginals = {}
        coinReachPending = {}
    end
end
function setAutoFarmCoinReach(arg35)
    autoFarmOwnsCoinReach = arg35 == true
    fn23(coinReachUserEnabled or autoFarmOwnsCoinReach)
end
autoFarmSpeed = 12
autoFarmCollectDelay = 1
autoFarmVariant = "Normal"
autoFarmMode = "Normal"
autoFarmCoinsCollected = 0
autoFarmFullActionDone = false
autoFarmRoundToken = 0
autoFarmCurrentTween = nil
autoFarmNoclipEnabled = false
autoFarmNoclipConnection = nil
autoFarmNoclipEnforceConnection = nil
autoFarmNoclipOriginals = {}
autoFarmGodPlatform = nil
autoFarmHoldCFrame = nil
autoFarmNoCoinsStanding = false
AUTO_FARM_LAY_DEPTH = 1.8
AUTO_FARM_STAND_ROOT_HEIGHT = 2.5
murdererKillAllEnabled = false
autoShootMurdererEnabled = false
local function fn24(arg36)
    arg36 = arg36 == true
    if arg36 and autoFarmNoclipEnabled then
        return
    end
    if autoFarmNoclipConnection then
        pcall(function()
            autoFarmNoclipConnection:Disconnect()
        end)
        autoFarmNoclipConnection = nil
    end
    if autoFarmNoclipEnforceConnection then
        pcall(function()
            autoFarmNoclipEnforceConnection:Disconnect()
        end)
        autoFarmNoclipEnforceConnection = nil
    end
    if not arg36 then
        for k5, v24 in pairs(autoFarmNoclipOriginals) do
            if k5 and k5.Parent then
                pcall(function()
                    k5.CanCollide = v24
                end)
            end
        end
        autoFarmNoclipOriginals = {}
        autoFarmNoclipEnabled = false
        return
    end
    autoFarmNoclipEnabled = true
    autoFarmNoclipOriginals = {}
    local character12 = localPlayer.Character
    if not character12 then
        autoFarmNoclipEnabled = false
        return
    end
    local function fn25(obj)
        if obj and obj:IsA("BasePart") then
            if autoFarmNoclipOriginals[obj] == nil then
                autoFarmNoclipOriginals[obj] = obj.CanCollide
            end
            pcall(function()
                obj.CanCollide = false
            end)
        end
    end
    local function fn26(parent)
        for _, v25 in ipairs(parent:GetChildren()) do
            fn25(v25)
            fn26(v25)
        end
    end
    fn26(character12)
    autoFarmNoclipConnection = character12.DescendantAdded:Connect(function(obj)
        if autoFarmNoclipEnabled then
            fn25(obj)
        end
    end)
    autoFarmNoclipEnforceConnection = RunService.Heartbeat:Connect(function()
        if not autoFarmNoclipEnabled then
            return
        end
        local var282 = localPlayer and localPlayer.Character
        if not var282 then
            return
        end
        for _, obj in ipairs(var282:GetDescendants()) do
            fn25(obj)
        end
    end)
end
var107 = function()
    if autoFarmGodPlatform then
        pcall(function()
            autoFarmGodPlatform:Destroy()
        end)
        autoFarmGodPlatform = nil
    end
end
local function fn27()
    local character13 = localPlayer.Character
    local var284 = character13 and character13:FindFirstChildOfClass("Humanoid")
    local var285 = character13 and character13:FindFirstChild("HumanoidRootPart")
    if var284 then
        pcall(function()
            var284.AutoRotate = true
            var284:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
    if var285 then
        pcall(function()
            var285.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end
local function fn28(holdCFrame)
    if not autoFarmCoinsRunning or not holdCFrame then
        return
    end
    local var288 = localPlayer and localPlayer.Character
    local var290 = var288 and var288:FindFirstChildOfClass("Humanoid")
    local var291 = var288 and var288:FindFirstChild("HumanoidRootPart")
    if not var290 or not var291 or var290.Health <= 0 then
        return
    end
    pcall(function()
        var290.AutoRotate = false
        var290:ChangeState(Enum.HumanoidStateType.Physics)
        var291.CFrame = holdCFrame
        var291.AssemblyLinearVelocity = Vector3.zero
        var291.AssemblyAngularVelocity = Vector3.zero
    end)
    autoFarmHoldCFrame = holdCFrame
end
local function fn29()
    if autoFarmVariant ~= "Lay" then
        fn27()
        return
    end
    local character14 = localPlayer.Character
    local var292 = character14 and character14:FindFirstChildOfClass("Humanoid")
    local var293 = character14 and character14:FindFirstChild("HumanoidRootPart")
    if not var292 or not var293 or var292.Health <= 0 then
        return
    end
    pcall(function()
        var292.AutoRotate = false
        var292:ChangeState(Enum.HumanoidStateType.Physics)
        var293.AssemblyLinearVelocity = Vector3.zero
        var293.AssemblyAngularVelocity = Vector3.zero
        var293.CFrame = CFrame.new(var293.Position) * CFrame.Angles(math.rad(90), 0, 0)
    end)
end
local function fn30()
    if autoFarmMapCache and autoFarmMapCache.Parent and autoFarmMapCache:GetAttribute("MapID") and autoFarmMapCache:FindFirstChild("CoinContainer") then
        return autoFarmMapCache
    end
    autoFarmMapCache = nil
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then
            autoFarmMapCache = obj
            return obj
        end
    end
    return nil
end
local function fn31()
    local var295 = fn30()
    if not var295 or not autoFarmCoinsRunning then
        return nil
    end
    local coinContainer = var295:FindFirstChild("CoinContainer")
    if not coinContainer then
        return nil
    end
    local var296, closestDist = nil, math.huge
    local character15 = localPlayer.Character
    local var298 = character15 and character15:FindFirstChild("HumanoidRootPart")
    local var299 = character15 and character15:FindFirstChildOfClass("Humanoid")
    if not character15 or not var298 or not var299 or var299.Health <= 0 then
        return nil
    end
    for _, v26 in ipairs(coinContainer:GetChildren()) do
        local coinVisual = v26:FindFirstChild("CoinVisual")
        if v26:IsA("BasePart") and coinVisual and not coinVisual:GetAttribute("Collected") then
            local magnitude = (var298.Position - v26.Position).Magnitude
            if magnitude < closestDist then
                var296 = v26
                closestDist = magnitude
            end
        end
    end
    return var296
end
local function fn32()
    while autoFarmCoinsRunning do
        local character16 = localPlayer.Character
        local var303 = character16 and character16:FindFirstChildOfClass("Humanoid")
        local var304 = character16 and character16:FindFirstChild("HumanoidRootPart")
        if character16 and var303 and var304 and var303.Health > 0 then
            return character16, var303, var304
        end
        task.wait(0.12)
    end
    return nil
end
local function fn33(arg37, arg38)
    local var305 = arg37.Position + Vector3.new(0, -AUTO_FARM_LAY_DEPTH, 0)
    local var306 = fn30()
    local var307 = var306 and var306:FindFirstChild("CoinContainer")
    local tbl11 = {arg38}
    if var307 then
        table.insert(tbl11, var307)
    end
    local var308 = nil
    local var312, var313 = pcall(function()
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = tbl11
        raycastParams.IgnoreWater = true
        return Workspace:Raycast(arg37.Position + Vector3.new(0, 6, 0), Vector3.new(0, -60, 0), raycastParams)
    end)
    if var312 and var313 then
        var308 = var313.Position
    end
    local var315 = var308 and var308 + Vector3.new(0, -AUTO_FARM_LAY_DEPTH, 0) or var305
    return CFrame.new(var315) * CFrame.Angles(math.rad(90), 0, 0)
end
local function fn34(arg39)
    local var316, var317, var318 = fn32()
    if not var316 or not var317 or not var318 or not arg39 or not arg39.Parent then
        return false
    end
    autoFarmNoCoinsStanding = false
    fn24(true)
    local var320
    if autoFarmVariant == "Lay" then
        fn29()
        var320 = fn33(arg39, var316)
    else
        var320 = CFrame.new(arg39.Position)
    end
    autoFarmHoldCFrame = nil
    local magnitude2 = (var318.Position - var320.Position).Magnitude
    local var321 = math.clamp(tonumber(autoFarmSpeed) or 12, 7, 30)
    local duration = math.max(0.02, magnitude2 / var321)
    if autoFarmCurrentTween then
        pcall(function()
            autoFarmCurrentTween:Cancel()
        end)
        autoFarmCurrentTween = nil
    end
    local var324 = TweenService:Create(var318, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = var320})
    autoFarmCurrentTween = var324
    var324:Play()
    while var324.PlaybackState == Enum.PlaybackState.Playing and autoFarmCoinsRunning do
        if var317.Health <= 0 or not var318.Parent or not arg39.Parent then
            var324:Cancel()
            autoFarmCurrentTween = nil
            return false
        end
        task.wait()
    end
    if autoFarmCurrentTween == var324 then
        autoFarmCurrentTween = nil
    end
    if autoFarmCoinsRunning and var318.Parent and arg39.Parent then
        fn28(var320)
    end
    return autoFarmCoinsRunning, var320
end
local function fn35(lastHoldCFrame)
    local var325 = localPlayer and localPlayer.Character
    local var326 = var325 and var325:FindFirstChildOfClass("Humanoid")
    local var327 = var325 and var325:FindFirstChild("HumanoidRootPart")
    if autoFarmVariant == "Lay" and lastHoldCFrame and var327 and var327.Parent and var326 and var326.Health > 0 then
        local var330 = lastHoldCFrame.Position + Vector3.new(0, AUTO_FARM_LAY_DEPTH + AUTO_FARM_STAND_ROOT_HEIGHT, 0)
        local cFrame = CFrame.new(var330)
        if autoFarmCurrentTween then
            pcall(function()
                autoFarmCurrentTween:Cancel()
            end)
            autoFarmCurrentTween = nil
        end
        fn24(true)
        local var331 = TweenService:Create(var327, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = cFrame})
        autoFarmCurrentTween = var331
        var331:Play()
        while var331.PlaybackState == Enum.PlaybackState.Playing and var327.Parent do
            task.wait()
        end
        if autoFarmCurrentTween == var331 then
            autoFarmCurrentTween = nil
        end
    end
    autoFarmHoldCFrame = nil
    autoFarmNoCoinsStanding = true
    fn24(false)
    fn27()
end
local function fn36()
    if autoFarmFullActionDone or autoFarmCoinsCollected < 40 then
        return false
    end
    autoFarmFullActionDone = true
    autoFarmCoinsRunning = false
    local var333 = autoFarmHoldCFrame
    if autoFarmCurrentTween then
        pcall(function()
            autoFarmCurrentTween:Cancel()
        end)
        autoFarmCurrentTween = nil
    end
    fn35(var333)
    local var335 = getKnife()
    local var336 = getGunForBolong()
    if murdererKillAllEnabled and var335 then
        equipTool(var335)
        task.defer(function()
            killAll()
        end)
        return true
    end
    if autoShootMurdererEnabled and var336 then
        equipTool(var336)
        task.spawn(function()
            local var339 = autoFarmRoundToken
            while autoFarmActive and autoShootMurdererEnabled and var339 == autoFarmRoundToken and RoundTimerState.phase ~= "ENDED" do
                local var340, targetPart = getMurdererTargetPart()
                if not var340 or not targetPart then
                    break
                end
                local character17 = var340.Character
                local var341 = character17 and character17:FindFirstChildOfClass("Humanoid")
                if not var341 or var341.Health <= 0 then
                    break
                end
                local var342 = getGunForBolong()
                if not var342 then
                    break
                end
                local var343 = localPlayer.Character and localPlayer.Character:FindFirstChild("Gun")
                if not var343 then
                    equipTool(var342)
                    task.wait(0.01)
                    var343 = localPlayer.Character and localPlayer.Character:FindFirstChild("Gun")
                end
                if not var343 then
                    break
                end
                fireShotAtTarget(var343, targetPart)
                task.wait(0.015)
            end
        end)
        return true
    end
    local character18 = localPlayer.Character
    local var344 = character18 and character18:FindFirstChildOfClass("Humanoid")
    local var345 = character18 and character18:FindFirstChild("HumanoidRootPart")
    if var344 then
        pcall(function()
            var344.AutoRotate = true
            var344:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
    if var345 then
        pcall(function()
            var345.AssemblyLinearVelocity = Vector3.zero
            var345.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    return true
end
function AutoFarmCoinsFunc()
    autoFarmRoundToken = autoFarmRoundToken + 1
    autoFarmCoinsCollected = 0
    autoFarmFullActionDone = false
    autoFarmMapCache = nil
    autoFarmCountedCoins = setmetatable({}, {__mode = "k"})
    fn24(true)
    fn29()
    while autoFarmCoinsRunning and not autoFarmFullActionDone do
        local var348 = fn31()
        if var348 then
            local coinVisual2 = var348:FindFirstChild("CoinVisual")
            local var349, holdCFrame = fn34(var348)
            if var349 then
                while autoFarmCoinsRunning and var348.Parent and coinVisual2 and coinVisual2.Parent and not coinVisual2:GetAttribute("Collected") do
                    fn28(holdCFrame)
                    task.wait(0.05)
                end
                local flag7 = false
                if not var348.Parent or not coinVisual2 or not coinVisual2.Parent then
                    flag7 = true
                elseif coinVisual2:GetAttribute("Collected") == true then
                    flag7 = true
                end
                if flag7 and not autoFarmCountedCoins[var348] then
                    autoFarmCountedCoins[var348] = true
                    autoFarmCoinsCollected = autoFarmCoinsCollected + 1
                    if autoFarmCoinsCollected >= 40 then
                        fn36()
                        break
                    end
                end
                if autoFarmCoinsRunning and fn31() then
                    local var354 = os.clock() + math.clamp(tonumber(autoFarmCollectDelay) or 1, 0.4, 2)
                    while autoFarmCoinsRunning and os.clock() < var354 do
                        fn28(holdCFrame)
                        task.wait(0.05)
                    end
                end
            end
        else
            if not autoFarmNoCoinsStanding then
                fn35(autoFarmHoldCFrame)
            end
            task.wait(0.12)
        end
    end
end
function startAutoFarm()
    autoFarmActive = true
    if autoFarmCoinsThread then
        task.cancel(autoFarmCoinsThread)
        autoFarmCoinsThread = nil
    end
    if not autoFarmRoundActive then
        autoFarmCoinsRunning = false
        autoFarmHoldCFrame = nil
        autoFarmNoCoinsStanding = false
        fn24(false)
        fn27()
        if type(setAutoFarmCoinReach) == "function" then
            setAutoFarmCoinReach(false)
        end
        return
    end
    autoFarmCoinsRunning = true
    autoFarmFullActionDone = false
    autoFarmNoCoinsStanding = false
    if type(setAutoFarmCoinReach) == "function" then
        setAutoFarmCoinReach(true)
    end
    if autoFarmVariant == "Lay" then
        fn29()
    else
        fn27()
    end
    autoFarmCoinsThread = task.spawn(function()
        AutoFarmCoinsFunc()
        autoFarmCoinsThread = nil
    end)
end
function stopAutoFarm()
    autoFarmActive = false
    autoFarmCoinsRunning = false
    autoFarmHoldCFrame = nil
    autoFarmNoCoinsStanding = false
    if autoFarmCurrentTween then
        pcall(function()
            autoFarmCurrentTween:Cancel()
        end)
        autoFarmCurrentTween = nil
    end
    fn24(false)
    fn27()
    if type(setAutoFarmCoinReach) == "function" then
        setAutoFarmCoinReach(false)
    end
    if autoFarmCoinsThread then
        task.cancel(autoFarmCoinsThread)
        autoFarmCoinsThread = nil
    end
    var107()
end
var108 = function()
    autoFarmCoinsRunning = false
    autoFarmRoundToken = (tonumber(autoFarmRoundToken) or 0) + 1
    local var365 = autoFarmHoldCFrame
    if autoFarmCurrentTween then
        pcall(function()
            autoFarmCurrentTween:Cancel()
        end)
        autoFarmCurrentTween = nil
    end
    local var367 = localPlayer and localPlayer.Character
    local var368 = var367 and var367:FindFirstChildOfClass("Humanoid")
    if autoFarmVariant == "Lay" and var365 and var368 and var368.Health > 0 then
        fn35(var365)
    else
        autoFarmHoldCFrame = nil
        autoFarmNoCoinsStanding = false
        fn24(false)
        fn27()
    end
    if type(setAutoFarmCoinReach) == "function" then
        setAutoFarmCoinReach(false)
    end
    if type(var107) == "function" then
        var107()
    end
end
aimlockLockedPlayer = nil
aimlockLockedHead = nil
aimlockLockedHumanoid = nil
aimlockAcquireAccumulator = 0
AIMLOCK_SMOOTHNESS = 1
function clearAimlockTarget()
    aimlockLockedPlayer = nil
    aimlockLockedHead = nil
    aimlockLockedHumanoid = nil
end
function acquireAimlockTarget()
    if not aimbotActive or not aimlockEngaged or aimlockLockedPlayer then
        return
    end
    local vector2 = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local var371 = AIMLOCK_FOV_RADIUS
    local var372 = nil
    local var373 = var371
    local character19 = localPlayer.Character
    local var374 = character19 and character19:FindFirstChild("HumanoidRootPart")
    for _, v27 in ipairs(Players:GetPlayers()) do
        if v27 ~= localPlayer and v27.Character then
            local character20 = v27.Character
            local humanoid4 = character20:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = character20:FindFirstChild("HumanoidRootPart")
            local var376 = getRole(v27) == "Murderer"
            if var376 and humanoid4 and humanoid4.Health > 0 and humanoidRootPart then
                local var377 = character20:FindFirstChild("Head") or humanoidRootPart
                local var378, onScreen = Camera:WorldToViewportPoint(var377.Position)
                if onScreen and var378.Z > 0 then
                    local magnitude3 = (Vector2.new(var378.X, var378.Y) - vector2).Magnitude
                    if magnitude3 <= var373 then
                        var373 = magnitude3
                        var372 = v27
                    end
                end
            end
        end
    end
    if var372 then
        aimlockLockedPlayer = var372
        local character21 = var372.Character
        aimlockLockedHead = character21 and (character21:FindFirstChild("Head") or character21:FindFirstChild("HumanoidRootPart")) or nil
        aimlockLockedHumanoid = character21 and character21:FindFirstChildOfClass("Humanoid") or nil
    end
end
pcall(function()
    RunService:UnbindFromRenderStep("BolongAimlockLock")
end)
RunService:BindToRenderStep("BolongAimlockLock", Enum.RenderPriority.Camera.Value + 1, function()
    if not aimbotActive or not aimlockEngaged then
        return
    end
    local var381 = aimlockLockedPlayer
    if not var381 or var381.Parent ~= Players then
        clearAimlockTarget()
        acquireAimlockTarget()
        var381 = aimlockLockedPlayer
    end
    local var382 = var381 and var381.Character
    local var383 = var382 and var382:FindFirstChildOfClass("Humanoid")
    local var384 = var382 and var382:FindFirstChild("HumanoidRootPart")
    if not var383 or var383.Health <= 0 or not var384 then
        clearAimlockTarget()
        acquireAimlockTarget()
        var381 = aimlockLockedPlayer
        var382 = var381 and var381.Character
        var383 = var382 and var382:FindFirstChildOfClass("Humanoid")
        var384 = var382 and var382:FindFirstChild("HumanoidRootPart")
    end
    if not var384 then
        return
    end
    local var385 = var382:FindFirstChild("Head") or var384
    aimlockLockedHead = var385
    aimlockLockedHumanoid = var383
    local position2 = Camera.CFrame.Position
    Camera.CFrame = CFrame.lookAt(position2, var385.Position)
end)
AUTO_SHOOT_SHOT_COOLDOWN = 0.008
function getMurdererTargetPart()
    local character22 = localPlayer.Character
    local var388 = character22 and character22:FindFirstChild("HumanoidRootPart")
    if not var388 then
        return nil, nil
    end
    local var389 = nil
    local var390 = nil
    local huge = math.huge
    for _, v28 in ipairs(Players:GetPlayers()) do
        if v28 ~= localPlayer then
            local character23 = v28.Character
            local var391 = character23 and character23:FindFirstChildOfClass("Humanoid")
            local var392 = character23 and character23:FindFirstChild("UpperTorso")
            local var393 = getRole(v28) == "Murderer"
            local var394 = character23 and character23:FindFirstChild("Knife") ~= nil
            if (var393 or var394) and var392 and var392:IsA("BasePart") and var391 and var391.Health > 0 then
                local magnitude4 = (var392.Position - var388.Position).Magnitude
                local var395 = magnitude4
                if var395 < huge then
                    huge = var395
                    var389 = v28
                    var390 = var392
                end
            end
        end
    end
    return var389, var390
end
function getGunShootRemote(arg40)
    if not arg40 then
        return nil
    end
    local shoot = arg40:FindFirstChild("Shoot")
    if shoot and (shoot:IsA("RemoteEvent") or shoot:IsA("UnreliableRemoteEvent")) then
        return shoot
    end
    local handle = arg40:FindFirstChild("Handle")
    if handle then
        local shoot2 = handle:FindFirstChild("Shoot")
        if shoot2 and (shoot2:IsA("RemoteEvent") or shoot2:IsA("UnreliableRemoteEvent")) then
            return shoot2
        end
    end
    return nil
end
local tbl12 = {
    Legacy = {
        PREDICTION_DISTANCE = 0.01,
        MAX_PREDICTION_OFFSET = 0.03,
        PREDICTION_WEIGHT = 0.03,
        MAX_PING_PREDICTION = 0.06,
        ANTI_JITTER_LOOKBACK = 0.08,
        ELEVATION_Y_OFFSET = -0.1,
        MAX_JITTER_PREDICTION = 0.1,
        JUMP_SPAM_THRESHOLD = 3,
        MAX_PREDICTION_DISTANCE = 0.5,
        HIGH_GROUND_HEIGHT = 4,
        RELATIVE_WEIGHT = 0.25,
        VerticalMode = "Legacy",
    },
    Astral = {
        PREDICTION_DISTANCE = 0.025,
        MAX_PREDICTION_OFFSET = 0.04,
        PREDICTION_WEIGHT = 0.035,
        MAX_PING_PREDICTION = 0.06,
        ANTI_JITTER_LOOKBACK = 0.08,
        ELEVATION_Y_OFFSET = -0.05,
        MAX_JITTER_PREDICTION = 0.12,
        JUMP_SPAM_THRESHOLD = 3,
        MAX_PREDICTION_DISTANCE = 0.9,
        HIGH_GROUND_HEIGHT = 4,
        RELATIVE_WEIGHT = 0.32,
        VerticalMode = "Astral",
    },
}
local str = "Legacy"
local var399 = setmetatable({}, {__mode = "k"})
function getAutoShootTargetPoint(character24)
    if not character24 then
        return nil
    end
    local var400 = tbl12[str] or tbl12.Legacy
    local var401 = character24:FindFirstChild("UpperTorso") or character24:FindFirstChild("Torso") or character24:FindFirstChild("HumanoidRootPart")
    local humanoidRootPart2 = character24:FindFirstChild("HumanoidRootPart")
    local humanoid5 = character24:FindFirstChildOfClass("Humanoid")
    if not var401 or not humanoidRootPart2 or not humanoid5 or humanoid5.Health <= 0 then
        return nil
    end
    local character25 = game.Players.LocalPlayer.Character
    local var402 = character25 and character25:FindFirstChild("HumanoidRootPart")
    if not var402 then
        return var401.Position
    end
    local position3 = var402.Position
    local position4 = var401.Position
    local var403 = humanoidRootPart2.AssemblyLinearVelocity or humanoidRootPart2.Velocity
    local var404 = var402.AssemblyLinearVelocity or var402.Velocity
    local var405 = var403 - var404
    local var406 = position3 - position4
    local num = 0
    if var406.Magnitude > 1e-5 and var405.Magnitude > 1e-5 then
        num = var405.Unit:Dot(var406.Unit)
    end
    local var407 = position3.Y - position4.Y
    local var408 = var407 > var400.HIGH_GROUND_HEIGHT
    local num2 = 0
    if type(fn3) == "function" then
        num2 = tonumber(fn3()) or 0
    end
    local var410 = math.min(num2 / 1000, var400.MAX_PING_PREDICTION)
    local delay = var410 + var400.PREDICTION_DISTANCE
    local var411 = var400.RELATIVE_WEIGHT * 0.8
    if var408 and num > 0.3 then
        var411 = var400.RELATIVE_WEIGHT * 0.2
    end
    local vector3 = Vector3.new(var405.X, 0, var405.Z)
    local var412 = vector3 * delay * var411 * var400.PREDICTION_WEIGHT
    local var413 = os.clock()
    local var414 = var399[humanoidRootPart2]
    local flag8 = false
    if var414 and var413 - var414.time <= var400.ANTI_JITTER_LOOKBACK then
        local velocity2 = var414.velocity
        if vector3.Magnitude >= 3 and velocity2.Magnitude >= 3 then
            flag8 = velocity2.Unit:Dot(vector3.Unit) < 0.25
        end
    end
    var399[humanoidRootPart2] = {velocity = vector3, time = var413}
    local var417 = math.clamp(var412.X, -var400.MAX_PREDICTION_DISTANCE, var400.MAX_PREDICTION_DISTANCE)
    local var418 = math.clamp(var412.Z, -var400.MAX_PREDICTION_DISTANCE, var400.MAX_PREDICTION_DISTANCE)
    local var420 = math.clamp(var417, -var400.MAX_JITTER_PREDICTION, var400.MAX_JITTER_PREDICTION)
    local var421 = math.clamp(var418, -var400.MAX_JITTER_PREDICTION, var400.MAX_JITTER_PREDICTION)
    local var422 = math.clamp(var420, -var400.MAX_PREDICTION_OFFSET, var400.MAX_PREDICTION_OFFSET)
    local var425 = math.clamp(var421, -var400.MAX_PREDICTION_OFFSET, var400.MAX_PREDICTION_OFFSET)
    if flag8 then
        var422 = 0
        var425 = 0
    end
    local num3 = 0
    local var427 = humanoid5:GetState()
    local Y = var405.Y
    if var400.VerticalMode == "Astral" then
        if var427 == Enum.HumanoidStateType.Freefall or var427 == Enum.HumanoidStateType.Jumping then
            num3 = math.clamp((Y - var404.Y * 0.35) * delay * 0.22, -0.4, 0.4)
        elseif math.abs(Y) > var400.JUMP_SPAM_THRESHOLD then
            num3 = math.clamp(Y * delay * 0.15, -0.3, 0.3)
        end
    else
        if var427 == Enum.HumanoidStateType.Freefall or var427 == Enum.HumanoidStateType.Jumping then
            num3 = math.clamp(Y * delay * 0.15, -0.3, 0.3)
        elseif math.abs(Y) > var400.JUMP_SPAM_THRESHOLD then
            num3 = math.clamp(Y * delay * 0.1, -0.3, 0.3)
        end
    end
    if var408 then
        if num > 0.3 then
            num3 = num3 + var407 * 0.02
        else
            num3 = num3 - var407 * 0.01
        end
        num3 = num3 - var400.ELEVATION_Y_OFFSET
    end
    return position4 + Vector3.new(var422, num3, var425)
end
gunFiredVisualEvent = nil
gunFiredVisualLastAt = 0
pcall(function()
    local clientServices = undefinedGlobal1:FindFirstChild("ClientServices")
    local var433 = clientServices and clientServices:FindFirstChild("WeaponService")
    local var434 = var433 and var433:FindFirstChild("GunFired")
    if var434 and var434:IsA("RemoteEvent") then
        gunFiredVisualEvent = var434
        var434.OnClientEvent:Connect(function()
            gunFiredVisualLastAt = os.clock()
        end)
    end
end)
function playGunFiredVisual(arg41, arg42, arg43, hitPart)
    if not arg41 or not arg42 or not arg43 or not gunFiredVisualEvent then
        return
    end
    task.delay(0.045, function()
        if not gunFiredVisualEvent or not gunFiredVisualEvent.Parent then
            return
        end
        if os.clock() - gunFiredVisualLastAt < 0.1 then
            return
        end
        if not arg41.Parent then
            return
        end
        pcall(function()
            firesignal(gunFiredVisualEvent.OnClientEvent, arg41, arg42, arg43, hitPart)
        end)
    end)
end
function fireShotAtTarget(arg44, targetPart)
    if not arg44 or not targetPart or not targetPart.Parent then
        return false
    end
    local var438 = getGunShootRemote(arg44)
    if not var438 then
        return false
    end
    local handle2 = arg44:FindFirstChild("Handle")
    if not handle2 or not handle2:IsA("BasePart") then
        return false
    end
    local parent2 = targetPart.Parent
    local upperTorso = parent2:FindFirstChild("UpperTorso")
    if not upperTorso or not upperTorso:IsA("BasePart") then
        return false
    end
    local position5 = handle2.Position
    local var441 = getAutoShootTargetPoint(parent2)
    if not var441 then
        var441 = upperTorso.Position
    end
    if (var441 - position5).Magnitude < 0.01 then
        return false
    end
    local cFrame2 = CFrame.lookAt(position5, var441)
    local cFrame3 = CFrame.new(var441)
    local var442 = pcall(function()
        var438:FireServer(cFrame2, cFrame3)
    end)
    if var442 then
        autoShootShotCooldownUntil = os.clock() + AUTO_SHOOT_SHOT_COOLDOWN
        PlaySoundAsset(104895925840852, 1)
        playGunFiredVisual(handle2, position5, var441, upperTorso)
    end
    return var442
end
function autoShootFlick(arg45, targetPart)
    if not arg45 or not targetPart or not targetPart.Parent then
        return false
    end
    if autoShootFlickBusy then
        return false
    end
    autoShootFlickBusy = true
    local character26 = localPlayer.Character
    local var443 = character26 and character26:FindFirstChildOfClass("Humanoid")
    local var444 = character26 and character26:FindFirstChild("HumanoidRootPart")
    if not var443 or not var444 then
        autoShootFlickBusy = false
        return false
    end
    local handle3 = arg45:FindFirstChild("Handle")
    local var446 = handle3 and handle3:IsA("BasePart") and handle3.Position or var444.Position
    local var447 = getAutoShootTargetPoint(targetPart.Parent)
    if not var447 then
        autoShootFlickBusy = false
        return false
    end
    local lookVector = var444.CFrame.LookVector
    local var449 = math.atan2(-lookVector.X, -lookVector.Z)
    local vector32 = Vector3.new(var447.X, var444.Position.Y, var447.Z)
    local var450 = vector32 - var444.Position
    if var450.Magnitude <= 0.01 then
        autoShootFlickBusy = false
        return fireShotAtTarget(arg45, targetPart)
    end
    local var451 = math.atan2(-var450.X, -var450.Z)
    local autoRotate = var443.AutoRotate
    local flag9 = false
    local function fn37(duration, fromYaw, toYaw)
        local var452 = os.clock()
        local var453 = math.atan2(math.sin(toYaw - fromYaw), math.cos(toYaw - fromYaw))
        while var444.Parent do
            local var455 = math.clamp((os.clock() - var452) / duration, 0, 1)
            local var456 = 1 - (1 - var455) * (1 - var455)
            local var457 = fromYaw + var453 * var456
            local position6 = var444.Position
            var444.CFrame = CFrame.new(position6) * CFrame.Angles(0, var457, 0)
            if var455 >= 1 then
                break
            end
            task.wait()
        end
    end
    local var461 = pcall(function()
        var443.AutoRotate = false
        if var444.Parent and targetPart.Parent then
            flag9 = fireShotAtTarget(arg45, targetPart)
        end
        if var444.Parent then
            fn37(0.1, var449, var451)
        end
        if var444.Parent then
            local lookVector2 = var444.CFrame.LookVector
            local var460 = math.atan2(-lookVector2.X, -lookVector2.Z)
            fn37(0.1, var460, var449)
        end
    end)
    if var444.Parent then
        local position7 = var444.Position
        var444.CFrame = CFrame.new(position7) * CFrame.Angles(0, var449, 0)
    end
    pcall(function()
        if var443.Parent then
            var443.AutoRotate = autoRotate
        end
    end)
    autoShootFlickBusy = false
    return var461 and flag9
end
function autoShoot()
    if not AutoShootEnabled or os.clock() < autoShootShotCooldownUntil then
        return
    end
    local var466 = getGunForBolong()
    if not var466 then
        return
    end
    local var467, targetPart = getMurdererTargetPart()
    if not var467 or not targetPart then
        return
    end
    local character27 = localPlayer.Character
    local var469 = character27 and character27:FindFirstChild("Gun")
    if not var469 then
        equipTool(var466)
        task.wait(0.01)
        character27 = localPlayer.Character
        var469 = character27 and character27:FindFirstChild("Gun")
    end
    if not var469 then
        return
    end
    if autoShootVariant == "Flick" then
        if autoShootFlick(var469, targetPart) then
            return
        end
        if var469 ~= var466 then
            autoShootFlick(var466, targetPart)
        end
        return
    end
    if fireShotAtTarget(var469, targetPart) then
        return
    end
    if var469 ~= var466 then
        fireShotAtTarget(var466, targetPart)
    end
end
MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "BolongFrutigerPanel"
MobileGui.ResetOnSpawn = false
MobileGui.IgnoreGuiInset = true
MobileGui.DisplayOrder = 10000
pcall(function()
    MobileGui.Parent = localPlayer:WaitForChild("PlayerGui")
end)
MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.BackgroundColor3 = Color3.fromRGB(40, 190, 255)
MainPanel.BackgroundTransparency = 0.77
MainPanel.Position = UDim2.new(0.5, -98.5, 0.5, -24.5)
MainPanel.Size = UDim2.fromOffset(197, 49)
MainPanel.Visible = false
MainPanel.Active = true
MainPanel.Selectable = true
MainPanel.Parent = MobileGui
PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 24)
PanelCorner.Parent = MainPanel
PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(0, 195, 255)
PanelStroke.Thickness = 2
PanelStroke.Transparency = 0.2
PanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
PanelStroke.Parent = MainPanel
ShootLabel = Instance.new("TextLabel")
ShootLabel.Size = UDim2.new(1, 0, 1, 0)
ShootLabel.BackgroundTransparency = 1
ShootLabel.Text = "AUTO SHOOT"
ShootLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ShootLabel.TextSize = PanelScale
ShootLabel.ZIndex = 3
ShootLabel.Active = false
ShootLabel.Selectable = false
ShootLabel.Font = Enum.Font.FredokaOne
ShootLabel.Parent = MainPanel
BubbleContainer = Instance.new("Frame")
BubbleContainer.Name = "Bubbles"
BubbleContainer.Size = UDim2.fromScale(1, 1)
BubbleContainer.BackgroundTransparency = 1
BubbleContainer.ClipsDescendants = true
BubbleContainer.Parent = MainPanel
BubbleData = {
    {x = 0.18, y = 0.72, size = 5, delay = 0, duration = 1.8},
    {x = 0.38, y = 0.84, size = 4, delay = 0.45, duration = 1.6},
    {x = 0.67, y = 0.68, size = 6, delay = 0.9, duration = 1.9},
    {x = 0.84, y = 0.82, size = 4, delay = 1.25, duration = 1.7},
}
for i7, v29 in ipairs(BubbleData) do
    local frame4 = Instance.new("Frame")
    frame4.Name = "Bubble" .. i7
    frame4.Size = UDim2.fromOffset(v29.size, v29.size)
    frame4.Position = UDim2.fromScale(v29.x, v29.y)
    frame4.AnchorPoint = Vector2.new(0.5, 0.5)
    frame4.BackgroundColor3 = Color3.fromRGB(235, 250, 255)
    frame4.BackgroundTransparency = 0.25
    frame4.BorderSizePixel = 0
    frame4.ZIndex = 2
    frame4.Parent = BubbleContainer
    local uICorner4 = Instance.new("UICorner")
    uICorner4.CornerRadius = UDim.new(1, 0)
    uICorner4.Parent = frame4
    task.spawn(function()
        task.wait(v29.delay)
        while frame4.Parent do
            frame4.Position = UDim2.fromScale(v29.x, 0.9)
            frame4.BackgroundTransparency = 0.15
            local var479 = TweenService:Create(frame4, TweenInfo.new(v29.duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(v29.x + 0.025, 0.12), BackgroundTransparency = 0.75})
            var479:Play()
            var479.Completed:Wait()
            task.wait(0.15)
        end
    end)
end
globalVar1, dragInputObject, globalVar2, globalVar3, touchStartTime, dragMoved = false, nil, nil, nil, 0, false
MainPanel.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not globalVar1 then
        uiPanelTouchActive = true
        globalVar1 = true
        dragInputObject = input
        dragMoved = false
        touchStartTime = os.clock()
        globalVar2 = input.Position
        globalVar3 = MainPanel.Position
        PanelStroke.Thickness = 3
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if globalVar1 and input == dragInputObject then
        local var482 = input.Position - globalVar2
        if var482.Magnitude > 5 then
            dragMoved = true
            MainPanel.Position = UDim2.new(globalVar3.X.Scale, globalVar3.X.Offset + var482.X, globalVar3.Y.Scale, globalVar3.Y.Offset + var482.Y)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if globalVar1 and input == dragInputObject then
        globalVar1 = false
        dragInputObject = nil
        uiPanelTouchActive = activeTouchCount > 0
        PanelStroke.Thickness = 2
        if not dragMoved and os.clock() - touchStartTime < 0.7 then
            if AutoShootEnabled then
                PlaySoundAsset(88129339693239, 1)
                autoShoot()
            end
        end
    end
end)
function UpdatePanelScale(value)
    PanelScale = math.clamp(tonumber(value) or 10, 5, 20)
    local var483 = PanelScale / 10
    local var484 = math.clamp(math.floor(197 * var483 + 0.5), 99, 394)
    local var486 = math.clamp(math.floor(49 * var483 + 0.5), 25, 98)
    MainPanel.Size = UDim2.fromOffset(var484, var486)
    ShootLabel.TextSize = math.clamp(math.floor(15 * var483 + 0.5), 10, 30)
end
UpdatePanelScale(10)
InvisibleGui = Instance.new("ScreenGui")
InvisibleGui.Name = "BolongInvisiblePanel"
InvisibleGui.ResetOnSpawn = false
InvisibleGui.IgnoreGuiInset = true
InvisibleGui.DisplayOrder = 10000
pcall(function()
    InvisibleGui.Parent = localPlayer:WaitForChild("PlayerGui")
end)
InvisiblePanel = Instance.new("Frame")
InvisiblePanel.Name = "InvisiblePanel"
InvisiblePanel.BackgroundColor3 = Color3.fromRGB(40, 190, 255)
InvisiblePanel.BackgroundTransparency = 0.77
InvisiblePanel.Position = UDim2.new(0.5, -98.5, 0.5, 35)
InvisiblePanel.Size = UDim2.fromOffset(65, 65)
InvisiblePanel.Visible = false
InvisiblePanel.Active = true
InvisiblePanel.Selectable = true
InvisiblePanel.Parent = InvisibleGui
InvisiblePanelCorner = Instance.new("UICorner")
InvisiblePanelCorner.CornerRadius = UDim.new(0, 10)
InvisiblePanelCorner.Parent = InvisiblePanel
InvisiblePanelStroke = Instance.new("UIStroke")
InvisiblePanelStroke.Color = Color3.fromRGB(0, 195, 255)
InvisiblePanelStroke.Thickness = 2
InvisiblePanelStroke.Transparency = 0.2
InvisiblePanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
InvisiblePanelStroke.Parent = InvisiblePanel
local var495
InvisibleLabel = Instance.new("TextLabel")
InvisibleLabel.Size = UDim2.new(1, 0, 1, 0)
InvisibleLabel.BackgroundTransparency = 1
InvisibleLabel.Text = "INVISIBLE"
InvisibleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InvisibleLabel.TextSize = 11
InvisibleLabel.ZIndex = 3
InvisibleLabel.Active = false
InvisibleLabel.Selectable = false
InvisibleLabel.Font = Enum.Font.FredokaOne
InvisibleLabel.Parent = InvisiblePanel
InvisibleBubbleContainer = Instance.new("Frame")
InvisibleBubbleContainer.Name = "Bubbles"
InvisibleBubbleContainer.Size = UDim2.fromScale(1, 1)
InvisibleBubbleContainer.BackgroundTransparency = 1
InvisibleBubbleContainer.ClipsDescendants = true
InvisibleBubbleContainer.Parent = InvisiblePanel
InvisibleBubbleData = {
    {x = 0.18, y = 0.72, size = 5, delay = 0, duration = 1.8},
    {x = 0.38, y = 0.84, size = 4, delay = 0.45, duration = 1.6},
    {x = 0.67, y = 0.68, size = 6, delay = 0.9, duration = 1.9},
    {x = 0.84, y = 0.82, size = 4, delay = 1.25, duration = 1.7},
}
for i8, v30 in ipairs(InvisibleBubbleData) do
    local frame5 = Instance.new("Frame")
    frame5.Name = "Bubble" .. i8
    frame5.Size = UDim2.fromOffset(v30.size, v30.size)
    frame5.Position = UDim2.fromScale(v30.x, v30.y)
    frame5.AnchorPoint = Vector2.new(0.5, 0.5)
    frame5.BackgroundColor3 = Color3.fromRGB(235, 250, 255)
    frame5.BackgroundTransparency = 0.25
    frame5.BorderSizePixel = 0
    frame5.ZIndex = 2
    frame5.Parent = InvisibleBubbleContainer
    local uICorner5 = Instance.new("UICorner")
    uICorner5.CornerRadius = UDim.new(1, 0)
    uICorner5.Parent = frame5
    task.spawn(function()
        task.wait(v30.delay)
        while frame5.Parent do
            frame5.Position = UDim2.fromScale(v30.x, 0.9)
            frame5.BackgroundTransparency = 0.15
            local var504 = TweenService:Create(frame5, TweenInfo.new(v30.duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(v30.x + 0.025, 0.12), BackgroundTransparency = 0.75})
            var504:Play()
            var504.Completed:Wait()
            task.wait(0.15)
        end
    end)
end
InvisiblePanel.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not invisibleDragging then
        invisibleDragging = true
        invisibleDragInput = input
        invisibleDragMoved = false
        invisibleTouchStartTime = os.clock()
        invisibleDragStart = input.Position
        invisibleStartPos = InvisiblePanel.Position
        InvisiblePanelStroke.Thickness = 3
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if invisibleDragging and input == invisibleDragInput then
        local var505 = input.Position - invisibleDragStart
        if var505.Magnitude > 5 then
            invisibleDragMoved = true
            InvisiblePanel.Position = UDim2.new(invisibleStartPos.X.Scale, invisibleStartPos.X.Offset + var505.X, invisibleStartPos.Y.Scale, invisibleStartPos.Y.Offset + var505.Y)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if invisibleDragging and input == invisibleDragInput then
        invisibleDragging = false
        invisibleDragInput = nil
        InvisiblePanelStroke.Thickness = 2
        if not invisibleDragMoved and os.clock() - invisibleTouchStartTime < 0.7 then
            var495(not invisibleEnabled)
        end
    end
end)
AimbotGui = Instance.new("ScreenGui")
AimbotGui.Name = "BolongAimbotPanel"
AimbotGui.ResetOnSpawn = false
AimbotGui.Parent = PlayerGui
AimbotPanel = Instance.new("Frame")
AimbotPanel.Name = "AimbotPanel"
AimbotPanel.AnchorPoint = Vector2.new(0.5, 0.5)
AimbotPanel.BackgroundColor3 = Color3.fromRGB(205, 245, 255)
AimbotPanel.BackgroundTransparency = 0.75
AimbotPanel.Position = UDim2.fromScale(0.5, 0.5)
AimbotPanel.Size = UDim2.fromOffset(80, 80)
AimbotPanel.Visible = false
AimbotPanel.Active = true
AimbotPanel.Selectable = true
AimbotPanel.Parent = AimbotGui
AimbotCorner = Instance.new("UICorner")
AimbotCorner.CornerRadius = UDim.new(0, 10)
AimbotCorner.Parent = AimbotPanel
AimbotStroke = Instance.new("UIStroke")
AimbotStroke.Color = Color3.fromRGB(0, 170, 255)
AimbotStroke.Thickness = 2
AimbotStroke.Transparency = 0.15
AimbotStroke.Parent = AimbotPanel
AimbotIcon = Instance.new("ImageLabel")
AimbotIcon.Name = "AimlockIcon"
AimbotIcon.AnchorPoint = Vector2.new(0.5, 0.5)
AimbotIcon.Position = UDim2.fromScale(0.5, 0.38)
AimbotIcon.Size = UDim2.fromOffset(50, 50)
AimbotIcon.BackgroundTransparency = 1
AimbotIcon.Image = "rbxassetid://78275912674145"
AimbotIcon.ImageTransparency = 0
AimbotIcon.ScaleType = Enum.ScaleType.Fit
AimbotIcon.ZIndex = 4
AimbotIcon.Active = false
AimbotIcon.Parent = AimbotPanel
AimbotLabel = Instance.new("TextLabel")
AimbotLabel.AnchorPoint = Vector2.new(0.5, 0.5)
AimbotLabel.Position = UDim2.fromScale(0.5, 0.78)
AimbotLabel.Size = UDim2.fromScale(0.9, 0.25)
AimbotLabel.BackgroundTransparency = 1
AimbotLabel.Text = "AIMLOCK"
AimbotLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotLabel.TextSize = 12
AimbotLabel.TextScaled = false
AimbotLabel.TextWrapped = false
AimbotLabel.Font = Enum.Font.GothamBold
AimbotLabel.TextXAlignment = Enum.TextXAlignment.Center
AimbotLabel.TextYAlignment = Enum.TextYAlignment.Center
AimbotLabel.Active = false
AimbotLabel.Selectable = false
AimbotLabel.ZIndex = 4
AimbotLabel.Parent = AimbotPanel
task.spawn(function()
    while AimbotIcon and AimbotIcon.Parent do
        AimbotIcon.Rotation = AimbotIcon.Rotation + 2.5
        task.wait(0.02)
    end
end)
AimbotBubbleContainer = Instance.new("Frame")
AimbotBubbleContainer.Name = "Bubbles"
AimbotBubbleContainer.Size = UDim2.fromScale(1, 1)
AimbotBubbleContainer.BackgroundTransparency = 1
AimbotBubbleContainer.ClipsDescendants = true
AimbotBubbleContainer.ZIndex = 2
AimbotBubbleContainer.Parent = AimbotPanel
AimbotBubbleData = {
    {x = 0.25, size = 5, delay = 0, duration = 1.55},
    {x = 0.5, size = 4, delay = 0.52, duration = 1.75},
    {x = 0.74, size = 6, delay = 0.95, duration = 1.65},
}
for i9, v31 in ipairs(AimbotBubbleData) do
    local frame6 = Instance.new("Frame")
    frame6.Name = "Bubble" .. i9
    frame6.Size = UDim2.fromOffset(v31.size, v31.size)
    frame6.Position = UDim2.fromScale(v31.x, 0.92)
    frame6.AnchorPoint = Vector2.new(0.5, 0.5)
    frame6.BackgroundColor3 = Color3.fromRGB(235, 250, 255)
    frame6.BackgroundTransparency = 0.18
    frame6.BorderSizePixel = 0
    frame6.ZIndex = 2
    frame6.Parent = AimbotBubbleContainer
    local uICorner6 = Instance.new("UICorner")
    uICorner6.CornerRadius = UDim.new(1, 0)
    uICorner6.Parent = frame6
    task.spawn(function()
        task.wait(v31.delay)
        while frame6.Parent do
            frame6.Position = UDim2.fromScale(v31.x, 0.92)
            frame6.BackgroundTransparency = 0.18
            local var521 = TweenService:Create(frame6, TweenInfo.new(v31.duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(v31.x + 0.02, 0.12), BackgroundTransparency = 0.78})
            var521:Play()
            var521.Completed:Wait()
            task.wait(0.12)
        end
    end)
end
AimbotCircleGui = Instance.new("ScreenGui")
AimbotCircleGui.Name = "BolongAimbotFOV"
AimbotCircleGui.ResetOnSpawn = false
AimbotCircleGui.IgnoreGuiInset = true
AimbotCircleGui.DisplayOrder = 10001
AimbotCircleGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
AimbotCircleGui.Enabled = true
AimbotCircleGui.Parent = PlayerGui
AimbotCircle = Instance.new("Frame")
AimbotCircle.Name = "FOVWater"
AimbotCircle.AnchorPoint = Vector2.new(0.5, 0.5)
AimbotCircle.Position = UDim2.fromScale(0.5, 0.5)
AimbotCircle.BackgroundTransparency = 1
AimbotCircle.Visible = false
AimbotCircle.Parent = AimbotCircleGui
CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = AimbotCircle
CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(70, 190, 255)
CircleStroke.Thickness = 3
CircleStroke.Transparency = 0.08
CircleStroke.Parent = AimbotCircle
function UpdateAimbotVisuals()
    AimbotCircle.Visible = false
    CircleStroke.Transparency = 1
    AimbotPanel.Visible = aimbotActive
end
aimDragging, aimDragInput, aimDragStart, aimStartPos = false, nil, nil, nil
aimPressStart = nil
aimWasDragged = false
AimbotPanel.InputBegan:Connect(function(input)
    if aimDragging then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        uiPanelTouchActive = true
        aimDragging = true
        aimDragInput = input
        aimDragStart = input.Position
        aimPressStart = input.Position
        aimWasDragged = false
        aimStartPos = AimbotPanel.Position
        AimbotStroke.Thickness = 3
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if aimDragging and input == aimDragInput then
        local var524 = input.Position - aimDragStart
        if var524.Magnitude > 6 then
            aimWasDragged = true
        end
        AimbotPanel.Position = UDim2.new(aimStartPos.X.Scale, aimStartPos.X.Offset + var524.X, aimStartPos.Y.Scale, aimStartPos.Y.Offset + var524.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if aimDragging and input == aimDragInput then
        aimDragging = false
        aimDragInput = nil
        uiPanelTouchActive = activeTouchCount > 0
        AimbotStroke.Thickness = 2
        if not aimWasDragged and aimPressStart then
            PlaySoundAsset(111044884172919, 1)
            aimlockEngaged = not aimlockEngaged
            aimbotFOVVisible = aimlockEngaged
            if not aimlockEngaged then
                clearAimlockTarget()
            end
            UpdateAimbotVisuals()
        end
        aimPressStart = nil
        aimWasDragged = false
    end
end)
function UpdateAimbotPanelScale(value)
    AimbotPanelScale = math.clamp(tonumber(value) or 8, 6, 16)
    local var525 = AimbotPanelScale * 10
    AimbotPanel.Size = UDim2.fromOffset(var525, var525)
    AimbotLabel.Size = UDim2.fromScale(0.9, 0.9)
    AimbotLabel.TextSize = math.clamp(AimbotPanelScale * 1.25, 10, 18)
    local var526 = math.clamp(AimbotPanelScale * 6, 34, 52)
    AimbotIcon.Size = UDim2.fromOffset(var526, var526)
end
UpdateAimbotPanelScale(AimbotPanelScale)
aimbotFOV = 30
aimbotFOVVisible = false
aimlockEngaged = false
UpdateAimbotVisuals()
function isPlayerAlive(player10)
    local var528 = player10 and player10.Character
    local var530 = var528 and var528:FindFirstChildOfClass("Humanoid")
    return var530 and var530.Health > 0
end
function killTarget(player11)
    local var531 = getKnife()
    if not var531 then
        return false
    end
    local character28 = localPlayer.Character
    local var532 = character28 and character28:FindFirstChild("HumanoidRootPart")
    local var533 = player11 and player11.Character
    local var534 = var533 and var533:FindFirstChild("HumanoidRootPart")
    if not var532 or not var534 or not isPlayerAlive(player11) then
        return false
    end
    if (var532.Position - var534.Position).Magnitude > 300 then
        return false
    end
    equipTool(var531)
    local vector33 = Vector3.new(var534.Position.X, var532.Position.Y, var534.Position.Z)
    if (vector33 - var532.Position).Magnitude > 0.01 then
        var532.CFrame = CFrame.lookAt(var532.Position, vector33)
    end
    pcall(function()
        var531:Activate()
    end)
    return true
end
function killAll()
    local var538 = localPlayer
    if not var538 then
        return false
    end
    local character29 = var538.Character
    if not character29 then
        return false
    end
    local knife = character29:FindFirstChild("Knife")
    if not knife then
        return false
    end
    local events = knife:FindFirstChild("Events")
    if not events then
        return false
    end
    local handleTouched = events:FindFirstChild("HandleTouched")
    if not handleTouched or not handleTouched:IsA("RemoteEvent") then
        return false
    end
    local flag10 = false
    for _, v32 in ipairs(Players:GetPlayers()) do
        if v32 ~= var538 and v32.Character then
            local humanoidRootPart3 = v32.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart3 then
                local var541 = pcall(function()
                    handleTouched:FireServer(humanoidRootPart3)
                end)
                if var541 then
                    flag10 = true
                end
                task.wait(0.05)
            end
        end
    end
    return flag10
end
function killSheriff()
    for _, v33 in ipairs(Players:GetPlayers()) do
        if v33 ~= localPlayer and getRole(v33) == "Sheriff" and v33.Character then
            killTarget(v33)
            break
        end
    end
end
task.spawn(function()
    while task.wait(0.1) do
        if killAuraActive and getRole(localPlayer) == "Murderer" and not autoFarmActive then
            local var543 = getKnife()
            local character30 = localPlayer.Character
            local var544 = character30 and character30:FindFirstChild("HumanoidRootPart")
            if var543 and var544 then
                equipTool(var543)
                for _, v34 in ipairs(Players:GetPlayers()) do
                    if v34 ~= localPlayer and v34.Character then
                        local humanoidRootPart4 = v34.Character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart4 and (var544.Position - humanoidRootPart4.Position).Magnitude <= killAuraDistance then
                            pcall(function()
                                var543:Activate()
                            end)
                        end
                    end
                end
            end
        end
    end
end)
local flag11 = false
local var545 = nil
local var546 = nil
local var547 = nil
local function fn38()
    local var548 = localPlayer
    local fn39 = function()
        local var550, var551, vel, movel = nil, nil, nil, 0.1
        while flag11 do
            RunService.Heartbeat:Wait()
            var550 = var548.Character
            var551 = var550 and var550:FindFirstChild("HumanoidRootPart")
            if var551 then
                vel = var551.Velocity
                pcall(function()
                    var551.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                end)
                RunService.RenderStepped:Wait()
                if not flag11 or not var551.Parent then
                    break
                end
                pcall(function()
                    var551.Velocity = vel
                end)
                RunService.Stepped:Wait()
                if not flag11 or not var551.Parent then
                    break
                end
                pcall(function()
                    var551.Velocity = vel + Vector3.new(0, movel, 0)
                end)
                movel = -movel
            end
        end
    end
    fn39()
end
local function fn40()
    local var557 = var547
    local var558 = var546
    if not var557 or not var558 then
        var546 = nil
        var547 = nil
        return
    end
    local humanoidRootPart5 = var557:FindFirstChild("HumanoidRootPart")
    local humanoid6 = var557:FindFirstChildOfClass("Humanoid")
    if humanoidRootPart5 and humanoidRootPart5.Parent then
        pcall(function()
            humanoidRootPart5.CFrame = var558
            humanoidRootPart5.AssemblyLinearVelocity = Vector3.zero
            humanoidRootPart5.AssemblyAngularVelocity = Vector3.zero
            humanoidRootPart5.Velocity = Vector3.zero
            humanoidRootPart5.RotVelocity = Vector3.zero
        end)
        if var557.PrimaryPart then
            pcall(function()
                var557:SetPrimaryPartCFrame(var558)
            end)
        end
        if humanoid6 then
            pcall(function()
                humanoid6:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    end
    var546 = nil
    var547 = nil
end
function SetTouchFling(enabled)
    local var561 = enabled == true
    if var561 then
        if not var546 then
            local character31 = localPlayer.Character
            local var562 = character31 and character31:FindFirstChild("HumanoidRootPart")
            if var562 then
                var546 = var562.CFrame
                var547 = character31
            end
        end
        flag11 = true
        if not var545 or coroutine.status(var545) == "dead" then
            var545 = coroutine.create(fn38)
            coroutine.resume(var545)
        end
    else
        flag11 = false
        var545 = nil
        fn40()
    end
end
localPlayer.CharacterAdded:Connect(function(character32)
    if flag11 then
        task.defer(function()
            character32:WaitForChild("HumanoidRootPart", 5)
        end)
    end
end)
function FindPlayerByRole(arg46)
    for _, v35 in ipairs(Players:GetPlayers()) do
        if v35 ~= localPlayer and GetPlayerRoleMM2(v35) == arg46 then
            return v35
        end
    end
    return nil
end
function PlayMiscEmote(arg47)
    if not arg47 or arg47 == "" then
        return
    end
    local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
    local remotes3 = ReplicatedStorage3:FindFirstChild("Remotes")
    local var569 = remotes3 and remotes3:FindFirstChild("PlayEmote")
    if not var569 then
        var569 = ReplicatedStorage3:FindFirstChild("PlayEmote", true)
    end
    if var569 then
        pcall(function()
            if var569:IsA("RemoteEvent") then
                var569:FireServer(arg47)
            elseif var569:IsA("BindableEvent") then
                var569:Fire(arg47)
            end
        end)
    end
end
antiFlingEnabled = false
antiFlingConnection = nil
function SetAntiFling(enabled)
    antiFlingEnabled = enabled == true
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    if not antiFlingEnabled then
        return
    end
    antiFlingConnection = RunService.Heartbeat:Connect(function()
        for _, v36 in ipairs(Players:GetPlayers()) do
            if v36 ~= localPlayer and v36.Character then
                local humanoidRootPart6 = v36.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart6 and humanoidRootPart6.AssemblyLinearVelocity.Magnitude > 250 then
                    pcall(function()
                        humanoidRootPart6.AssemblyLinearVelocity = Vector3.zero
                        humanoidRootPart6.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
            end
        end
    end)
end
PickupGui = Instance.new("ScreenGui")
PickupGui.Name = "BolongPickupPanel"
PickupGui.ResetOnSpawn = false
PickupGui.IgnoreGuiInset = true
PickupGui.Parent = PlayerGui
PickupPanel = Instance.new("Frame")
PickupPanel.Name = "PickupPanel"
PickupPanel.AnchorPoint = Vector2.new(0.5, 0.5)
PickupPanel.Position = UDim2.fromScale(0.5, 0.68)
PickupPanel.Size = UDim2.fromOffset(72, 72)
PickupPanel.BackgroundColor3 = Color3.fromRGB(40, 190, 255)
PickupPanel.BackgroundTransparency = 0.77
PickupPanel.Visible = false
PickupPanel.Active = true
PickupPanel.Parent = PickupGui
PickupCorner = Instance.new("UICorner")
PickupCorner.CornerRadius = UDim.new(1, 0)
PickupCorner.Parent = PickupPanel
PickupStroke = Instance.new("UIStroke")
PickupStroke.Color = Color3.fromRGB(0, 170, 255)
PickupStroke.Thickness = 2
PickupStroke.Transparency = 0.08
PickupStroke.Parent = PickupPanel
PickupLabel = Instance.new("TextLabel")
PickupLabel.Size = UDim2.fromScale(0.88, 0.88)
PickupLabel.Position = UDim2.fromScale(0.06, 0.06)
PickupLabel.BackgroundTransparency = 1
PickupLabel.Text = "PICK UP GUN"
PickupLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PickupLabel.TextSize = 11
PickupLabel.Font = Enum.Font.GothamBold
PickupLabel.TextWrapped = true
PickupLabel.Active = false
PickupLabel.Selectable = false
PickupLabel.Parent = PickupPanel
pickupDragging, pickupDragInput, pickupDragStart, pickupStartPos = false, nil, nil, nil
pickupDragMoved = false
pickupPressStart = 0
local function fn41()
    if not autoPickupGunActive then
        return
    end
    PlaySoundAsset(402143943, 1)
    local var578 = getGunDrop()
    local character33 = localPlayer.Character
    local var579 = character33 and character33:FindFirstChild("HumanoidRootPart")
    if not var578 or not var579 then
        return
    end
    local cFrame4 = var579.CFrame
    pcall(function()
        var579.CFrame = var578.CFrame
    end)
    if type(firetouchinterest) == "function" then
        pcall(function()
            firetouchinterest(var579, var578, 0)
            firetouchinterest(var579, var578, 1)
        end)
    end
    task.wait(0.001)
    if var579.Parent then
        pcall(function()
            var579.CFrame = cFrame4
            var579.AssemblyLinearVelocity = Vector3.zero
            var579.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end
PickupPanel.InputBegan:Connect(function(input)
    if pickupDragging then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        pickupPanelInteracting = true
        uiPanelTouchActive = true
        pickupDragging = true
        pickupDragMoved = false
        pickupPressStart = os.clock()
        pickupDragInput = input
        pickupDragStart = input.Position
        pickupStartPos = PickupPanel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if pickupDragging and input == pickupDragInput then
        local var581 = input.Position - pickupDragStart
        if var581.Magnitude > 6 then
            pickupDragMoved = true
        end
        PickupPanel.Position = UDim2.new(pickupStartPos.X.Scale, pickupStartPos.X.Offset + var581.X, pickupStartPos.Y.Scale, pickupStartPos.Y.Offset + var581.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if pickupDragging and input == pickupDragInput then
        pickupDragging = false
        pickupDragInput = nil
        pickupPanelInteracting = false
        uiPanelTouchActive = activeTouchCount > 0
        if not pickupDragMoved and os.clock() - pickupPressStart < 0.45 then
            fn41()
        end
    end
end)
function UpdatePickupPanelScale(value)
    local var584 = math.clamp(tonumber(value) or 10, 5, 20)
    local var585 = math.clamp(var584 * 5.5, 40, 110)
    PickupPanel.Size = UDim2.fromOffset(var585, var585)
    PickupLabel.TextSize = math.clamp(var584 * 0.8, 7, 16)
end
UpdatePickupPanelScale(8)
autoThrowKnifeEnabled = false
autoThrowCycle = 0
autoThrowAnimationConnection = nil
autoThrowCharacterConnection = nil
autoThrowLastWindupAt = 0
AUTO_THROW_FOV_DOT = 0.75
AUTO_THROW_WINDUP_ID = "1957618848"
AUTO_THROW_READY_ID = "15478370930"
AUTO_THROW_SWING_ID = "112035104498952"
function getKnifeThrownEvent()
    local character34 = localPlayer.Character
    if not character34 then
        return nil, nil
    end
    local knife2 = character34:FindFirstChild("Knife")
    local var591 = knife2 and knife2:FindFirstChild("Events")
    local var592 = var591 and var591:FindFirstChild("KnifeThrown")
    if var592 and var592:IsA("RemoteEvent") then
        return var592, knife2
    end
    return nil, knife2
end
function getAutoThrowSilentTarget()
    local currentCamera = Workspace.CurrentCamera
    local character35 = localPlayer.Character
    if not currentCamera or not character35 then
        return nil
    end
    local var594 = character35:FindFirstChild("HumanoidRootPart") or character35:FindFirstChild("UpperTorso") or character35:FindFirstChild("Torso")
    if not var594 then
        return nil
    end
    local position8 = var594.Position
    local lookVector3 = currentCamera.CFrame.LookVector
    local flag12 = false
    local var595 = pcall(function()
        flag12 = isFakeBombMouseLockOn()
    end)
    if var595 and flag12 then
        local lookVector4 = var594.CFrame.LookVector
        if lookVector4.Magnitude > 0.001 then
            lookVector3 = lookVector4
        end
        if currentCamera then
            local lookVector5 = currentCamera.CFrame.LookVector
            if lookVector5.Magnitude > 0.001 and lookVector5:Dot(lookVector3) < 0.5 then
                lookVector3 = lookVector5
            end
        end
    end
    local var598 = AUTO_THROW_FOV_DOT
    if flag12 then
        var598 = 0.2
    end
    local var601 = nil
    local var602 = -math.huge
    local huge2 = math.huge
    for _, v37 in ipairs(Players:GetPlayers()) do
        if v37 ~= localPlayer and v37.Character then
            local var603 = GetPlayerRoleMM2(v37)
            if var603 == "Innocent" or var603 == "Sheriff" or var603 == "Hero" then
                local character36 = v37.Character
                local humanoid7 = character36:FindFirstChildOfClass("Humanoid")
                local targetPart = character36:FindFirstChild("HumanoidRootPart") or character36:FindFirstChild("UpperTorso") or character36:FindFirstChild("Torso")
                if humanoid7 and humanoid7.Health > 0 and targetPart and targetPart:IsA("BasePart") then
                    local var606 = targetPart.Position - position8
                    local magnitude5 = var606.Magnitude
                    if magnitude5 > 0.05 and magnitude5 < 60 then
                        local unit = var606.Unit
                        local var609 = lookVector3:Dot(unit)
                        if var609 >= var598 then
                            local var610 = var609 * 1000 - magnitude5
                            if var610 > var602 then
                                var602 = var610
                                var601 = targetPart
                            end
                        elseif flag12 and magnitude5 < huge2 then
                            huge2 = magnitude5
                            var601 = targetPart
                        end
                    end
                end
            end
        end
    end
    if not var601 and flag12 then
        local huge3 = math.huge
        for _, v38 in ipairs(Players:GetPlayers()) do
            if v38 ~= localPlayer and v38.Character then
                local var611 = GetPlayerRoleMM2(v38)
                if var611 == "Innocent" or var611 == "Sheriff" or var611 == "Hero" then
                    local character37 = v38.Character
                    local humanoid8 = character37:FindFirstChildOfClass("Humanoid")
                    local targetPart = character37:FindFirstChild("HumanoidRootPart") or character37:FindFirstChild("UpperTorso") or character37:FindFirstChild("Torso")
                    if humanoid8 and humanoid8.Health > 0 and targetPart and targetPart:IsA("BasePart") then
                        local magnitude6 = (targetPart.Position - position8).Magnitude
                        if magnitude6 > 0.05 and magnitude6 < 60 and magnitude6 < huge3 then
                            huge3 = magnitude6
                            var601 = targetPart
                        end
                    end
                end
            end
        end
    end
    return var601
end
function fireKnifeThrowAtTarget(targetPart)
    if not targetPart or not targetPart.Parent then
        return false
    end
    local var616, var617 = getKnifeThrownEvent()
    if not var616 or not var617 then
        return false
    end
    local handle4 = var617:FindFirstChild("Handle")
    local character38 = localPlayer.Character
    local var620 = handle4 or character38 and character38:FindFirstChild("HumanoidRootPart") or character38 and character38:FindFirstChild("UpperTorso") or character38 and character38:FindFirstChild("Torso")
    if not var620 or not var620:IsA("BasePart") then
        return false
    end
    local position9 = targetPart.Position
    local cFrame5 = CFrame.lookAt(var620.Position, position9)
    local cFrame6 = CFrame.new(position9)
    local var621 = pcall(function()
        var616:FireServer(cFrame5, cFrame6)
    end)
    return var621
end
function getAnimationId(track)
    if not track then
        return ""
    end
    local animation = track.Animation
    if not animation then
        return ""
    end
    local var624 = tostring(animation.AnimationId or "")
    return var624:match("(%d+)$") or var624
end
function handleKnifeAnimation(track)
    if not autoThrowKnifeEnabled or not track then
        return
    end
    local character39 = localPlayer.Character
    if not character39 or not character39:FindFirstChild("Knife") then
        return
    end
    local var627 = getAnimationId(track)
    if var627 == AUTO_THROW_WINDUP_ID then
        autoThrowLastWindupAt = os.clock()
        do
            local flag13 = false
            pcall(function()
                flag13 = isFakeBombMouseLockOn()
            end)
            if flag13 then
                task.defer(function()
                    local var628 = getAutoThrowSilentTarget()
                    if var628 then
                        fireKnifeThrowAtTarget(var628)
                    end
                end)
            end
        end
        return
    end
    if var627 ~= AUTO_THROW_READY_ID then
        return
    end
    local flag14 = false
    pcall(function()
        flag14 = isFakeBombMouseLockOn()
    end)
    local num4 = 2
    if flag14 then
        num4 = 4
    end
    if os.clock() - autoThrowLastWindupAt > num4 and not flag14 then
        return
    end
    if flag14 and os.clock() - autoThrowLastWindupAt > 5 then
        return
    end
    autoThrowLastWindupAt = 0
    local var633 = getAutoThrowSilentTarget()
    if var633 then
        fireKnifeThrowAtTarget(var633)
    end
end
function disconnectAutoThrowAnimationConnections()
    if autoThrowAnimationConnection then
        pcall(function()
            autoThrowAnimationConnection:Disconnect()
        end)
        autoThrowAnimationConnection = nil
    end
    if autoThrowCharacterConnection then
        pcall(function()
            autoThrowCharacterConnection:Disconnect()
        end)
        autoThrowCharacterConnection = nil
    end
end
function watchKnifeAnimations(character40)
    if not character40 then
        return
    end
    local humanoid9 = character40:FindFirstChildOfClass("Humanoid")
    if not humanoid9 then
        humanoid9 = character40:WaitForChild("Humanoid", 5)
    end
    if not humanoid9 then
        return
    end
    if autoThrowAnimationConnection then
        pcall(function()
            autoThrowAnimationConnection:Disconnect()
        end)
    end
    autoThrowAnimationConnection = humanoid9.AnimationPlayed:Connect(function(track)
        handleKnifeAnimation(track)
    end)
end
function disableAutoThrowKnife()
    autoThrowKnifeEnabled = false
    autoThrowCycle = autoThrowCycle + 1
    autoThrowLastWindupAt = 0
    disconnectAutoThrowAnimationConnections()
end
function enableAutoThrowKnife()
    disableAutoThrowKnife()
    autoThrowKnifeEnabled = true
    autoThrowCycle = autoThrowCycle + 1
    watchKnifeAnimations(localPlayer.Character)
    autoThrowCharacterConnection = localPlayer.CharacterAdded:Connect(function(arg48)
        if autoThrowKnifeEnabled then
            task.defer(function()
                watchKnifeAnimations(arg48)
            end)
        end
    end)
end
function disconnectFakeBombTool(arg49)
    local var642 = fakeBombToolConnections[arg49]
    if var642 then
        pcall(function()
            var642:Disconnect()
        end)
        fakeBombToolConnections[arg49] = nil
    end
end
function disconnectAllFakeBombTools()
    for k6, v39 in pairs(fakeBombToolConnections) do
        if v39 then
            pcall(function()
                v39:Disconnect()
            end)
        end
        fakeBombToolConnections[k6] = nil
    end
end
function getFakeBombTool()
    local character41 = localPlayer.Character
    local backpack6 = localPlayer:FindFirstChildOfClass("Backpack")
    local var644 = character41 and character41:FindFirstChild("FakeBomb")
    if var644 and var644:IsA("Tool") then
        return var644
    end
    var644 = backpack6 and backpack6:FindFirstChild("FakeBomb")
    if var644 and var644:IsA("Tool") then
        return var644
    end
    return nil
end
function isFakeBombMouseLockOn()
    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        return true
    end
    return fakeBombMouseLockActive == true
end
function getFakeBombFreeAimCFrame()
    local currentCamera2 = Workspace.CurrentCamera
    if not currentCamera2 then
        return nil
    end
    if not UserInputService.TouchEnabled or UserInputService.MouseEnabled then
        local var647 = localPlayer:GetMouse()
        local var649 = nil
        local var650 = pcall(function()
            var649 = var647.Hit
        end)
        if var650 and typeof(var649) == "CFrame" then
            return var649
        end
    end
    local var651 = fakeBombLastPointer
    if not var651 then
        var651 = UserInputService:GetMouseLocation()
    end
    local var655 = currentCamera2:ViewportPointToRay(var651.X, var651.Y)
    local position10 = currentCamera2.CFrame.Position
    return CFrame.lookAt(position10 + var655.Direction * 50, position10 + var655.Direction * 51)
end
function getFakeBombMouseLockCFrame()
    local currentCamera3 = Workspace.CurrentCamera
    if not currentCamera3 then
        return nil
    end
    local character42 = localPlayer.Character
    local var656 = character42 and character42:FindFirstChild("HumanoidRootPart")
    local var657 = var656 and var656.Position or currentCamera3.CFrame.Position
    local lookVector6 = currentCamera3.CFrame.LookVector
    if lookVector6.Magnitude <= 0.001 then
        return nil
    end
    lookVector6 = lookVector6.Unit
    local var658 = var657 + lookVector6 * 50
    return CFrame.lookAt(var658, var658 + lookVector6)
end
function getFakeBombThrowCFrame()
    if isFakeBombMouseLockOn() then
        return getFakeBombMouseLockCFrame()
    end
    return getFakeBombFreeAimCFrame()
end
function triggerFakeBombRemotes()
    local remotes4 = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    local var661 = remotes4 and remotes4:FindFirstChild("Extras")
    local var662 = var661 and var661:FindFirstChild("ReplicateToy")
    if var662 and var662:IsA("RemoteFunction") then
        pcall(function()
            var662:InvokeServer("FakeBomb")
        end)
    end
    local var664 = remotes4 and remotes4:FindFirstChild("Misc")
    local var665 = var664 and var664:FindFirstChild("PlayEmote")
    if var665 then
        pcall(function()
            if var665:IsA("RemoteEvent") then
                var665:Fire("FakeBomb")
            elseif var665:IsA("BindableEvent") then
                var665:Fire("FakeBomb")
            end
        end)
    end
end
function fireFakeBombThrow()
    if not fakeBombJumpEnabled or not fakeBombJumpReady then
        return false
    end
    local character43 = localPlayer.Character
    if not character43 then
        return false
    end
    local humanoidRootPart7 = character43:FindFirstChild("HumanoidRootPart")
    local humanoid10 = character43:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart7 or not humanoid10 then
        return false
    end
    local fakeBomb = character43:FindFirstChild("FakeBomb")
    if not fakeBomb then
        return false
    end
    local remote = fakeBomb:FindFirstChild("Remote")
    if not remote or not remote:IsA("RemoteEvent") then
        return false
    end
    fakeBombJumpReady = false
    fakeBombCooldownUntil = os.clock() + fakeBombCooldownTime
    local var669 = humanoidRootPart7.Position - Vector3.new(0, 3.15, 0)
    pcall(function()
        remote:FireServer(CFrame.new(var669), 50)
    end)
    if fakeBombVariant == "Auto" and fakeBombAutoJumpEnabled then
        task.wait(0.06)
        if humanoid10.Parent then
            fakeBombScreenTouchSuppress = true
            humanoid10:ChangeState(Enum.HumanoidStateType.Jumping)
            humanoid10.Jump = true
            task.delay(0.25, function()
                fakeBombScreenTouchSuppress = false
            end)
        end
    end
    task.spawn(function()
        while fakeBombJumpEnabled and os.clock() < fakeBombCooldownUntil do
            local var671 = math.max(0, fakeBombCooldownUntil - os.clock())
            if FakeBombJumpLabel and FakeBombJumpLabel.Parent then
                FakeBombJumpLabel.Text = tostring(math.ceil(var671))
            end
            task.wait(1)
        end
        if fakeBombJumpEnabled then
            fakeBombJumpReady = true
            if FakeBombJumpLabel and FakeBombJumpLabel.Parent then
                FakeBombJumpLabel.Text = "Ready"
            end
        end
    end)
    return true
end
function onFakeBombManualScreenTap(input)
    if fakeBombVariant ~= "Manual" then
        return
    end
    if not fakeBombJumpEnabled or fakeBombScreenTouchSuppress then
        return
    end
    if input and input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end
    local character44 = localPlayer.Character
    local var673 = character44 and character44:FindFirstChildOfClass("Humanoid")
    local var675 = character44 and character44:FindFirstChild("FakeBomb")
    if not var673 or not var675 or not var675:IsA("Tool") then
        return
    end
    local var676 = var673:GetState()
    if var676 ~= Enum.HumanoidStateType.Jumping and var676 ~= Enum.HumanoidStateType.Freefall and var676 ~= Enum.HumanoidStateType.FallingDown then
        return
    end
    fireFakeBombThrow()
end
function setupFakeBombScreenTouchHumanoid(arg50)
    if fakeBombScreenTouchJumpConnection then
        pcall(function()
            fakeBombScreenTouchJumpConnection:Disconnect()
        end)
        fakeBombScreenTouchJumpConnection = nil
    end
end
function setupFakeBombManualInput()
    if fakeBombManualInputConnection then
        pcall(function()
            fakeBombManualInputConnection:Disconnect()
        end)
        fakeBombManualInputConnection = nil
    end
    fakeBombManualInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        onFakeBombManualScreenTap(input)
    end)
end
function updateFakeBombJumpPanelScale(value)
    local var682 = math.clamp(tonumber(value) or 10, 6, 20)
    local size = math.floor(60 + (var682 - 6) / 14 * 95 + 0.5)
    size = math.clamp(size, 60, 155)
    if FakeBombJumpPanel then
        FakeBombJumpPanel.Size = UDim2.fromOffset(size, size)
    end
    if FakeBombJumpLabel then
        FakeBombJumpLabel.TextSize = math.clamp(math.floor(size * 0.23), 16, 34)
    end
end
function ensureFakeBombJumpPanel()
    if FakeBombJumpPanel and FakeBombJumpPanel.Parent then
        return
    end
    local gui = PlayerGui:FindFirstChild("BolongFakeBombJump")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "BolongFakeBombJump"
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 10001
        gui.Parent = PlayerGui
    end
    local panel = Instance.new("Frame")
    panel.Name = "FakeBombJumpPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.72)
    panel.Size = UDim2.fromOffset(100, 100)
    panel.BackgroundColor3 = Color3.fromRGB(72, 200, 255)
    panel.BackgroundTransparency = 0.77
    panel.BorderSizePixel = 0
    panel.Active = true
    panel.Parent = gui
    local uICorner7 = Instance.new("UICorner")
    uICorner7.CornerRadius = UDim.new(0, 16)
    uICorner7.Parent = panel
    local uIStroke3 = Instance.new("UIStroke")
    uIStroke3.Color = Color3.fromRGB(120, 225, 255)
    uIStroke3.Thickness = 2
    uIStroke3.Transparency = 0.15
    uIStroke3.Parent = panel
    local label = Instance.new("TextLabel")
    label.Name = "Status"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "Ready"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 23
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Active = false
    label.Selectable = false
    label.ZIndex = 3
    label.Parent = panel
    FakeBombJumpPanel = panel
    FakeBombJumpLabel = label
    panel.InputBegan:Connect(function(input)
        if fakeBombPanelDragging then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        uiPanelTouchActive = true
        fakeBombPanelDragging = true
        fakeBombPanelDragInput = input
        fakeBombPanelDragStart = input.Position
        fakeBombPanelStartPos = panel.Position
        fakeBombPanelDragMoved = false
        fakeBombPanelTouchStart = os.clock()
        uIStroke3.Thickness = 3
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not fakeBombPanelDragging or input ~= fakeBombPanelDragInput then
            return
        end
        local var691 = input.Position - fakeBombPanelDragStart
        if var691.Magnitude > 6 then
            fakeBombPanelDragMoved = true
        end
        panel.Position = UDim2.new(fakeBombPanelStartPos.X.Scale, fakeBombPanelStartPos.X.Offset + var691.X, fakeBombPanelStartPos.Y.Scale, fakeBombPanelStartPos.Y.Offset + var691.Y)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if not fakeBombPanelDragging or input ~= fakeBombPanelDragInput then
            return
        end
        fakeBombPanelDragging = false
        fakeBombPanelDragInput = nil
        uiPanelTouchActive = activeTouchCount > 0
        uIStroke3.Thickness = 2
        if not fakeBombPanelDragMoved and os.clock() - fakeBombPanelTouchStart < 0.4 then
            if fakeBombVariant == "Auto" then
                fireFakeBombThrow()
            end
        end
    end)
    updateFakeBombJumpPanelScale(10)
end
function connectFakeBombTool(arg51)
    if not arg51 or not arg51:IsA("Tool") or arg51.Name ~= "FakeBomb" then
        return
    end
    disconnectFakeBombTool(arg51)
    fakeBombToolConnections[arg51] = true
end
function scanFakeBombToolsOnce()
    local character45 = localPlayer.Character
    local backpack7 = localPlayer:FindFirstChildOfClass("Backpack")
    if character45 then
        local fakeBomb2 = character45:FindFirstChild("FakeBomb")
        if fakeBomb2 then
            connectFakeBombTool(fakeBomb2)
        end
    end
    if backpack7 then
        local fakeBomb3 = backpack7:FindFirstChild("FakeBomb")
        if fakeBomb3 then
            connectFakeBombTool(fakeBomb3)
        end
    end
end
function setupFakeBombMouseLock()
    setupFakeBombManualInput()
    local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
    if not playerScripts then
        playerScripts = localPlayer:WaitForChild("PlayerScripts", 10)
    end
    local var694 = playerScripts and playerScripts:FindFirstChild("MouseLock")
    if not var694 and playerScripts then
        var694 = playerScripts:WaitForChild("MouseLock", 10)
    end
    local var696 = var694 and var694:FindFirstChild("MouseLockToggled")
    if not var696 and var694 then
        var696 = var694:WaitForChild("MouseLockToggled", 10)
    end
    if var696 and var696:IsA("BindableEvent") then
        pcall(function()
            fakeBombMouseLockConnection = var696.Event:Connect(function(enabled)
                fakeBombMouseLockActive = enabled == true
            end)
        end)
    end
end
function enableFakeBombJump()
    fakeBombJumpEnabled = true
    scanFakeBombToolsOnce()
end
function disableFakeBombJump()
    fakeBombJumpEnabled = false
    fakeBombAutoJumpEnabled = true
    if FakeBombJumpPanel then
        FakeBombJumpPanel.Visible = false
    end
    disconnectAllFakeBombTools()
end
setupFakeBombMouseLock()
if localPlayer.Character then
    localPlayer.Character.ChildAdded:Connect(function(arg52)
        if arg52.Name == "FakeBomb" then
            connectFakeBombTool(arg52)
        end
    end)
    task.defer(setupFakeBombScreenTouchHumanoid, localPlayer.Character)
end
localPlayer.CharacterAdded:Connect(function(arg53)
    if fakeBombCharacterConnection then
        pcall(function()
            fakeBombCharacterConnection:Disconnect()
        end)
        fakeBombCharacterConnection = nil
    end
    fakeBombCharacterConnection = arg53.ChildAdded:Connect(function(arg54)
        if arg54.Name == "FakeBomb" then
            connectFakeBombTool(arg54)
        end
    end)
    task.defer(setupFakeBombScreenTouchHumanoid, arg53)
    task.defer(scanFakeBombToolsOnce)
end)
local function fn42()
    return localPlayer:FindFirstChildOfClass("Backpack")
end
fakeBombBackpack = fn42()
if fakeBombBackpack then
    fakeBombBackpackConnection = fakeBombBackpack.ChildAdded:Connect(function(arg55)
        if arg55.Name == "FakeBomb" then
            connectFakeBombTool(arg55)
        end
    end)
end
localPlayer.ChildAdded:Connect(function(arg56)
    if arg56:IsA("Backpack") then
        if fakeBombBackpackConnection then
            pcall(function()
                fakeBombBackpackConnection:Disconnect()
            end)
        end
        fakeBombBackpackConnection = arg56.ChildAdded:Connect(function(item)
            if item.Name == "FakeBomb" then
                connectFakeBombTool(item)
            end
        end)
        task.defer(scanFakeBombToolsOnce)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        fakeBombLastPointer = input.Position
    end
end)
local function fn43(arg57, callback)
    for _, v40 in ipairs(arg57:GetChildren()) do
        callback(v40)
        fn43(v40, callback)
    end
end
local function fn44(arg58, targetName)
    local tbl13 = {}
    fn43(arg58, function(obj)
        if obj.Name == targetName then
            table.insert(tbl13, obj)
        end
    end)
    return tbl13
end
local function fn45(arg59)
    local var704 = hitboxOriginals[arg59]
    if not var704 then
        return
    end
    pcall(function()
        if arg59 and arg59.Parent then
            arg59.Size = var704.Size
            arg59.CanCollide = var704.CanCollide
            arg59.Transparency = var704.Transparency
        end
    end)
    hitboxOriginals[arg59] = nil
end
local function fn46()
    for k7 in pairs(hitboxOriginals) do
        fn45(k7)
    end
end
local function fn47()
    if not hitboxExpandEnabled then
        fn46()
        return
    end
    local tbl14 = {}
    local size = math.clamp(tonumber(hitboxSize) or 8, 1, 30)
    for _, v41 in ipairs(Players:GetPlayers()) do
        if v41 ~= localPlayer then
            local character46 = v41.Character
            local var708 = character46 and character46:FindFirstChildOfClass("Humanoid")
            local var710 = character46 and character46:FindFirstChild("HumanoidRootPart")
            if var710 and var710:IsA("BasePart") and var708 and var708.Health > 0 then
                if not hitboxOriginals[var710] then
                    hitboxOriginals[var710] = {Size = var710.Size, CanCollide = var710.CanCollide, Transparency = var710.Transparency}
                end
                tbl14[var710] = true
                pcall(function()
                    var710.Size = Vector3.new(size, size, size)
                    var710.CanCollide = false
                    var710.Transparency = 0.6
                end)
            end
        end
    end
    for k8 in pairs(hitboxOriginals) do
        if not tbl14[k8] then
            fn45(k8)
        end
    end
end
local function fn48(arg60)
    hitboxExpandEnabled = arg60 == true
    if not hitboxExpandEnabled then
        fn46()
    end
end
local function fn49(value)
    hitboxSize = math.clamp(tonumber(value) or 8, 1, 30)
end
local var716
var716 = RunService.Heartbeat:Connect(function()
    local var717, err = pcall(fn47)
    if not var717 then
        warn("[Hitbox Expander] " .. tostring(err))
    end
end)
local var718 = nil
local num5 = 0
local vector34 = Vector3.new(-25.95, 84, 3537.55)
local function fn50(arg61)
    for k9, v42 in pairs(invisibleTransparencyOriginals) do
        local var719 = k9 and k9.Parent and (arg61 == nil or k9:IsDescendantOf(arg61))
        if var719 then
            pcall(function()
                k9.Transparency = v42
            end)
            invisibleTransparencyOriginals[k9] = nil
        elseif not k9 or not k9.Parent then
            invisibleTransparencyOriginals[k9] = nil
        end
    end
end
local function fn51(arg62)
    if not arg62 then
        return
    end
    fn50(nil)
    invisibleTransparencyOriginals = {}
    fn43(arg62, function(obj)
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            invisibleTransparencyOriginals[obj] = obj.Transparency
            obj.Transparency = 0.5
        end
    end)
end
local function fn52()
    local var720 = var718
    var718 = nil
    if var720 and var720.Parent then
        pcall(function()
            var720:Destroy()
        end)
    end
end
local function fn53(_enabled)
end
local function fn54(arg63)
    if not arg63 or not arg63:IsA("BasePart") then
        return false
    end
    if arg63.Transparency < 0.99 or not arg63.CanCollide then
        return false
    end
    for _, v43 in ipairs(Players:GetPlayers()) do
        if v43.Character and arg63:IsDescendantOf(v43.Character) then
            return false
        end
    end
    local tool = arg63:FindFirstAncestorOfClass("Tool")
    if tool then
        return false
    end
    return true
end
local function fn55(arg64)
    if not fn54(arg64) then
        return
    end
    if removeInvisibleBarrierOriginals[arg64] == nil then
        removeInvisibleBarrierOriginals[arg64] = arg64.CanCollide
    end
    pcall(function()
        arg64.CanCollide = false
    end)
end
local function fn56()
    for k10, v44 in pairs(removeInvisibleBarrierOriginals) do
        if k10 and k10.Parent then
            pcall(function()
                k10.CanCollide = v44
            end)
        end
    end
    removeInvisibleBarrierOriginals = {}
end
local function fn57()
    fn43(Workspace, function(obj)
        if obj:IsA("BasePart") then
            fn55(obj)
        end
    end)
end
function SetRemoveInvisibleBarriers(arg65)
    removeInvisibleBarrierEnabled = arg65 == true
    if removeInvisibleBarrierConnection then
        removeInvisibleBarrierConnection:Disconnect()
        removeInvisibleBarrierConnection = nil
    end
    if not removeInvisibleBarrierEnabled then
        fn56()
        return
    end
    fn57()
    removeInvisibleBarrierConnection = Workspace.DescendantAdded:Connect(function(obj)
        if removeInvisibleBarrierEnabled and obj:IsA("BasePart") then
            task.defer(function()
                if removeInvisibleBarrierEnabled and obj.Parent then
                    fn55(obj)
                end
            end)
        end
    end)
end
var495 = function(arg66, silent)
    local var730 = arg66 == true
    if var730 and invisibleEnabled and var718 and var718.Parent then
        return
    end
    num5 = num5 + 1
    local var731 = num5
    if not var730 then
        local var733 = invisibleEnabled
        invisibleEnabled = false
        fn52()
        fn50(nil)
        if var733 and not silent then
            fn53(false)
        end
        return
    end
    invisibleEnabled = true
    fn52()
    fn50(nil)
    local var735 = localPlayer and localPlayer.Character
    local var736 = var735 and var735:FindFirstChild("HumanoidRootPart")
    local var737 = var735 and var735:FindFirstChildOfClass("Humanoid")
    if not var735 or not var736 or not var737 then
        invisibleEnabled = false
        return
    end
    local cFrame7 = var736.CFrame
    local var738 = pcall(function()
        var735:MoveTo(vector34)
    end)
    if not var738 then
        invisibleEnabled = false
        return
    end
    task.wait(0.15)
    if var731 ~= num5 or not invisibleEnabled or not var735.Parent or localPlayer.Character ~= var735 then
        if var736.Parent then
            pcall(function()
                var736.CFrame = cFrame7
            end)
        end
        return
    end
    local seat = Instance.new("Seat")
    seat.Name = "invischair"
    seat.Anchored = false
    seat.CanCollide = false
    seat.Transparency = 1
    seat.Position = vector34
    seat.Parent = Workspace
    var718 = seat
    local var744 = var735:FindFirstChild("Torso") or var735:FindFirstChild("UpperTorso") or var736
    if not var744 or not var744:IsA("BasePart") then
        fn52()
        invisibleEnabled = false
        pcall(function()
            var736.CFrame = cFrame7
        end)
        return
    end
    local weld = Instance.new("Weld")
    weld.Part0 = seat
    weld.Part1 = var744
    weld.Parent = seat
    task.wait()
    if var731 ~= num5 or not invisibleEnabled or not seat.Parent or not var735.Parent or localPlayer.Character ~= var735 then
        fn52()
        if var736.Parent then
            pcall(function()
                var736.CFrame = cFrame7
            end)
        end
        return
    end
    pcall(function()
        seat.CFrame = cFrame7
    end)
    fn51(var735)
    if InvisiblePanel then
        InvisiblePanel.Visible = invisibleFeatureEnabled
    end
    if not silent then
        fn53(true)
    end
end
local function fn58(arg67)
    lowDetailsEnabled = arg67 == true
    if lowDetailsEnabled then
        if not lowDetailsOriginal then
            lowDetailsOriginal = {
                GlobalShadows = Lighting.GlobalShadows,
                ShadowSoftness = Lighting.ShadowSoftness,
                ShadowColor = Lighting.ShadowColor,
            }
        end
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.ShadowColor = Color3.new(0, 0, 0)
    else
        if lowDetailsOriginal then
            Lighting.GlobalShadows = lowDetailsOriginal.GlobalShadows
            Lighting.ShadowSoftness = lowDetailsOriginal.ShadowSoftness
            Lighting.ShadowColor = lowDetailsOriginal.ShadowColor
            lowDetailsOriginal = nil
        end
    end
end
local function fn59(arg68)
    disableFootstepEnabled = arg68 == true
    if footstepConnection then
        footstepConnection:Disconnect()
        footstepConnection = nil
    end
    if disableFootstepEnabled then
        footstepBackups = {}
        local var749 = fn44(Workspace, "Footsteps")
        for _, obj in ipairs(var749) do
            local clone = nil
            pcall(function()
                if obj.Archivable then
                    clone = obj:Clone()
                end
            end)
            if clone then
                table.insert(footstepBackups, {parent = obj.Parent, clone = clone})
            end
            pcall(function()
                obj:Destroy()
            end)
        end
        footstepConnection = Workspace.DescendantAdded:Connect(function(obj)
            if disableFootstepEnabled and obj.Name == "Footsteps" then
                task.defer(function()
                    if not disableFootstepEnabled or not obj or not obj.Parent then
                        return
                    end
                    local flag15 = false
                    for _, v45 in ipairs(footstepBackups) do
                        if v45.parent == obj.Parent then
                            flag15 = true
                            break
                        end
                    end
                    if not flag15 then
                        local clone = nil
                        pcall(function()
                            if obj.Archivable then
                                clone = obj:Clone()
                            end
                        end)
                        if clone then
                            table.insert(footstepBackups, {parent = obj.Parent, clone = clone})
                        end
                    end
                    pcall(function()
                        obj:Destroy()
                    end)
                end)
            end
        end)
    else
        local var751 = fn44(Workspace, "Footsteps")
        if #var751 == 0 then
            for _, v46 in ipairs(footstepBackups) do
                if v46.parent and v46.parent.Parent and v46.clone then
                    pcall(function()
                        v46.clone.Parent = v46.parent
                    end)
                end
            end
        end
        footstepBackups = {}
    end
end
local tbl15 = {flag1 = false, list1 = {}, field1 = nil, flag18 = false, list2 = {}}
local function fn60()
    local tbl16 = {}
    fn43(Workspace, function(desc)
        if desc.Name == "Coin_Server" then
            tbl16[#tbl16 + 1] = desc
        end
    end)
    return tbl16
end
local function fn61(obj, store)
    if not obj or not obj.Parent then
        return false
    end
    table.insert(store, {obj = obj, parent = obj.Parent})
    obj.Parent = nil
    return true
end
local function fn62()
    tbl15.list1 = {}
    for _, obj in ipairs(fn60()) do
        fn61(obj, tbl15.list1)
    end
end
local function fn63()
    for _, v47 in ipairs(tbl15.list1) do
        if v47.obj and v47.parent then
            pcall(function()
                v47.obj.Parent = v47.parent
            end)
        end
    end
    tbl15.list1 = {}
end
local function fn64()
    local tbl17 = {}
    for _, v48 in ipairs(Workspace:GetChildren()) do
        local pet = v48:FindFirstChild("Pet")
        if pet then
            tbl17[#tbl17 + 1] = pet
        end
    end
    return tbl17
end
local function fn65()
    tbl15.list2 = {}
    for _, obj in ipairs(fn64()) do
        fn61(obj, tbl15.list2)
    end
end
local function fn66()
    for _, v49 in ipairs(tbl15.list2) do
        if v49.obj and v49.parent then
            pcall(function()
                v49.obj.Parent = v49.parent
            end)
        end
    end
    tbl15.list2 = {}
end
local function fn67()
    if tbl15.field1 then
        return
    end
    tbl15.field1 = task.spawn(function()
        while tbl15.flag1 or tbl15.flag18 do
            if tbl15.flag1 then
                for _, obj in ipairs(fn60()) do
                    fn61(obj, tbl15.list1)
                end
            end
            if tbl15.flag18 then
                for _, obj in ipairs(fn64()) do
                    fn61(obj, tbl15.list2)
                end
            end
            task.wait(0.3)
        end
        tbl15.field1 = nil
    end)
end
local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
colorCorrectionEffect.Name = "Bolong3DOff"
colorCorrectionEffect.Brightness = -1
colorCorrectionEffect.Contrast = -1
colorCorrectionEffect.Saturation = -1
colorCorrectionEffect.Enabled = false
colorCorrectionEffect.Parent = Lighting
local num6 = 2.5
local var759 = nil
local var760 = nil
local function fn68()
    local var761 = var760
    local var762 = var759
    if not var761 or not var762 then
        var759 = nil
        var760 = nil
        return
    end
    local humanoidRootPart8 = var761:FindFirstChild("HumanoidRootPart")
    local humanoid11 = var761:FindFirstChildOfClass("Humanoid")
    if humanoidRootPart8 and humanoidRootPart8.Parent then
        pcall(function()
            humanoidRootPart8.CFrame = var762
            humanoidRootPart8.AssemblyLinearVelocity = Vector3.zero
            humanoidRootPart8.AssemblyAngularVelocity = Vector3.zero
        end)
        if var761.PrimaryPart then
            pcall(function()
                var761:SetPrimaryPartCFrame(var762)
            end)
        end
        if humanoid11 then
            pcall(function()
                humanoid11:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    end
    var759 = nil
    var760 = nil
end
local function fn69()
    selectedFlingEnabled = false
    selectedFlingInProgress = false
    if selectedFlingThread then
        task.cancel(selectedFlingThread)
        selectedFlingThread = nil
    end
    fn68()
end
local function fn70(player12)
    selectedFlingInProgress = true
    local character47 = localPlayer.Character
    if not character47 then
        selectedFlingInProgress = false
        return
    end
    local humanoid12 = character47:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart9 = character47:FindFirstChild("HumanoidRootPart")
    local var768 = player12 and player12.Character
    if not (humanoid12 and humanoidRootPart9 and var768) then
        selectedFlingInProgress = false
        return
    end
    local humanoid13 = var768:FindFirstChildOfClass("Humanoid")
    local var772 = humanoid13 and humanoid13.RootPart
    local head = var768:FindFirstChild("Head")
    local accessory = var768:FindFirstChildOfClass("Accessory")
    local var775 = accessory and accessory:FindFirstChild("Handle")
    local function fn71(basePart, arg69, angle)
        if not selectedFlingEnabled then
            return false
        end
        local var776 = CFrame.new(basePart.Position) * arg69 * angle
        humanoidRootPart9.CFrame = var776
        if character47.PrimaryPart then
            character47:SetPrimaryPartCFrame(var776)
        end
        humanoidRootPart9.Velocity = Vector3.new(90000000, 900000000, 90000000)
        humanoidRootPart9.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
        return true
    end
    local function fn72(basePart)
        local now = tick()
        local num7 = 0
        while selectedFlingEnabled and basePart and basePart.Parent and humanoid13 and humanoid13.Health > 0 and tick() - now <= num6 do
            num7 = num7 + 100
            for _, v50 in ipairs({
                CFrame.new(0, 1.5, 0),
                CFrame.new(0, -1.5, 0),
                CFrame.new(2.25, 1.5, -2.25),
                CFrame.new(-2.25, -1.5, 2.25),
            }) do
                if not fn71(basePart, v50 + humanoid13.MoveDirection, CFrame.Angles(math.rad(num7), 0, 0)) then
                    return
                end
                task.wait()
            end
        end
    end
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "SelectedFlingVelocity"
    bodyVelocity.Velocity = Vector3.new(900000000, 900000000, 900000000)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = humanoidRootPart9
    humanoid12:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    local targetPart = var772 or head or var775
    if targetPart then
        fn72(targetPart)
    end
    if bodyVelocity.Parent then
        bodyVelocity:Destroy()
    end
    humanoid12:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    selectedFlingInProgress = false
end
local function fn73()
    local var784 = selectedFlingPlayerName and Players:FindFirstChild(selectedFlingPlayerName)
    if not var784 or var784 == localPlayer then
        selectedFlingEnabled = false
        return
    end
    fn69()
    local character48 = localPlayer.Character
    local var785 = character48 and character48:FindFirstChild("HumanoidRootPart")
    if not character48 or not var785 then
        selectedFlingEnabled = false
        return
    end
    var759 = var785.CFrame
    var760 = character48
    selectedFlingEnabled = true
    selectedFlingThread = task.spawn(function()
        while selectedFlingEnabled do
            local var786 = selectedFlingPlayerName and Players:FindFirstChild(selectedFlingPlayerName)
            if not var786 or var786 == localPlayer then
                selectedFlingEnabled = false
                break
            end
            fn70(var786)
            if not selectedFlingEnabled then
                break
            end
            task.wait(0.12)
        end
        selectedFlingThread = nil
    end)
end
local function fn74()
    local tbl18 = {}
    for _, v51 in ipairs(Players:GetPlayers()) do
        if v51 ~= localPlayer then
            table.insert(tbl18, v51.Name)
        end
    end
    table.sort(tbl18)
    return tbl18
end
local var789 = nil
local function fn75()
    if not var789 then
        return
    end
    local var790 = fn74()
    pcall(function()
        if var789.SetValues then
            var789:SetValues(var790)
        elseif var789.SetOptions then
            var789:SetOptions(var790)
        end
    end)
end
Players.PlayerAdded:Connect(function()
    task.defer(fn75)
end)
Players.PlayerRemoving:Connect(function(arg70)
    if arg70 and selectedFlingPlayerName == arg70.Name then
        fn69()
    end
    task.defer(fn75)
end)
localPlayer.CharacterAdded:Connect(function(arg71)
    local var792 = invisibleEnabled
    if var792 then
        var495(false, true)
        task.delay(0.2, function()
            if var792 and arg71.Parent and localPlayer.Character == arg71 then
                var495(true, true)
            end
        end)
    end
    if InvisiblePanel then
        InvisiblePanel.Visible = invisibleFeatureEnabled
    end
    if selectedFlingEnabled then
        fn69()
    end
end)
local tbl19 = {
    enabled = false,
    flag19 = false,
    num1 = 150,
    flag20 = true,
    color31 = Color3.fromRGB(255, 255, 255),
    throwBtnEnabled = false,
    field2 = nil,
    field3 = nil,
    num10 = 1,
    num11 = 80,
    num12 = 1.5,
    flag21 = true,
    flag22 = true,
}
local tbl20 = {
    ws = nil,
    origGetTarget = nil,
    origMouseTarget = nil,
    flag23 = false,
    flag24 = false,
    field4 = nil,
    field5 = nil,
}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BolongKnifeSilenceCircle"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 996
screenGui.Parent = PlayerGui
local frame7 = Instance.new("Frame")
frame7.Name = "Circle"
frame7.AnchorPoint = Vector2.new(0.5, 0.5)
frame7.Position = UDim2.fromScale(0.5, 0.5)
frame7.BackgroundTransparency = 1
frame7.BorderSizePixel = 0
frame7.Visible = false
frame7.ZIndex = 30
frame7.Parent = screenGui
Instance.new("UICorner", frame7).CornerRadius = UDim.new(1, 0)
local uIStroke4 = Instance.new("UIStroke")
uIStroke4.Thickness = 2
uIStroke4.Transparency = 0
uIStroke4.Color = tbl19.color31
uIStroke4.Parent = frame7
local function fn76()
    return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end
local function fn77()
    local character49 = localPlayer.Character
    local backpack8 = localPlayer:FindFirstChild("Backpack")
    if character49 then
        for _, v52 in ipairs(character49:GetChildren()) do
            if v52:IsA("Tool") and v52.Name:lower():find("knife") then
                return v52, true
            end
        end
    end
    if backpack8 then
        for _, v53 in ipairs(backpack8:GetChildren()) do
            if v53:IsA("Tool") and v53.Name:lower():find("knife") then
                return v53, false
            end
        end
    end
    return nil, false
end
local function fn78()
    local character50 = localPlayer.Character
    local var796 = character50 and character50:FindFirstChild("HumanoidRootPart")
    if not var796 then
        return nil
    end
    local var797, closestDist = nil, math.huge
    for _, v54 in ipairs(Players:GetPlayers()) do
        if v54 ~= localPlayer then
            local character51 = v54.Character
            local var800 = character51 and character51:FindFirstChild("HumanoidRootPart")
            local var801 = character51 and character51:FindFirstChildOfClass("Humanoid")
            if var800 and var801 and var801.Health > 0 then
                local magnitude7 = (var800.Position - var796.Position).Magnitude
                if magnitude7 < closestDist then
                    closestDist = magnitude7
                    var797 = character51
                end
            end
        end
    end
    return var797
end
local function fn79(position)
    local currentCamera4 = Workspace.CurrentCamera
    if not currentCamera4 then
        return nil
    end
    local var804, onScreen = currentCamera4:WorldToViewportPoint(position)
    if var804.Z <= 0 then
        return nil
    end
    return Vector2.new(var804.X, var804.Y), onScreen
end
local function fn80(character52)
    local var805 = character52 and character52:FindFirstChild("HumanoidRootPart")
    if not var805 then
        return false
    end
    local var806, onScreen = fn79(var805.Position)
    if not var806 or not onScreen then
        return false
    end
    local viewportSize = Workspace.CurrentCamera.ViewportSize
    local vector22 = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    return (var806 - vector22).Magnitude <= tbl19.num1 / 2
end
local function fn81(character53)
    local var808 = character53 and character53:FindFirstChild("HumanoidRootPart")
    local var810 = character53 and (character53:FindFirstChild("UpperTorso") or character53:FindFirstChild("HumanoidRootPart") or character53:FindFirstChild("Head") or character53:FindFirstChild("Torso"))
    if not var808 or not var810 then
        return nil
    end
    local character54 = localPlayer.Character
    local var811 = character54 and character54:FindFirstChild("HumanoidRootPart")
    if not var811 then
        return nil
    end
    local velocity = var808.AssemblyLinearVelocity
    local var812 = localPlayer:GetNetworkPing() or 0
    local vector35 = Vector3.new(var810.Position.X, var810.Position.Y + tbl19.num12, var810.Position.Z)
    local vector36 = Vector3.new(var811.Position.X, 0, var811.Position.Z)
    local vector37 = Vector3.new(vector35.X, 0, vector35.Z)
    local magnitude8 = (vector37 - vector36).Magnitude
    if magnitude8 < 1 then
        magnitude8 = 1
    end
    local var813 = magnitude8 / math.max(1, tbl19.num11)
    if tbl19.flag21 then
        var813 = var813 + math.max(0, var812)
    end
    local vector38 = Vector3.new(velocity.X, 0, velocity.Z)
    local var815 = vector37 - vector36
    local var816 = var815.Magnitude > 0.1 and var815.Unit or Vector3.new(0, 0, -1)
    local var817 = vector38:Dot(var816)
    local var818 = var816 * var817
    local var820 = vector38 - var818
    local zero = Vector3.zero
    if tbl19.num10 ~= 0 and var820.Magnitude > 0.1 then
        zero = var820.Unit * tbl19.num10
    end
    local Y2 = vector35.Y
    if tbl19.flag22 then
        local var821 = math.min(var813, 0.6)
        Y2 = vector35.Y + velocity.Y * var821 * 0.25
    end
    local var823 = var820 * var813 * 0.6
    return Vector3.new(vector35.X + var823.X + zero.X, Y2, vector35.Z + var823.Z + zero.Z)
end
local function fn82()
    if not tbl19.enabled then
        return nil
    end
    local var826 = fn78()
    if var826 then
        if tbl19.flag19 then
            if fn80(var826) then
                local var827 = fn81(var826)
                if var827 then
                    return CFrame.new(var827)
                end
            end
        else
            local var828 = fn81(var826)
            if var828 then
                return CFrame.new(var828)
            end
        end
    end
    if tbl19.flag19 and fn76() then
        local currentCamera5 = Workspace.CurrentCamera
        if not currentCamera5 then
            return nil
        end
        local var830 = currentCamera5.CFrame.LookVector * 1000
        local raycastParams2 = RaycastParams.new()
        raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams2.FilterDescendantsInstances = {localPlayer.Character}
        local var833 = Workspace:Raycast(currentCamera5.CFrame.Position, var830, raycastParams2)
        if var833 then
            return CFrame.new(var833.Position)
        end
        return CFrame.new(currentCamera5.CFrame.Position + var830)
    end
    return nil
end
local function fn83()
    if tbl20.flag23 then
        return
    end
    if not tbl20.ws then
        local var836, ws = pcall(function()
            return require(game:GetService("ReplicatedStorage"):WaitForChild("ClientServices"):WaitForChild("WeaponService"))
        end)
        if not var836 or not ws then
            return
        end
        tbl20.ws = ws
        tbl20.origGetTarget = ws.GetTargetPosition
        tbl20.origMouseTarget = ws.GetMouseTargetCFrame
    end
    local ws = tbl20.ws
    if not ws then
        return
    end
    ws.GetTargetPosition = function(self, x, y)
        local var841 = fn82()
        if var841 then
            return var841
        end
        return tbl20.origGetTarget(self, x, y)
    end
    ws.GetMouseTargetCFrame = function(self)
        local var843 = fn82()
        if var843 then
            return var843
        end
        return tbl20.origMouseTarget(self)
    end
    tbl20.flag23 = true
end
local function fn84()
    if not tbl20.flag23 or not tbl20.ws then
        return
    end
    tbl20.ws.GetTargetPosition = tbl20.origGetTarget
    tbl20.ws.GetMouseTargetCFrame = tbl20.origMouseTarget
    tbl20.flag23 = false
end
local function fn85()
    if tbl19.field2 and tbl19.field2.Parent then
        return
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "BolongKnifeSilenceThrow"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 995
    gui.Parent = PlayerGui
    local textButton = Instance.new("TextButton")
    textButton.Name = "ThrowBtn"
    textButton.AnchorPoint = Vector2.new(0.5, 0.5)
    textButton.Position = UDim2.fromScale(0.5, 0.68)
    textButton.Size = UDim2.fromOffset(72, 72)
    textButton.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    textButton.BackgroundTransparency = 0.2
    textButton.Text = "THROW"
    textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    textButton.TextSize = 12
    textButton.Font = Enum.Font.GothamBold
    textButton.AutoButtonColor = false
    textButton.Visible = true
    textButton.Parent = gui
    Instance.new("UICorner", textButton).CornerRadius = UDim.new(1, 0)
    local uIStroke5 = Instance.new("UIStroke")
    uIStroke5.Color = tbl19.color31
    uIStroke5.Thickness = 2
    uIStroke5.Transparency = 0.1
    uIStroke5.Parent = textButton
    local flag16 = false
    local var850 = nil
    local var851 = nil
    local var852 = nil
    local flag17 = false
    textButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            flag16 = true
            flag17 = false
            var850 = input
            var851 = input.Position
            var852 = textButton.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if flag16 and input == var850 then
            local var853 = input.Position - var851
            if var853.Magnitude > 6 then
                flag17 = true
            end
            textButton.Position = UDim2.new(var852.X.Scale, var852.X.Offset + var853.X, var852.Y.Scale, var852.Y.Offset + var853.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if flag16 and input == var850 then
            flag16 = false
            var850 = nil
        end
    end)
    textButton.Activated:Connect(function()
        if not flag17 then
            tbl20.flag24 = false
            local character55 = localPlayer.Character
            local var854, equipped = fn77()
            local backpack9 = localPlayer:FindFirstChild("Backpack")
            if not var854 or not character55 then
                return
            end
            if tbl20.flag24 then
                return
            end
            tbl20.flag24 = true
            tbl20.field5 = nil
            tbl20.field4 = task.spawn(function()
                while tbl20.flag24 do
                    local var855 = fn78()
                    if var855 then
                        local var856 = not tbl19.flag19 or fn80(var855)
                        if var856 then
                            local var857 = fn81(var855)
                            if var857 then
                                tbl20.field5 = var857
                            end
                        else
                            tbl20.field5 = nil
                        end
                    end
                    task.wait(0.05)
                end
            end)
            pcall(function()
                if not equipped and var854.Parent ~= character55 and backpack9 then
                    var854.Parent = character55
                end
                local var858 = var854:GetAttribute("ThrowSpeed") or 1
                task.wait(var858)
                local var859 = tbl20.field5
                if not var859 and tbl19.flag19 and fn76() then
                    local currentCamera6 = Workspace.CurrentCamera
                    local position11 = currentCamera6.CFrame.Position
                    local var860 = currentCamera6.CFrame.LookVector * 1000
                    local raycastParams3 = RaycastParams.new()
                    raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
                    raycastParams3.FilterDescendantsInstances = {localPlayer.Character}
                    local var861 = Workspace:Raycast(position11, var860, raycastParams3)
                    var859 = var861 and var861.Position or position11 + var860
                end
                if not var859 then
                    return
                end
                local events2 = var854:FindFirstChild("Events")
                local var862 = events2 and events2:FindFirstChild("KnifeThrown")
                local handle5 = var854:FindFirstChild("Handle")
                if var862 and var862:IsA("RemoteEvent") and handle5 then
                    var862:FireServer(handle5.CFrame, CFrame.new(var859))
                end
            end)
            tbl20.flag24 = false
        end
    end)
    tbl19.field3 = gui
    tbl19.field2 = textButton
end
local function fn86()
    if tbl19.field3 then
        pcall(function()
            tbl19.field3:Destroy()
        end)
    end
    tbl19.field3 = nil
    tbl19.field2 = nil
end
RunService.RenderStepped:Connect(function()
    frame7.Size = UDim2.fromOffset(tbl19.num1, tbl19.num1)
    uIStroke4.Color = tbl19.color31
    frame7.Visible = tbl19.enabled and tbl19.flag19 and tbl19.flag20
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end
    if input.KeyCode == Enum.KeyCode.E then
        if AutoShootEnabled and MainPanel then
            PlaySoundAsset(88129339693239, 1)
            autoShoot()
        end
        return
    end
    if input.KeyCode == Enum.KeyCode.F then
        if aimbotActive then
            PlaySoundAsset(111044884172919, 1)
            aimlockEngaged = not aimlockEngaged
            aimbotFOVVisible = aimlockEngaged
            if not aimlockEngaged then
                clearAimlockTarget()
            end
            UpdateAimbotVisuals()
        end
        return
    end
    if input.KeyCode == Enum.KeyCode.Q then
        if fakeBombJumpEnabled and fakeBombVariant == "Auto" then
            fireFakeBombThrow()
        end
    end
end)
function BuildUI()
    refreshLocalPlayerReferences()
    if not PlayerGui then
        PlayerGui = localPlayer:WaitForChild("PlayerGui")
    end
    local var866 = var114:Window({
        Title = "BOLONG-HUB",
        Image = "84034353458936",
        Footer = "Murder Mystery 2",
        Author = "discord.gg/pWpgqVGxNK",
        Color = ACCENT_COLOR,
        Version = 2,
        Search = true,
        Folder = "BolongHubMM2",
    })
    PlayOpenSound()
    local str2 = "v1.0.0"
    var866:InfoTab({
        Name = "Info",
        Icon = "info",
        SectionTitle = "Information",
        Banner = "79662603577585",
        BannerAspectRatio = 3.2,
        Version = str2,
        DiscordLink = "https://discord.gg/pWpgqVGxNK",
        DiscordName = "Community BolongHub",
        DiscordText = "Gabung untuk update & support.",
        DiscordDesc = "Made by 11rill — features: Killer & Survivor Hitbox/ESP, Auto Aim, Auto Generator, Killer Warn, Camera Veil, and many more.",
        CardsWidget = {{catwidget = "rbxassetid://117486345000318"}},
    })
    local var867 = var866:AddTab({Name = "Main", Icon = "house"})
    local var868 = var866:AddTab({Name = "Auto Farm", Icon = "bot"})
    local var869 = var866:AddTab({Name = "Combat", Icon = "crosshair"})
    local var872 = var866:AddTab({Name = "Murderer", Icon = "skull"})
    local var873 = var866:AddTab({Name = "Visuals", Icon = "eye"})
    local var874 = var866:AddTab({Name = "Misc", Icon = "settings"})
    local var875 = var866:AddTab({Name = "Configuration", Icon = "settings"})
    local tbl21 = {
        Info = true,
        Main = true,
        ["Auto Farm"] = true,
        Combat = true,
        Murderer = true,
        Visuals = true,
        Misc = true,
        Configuration = true,
    }
    local function fn87(guiObject)
        local var876 = guiObject
        local num8 = 0
        while var876 and num8 < 8 do
            if var876:IsA("TextButton") or var876:IsA("TextLabel") then
                local var877 = tostring(var876.Text or "")
                if tbl21[var877] then
                    return var877
                end
            end
            var876 = var876.Parent
            num8 = num8 + 1
        end
        return nil
    end
    local function fn88(position)
        local var881, var882 = pcall(function()
            return GuiService:GetGuiObjectsAtPosition(position.X, position.Y)
        end)
        if not var881 or type(var882) ~= "table" then
            return
        end
        local num9 = 1
        while num9 <= #var882 do
            local var884 = fn87(var882[num9])
            if var884 then
                PlaySoundAsset(124199202280292, 1)
                return
            end
            num9 = num9 + 1
        end
    end
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fn88(input.Position)
        end
    end)
    local var886 = var867:AddSection("Movement & Physics", nil)
    var886:AddSlider({
        Title = "Speed",
        Min = 16,
        Max = 200,
        Default = 16,
        Increment = 1,
        Callback = function(arg72)
            currentSpeed = tonumber(arg72) or 16
            ApplyMovement()
        end,
    })
    var886:AddSlider({
        Title = "JumpPower",
        Min = 50,
        Max = 300,
        Default = 50,
        Increment = 1,
        Callback = function(arg73)
            currentJump = tonumber(arg73) or 50
            ApplyMovement()
        end,
    })
    var886:AddSlider({
        Title = "Gravity",
        Min = 0,
        Max = 300,
        Default = 196.2,
        Increment = 1,
        Callback = function(arg74)
            currentGravity = tonumber(arg74) or 196.2
        end,
    })
    var886:AddSlider({
        Title = "FOV",
        Min = 70,
        Max = 120,
        Default = 70,
        Increment = 1,
        Callback = function(arg75)
            Camera.FieldOfView = tonumber(arg75) or 70
        end,
    })
    local var888 = var867:AddSection("Utilities", nil)
    var888:AddToggle({
        Title = "Inf Jump",
        Default = false,
        Callback = function(arg76)
            infJumpEnabled = arg76 == true
        end,
    })
    var888:AddToggle({
        Title = "Noclip",
        Default = false,
        Callback = function(arg77)
            noclipEnabled = arg77 == true
            NoclipEnabled = noclipEnabled
            if not noclipEnabled then
                SetNoclip(false)
            end
        end,
    })
    local var891 = var867:AddSection("Hitbox Expander", nil)
    var891:AddToggle({
        Title = "Hitbox Expander",
        Default = false,
        Callback = function(arg78)
            fn48(arg78 == true)
        end,
    })
    var891:AddSlider({
        Title = "Hitbox Size",
        Min = 1,
        Max = 30,
        Default = 8,
        Increment = 1,
        Callback = function(arg79)
            fn49(arg79)
        end,
    })
    local var892 = var867:AddSection("Remove invisible barrier", nil)
    var892:AddToggle({
        Title = "Remove invisible barrier",
        Default = false,
        Callback = function(arg80)
            SetRemoveInvisibleBarriers(arg80 == true)
        end,
    })
    local var894 = var868:AddSection("AUTO FARM COINS", nil)
    var894:AddToggle({
        Title = "Auto Farm Coins",
        Default = false,
        Callback = function(arg81)
            if arg81 == true then
                startAutoFarm()
            else
                stopAutoFarm()
            end
        end,
    })
    var894:AddDropdown({
        Title = "Variants",
        Values = {"Normal", "Lay"},
        Options = {"Normal", "Lay"},
        Default = "Normal",
        Callback = function(arg82)
            if type(arg82) == "table" then
                arg82 = arg82[1]
            end
            autoFarmVariant = arg82 == "Lay" and "Lay" or "Normal"
            if autoFarmActive then
                if autoFarmVariant == "Lay" then
                    fn29()
                else
                    fn27()
                end
            end
        end,
    })
    var894:AddSlider({
        Title = "Farm Speed",
        Min = 7,
        Max = 30,
        Default = 12,
        Increment = 1,
        Callback = function(arg83)
            autoFarmSpeed = math.clamp(tonumber(arg83) or 12, 7, 30)
        end,
    })
    var894:AddSlider({
        Title = "Coin Collect Delay",
        Min = 0.4,
        Max = 2,
        Default = 1,
        Increment = 0.1,
        Callback = function(arg84)
            autoFarmCollectDelay = math.clamp(tonumber(arg84) or 1, 0.4, 2)
        end,
    })
    var894:AddToggle({
        Title = "Anti AFK",
        Default = false,
        Callback = function(arg85)
            antiAFKEnabled = arg85 == true
        end,
    })
    local var897 = var868:AddSection("COINS REACH", nil)
    var897:AddToggle({
        Title = "Coin Reach",
        Default = false,
        Callback = function(arg86)
            coinReachUserEnabled = arg86 == true
            fn23(coinReachUserEnabled or autoFarmOwnsCoinReach)
        end,
    })
    var897:AddSlider({
        Title = "Reach Range",
        Min = 4,
        Max = 7,
        Default = 4,
        Increment = 1,
        Callback = function(arg87)
            coinReachRange = math.clamp(tonumber(arg87) or 4, 4, 7)
            if coinReachEnabled then
                for obj, v55 in pairs(coinReachOriginals) do
                    if obj and obj.Parent and v55 then
                        pcall(function()
                            obj.Size = v55 * (autoFarmOwnsCoinReach and 5 or coinReachRange)
                        end)
                    end
                end
            end
        end,
    })
    local var898 = var868:AddSection("Remove 3D Rendering", nil)
    var898:AddToggle({
        Title = "Remove 3D Rendering",
        Default = false,
        Callback = function(arg88)
            colorCorrectionEffect.Enabled = arg88 == true
        end,
    })
    local var899 = var869:AddSection("Auto Shoot", nil)
    var899:AddToggle({
        Title = "Auto Shoot",
        Content = "Pc Press E",
        Default = false,
        Callback = function(arg89)
            autoShootActive = arg89 == true
            AutoShootEnabled = autoShootActive
            MobilePanelEnabled = autoShootActive
            MainPanel.Visible = autoShootActive
        end,
    })
    var899:AddDropdown({
        Title = "Variant",
        Values = {"Auto", "Flick"},
        Options = {"Auto", "Flick"},
        Default = "Auto",
        Callback = function(arg90)
            if type(arg90) == "table" then
                arg90 = arg90[1]
            end
            if arg90 ~= "Flick" then
                arg90 = "Auto"
            end
            autoShootVariant = arg90
        end,
    })
    var899:AddDropdown({
        Title = "Mode",
        Values = {"Legacy", "Astral"},
        Options = {"Legacy", "Astral"},
        Default = "Legacy",
        Callback = function(arg91)
            if type(arg91) == "table" then
                arg91 = arg91[1]
            end
            str = arg91 == "Astral" and "Astral" or "Legacy"
            var399 = setmetatable({}, {__mode = "k"})
        end,
    })
    var899:AddSlider({
        Title = "Panel Size",
        Min = 5,
        Max = 16,
        Default = 10,
        Increment = 1,
        Callback = function(arg92)
            UpdatePanelScale(arg92)
        end,
    })
    local var902 = var869:AddSection("Aimlock", nil)
    var902:AddToggle({
        Title = "Aimlock",
        Content = "Pc Press F",
        Default = false,
        Callback = function(arg93)
            aimbotActive = arg93 == true
            if not aimbotActive then
                aimlockEngaged = false
                aimbotFOVVisible = false
                clearAimlockTarget()
            end
            UpdateAimbotVisuals()
            AimbotPanel.Visible = arg93 == true
        end,
    })
    var902:AddSlider({
        Title = "Size",
        Min = 6,
        Max = 16,
        Default = 8,
        Increment = 1,
        Callback = function(arg94)
            UpdateAimbotPanelScale(arg94)
        end,
    })
    local var903 = var869:AddSection("Auto Pick Up Gun", nil)
    var903:AddToggle({
        Title = "Auto Pick Up Gun",
        Default = false,
        Callback = function(arg95)
            autoPickupGunActive = arg95 == true
            PickupPanel.Visible = arg95 == true
        end,
    })
    var903:AddSlider({
        Title = "Size",
        Min = 5,
        Max = 20,
        Default = 10,
        Increment = 1,
        Callback = function(arg96)
            UpdatePickupPanelScale(arg96)
        end,
    })
    local var904 = var869:AddSection("Fake Bomb Jump", nil)
    var904:AddToggle({
        Title = "Fake Bomb Jump",
        Content = "Pc Press Q",
        Default = false,
        Callback = function(arg97)
            fakeBombJumpEnabled = arg97 == true
            if fakeBombJumpEnabled then
                ensureFakeBombJumpPanel()
                FakeBombJumpPanel.Visible = fakeBombVariant == "Auto"
                fakeBombAutoJumpEnabled = fakeBombVariant == "Auto"
                scanFakeBombToolsOnce()
            else
                if FakeBombJumpPanel then
                    FakeBombJumpPanel.Visible = false
                end
                fakeBombCooldownUntil = 0
                fakeBombJumpReady = true
                fakeBombScreenTouchSuppress = false
                if FakeBombJumpLabel then
                    FakeBombJumpLabel.Text = "Ready"
                end
            end
        end,
    })
    var904:AddDropdown({
        Title = "Variant",
        Values = {"Auto", "Manual"},
        Options = {"Auto", "Manual"},
        Default = "Auto",
        Callback = function(arg98)
            if type(arg98) == "table" then
                arg98 = arg98[1]
            end
            if arg98 ~= "Manual" then
                arg98 = "Auto"
            end
            fakeBombVariant = arg98
            fakeBombAutoJumpEnabled = fakeBombVariant == "Auto"
            if FakeBombJumpPanel then
                FakeBombJumpPanel.Visible = fakeBombJumpEnabled and fakeBombVariant == "Auto"
            end
        end,
    })
    var904:AddSlider({
        Title = "Fake Bomb Jump Panel Size",
        Min = 6,
        Max = 20,
        Default = 10,
        Increment = 1,
        Callback = function(arg99)
            updateFakeBombJumpPanelScale(arg99)
        end,
    })
    local var906 = var872:AddSection("Murderer Kill section", nil)
    var906:AddButton({
        Title = "Kill All",
        Callback = function()
            killAll()
        end,
    })
    local var907 = var872:AddSection("Auto Throwing Knife", nil)
    var907:AddToggle({
        Title = "Auto Throwing Knife",
        Default = false,
        Callback = function(arg100)
            if arg100 == true then
                autoThrowKnifeEnabled = true
                enableAutoThrowKnife()
            else
                disableAutoThrowKnife()
            end
        end,
    })
    local var909 = var872:AddSection("Knife silence aim", nil)
    var909:AddToggle({
        Title = "Knife silence aim",
        Default = false,
        Callback = function(arg101)
            tbl19.enabled = arg101 == true
            if tbl19.enabled then
                fn83()
            else
                fn84()
            end
        end,
    })
    var909:AddToggle({
        Title = "Circle Aim",
        Default = false,
        Callback = function(arg102)
            tbl19.flag19 = arg102 == true
        end,
    })
    var909:AddSlider({
        Title = "Circle Size",
        Min = 30,
        Max = 300,
        Default = 150,
        Increment = 5,
        Callback = function(arg103)
            tbl19.num1 = math.clamp(tonumber(arg103) or 150, 30, 300)
        end,
    })
    var909:AddToggle({
        Title = "Draw Circle",
        Default = true,
        Callback = function(arg104)
            tbl19.flag20 = arg104 == true
        end,
    })
    var909:AddDropdown({
        Title = "Circle Color",
        Values = {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Purple", "Orange", "Pink", "Black"},
        Options = {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Purple", "Orange", "Pink", "Black"},
        Default = "White",
        Callback = function(arg105)
            if type(arg105) == "table" then
                arg105 = arg105[1]
            end
            local tbl22 = {
                White = Color3.fromRGB(255, 255, 255),
                Red = Color3.fromRGB(255, 70, 70),
                Green = Color3.fromRGB(80, 255, 120),
                Blue = Color3.fromRGB(80, 150, 255),
                Yellow = Color3.fromRGB(255, 220, 60),
                Cyan = Color3.fromRGB(80, 255, 255),
                Purple = Color3.fromRGB(190, 100, 255),
                Orange = Color3.fromRGB(255, 140, 60),
                Pink = Color3.fromRGB(255, 110, 190),
                Black = Color3.fromRGB(20, 20, 20),
            }
            tbl19.color31 = tbl22[arg105] or tbl22.White
        end,
    })
    var909:AddSlider({
        Title = "Knife Offset",
        Min = -5,
        Max = 5,
        Default = 1,
        Increment = 0.1,
        Callback = function(arg106)
            tbl19.num10 = math.clamp(tonumber(arg106) or 1, -5, 5)
        end,
    })
    var909:AddSlider({
        Title = "Knife Speed",
        Min = 10,
        Max = 200,
        Default = 80,
        Increment = 1,
        Callback = function(arg107)
            tbl19.num11 = math.clamp(tonumber(arg107) or 80, 10, 200)
        end,
    })
    var909:AddSlider({
        Title = "Knife Height",
        Min = -2,
        Max = 4,
        Default = 1.5,
        Increment = 0.1,
        Callback = function(arg108)
            tbl19.num12 = math.clamp(tonumber(arg108) or 1.5, -2, 4)
        end,
    })
    var909:AddToggle({
        Title = "Knife Ping Predict",
        Default = true,
        Callback = function(arg109)
            tbl19.flag21 = arg109 == true
        end,
    })
    var909:AddToggle({
        Title = "Knife Jump Predict",
        Default = true,
        Callback = function(arg110)
            tbl19.flag22 = arg110 == true
        end,
    })
    local var911 = var872:AddSection("Disable Footstep", nil)
    var911:AddToggle({
        Title = "Disable Footstep",
        Default = false,
        Callback = function(arg111)
            fn59(arg111 == true)
        end,
    })
    local var912 = var873:AddSection("Roles ESP", nil)
    var912:AddToggle({
        Title = "ESP Roles",
        Default = false,
        Callback = function(arg112)
            EspEnabled = arg112 == true
            if not EspEnabled then
                for k11 in pairs(roleBoxes) do
                    clearRoleBoxes(k11)
                end
            else
                if roleVisualSource == "FALLBACK" then
                    fn9()
                end
                for _, v56 in ipairs(Players:GetPlayers()) do
                    if v56 ~= localPlayer and v56.Character then
                        buildRoleBoxes(v56)
                    end
                end
            end
        end,
    })
    local var913 = var873:AddSection("Gun Dropped Charm", nil)
    var913:AddToggle({
        Title = "ESP Dropped Gun",
        Default = false,
        Callback = function(arg113)
            droppedGunEspEnabled = arg113 == true
            updateDroppedGunESP()
        end,
    })
    local var914 = var873:AddSection("Gun Dropped Name", nil)
    var914:AddToggle({
        Title = "Show Dropped gun esp name",
        Default = false,
        Callback = function(arg114)
            showDroppedGunEspNameEnabled = arg114 == true
            if not showDroppedGunEspNameEnabled then
                clearDroppedGunESPName()
            end
        end,
    })
    local var915 = var873:AddSection("Show rounds timer", nil)
    var915:AddToggle({
        Title = "Show rounds timer",
        Default = false,
        Callback = function(arg115)
            RoundTimerState.enabled = arg115 == true
            if RoundTimerState.enabled then
                fn5()
                RoundTimerState.gui.Enabled = true
                RoundTimerState.panel.Visible = true
                if RoundTimerState.phase == "RUNNING" then
                    RoundTimerState.label.Text = fn6(math.max(0, RoundTimerState.endAt - fn2()))
                else
                    RoundTimerState.label.Text = "0:00"
                end
                RoundTimerState.statsLabel.Text = string.format("FPS %d    Ping %dms", RoundTimerState.fps, fn3())
            else
                fn4(false)
            end
        end,
    })
    local var916 = var874:AddSection("Anti Fling / Fling", nil)
    var916:AddToggle({
        Title = "Anti Fling",
        Default = false,
        Callback = function(arg116)
            SetAntiFling(arg116 == true)
        end,
    })
    var916:AddToggle({
        Title = "Touch Fling",
        Default = false,
        Callback = function(arg117)
            SetTouchFling(arg117 == true)
        end,
    })
    local var919 = fn74()
    if #var919 > 0 then
        selectedFlingPlayerName = var919[1]
    end
    var789 = var916:AddDropdown({
        Title = "Select Player",
        Values = var919,
        Options = var919,
        Default = selectedFlingPlayerName,
        Callback = function(arg118)
            if type(arg118) == "table" then
                arg118 = arg118[1]
            end
            selectedFlingPlayerName = arg118
            if selectedFlingEnabled then
                fn73()
            end
        end,
    })
    var916:AddToggle({
        Title = "Fling Selected Player",
        Default = false,
        Callback = function(arg119)
            if arg119 == true then
                fn73()
            else
                fn69()
            end
        end,
    })
    var916:AddButton({
        Title = "Refresh Player List",
        Callback = function()
            fn75()
        end,
    })
    local var920 = var874:AddSection("Invisible", nil)
    var920:AddToggle({
        Title = "Invisible",
        Default = false,
        Callback = function(arg120)
            invisibleFeatureEnabled = arg120 == true
            if not invisibleFeatureEnabled and invisibleEnabled then
                var495(false)
            end
            if InvisiblePanel then
                InvisiblePanel.Visible = invisibleFeatureEnabled
            end
        end,
    })
    local var921 = var874:AddSection("Low Details mode", nil)
    var921:AddToggle({
        Title = "Low Details mode",
        Default = false,
        Callback = function(arg121)
            fn58(arg121 == true)
        end,
    })
    local var922 = var874:AddSection("Optimizer Coins", nil)
    var922:AddToggle({
        Title = "Delete Coins",
        Default = false,
        Callback = function(arg122)
            tbl15.flag1 = arg122 == true
            if tbl15.flag1 then
                fn62()
                fn67()
            else
                fn63()
            end
        end,
    })
    local var923 = var874:AddSection("Delete Pets", nil)
    var923:AddToggle({
        Title = "Delete Pets",
        Default = false,
        Callback = function(arg123)
            tbl15.flag18 = arg123 == true
            if tbl15.flag18 then
                fn65()
                fn67()
            else
                fn66()
            end
        end,
    })
    local var924 = var874:AddSection("Emotes", nil)
    for _, v57 in ipairs({"sit", "zombie", "ninja", "zen", "floss", "dab"}) do
        var924:AddButton({
            Title = "Emote: " .. v57:gsub("^%l", string.upper),
            Callback = function()
                PlayMiscEmote(v57)
            end,
        })
    end
    local var925 = var875:AddSection("Configuration", true)
    var925:AddConfig()
end
BuildUI()
flag2 = true
print("BOLONG-HUB MM2 - DISCORD.GG/PWPGQVGXNK LOADED!")
