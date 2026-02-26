--[[
╔══════════════════════════════════════════════════════════════════╗
║  CartLib.lua  |  Reusable UI Library for Roblox Exploit Scripts ║
║  Features:                                                       ║
║    • CoreGui parent  → overlays the Roblox escape menu           ║
║    • Draggable window with tabs, minimize and close              ║
║    • Pill toggles, keybind badges, sliders + textbox input       ║
║    • Floating ESP panels with search + deselect-all              ║
║    • No shadow / no redundant decorations                        ║
╚══════════════════════════════════════════════════════════════════╝

  QUICK START
  ───────────
  local Lib = loadstring(game:HttpGet("RAW_URL_HERE"))()
  local win = Lib.new("My Window", { width=300, height=320 })

  local tab = win:Tab("Settings", "⚙")

  local row = tab:Row("Auto Farm")
  local setFarmToggle = row:Toggle(function(on) print(on) end)
  row:Keybind(nil, function(kc) farmKey = kc end)

  tab:SectionHeader("ESP")
  local panel = win:FloatingPanel("📦 Item ESP", 320, 20)
  tab:PanelButton("📦 Item ESP", panel)
  tab:DistanceRow(espData, 500)

  win:OnInput(function(kc)
      if farmKey and kc == farmKey then
          farmOn = not farmOn; setFarmToggle(farmOn, true)
      end
  end)
]]

-- ════════════════════════════════════════════════════════════════
local CartLib = {}

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local player           = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
--  DEFAULT THEME
-- ════════════════════════════════════════════════════════════════
CartLib.DefaultTheme = {
    bg         = Color3.fromRGB( 12,  12,  18),
    panel      = Color3.fromRGB( 20,  20,  30),
    tabActive  = Color3.fromRGB( 25,  35,  60),
    border     = Color3.fromRGB( 50,  50,  80),
    accent     = Color3.fromRGB( 80, 160, 255),
    green      = Color3.fromRGB( 60, 220, 120),
    red        = Color3.fromRGB(220,  70,  70),
    text       = Color3.fromRGB(220, 225, 240),
    sub        = Color3.fromRGB(120, 125, 150),
    sliderbg   = Color3.fromRGB( 35,  35,  55),
    sliderfill = Color3.fromRGB( 80, 160, 255),
    bindlisten = Color3.fromRGB(255, 200,  60),
    bindset    = Color3.fromRGB( 80, 160, 255),
}

-- ════════════════════════════════════════════════════════════════
--  PRIVATE GUI HELPERS
-- ════════════════════════════════════════════════════════════════

local function _corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = inst
end

local function _stroke(inst, col, t)
    local s = Instance.new("UIStroke")
    s.Color = col; s.Thickness = t or 1; s.Parent = inst
end

local function _frame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k, v in pairs(props or {}) do f[k] = v end
    if parent then f.Parent = parent end
    return f
end

local function _label(parent, props)
    local l = Instance.new("TextLabel")
    l.BorderSizePixel = 0; l.BackgroundTransparency = 1
    for k, v in pairs(props or {}) do l[k] = v end
    if parent then l.Parent = parent end
    return l
end

local function _btn(parent, props, hoverCol)
    local b = Instance.new("TextButton")
    b.BorderSizePixel = 0; b.AutoButtonColor = false
    for k, v in pairs(props or {}) do b[k] = v end
    if parent then b.Parent = parent end
    if hoverCol then
        local base = (props and props.TextColor3) or Color3.new(1,1,1)
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1), {TextColor3 = hoverCol}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1), {TextColor3 = base}):Play()
        end)
    end
    return b
end

local function _box(parent, props)
    local x = Instance.new("TextBox")
    x.BorderSizePixel = 0; x.ClearTextOnFocus = false
    for k, v in pairs(props or {}) do x[k] = v end
    if parent then x.Parent = parent end
    return x
end

