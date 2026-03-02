--[[
    NexusLib — Roblox UI Library
    Aesthetic: Dark, modern, rounded — inspired by UBS_Main
    Features: Windows, Tabs, Sections, Buttons, Toggles, Sliders,
              Dropdowns, Textboxes, Keybinds, ColorPickers, Labels,
              Separators, Notifications, Prompts, Credits, Configs, Themes
]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- PREVENT DUPLICATE LOAD
-- ============================================================
if getgenv and getgenv().NexusLib then
    getgenv().NexusLib:Destroy()
end

-- ============================================================
-- LIBRARY TABLE
-- ============================================================
local NexusLib = {
    Flags       = {},
    Options     = {},
    Connections = {},
    Instances   = {},
    Windows     = {},
    Themes      = {},
    FolderName  = "NexusLib_Configs",
    FileExt     = ".json",
}
NexusLib.__index = NexusLib

if getgenv then
    getgenv().NexusLib = NexusLib
end

-- ============================================================
-- BUILT-IN THEMES
-- ============================================================
NexusLib.Themes = {
    Dark = {
        Background      = Color3.fromRGB(22, 22, 27),
        SecondaryBg     = Color3.fromRGB(30, 30, 36),
        TertiaryBg      = Color3.fromRGB(38, 38, 46),
        ElementBg       = Color3.fromRGB(44, 44, 54),
        ElementHover    = Color3.fromRGB(54, 54, 66),
        Accent          = Color3.fromRGB(80, 130, 230),
        AccentHover     = Color3.fromRGB(100, 150, 250),
        TextPrimary     = Color3.fromRGB(240, 240, 245),
        TextSecondary   = Color3.fromRGB(160, 160, 175),
        TextDim         = Color3.fromRGB(100, 100, 115),
        Success         = Color3.fromRGB(80, 200, 120),
        Danger          = Color3.fromRGB(210, 65, 65),
        Warning         = Color3.fromRGB(220, 160, 50),
        ScrollBar       = Color3.fromRGB(55, 55, 68),
        Border          = Color3.fromRGB(55, 55, 68),
        Shadow          = Color3.fromRGB(10, 10, 14),
        ToggleOn        = Color3.fromRGB(70, 185, 120),
        ToggleOff       = Color3.fromRGB(70, 70, 85),
    },
    Ocean = {
        Background      = Color3.fromRGB(15, 22, 35),
        SecondaryBg     = Color3.fromRGB(20, 30, 48),
        TertiaryBg      = Color3.fromRGB(26, 40, 62),
        ElementBg       = Color3.fromRGB(32, 50, 78),
        ElementHover    = Color3.fromRGB(40, 62, 96),
        Accent          = Color3.fromRGB(45, 185, 210),
        AccentHover     = Color3.fromRGB(60, 210, 235),
        TextPrimary     = Color3.fromRGB(230, 240, 255),
        TextSecondary   = Color3.fromRGB(140, 170, 210),
        TextDim         = Color3.fromRGB(80, 110, 155),
        Success         = Color3.fromRGB(60, 200, 150),
        Danger          = Color3.fromRGB(210, 65, 65),
        Warning         = Color3.fromRGB(220, 160, 50),
        ScrollBar       = Color3.fromRGB(40, 65, 100),
        Border          = Color3.fromRGB(40, 65, 100),
        Shadow          = Color3.fromRGB(5, 10, 20),
        ToggleOn        = Color3.fromRGB(45, 185, 210),
        ToggleOff       = Color3.fromRGB(32, 50, 78),
    },
    Midnight = {
        Background      = Color3.fromRGB(18, 15, 28),
        SecondaryBg     = Color3.fromRGB(25, 20, 38),
        TertiaryBg      = Color3.fromRGB(34, 28, 52),
        ElementBg       = Color3.fromRGB(42, 35, 64),
        ElementHover    = Color3.fromRGB(54, 45, 82),
        Accent          = Color3.fromRGB(155, 90, 240),
        AccentHover     = Color3.fromRGB(175, 110, 255),
        TextPrimary     = Color3.fromRGB(235, 228, 255),
        TextSecondary   = Color3.fromRGB(160, 145, 200),
        TextDim         = Color3.fromRGB(100, 88, 135),
        Success         = Color3.fromRGB(80, 200, 120),
        Danger          = Color3.fromRGB(210, 65, 65),
        Warning         = Color3.fromRGB(220, 160, 50),
        ScrollBar       = Color3.fromRGB(54, 44, 82),
        Border          = Color3.fromRGB(54, 44, 82),
        Shadow          = Color3.fromRGB(8, 5, 15),
        ToggleOn        = Color3.fromRGB(155, 90, 240),
        ToggleOff       = Color3.fromRGB(42, 35, 64),
    },
    Crimson = {
        Background      = Color3.fromRGB(22, 15, 15),
        SecondaryBg     = Color3.fromRGB(32, 20, 20),
        TertiaryBg      = Color3.fromRGB(44, 28, 28),
        ElementBg       = Color3.fromRGB(55, 35, 35),
        ElementHover    = Color3.fromRGB(68, 44, 44),
        Accent          = Color3.fromRGB(210, 55, 80),
        AccentHover     = Color3.fromRGB(235, 70, 95),
        TextPrimary     = Color3.fromRGB(250, 230, 230),
        TextSecondary   = Color3.fromRGB(190, 155, 155),
        TextDim         = Color3.fromRGB(130, 95, 95),
        Success         = Color3.fromRGB(80, 200, 120),
        Danger          = Color3.fromRGB(210, 65, 65),
        Warning         = Color3.fromRGB(220, 160, 50),
        ScrollBar       = Color3.fromRGB(65, 40, 40),
        Border          = Color3.fromRGB(65, 40, 40),
        Shadow          = Color3.fromRGB(10, 5, 5),
        ToggleOn        = Color3.fromRGB(210, 55, 80),
        ToggleOff       = Color3.fromRGB(55, 35, 35),
    },
}

-- Active theme
NexusLib.ActiveTheme = NexusLib.Themes.Dark

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function tween(instance, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    return TweenService:Create(instance, TweenInfo.new(duration or 0.15, style, direction), props)
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Color3.fromRGB(60, 60, 75)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    return s
end

local function makePadding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, top    or 6)
    p.PaddingBottom = UDim.new(0, bottom or 6)
    p.PaddingLeft   = UDim.new(0, left   or 8)
    p.PaddingRight  = UDim.new(0, right  or 8)
    return p
end

local function addHover(btn, normalColor, hoverColor, duration)
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = hoverColor}, duration or 0.1):Play()
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = normalColor}, duration or 0.1):Play()
    end)
end

local function addClickAnim(btn)
    btn.MouseButton1Down:Connect(function()
        tween(btn, {BackgroundTransparency = 0.3}, 0.07):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, {BackgroundTransparency = 0}, 0.07):Play()
    end)
end

local function newInstance(class, properties, parent)
    local inst = Instance.new(class)
    if parent then inst.Parent = parent end
    for k, v in pairs(properties or {}) do
        inst[k] = v
    end
    return inst
end

-- Config folder
local function ensureFolder()
    if isfolder and not isfolder(NexusLib.FolderName) then
        makefolder(NexusLib.FolderName)
    end
end

