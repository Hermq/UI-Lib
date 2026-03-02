--[[
╔══════════════════════════════════════════════════════════════════════╗
║  CartLib.lua  |  Roblox Exploit UI Library                          ║
║  v2.0  — Revamped with: Sliders, Dropdowns, Buttons, TextBoxes,     ║
║           Notifications, Flags system, Theme system, Config I/O,    ║
║           plus all original v1 components.                          ║
╚══════════════════════════════════════════════════════════════════════╝

  QUICK START
  ───────────
  local Lib = loadstring(game:HttpGet("RAW_CARTLIB_URL"))()
  local win  = Lib.new("My Script", { width=320, height=380 })

  local tab = win:Tab("Main", "⚙")

  tab:Row("God Mode"):Toggle(function(on) print(on) end, false, "godmode")
  tab:Slider("Walk Speed",  { min=16, max=200, default=100, flag="ws",
      callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end })
  tab:Dropdown("Hit Part",  {"Head","Torso","Random"}, { flag="hitpart",
      callback = function(v) print("selected:", v) end })
  tab:Button("Teleport",    function() print("tp!") end)
  tab:TextBox("Player Name","Enter name…", function(v) print(v) end, { flag="pname" })

  win:Notify("Loaded!", "Script started.", 4)

  win:SaveConfig("default")
  win:LoadConfig("default")
]]

local CartLib    = {}
CartLib.Flags    = {}     -- global flags: CartLib.Flags["my_flag"] = value
CartLib._version = "2.0"

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local player           = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════
--  SAFE TWEEN  (never crashes if TweenService:Create returns nil)
-- ════════════════════════════════════════════════════════════════
local function _tween(inst, duration, goals)
    local ok, tw = pcall(function()
        return TweenService:Create(inst, TweenInfo.new(duration, Enum.EasingStyle.Quad), goals)
    end)
    if ok and tw then pcall(function() tw:Play() end) end
end

-- ════════════════════════════════════════════════════════════════
--  DEFAULT THEME  (identical palette to v1 + new entries)
-- ════════════════════════════════════════════════════════════════
CartLib.DefaultTheme = {
    bg          = Color3.fromRGB( 12,  12,  18),
    panel       = Color3.fromRGB( 20,  20,  30),
    tabActive   = Color3.fromRGB( 25,  35,  60),
    border      = Color3.fromRGB( 50,  50,  80),
    accent      = Color3.fromRGB( 80, 160, 255),
    green       = Color3.fromRGB( 60, 220, 120),
    red         = Color3.fromRGB(220,  70,  70),
    text        = Color3.fromRGB(220, 225, 240),
    sub         = Color3.fromRGB(120, 125, 150),
    sliderbg    = Color3.fromRGB( 35,  35,  55),
    sliderfill  = Color3.fromRGB( 80, 160, 255),
    bindlisten  = Color3.fromRGB(255, 200,  60),
    bindset     = Color3.fromRGB( 80, 160, 255),
    dropbg      = Color3.fromRGB( 18,  18,  28),
    notifbg     = Color3.fromRGB( 20,  20,  32),
    inputbg     = Color3.fromRGB( 18,  18,  28),
}

-- ════════════════════════════════════════════════════════════════
--  GUI PRIMITIVES
-- ════════════════════════════════════════════════════════════════
local function _corner(inst, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = inst
end
local function _stroke(inst, col, t)
    local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = t or 1; s.Parent = inst; return s
end
local function _frame(parent, props)
    local f = Instance.new("Frame"); f.BorderSizePixel = 0
    for k,v in pairs(props or {}) do f[k] = v end
    if parent then f.Parent = parent end; return f
end
local function _label(parent, props)
    local l = Instance.new("TextLabel"); l.BorderSizePixel = 0; l.BackgroundTransparency = 1
    for k,v in pairs(props or {}) do l[k] = v end
    if parent then l.Parent = parent end; return l
end
local function _btn(parent, props, hoverBg)
    local b = Instance.new("TextButton"); b.BorderSizePixel = 0; b.AutoButtonColor = false
    for k,v in pairs(props or {}) do b[k] = v end
    if parent then b.Parent = parent end
    if hoverBg then
        local base = (props and props.BackgroundColor3) or Color3.new(0,0,0)
        b.MouseEnter:Connect(function()  _tween(b, 0.1, {BackgroundColor3 = hoverBg}) end)
        b.MouseLeave:Connect(function()  _tween(b, 0.1, {BackgroundColor3 = base})    end)
    end
    return b
end
local function _box(parent, props)
    local x = Instance.new("TextBox"); x.BorderSizePixel = 0; x.ClearTextOnFocus = false
    for k,v in pairs(props or {}) do x[k] = v end
    if parent then x.Parent = parent end; return x
end
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
--  PILL TOGGLE
-- ════════════════════════════════════════════════════════════════
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
    hit.Text = ""; hit.BorderSizePixel = 0; hit.AutoButtonColor = false; hit.Parent = bg
    local function setFn(on, anim)
        local kx = on and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8)
        if anim then
            _tween(knob, 0.15, {Position=kx, BackgroundColor3 = on and Color3.new(1,1,1) or C.sub})
            _tween(bg,   0.15, {BackgroundColor3 = on and C.green or C.sliderbg})
        else
            knob.Position = kx
            knob.BackgroundColor3 = on and Color3.new(1,1,1) or C.sub
            bg.BackgroundColor3   = on and C.green or C.sliderbg
        end
    end
    return hit, setFn