-- Make any frame draggable by a handle
local function _draggable(handle, target, conns)
    local dragging, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; ds = inp.Position; sp = target.Position
        end
    end)
    local c1 = UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - ds
            target.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    local c2 = UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    if conns then table.insert(conns, c1); table.insert(conns, c2) end
end

-- ════════════════════════════════════════════════════════════════
--  REUSABLE COMPONENT FACTORIES (used internally)
-- ════════════════════════════════════════════════════════════════

-- Animated pill toggle. Returns: hitButton, setFn(on, animated)
local function _pill(parent, pos, initOn, C)
    local bg = _frame(parent, {
        Size = UDim2.new(0,44,0,22), Position = pos,
        BackgroundColor3 = initOn and C.green or C.sliderbg,
    })
    _corner(bg, 11)

    local knob = _frame(bg, {
        Size = UDim2.new(0,16,0,16),
        Position = initOn and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8),
        BackgroundColor3 = initOn and Color3.new(1,1,1) or C.sub,
    })
    _corner(knob, 8)

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1
    hit.Text = ""; hit.BorderSizePixel = 0; hit.AutoButtonColor = false
    hit.Parent = bg

    local function setFn(on, anim)
        local kx = on and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8)
        local bc = on and C.green or C.sliderbg
        local kc = on and Color3.new(1,1,1) or C.sub
        if anim then
            TweenService:Create(knob, TweenInfo.new(0.15), {Position=kx, BackgroundColor3=kc}):Play()
            TweenService:Create(bg,   TweenInfo.new(0.15), {BackgroundColor3=bc}):Play()
        else
            knob.Position=kx; knob.BackgroundColor3=kc; bg.BackgroundColor3=bc
        end
    end
    return hit, setFn
end

-- Keybind badge. Returns the badge TextButton.
-- bindRef = { active: bool } shared table to block global keybinds while listening
local function _keybind(parent, initKey, onBind, C, bindRef)
    local badge = _btn(parent, {
        Size = UDim2.new(0,46,0,17), TextSize = 9, Font = Enum.Font.GothamBold,
        BackgroundColor3 = C.panel,
        Text       = initKey and initKey.Name:sub(1,5) or "None",
        TextColor3 = initKey and C.bindset or C.sub,
    })
    _corner(badge, 3); _stroke(badge, C.border, 1)

    local lConn = nil

    local function stopListen()
        if lConn then lConn:Disconnect(); lConn = nil end
        if bindRef then bindRef.active = false end
        local has = badge.Text ~= "None"
        TweenService:Create(badge, TweenInfo.new(0.1), {
            TextColor3 = has and C.bindset or C.sub,
            BackgroundColor3 = C.panel,
        }):Play()
    end

    badge.MouseButton1Click:Connect(function()
        if lConn then stopListen(); return end
        if bindRef then bindRef.active = true end
        badge.Text = "···"
        TweenService:Create(badge, TweenInfo.new(0.1), {
            TextColor3 = C.bindlisten,
            BackgroundColor3 = Color3.fromRGB(35, 28, 8),
        }):Play()
        lConn = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
            lConn:Disconnect(); lConn = nil
            if bindRef then bindRef.active = false end
            if inp.KeyCode == Enum.KeyCode.Escape then
                badge.Text = "None"; onBind(nil)
            else
                local n = inp.KeyCode.Name
                    :gsub("LeftControl","LCtrl"):gsub("RightControl","RCtrl")
                    :gsub("LeftShift","LShft"):gsub("RightShift","RShft")
                    :gsub("LeftAlt","LAlt"):gsub("RightAlt","RAlt")
                badge.Text = n:sub(1,5); onBind(inp.KeyCode)
            end
            local has = badge.Text ~= "None"
            TweenService:Create(badge, TweenInfo.new(0.1), {
                TextColor3 = has and C.bindset or C.sub,
                BackgroundColor3 = C.panel,
            }):Play()
        end)
    end)
    return badge
end