-- ============================================================
-- SCREEN GUI ROOT
-- ============================================================
local ScreenGui = newInstance("ScreenGui", {
    Name            = "NexusLib",
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local NotifHolder = newInstance("Frame", {
    Name                 = "NotifHolder",
    Size                 = UDim2.new(0, 280, 1, 0),
    Position             = UDim2.new(1, -295, 0, 0),
    BackgroundTransparency = 1,
    AnchorPoint          = Vector2.new(0, 0),
}, ScreenGui)

local NotifList = newInstance("UIListLayout", {
    FillDirection   = Enum.FillDirection.Vertical,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding         = UDim.new(0, 6),
    SortOrder       = Enum.SortOrder.LayoutOrder,
}, NotifHolder)

newInstance("UIPadding", {
    PaddingBottom = UDim.new(0, 12),
    PaddingRight  = UDim.new(0, 0),
}, NotifHolder)

function NexusLib:Notify(options)
    options = options or {}
    local T     = NexusLib.ActiveTheme
    local title = options.Title    or "Notification"
    local text  = options.Text     or ""
    local dur   = options.Duration or 4
    local ntype = options.Type     or "Info" -- Info, Success, Danger, Warning

    local accentMap = {
        Info    = T.Accent,
        Success = T.Success,
        Danger  = T.Danger,
        Warning = T.Warning,
    }
    local accent = accentMap[ntype] or T.Accent

    local card = newInstance("Frame", {
        Name              = "Notification",
        Size              = UDim2.new(1, 0, 0, 72),
        BackgroundColor3  = T.SecondaryBg,
        BackgroundTransparency = 0,
        ClipsDescendants  = true,
    }, NotifHolder)
    makeCorner(card, 10)
    makeStroke(card, T.Border, 1)

    -- Accent bar
    local bar = newInstance("Frame", {
        Size             = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
    }, card)
    makeCorner(bar, 4)

    -- Title
    newInstance("TextLabel", {
        Size             = UDim2.new(1, -20, 0, 22),
        Position         = UDim2.fromOffset(14, 10),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = T.TextPrimary,
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, card)

    -- Body
    newInstance("TextLabel", {
        Size             = UDim2.new(1, -20, 0, 30),
        Position         = UDim2.fromOffset(14, 34),
        BackgroundTransparency = 1,
        Text             = text,
        TextColor3       = T.TextSecondary,
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
    }, card)

    -- Progress bar
    local progress = newInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 3),
        Position         = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
    }, card)

    -- Slide in
    card.Position = UDim2.new(1, 20, 0, 0)
    tween(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart):Play()

    -- Progress shrink
    task.delay(0.3, function()
        tween(progress, {Size = UDim2.new(0, 0, 0, 3)}, dur - 0.3):Play()
    end)

    task.delay(dur, function()
        tween(card, {BackgroundTransparency = 1}, 0.2):Play()
        task.wait(0.2)
        card:Destroy()
        if options.Callback then options.Callback() end
    end)

    return card
end

-- ============================================================
-- PROMPT / DIALOG SYSTEM
-- ============================================================
function NexusLib:Prompt(options)
    options = options or {}
    local T       = NexusLib.ActiveTheme
    local title   = options.Title   or "Prompt"
    local text    = options.Text    or "Are you sure?"
    local buttons = options.Buttons or { OK = function() end }

    -- Backdrop
    local backdrop = newInstance("Frame", {
        Name             = "PromptBackdrop",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        ZIndex           = 200,
    }, ScreenGui)

    local box = newInstance("Frame", {
        Name             = "PromptBox",
        Size             = UDim2.fromOffset(360, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = T.SecondaryBg,
        ClipsDescendants = true,
        ZIndex           = 201,
        AutomaticSize    = Enum.AutomaticSize.Y,
    }, ScreenGui)
    makeCorner(box, 12)
    makeStroke(box, T.Border, 1)

    local layout = newInstance("UIListLayout", {
        SortOrder         = Enum.SortOrder.LayoutOrder,
        Padding           = UDim.new(0, 0),
    }, box)

    -- Header
    local header = newInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.TertiaryBg,
        BorderSizePixel  = 0,
        LayoutOrder      = 1,
        ZIndex           = 202,
    }, box)

    newInstance("TextLabel", {
        Size             = UDim2.new(1, -20, 1, 0),
        Position         = UDim2.fromOffset(16, 0),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = T.TextPrimary,
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 202,
    }, header)

    -- Body
    local body = newInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize    = Enum.AutomaticSize.Y,
        LayoutOrder      = 2,
        ZIndex           = 202,
    }, box)
    makePadding(body, 14, 14, 16, 16)

    newInstance("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = text,
        TextColor3       = T.TextSecondary,
        Font             = Enum.Font.Gotham,
        TextSize         = 13,
        TextWrapped      = true,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 202,
    }, body)

    -- Buttons row
    local btnRow = newInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        LayoutOrder      = 3,
        ZIndex           = 202,
    }, box)
    makePadding(btnRow, 8, 8, 12, 12)

    local btnLayout = newInstance("UIListLayout", {
        FillDirection    = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding          = UDim.new(0, 8),
        SortOrder        = Enum.SortOrder.LayoutOrder,
    }, btnRow)

    local resultEvent = Instance.new("BindableEvent")
    local btnIdx = 0
    for label, callback in pairs(buttons) do
        btnIdx = btnIdx + 1
        local isFirst = (btnIdx == 1)
        local btn = newInstance("TextButton", {
            Size             = UDim2.fromOffset(90, 34),
            BackgroundColor3 = isFirst and T.Accent or T.ElementBg,
            Text             = label,
            TextColor3       = T.TextPrimary,
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
            ZIndex           = 202,
            LayoutOrder      = btnIdx,
        }, btnRow)
        makeCorner(btn, 7)
        addHover(btn, btn.BackgroundColor3, isFirst and T.AccentHover or T.ElementHover)

        btn.MouseButton1Click:Connect(function()
            backdrop:Destroy()
            box:Destroy()
            resultEvent:Fire(label)
            if callback then callback() end
        end)
    end

    -- Animate in
    box.Size = UDim2.fromOffset(360, 0)
    local r = resultEvent.Event:Wait()
    resultEvent:Destroy()
    return r
end

