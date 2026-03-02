--[[
╔═══════════════════════════════════════════════════════════════╗
║  CartLib.lua  |  v3.0  —  Roblox Exploit UI Library           ║
║  Same look as the original CartUI, cleaner API surface.       ║
║                                                               ║
║  QUICK START                                                  ║
║    local Lib = loadstring(game:HttpGet("RAW_URL"))()          ║
║    local win = Lib.new("🛒 MY PANEL")                         ║
║    local tab = win:Tab("Main","⚙")                           ║
║                                                               ║
║    -- Toggle only                                             ║
║    tab:Toggle("God Mode",{flag="gm",callback=fn})             ║
║                                                               ║
║    -- Toggle + Keybind on one row                             ║
║    tab:ToggleBind("Auto Drive",                               ║
║        {flag="drive",callback=fn},                            ║
║        {default=Enum.KeyCode.F,flag="drive_k",callback=fn})   ║
║                                                               ║
║    -- Standalone keybind row                                  ║
║    tab:Keybind("Toggle UI",                                   ║
║        {default=Enum.KeyCode.Delete,callback=fn})             ║
║                                                               ║
║    tab:Slider("Speed",{min=16,max=300,flag="spd",callback=fn})║
║    tab:Button("Rejoin", fn)                                   ║
║    tab:Dropdown("Mode",{"A","B"},{flag="m",callback=fn})      ║
║    win:Notify("Loaded!","Script ready.",4)                    ║
╚═══════════════════════════════════════════════════════════════╝
]]

local CartLib    = {}
CartLib.Flags    = {}       -- all flagged components write here
CartLib._version = "3.0"

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local player           = Players.LocalPlayer

-- ─────────────────────────────────────────────────────────────
--  SAFE TWEEN
-- ─────────────────────────────────────────────────────────────
local function tw(inst, t, goals)
    local ok, obj = pcall(TweenService.Create, TweenService, inst,
        TweenInfo.new(t, Enum.EasingStyle.Quad), goals)
    if ok and obj then pcall(obj.Play, obj) end
end

-- ─────────────────────────────────────────────────────────────
--  PALETTE  (same dark blue-black palette as original CartUI)
-- ─────────────────────────────────────────────────────────────
CartLib.DefaultTheme = {
    bg         = Color3.fromRGB( 12,  12,  18),
    panel      = Color3.fromRGB( 20,  20,  30),
    tabOn      = Color3.fromRGB( 25,  35,  60),
    border     = Color3.fromRGB( 50,  50,  80),
    accent     = Color3.fromRGB( 80, 160, 255),
    green      = Color3.fromRGB( 60, 220, 120),
    red        = Color3.fromRGB(220,  70,  70),
    text       = Color3.fromRGB(220, 225, 240),
    sub        = Color3.fromRGB(120, 125, 150),
    sliderBg   = Color3.fromRGB( 35,  35,  55),
    sliderFill = Color3.fromRGB( 80, 160, 255),
    listening  = Color3.fromRGB(255, 200,  60),
    dropBg     = Color3.fromRGB( 16,  16,  26),
    notifBg    = Color3.fromRGB( 20,  20,  32),
    inputBg    = Color3.fromRGB( 16,  16,  26),
}

-- ─────────────────────────────────────────────────────────────
--  PRIMITIVE HELPERS
-- ─────────────────────────────────────────────────────────────
local function fr(parent, p)
    local f = Instance.new("Frame"); f.BorderSizePixel = 0
    for k,v in pairs(p or {}) do f[k]=v end; f.Parent=parent; return f
end
local function lb(parent, p)
    local l = Instance.new("TextLabel")
    l.BorderSizePixel=0; l.BackgroundTransparency=1
    for k,v in pairs(p or {}) do l[k]=v end; l.Parent=parent; return l
end
local function bt(parent, p, hov)
    local b = Instance.new("TextButton")
    b.BorderSizePixel=0; b.AutoButtonColor=false
    for k,v in pairs(p or {}) do b[k]=v end; b.Parent=parent
    if hov then
        local base = p and p.BackgroundColor3 or Color3.new()
        b.MouseEnter:Connect(function() tw(b,.08,{BackgroundColor3=hov}) end)
        b.MouseLeave:Connect(function() tw(b,.08,{BackgroundColor3=base}) end)
    end
    return b
end
local function bx(parent, p)
    local x = Instance.new("TextBox")
    x.BorderSizePixel=0; x.ClearTextOnFocus=false
    for k,v in pairs(p or {}) do x[k]=v end; x.Parent=parent; return x
end
local function corner(inst, r)
    local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); c.Parent=inst
end
local function stroke(inst, col, t)
    local s = Instance.new("UIStroke"); s.Color=col; s.Thickness=t or 1; s.Parent=inst; return s
