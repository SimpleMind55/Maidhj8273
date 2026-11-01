--[[
  🎃 Word Game [RU] — Keyless Bot
  PlaceId: 71106427459865
  Dictionary: meow67676767/roblox-word-bot (55k+)
  No key / no auth
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local DICT_URL = "https://raw.githubusercontent.com/meow67676767/roblox-word-bot/main/russian_words_by_letter.json"

local Dict = {}          -- letter (lower) -> {words}
local Used = {}
local CurLetter = ""
local Mode = "Legit"     -- Legit | Rage
local RageOn = false
local RageDelay = 0.8
local LongWords = false
local NamesOn = false
local OverlayOpen = false
local overlayGui, overlayTitle, overlayScroll

local function lower(s)
    return string.lower(tostring(s or ""))
end

local function available(letter)
    letter = lower(letter)
    local t = {}
    for _, w in ipairs(Dict[letter] or {}) do
        if not Used[w] then
            if LongWords then
                if #w >= 8 then table.insert(t, w) end
            else
                table.insert(t, w)
            end
        end
    end
    return t
end

-- ─── load dictionary ───
local function loadDict()
    local body
    local ok = pcall(function()
        body = game:HttpGet(DICT_URL)
    end)
    if not ok or not body or #body < 100 then
        warn("[WordBot] failed to download dictionary")
        return false
    end
    local data
    ok = pcall(function()
        data = HttpService:JSONDecode(body)
    end)
    if not ok or type(data) ~= "table" then
        warn("[WordBot] bad JSON")
        return false
    end
    local n = 0
    for k, list in pairs(data) do
        local L = lower(k)
        Dict[L] = {}
        if type(list) == "table" then
            for _, w in ipairs(list) do
                if type(w) == "string" and #w >= 2 then
                    table.insert(Dict[L], lower(w))
                    n += 1
                end
            end
        end
    end
    print("[WordBot] loaded", n, "words")
    return true
end

-- ─── find game input ───
local function findInput()
    local best
    for _, obj in ipairs(PG:GetDescendants()) do
        if obj:IsA("TextBox") and obj.Visible and obj.AbsoluteSize.X > 40 then
            local n = lower(obj.Name .. " " .. (obj.PlaceholderText or ""))
            if n:find("word") or n:find("слов") or n:find("answer") or n:find("input")
                or n:find("guess") or n:find("ответ") or n:find("text") then
                return obj
            end
            best = best or obj
        end
    end
    return best
end

local function send(word)
    if not word or word == "" then return end
    word = lower(word)
    Used[word] = true

    local box = findInput()
    if box then
        pcall(function()
            box:CaptureFocus()
            task.wait(0.04)
            box.Text = ""
            task.wait()
            if Mode == "Legit" then
                -- humanized type
                for i = 1, #word do
                    box.Text = string.sub(word, 1, i)
                    task.wait(0.04 + math.random() * 0.04)
                end
            else
                box.Text = word
            end
            task.wait(0.05)
            VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.03)
            VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end)
        for _, b in ipairs(PG:GetDescendants()) do
            if b:IsA("TextButton") or b:IsA("ImageButton") then
                local t = lower(b.Name .. " " .. (b.Text or ""))
                if t:find("отправ") or t:find("submit") or t:find("send")
                    or t:find("готово") or t:find("enter") or t:find("ок") then
                    pcall(function() firesignal(b.MouseButton1Click) end)
                end
            end
        end
    end

    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = lower(v.Name)
            if n:find("word") or n:find("answer") or n:find("submit")
                or n:find("guess") or n:find("play") or n:find("say") then
                pcall(function() v:FireServer(word) end)
            end
        end
    end
    refreshOverlay()
end

-- ─── overlay ───
local function clearScroll()
    if not overlayScroll then return end
    for _, c in ipairs(overlayScroll:GetChildren()) do
        if c:IsA("TextButton") or c.Name == "empty" then c:Destroy() end
    end
end

function refreshOverlay()
    if not overlayScroll then return end
    clearScroll()
    if CurLetter == "" or not Dict[CurLetter] then
        if overlayTitle then overlayTitle.Text = "🎃  нет буквы" end
        local e = Instance.new("TextLabel")
        e.Name = "empty"
        e.Size = UDim2.new(1, 0, 0, 36)
        e.BackgroundTransparency = 1
        e.Text = "Введи букву в UI\nили дождись авто"
        e.TextColor3 = Color3.fromRGB(150, 150, 160)
        e.Font = Enum.Font.Gotham
        e.TextSize = 11
        e.TextWrapped = true
        e.Parent = overlayScroll
        return
    end
    local words = available(CurLetter)
    if overlayTitle then
        overlayTitle.Text = "🎃  " .. string.upper(CurLetter) .. "  (" .. #words .. ")"
    end
    if #words == 0 then
        local e = Instance.new("TextLabel")
        e.Name = "empty"
        e.Size = UDim2.new(1, 0, 0, 20)
        e.BackgroundTransparency = 1
        e.Text = "нет слов"
        e.TextColor3 = Color3.fromRGB(180, 90, 90)
        e.Font = Enum.Font.Gotham
        e.TextSize = 11
        e.Parent = overlayScroll
        return
    end
    local maxShow = math.min(#words, 80)
    for i = 1, maxShow do
        local w = words[i]
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -2, 0, 20)
        b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        b.BackgroundTransparency = 0.35
        b.Text = " " .. w
        b.TextColor3 = Color3.fromRGB(220, 220, 230)
        b.Font = Enum.Font.Gotham
        b.TextSize = 11
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.AutoButtonColor = false
        b.LayoutOrder = i
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.Parent = overlayScroll
        b.MouseButton1Click:Connect(function() send(w) end)
    end
end

local function destroyOverlay()
    if overlayGui then overlayGui:Destroy() end
    overlayGui, overlayTitle, overlayScroll = nil, nil, nil
    OverlayOpen = false
end

local function openOverlay()
    destroyOverlay()
    OverlayOpen = true
    overlayGui = Instance.new("ScreenGui")
    overlayGui.Name = "WordBotOverlay"
    overlayGui.ResetOnSpawn = false
    overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    overlayGui.IgnoreGuiInset = true
    overlayGui.Parent = (gethui and gethui()) or PG

    local panel = Instance.new("Frame")
    panel.Size = UDim2.fromOffset(190, 260)
    panel.Position = UDim2.new(0, 12, 0.28, 0)
    panel.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    panel.BackgroundTransparency = 0.25
    panel.BorderSizePixel = 0
    panel.Active = true
    panel.Draggable = true
    panel.Parent = overlayGui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", panel)
    st.Color = Color3.fromRGB(70, 70, 95)
    st.Transparency = 0.4

    overlayTitle = Instance.new("TextLabel", panel)
    overlayTitle.Size = UDim2.new(1, -30, 0, 24)
    overlayTitle.Position = UDim2.fromOffset(8, 4)
    overlayTitle.BackgroundTransparency = 1
    overlayTitle.Text = "🎃  —"
    overlayTitle.TextColor3 = Color3.fromRGB(235, 235, 245)
    overlayTitle.Font = Enum.Font.GothamBold
    overlayTitle.TextSize = 13
    overlayTitle.TextXAlignment = Enum.TextXAlignment.Left

    local close = Instance.new("TextButton", panel)
    close.Size = UDim2.fromOffset(20, 20)
    close.Position = UDim2.new(1, -24, 0, 5)
    close.BackgroundTransparency = 1
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(180, 180, 190)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.MouseButton1Click:Connect(destroyOverlay)

    overlayScroll = Instance.new("ScrollingFrame", panel)
    overlayScroll.Size = UDim2.new(1, -10, 1, -36)
    overlayScroll.Position = UDim2.fromOffset(5, 30)
    overlayScroll.BackgroundTransparency = 1
    overlayScroll.BorderSizePixel = 0
    overlayScroll.ScrollBarThickness = 2
    overlayScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    overlayScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UIListLayout", overlayScroll).Padding = UDim.new(0, 2)

    refreshOverlay()
end

local function setLetter(raw)
    local l = lower(raw):match("[а-яё]")
    if not l then return end
    if l == CurLetter then
        refreshOverlay()
        return
    end
    CurLetter = l
    if not OverlayOpen then openOverlay() end
    refreshOverlay()
    if RageOn then
        task.delay(RageDelay, function()
            if CurLetter == l then
                local ws = available(l)
                if #ws > 0 then
                    send(ws[math.random(1, math.min(5, #ws))])
                end
            end
        end)
    end
end

-- ─── auto letter from GUI ───
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, obj in ipairs(PG:GetDescendants()) do
                if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Visible then
                    local t = lower(obj.Text or "")
                    if #t > 0 and #t < 40 then
                        local l = t:match("букв[аы]?[%s:]*([а-яё])")
                               or t:match("%[([а-яё])%]")
                               or t:match("^%s*([а-яё])%s*$")
                        if l and Dict[l] then
                            setLetter(l)
                            return
                        end
                    end
                end
            end
        end)
    end
end)

-- ─── WindUI ───
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "🎃 Word Game [RU]",
    Icon = "book-open",
    Author = "Keyless · 55k dict",
    Folder = "WordBotKeyless",
    Size = UDim2.fromOffset(420, 360),
    Transparent = true,
    Theme = "Dark",
})

local Main = Window:Tab({ Title = "Основное", Icon = "zap" })

Main:Section({ Title = "Буква" })
Main:Input({
    Title = "Введи букву вручную",
    Placeholder = "к",
    Callback = function(txt)
        setLetter(txt)
        WindUI:Notify({ Title = "Буква", Content = string.upper(CurLetter or "?"), Duration = 1.5 })
    end,
})

Main:Section({ Title = "Окно слов" })
Main:Button({
    Title = "Открыть список слов",
    Callback = openOverlay,
})
Main:Button({
    Title = "Закрыть список",
    Callback = destroyOverlay,
})

Main:Section({ Title = "Режим" })
Main:Dropdown({
    Title = "Режим ввода",
    Values = { "Legit", "Rage" },
    Value = "Legit",
    Callback = function(v) Mode = v end,
})
Main:Toggle({
    Title = "Rage авто-ответ",
    Value = false,
    Callback = function(v) RageOn = v end,
})
Main:Slider({
    Title = "Задержка Rage (сек)",
    Value = { Min = 0, Max = 3, Default = 0.8 },
    Callback = function(v) RageDelay = v end,
})
Main:Toggle({
    Title = "Длинные слова (8+)",
    Value = false,
    Callback = function(v)
        LongWords = v
        refreshOverlay()
    end,
})

Main:Section({ Title = "Действия" })
Main:Button({
    Title = "Ответить сейчас (1-е слово)",
    Callback = function()
        if CurLetter == "" then
            WindUI:Notify({ Title = "Нет буквы", Content = "Введи букву", Duration = 2 })
            return
        end
        local ws = available(CurLetter)
        if #ws > 0 then send(ws[1]) else
            WindUI:Notify({ Title = "Пусто", Content = "Нет слов", Duration = 2 })
        end
    end,
})
Main:Button({
    Title = "Сбросить использованные",
    Callback = function()
        Used = {}
        refreshOverlay()
        WindUI:Notify({ Title = "Сброс", Content = "История очищена", Duration = 2 })
    end,
})

Main:Paragraph({
    Title = "Подсказка",
    Desc = "Словарь грузится с GitHub. Клик по слову вставляет в поле игры. RightShift = быстрый ответ. Без ключа.",
})

UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift or inp.KeyCode == Enum.KeyCode.LeftControl then
        if CurLetter ~= "" then
            local ws = available(CurLetter)
            if #ws > 0 then send(ws[1]) end
        end
    end
end)

-- boot
task.spawn(function()
    WindUI:Notify({ Title = "WordBot", Content = "Гружу словарь 55k…", Duration = 3 })
    if loadDict() then
        WindUI:Notify({ Title = "Готово", Content = "Словарь загружен. Введи букву.", Duration = 3 })
    else
        WindUI:Notify({ Title = "Ошибка", Content = "Не скачался словарь", Duration = 4 })
    end
end)

print("[WordBot] keyless ready · PlaceId", game.PlaceId)