end

-- ════════════════════════════════════════════════════════════════
--  KEYBIND BADGE
-- ════════════════════════════════════════════════════════════════
local function _keybind(parent, initKey, onBind, C, bindRef)
    local function shortName(kc)
        return kc.Name
            :gsub("LeftControl","LCtrl"):gsub("RightControl","RCtrl")
            :gsub("LeftShift",  "LShft"):gsub("RightShift",  "RShft")
            :gsub("LeftAlt",    "LAlt" ):gsub("RightAlt",    "RAlt" )
            :sub(1,5)
    end
    local badge = _btn(parent, {
        Size = UDim2.new(0,46,0,17), TextSize = 9, Font = Enum.Font.GothamBold,
        BackgroundColor3 = C.panel,
        Text = initKey and shortName(initKey) or "None",
        TextColor3 = initKey and C.bindset or C.sub,
    })
    _corner(badge, 3); _stroke(badge, C.border, 1)
    local function refreshColors()
        badge.TextColor3       = badge.Text ~= "None" and C.bindset or C.sub
        badge.BackgroundColor3 = C.panel
    end
    local lConn = nil
    local function stopListen()
        if lConn then lConn:Disconnect(); lConn = nil end
        if bindRef then bindRef.active = false end
        refreshColors()
    end
    badge.MouseButton1Click:Connect(function()
        if lConn then stopListen(); return end
        if bindRef then bindRef.active = true end
        badge.Text = "···"; badge.TextColor3 = C.bindlisten
        badge.BackgroundColor3 = Color3.fromRGB(35,28,8)
        lConn = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
            lConn:Disconnect(); lConn = nil
            if bindRef then bindRef.active = false end
            if inp.KeyCode == Enum.KeyCode.Escape then
                badge.Text = "None"; onBind(nil)
            else
                badge.Text = shortName(inp.KeyCode); onBind(inp.KeyCode)
            end
            refreshColors()
        end)
    end)
    return badge
end