end
local function drag(handle, target, conns)
    local on,ds,sp=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then on=true;ds=i.Position;sp=target.Position end
    end)
    local c1=UserInputService.InputChanged:Connect(function(i)
        if on and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            target.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    local c2=UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then on=false end
    end)
    if conns then table.insert(conns,c1);table.insert(conns,c2) end
end

-- ─────────────────────────────────────────────────────────────
--  PILL TOGGLE  (44×22 green/dark, animated knob)
-- ─────────────────────────────────────────────────────────────
local function makePill(parent, pos, initOn, C)
    local bg=fr(parent,{Size=UDim2.new(0,44,0,22),Position=pos,
        BackgroundColor3=initOn and C.green or C.sliderBg})
    corner(bg,11)
    local knob=fr(bg,{Size=UDim2.new(0,16,0,16),
        Position=initOn and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8),
        BackgroundColor3=initOn and Color3.new(1,1,1) or C.sub})
    corner(knob,8)
    local hit=Instance.new("TextButton")
    hit.Size=UDim2.new(1,0,1,0);hit.BackgroundTransparency=1
    hit.Text="";hit.BorderSizePixel=0;hit.AutoButtonColor=false;hit.Parent=bg
    local function set(on,anim)
        local kp=on and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8)
        local kc=on and Color3.new(1,1,1) or C.sub
        local bc=on and C.green or C.sliderBg
        if anim then
            tw(knob,.15,{Position=kp,BackgroundColor3=kc});tw(bg,.15,{BackgroundColor3=bc})
        else
            knob.Position=kp;knob.BackgroundColor3=kc;bg.BackgroundColor3=bc
        end
    end
    return hit,set
end

-- ─────────────────────────────────────────────────────────────
--  KEYBIND BADGE  (46×17 panel bg, shows key name)
-- ─────────────────────────────────────────────────────────────
local function makeBadge(parent, initKey, onBind, C, bRef)
    local function short(kc)
        if not kc then return "None" end
        return kc.Name
            :gsub("LeftControl","LCtrl"):gsub("RightControl","RCtrl")
            :gsub("LeftShift","LShft"):gsub("RightShift","RShft")
            :gsub("LeftAlt","LAlt"):gsub("RightAlt","RAlt"):sub(1,5)
    end
    local badge=bt(parent,{Size=UDim2.new(0,46,0,17),TextSize=9,Font=Enum.Font.GothamBold,
        BackgroundColor3=C.panel,Text=short(initKey),
        TextColor3=initKey and C.accent or C.sub})
    corner(badge,3);stroke(badge,C.border,1)
    local function refresh()
        badge.TextColor3=badge.Text~="None" and C.accent or C.sub
        badge.BackgroundColor3=C.panel
    end
    local lc=nil
    badge.MouseButton1Click:Connect(function()
        if lc then lc:Disconnect();lc=nil
            if bRef then bRef.active=false end; refresh(); return
        end
        if bRef then bRef.active=true end
        badge.Text="···";badge.TextColor3=C.listening
        badge.BackgroundColor3=Color3.fromRGB(35,28,8)
        lc=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            lc:Disconnect();lc=nil
            if bRef then bRef.active=false end
            local kc=inp.KeyCode==Enum.KeyCode.Escape and nil or inp.KeyCode
            badge.Text=short(kc);onBind(kc);refresh()
        end)
    end)
    return badge
end