-- ════════════════════════════════════════════════════════════════
--  FLOATING PANEL (for ESP target lists, etc.)
-- ════════════════════════════════════════════════════════════════
--
--  Usage:
--    local panel = win:FloatingPanel("📦 ITEM ESP TARGETS", 320, 20)
--    tab:PanelButton("📦 Item ESP", panel)
--    panel:SetESPData(espCat.items, getColor, refreshCallback)
--
local function buildFloatingPanel(sg, title, x, y, C, conns)
    local panel = _frame(sg, {
        Size = UDim2.new(0,240,0,320),
        Position = UDim2.new(0,x,0,y),
        BackgroundColor3 = C.bg, Visible = false, ClipsDescendants = true,
    })
    _corner(panel, 8); _stroke(panel, C.border, 1)

    -- Title bar (draggable)
    local pTitle = _frame(panel, {Size=UDim2.new(1,0,0,30), BackgroundColor3=C.panel})
    _label(pTitle, {
        Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,10,0,0),
        Text=title, TextSize=10, Font=Enum.Font.GothamBold,
        TextColor3=C.accent, TextXAlignment=Enum.TextXAlignment.Left,
    })
    _draggable(pTitle, panel, conns)

    -- Toolbar: search + deselect
    local toolbar = _frame(panel, {
        Size=UDim2.new(1,0,0,28), Position=UDim2.new(0,0,0,30), BackgroundTransparency=1,
    })
    local deselectBtn = _btn(toolbar, {
        Size=UDim2.new(0,100,0,20), Position=UDim2.new(1,-108,0.5,-10),
        Text="☐ Deselect All", TextSize=9, Font=Enum.Font.GothamBold,
        TextColor3=C.sub, BackgroundColor3=C.panel,
    }, C.text)
    _corner(deselectBtn, 4); _stroke(deselectBtn, C.border, 1)

    local searchBox = _box(toolbar, {
        Size=UDim2.new(1,-116,0,20), Position=UDim2.new(0,6,0.5,-10),
        Text="", PlaceholderText="🔍 search...",
        TextSize=9, Font=Enum.Font.Gotham,
        TextColor3=C.text, PlaceholderColor3=C.sub, BackgroundColor3=C.panel,
    })
    _corner(searchBox, 4); _stroke(searchBox, C.border, 1)

    _frame(panel, {
        Size=UDim2.new(1,-12,0,1), Position=UDim2.new(0,6,0,60),
        BackgroundColor3=C.border,
    })

    -- Scroll list
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,-4,1,-65); scroll.Position=UDim2.new(0,2,0,64)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=4; scroll.ScrollBarImageColor3=C.border
    scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.Parent=panel

    local layout = Instance.new("UIListLayout")
    layout.SortOrder=Enum.SortOrder.Name; layout.Padding=UDim.new(0,2)
    layout.Parent=scroll

    -- Search filter
    local searchFilter = ""
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchFilter = searchBox.Text
        for _, ch in ipairs(scroll:GetChildren()) do
            if ch:IsA("Frame") then
                ch.Visible = searchFilter=="" or ch.Name:lower():find(searchFilter:lower(),1,true)~=nil
            end
        end
    end)

    -- Panel object returned to caller
    local panelObj = { _frame=panel, _scroll=scroll }

    --[[
        SetESPData(entries, colorFn, onToggleCb)
          entries   = the flat table { [name]={name,enabled} }
          colorFn   = function(name) → { fillColor, outlineColor }
          onToggleCb= called when any entry is toggled (e.g. to refresh highlights)
        Returns: rebuild() — call whenever entries table changes externally
    ]]
    function panelObj:SetESPData(entries, colorFn, onToggleCb)
        local function buildRow(name, entry)
            local cols = colorFn(name)

            local row = _frame(scroll, {
                Name=name, Size=UDim2.new(1,-6,0,28), BackgroundTransparency=1,
                Visible = searchFilter=="" or name:lower():find(searchFilter:lower(),1,true)~=nil,
            })

            local dot = _frame(row, {
                Size=UDim2.new(0,8,0,8), Position=UDim2.new(0,6,0.5,-4),
                BackgroundColor3=cols[1],
            })
            _corner(dot, 4)

            _label(row, {
                Size=UDim2.new(1,-70,1,0), Position=UDim2.new(0,20,0,0),
                Text=name, TextSize=10, Font=Enum.Font.Gotham, TextColor3=C.text,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextTruncate=Enum.TextTruncate.AtEnd,
            })

            local pillHit, setPill = _pill(row, UDim2.new(1,-48,0.5,-11), entry.enabled, C)
            pillHit.MouseButton1Click:Connect(function()
                entry.enabled = not entry.enabled
                setPill(entry.enabled, true)
                if onToggleCb then onToggleCb() end
            end)
        end

        local function rebuild()
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            local count = 0
            for name, entry in pairs(entries) do
                buildRow(name, entry)
                count = count + 1
            end
            scroll.CanvasSize = UDim2.new(0,0,0, count*30+4)
        end

        deselectBtn.MouseButton1Click:Connect(function()
            for _, entry in pairs(entries) do entry.enabled = false end
            if onToggleCb then onToggleCb() end
            rebuild()
        end)

        return rebuild
    end

    return panelObj