-- ============================================================
-- WINDOW CREATION
-- ============================================================
function NexusLib:CreateWindow(options)
    options = options or {}
    local T         = NexusLib.ActiveTheme
    local winName   = options.Name   or "Nexus"
    local winSize   = options.Size   or Vector2.new(580, 400)
    local logoId    = options.Logo   or nil
    local link      = options.Link   or nil
    local theme     = options.Theme  or nil

    if theme then
        NexusLib.ActiveTheme = type(theme) == "table" and theme or (NexusLib.Themes[theme] or T)
        T = NexusLib.ActiveTheme
    end

    -- ── Root Frame ──────────────────────────────────────────
    local mainFrame = newInstance("Frame", {
        Name             = "NexusWindow_" .. winName,
        Size             = UDim2.fromOffset(winSize.X, winSize.Y),
        Position         = UDim2.new(0.5, -winSize.X/2, 0.5, -winSize.Y/2),
        BackgroundColor3 = T.Background,
        ClipsDescendants = true,
    }, ScreenGui)
    makeCorner(mainFrame, 12)
    makeStroke(mainFrame, T.Border, 1)

    -- Drop shadow
    local shadow = newInstance("ImageLabel", {
        Name             = "Shadow",
        Size             = UDim2.new(1, 30, 1, 30),
        Position         = UDim2.new(0, -15, 0, -10),
        BackgroundTransparency = 1,
        Image            = "rbxassetid://6015897843",
        ImageColor3      = T.Shadow,
        ImageTransparency = 0.5,
        ZIndex           = 0,
    }, mainFrame)

    -- ── Title Bar ────────────────────────────────────────────
    local titleBar = newInstance("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.SecondaryBg,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, mainFrame)

    -- Fix bottom of title bar (overlap so no gap)
    newInstance("Frame", {
        Size             = UDim2.new(1, 0, 0, 12),
        Position         = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = T.SecondaryBg,
        BorderSizePixel  = 0,
    }, titleBar)

    -- Logo
    if logoId then
        newInstance("ImageLabel", {
            Size             = UDim2.fromOffset(24, 24),
            Position         = UDim2.fromOffset(12, 9),
            BackgroundTransparency = 1,
            Image            = logoId,
        }, titleBar)
    end

    -- Title label
    newInstance("TextLabel", {
        Size             = UDim2.new(1, -130, 1, 0),
        Position         = UDim2.fromOffset(logoId and 42 or 14, 0),
        BackgroundTransparency = 1,
        Text             = winName,
        TextColor3       = T.TextPrimary,
        Font             = Enum.Font.GothamBold,
        TextSize          = 15,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, titleBar)

    -- Window control buttons
    local function makeWinBtn(xOff, color, symbol)
        local b = newInstance("TextButton", {
            Size             = UDim2.fromOffset(28, 28),
            Position         = UDim2.new(1, xOff, 0.5, -14),
            BackgroundColor3 = color,
            Text             = symbol,
            TextColor3       = T.TextPrimary,
            Font             = Enum.Font.GothamBold,
            TextSize         = 16,
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
        }, titleBar)
        makeCorner(b, 6)
        return b
    end

    local closeBtn    = makeWinBtn(-10,  T.Danger,      "×")
    local minimizeBtn = makeWinBtn(-44,  T.ElementBg,   "−")

    -- ── Content Area ─────────────────────────────────────────
    local contentFrame = newInstance("Frame", {
        Name             = "Content",
        Size             = UDim2.new(1, 0, 1, -42),
        Position         = UDim2.fromOffset(0, 42),
        BackgroundTransparency = 1,
    }, mainFrame)

    -- ── Sidebar ───────────────────────────────────────────────
    local sidebar = newInstance("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 128, 1, 0),
        BackgroundColor3 = T.SecondaryBg,
        BorderSizePixel  = 0,
    }, contentFrame)

    local sideList = newInstance("UIListLayout", {
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Padding          = UDim.new(0, 3),
    }, sidebar)
    makePadding(sidebar, 8, 8, 6, 6)

    -- ── Display Area ──────────────────────────────────────────
    local displayArea = newInstance("Frame", {
        Name             = "Display",
        Size             = UDim2.new(1, -128, 1, 0),
        Position         = UDim2.fromOffset(128, 0),
        BackgroundTransparency = 1,
    }, contentFrame)

    -- ── Drag System ───────────────────────────────────────────
    local dragging, dragStart, startPos = false, nil, nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos  = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── Minimize ─────────────────────────────────────────────
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(mainFrame,
            {Size = minimized and UDim2.fromOffset(winSize.X, 42) or UDim2.fromOffset(winSize.X, winSize.Y)},
            0.25, Enum.EasingStyle.Quart
        ):Play()
        minimizeBtn.Text = minimized and "+" or "−"
    end)

    -- ── Close ─────────────────────────────────────────────────
    closeBtn.MouseButton1Click:Connect(function()
        tween(mainFrame, {BackgroundTransparency = 1, Size = UDim2.fromOffset(winSize.X * 0.85, winSize.Y * 0.85)}, 0.2):Play()
        task.wait(0.2)
        mainFrame:Destroy()
    end)

    -- Hover effects on window buttons
    addHover(closeBtn, T.Danger, Color3.fromRGB(235, 80, 80))
    addHover(minimizeBtn, T.ElementBg, T.ElementHover)

    -- ── Window Object ──────────────────────────────────────────
    local Window = {
        _frame      = mainFrame,
        _sidebar    = sidebar,
        _display    = displayArea,
        _tabs       = {},
        _activeTab  = nil,
        _theme      = T,
    }

    -- ── STATUS BAR ────────────────────────────────────────────
    local statusBar = newInstance("Frame", {
        Name             = "StatusBar",
        Size             = UDim2.new(1, -128, 0, 22),
        Position         = UDim2.new(0, 128, 1, -22),
        BackgroundColor3 = T.SecondaryBg,
        BorderSizePixel  = 0,
    }, contentFrame)

    local statusLabel = newInstance("TextLabel", {
        Size             = UDim2.new(1, -10, 1, 0),
        Position         = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text             = link and ("🔗 " .. link) or "Ready",
        TextColor3       = T.TextDim,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, statusBar)

    function Window:SetStatus(text)
        statusLabel.Text = tostring(text)
    end

    -- ── TAB CREATION ──────────────────────────────────────────
    function Window:AddTab(options)
        options = options or {}
        local tabName = options.Name or ("Tab " .. (#self._tabs + 1))
        local tabIcon = options.Icon or nil
        local T2 = self._theme

        -- Sidebar button
        local tabBtn = newInstance("TextButton", {
            Name             = "Tab_" .. tabName,
            Size             = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = T2.TertiaryBg,
            Text             = (tabIcon and "  ") or "" .. tabName,
            TextColor3       = T2.TextSecondary,
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
            LayoutOrder      = #self._tabs + 1,
        }, sidebar)
        makeCorner(tabBtn, 7)

        if tabIcon then
            newInstance("ImageLabel", {
                Size             = UDim2.fromOffset(18, 18),
                Position         = UDim2.fromOffset(8, 10),
                BackgroundTransparency = 1,
                Image            = tabIcon,
                ImageColor3      = T2.TextSecondary,
            }, tabBtn)
        end

        -- Scroll frame for tab content
        local scroll = newInstance("ScrollingFrame", {
            Name                    = "Scroll_" .. tabName,
            Size                    = UDim2.new(1, 0, 1, -22),
            BackgroundTransparency  = 1,
            BorderSizePixel         = 0,
            ScrollBarThickness      = 4,
            ScrollBarImageColor3    = T2.ScrollBar,
            CanvasSize              = UDim2.new(0, 0, 0, 0),
            Visible                 = false,
            AutomaticCanvasSize     = Enum.AutomaticSize.Y,
        }, displayArea)

        local listLayout = newInstance("UIListLayout", {
            SortOrder  = Enum.SortOrder.LayoutOrder,
            Padding    = UDim.new(0, 6),
        }, scroll)
        makePadding(scroll, 8, 8, 8, 12)

        -- Tab data
        local Tab = {
            _btn     = tabBtn,
            _scroll  = scroll,
            _layout  = listLayout,
            _window  = self,
            _theme   = T2,
        }
        table.insert(self._tabs, Tab)

        -- Activate tab
        local function activate()
            for _, t in pairs(self._tabs) do
                t._scroll.Visible = false
                tween(t._btn, {BackgroundColor3 = T2.TertiaryBg, TextColor3 = T2.TextSecondary}, 0.1):Play()
            end
            scroll.Visible = true
            tween(tabBtn, {BackgroundColor3 = T2.Accent, TextColor3 = T2.TextPrimary}, 0.1):Play()
            self._activeTab = Tab
        end

        tabBtn.MouseButton1Click:Connect(activate)
        addHover(tabBtn, T2.TertiaryBg, T2.ElementBg)

        if #self._tabs == 1 then activate() end

        -- ── SECTION ─────────────────────────────────────────
        function Tab:AddSection(options)
            options = options or {}
            local secName = options.Name or "Section"
            local T3 = self._theme

            local secFrame = newInstance("Frame", {
                Name             = "Section_" .. secName,
                Size             = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = T3.SecondaryBg,
                BorderSizePixel  = 0,
                AutomaticSize    = Enum.AutomaticSize.Y,
                LayoutOrder      = #scroll:GetChildren(),
            }, scroll)
            makeCorner(secFrame, 9)
            makeStroke(secFrame, T3.Border, 1)

            local secLayout = newInstance("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 4),
            }, secFrame)
            makePadding(secFrame, 8, 8, 8, 8)

            -- Section header
            local header = newInstance("Frame", {
                Size             = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = T3.TertiaryBg,
                BorderSizePixel  = 0,
                LayoutOrder      = 0,
            }, secFrame)
            makeCorner(header, 6)

            newInstance("TextLabel", {
                Size             = UDim2.new(1, -10, 1, 0),
                Position         = UDim2.fromOffset(8, 0),
                BackgroundTransparency = 1,
                Text             = secName,
                TextColor3       = T3.Accent,
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
            }, header)

            -- ── Section Object ──────────────────────────────
            local Section = {
                _frame  = secFrame,
                _layout = secLayout,
                _order  = 1,
                _theme  = T3,
            }

            local function nextOrder()
                Section._order = Section._order + 1
                return Section._order
            end

            -- ─────────────────────────────────────────────────
            -- BUTTON
            -- ─────────────────────────────────────────────────
            function Section:AddButton(options)
                options = options or {}
                local T4 = self._theme
                local label = options.Name        or "Button"
                local desc  = options.Description or nil
                local cb    = options.Callback    or function() end

                local h = desc and 52 or 34
                local btn = newInstance("TextButton", {
                    Size             = UDim2.new(1, 0, 0, h),
                    BackgroundColor3 = T4.ElementBg,
                    Text             = "",
                    BorderSizePixel  = 0,
                    AutoButtonColor  = false,
                    LayoutOrder      = nextOrder(),
                }, secFrame)
                makeCorner(btn, 6)

                newInstance("TextLabel", {
                    Size             = UDim2.new(1, -12, 0, 20),
                    Position         = UDim2.fromOffset(10, desc and 7 or 7),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = T4.TextPrimary,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, btn)

                if desc then
                    newInstance("TextLabel", {
                        Size             = UDim2.new(1, -12, 0, 16),
                        Position         = UDim2.fromOffset(10, 28),
                        BackgroundTransparency = 1,
                        Text             = desc,
                        TextColor3       = T4.TextDim,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 11,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                    }, btn)
                end

                -- Accent left bar
                local accent = newInstance("Frame", {
                    Size             = UDim2.new(0, 3, 0.6, 0),
                    Position         = UDim2.new(0, 0, 0.2, 0),
                    BackgroundColor3 = T4.Accent,
                    BorderSizePixel  = 0,
                }, btn)
                makeCorner(accent, 2)

                addHover(btn, T4.ElementBg, T4.ElementHover)
                addClickAnim(btn)

                btn.MouseButton1Click:Connect(cb)

                local BtnObj = {_btn = btn}
                function BtnObj:SetName(name) btn:FindFirstChildOfClass("TextLabel").Text = name end
                function BtnObj:SetCallback(fn) cb = fn end
                return BtnObj
            end

            -- ─────────────────────────────────────────────────
            -- TOGGLE
            -- ─────────────────────────────────────────────────
            function Section:AddToggle(options)
                options = options or {}
                local T4    = self._theme
                local label = options.Name         or "Toggle"
                local desc  = options.Description  or nil
                local start = options.Default       or false
                local flag  = options.Flag          or nil
                local cb    = options.Callback      or function() end

                local state = start

                local row = newInstance("Frame", {
                    Size             = UDim2.new(1, 0, 0, desc and 50 or 34),
                    BackgroundColor3 = T4.ElementBg,
                    BorderSizePixel  = 0,
                    LayoutOrder      = nextOrder(),
                }, secFrame)
                makeCorner(row, 6)

                newInstance("TextLabel", {
                    Size             = UDim2.new(1, -60, 0, 20),
                    Position         = UDim2.fromOffset(10, desc and 7 or 7),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = T4.TextPrimary,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, row)

                if desc then
                    newInstance("TextLabel", {
                        Size             = UDim2.new(1, -60, 0, 16),
                        Position         = UDim2.fromOffset(10, 28),
                        BackgroundTransparency = 1,
                        Text             = desc,
                        TextColor3       = T4.TextDim,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 11,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                    }, row)
                end

                -- Toggle pill
                local pillBg = newInstance("Frame", {
                    Size             = UDim2.fromOffset(44, 22),
                    Position         = UDim2.new(1, -52, 0.5, -11),
                    BackgroundColor3 = state and T4.ToggleOn or T4.ToggleOff,
                    BorderSizePixel  = 0,
                }, row)
                makeCorner(pillBg, 11)

                local knob = newInstance("Frame", {
                    Size             = UDim2.fromOffset(16, 16),
                    Position         = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel  = 0,
                }, pillBg)
                makeCorner(knob, 8)

                if flag then NexusLib.Flags[flag] = state end

                local function setToggle(val, silent)
                    state = val
                    if flag then NexusLib.Flags[flag] = state end
                    tween(pillBg, {BackgroundColor3 = state and T4.ToggleOn or T4.ToggleOff}, 0.15):Play()
                    tween(knob,   {Position = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)}, 0.15):Play()
                    if not silent then cb(state) end
                end

                local clickArea = newInstance("TextButton", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = "",
                }, row)
                addHover(row, T4.ElementBg, T4.ElementHover)
                clickArea.MouseButton1Click:Connect(function()
                    setToggle(not state)
                end)

                local ToggleObj = {_state = state}
                function ToggleObj:Set(val) setToggle(val, true) end
                function ToggleObj:Get() return state end
                function ToggleObj:SetCallback(fn) cb = fn end
                return ToggleObj
            end

            -- ─────────────────────────────────────────────────
            -- SLIDER
            -- ─────────────────────────────────────────────────
            function Section:AddSlider(options)
                options = options or {}
                local T4    = self._theme
                local label = options.Name     or "Slider"
                local min   = options.Min      or 0
                local max   = options.Max      or 100
                local def   = options.Default  or min
                local suf   = options.Suffix   or ""
                local prec  = options.Precision or 0
                local flag  = options.Flag     or nil
                local cb    = options.Callback or function() end

                local value = math.clamp(def, min, max)

                local row = newInstance("Frame", {
                    Size             = UDim2.new(1, 0, 0, 52),
                    BackgroundColor3 = T4.ElementBg,
                    BorderSizePixel  = 0,
                    LayoutOrder      = nextOrder(),
                }, secFrame)
                makeCorner(row, 6)

                -- Labels row
                newInstance("TextLabel", {
                    Size             = UDim2.new(0.6, 0, 0, 18),
                    Position         = UDim2.fromOffset(10, 8),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = T4.TextPrimary,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, row)

                local valLabel = newInstance("TextLabel", {
                    Size             = UDim2.new(0.4, -10, 0, 18),
                    Position         = UDim2.new(0.6, 0, 0, 8),
                    BackgroundTransparency = 1,
                    Text             = string.format("%." .. prec .. "f", value) .. suf,
                    TextColor3       = T4.Accent,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Right,
                }, row)

                -- Track
                local track = newInstance("Frame", {
                    Size             = UDim2.new(1, -20, 0, 6),
                    Position         = UDim2.fromOffset(10, 36),
                    BackgroundColor3 = T4.TertiaryBg,
                    BorderSizePixel  = 0,
                }, row)
                makeCorner(track, 3)

                local pct = (value - min) / (max - min)
                local fill = newInstance("Frame", {
                    Size             = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = T4.Accent,
                    BorderSizePixel  = 0,
                }, track)
                makeCorner(fill, 3)

                local thumb = newInstance("Frame", {
                    Size             = UDim2.fromOffset(14, 14),
                    Position         = UDim2.new(pct, -7, 0.5, -7),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel  = 0,
                }, track)
                makeCorner(thumb, 7)

                if flag then NexusLib.Flags[flag] = value end

                local function updateSlider(v)
                    v = math.clamp(v, min, max)
                    local fmt = "%." .. prec .. "f"
                    if prec == 0 then v = math.floor(v + 0.5) end
                    value = v
                    if flag then NexusLib.Flags[flag] = value end
                    local p = (v - min) / (max - min)
                    fill.Size     = UDim2.new(p, 0, 1, 0)
                    thumb.Position = UDim2.new(p, -7, 0.5, -7)
                    valLabel.Text = string.format(fmt, v) .. suf
                    cb(v)
                end

                local sliding = false
                local inputArea = newInstance("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 22),
                    Position         = UDim2.fromOffset(0, 30),
                    BackgroundTransparency = 1,
                    Text             = "",
                    BorderSizePixel  = 0,
                }, row)

                local function sliderFromMouse(x)
                    local abs = track.AbsolutePosition.X
                    local sz  = track.AbsoluteSize.X
                    local p   = math.clamp((x - abs) / sz, 0, 1)
                    updateSlider(min + p * (max - min))
                end

                inputArea.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        sliderFromMouse(inp.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        sliderFromMouse(inp.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)

                local SliderObj = {}
                function SliderObj:Set(v) updateSlider(v) end
                function SliderObj:Get() return value end
                function SliderObj:SetCallback(fn) cb = fn end
                return SliderObj
            end

            -- ─────────────────────────────────────────────────
            -- DROPDOWN
            -- ─────────────────────────────────────────────────
            function Section:AddDropdown(options)
                options = options or {}
                local T4      = self._theme
                local label   = options.Name         or "Dropdown"
                local items   = options.Items        or {}
                local defText = options.Default      or "Select..."
                local desc    = options.Description  or nil
                local flag    = options.Flag         or nil
                local cb      = options.Callback     or function() end
                local multi   = options.Multi        or false

                local selected = multi and {} or nil

                local h = desc and 60 or 44
                local container = newInstance("Frame", {
                    Size             = UDim2.new(1, 0, 0, h),
                    BackgroundColor3 = T4.ElementBg,
                    BorderSizePixel  = 0,
                    ClipsDescendants = false,
                    LayoutOrder      = nextOrder(),
                }, secFrame)
                makeCorner(container, 6)

                newInstance("TextLabel", {
                    Size             = UDim2.new(1, -12, 0, 18),
                    Position         = UDim2.fromOffset(10, 6),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = T4.TextPrimary,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, container)

                if desc then
                    newInstance("TextLabel", {
                        Size             = UDim2.new(1, -12, 0, 14),
                        Position         = UDim2.fromOffset(10, 24),
                        BackgroundTransparency = 1,
                        Text             = desc,
                        TextColor3       = T4.TextDim,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 11,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                    }, container)
                end

                -- Dropdown button
                local dropBtn = newInstance("TextButton", {
                    Size             = UDim2.new(1, -20, 0, 26),
                    Position         = UDim2.new(0, 10, 1, -32),
                    BackgroundColor3 = T4.TertiaryBg,
                    Text             = defText,
                    TextColor3       = T4.TextSecondary,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    BorderSizePixel  = 0,
                    AutoButtonColor  = false,
                    ZIndex           = 3,
                }, container)
                makeCorner(dropBtn, 5)

                -- Chevron
                local chevron = newInstance("TextLabel", {
                    Size             = UDim2.fromOffset(20, 20),
                    Position         = UDim2.new(1, -24, 0.5, -10),
                    BackgroundTransparency = 1,
                    Text             = "▾",
                    TextColor3       = T4.TextDim,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 14,
                    ZIndex           = 4,
                }, dropBtn)

                -- Dropdown menu (rendered outside section, high ZIndex)
                local menuFrame = newInstance("Frame", {
                    Name             = "DropMenu",
                    Size             = UDim2.fromOffset(0, 0),
                    BackgroundColor3 = T4.SecondaryBg,
                    BorderSizePixel  = 0,
                    Visible          = false,
                    ZIndex           = 100,
                    ClipsDescendants = true,
                }, ScreenGui)
                makeCorner(menuFrame, 7)
                makeStroke(menuFrame, T4.Border, 1)

                local menuList = newInstance("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding   = UDim.new(0, 2),
                }, menuFrame)
                makePadding(menuFrame, 4, 4, 4, 4)

                local open = false

                local function updateMenuPos()
                    local ap = dropBtn.AbsolutePosition
                    local asz = dropBtn.AbsoluteSize
                    menuFrame.Size = UDim2.fromOffset(asz.X, math.min(#items * 28 + 8, 180))
                    menuFrame.Position = UDim2.fromOffset(ap.X, ap.Y + asz.Y + 2)
                end

                local function buildMenu(itemList)
                    for _, c in pairs(menuFrame:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for i, item in ipairs(itemList) do
                        local name = type(item) == "table" and item[1] or tostring(item)
                        local val  = type(item) == "table" and item[2] or item

                        local mBtn = newInstance("TextButton", {
                            Size             = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = T4.TertiaryBg,
                            Text             = name,
                            TextColor3       = T4.TextSecondary,
                            Font             = Enum.Font.Gotham,
                            TextSize         = 12,
                            BorderSizePixel  = 0,
                            AutoButtonColor  = false,
                            ZIndex           = 101,
                            LayoutOrder      = i,
                        }, menuFrame)
                        makeCorner(mBtn, 5)
                        addHover(mBtn, T4.TertiaryBg, T4.ElementBg)

                        mBtn.MouseButton1Click:Connect(function()
                            if multi then
                                local idx = table.find(selected, val)
                                if idx then
                                    table.remove(selected, idx)
                                    mBtn.TextColor3 = T4.TextSecondary
                                else
                                    table.insert(selected, val)
                                    mBtn.TextColor3 = T4.Accent
                                end
                                local names = {}
                                for _, s in ipairs(selected) do
                                    for _, it in ipairs(items) do
                                        local n2 = type(it) == "table" and it[1] or tostring(it)
                                        local v2 = type(it) == "table" and it[2] or it
                                        if v2 == s then table.insert(names, n2) end
                                    end
                                end
                                dropBtn.Text = #names > 0 and table.concat(names, ", ") or defText
                                if flag then NexusLib.Flags[flag] = selected end
                                cb(selected)
                            else
                                selected = val
                                dropBtn.Text = name
                                dropBtn.TextColor3 = T4.TextPrimary
                                if flag then NexusLib.Flags[flag] = selected end
                                cb(val)
                                open = false
                                menuFrame.Visible = false
                                tween(chevron, {Rotation = 0}, 0.1):Play()
                            end
                        end)
                    end
                end

                buildMenu(items)

                dropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        updateMenuPos()
                        menuFrame.Visible = true
                        tween(chevron, {Rotation = 180}, 0.15):Play()
                    else
                        menuFrame.Visible = false
                        tween(chevron, {Rotation = 0}, 0.1):Play()
                    end
                end)

                -- Close on outside click
                UserInputService.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        if open then
                            local mPos = inp.Position
                            local mAbs = menuFrame.AbsolutePosition
                            local mSz  = menuFrame.AbsoluteSize
                            if not (mPos.X >= mAbs.X and mPos.X <= mAbs.X + mSz.X
                                and mPos.Y >= mAbs.Y and mPos.Y <= mAbs.Y + mSz.Y) then
                                open = false
                                menuFrame.Visible = false
                                tween(chevron, {Rotation = 0}, 0.1):Play()
                            end
                        end
                    end
                end)

                local DropObj = {}
                function DropObj:Set(val)
                    for _, item in ipairs(items) do
                        local n = type(item) == "table" and item[1] or tostring(item)
                        local v = type(item) == "table" and item[2] or item
                        if v == val then
                            selected = val
                            dropBtn.Text = n
                            dropBtn.TextColor3 = T4.TextPrimary
                            if flag then NexusLib.Flags[flag] = selected end
                        end
                    end
                end
                function DropObj:Get() return selected end
                function DropObj:Refresh(newItems)
                    items = newItems
                    buildMenu(items)
                    menuFrame.Size = UDim2.fromOffset(dropBtn.AbsoluteSize.X, math.min(#items * 28 + 8, 180))
                end
                function DropObj:AddItem(item) table.insert(items, item) buildMenu(items) end
                function DropObj:RemoveItem(name)
                    for i, item in ipairs(items) do
                        local n = type(item) == "table" and item[1] or tostring(item)
                        if n:lower() == name:lower() then table.remove(items, i) break end
                    end
                    buildMenu(items)
                end
                function DropObj:SetCallback(fn) cb = fn end
                return DropObj
            end

            -- ─────────────────────────────────────────────────
            -- TEXTBOX
            -- ─────────────────────────────────────────────────
            function Section:AddTextbox(options)
                options = options or {}
                local T4    = self._theme
                local label = options.Name        or "Textbox"
                local ph    = options.Placeholder or "Type here..."
                local desc  = options.Description or nil
                local flag  = options.Flag        or nil
                local cb    = options.Callback    or function() end
                local live  = options.LiveUpdate  or false

                local row = newInstance("Frame", {
                    Size             = UDim2.new(1, 0, 0, desc and 62 or 48),
                    BackgroundColor3 = T4.ElementBg,
                    BorderSizePixel  = 0,
                    LayoutOrder      = nextOrder(),
                }, secFrame)
                makeCorner(row, 6)

                newInstance("TextLabel", {
                    Size             = UDim2.new(1, -12, 0, 18),
                    Position         = UDim2.fromOffset(10, 6),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = T4.TextPrimary,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, row)

                if desc then
                    newInstance("TextLabel", {
                        Size             = UDim2.new(1, -12, 0, 14),
                        Position         = UDim2.fromOffset(10, 24),
                        BackgroundTransparency = 1,
                        Text             = desc,
                        TextColor3       = T4.TextDim,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 11,
                        TextXAlignment   = Enum.TextXAlignment.Left,
                    }, row)
                end

                local box = newInstance("TextBox", {
                    Size             = UDim2.new(1, -20, 0, 24),
                    Position         = UDim2.new(0, 10, 1, -30),
                    BackgroundColor3 = T4.TertiaryBg,
                    Text             = "",
                    PlaceholderText  = ph,
                    TextColor3       = T4.TextPrimary,
                    PlaceholderColor3 = T4.TextDim,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    BorderSizePixel  = 0,
                    ClearTextOnFocus = false,
                }, row)
                makeCorner(box, 5)
                makeStroke(box, T4.Border, 1)

                box.Focused:Connect(function()
                    tween(box, {BackgroundColor3 = T4.ElementBg}, 0.1):Play()
                end)
                box.FocusLost:Connect(function()
                    tween(box, {BackgroundColor3 = T4.TertiaryBg}, 0.1):Play()
                    if flag then NexusLib.Flags[flag] = box.Text end
                    cb(box.Text)
                end)
                if live then
                    box:GetPropertyChangedSignal("Text"):Connect(function()
                        if flag then NexusLib.Flags[flag] = box.Text end
                        cb(box.Text)
                    end)
                end

                local TbObj = {}
                function TbObj:Set(text) box.Text = tostring(text) end
                function TbObj:Get() return box.Text end
                function TbObj:SetCallback(fn) cb = fn end
                return TbObj
            end

            -- ─────────────────────────────────────────────────
            -- KEYBIND
            -- ─────────────────────────────────────────────────
            function Section:AddKeybind(options)
                options = options or {}
                local T4    = self._theme
                local label = options.Name        or "Keybind"
                local desc  = options.Description or nil
                local def   = options.Default     or nil
                local flag  = options.Flag        or nil
                local cb    = options.Callback    or function() end

                local current = def
                local setting = false

                local row = newInstance("Frame", {
                    Size             = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = T4.ElementBg,
                    BorderSizePixel  = 0,
                    LayoutOrder      = nextOrder(),
                }, secFrame)
                makeCorner(row, 6)

                newInstance("TextLabel", {
                    Size             = UDim2.new(0.55, 0, 1, 0),
                    Position         = UDim2.fromOffset(10, 0),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = T4.TextPrimary,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, row)

                local kbBtn = newInstance("TextButton", {
                    Size             = UDim2.fromOffset(100, 24),
                    Position         = UDim2.new(1, -108, 0.5, -12),
                    BackgroundColor3 = T4.TertiaryBg,
                    Text             = current and current.Name or "None",
                    TextColor3       = T4.TextSecondary,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    BorderSizePixel  = 0,
                    AutoButtonColor  = false,
                }, row)
                makeCorner(kbBtn, 5)

                if flag then NexusLib.Flags[flag] = current end

                kbBtn.MouseButton1Click:Connect(function()
                    if setting then return end
                    setting = true
                    kbBtn.Text = "..."
                    tween(kbBtn, {BackgroundColor3 = T4.Accent}, 0.1):Play()
                end)

                local blacklist = {
                    Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A,
                    Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Escape
                }
                UserInputService.InputBegan:Connect(function(inp, gp)
                    if not setting then return end
                    if inp.KeyCode == Enum.KeyCode.Escape then
                        setting = false
                        kbBtn.Text = current and current.Name or "None"
                        tween(kbBtn, {BackgroundColor3 = T4.TertiaryBg}, 0.1):Play()
                        return
                    end
                    if table.find(blacklist, inp.KeyCode) then return end
                    current = inp.KeyCode
                    if flag then NexusLib.Flags[flag] = current end
                    kbBtn.Text = current.Name
                    tween(kbBtn, {BackgroundColor3 = T4.TertiaryBg}, 0.1):Play()
                    setting = false
                end)

                UserInputService.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    if current and inp.KeyCode == current then
                        cb()
                    end
                end)

                local KbObj = {}
                function KbObj:Set(key) current = key kbBtn.Text = key and key.Name or "None" end
                function KbObj:Get() return current end
                function KbObj:SetCallback(fn) cb = fn end
                return KbObj
            end

            -- ─────────────────────────────────────────────────
            -- COLOR PICKER
            -- ─────────────────────────────────────────────────
            function Section:AddColorPicker(options)
                options = options or {}
                local T4    = self._theme
                local label = options.Name     or "Color"
                local def   = options.Default  or Color3.fromRGB(255, 255, 255)
                local flag  = options.Flag     or nil
                local cb    = options.Callback or function() end

                local currentColor = def
                local pickerOpen = false

                local row = newInstance("Frame", {
                    Size             = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = T4.ElementBg,
                    BorderSizePixel  = 0,
                    LayoutOrder      = nextOrder(),
                }, secFrame)
                makeCorner(row, 6)

                newInstance("TextLabel", {
                    Size             = UDim2.new(1, -60, 1, 0),
                    Position         = UDim2.fromOffset(10, 0),
                    BackgroundTransparency = 1,
                    Text             = label,
                    TextColor3       = T4.TextPrimary,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, row)

                -- Color swatch
                local swatch = newInstance("TextButton", {
                    Size             = UDim2.fromOffset(40, 22),
                    Position         = UDim2.new(1, -48, 0.5, -11),
                    BackgroundColor3 = currentColor,
                    Text             = "",
                    BorderSizePixel  = 0,
                    AutoButtonColor  = false,
                }, row)
                makeCorner(swatch, 5)
                makeStroke(swatch, T4.Border, 1)

                if flag then NexusLib.Flags[flag] = currentColor end

                -- Picker popup
                local pickerFrame = newInstance("Frame", {
                    Size             = UDim2.fromOffset(220, 200),
                    BackgroundColor3 = T4.SecondaryBg,
                    BorderSizePixel  = 0,
                    Visible          = false,
                    ZIndex           = 90,
                }, ScreenGui)
                makeCorner(pickerFrame, 10)
                makeStroke(pickerFrame, T4.Border, 1)
                makePadding(pickerFrame, 10, 10, 10, 10)

                -- Hue, Saturation, Value sliders
                local function makePickerSlider(parent, yPos, labelText, color)
                    local sl = newInstance("Frame", {
                        Size             = UDim2.new(1, 0, 0, 36),
                        Position         = UDim2.fromOffset(0, yPos),
                        BackgroundTransparency = 1,
                        ZIndex           = 91,
                    }, parent)
                    newInstance("TextLabel", {
                        Size             = UDim2.new(0.35, 0, 0, 16),
                        BackgroundTransparency = 1,
                        Text             = labelText,
                        TextColor3       = T4.TextSecondary,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 11,
                        ZIndex           = 91,
                    }, sl)
                    local track = newInstance("Frame", {
                        Size             = UDim2.new(0.65, -4, 0, 8),
                        Position         = UDim2.new(0.35, 2, 0, 4),
                        BackgroundColor3 = color,
                        BorderSizePixel  = 0,
                        ZIndex           = 91,
                    }, sl)
                    makeCorner(track, 4)
                    local fill = newInstance("Frame", {
                        Size             = UDim2.new(0, 0, 1, 0),
                        BackgroundColor3 = T4.Accent,
                        BorderSizePixel  = 0,
                        ZIndex           = 92,
                    }, track)
                    makeCorner(fill, 4)
                    local thumb = newInstance("Frame", {
                        Size             = UDim2.fromOffset(12, 12),
                        Position         = UDim2.new(0, -6, 0.5, -6),
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel  = 0,
                        ZIndex           = 93,
                    }, track)
                    makeCorner(thumb, 6)
                    return track, fill, thumb
                end

                local h, s, v = Color3.toHSV(currentColor)
                local hTrack, hFill, hThumb = makePickerSlider(pickerFrame, 10, "H", Color3.fromRGB(255, 100, 100))
                local sTrack, sFill, sThumb = makePickerSlider(pickerFrame, 56, "S", T4.TertiaryBg)
                local vTrack, vFill, vThumb = makePickerSlider(pickerFrame, 102, "V", T4.TertiaryBg)

                -- Hex input
                local hexBox = newInstance("TextBox", {
                    Size             = UDim2.new(1, 0, 0, 28),
                    Position         = UDim2.fromOffset(0, 152),
                    BackgroundColor3 = T4.TertiaryBg,
                    Text             = "",
                    PlaceholderText  = "Hex: RRGGBB",
                    TextColor3       = T4.TextPrimary,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    BorderSizePixel  = 0,
                    ZIndex           = 91,
                }, pickerFrame)
                makeCorner(hexBox, 5)

                local function updatePicker()
                    currentColor = Color3.fromHSV(h, s, v)
                    swatch.BackgroundColor3 = currentColor
                    hFill.Size  = UDim2.new(h, 0, 1, 0)
                    hThumb.Position = UDim2.new(h, -6, 0.5, -6)
                    sFill.Size  = UDim2.new(s, 0, 1, 0)
                    sThumb.Position = UDim2.new(s, -6, 0.5, -6)
                    vFill.Size  = UDim2.new(v, 0, 1, 0)
                    vThumb.Position = UDim2.new(v, -6, 0.5, -6)
                    hexBox.Text = string.format("%02X%02X%02X",
                        math.floor(currentColor.R * 255),
                        math.floor(currentColor.G * 255),
                        math.floor(currentColor.B * 255))
                    if flag then NexusLib.Flags[flag] = currentColor end
                    cb(currentColor)
                end

                local function sliderDrag(track, callback)
                    local sliding = false
                    local hitArea = newInstance("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 20),
                        Position         = UDim2.new(0, 0, 0.5, -10),
                        BackgroundTransparency = 1,
                        Text             = "",
                        ZIndex           = 94,
                    }, track)
                    hitArea.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            local p = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            callback(p)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                            local p = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            callback(p)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                    end)
                end

                sliderDrag(hTrack, function(p) h = p updatePicker() end)
                sliderDrag(sTrack, function(p) s = p updatePicker() end)
                sliderDrag(vTrack, function(p) v = p updatePicker() end)

                hexBox.FocusLost:Connect(function()
                    local hex = hexBox.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,2), 16) or 0
                        local g = tonumber(hex:sub(3,4), 16) or 0
                        local b = tonumber(hex:sub(5,6), 16) or 0
                        currentColor = Color3.fromRGB(r, g, b)
                        h, s, v = Color3.toHSV(currentColor)
                        updatePicker()
                    end
                end)

                updatePicker()

                swatch.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        local ap = swatch.AbsolutePosition
                        pickerFrame.Position = UDim2.fromOffset(ap.X - 180, ap.Y + 30)
                        pickerFrame.Visible = true
                    else
                        pickerFrame.Visible = false
                    end
                end)

                UserInputService.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and pickerOpen then
                        local mp = inp.Position
                        local pf = pickerFrame
                        local pp = pf.AbsolutePosition
                        local ps = pf.AbsoluteSize
                        if not (mp.X >= pp.X and mp.X <= pp.X+ps.X and mp.Y >= pp.Y and mp.Y <= pp.Y+ps.Y) then
                            local sp2 = swatch.AbsolutePosition
                            local ss = swatch.AbsoluteSize
                            if not (mp.X >= sp2.X and mp.X <= sp2.X+ss.X and mp.Y >= sp2.Y and mp.Y <= sp2.Y+ss.Y) then
                                pickerOpen = false
                                pickerFrame.Visible = false
                            end
                        end
                    end
                end)

                local CpObj = {}
                function CpObj:Set(color)
                    currentColor = color
                    h, s, v = Color3.toHSV(color)
                    updatePicker()
                end
                function CpObj:Get() return currentColor end
                function CpObj:SetCallback(fn) cb = fn end
                return CpObj
            end

            -- ─────────────────────────────────────────────────
            -- LABEL
            -- ─────────────────────────────────────────────────
            function Section:AddLabel(text)
                local T4 = self._theme
                local lbl = newInstance("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text             = tostring(text),
                    TextColor3       = T4.TextSecondary,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    LayoutOrder      = nextOrder(),
                }, secFrame)
                makePadding(lbl, 0, 0, 10, 0)

                local LblObj = {}
                function LblObj:Set(t) lbl.Text = tostring(t) end
                function LblObj:SetColor(c) lbl.TextColor3 = c end
                return LblObj
            end

            -- ─────────────────────────────────────────────────
            -- SEPARATOR
            -- ─────────────────────────────────────────────────
            function Section:AddSeparator(text)
                local T4 = self._theme
                local sep = newInstance("Frame", {
                    Size             = UDim2.new(1, 0, 0, text and 20 or 8),
                    BackgroundTransparency = 1,
                    LayoutOrder      = nextOrder(),
                }, secFrame)

                local line = newInstance("Frame", {
                    Size             = UDim2.new(1, -20, 0, 1),
                    Position         = UDim2.new(0, 10, 0.5, 0),
                    BackgroundColor3 = T4.Border,
                    BorderSizePixel  = 0,
                }, sep)

                if text then
                    local lbl = newInstance("TextLabel", {
                        Size             = UDim2.fromOffset(0, 18),
                        AnchorPoint      = Vector2.new(0.5, 0.5),
                        Position         = UDim2.new(0.5, 0, 0.5, 0),
                        AutomaticSize    = Enum.AutomaticSize.X,
                        BackgroundColor3 = T4.SecondaryBg,
                        Text             = "  " .. text .. "  ",
                        TextColor3       = T4.TextDim,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 11,
                    }, sep)
                end
            end

            -- ─────────────────────────────────────────────────
            -- CREDIT CARD
            -- ─────────────────────────────────────────────────
            function Section:AddCredit(options)
                options = options or {}
                local T4   = self._theme
                local name = options.Name        or "Unknown"
                local desc = options.Description or "Contributor"
                local dis  = options.Discord     or nil
                local v3rm = options.V3rm        or nil

                local card = newInstance("Frame", {
                    Size             = UDim2.new(1, 0, 0, 52),
                    BackgroundColor3 = T4.TertiaryBg,
                    BorderSizePixel  = 0,
                    LayoutOrder      = nextOrder(),
                }, secFrame)
                makeCorner(card, 7)

                newInstance("TextLabel", {
                    Size             = UDim2.new(0.6, 0, 0, 20),
                    Position         = UDim2.fromOffset(10, 8),
                    BackgroundTransparency = 1,
                    Text             = name,
                    TextColor3       = T4.TextPrimary,
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 13,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, card)

                newInstance("TextLabel", {
                    Size             = UDim2.new(0.6, 0, 0, 16),
                    Position         = UDim2.fromOffset(10, 28),
                    BackgroundTransparency = 1,
                    Text             = desc,
                    TextColor3       = T4.TextDim,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                }, card)

                local tags = {}
                if dis then table.insert(tags, "Discord: " .. dis) end
                if v3rm then table.insert(tags, "V3rm: " .. v3rm) end
                if #tags > 0 then
                    newInstance("TextLabel", {
                        Size             = UDim2.new(0.4, -10, 1, -8),
                        Position         = UDim2.new(0.6, 0, 0, 4),
                        BackgroundTransparency = 1,
                        Text             = table.concat(tags, "\n"),
                        TextColor3       = T4.Accent,
                        Font             = Enum.Font.Gotham,
                        TextSize         = 10,
                        TextXAlignment   = Enum.TextXAlignment.Right,
                        TextYAlignment   = Enum.TextYAlignment.Center,
                    }, card)
                end
            end

            -- UpdateSection
            function Section:SetName(name)
                local hdr = secFrame:FindFirstChild("TextLabel", true)
                if hdr then hdr.Text = name end
            end

            return Section
        end -- AddSection

        -- ── Tab-level KEYBIND toggle for UI visibility ───────
        function Tab:AddUIToggle(options)
            options = options or {}
            local key = options.Key or Enum.KeyCode.RightShift
            local vis = true

            UserInputService.InputBegan:Connect(function(inp, gp)
                if gp then return end
                if inp.KeyCode == key then
                    vis = not vis
                    tween(mainFrame, {BackgroundTransparency = vis and 0 or 1}, 0.2):Play()
                    mainFrame.Visible = vis
                end
            end)
        end

        return Tab
    end -- AddTab

    -- ── Config / Preset System ──────────────────────────────
    function Window:SaveConfig(name)
        ensureFolder()
        if not (writefile and isfolder) then return false end
        local data = {}
        for flag, val in pairs(NexusLib.Flags) do
            local t = type(val)
            if t == "boolean" or t == "number" or t == "string" then
                data[flag] = val
            elseif t == "userdata" then
                if typeof(val) == "EnumItem" then
                    data[flag] = {_type = "enum", value = val.Name}
                elseif typeof(val) == "Color3" then
                    data[flag] = {_type = "color3", r = val.R, g = val.G, b = val.B}
                end
            end
        end
        local ok, err = pcall(function()
            writefile(NexusLib.FolderName .. "/" .. name .. NexusLib.FileExt,
                HttpService:JSONEncode(data))
        end)
        return ok
    end

    function Window:LoadConfig(name)
        if not (readfile and isfile) then return false end
        local path = NexusLib.FolderName .. "/" .. name .. NexusLib.FileExt
        if not isfile(path) then return false end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if not ok or not data then return false end

        for flag, val in pairs(data) do
            if type(val) == "table" then
                if val._type == "enum" then
                    NexusLib.Flags[flag] = Enum.KeyCode[val.value] or val.value
                elseif val._type == "color3" then
                    NexusLib.Flags[flag] = Color3.new(val.r, val.g, val.b)
                end
            else
                NexusLib.Flags[flag] = val
            end
            if NexusLib.Options[flag] then
                pcall(function() NexusLib.Options[flag]:Set(NexusLib.Flags[flag]) end)
            end
        end
        return true
    end

    function Window:GetConfigs()
        if not (listfiles and isfolder) then return {} end
        if not isfolder(NexusLib.FolderName) then return {} end
        local configs = {}
        for _, f in ipairs(listfiles(NexusLib.FolderName)) do
            local name = f:match("([^/\\]+)$") or f
            name = name:gsub(NexusLib.FileExt .. "$", "")
            table.insert(configs, name)
        end
        return configs
    end

    function Window:Destroy()
        mainFrame:Destroy()
    end

    function Window:SetTheme(themeData)
        -- Live theme switch (re-tints the main frame)
        self._theme = themeData
        tween(mainFrame, {BackgroundColor3 = themeData.Background}, 0.3):Play()
        tween(titleBar,  {BackgroundColor3 = themeData.SecondaryBg}, 0.3):Play()
        tween(sidebar,   {BackgroundColor3 = themeData.SecondaryBg}, 0.3):Play()
    end

    table.insert(NexusLib.Windows, Window)

    -- Animate open
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.fromOffset(winSize.X * 0.9, winSize.Y * 0.9)
    tween(mainFrame, {
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(winSize.X, winSize.Y)
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()

    return Window
end

-- ============================================================
-- LIBRARY-LEVEL UTILITIES
-- ============================================================
function NexusLib:Destroy()
    ScreenGui:Destroy()
    if getgenv then getgenv().NexusLib = nil end
end

function NexusLib:SetTheme(theme)
    if type(theme) == "string" then
        self.ActiveTheme = self.Themes[theme] or self.ActiveTheme
    elseif type(theme) == "table" then
        self.ActiveTheme = theme
    end
end

return NexusLib