-- ─────────────────────────────────────────────────────────────
--  FLOATING ESP PANEL  (same design as original)
-- ─────────────────────────────────────────────────────────────
local function makeFloatingPanel(sg, title, x, y, C, conns)
    local panel=fr(sg,{Size=UDim2.new(0,240,0,320),Position=UDim2.new(0,x,0,y),
        BackgroundColor3=C.bg,Visible=false,ClipsDescendants=true})
    corner(panel,8);stroke(panel,C.border,1)

    local hdr=fr(panel,{Size=UDim2.new(1,0,0,30),BackgroundColor3=C.panel})
    lb(hdr,{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),
        Text=title,TextSize=10,Font=Enum.Font.GothamBold,
        TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Left})
    drag(hdr,panel,conns)

    local tbar=fr(panel,{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,30),BackgroundTransparency=1})
    local desBt=bt(tbar,{Size=UDim2.new(0,100,0,20),Position=UDim2.new(1,-108,0.5,-10),
        Text="☐ Deselect All",TextSize=9,Font=Enum.Font.GothamBold,
        TextColor3=C.sub,BackgroundColor3=C.panel},C.tabOn)
    corner(desBt,4);stroke(desBt,C.border,1)

    local srch=bx(tbar,{Size=UDim2.new(1,-116,0,20),Position=UDim2.new(0,6,0.5,-10),
        Text="",PlaceholderText="🔍 search…",TextSize=9,Font=Enum.Font.Gotham,
        TextColor3=C.text,PlaceholderColor3=C.sub,BackgroundColor3=C.panel})
    corner(srch,4);stroke(srch,C.border,1)

    fr(panel,{Size=UDim2.new(1,-12,0,1),Position=UDim2.new(0,6,0,60),BackgroundColor3=C.border})

    local scrl=Instance.new("ScrollingFrame")
    scrl.Size=UDim2.new(1,-4,1,-65);scrl.Position=UDim2.new(0,2,0,64)
    scrl.BackgroundTransparency=1;scrl.BorderSizePixel=0
    scrl.ScrollBarThickness=4;scrl.ScrollBarImageColor3=C.border
    scrl.CanvasSize=UDim2.new(0,0,0,0);scrl.Parent=panel

    local ll=Instance.new("UIListLayout")
    ll.SortOrder=Enum.SortOrder.Name;ll.Padding=UDim.new(0,2);ll.Parent=scrl

    local filt=""
    srch:GetPropertyChangedSignal("Text"):Connect(function()
        filt=srch.Text
        for _,ch in ipairs(scrl:GetChildren()) do
            if ch:IsA("Frame") then
                ch.Visible=filt=="" or ch.Name:lower():find(filt:lower(),1,true)~=nil
            end
        end
    end)

    local obj={_frame=panel,_scroll=scrl}
    function obj:SetESPData(entries, colorFn, onChange)
        local function buildRow(name, entry)
            local cols=colorFn(name)
            local row=fr(scrl,{Name=name,Size=UDim2.new(1,-6,0,28),BackgroundTransparency=1,
                Visible=filt=="" or name:lower():find(filt:lower(),1,true)~=nil})
            local dot=fr(row,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,6,0.5,-4),BackgroundColor3=cols[1]})
            corner(dot,4)
            lb(row,{Size=UDim2.new(1,-70,1,0),Position=UDim2.new(0,20,0,0),
                Text=name,TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.text,
                TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
            local hit,set=makePill(row,UDim2.new(1,-48,0.5,-11),entry.enabled,C)
            hit.MouseButton1Click:Connect(function()
                entry.enabled=not entry.enabled;set(entry.enabled,true)
                if onChange then onChange() end
            end)
        end
        local function rebuild()
            for _,ch in ipairs(scrl:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
            local n=0
            for name,entry in pairs(entries) do buildRow(name,entry);n=n+1 end
            scrl.CanvasSize=UDim2.new(0,0,0,n*30+4)
        end
        desBt.MouseButton1Click:Connect(function()
            for _,e in pairs(entries) do e.enabled=false end
            if onChange then onChange() end;rebuild()
        end)
        return rebuild
    end
    return obj
end

-- ─────────────────────────────────────────────────────────────
--  DISTANCE ROW  (toggle + slider, same design as original)
-- ─────────────────────────────────────────────────────────────
local function makeDistRow(page, yPos, espData, maxVal, C, conns)
    maxVal=maxVal or 500
    local row=fr(page,{Size=UDim2.new(1,-16,0,50),Position=UDim2.new(0,8,0,yPos),BackgroundTransparency=1})
    lb(row,{Size=UDim2.new(0,70,0,20),Text="Distance:",TextSize=10,
        Font=Enum.Font.GothamBold,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Left})
    local ph,ps=makePill(row,UDim2.new(1,-44,0,-1),espData.distOn,C)
    ph.MouseButton1Click:Connect(function() espData.distOn=not espData.distOn;ps(espData.distOn,true) end)
    local vRow=fr(row,{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,26),BackgroundTransparency=1})
    local track=fr(vRow,{Size=UDim2.new(1,-52,0,6),Position=UDim2.new(0,0,0.5,-3),BackgroundColor3=C.sliderBg})
    corner(track,3);stroke(track,C.border,1)
    local fill=fr(track,{Size=UDim2.new(espData.dist/maxVal,0,1,0),BackgroundColor3=C.sliderFill})
    corner(fill,3)
    local knob=fr(track,{Size=UDim2.new(0,12,0,12),
        Position=UDim2.new(espData.dist/maxVal,-6,0.5,-6),BackgroundColor3=Color3.new(1,1,1)})
    corner(knob,6)
    local vLbl=bt(vRow,{Size=UDim2.new(0,48,0,20),Position=UDim2.new(1,-48,0,0),
        Text=tostring(espData.dist),TextSize=10,Font=Enum.Font.GothamBold,
        TextColor3=C.accent,BackgroundColor3=C.panel,TextXAlignment=Enum.TextXAlignment.Center})
    corner(vLbl,3);stroke(vLbl,C.border,1)
    local vBox=bx(vRow,{Size=UDim2.new(0,48,0,20),Position=UDim2.new(1,-48,0,0),
        Text=tostring(espData.dist),TextSize=10,Font=Enum.Font.GothamBold,
        TextColor3=C.accent,BackgroundColor3=C.panel,TextXAlignment=Enum.TextXAlignment.Center,Visible=false})
    corner(vBox,3);stroke(vBox,C.border,1)
    local function setDist(v)
        v=math.max(1,math.floor(v));espData.dist=v
        local f=math.clamp(v/maxVal,0,1)
        fill.Size=UDim2.new(f,0,1,0);knob.Position=UDim2.new(f,-6,0.5,-6)
        vLbl.Text=tostring(v);vBox.Text=tostring(v)
    end
    local dragging=false
    local sHit=bt(track,{Size=UDim2.new(1,12,0,22),Position=UDim2.new(0,-6,0.5,-11),
        BackgroundTransparency=1,Text=""})
    sHit.MouseButton1Down:Connect(function() dragging=true end)
    table.insert(conns,UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end))
    table.insert(conns,RunService.RenderStepped:Connect(function()
        if dragging then
            setDist(math.clamp((player:GetMouse().X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*maxVal)
        end
    end))
    vLbl.MouseButton1Click:Connect(function() vLbl.Visible=false;vBox.Visible=true;vBox:CaptureFocus() end)
    vBox.FocusLost:Connect(function()
        local n=tonumber(vBox.Text);if n then setDist(n) end
        vLbl.Visible=true;vBox.Visible=false
    end)
    return setDist
end

-- ─────────────────────────────────────────────────────────────
--  NOTIFICATION STACK  (bottom-right corner, auto-dismiss)
-- ─────────────────────────────────────────────────────────────
local _nHolder=nil
local function ensureHolder(sg,C)
    if _nHolder and _nHolder.Parent==sg then return end
    _nHolder=fr(sg,{Size=UDim2.new(0,260,1,0),Position=UDim2.new(1,-268,0,0),
        BackgroundTransparency=1,ZIndex=50})
    local ll=Instance.new("UIListLayout")
    ll.SortOrder=Enum.SortOrder.LayoutOrder
    ll.VerticalAlignment=Enum.VerticalAlignment.Bottom
    ll.Padding=UDim.new(0,6);ll.Parent=_nHolder
    local pad=Instance.new("UIPadding");pad.PaddingBottom=UDim.new(0,10);pad.Parent=_nHolder
end
local function spawnNotif(sg,C,title,body,dur)
    ensureHolder(sg,C);dur=math.max(.5,dur or 4)
    local card=fr(_nHolder,{Size=UDim2.new(1,0,0,58),BackgroundColor3=C.notifBg,
        ZIndex=51,LayoutOrder=math.floor(os.clock()*1000)})
    corner(card,8);stroke(card,C.border,1)
    local strip=fr(card,{Size=UDim2.new(0,3,1,-8),Position=UDim2.new(0,0,0,4),
        BackgroundColor3=C.accent,ZIndex=52})
    corner(strip,2)
    lb(card,{Size=UDim2.new(1,-20,0,17),Position=UDim2.new(0,14,0,7),
        Text=title,TextSize=11,Font=Enum.Font.GothamBold,
        TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=52})
    lb(card,{Size=UDim2.new(1,-20,0,24),Position=UDim2.new(0,14,0,26),
        Text=body,TextSize=9,Font=Enum.Font.Gotham,
        TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=52})
    local bar=fr(card,{Size=UDim2.new(1,-4,0,2),Position=UDim2.new(0,2,1,-4),
        BackgroundColor3=C.accent,ZIndex=52})
    corner(bar,1)
    task.spawn(function()
        tw(bar,dur,{Size=UDim2.new(0,0,0,2)})
        task.wait(dur)
        tw(card,.22,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)})
        task.wait(.25);pcall(function() card:Destroy() end)
    end)
end

-- ═════════════════════════════════════════════════════════════
--  CartLib.new(title, opts?)
-- ═════════════════════════════════════════════════════════════
function CartLib.new(title, opts)
    opts=opts or {}
    local C  =opts.theme or CartLib.DefaultTheme
    local W  =opts.width or 300
    local H  =opts.height or 320
    local TW =opts.tabBarWidth or 48
    local POS=opts.position or UDim2.new(0,20,0,20)

    local conns={};local bRef={active=false};local inCbs={}
    local fPanels={};local pwOpen={};local minimized,visible=false,true
    local tabs={};local tabY=4;local activeId=nil

    -- ── ScreenGui (PlayerGui → CoreGui on escape) ──────────
    local CoreGui=game:GetService("CoreGui");local GS=game:GetService("GuiService")
    local cOk=pcall(function() local t=Instance.new("ScreenGui");t.Parent=CoreGui;t:Destroy() end)
    local sg=Instance.new("ScreenGui")
    sg.Name=opts.name or "CartLib";sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset=true;sg.DisplayOrder=5;sg.Parent=player.PlayerGui
    if cOk then
        table.insert(conns,GS.MenuOpened:Connect(function() pcall(function() sg.Parent=CoreGui end) end))
        table.insert(conns,GS.MenuClosed:Connect(function() pcall(function() sg.Parent=player.PlayerGui end) end))
    end

    -- ── Main window frame ───────────────────────────────────
    local main=fr(sg,{Name="Main",Size=UDim2.new(0,W,0,H),Position=POS,
        BackgroundColor3=C.bg,ClipsDescendants=true})
    corner(main,8);stroke(main,C.border,1)

    local titleBar=fr(main,{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.panel})
    lb(titleBar,{Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,12,0,0),
        Text=title,TextSize=12,Font=Enum.Font.GothamBold,
        TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Left})
    local function mkIco(txt,xo)
        local b=bt(titleBar,{Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,xo,0.5,-11),
            Text=txt,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.sub,BackgroundColor3=C.panel})
        corner(b,4);return b
    end
    local minBtn=mkIco("─",-50);local clsBtn=mkIco("✕",-25)

    local sidebar=fr(main,{Size=UDim2.new(0,TW,1,-34),Position=UDim2.new(0,0,0,34),BackgroundColor3=C.panel})
    stroke(sidebar,C.border,1)

    local content=fr(main,{Size=UDim2.new(1,-TW,1,-34),Position=UDim2.new(0,TW,0,34),
        BackgroundTransparency=1,ClipsDescendants=true})

    drag(titleBar,main,conns)

    local function setActive(id)
        activeId=id
        for tid,info in pairs(tabs) do
            local on=tid==id;info.page.Visible=on
            tw(info.btn,.12,{BackgroundColor3=on and C.tabOn or C.panel})
            for _,ch in ipairs(info.btn:GetChildren()) do
                if ch:IsA("TextLabel") then tw(ch,.12,{TextColor3=on and C.accent or C.sub}) end
            end
        end
    end

    minBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        tw(main,.18,{Size=UDim2.new(0,W,0,minimized and 34 or H)})
        minBtn.Text=minimized and "□" or "─"
        for _,pf in ipairs(fPanels) do
            if minimized then pwOpen[pf]=pf.Visible;pf.Visible=false
            else pf.Visible=pwOpen[pf] or false end
        end
    end)
    clsBtn.MouseButton1Click:Connect(function()
        tw(main,.18,{Size=UDim2.new(0,W,0,0)})
        task.delay(.22,function()
            for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
            pcall(function() sg:Destroy() end)
        end)
    end)
    table.insert(conns,UserInputService.InputBegan:Connect(function(inp,gp)
        if gp or bRef.active then return end
        if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
        for _,cb in ipairs(inCbs) do pcall(cb,inp.KeyCode) end
    end))

    -- ═══════════════════════════════════════════════════════
    --  WINDOW OBJECT returned to caller
    -- ═══════════════════════════════════════════════════════
    local win={}

    --[[
    win:Tab(name, icon) → tab object
    ]]
    function win:Tab(name, icon)
        local by=tabY;tabY=tabY+56
        local btn=bt(sidebar,{Size=UDim2.new(1,0,0,52),Position=UDim2.new(0,0,0,by),
            Text="",BackgroundColor3=C.panel})
        lb(btn,{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,6),
            Text=icon or "",TextSize=14,Font=Enum.Font.GothamBold,
            TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Center})
        lb(btn,{Size=UDim2.new(1,0,0,13),Position=UDim2.new(0,0,0,27),
            Text=name,TextSize=8,Font=Enum.Font.Gotham,
            TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Center})

        local page=Instance.new("ScrollingFrame")
        page.Name=name.."Page";page.Size=UDim2.new(1,0,1,0)
        page.BackgroundTransparency=1;page.BorderSizePixel=0
        page.ScrollBarThickness=4;page.ScrollBarImageColor3=C.border
        page.CanvasSize=UDim2.new(0,0,0,0);page.Visible=false;page.Parent=content

        local info={btn=btn,page=page,y=8}
        tabs[name]=info
        btn.MouseButton1Click:Connect(function() setActive(name) end)
        if not activeId then setActive(name) end

        local tab={}
        local function py(a) info.y=info.y+a;page.CanvasSize=UDim2.new(0,0,0,info.y+8) end
        local function row(h) -- internal: bare horizontal strip
            local y=info.y
            local r=fr(page,{Size=UDim2.new(1,-12,0,h or 28),
                Position=UDim2.new(0,6,0,y),BackgroundTransparency=1})
            return r
        end

        --[[
        tab:Toggle(label, opts)
        opts: { default=bool, flag=str, callback=fn }
        Returns: setValue(bool, animated?)
        ]]
        function tab:Toggle(label, opts)
            opts=opts or {}
            local on=opts.default or false
            local flag=opts.flag;local cb=opts.callback or function() end
            local r=row()
            lb(r,{Size=UDim2.new(1,-54,1,0),Text=label,TextSize=11,
                Font=Enum.Font.Gotham,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})
            if flag then CartLib.Flags[flag]=on end
            local hit,set=makePill(r,UDim2.new(1,-44,0.5,-11),on,C)
            hit.MouseButton1Click:Connect(function()
                on=not on;set(on,true)
                if flag then CartLib.Flags[flag]=on end;cb(on)
            end)
            py(36)
            return function(v,anim)
                on=v;set(v,anim)
                if flag then CartLib.Flags[flag]=v end
            end
        end

        --[[
        tab:Keybind(label, opts)
        opts: { default=KeyCode, flag=str, callback=fn }
        Returns: badge TextButton
        ]]
        function tab:Keybind(label, opts)
            opts=opts or {}
            local flag=opts.flag;local cb=opts.callback or function() end
            local curKey=opts.default
            if flag then CartLib.Flags[flag]=curKey end
            local r=row()
            lb(r,{Size=UDim2.new(1,-54,1,0),Text=label,TextSize=11,
                Font=Enum.Font.Gotham,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})
            local badge=makeBadge(r,curKey,function(kc)
                curKey=kc
                if flag then CartLib.Flags[flag]=kc end;cb(kc)
            end,C,bRef)
            badge.Position=UDim2.new(1,-48,0.5,-8)
            py(36);return badge
        end

        --[[
        tab:ToggleBind(label, topts, kopts)
        Toggle + Keybind on ONE row — mirrors original CartUI rows.
        topts: { default, flag, callback }
        kopts: { default, flag, callback }
        Returns: setToggle(bool, anim?), badge
        ]]
        function tab:ToggleBind(label, topts, kopts)
            topts=topts or {};kopts=kopts or {}
            local on=topts.default or false
            local tf=topts.flag;local tc=topts.callback or function() end
            local kf=kopts.flag;local kc=kopts.callback or function() end
            local curKey=kopts.default
            if tf then CartLib.Flags[tf]=on end
            if kf then CartLib.Flags[kf]=curKey end
            local r=row()
            lb(r,{Size=UDim2.new(1,-100,1,0),Text=label,TextSize=11,
                Font=Enum.Font.Gotham,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})
            -- pill at right-94, badge at right-48
            local hit,set=makePill(r,UDim2.new(1,-94,0.5,-11),on,C)
            hit.MouseButton1Click:Connect(function()
                on=not on;set(on,true)
                if tf then CartLib.Flags[tf]=on end;tc(on)
            end)
            local badge=makeBadge(r,curKey,function(k)
                curKey=k
                if kf then CartLib.Flags[kf]=k end;kc(k)
            end,C,bRef)
            badge.Position=UDim2.new(1,-48,0.5,-8)
            py(36)
            local setToggle=function(v,anim)
                on=v;set(v,anim)
                if tf then CartLib.Flags[tf]=v end
            end
            return setToggle,badge
        end

        --[[
        tab:Slider(label, opts)
        opts: { min, max, default, step, suffix, flag, callback }
        Returns: setValue(number)
        ]]
        function tab:Slider(label, opts)
            opts=opts or {}
            local mn=opts.min or 0;local mx=opts.max or 100
            local step=opts.step or 1;local suf=opts.suffix or ""
            local flag=opts.flag;local cb=opts.callback or function() end
            local val=math.clamp(opts.default or mn,mn,mx)
            if flag then CartLib.Flags[flag]=val end

            local y=info.y
            local cont=fr(page,{Size=UDim2.new(1,-12,0,46),Position=UDim2.new(0,6,0,y),BackgroundTransparency=1})
            lb(cont,{Size=UDim2.new(1,-60,0,18),Text=label,TextSize=11,Font=Enum.Font.Gotham,
                TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})
            local vLb=lb(cont,{Size=UDim2.new(0,56,0,18),Position=UDim2.new(1,-56,0,0),
                Text=tostring(val)..suf,TextSize=11,Font=Enum.Font.GothamBold,
                TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Right})
            local track=fr(cont,{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,27),BackgroundColor3=C.sliderBg})
            corner(track,3);stroke(track,C.border,1)
            local frac=(val-mn)/math.max(mx-mn,1)
            local fill=fr(track,{Size=UDim2.new(frac,0,1,0),BackgroundColor3=C.sliderFill});corner(fill,3)
            local knob=fr(track,{Size=UDim2.new(0,14,0,14),Position=UDim2.new(frac,-7,0.5,-7),
                BackgroundColor3=Color3.new(1,1,1)});corner(knob,7)

            local function sv(v)
                local r2=math.max(mx-mn,1)
                v=math.clamp(math.floor((v-mn)/step+.5)*step+mn,mn,mx)
                val=v;local f=(v-mn)/r2
                fill.Size=UDim2.new(f,0,1,0);knob.Position=UDim2.new(f,-7,0.5,-7)
                vLb.Text=tostring(v)..suf
                if flag then CartLib.Flags[flag]=v end;cb(v)
            end
            local dragging=false
            local hitA=bt(track,{Size=UDim2.new(1,14,0,22),Position=UDim2.new(0,-7,0.5,-11),
                BackgroundTransparency=1,Text=""})
            hitA.MouseButton1Down:Connect(function() dragging=true end)
            table.insert(conns,UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
            end))
            table.insert(conns,RunService.RenderStepped:Connect(function()
                if dragging then
                    sv(mn+math.clamp((player:GetMouse().X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(mx-mn))
                end
            end))
            py(54);return sv
        end

        --[[
        tab:Button(label, callback, opts?)
        opts: { style="primary"|"default" }
        ]]
        function tab:Button(label, callback, opts)
            opts=opts or {};local primary=opts.style=="primary"
            local base=primary and C.accent or C.panel
            local hov=primary and Color3.fromRGB(105,175,255) or C.tabOn
            local y=info.y
            local b=bt(page,{Size=UDim2.new(1,-12,0,26),Position=UDim2.new(0,6,0,y),
                Text=label,TextSize=11,Font=Enum.Font.GothamBold,
                TextColor3=primary and Color3.new(1,1,1) or C.text,
                BackgroundColor3=base,TextXAlignment=Enum.TextXAlignment.Center},hov)
            corner(b,6);stroke(b,C.border,1)
            b.MouseButton1Click:Connect(function() if callback then callback() end end)
            py(34);return b
        end

        --[[
        tab:Dropdown(label, items, opts)
        opts: { default, flag, callback, maxHeight }
        Returns: { setValue(str), refresh(newItems[]) }
        ]]
        function tab:Dropdown(label, items, opts)
            opts=opts or {};local flag=opts.flag;local cb=opts.callback or function() end
            local cur=opts.default or (items[1] or "")
            local open=false;local iH=22;local maxH=opts.maxHeight or 110
            if flag then CartLib.Flags[flag]=cur end

            local y=info.y
            local cont=fr(page,{Size=UDim2.new(1,-12,0,46),Position=UDim2.new(0,6,0,y),BackgroundTransparency=1})
            lb(cont,{Size=UDim2.new(1,-6,0,18),Text=label,TextSize=11,Font=Enum.Font.Gotham,
                TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})
            local hdr=bt(cont,{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,20),
                Text="",BackgroundColor3=C.panel})
            corner(hdr,5);stroke(hdr,C.border,1)
            local cLb=lb(hdr,{Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,8,0,0),
                Text=cur,TextSize=10,Font=Enum.Font.Gotham,
                TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left})
            local arw=lb(hdr,{Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-20,0,0),
                Text="▾",TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.sub,
                TextXAlignment=Enum.TextXAlignment.Center})

            local lF=fr(sg,{Size=UDim2.new(0,0,0,0),BackgroundColor3=C.dropBg,Visible=false,ZIndex=20,ClipsDescendants=true})
            corner(lF,5);stroke(lF,C.border,1)
            local lsc=Instance.new("ScrollingFrame")
            lsc.Size=UDim2.new(1,0,1,0);lsc.BackgroundTransparency=1;lsc.BorderSizePixel=0
            lsc.ScrollBarThickness=3;lsc.ScrollBarImageColor3=C.border;lsc.ZIndex=21;lsc.Parent=lF
            local ll2=Instance.new("UIListLayout");ll2.SortOrder=Enum.SortOrder.LayoutOrder;ll2.Padding=UDim.new(0,2);ll2.Parent=lsc

            local function closeDD()
                open=false;arw.Text="▾"
                tw(lF,.1,{Size=UDim2.new(0,lF.Size.X.Offset,0,0)})
                task.delay(.12,function() lF.Visible=false end)
            end
            local function openDD()
                local ap=hdr.AbsolutePosition;local aw=hdr.AbsoluteSize.X
                local th=math.min(#items*(iH+2),maxH)
                lF.Position=UDim2.new(0,ap.X,0,ap.Y+26)
                lF.Size=UDim2.new(0,aw,0,0);lF.Visible=true
                lsc.CanvasSize=UDim2.new(0,0,0,#items*(iH+2))
                tw(lF,.1,{Size=UDim2.new(0,aw,0,th)})
                arw.Text="▴";open=true
            end
            local function buildList(list)
                for _,ch in ipairs(lsc:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
                for i,item in ipairs(list) do
                    local ib=bt(lsc,{Size=UDim2.new(1,-4,0,iH),BackgroundColor3=C.dropBg,
                        Text=item,TextSize=10,Font=Enum.Font.Gotham,
                        TextColor3=item==cur and C.accent or C.text,
                        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=22,LayoutOrder=i})
                    local pd=Instance.new("UIPadding");pd.PaddingLeft=UDim.new(0,8);pd.Parent=ib
                    ib.MouseEnter:Connect(function() if item~=cur then tw(ib,.07,{BackgroundColor3=C.tabOn}) end end)
                    ib.MouseLeave:Connect(function() if item~=cur then tw(ib,.07,{BackgroundColor3=C.dropBg}) end end)
                    ib.MouseButton1Click:Connect(function()
                        cur=item;cLb.Text=item
                        if flag then CartLib.Flags[flag]=item end;cb(item);closeDD()
                        for _,c2 in ipairs(lsc:GetChildren()) do
                            if c2:IsA("TextButton") then
                                c2.TextColor3=c2.Text==cur and C.accent or C.text
                                c2.BackgroundColor3=C.dropBg
                            end
                        end
                    end)
                end
            end
            buildList(items)
            hdr.MouseButton1Click:Connect(function() if open then closeDD() else openDD() end end)
            table.insert(conns,UserInputService.InputBegan:Connect(function(inp)
                if open and inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    local mx2,my2=inp.Position.X,inp.Position.Y
                    local lp=lF.AbsolutePosition;local ls=lF.AbsoluteSize
                    if not(mx2>=lp.X and mx2<=lp.X+ls.X and my2>=lp.Y and my2<=lp.Y+ls.Y) then closeDD() end
                end
            end))
            py(54)
            local obj={};function obj:setValue(v) cur=v;cLb.Text=v;if flag then CartLib.Flags[flag]=v end end
            function obj:refresh(nl) items=nl;buildList(nl)
                if not table.find(nl,cur) then cur=nl[1] or "";cLb.Text=cur;if flag then CartLib.Flags[flag]=cur end end
            end
            return obj
        end

        --[[  tab:Section(label)  — accent header + underline  ]]
        function tab:Section(label)
            local y=info.y
            lb(page,{Size=UDim2.new(1,-12,0,16),Position=UDim2.new(0,6,0,y),
                Text=label,TextSize=9,Font=Enum.Font.GothamBold,
                TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Left})
            fr(page,{Size=UDim2.new(1,-12,0,1),Position=UDim2.new(0,6,0,y+17),BackgroundColor3=C.border})
            py(24)
        end

        --[[  tab:Divider()  — thin rule  ]]
        function tab:Divider()
            fr(page,{Size=UDim2.new(1,-12,0,1),Position=UDim2.new(0,6,0,info.y),BackgroundColor3=C.border})
            py(9)
        end

        --[[  tab:Note(text)  — small grey label  ]]
        function tab:Note(text)
            lb(page,{Size=UDim2.new(1,-12,0,22),Position=UDim2.new(0,6,0,info.y),
                Text=text,TextSize=8,Font=Enum.Font.Gotham,TextColor3=C.sub,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
            py(26)
        end

        --[[  tab:PanelButton(label, panelObj)  ]]
        function tab:PanelButton(label, panelObj)
            local y=info.y;local pf=panelObj._frame;local openP=false
            table.insert(fPanels,pf);pwOpen[pf]=false
            local b=bt(page,{Size=UDim2.new(1,-12,0,24),Position=UDim2.new(0,6,0,y),
                Text=label.." ▸",TextSize=10,Font=Enum.Font.GothamBold,
                TextColor3=C.sub,BackgroundColor3=C.panel,TextXAlignment=Enum.TextXAlignment.Center})
            corner(b,5);stroke(b,C.border,1)
            b.MouseEnter:Connect(function() if not openP then tw(b,.08,{TextColor3=C.text}) end end)
            b.MouseLeave:Connect(function() if not openP then tw(b,.08,{TextColor3=C.sub}) end end)
            b.MouseButton1Click:Connect(function()
                openP=not openP;pf.Visible=openP;pwOpen[pf]=openP
                b.Text=label..(openP and " ▾" or " ▸")
                tw(b,.08,{TextColor3=openP and C.accent or C.sub})
            end)
            py(32)
        end

        --[[  tab:DistanceRow(espData, max)  ]]
        function tab:DistanceRow(espData, max)
            makeDistRow(page,info.y,espData,max or 500,C,conns);py(58)
        end

        return tab
    end

    function win:FloatingPanel(title,x,y) return makeFloatingPanel(sg,title,x,y,C,conns) end
    function win:Notify(title,body,dur)   spawnNotif(sg,C,title,body,dur) end
    function win:OnInput(cb)              table.insert(inCbs,cb) end
    function win:SetVisible(v)
        visible=v;main.Visible=v
        for _,pf in ipairs(fPanels) do
            if v then pf.Visible=pwOpen[pf] or false
            else pwOpen[pf]=pf.Visible;pf.Visible=false end
        end
    end
    function win:IsVisible() return visible end
    function win:Toggle()    self:SetVisible(not visible) end
    function win:ChangeAccent(col) C.accent=col;C.sliderFill=col end
    function win:SaveConfig(name)
        pcall(function()
            if not isfolder("CartLib") then makefolder("CartLib") end
            local t={}
            for k,v in pairs(CartLib.Flags) do
                if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then t[k]=v
                elseif typeof(v)=="EnumItem" then t[k]=tostring(v) end
            end
            writefile("CartLib/"..name..".json",HttpService:JSONEncode(t))
        end)
    end
    function win:LoadConfig(name)
        pcall(function()
            local raw=readfile("CartLib/"..name..".json")
            for k,v in pairs(HttpService:JSONDecode(raw)) do CartLib.Flags[k]=v end
        end)
    end
    function win:Destroy()
        for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns={};pcall(function() sg:Destroy() end)
    end

    return win
end

return CartLib