end

-- ════════════════════════════════════════════════════════════════
--  WIN:  DISTANCE SLIDER ROW  (shared by Tab:DistanceRow)
-- ════════════════════════════════════════════════════════════════
local function _distanceRow(page, yPos, espData, sliderMax, C, conns)
    sliderMax = sliderMax or 500
    local row = _frame(page, {
        Size=UDim2.new(1,-16,0,50), Position=UDim2.new(0,8,0,yPos),
        BackgroundTransparency=1,
    })

    _label(row, {
        Size=UDim2.new(0,70,0,20), Text="Distance:", TextSize=10,
        Font=Enum.Font.GothamBold, TextColor3=C.sub,
        TextXAlignment=Enum.TextXAlignment.Left,
    })

    local pillHit, setPill = _pill(row, UDim2.new(1,-44,0,-1), espData.distOn, C)
    pillHit.MouseButton1Click:Connect(function()
        espData.distOn = not espData.distOn
        setPill(espData.distOn, true)
    end)

    -- Slider track row
    local valRow = _frame(row, {
        Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,26), BackgroundTransparency=1,
    })
    local track = _frame(valRow, {
        Size=UDim2.new(1,-52,0,6), Position=UDim2.new(0,0,0.5,-3), BackgroundColor3=C.sliderbg,
    })
    _corner(track, 3); _stroke(track, C.border, 1)

    local fill = _frame(track, {
        Size=UDim2.new(espData.dist/sliderMax, 0,1,0), BackgroundColor3=C.sliderfill,
    })
    _corner(fill, 3)

    local sKnob = _frame(track, {
        Size=UDim2.new(0,12,0,12),
        Position=UDim2.new(espData.dist/sliderMax,-6,0.5,-6),
        BackgroundColor3=Color3.new(1,1,1),
    })
    _corner(sKnob, 6)

    -- Clickable value label (click to type custom distance)
    local valLbl = _btn(valRow, {
        Size=UDim2.new(0,48,0,20), Position=UDim2.new(1,-48,0,0),
        Text=tostring(espData.dist), TextSize=10, Font=Enum.Font.GothamBold,
        TextColor3=C.accent, BackgroundColor3=C.panel, TextXAlignment=Enum.TextXAlignment.Center,
    })
    _corner(valLbl, 3); _stroke(valLbl, C.border, 1)

    local valBox = _box(valRow, {
        Size=UDim2.new(0,48,0,20), Position=UDim2.new(1,-48,0,0),
        Text=tostring(espData.dist), TextSize=10, Font=Enum.Font.GothamBold,
        TextColor3=C.accent, BackgroundColor3=C.panel,
        TextXAlignment=Enum.TextXAlignment.Center, Visible=false,
    })
    _corner(valBox, 3); _stroke(valBox, C.border, 1)

    local function setDist(v)
        v = math.max(1, math.floor(v)); espData.dist = v
        local frac = math.clamp(v/sliderMax, 0, 1)
        fill.Size = UDim2.new(frac,0,1,0)
        sKnob.Position = UDim2.new(frac,-6,0.5,-6)
        valLbl.Text = tostring(v); valBox.Text = tostring(v)
    end

    -- Drag behaviour
    local sDragging = false
    local sHit = _btn(track, {
        Size=UDim2.new(1,12,0,22), Position=UDim2.new(0,-6,0.5,-11),
        BackgroundTransparency=1, Text="",
    })
    sHit.MouseButton1Down:Connect(function() sDragging = true end)

    table.insert(conns, UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = false end
    end))
    table.insert(conns, RunService.RenderStepped:Connect(function()
        if sDragging then
            local mx = player:GetMouse().X
            local frac = (mx - track.AbsolutePosition.X) / track.AbsoluteSize.X
            setDist(math.clamp(frac, 0, 1) * sliderMax)
        end
    end))

    -- Textbox custom input
    valLbl.MouseButton1Click:Connect(function() valLbl.Visible=false; valBox.Visible=true; valBox:CaptureFocus() end)
    valBox.FocusLost:Connect(function()
        local n = tonumber(valBox.Text); if n then setDist(n) end
        valLbl.Visible=true; valBox.Visible=false
    end)

    return setDist