-- ════════════════════════════════════════════════════════════════
--  FLOATING PANEL  (unchanged from v1)
-- ════════════════════════════════════════════════════════════════
local function buildFloatingPanel(sg, title, x, y, C, conns)
    local panel = _frame(sg, {
        Size = UDim2.new(0,240,0,320), Position = UDim2.new(0,x,0,y),
        BackgroundColor3 = C.bg, Visible = false, ClipsDescendants = true,
    })
    _corner(panel, 8); _stroke(panel, C.border, 1)

    local pTitle = _frame(panel, {Size=UDim2.new(1,0,0,30), BackgroundColor3=C.panel})
    _label(pTitle, {
        Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,10,0,0),
        Text=title, TextSize=10, Font=Enum.Font.GothamBold,
        TextColor3=C.accent, TextXAlignment=Enum.TextXAlignment.Left,
    })
    _draggable(pTitle, panel, conns)

    local toolbar = _frame(panel, {
        Size=UDim2.new(1,0,0,28), Position=UDim2.new(0,0,0,30), BackgroundTransparency=1,
    })
    local deselectBtn = _btn(toolbar, {
        Size=UDim2.new(0,100,0,20), Position=UDim2.new(1,-108,0.5,-10),
        Text="☐ Deselect All", TextSize=9, Font=Enum.Font.GothamBold,
        TextColor3=C.sub, BackgroundColor3=C.panel,
    }, C.tabActive)
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

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,-4,1,-65); scroll.Position=UDim2.new(0,2,0,64)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=4; scroll.ScrollBarImageColor3=C.border
    scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.Parent=panel

    local layout=Instance.new("UIListLayout")
    layout.SortOrder=Enum.SortOrder.Name; layout.Padding=UDim.new(0,2); layout.Parent=scroll

    local searchFilter=""
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchFilter=searchBox.Text
        for _,ch in ipairs(scroll:GetChildren()) do
            if ch:IsA("Frame") then
                ch.Visible = searchFilter=="" or ch.Name:lower():find(searchFilter:lower(),1,true)~=nil
            end
        end
    end)

    local panelObj={_frame=panel, _scroll=scroll}
    function panelObj:SetESPData(entries, colorFn, onToggleCb)
        local function buildRow(name, entry)
            local cols=colorFn(name)
            local row=_frame(scroll,{
                Name=name, Size=UDim2.new(1,-6,0,28), BackgroundTransparency=1,
                Visible=searchFilter=="" or name:lower():find(searchFilter:lower(),1,true)~=nil,
            })
            local dot=_frame(row,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,6,0.5,-4),BackgroundColor3=cols[1]})
            _corner(dot,4)
            _label(row,{
                Size=UDim2.new(1,-70,1,0), Position=UDim2.new(0,20,0,0),
                Text=name, TextSize=10, Font=Enum.Font.Gotham, TextColor3=C.text,
                TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd,
            })
            local pillHit,setPill=_pill(row,UDim2.new(1,-48,0.5,-11),entry.enabled,C)
            pillHit.MouseButton1Click:Connect(function()
                entry.enabled=not entry.enabled; setPill(entry.enabled,true)
                if onToggleCb then onToggleCb() end
            end)
        end
        local function rebuild()
            for _,ch in ipairs(scroll:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
            local count=0
            for name,entry in pairs(entries) do buildRow(name,entry); count=count+1 end
            scroll.CanvasSize=UDim2.new(0,0,0,count*30+4)
        end
        deselectBtn.MouseButton1Click:Connect(function()
            for _,entry in pairs(entries) do entry.enabled=false end
            if onToggleCb then onToggleCb() end; rebuild()
        end)
        return rebuild
    end
    return panelObj
end

-- ════════════════════════════════════════════════════════════════
--  DISTANCE SLIDER ROW  (unchanged from v1)
-- ════════════════════════════════════════════════════════════════
local function _distanceRow(page, yPos, espData, sliderMax, C, conns)
    sliderMax=sliderMax or 500
    local row=_frame(page,{Size=UDim2.new(1,-16,0,50),Position=UDim2.new(0,8,0,yPos),BackgroundTransparency=1})
    _label(row,{Size=UDim2.new(0,70,0,20),Text="Distance:",TextSize=10,Font=Enum.Font.GothamBold,
        TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Left})
    local pillHit,setPill=_pill(row,UDim2.new(1,-44,0,-1),espData.distOn,C)
    pillHit.MouseButton1Click:Connect(function() espData.distOn=not espData.distOn; setPill(espData.distOn,true) end)
    local valRow=_frame(row,{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,26),BackgroundTransparency=1})
    local track=_frame(valRow,{Size=UDim2.new(1,-52,0,6),Position=UDim2.new(0,0,0.5,-3),BackgroundColor3=C.sliderbg})
    _corner(track,3); _stroke(track,C.border,1)
    local fill=_frame(track,{Size=UDim2.new(espData.dist/sliderMax,0,1,0),BackgroundColor3=C.sliderfill})
    _corner(fill,3)
    local sKnob=_frame(track,{Size=UDim2.new(0,12,0,12),Position=UDim2.new(espData.dist/sliderMax,-6,0.5,-6),BackgroundColor3=Color3.new(1,1,1)})
    _corner(sKnob,6)
    local valLbl=_btn(valRow,{Size=UDim2.new(0,48,0,20),Position=UDim2.new(1,-48,0,0),
        Text=tostring(espData.dist),TextSize=10,Font=Enum.Font.GothamBold,
        TextColor3=C.accent,BackgroundColor3=C.panel,TextXAlignment=Enum.TextXAlignment.Center})
    _corner(valLbl,3); _stroke(valLbl,C.border,1)
    local valBox=_box(valRow,{Size=UDim2.new(0,48,0,20),Position=UDim2.new(1,-48,0,0),
        Text=tostring(espData.dist),TextSize=10,Font=Enum.Font.GothamBold,
        TextColor3=C.accent,BackgroundColor3=C.panel,TextXAlignment=Enum.TextXAlignment.Center,Visible=false})
    _corner(valBox,3); _stroke(valBox,C.border,1)
    local function setDist(v)
        v=math.max(1,math.floor(v)); espData.dist=v
        local frac=math.clamp(v/sliderMax,0,1)
        fill.Size=UDim2.new(frac,0,1,0); sKnob.Position=UDim2.new(frac,-6,0.5,-6)
        valLbl.Text=tostring(v); valBox.Text=tostring(v)
    end
    local sDragging=false
    local sHit=_btn(track,{Size=UDim2.new(1,12,0,22),Position=UDim2.new(0,-6,0.5,-11),BackgroundTransparency=1,Text=""})
    sHit.MouseButton1Down:Connect(function() sDragging=true end)
    table.insert(conns,UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then sDragging=false end
    end))
    table.insert(conns,RunService.RenderStepped:Connect(function()
        if sDragging then
            local mx=player:GetMouse().X
            setDist(math.clamp((mx-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*sliderMax)
        end
    end))
    valLbl.MouseButton1Click:Connect(function() valLbl.Visible=false; valBox.Visible=true; valBox:CaptureFocus() end)
    valBox.FocusLost:Connect(function()
        local n=tonumber(valBox.Text); if n then setDist(n) end
        valLbl.Visible=true; valBox.Visible=false
    end)
    return setDist
end

-- ════════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════════
local _notifSg, _notifHolder

local function _ensureNotifHolder(sg, C)
    if _notifHolder and _notifHolder.Parent == sg then return end
    _notifHolder = _frame(sg, {
        Size=UDim2.new(0,260,1,0), Position=UDim2.new(1,-270,0,0),
        BackgroundTransparency=1, ZIndex=50,
    })
    local ll=Instance.new("UIListLayout")
    ll.SortOrder=Enum.SortOrder.LayoutOrder
    ll.VerticalAlignment=Enum.VerticalAlignment.Bottom
    ll.Padding=UDim.new(0,6); ll.Parent=_notifHolder
    local pad=Instance.new("UIPadding")
    pad.PaddingBottom=UDim.new(0,12); pad.Parent=_notifHolder
end

local function _spawnNotif(sg, C, title, text, duration)
    _ensureNotifHolder(sg, C)
    duration = math.max(0.5, duration or 4)

    local card=_frame(_notifHolder, {
        Size=UDim2.new(1,0,0,62), BackgroundColor3=C.notifbg,
        ZIndex=51, LayoutOrder=os.clock()*1000,
    })
    _corner(card, 8); _stroke(card, C.border, 1)

    -- coloured left accent strip
    local strip=_frame(card,{Size=UDim2.new(0,3,1,-8),Position=UDim2.new(0,0,0,4),
        BackgroundColor3=C.accent, ZIndex=52})
    _corner(strip, 2)

    _label(card,{Size=UDim2.new(1,-20,0,18),Position=UDim2.new(0,14,0,8),
        Text=title, TextSize=11, Font=Enum.Font.GothamBold,
        TextColor3=C.accent, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=52})
    _label(card,{Size=UDim2.new(1,-20,0,28),Position=UDim2.new(0,14,0,28),
        Text=text, TextSize=9, Font=Enum.Font.Gotham,
        TextColor3=C.text, TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true, ZIndex=52})

    -- timer bar that shrinks to zero
    local bar=_frame(card,{Size=UDim2.new(1,-4,0,2),Position=UDim2.new(0,2,1,-4),
        BackgroundColor3=C.accent, ZIndex=52})
    _corner(bar,1)

    task.spawn(function()
        _tween(bar, duration, {Size=UDim2.new(0,0,0,2)})
        task.wait(duration)
        _tween(card, 0.25, {BackgroundTransparency=1})
        task.wait(0.3)
        pcall(function() card:Destroy() end)
    end)
end

-- ════════════════════════════════════════════════════════════════
--  CartLib.new  —  creates a window and returns the window object
-- ════════════════════════════════════════════════════════════════
function CartLib.new(title, opts)
    opts = opts or {}
    local C   = opts.theme       or CartLib.DefaultTheme
    local W   = opts.width       or 320
    local H   = opts.height      or 380
    local TabW= opts.tabBarWidth or 52
    local pos = opts.position    or UDim2.new(0,20,0,20)

    local conns    = {}
    local bindRef  = {active=false}
    local inputCbs = {}
    local floatPanels  = {}
    local panelWasOpen = {}
    local minimized    = false
    local visible      = true
    local activeTabId  = nil
    local tabs         = {}
    local tabBtnY      = 4

    -- ── ScreenGui ──────────────────────────────────────────────
    local CoreGui    = game:GetService("CoreGui")
    local GuiService = game:GetService("GuiService")
    local coreGuiOk  = pcall(function()
        local t=Instance.new("ScreenGui"); t.Parent=CoreGui; t:Destroy()
    end)
    local sg=Instance.new("ScreenGui")
    sg.Name=opts.name or "CartLib"; sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset=true; sg.DisplayOrder=5
    sg.Parent=player.PlayerGui
    if coreGuiOk then
        table.insert(conns, GuiService.MenuOpened:Connect(function()
            pcall(function() sg.Parent=CoreGui end)
        end))
        table.insert(conns, GuiService.MenuClosed:Connect(function()
            pcall(function() sg.Parent=player.PlayerGui end)
        end))
    end

    -- ── Main frame ─────────────────────────────────────────────
    local main=_frame(sg,{
        Name="Main", Size=UDim2.new(0,W,0,H), Position=pos,
        BackgroundColor3=C.bg, ClipsDescendants=true,
    })
    _corner(main,8); _stroke(main,C.border,1)

    local titleBar=_frame(main,{Size=UDim2.new(1,0,0,34), BackgroundColor3=C.panel})
    _label(titleBar,{
        Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,12,0,0),
        Text=title, TextSize=12, Font=Enum.Font.GothamBold,
        TextColor3=C.accent, TextXAlignment=Enum.TextXAlignment.Left,
    })
    local function iconBtn(txt, xOff)
        local b=_btn(titleBar,{
            Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,xOff,0.5,-11),
            Text=txt, TextSize=12, Font=Enum.Font.GothamBold,
            TextColor3=C.sub, BackgroundColor3=C.panel,
        })
        _corner(b,4); return b
    end
    local minBtn   = iconBtn("─",-50)
    local closeBtn = iconBtn("✕",-25)

    local tabBar=_frame(main,{
        Size=UDim2.new(0,TabW,1,-34), Position=UDim2.new(0,0,0,34),
        BackgroundColor3=C.panel,
    })
    _stroke(tabBar,C.border,1)

    local contentArea=_frame(main,{
        Size=UDim2.new(1,-TabW,1,-34), Position=UDim2.new(0,TabW,0,34),
        BackgroundTransparency=1, ClipsDescendants=true,
    })

    _draggable(titleBar, main, conns)

    local function setTab(id)
        activeTabId=id
        for tid,info in pairs(tabs) do
            local on=tid==id
            info.page.Visible=on
            _tween(info.btn, 0.12, {BackgroundColor3=on and C.tabActive or C.panel})
            for _,ch in ipairs(info.btn:GetChildren()) do
                if ch:IsA("TextLabel") then
                    _tween(ch, 0.12, {TextColor3=on and C.accent or C.sub})
                end
            end
        end
    end

    minBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        _tween(main, 0.18, {Size=UDim2.new(0,W,0,minimized and 34 or H)})
        minBtn.Text=minimized and "□" or "─"
        for _,pf in ipairs(floatPanels) do
            if minimized then panelWasOpen[pf]=pf.Visible; pf.Visible=false
            else pf.Visible=panelWasOpen[pf] or false end
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        _tween(main, 0.18, {Size=UDim2.new(0,W,0,0)})
        task.delay(0.22, function()
            for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
            pcall(function() sg:Destroy() end)
        end)
    end)
    table.insert(conns, UserInputService.InputBegan:Connect(function(inp,gp)
        if gp or bindRef.active then return end
        if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        for _,cb in ipairs(inputCbs) do pcall(cb, inp.KeyCode) end
    end))

    -- ════════════════════════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ════════════════════════════════════════════════════════════════
    local win={}

    ---- win:Tab(name, icon) ----------------------------------------
    function win:Tab(name, icon)
        local btnY=tabBtnY; tabBtnY=tabBtnY+60
        local btn=_btn(tabBar,{
            Size=UDim2.new(1,0,0,56), Position=UDim2.new(0,0,0,btnY),
            Text="", BackgroundColor3=C.panel,
        })
        _label(btn,{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,8),
            Text=icon or "", TextSize=14, Font=Enum.Font.GothamBold,
            TextColor3=C.sub, TextXAlignment=Enum.TextXAlignment.Center})
        _label(btn,{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,28),
            Text=name, TextSize=8, Font=Enum.Font.Gotham,
            TextColor3=C.sub, TextXAlignment=Enum.TextXAlignment.Center})

        local page=Instance.new("ScrollingFrame")
        page.Name=name.."Page"; page.Size=UDim2.new(1,0,1,0)
        page.BackgroundTransparency=1; page.BorderSizePixel=0
        page.ScrollBarThickness=4; page.ScrollBarImageColor3=C.border
        page.CanvasSize=UDim2.new(0,0,0,0); page.Visible=false; page.Parent=contentArea

        local tabInfo={btn=btn, page=page, yOffset=8}
        tabs[name]=tabInfo
        btn.MouseButton1Click:Connect(function() setTab(name) end)
        if not activeTabId then setTab(name) end

        local tab={}
        local function pushY(a) tabInfo.yOffset=tabInfo.yOffset+a; page.CanvasSize=UDim2.new(0,0,0,tabInfo.yOffset+8) end

        ---------- tab:Row(label) ------------------------------------
        -- Hosts a toggle pill and optional keybind badge.
        function tab:Row(label)
            local y=tabInfo.yOffset
            local row=_frame(page,{Size=UDim2.new(1,-12,0,28),Position=UDim2.new(0,6,0,y),BackgroundTransparency=1})
            _label(row,{Size=UDim2.new(0,110,1,0),Text=label,TextSize=11,Font=Enum.Font.Gotham,
                TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})
            pushY(36)
            local rowObj={_hasBadge=false}

            -- rowObj:Toggle(callback, default?, flag?) → setValue(bool, animated?)
            function rowObj:Toggle(callback, default, flag)
                local on=default or false
                local px=self._hasBadge and UDim2.new(1,-92,0.5,-11) or UDim2.new(1,-44,0.5,-11)
                local pillHit,setFn=_pill(row,px,on,C)
                if flag then CartLib.Flags[flag]=on end
                pillHit.MouseButton1Click:Connect(function()
                    on=not on; setFn(on,true)
                    if flag then CartLib.Flags[flag]=on end
                    if callback then callback(on) end
                end)
                return function(newOn,anim)
                    on=newOn; setFn(newOn,anim)
                    if flag then CartLib.Flags[flag]=on end
                end
            end

            -- rowObj:Keybind(defaultKey?, callback?, flag?) → badge
            function rowObj:Keybind(defaultKey, callback, flag)
                self._hasBadge=true
                local badge=_keybind(row, defaultKey, function(kc)
                    if flag then CartLib.Flags[flag]=kc end
                    if callback then callback(kc) end
                end, C, bindRef)
                badge.Position=UDim2.new(1,-48,0.5,-8)
                if flag then CartLib.Flags[flag]=defaultKey end
                return badge
            end

            return rowObj
        end

        ---------- tab:Slider(label, opts) --------------------------
        -- opts: { min, max, default, step, suffix, flag, callback }
        -- Returns: setValue(number)
        function tab:Slider(label, opts)
            opts=opts or {}
            local min  =opts.min or 0
            local max  =opts.max or 100
            local step =opts.step or 1
            local def  =math.clamp(opts.default or min, min, max)
            local suf  =opts.suffix or ""
            local flag =opts.flag
            local cb   =opts.callback or function() end
            local val  =def

            local y=tabInfo.yOffset
            local cont=_frame(page,{Size=UDim2.new(1,-12,0,48),Position=UDim2.new(0,6,0,y),BackgroundTransparency=1})
            _label(cont,{Size=UDim2.new(1,-60,0,18),Text=label,TextSize=11,Font=Enum.Font.Gotham,
                TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})
            local valLbl=_label(cont,{Size=UDim2.new(0,56,0,18),Position=UDim2.new(1,-56,0,0),
                Text=tostring(val)..suf,TextSize=11,Font=Enum.Font.GothamBold,
                TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Right})

            local track=_frame(cont,{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,28),BackgroundColor3=C.sliderbg})
            _corner(track,3); _stroke(track,C.border,1)

            local frac=(val-min)/(max==min and 1 or max-min)
            local fill=_frame(track,{Size=UDim2.new(frac,0,1,0),BackgroundColor3=C.sliderfill})
            _corner(fill,3)
            local knob=_frame(track,{Size=UDim2.new(0,14,0,14),Position=UDim2.new(frac,-7,0.5,-7),BackgroundColor3=Color3.new(1,1,1)})
            _corner(knob,7)

            if flag then CartLib.Flags[flag]=val end

            local function setValue(v)
                local range=max-min; if range==0 then range=1 end
                v=math.clamp(math.floor((v-min)/step+0.5)*step+min, min, max)
                val=v
                local f=(v-min)/range
                fill.Size=UDim2.new(f,0,1,0); knob.Position=UDim2.new(f,-7,0.5,-7)
                valLbl.Text=tostring(v)..suf
                if flag then CartLib.Flags[flag]=v end
                cb(v)
            end

            local dragging=false
            local hitArea=_btn(track,{Size=UDim2.new(1,14,0,22),Position=UDim2.new(0,-7,0.5,-11),BackgroundTransparency=1,Text=""})
            hitArea.MouseButton1Down:Connect(function() dragging=true end)
            table.insert(conns,UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
            end))
            table.insert(conns,RunService.RenderStepped:Connect(function()
                if dragging then
                    local mx=player:GetMouse().X
                    setValue(min+math.clamp((mx-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(max-min))
                end
            end))
            pushY(56)
            return setValue
        end

        ---------- tab:Button(label, callback, opts) ----------------
        -- opts: { style="primary"|"default" }
        -- Returns: button instance
        function tab:Button(label, callback, opts)
            opts=opts or {}
            local isPrimary=opts.style=="primary"
            local baseBg=isPrimary and C.accent or C.panel
            local hovBg =isPrimary and Color3.fromRGB(100,175,255) or C.tabActive
            local y=tabInfo.yOffset
            local btn2=_btn(page,{
                Size=UDim2.new(1,-12,0,26), Position=UDim2.new(0,6,0,y),
                Text=label, TextSize=11, Font=Enum.Font.GothamBold,
                TextColor3=isPrimary and Color3.new(1,1,1) or C.text,
                BackgroundColor3=baseBg, TextXAlignment=Enum.TextXAlignment.Center,
            }, hovBg)
            _corner(btn2,6); _stroke(btn2,C.border,1)
            btn2.MouseButton1Click:Connect(function() if callback then callback() end end)
            pushY(34)
            return btn2
        end

        ---------- tab:Dropdown(label, items, opts) -----------------
        -- items: string array
        -- opts: { flag, default, callback, maxHeight }
        -- Returns: { setValue(str), refresh(newItems[]) }
        function tab:Dropdown(label, items, opts)
            opts=opts or {}
            local flag  =opts.flag
            local cb    =opts.callback or function() end
            local curVal=opts.default or (items[1] or "")
            local open  =false
            local itemH =22
            local maxH  =opts.maxHeight or 120

            local y=tabInfo.yOffset
            local cont=_frame(page,{Size=UDim2.new(1,-12,0,48),Position=UDim2.new(0,6,0,y),BackgroundTransparency=1})
            _label(cont,{Size=UDim2.new(1,-6,0,18),Text=label,TextSize=11,Font=Enum.Font.Gotham,
                TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})

            local header=_btn(cont,{Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,0,20),
                Text="",BackgroundColor3=C.panel})
            _corner(header,5); _stroke(header,C.border,1)
            local curLbl=_label(header,{Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,8,0,0),
                Text=curVal,TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})
            local arrow=_label(header,{Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-20,0,0),
                Text="▾",TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Center})

            -- list renders above everything in sg
            local listFrame=_frame(sg,{Size=UDim2.new(0,0,0,0),BackgroundColor3=C.dropbg,Visible=false,ZIndex=20,ClipsDescendants=true})
            _corner(listFrame,5); _stroke(listFrame,C.border,1)
            local lscroll=Instance.new("ScrollingFrame")
            lscroll.Size=UDim2.new(1,0,1,0); lscroll.BackgroundTransparency=1; lscroll.BorderSizePixel=0
            lscroll.ScrollBarThickness=3; lscroll.ScrollBarImageColor3=C.border; lscroll.ZIndex=21; lscroll.Parent=listFrame
            local ll=Instance.new("UIListLayout"); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,2); ll.Parent=lscroll

            if flag then CartLib.Flags[flag]=curVal end

            local function closeDD()
                open=false
                _tween(listFrame,0.12,{Size=UDim2.new(0,listFrame.Size.X.Offset,0,0)})
                task.delay(0.14,function() listFrame.Visible=false end)
                arrow.Text="▾"
            end
            local function openDD()
                local abs=header.AbsolutePosition; local aw=header.AbsoluteSize.X
                local totalH=math.min(#items*(itemH+2),maxH)
                listFrame.Position=UDim2.new(0,abs.X,0,abs.Y+28)
                listFrame.Size=UDim2.new(0,aw,0,0); listFrame.Visible=true
                lscroll.CanvasSize=UDim2.new(0,0,0,#items*(itemH+2))
                _tween(listFrame,0.12,{Size=UDim2.new(0,aw,0,totalH)})
                arrow.Text="▴"; open=true
            end

            local function buildItems(itemList)
                for _,ch in ipairs(lscroll:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
                for i,item in ipairs(itemList) do
                    local iBtn=_btn(lscroll,{
                        Size=UDim2.new(1,-4,0,itemH), BackgroundColor3=C.dropbg,
                        Text=item, TextSize=10, Font=Enum.Font.Gotham,
                        TextColor3=item==curVal and C.accent or C.text,
                        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22, LayoutOrder=i,
                    })
                    local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,8); pad.Parent=iBtn
                    iBtn.MouseEnter:Connect(function() if item~=curVal then _tween(iBtn,0.08,{BackgroundColor3=C.tabActive}) end end)
                    iBtn.MouseLeave:Connect(function() if item~=curVal then _tween(iBtn,0.08,{BackgroundColor3=C.dropbg}) end end)
                    iBtn.MouseButton1Click:Connect(function()
                        curVal=item; curLbl.Text=item
                        if flag then CartLib.Flags[flag]=item end
                        cb(item); closeDD()
                        for _,ch2 in ipairs(lscroll:GetChildren()) do
                            if ch2:IsA("TextButton") then
                                ch2.TextColor3=ch2.Text==curVal and C.accent or C.text
                                ch2.BackgroundColor3=C.dropbg
                            end
                        end
                    end)
                end
            end
            buildItems(items)

            header.MouseButton1Click:Connect(function() if open then closeDD() else openDD() end end)
            table.insert(conns,UserInputService.InputBegan:Connect(function(inp)
                if open and inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    local mx,my=inp.Position.X,inp.Position.Y
                    local lp=listFrame.AbsolutePosition; local ls=listFrame.AbsoluteSize
                    if not(mx>=lp.X and mx<=lp.X+ls.X and my>=lp.Y and my<=lp.Y+ls.Y) then closeDD() end
                end
            end))

            pushY(56)
            local dropObj={}
            function dropObj:setValue(v) curVal=v; curLbl.Text=v; if flag then CartLib.Flags[flag]=v end end
            function dropObj:refresh(newItems)
                items=newItems; buildItems(newItems)
                if not table.find(newItems,curVal) then
                    curVal=newItems[1] or ""; curLbl.Text=curVal
                    if flag then CartLib.Flags[flag]=curVal end
                end
            end
            return dropObj
        end

        ---------- tab:TextBox(label, placeholder, callback, opts) --
        -- opts: { flag, default, onEnter }
        -- callback fires on every keystroke; onEnter fires on FocusLost
        -- Returns: setValue(str)
        function tab:TextBox(label, placeholder, callback, opts)
            opts=opts or {}
            local flag =opts.flag
            local def  =opts.default or ""
            local cb   =callback or function() end
            local onEnter=opts.onEnter or function() end

            local y=tabInfo.yOffset
            local cont=_frame(page,{Size=UDim2.new(1,-12,0,48),Position=UDim2.new(0,6,0,y),BackgroundTransparency=1})
            _label(cont,{Size=UDim2.new(1,-6,0,18),Text=label,TextSize=11,Font=Enum.Font.Gotham,
                TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})

            local inputBg=_frame(cont,{Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,0,20),BackgroundColor3=C.inputbg})
            _corner(inputBg,5)
            local stroke=_stroke(inputBg,C.border,1)

            local tb=_box(inputBg,{
                Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,8,0,0),
                Text=def, PlaceholderText=placeholder or "",
                TextSize=10, Font=Enum.Font.Gotham,
                TextColor3=C.text, PlaceholderColor3=C.sub, BackgroundTransparency=1,
            })

            if flag then CartLib.Flags[flag]=def end
            tb:GetPropertyChangedSignal("Text"):Connect(function()
                if flag then CartLib.Flags[flag]=tb.Text end; cb(tb.Text)
            end)
            tb.Focused:Connect(function()    stroke.Color=C.accent end)
            tb.FocusLost:Connect(function(enter)
                stroke.Color=C.border
                if enter then onEnter(tb.Text) end
            end)

            pushY(56)
            return function(v) tb.Text=v or "" end
        end

        ---------- tab:SectionHeader(label) -------------------------
        function tab:SectionHeader(label)
            local y=tabInfo.yOffset
            _label(page,{Size=UDim2.new(1,-12,0,16),Position=UDim2.new(0,6,0,y),
                Text=label,TextSize=9,Font=Enum.Font.GothamBold,
                TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Left})
            _frame(page,{Size=UDim2.new(1,-12,0,1),Position=UDim2.new(0,6,0,y+17),BackgroundColor3=C.border})
            pushY(24)
        end

        ---------- tab:Separator() ----------------------------------
        function tab:Separator()
            _frame(page,{Size=UDim2.new(1,-12,0,1),Position=UDim2.new(0,6,0,tabInfo.yOffset),BackgroundColor3=C.border})
            pushY(9)
        end

        ---------- tab:InfoLabel(text) ------------------------------
        function tab:InfoLabel(text)
            _label(page,{Size=UDim2.new(1,-12,0,24),Position=UDim2.new(0,6,0,tabInfo.yOffset),
                Text=text,TextSize=8,Font=Enum.Font.Gotham,TextColor3=C.sub,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
            pushY(28)
        end

        ---------- tab:PanelButton(label, panelObj) -----------------
        function tab:PanelButton(label, panelObj)
            local y=tabInfo.yOffset
            local pf=panelObj._frame
            local openP=false
            table.insert(floatPanels,pf); panelWasOpen[pf]=false
            local btn2=_btn(page,{
                Size=UDim2.new(1,-12,0,24), Position=UDim2.new(0,6,0,y),
                Text=label.." ▸", TextSize=10, Font=Enum.Font.GothamBold,
                TextColor3=C.sub, BackgroundColor3=C.panel, TextXAlignment=Enum.TextXAlignment.Center,
            })
            _corner(btn2,5); _stroke(btn2,C.border,1)
            btn2.MouseEnter:Connect(function() if not openP then _tween(btn2,0.1,{TextColor3=C.text}) end end)
            btn2.MouseLeave:Connect(function() if not openP then _tween(btn2,0.1,{TextColor3=C.sub}) end end)
            btn2.MouseButton1Click:Connect(function()
                openP=not openP; pf.Visible=openP; panelWasOpen[pf]=openP
                btn2.Text=label..(openP and " ▾" or " ▸")
                _tween(btn2,0.1,{TextColor3=openP and C.accent or C.sub})
            end)
            pushY(32)
            return btn2
        end

        ---------- tab:DistanceRow(espData, sliderMax) --------------
        function tab:DistanceRow(espData, sliderMax)
            _distanceRow(page, tabInfo.yOffset, espData, sliderMax or 500, C, conns)
            pushY(58)
        end

        return tab
    end

    ---- win:FloatingPanel(title, x, y) ----------------------------
    function win:FloatingPanel(title, x, y)
        return buildFloatingPanel(sg, title, x, y, C, conns)
    end

    ---- win:Notify(title, text, duration) -------------------------
    -- Spawns a toast notification in the bottom-right corner.
    function win:Notify(notifTitle, notifText, duration)
        _spawnNotif(sg, C, notifTitle, notifText, duration)
    end

    ---- win:OnInput(callback) -------------------------------------
    -- callback(keyCode) called for every keyboard press not consumed by UI
    function win:OnInput(callback) table.insert(inputCbs, callback) end

    ---- win:SetVisible(bool) --------------------------------------
    function win:SetVisible(v)
        visible=v; main.Visible=v
        for _,pf in ipairs(floatPanels) do
            if v then pf.Visible=panelWasOpen[pf] or false
            else panelWasOpen[pf]=pf.Visible; pf.Visible=false end
        end
    end

    ---- win:IsVisible() -------------------------------------------
    function win:IsVisible() return visible end

    ---- win:Toggle() ----------------------------------------------
    function win:Toggle() self:SetVisible(not visible) end

    ---- win:SetTheme(themeTable) ----------------------------------
    -- Merges keys from themeTable into the live colour table.
    function win:SetTheme(newTheme)
        for k,v in pairs(newTheme) do C[k]=v end
    end

    ---- win:ChangeAccent(Color3) ----------------------------------
    -- Convenience: update accent, sliderfill and bindset at once.
    function win:ChangeAccent(color3)
        C.accent=color3; C.sliderfill=color3; C.bindset=color3
    end

    ---- win:SaveConfig(name) --------------------------------------
    -- Writes CartLib.Flags to CartLib/<name>.json (needs writefile)
    function win:SaveConfig(name)
        pcall(function()
            if not isfolder("CartLib") then makefolder("CartLib") end
            local t={}
            for k,v in pairs(CartLib.Flags) do
                if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then t[k]=v
                elseif typeof(v)=="EnumItem" then t[k]=tostring(v) end
            end
            writefile("CartLib/"..name..".json", HttpService:JSONEncode(t))
        end)
    end

    ---- win:LoadConfig(name) --------------------------------------
    -- Reads CartLib/<name>.json back into CartLib.Flags (needs readfile)
    function win:LoadConfig(name)
        pcall(function()
            local raw=readfile("CartLib/"..name..".json")
            local t=HttpService:JSONDecode(raw)
            for k,v in pairs(t) do CartLib.Flags[k]=v end
        end)
    end

    ---- win:Destroy() ---------------------------------------------
    function win:Destroy()
        for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns={}; pcall(function() sg:Destroy() end)
    end

    return win
end

return CartLib