end

-- ════════════════════════════════════════════════════════════════
--  MAIN ENTRY POINT: CartLib.new(title, opts)
-- ════════════════════════════════════════════════════════════════
--[[
  opts = {
    width         = 300,
    height        = 320,
    tabBarWidth   = 48,
    position      = UDim2.new(0,20,0,20),
    theme         = CartLib.DefaultTheme,   -- optional custom theme table
    name          = "CartLib",              -- ScreenGui name
  }
]]
function CartLib.new(title, opts)
    opts   = opts or {}
    local C    = opts.theme       or CartLib.DefaultTheme
    local W    = opts.width       or 300
    local H    = opts.height      or 320
    local TabW = opts.tabBarWidth or 48
    local pos  = opts.position    or UDim2.new(0,20,0,20)

    -- Connection tracker
    local conns = {}
    local function tc(c) table.insert(conns, c); return c end

    -- Shared flag: prevents global keybinds firing while rebinding
    local bindRef = { active = false }

    -- ── Screen GUI  ──────────────────────────────────────────────
    -- Try CoreGui first so the UI sits above the Roblox escape menu.
    local sg = Instance.new("ScreenGui")
    sg.Name            = opts.name or "CartLib"
    sg.ResetOnSpawn    = false
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset  = true
    sg.DisplayOrder    = 999
    local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not ok then sg.Parent = player.PlayerGui end

    -- ── Main frame (NO shadow) ───────────────────────────────────
    local main = _frame(sg, {
        Name="Main", Size=UDim2.new(0,W,0,H), Position=pos,
        BackgroundColor3=C.bg, ClipsDescendants=true,
    })
    _corner(main, 8); _stroke(main, C.border, 1)

    -- ── Title bar ────────────────────────────────────────────────
    local titleBar = _frame(main, {Size=UDim2.new(1,0,0,34), BackgroundColor3=C.panel})
    _label(titleBar, {
        Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,12,0,0),
        Text=title, TextSize=12, Font=Enum.Font.GothamBold,
        TextColor3=C.accent, TextXAlignment=Enum.TextXAlignment.Left,
    })

    local function iconBtn(txt, xOff)
        local b = _btn(titleBar, {
            Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,xOff,0.5,-11),
            Text=txt, TextSize=12, Font=Enum.Font.GothamBold,
            TextColor3=C.sub, BackgroundColor3=C.panel,
        }, C.text)
        _corner(b, 4); return b
    end
    local minBtn   = iconBtn("─", -50)
    local closeBtn = iconBtn("✕", -25)

    -- ── Tab bar (left side) ──────────────────────────────────────
    local tabBar = _frame(main, {
        Size=UDim2.new(0,TabW,1,-34), Position=UDim2.new(0,0,0,34),
        BackgroundColor3=C.panel,
    })
    _stroke(tabBar, C.border, 1)

    -- ── Content area (right of tab bar) ─────────────────────────
    local contentArea = _frame(main, {
        Size=UDim2.new(1,-TabW,1,-34), Position=UDim2.new(0,TabW,0,34),
        BackgroundTransparency=1, ClipsDescendants=true,
    })

    _draggable(titleBar, main, conns)

    -- ── Internal state ───────────────────────────────────────────
    local tabs         = {}       -- [name] = { btn, page, yOffset }
    local tabBtnY      = 4
    local activeTabId  = nil
    local floatPanels  = {}       -- list of panel _frame references
    local panelWasOpen = {}       -- [panel] = bool; used by minimize
    local minimized    = false
    local visible      = true
    local inputCbs     = {}

    -- Switch active tab
    local function setTab(id)
        activeTabId = id
        for tid, info in pairs(tabs) do
            local on = (tid == id)
            info.page.Visible = on
            TweenService:Create(info.btn, TweenInfo.new(0.12), {
                BackgroundColor3 = on and C.tabActive or C.panel
            }):Play()
            for _, ch in ipairs(info.btn:GetChildren()) do
                if ch:IsA("TextLabel") then
                    TweenService:Create(ch, TweenInfo.new(0.12), {
                        TextColor3 = on and C.accent or C.sub
                    }):Play()
                end
            end
        end
    end

    -- ── Minimize ─────────────────────────────────────────────────
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local h = minimized and 34 or H
        TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size=UDim2.new(0,W,0,h)}):Play()
        minBtn.Text = minimized and "□" or "─"
        for _, pf in ipairs(floatPanels) do
            if minimized then panelWasOpen[pf] = pf.Visible; pf.Visible=false
            else               pf.Visible = panelWasOpen[pf] or false end
        end
    end)

    -- ── Close ────────────────────────────────────────────────────
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(main, TweenInfo.new(0.18), {Size=UDim2.new(0,W,0,0)}):Play()
        task.delay(0.22, function()
            for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
            pcall(function() sg:Destroy() end)
        end)
    end)

    -- ── Global keyboard input dispatcher ─────────────────────────
    tc(UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or bindRef.active then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, cb in ipairs(inputCbs) do pcall(cb, inp.KeyCode) end
    end))

    -- ══════════════════════════════════════════════════════════════
    --  WINDOW OBJECT  (returned to the caller)
    -- ══════════════════════════════════════════════════════════════
    local win = {}

    -- ── win:Tab(name, icon)  ──────────────────────────────────────
    --  Creates a tab button + scrolling page and returns a Tab object.
    function win:Tab(name, icon)
        local btnY = tabBtnY; tabBtnY = tabBtnY + 60

        local btn = _btn(tabBar, {
            Size=UDim2.new(1,0,0,56), Position=UDim2.new(0,0,0,btnY),
            Text="", BackgroundColor3=C.panel,
        })
        _label(btn, {Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0,8),
            Text=icon or "", TextSize=14, Font=Enum.Font.GothamBold,
            TextColor3=C.sub, TextXAlignment=Enum.TextXAlignment.Center})
        _label(btn, {Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,28),
            Text=name, TextSize=8, Font=Enum.Font.Gotham,
            TextColor3=C.sub, TextXAlignment=Enum.TextXAlignment.Center})

        local page = Instance.new("ScrollingFrame")
        page.Name=name.."Page"; page.Size=UDim2.new(1,0,1,0)
        page.BackgroundTransparency=1; page.BorderSizePixel=0
        page.ScrollBarThickness=4; page.ScrollBarImageColor3=C.border
        page.CanvasSize=UDim2.new(0,0,0,0)
        page.Visible=false; page.Parent=contentArea

        tabs[name] = { btn=btn, page=page, yOffset=8 }
        btn.MouseButton1Click:Connect(function() setTab(name) end)
        if not activeTabId then setTab(name) end

        -- ── TAB OBJECT ────────────────────────────────────────────
        local tab = { _C=C, _page=page, _tabInfo=tabs[name] }

        local function pushY(amount)
            tab._tabInfo.yOffset = tab._tabInfo.yOffset + amount
            page.CanvasSize = UDim2.new(0,0,0, tab._tabInfo.yOffset + 8)
        end

        -- ────────────────────────────────────────────────────────
        --  tab:Row(label)
        --    Adds a labelled row. Returns a Row object you can add
        --    :Toggle() and/or :Keybind() to.
        --
        --  Row:Toggle(callback, default?) → setFn(on, animated?)
        --  Row:Keybind(defaultKey, callback) → badge TextButton
        -- ────────────────────────────────────────────────────────
        function tab:Row(label)
            local y = self._tabInfo.yOffset
            local row = _frame(page, {
                Size=UDim2.new(1,-12,0,28), Position=UDim2.new(0,6,0,y),
                BackgroundTransparency=1,
            })
            _label(row, {
                Size=UDim2.new(0,110,1,0), Text=label, TextSize=11,
                Font=Enum.Font.Gotham, TextColor3=C.text,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            pushY(36)

            local rowObj = { _row=row, _hasBadge=false, _hasPill=false }

            -- Adds an animated pill toggle to the right side of the row.
            -- Callback receives (bool). Returns setFn(on, animated).
            function rowObj:Toggle(callback, default)
                self._hasPill = true
                local initOn = default or false
                -- If a keybind badge is also present, shift pill left
                local pillPos = self._hasBadge
                    and UDim2.new(1,-92,0.5,-11)
                    or  UDim2.new(1,-44,0.5,-11)
                local pillHit, setFn = _pill(row, pillPos, initOn, C)
                pillHit.MouseButton1Click:Connect(function()
                    initOn = not initOn
                    setFn(initOn, true)
                    if callback then callback(initOn) end
                end)
                return function(on, anim)
                    initOn = on; setFn(on, anim)
                end
            end

            -- Adds a keybind badge to the right side of the row.
            -- defaultKey: Enum.KeyCode or nil. Callback receives (KeyCode or nil).
            -- Returns the badge instance.
            function rowObj:Keybind(defaultKey, callback)
                self._hasBadge = true
                local badge = _keybind(row, defaultKey, callback, C, bindRef)
                badge.Position = UDim2.new(1, self._hasPill and -94 or -48, 0.5, -8)
                return badge
            end

            return rowObj
        end

        -- ────────────────────────────────────────────────────────
        --  tab:SectionHeader(label)
        --    Bold accent-coloured header with a separator line.
        -- ────────────────────────────────────────────────────────
        function tab:SectionHeader(label)
            local y = self._tabInfo.yOffset
            _label(page, {
                Size=UDim2.new(1,-12,0,16), Position=UDim2.new(0,6,0,y),
                Text=label, TextSize=9, Font=Enum.Font.GothamBold,
                TextColor3=C.accent, TextXAlignment=Enum.TextXAlignment.Left,
            })
            _frame(page, {
                Size=UDim2.new(1,-12,0,1), Position=UDim2.new(0,6,0,y+17),
                BackgroundColor3=C.border,
            })
            pushY(24)
        end

        -- ────────────────────────────────────────────────────────
        --  tab:Separator()  — thin horizontal divider line
        -- ────────────────────────────────────────────────────────
        function tab:Separator()
            local y = self._tabInfo.yOffset
            _frame(page, {
                Size=UDim2.new(1,-12,0,1), Position=UDim2.new(0,6,0,y),
                BackgroundColor3=C.border,
            })
            pushY(9)
        end

        -- ────────────────────────────────────────────────────────
        --  tab:InfoLabel(text)
        --    Small muted sub-text label (wraps automatically).
        -- ────────────────────────────────────────────────────────
        function tab:InfoLabel(text)
            local y = self._tabInfo.yOffset
            _label(page, {
                Size=UDim2.new(1,-12,0,24), Position=UDim2.new(0,6,0,y),
                Text=text, TextSize=8, Font=Enum.Font.Gotham, TextColor3=C.sub,
                TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
            })
            pushY(28)
        end

        -- ────────────────────────────────────────────────────────
        --  tab:PanelButton(label, panelObj)
        --    A button that toggles the visibility of a FloatingPanel.
        --    Tracks open/closed state and shows ▸ / ▾ accordingly.
        -- ────────────────────────────────────────────────────────
        function tab:PanelButton(label, panelObj)
            local y = self._tabInfo.yOffset
            local pf = panelObj._frame
            local open = false
            table.insert(floatPanels, pf)
            panelWasOpen[pf] = false

            local btn = _btn(page, {
                Size=UDim2.new(1,-12,0,24), Position=UDim2.new(0,6,0,y),
                Text=label.." ▸", TextSize=10, Font=Enum.Font.GothamBold,
                TextColor3=C.sub, BackgroundColor3=C.panel,
                TextXAlignment=Enum.TextXAlignment.Center,
            })
            _corner(btn, 5); _stroke(btn, C.border, 1)
            btn.MouseEnter:Connect(function()
                if not open then TweenService:Create(btn,TweenInfo.new(0.1),{TextColor3=C.text}):Play() end
            end)
            btn.MouseLeave:Connect(function()
                if not open then TweenService:Create(btn,TweenInfo.new(0.1),{TextColor3=C.sub}):Play() end
            end)

            btn.MouseButton1Click:Connect(function()
                open = not open
                pf.Visible = open; panelWasOpen[pf] = open
                btn.Text = label .. (open and " ▾" or " ▸")
                TweenService:Create(btn,TweenInfo.new(0.1),{TextColor3=open and C.accent or C.sub}):Play()
            end)
            pushY(32)
            return btn
        end

        -- ────────────────────────────────────────────────────────
        --  tab:DistanceRow(espData, sliderMax?)
        --    A distance slider + on/off pill for ESP distance filtering.
        --    espData = { dist: number, distOn: bool }
        --    Mutates espData.dist and espData.distOn directly.
        -- ────────────────────────────────────────────────────────
        function tab:DistanceRow(espData, sliderMax)
            local y = self._tabInfo.yOffset
            _distanceRow(page, y, espData, sliderMax or 500, C, conns)
            pushY(58)
        end

        return tab
    end

    -- ── win:FloatingPanel(title, x, y) ───────────────────────────
    --  Creates a draggable floating panel parented to the ScreenGui.
    --  Returns a panel object with :SetESPData(...).
    function win:FloatingPanel(title, x, y)
        return buildFloatingPanel(sg, title, x, y, C, conns)
    end

    -- ── win:OnInput(callback) ────────────────────────────────────
    --  Register a function called on every keyboard press (unless
    --  a keybind is being actively recorded).
    --  Callback receives (Enum.KeyCode).
    function win:OnInput(callback)
        table.insert(inputCbs, callback)
    end

    -- ── win:SetVisible(bool) ─────────────────────────────────────
    function win:SetVisible(v)
        visible = v
        main.Visible = v
        for _, pf in ipairs(floatPanels) do
            if v then pf.Visible = panelWasOpen[pf] or false
            else       panelWasOpen[pf] = pf.Visible; pf.Visible = false end
        end
    end

    function win:IsVisible() return visible end

    -- ── win:Destroy() ────────────────────────────────────────────
    function win:Destroy()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        pcall(function() sg:Destroy() end)
    end

    return win
end

return CartLib
