local a={cache={}::any}do do local function __modImpl()
local b={}
b.__index=b

local function dispose(c,d)
if c==nil then return end
local e=typeof(c)
if d and type(c)=="table"and type(c[d])=="function"then
c[d](c)
elseif e=="RBXScriptConnection"then
c:Disconnect()
elseif e=="Instance"then
c:Destroy()
elseif type(c)=="function"then
c()
elseif type(c)=="thread"then
pcall(task.cancel,c)
elseif type(c)=="table"then
if type(c.Destroy)=="function"then c:Destroy()
elseif type(c.Disconnect)=="function"then c:Disconnect()
elseif type(c.Cancel)=="function"then c:Cancel()end
end
end

function b.new()
return setmetatable({_items={},_destroyed=false},b)
end

function b.Add(c,d,e)
if d==nil then return nil end
if c._destroyed then
dispose(d,e)
return d
end
table.insert(c._items,{Resource=d,Method=e})
return d
end

function b.Remove(c,d,e)
for f=#c._items,1,-1 do
local g=c._items[f]
if g.Resource==d then
table.remove(c._items,f)
if e then dispose(g.Resource,g.Method)end
return true
end
end
return false
end

function b.Clean(c)
if c._destroyed then return end
for d=#c._items,1,-1 do
local e=c._items[d]
local f,g=pcall(dispose,e.Resource,e.Method)
if not f then warn("[Harkening] Error durante cleanup: "..tostring(g))end
c._items[d]=nil
end
end

function b.Destroy(c)
if c._destroyed then return end
c:Clean()
c._destroyed=true
end

b.Dispose=dispose
return b end function a.a():typeof(__modImpl())local b=a.cache.a if not b then b={c=__modImpl()}a.cache.a=b end return b.c end end do local function __modImpl()


local b={}

local function clone(c)
if type(c)~="table"then return c end
local d={}
for e,f in pairs(c)do d[e]=clone(f)end
return d
end

function b.Merge(c,d)
assert(type(c)=="table","Defaults.Merge: defaults debe ser una tabla")
if d~=nil then assert(type(d)=="table","Defaults.Merge: options debe ser una tabla")end
d=d or{}
local e={}
for f,g in pairs(c)do
local h=d[f]
if type(g)=="table"and(h==nil or type(h)=="table")then
e[f]=b.Merge(g,h)
elseif h~=nil then

e[f]=clone(h)
else
e[f]=clone(g)
end
end

for f,g in pairs(d)do
if c[f]==nil then e[f]=clone(g)end
end
return e
end

function b.Clone(c)
return clone(c)
end

b.Framework={
Name="Harkening UI",
Parent=nil,
ResetOnSpawn=false,
DisplayOrder=50,
Theme={},
Animation=true,
Debug=false,
Watermark={
Enabled=true,Title="HARKENING UI",ShowLogo=true,ShowGameName=true,
ShowGameIcon=true,ShowFPS=true,ShowClock=false,ShowStatus=true,
Position="TopRight",Style="Compact",Status="RUNNING",BackgroundTransparency=0.12,Width=300,
},
}

b.Window={
Id=nil,
Title="Harkening UI",
Description="",
Icon=nil,
Size=UDim2.fromOffset(780,520),
Position=UDim2.fromScale(0.5,0.5),
MinSize=Vector2.new(420,300),
MaxSize=Vector2.new(1400,960),
AdaptiveSize=true,
Draggable=true,
Resizable=true,
Minimizable=true,
Maximizable=true,
Closable=true,
CloseBehavior="Hide",
Animation=true,
SidebarWidth=168,
}

b.Theme={

Background=Color3.fromRGB(12,14,19),
Surface=Color3.fromRGB(17,20,27),
SurfaceRaised=Color3.fromRGB(24,29,39),
SurfaceHover=Color3.fromRGB(31,38,51),
SurfaceInset=Color3.fromRGB(9,11,16),
SurfaceSelected=Color3.fromRGB(28,39,64),
Border=Color3.fromRGB(47,56,73),
BorderSubtle=Color3.fromRGB(34,41,54),
BorderFocus=Color3.fromRGB(190,108,255),
Text=Color3.fromRGB(241,244,250),
MutedText=Color3.fromRGB(145,156,176),
Accent=Color3.fromRGB(190,108,255),
AccentSecondary=Color3.fromRGB(255,91,193),
AccentSoft=Color3.fromRGB(43,28,61),
AccentText=Color3.fromRGB(250,252,255),
Danger=Color3.fromRGB(238,88,108),
Warning=Color3.fromRGB(238,180,79),
Success=Color3.fromRGB(74,195,139),
Info=Color3.fromRGB(91,169,247),
Disabled=Color3.fromRGB(88,97,113),
Shadow=Color3.fromRGB(0,0,0),
CornerRadius=11,
}

return b end function a.b():typeof(__modImpl())local b=a.cache.b if not b then b={c=__modImpl()}a.cache.b=b end return b.c end end do local function __modImpl()

local b={}

function b.Options(c,d)
if c==nil then return{}end
assert(type(c)=="table",(d or"options").." debe ser una tabla")
return c
end

function b.String(c,d,e,f)
if c==nil then return e end
assert(type(c)=="string",(d or"value").." debe ser una cadena")
assert(f or c~="",(d or"value").." no puede estar vacía")
return c
end

function b.Number(c,d,e,f,g)
if c==nil then c=e end
assert(type(c)=="number"and c==c and c>-math.huge and c<math.huge,
(d or"value").." debe ser un número finito")
if f~=nil then assert(c>=f,(d or"value").." debe ser >= "..tostring(f))end
if g~=nil then assert(c<=g,(d or"value").." debe ser <= "..tostring(g))end
return c
end

function b.Callback(c,d)
if c==nil then return nil end
assert(type(c)=="function",(d or"Callback").." debe ser una función")
return c
end

function b.Range(c,d,e,f)
c=b.Number(c,"Min",e)
d=b.Number(d,"Max",f)
assert(d>c,"Max debe ser mayor que Min")
return c,d
end

function b.Step(c,d)
c=b.Number(c,"Step",d or 1)
assert(c>0,"Step debe ser mayor que cero")
return c
end

function b.EnumItem(c,d,e,f)
if c==nil then return e end
assert(typeof(c)=="EnumItem"and c.EnumType==d,
(f or"value").." debe ser un valor de "..tostring(d))
return c
end

return b end function a.c():typeof(__modImpl())local b=a.cache.c if not b then b={c=__modImpl()}a.cache.c=b end return b.c end end do local function __modImpl()

local b={}

function b.Create(c,d,e)
local f=Instance.new(c)
for g,h in pairs(d or{})do
local i,j=pcall(function()f[g]=h end)
if not i then
f:Destroy()
error(("No se pudo asignar %s.%s: %s"):format(c,tostring(g),tostring(j)),2)
end
end
if e then f.Parent=e end
return f
end

function b.Corner(c,d)
return b.Create("UICorner",{CornerRadius=UDim.new(0,d or 8)},c)
end

function b.Stroke(c,d,e,f)
return b.Create("UIStroke",{
Color=d or Color3.fromRGB(48,53,64),
Transparency=e or 0,
Thickness=f or 1,
},c)
end

function b.Padding(c,d,e,f,g)
return b.Create("UIPadding",{
PaddingLeft=UDim.new(0,d or 0),PaddingRight=UDim.new(0,e or 0),
PaddingTop=UDim.new(0,f or 0),PaddingBottom=UDim.new(0,g or 0),
},c)
end

function b.Label(c,d,e,f,g,h,i,j)
return b.Create("TextLabel",{
Name=d or"Label",BackgroundTransparency=1,
Size=f or UDim2.new(1,0,0,20),Position=g or UDim2.new(),
Font=j and Enum.Font.GothamSemibold or Enum.Font.Gotham,
Text=e or"",TextColor3=h or Color3.new(1,1,1),
TextSize=i or 14,TextWrapped=true,
TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
RichText=false,
},c)
end

return b end function a.d():typeof(__modImpl())local b=a.cache.d if not b then b={c=__modImpl()}a.cache.d=b end return b.c end end do local function __modImpl()


local b={}
b.__index=b

function b.new(c)
return setmetatable({Options=c or{}},b)
end

function b.GetService(c,d)
assert(type(d)=="string"and d~="","GetService necesita un nombre de servicio")
return game:GetService(d)
end

function b.GetPlayer(c)
local d=c:GetService"RunService"
if not d:IsClient()then
return nil,"Harkening UI debe inicializarse desde un LocalScript en el cliente."
end
local e=c:GetService"Players"
local f=e.LocalPlayer
if not f then return nil,"Players.LocalPlayer aún no está disponible."end
return f
end

function b.ResolveParent(c)


local d,e=c:GetPlayer()
assert(d,e)

local f=c.Options.Parent
if f~=nil then
assert(typeof(f)=="Instance","Parent debe ser una Instance válida para ScreenGui")
return f
end

local g=d:FindFirstChildOfClass"PlayerGui"or d:WaitForChild"PlayerGui"
assert(g and g:IsA"PlayerGui","No se pudo resolver PlayerGui")
return g
end

function b.GetServices(c)
return{
Players=c:GetService"Players",
RunService=c:GetService"RunService",
TweenService=c:GetService"TweenService",
UserInputService=c:GetService"UserInputService",
Workspace=c:GetService"Workspace",
MarketplaceService=c:GetService"MarketplaceService",
MarketplaceService=c:GetService"MarketplaceService",
}
end

return b end function a.e():typeof(__modImpl())local b=a.cache.e if not b then b={c=__modImpl()}a.cache.e=b end return b.c end end do local function __modImpl()

local b=a.b()
local c={}
c.__index=c

function c.new(d)
return setmetatable({_theme=b.Merge(b.Theme,d),_listeners={}},c)
end

function c.Get(d,e)
local f=d._theme
for g in string.gmatch(tostring(e),"[^%.]+")do
if type(f)~="table"then return nil end
f=f[g]
end
return f
end

function c.GetAll(d)
return b.Clone(d._theme)
end

function c.SetTheme(d,e)
assert(type(e)=="table","SetTheme espera una tabla")
d._theme=b.Merge(d._theme,e)
for f in pairs(d._listeners)do
task.spawn(f,d:GetAll())
end
end

function c.Subscribe(d,e)
assert(type(e)=="function","callback debe ser una función")
d._listeners[e]=true
local f=false
return{
Disconnect=function()
if f then return end
f=true
d._listeners[e]=nil
end,
}
end

function c.Destroy(d)
table.clear(d._listeners)
end

return c end function a.f():typeof(__modImpl())local b=a.cache.f if not b then b={c=__modImpl()}a.cache.f=b end return b.c end end do local function __modImpl()

local b={}
b.__index=b

function b.new(c,d)
assert(d,"TweenManager necesita TweenService")
return setmetatable({Enabled=c~=false,_active={},_destroyed=false,_service=d},b)
end

function b.Cancel(c,d)
local e=c._active[d]
if not e then return end
e.Generation+=1
if e.Connection then e.Connection:Disconnect();e.Connection=nil end
if e.Tween then e.Tween:Cancel();e.Tween=nil end
if c._active[d]==e then c._active[d]=nil end
end

function b.To(c,d,e,f)
assert(typeof(d)=="Instance","TweenManager:To espera una Instance")
assert(type(e)=="table","properties debe ser una tabla")
f=f or{}
c:Cancel(d)
if c._destroyed then return nil end
if not c.Enabled or f.Enabled==false then
for g,h in pairs(e)do d[g]=h end
return nil
end
local g=TweenInfo.new(
math.max(0,f.Time or 0.18),
f.EasingStyle or Enum.EasingStyle.Quad,
f.EasingDirection or Enum.EasingDirection.Out,
f.RepeatCount or 0,
f.Reverses==true,
f.DelayTime or 0
)
local h=c._service:Create(d,g,e)
local i=c._active[d]or{Generation=0}
i.Generation+=1
i.Tween=h
i.Connection=nil
c._active[d]=i
i.Connection=h.Completed:Connect(function()
if c._active[d]==i and i.Tween==h then
if i.Connection then i.Connection:Disconnect();i.Connection=nil end
i.Tween=nil
c._active[d]=nil
end
end)
h:Play()
return h
end

function b.Sequence(c,d,e,f)
assert(typeof(d)=="Instance","Sequence espera una Instance")
assert(type(e)=="table","steps debe ser una tabla")
f=f or{}
c:Cancel(d)
local g=c
local h={Index=0,Cancelled=false,_generation=0,_connection=nil,_tween=nil}
local function cancelCurrent()
if h._connection then h._connection:Disconnect();h._connection=nil end
if h._tween then h._tween:Cancel();h._tween=nil end
end
function h.Cancel(i)
if i.Cancelled then return end
i.Cancelled=true
i._generation+=1
cancelCurrent()
end
function h.Play(i)
i:Cancel()
i.Cancelled=false
i.Index=0
i._generation+=1
local j=i._generation
cancelCurrent()
if not g.Enabled or f.Enabled==false then
for k,l in ipairs(e)do
i.Index=k
for m,n in pairs(l.Properties or{})do d[m]=n end
end
return i
end
local function playNext()
if i.Cancelled or i._generation~=j then return end
i.Index+=1
local k=e[i.Index]
if not k then return end
local l=g:To(d,k.Properties or{},{
Time=k.Time or f.Time or 0.18,
EasingStyle=k.EasingStyle or f.EasingStyle,
EasingDirection=k.EasingDirection or f.EasingDirection,
Enabled=k.Enabled==nil and f.Enabled or k.Enabled,
})
if not l then playNext();return end
i._tween=l
i._connection=l.Completed:Connect(function(m)
if i._connection then i._connection:Disconnect();i._connection=nil end
i._tween=nil
if m==Enum.PlaybackState.Completed then playNext()end
end)
end
playNext()
return i
end
return h
end

function b.Destroy(c)
if c._destroyed then return end
c._destroyed=true
local d={}
for e in pairs(c._active)do table.insert(d,e)end
for e,f in ipairs(d)do c:Cancel(f)end
table.clear(c._active)
end

return b end function a.g():typeof(__modImpl())local b=a.cache.g if not b then b={c=__modImpl()}a.cache.g=b end return b.c end end do local function __modImpl()

local b={}
b.__index=b

function b.new(c,d)
assert(d,"InputManager necesita UserInputService")
local e=setmetatable({_drag=nil,_destroyed=false,_cleanup=c,_service=d},b)
e._cleanup:Add(d.InputChanged:Connect(function(f)
local g=e._drag
if not g then return end
local h=f.UserInputType
if(g.PointerType==Enum.UserInputType.MouseButton1 and h==Enum.UserInputType.MouseMovement)
or(g.PointerType==Enum.UserInputType.Touch and h==Enum.UserInputType.Touch)then
g.OnMove(f.Position)
end
end))
e._cleanup:Add(d.InputEnded:Connect(function(f)
local g=e._drag
if g and f.UserInputType==g.PointerType then
e._drag=nil
if g.OnEnd then g.OnEnd()end
end
end))
return e
end

function b.BeginDrag(c,d,e,f,g,h)
if c._destroyed or not d then return false end
local i=d.UserInputType
if i~=Enum.UserInputType.MouseButton1 and i~=Enum.UserInputType.Touch then return false end
c:EndDrag()
c._drag={PointerType=i,OnMove=e,OnEnd=f,Owner=g,Scope=h}
return true
end

function b.EndDrag(c)
if not c._drag then return end
local d=c._drag
c._drag=nil
if d.OnEnd then d.OnEnd()end
end

function b.CancelOwner(c,d)
if c._drag and c._drag.Owner==d then c:EndDrag()end
end

function b.CancelScope(c,d)
if d~=nil and c._drag and c._drag.Scope==d then c:EndDrag()end
end

function b.Destroy(c)
if c._destroyed then return end
c:EndDrag()
c._destroyed=true
end

return b end function a.h():typeof(__modImpl())local b=a.cache.h if not b then b={c=__modImpl()}a.cache.h=b end return b.c end end do local function __modImpl()

local b=a.a()
local c={}
c.__index=c

function c.Initialize(d,e,f)
d.Context=e
d.Frame=f
d.Enabled=true
d.Visible=true
d._cleanup=b.new()
d._destroyed=false
return d
end

function c.Connect(d,e,f)
return d._cleanup:Add(e:Connect(f))
end

function c.FocusWindow(d)
local e=d.Context and d.Context.Window
if e and not e._destroyed then e:Focus()end
end

function c.SetVisible(d,e)
if d._destroyed then return end
d.Visible=e==true
if not d.Visible and d.Context and d.Context.Input then d.Context.Input:CancelOwner(d)end
if d.Frame and d.Frame.Parent then d.Frame.Visible=d.Visible end
end

function c.SetEnabled(d,e)
if d._destroyed then return end
d.Enabled=e==true
if d.Frame and d.Frame.Parent then
d.Frame.Active=d.Enabled
d.Frame.Selectable=d.Enabled
end
end

function c.SetText(d,e)
assert(type(e)=="string","SetText espera una cadena")
local f=d.TextObject or d.TitleObject
assert(f and f:IsA"TextLabel","Este componente no expone SetText")
f.Text=e
end

function c.Destroy(d)
if d._destroyed then return end
d._destroyed=true
if d.Context and d.Context.Input then d.Context.Input:CancelOwner(d)end
if d._children then
for e=#d._children,1,-1 do
local f=d._children[e]
if f and type(f.Destroy)=="function"then pcall(f.Destroy,f)end
end
table.clear(d._children)
end
if d.Frame and d.Context and d.Context.Tweens and d.Context.Tweens.Cancel then
d.Context.Tweens:Cancel(d.Frame)
for e,f in ipairs(d.Frame:GetDescendants())do d.Context.Tweens:Cancel(f)end
end
d._cleanup:Destroy()
if d.Context and d.Context.Lifecycle then d.Context.Lifecycle:Remove(d)end
if d.Frame and d.Frame.Parent then d.Frame:Destroy()end
d.Frame=nil
if d._onDestroy then
local e=d._onDestroy;d._onDestroy=nil
local f,g=pcall(e,d)
if not f then warn("[Harkening] Error en OnDestroy: "..tostring(g))end
end
end

return c end function a.i():typeof(__modImpl())local b=a.cache.i if not b then b={c=__modImpl()}a.cache.i=b end return b.c end end do local function __modImpl()



return{
["icono-cuenta"]="rbxassetid://112218804079816",
["icono-dropdown-list"]="rbxassetid://92670828096691",
["icono-cursor-fill"]="rbxassetid://92670828096691",
["icono-lock-password-fill"]="rbxassetid://100676914830547",
["icono-lock-2-fill"]="rbxassetid://70534796161944",
["icono-close"]="rbxassetid://9886659671",
["icono-minimize"]="rbxassetid://9886659276",
["icono-maximize"]="rbxassetid://9886659406",
["icono-restore"]="rbxassetid://9886659001",
["icono-shadow"]="rbxassetid://6015897843",
["icono-chevron"]="rbxassetid://16851841101",

close="rbxassetid://9886659671",
minimize="rbxassetid://9886659276",
maximize="rbxassetid://9886659406",
restore="rbxassetid://9886659001",
chevron="rbxassetid://16851841101",
["chevron-down"]="rbxassetid://16851841101",
lock="rbxassetid://70534796161944",
}end function a.j():typeof(__modImpl())local b=a.cache.j if not b then b={c=__modImpl()}a.cache.j=b end return b.c end end do local function __modImpl()



local b=a.d()
local c=a.j()

local d={}

local e={
home="⌂",house="⌂",general="◈",grid="▦",catalog="▦",inventory="▤",
layers="▱",layout="▦",panel="▤",settings="⚙",gear="⚙",wrench="⌁",
search="⌕",filter="▽",sort="⇅",list="☷",menu="☰",sidebar="▥",chevron="⌄",["chevron-down"]="⌄",
["chevron-up"]="⌃",["chevron-right"]="›",["chevron-left"]="‹",arrow="→",
["arrow-left"]="←",["arrow-right"]="→",close="×",x="×",minimize="−",
maximize="□",restore="❐",resize="⤡",plus="+",minus="−",check="✓",
copy="▢",edit="✎",trash="⌫",refresh="↻",heart="♥",favorite="♥",star="★",
lock="▣",unlock="▢",shield="⬡",sword="⚔",weapon="⚔",coin="●",coins="●",
gem="◆",diamond="◇",pet="♥",paw="🐾",box="▣",package="▣",item="◆",potion="⚗",flask="⚗",more="•••",
book="▤",food="◉",car="▰",key="⚿",backpack="▤",equip="✓",equipped="✓",favoriteon="♥",new="✦",premium="♛",
info="i",warning="!",alert="!",success="✓",error="×",terminal="›_",
code="</>",bell="♢",clock="◷",gamepad="⌘",play="▶",pause="Ⅱ",stop="■",
download="↓",upload="↑",link="↗",folder="▰",file="▤",document="▤",tag="◇",
hash="#",sliders="☷",zap="ϟ",lightning="ϟ",fire="♨",crown="♛",trophy="♜",
medal="●",calendar="▦",mail="✉",message="▱",help="?",question="?",eye="◉",
["eye-off"]="⊘",power="⏻",server="▤",database="▦",activity="⌁",globe="◎",
wifi="⌁",image="▧",palette="◒",clipboard="▤",bookmark="▯",flag="⚑",volume="◖",
map="⌖",["map-pin"]="⌖",sun="☼",moon="☾",sparkles="✦",chart="▥",
["bar-chart"]="▥",["chart-line"]="⌁",user="●",users="●",profile="●",
}

local function cleanName(f)
return string.lower(tostring(f)):gsub("[%s_]+","-")
end

local function assetString(f)
if type(f)=="number"then
if f<=0 or f~=f or f==math.huge then return nil end
return"rbxassetid://"..tostring(math.floor(f))
end
if type(f)~="string"or f==""then return nil end
if f:match"^%d+$"then return"rbxassetid://"..f end
if f:match"^rbxassetid://%d+$"or f:match"^rbxthumb://"or f:match"^rbxasset://"or f:match"^https?://"then
return f
end
return nil
end

function d.Resolve(f,g)
local h,i,j
if type(f)=="table"then
h=f.Color or f.TextColor3
i=f.ImageColor3 or f.Tint
j=f.Name or f.Key
f=f.Asset or f.Image or f.Id or f.Icon or j
end
if f==nil or f==false or f==""then
if g==false then return nil end
f=g or"item"
end
local k=type(f)=="string"and c[f]
local l=k or assetString(f)
if l then return{Kind="Image",Value=l,Color=h or i}end
local m=cleanName(j or f)
if c[m]then return{Kind="Image",Value=c[m],Color=h or i}end
local n=e[m]
if not n and type(f)=="string"and#f<=4 and not f:match"^[%w%-_]+$"then n=f end
if not n and g~=false then n=e[cleanName(g or"item")]or"◆"end
if not n then return nil end
return{Kind="Glyph",Value=n,Color=h}
end

function d.Create(f,g,h)
h=h or{}
local i=d.Resolve(g,h.Fallback)
if not i then return nil end
local j=h.Size or UDim2.fromOffset(18,18)
local k=h.Color or i.Color or Color3.fromRGB(210,220,238)
local l={
Name=h.Name or"Icon",
BackgroundTransparency=h.BackgroundTransparency==nil and 1 or h.BackgroundTransparency,
BackgroundColor3=h.BackgroundColor3 or Color3.new(1,1,1),
Size=j,
Position=h.Position or UDim2.new(),
AnchorPoint=h.AnchorPoint or Vector2.new(0,0),
ZIndex=h.ZIndex,
}
if i.Kind=="Image"then
l.Image=i.Value
l.ImageColor3=h.Color or i.Color or Color3.new(1,1,1)
l.ImageTransparency=h.ImageTransparency or 0
l.ScaleType=h.ScaleType or Enum.ScaleType.Fit
return b.Create("ImageLabel",l,f)
end
l.Font=h.Font or Enum.Font.GothamBold
l.Text=i.Value
l.TextColor3=k
l.TextSize=h.TextSize or math.max(10,math.floor(math.min(j.X.Offset,j.Y.Offset)*0.82))
l.TextXAlignment=h.TextXAlignment or Enum.TextXAlignment.Center
l.TextYAlignment=h.TextYAlignment or Enum.TextYAlignment.Center
l.TextWrapped=false
l.RichText=false
return b.Create("TextLabel",l,f)
end

function d.Glyph(f,g)
local h=d.Resolve(f,g)
return h and h.Kind=="Glyph"and h.Value or nil
end

function d.DefaultFor(f)
local g=cleanName(f or"")
if g:find("setting",1,true)or g:find("config",1,true)then return"settings"end
if g:find("invent",1,true)or g:find("item",1,true)then return"inventory"end
if g:find("catalog",1,true)or g:find("shop",1,true)then return"catalog"end
if g:find("stat",1,true)or g:find("metric",1,true)then return"chart"end
if g:find("log",1,true)or g:find("console",1,true)then return"terminal"end
if g:find("security",1,true)or g:find("protect",1,true)then return"shield"end
if g:find("general",1,true)or g:find("home",1,true)then return"home"end
return"layers"
end

return d end function a.k():typeof(__modImpl())local b=a.cache.k if not b then b={c=__modImpl()}a.cache.k=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.k()
local e=a.c()
local f={}
f.__index=f
setmetatable(f,{__index=b})

function f.new(g,h,i)
i=e.Options(i,"Button options")
local j=g.Theme
local k=e.String(i.Title,"Title","Button",true)
local l=e.String(i.Description,"Description","",true)
local m=e.Callback(i.Callback)
local n=i.Variant or"Secondary"
local o={Primary=j:Get"Accent",Secondary=j:Get"SurfaceRaised",Destructive=j:Get"Danger",Success=j:Get"Success"}
local p=o[n]or j:Get"SurfaceRaised"
local q=i.Height or(l~=""and 62 or(i.IconOnly and 40 or 42))
local r=c.Create("Frame",{
Name=i.Name or"Button",BackgroundColor3=p,BorderSizePixel=0,
Size=UDim2.new(1,0,0,i.Height or q),
},h)
c.Corner(r,j:Get"CornerRadius")
local s=c.Stroke(r,n=="Primary"and j:Get"Accent"or j:Get"BorderSubtle",n=="Primary"and 0.25 or 0.34,1)
local t=c.Create("TextButton",{
Name="Action",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
Text="",AutoButtonColor=false,Active=i.Enabled~=false,Selectable=i.Enabled~=false,
},r)
local u=i.IconPosition=="Right"
local v=i.Icon and not u and 43 or 12
local w=i.Icon and u and 42 or 12
local x
if i.Icon then
local y=i.IconSize or 18
local z=c.Create("Frame",{Name="IconHolder",AnchorPoint=Vector2.new(u and 1 or 0,0.5),
Position=u and UDim2.new(1,-10,0.5,0)or UDim2.new(0,9,0.5,0),
Size=UDim2.fromOffset(y+8,y+8),BackgroundColor3=n=="Primary"and j:Get"AccentText"or j:Get"AccentSoft",
BackgroundTransparency=n=="Primary"and 0.72 or 0.06,BorderSizePixel=0},r)
c.Corner(z,7)
x=d.Create(z,i.Icon,{Name="Icon",Size=UDim2.fromOffset(y,y),
Position=UDim2.new(0.5,-y/2,0.5,-y/2),
Color=(n=="Primary"or n=="Destructive"or n=="Success")and j:Get"AccentText"or j:Get"Accent",
Fallback="sparkles",TextSize=y,ZIndex=r.ZIndex+1})
end
local y=c.Label(r,"Title",k,
UDim2.new(1,-(v+w+4),0,l~=""and 22 or 24),UDim2.new(0,v,0,l~=""and 6 or 0),
(n=="Primary"or n=="Destructive"or n=="Success")and j:Get"AccentText"or j:Get"Text",13,true)
y.TextTruncate=Enum.TextTruncate.AtEnd
if i.IconOnly then y.Visible=false;if x and x.Parent then x.Parent.AnchorPoint=Vector2.new(0.5,0.5);x.Parent.Position=UDim2.fromScale(0.5,0.5)end end
local z
if l~=""then
z=c.Label(r,"Description",l,
UDim2.new(1,-(v+w+4),0,20),UDim2.new(0,v,0,32),j:Get"MutedText",10,false)
end
local A=setmetatable({},f)
b.Initialize(A,g,r)
A.TextObject=y
A.DescriptionObject=z
A._button=t
A._callback=m
A._originalColor=r.BackgroundColor3
A._stroke=s
A._variant=n;A._loading=i.Loading==true;A._originalTitle=k
A.Enabled=i.Enabled~=false
t.Active=A.Enabled
t.Selectable=A.Enabled
A:Connect(t.MouseEnter,function()
if A.Enabled then
local B=n=="Primary"and A._originalColor:Lerp(j:Get"Text",0.08)or j:Get"SurfaceHover"
g.Tweens:To(r,{BackgroundColor3=B},{Time=0.12})
g.Tweens:To(s,{Color=j:Get"Accent",Transparency=0.16},{Time=0.12})
end
end)
A:Connect(t.MouseLeave,function()
if A.Enabled then
g.Tweens:To(r,{BackgroundColor3=A._originalColor},{Time=0.12})
g.Tweens:To(s,{Color=n=="Primary"and j:Get"Accent"or j:Get"BorderSubtle",Transparency=n=="Primary"and 0.25 or 0.34},{Time=0.12})
end
end)
A:Connect(t.Activated,function()
if not A.Enabled or A._loading or A._destroyed then return end
A:FocusWindow()
g.Tweens:To(r,{BackgroundColor3=n=="Primary"and j:Get"AccentSecondary"or j:Get"AccentSoft"},{Time=0.07})
task.delay(0.09,function()
if not A._destroyed and A.Enabled and r.Parent then
g.Tweens:To(r,{BackgroundColor3=A._originalColor},{Time=0.12})
end
end)
if A._callback then task.spawn(A._callback,A)end
end)
if A._loading then A:SetLoading(true)end
return A
end

function f.SetText(g,h)
if g._destroyed then return end
g.TextObject.Text=e.String(h,"text",nil,true)
end

function f.SetDescription(g,h)
if g._destroyed then return end
assert(type(h)=="string","text debe ser una cadena")
if not g.DescriptionObject then
g.DescriptionObject=c.Label(g.Frame,"Description",h,UDim2.new(1,-58,0,20),UDim2.new(0,43,0,32),g.Context.Theme:Get"MutedText",10)
g.Frame.Size=UDim2.new(1,0,0,62)
else g.DescriptionObject.Text=h end
end

function f.SetEnabled(g,h)
b.SetEnabled(g,h)
g._button.Active=g.Enabled
g._button.Selectable=g.Enabled
g._button.TextTransparency=g.Enabled and 0 or 0.35
g.Frame.BackgroundTransparency=g.Enabled and 0 or 0.35
if g._stroke then g._stroke.Transparency=g.Enabled and 0.34 or 0.72 end
end

function f.SetLoading(g,h,i)
if g._destroyed then return end
g._loading=h==true
g._button.Active=g.Enabled and not g._loading
g._button.Selectable=g.Enabled and not g._loading
g.TextObject.Text=g._loading and tostring(i or"Loading…")or g._originalTitle
g.Frame.BackgroundTransparency=(not g.Enabled or g._loading)and 0.25 or 0
end
function f.IsLoading(g)return g._loading end
function f.SetVariant(g,h)
if g._destroyed then return end
local i=g.Context.Theme
local j={Primary=i:Get"Accent",Secondary=i:Get"SurfaceRaised",Destructive=i:Get"Danger",Success=i:Get"Success"}
g._variant=h;g._originalColor=j[h]or i:Get"SurfaceRaised";g.Frame.BackgroundColor3=g._originalColor
if g._stroke then g._stroke.Color=h=="Primary"and i:Get"Accent"or i:Get"BorderSubtle"end
g.TextObject.TextColor3=(h=="Primary"or h=="Destructive"or h=="Success")and i:Get"AccentText"or i:Get"Text"
end

return f end function a.l():typeof(__modImpl())local b=a.cache.l if not b then b={c=__modImpl()}a.cache.l=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.c()
local e={};e.__index=e;setmetatable(e,{__index=b})
function e.new(f,g,h)
h=d.Options(h,"Checkbox options");local i=f.Theme
local j=h.Value;if j==nil then j=h.Default end;if j==nil then j=false end
assert(type(j)=="boolean","Checkbox.Value debe ser booleano")
local k=d.Callback(h.Callback)
local l=h.Description and 58 or 38
local m=c.Create("Frame",{Name=h.Name or"Checkbox",BackgroundColor3=i:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,h.Height or l)},g);c.Corner(m,i:Get"CornerRadius")
local n=c.Create("TextButton",{Name="Action",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},m)
local o=c.Create("Frame",{Name="Box",BackgroundColor3=i:Get"Background",BorderSizePixel=0,
Position=UDim2.new(0,10,0.5,-8),Size=UDim2.fromOffset(16,16)},m)
c.Corner(o,4);local p=c.Stroke(o,i:Get"Border",0,1)
local q=c.Label(o,"Check","✓",UDim2.fromScale(1,1),UDim2.new(),i:Get"AccentText",12,true)
q.TextXAlignment=Enum.TextXAlignment.Center;q.Visible=j
local r=c.Label(m,"Title",tostring(h.Title or"Checkbox"),UDim2.new(1,-40,0,20),UDim2.new(0,35,0,h.Description and 5 or 0),i:Get"Text",12,true)
if h.Description then c.Label(m,"Description",tostring(h.Description),UDim2.new(1,-42,0,20),UDim2.new(0,35,0,28),i:Get"MutedText",10)end
local s=setmetatable({},e);b.Initialize(s,f,m);s.TextObject=r;s._value=j;s._callback=k;s._mark=q;s._box=o;s._outline=p
local function render(t)
local u=s._value and i:Get"Accent"or i:Get"Background"
if t then f.Tweens:To(o,{BackgroundColor3=u},{Time=0.12})else o.BackgroundColor3=u end
p.Color=s._value and i:Get"Accent"or i:Get"Border";q.Visible=s._value
end
function s.GetValue(t)return t._value end
function s.SetValue(t,u,v)
assert(type(u)=="boolean","Checkbox:SetValue espera booleano");if t._destroyed then return end
local w=t._value~=u;t._value=u;render(true)
if w and v==true and k then task.spawn(k,u,t)end
end
function s.Get(t)return t:GetValue()end
function s.Set(t,u,v)return t:SetValue(u,v)end
s:Connect(n.Activated,function()if s.Enabled then s:FocusWindow();s:SetValue(not s._value,true)end end)
s:Connect(n.MouseEnter,function()if s.Enabled then f.Tweens:To(m,{BackgroundColor3=i:Get"SurfaceRaised"},{Time=0.1})end end)
s:Connect(n.MouseLeave,function()if s.Enabled then f.Tweens:To(m,{BackgroundColor3=i:Get"Surface"},{Time=0.1})end end)
function s.SetEnabled(t,u)b.SetEnabled(t,u);n.Active=t.Enabled;n.Selectable=t.Enabled;m.BackgroundTransparency=t.Enabled and 0 or 0.4 end
render(false);s:SetEnabled(h.Enabled~=false);return s
end
return e end function a.m():typeof(__modImpl())local b=a.cache.m if not b then b={c=__modImpl()}a.cache.m=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.c()
local e={}
e.__index=e
setmetatable(e,{__index=b})

function e.new(f,g,h)
h=d.Options(h,"Toggle options")
local i=f.Theme
local j=d.String(h.Title,"Title","Toggle",true)
local k=d.String(h.Description,"Description","",true)
local l=d.Callback(h.Callback)
local m=h.Value
if m==nil then m=h.Default end
if m==nil then m=false end
assert(type(m)=="boolean","Toggle Value debe ser booleano")
local n=k~=""and 58 or 42
local o=c.Create("Frame",{Name=h.Name or"Toggle",BackgroundColor3=i:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,h.Height or n)},g)
c.Corner(o,i:Get"CornerRadius")
local p=c.Create("TextButton",{Name="Action",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Text="",AutoButtonColor=false},o)
local q=c.Label(o,"Title",j,UDim2.new(1,-78,0,22),UDim2.new(0,12,0,k~=""and 6 or 0),i:Get"Text",14,true)
local r
if k~=""then r=c.Label(o,"Description",k,
UDim2.new(1,-78,0,20),UDim2.new(0,12,0,30),i:Get"MutedText",11)end
local s=c.Create("Frame",{Name="Track",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
Size=UDim2.fromOffset(40,22),BackgroundColor3=i:Get"Disabled",BorderSizePixel=0},o)
c.Corner(s,11)
local t=c.Create("Frame",{Name="Knob",Position=UDim2.new(0,3,0.5,-8),Size=UDim2.fromOffset(16,16),
BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},s)
c.Corner(t,8)
local u=setmetatable({},e)
b.Initialize(u,f,o)
u.TextObject=q
u.DescriptionObject=r
u._action,u._track,u._knob=p,s,t
u._callback=l
u._value=m
local function render(v)
local w=u._value and UDim2.new(1,-19,0.5,-8)or UDim2.new(0,3,0.5,-8)
local x=u._value and i:Get"Accent"or i:Get"Disabled"
if v then
f.Tweens:To(t,{Position=w},{Time=0.14})
f.Tweens:To(s,{BackgroundColor3=x},{Time=0.14})
else t.Position=w;s.BackgroundColor3=x end
end
function u.GetValue(v)return v._value end
function u.SetValue(v,w,x)
if v._destroyed then return end
assert(type(w)=="boolean","Toggle:SetValue espera booleano")
local y=w~=v._value
v._value=w
render(true)
if y and x==true and v._callback then task.spawn(v._callback,w,v)end
end
function u.Set(v,w,x)return v:SetValue(w,x)end
function u.Get(v)return v:GetValue()end
u:Connect(p.Activated,function()
if not u.Enabled then return end
u:FocusWindow()
u:SetValue(not u._value,true)
end)
u:Connect(p.MouseEnter,function()if u.Enabled then f.Tweens:To(o,{BackgroundColor3=i:Get"SurfaceRaised"},{Time=0.1})end end)
u:Connect(p.MouseLeave,function()if u.Enabled then f.Tweens:To(o,{BackgroundColor3=i:Get"Surface"},{Time=0.1})end end)
function u.SetEnabled(v,w)
if v._destroyed then return end
b.SetEnabled(v,w)
v._action.Active=v.Enabled
v._action.Selectable=v.Enabled
v.Frame.BackgroundTransparency=v.Enabled and 0 or 0.4
end
render(false)
u:SetEnabled(h.Enabled~=false)
return u
end

return e end function a.n():typeof(__modImpl())local b=a.cache.n if not b then b={c=__modImpl()}a.cache.n=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.c()
local e={}
e.__index=e
setmetatable(e,{__index=b})

function e.new(f,g,h)
h=d.Options(h,"Slider options")
local i=f.Theme
local j,k=d.Range(h.Min,h.Max,0,100)
local l=d.Step(h.Step,1)
local m=d.Number(h.Value,"Value",h.Default or j)
local n=d.Callback(h.Callback)
local o=c.Create("Frame",{Name=h.Name or"Slider",BackgroundColor3=i:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,h.Height or 60)},g)
c.Corner(o,i:Get"CornerRadius")
local p=c.Label(o,"Title",h.Title or"Slider",UDim2.new(0.7,-12,0,22),UDim2.new(0,12,0,4),i:Get"Text",14,true)
local q=c.Label(o,"Value","",UDim2.new(0,90,0,22),UDim2.new(1,-102,0,4),i:Get"MutedText",12)
q.TextXAlignment=Enum.TextXAlignment.Right
local r=c.Create("TextButton",{Name="Track",Text="",AutoButtonColor=false,BorderSizePixel=0,
BackgroundColor3=i:Get"Border",Position=UDim2.new(0,12,0,36),Size=UDim2.new(1,-24,0,8)},o)
c.Corner(r,4)
local s=c.Create("Frame",{Name="Fill",BackgroundColor3=i:Get"Accent",BorderSizePixel=0,
Size=UDim2.new(0,0,1,0)},r)
c.Corner(s,4)
local t=c.Create("Frame",{Name="Knob",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),
Size=UDim2.fromOffset(14,14),BackgroundColor3=i:Get"Text",BorderSizePixel=0},r)
c.Corner(t,7)
local u=c.Create("TextButton",{Name="InputArea",BackgroundTransparency=1,Text="",AutoButtonColor=false,
Size=UDim2.new(1,12,1,18),Position=UDim2.new(0,-6,0,-5),ZIndex=r.ZIndex+1},r)
local v=setmetatable({},e)
b.Initialize(v,f,o)
v.TextObject=p
v._valueLabel,v._track,v._fill,v._knob,v._pointer=q,r,s,t,u
v._minimum,v._maximum,v._step,v._callback=j,k,l,n
local function quantize(w)
w=math.clamp(w,j,k)
local x=math.floor(((w-j)/l)+0.5)
return math.clamp(j+x*l,j,k)
end
local function render()
local w=(v._value-j)/(k-j)
s.Size=UDim2.new(w,0,1,0)
t.Position=UDim2.new(w,0,0.5,0)
q.Text=tostring(v._value)
end
function v.GetValue(w)return w._value end
function v.SetValue(w,x,y)
if w._destroyed then return end
x=quantize(d.Number(x,"value"))
local z=x~=w._value
w._value=x
render()
if z and y==true and w._callback then task.spawn(w._callback,x,w)end
end
function v.Set(w,x,y)return w:SetValue(x,y)end
local function moveTo(w)
if not v.Enabled then return end
local x=r.AbsoluteSize.X
if x<=0 then return end
local y=math.clamp((w.X-r.AbsolutePosition.X)/x,0,1)
v:SetValue(j+y*(k-j),true)
end
v:Connect(u.InputBegan,function(w)
if not v.Enabled then return end
v:FocusWindow()
if f.Input:BeginDrag(w,moveTo,nil,v,f.Window)then moveTo(w.Position)end
end)
v._value=quantize(m)
function v.SetEnabled(w,x)
if w._destroyed then return end
b.SetEnabled(w,x)
w._pointer.Active=w.Enabled
w._pointer.Selectable=w.Enabled
w.Frame.BackgroundTransparency=w.Enabled and 0 or 0.4
end
render()
v:SetEnabled(h.Enabled~=false)
return v
end

return e end function a.o():typeof(__modImpl())local b=a.cache.o if not b then b={c=__modImpl()}a.cache.o=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.k()
local e=a.c()
local f={}
f.__index=f
setmetatable(f,{__index=b})

local function normalizeOption(g)
if type(g)=="string"or type(g)=="number"then
return{Value=g,Text=tostring(g)}
end
assert(type(g)=="table","Cada opción debe ser string, number o tabla")
local h=g.Value
if h==nil then h=g.Text end
assert(h~=nil,"Cada opción necesita Value o Text")
assert(type(h)=="string"or type(h)=="number"or type(h)=="boolean","Value debe ser string, number o boolean")
if type(h)=="number"then assert(h==h and h>-math.huge and h<math.huge,"Value numérico debe ser finito")end
return{Value=h,Text=tostring(g.Text or h),Id=g.Id,Description=g.Description,Icon=g.Icon or g.Image,Disabled=g.Disabled==true}
end

function f.new(g,h,i)
i=e.Options(i,"Dropdown options")
local j=g.Theme
local k=i.Multiple==true
local l=e.Callback(i.Callback)
if i.Title~=nil then assert(type(i.Title)=="string","Title debe ser string")end
if i.Placeholder~=nil then assert(type(i.Placeholder)=="string","Placeholder debe ser string")end
assert(i.Options==nil or type(i.Options)=="table","Options debe ser una tabla")
local m=e.Number(i.RowHeight,"RowHeight",36)
local n=i.Searchable==true
local o=e.Number(i.MaxListHeight,"MaxListHeight",150)
assert(m>0 and o>0,"RowHeight y MaxListHeight deben ser positivos")
local p={}
for q,r in ipairs(i.Options or{})do
local s=normalizeOption(r)
assert(not p[s.Value],"Opción duplicada: "..tostring(s.Value))
p[s.Value]=true
end
local q=c.Create("Frame",{Name=i.Name or(k and"MultiSelect"or"Dropdown"),
BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,m),ClipsDescendants=true},h)
local r=c.Create("TextButton",{Name="Header",BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,
Size=UDim2.new(1,0,0,m),Text="",AutoButtonColor=false},q)
c.Corner(r,j:Get"CornerRadius")
local s=c.Stroke(r,j:Get"BorderSubtle",0.32,1)
local t
if n then
t=c.Create("TextBox",{Name="Search",Position=UDim2.new(0,0,0,m+4),
Size=UDim2.new(1,0,0,28),BackgroundColor3=j:Get"Background",BorderSizePixel=0,
Text="",PlaceholderText=i.SearchPlaceholder or"Search options…",ClearTextOnFocus=false,
Font=Enum.Font.Gotham,TextSize=11,TextColor3=j:Get"Text",PlaceholderColor3=j:Get"MutedText",
TextXAlignment=Enum.TextXAlignment.Left,Visible=false},q)
c.Corner(t,5);c.Padding(t,8,6,0,0)
end
local u
local v=12
if i.Icon then
u=d.Create(r,i.Icon,{Size=UDim2.fromOffset(16,16),Position=UDim2.new(0,10,0.5,-8),
Color=j:Get"Accent",Fallback="filter",TextSize=16})
v=34
end
local w=c.Label(r,"Title",i.Title or(k and"Select options"or"Select an option"),
UDim2.new(0.47,-v,1,0),UDim2.new(0,v,0,0),j:Get"Text",12,true)
local x=c.Label(r,"SelectedValue","",UDim2.new(0.48,-30,1,0),UDim2.new(0.48,0,0,0),j:Get"MutedText",10)
x.TextXAlignment=Enum.TextXAlignment.Right
local y=d.Create(r,"chevron-down",{Name="Arrow",Size=UDim2.fromOffset(16,16),Position=UDim2.new(1,-24,0.5,-8),
Color=j:Get"MutedText",Fallback="chevron-down",TextSize=16})
local z=c.Create("ScrollingFrame",{Name="Options",BackgroundColor3=j:Get"Surface",BorderSizePixel=0,
Position=UDim2.new(0,0,0,m+(n and 36 or 4)),Size=UDim2.new(1,0,0,0),CanvasSize=UDim2.new(),
AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,Visible=false,ClipsDescendants=true},q)
c.Corner(z,j:Get"CornerRadius")
c.Stroke(z,j:Get"BorderSubtle",0.28,1)
c.Padding(z,4,4,4,4)
local A=c.Create("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},z)
local B=c.Label(z,"NoResults",i.NoResultsText or"No matching options",UDim2.new(1,-8,0,26),UDim2.new(),j:Get"MutedText",10)
B.TextXAlignment=Enum.TextXAlignment.Center;B.LayoutOrder=0;B.Visible=false
local C=setmetatable({},f)
b.Initialize(C,g,q)
C.TextObject=w
C._header,C._valueLabel,C._arrow,C._list=r,x,y,z
C._layout,C._multiple,C._callback=A,k,l
C._options,C._optionButtons,C._open={},{},false
C._maximumListHeight=o
C._rowHeight=m
C._searchable,C._searchBox=n,t
C._minSelected=math.max(0,math.floor(tonumber(i.MinSelected)or 0))
C._maxSelected=tonumber(i.MaxSelected)and math.max(0,math.floor(tonumber(i.MaxSelected)))or math.huge
assert(C._minSelected<=C._maxSelected,"MinSelected no puede superar MaxSelected")
C._value=k and{}or nil
local D
C:Connect(A:GetPropertyChangedSignal"AbsoluteContentSize",function()
if not C._open or not D then return end
D()
end)
local E=i.Value
if E==nil then E=i.Default end

local function isSelected(F)
if k then
for G,H in ipairs(C._value)do if H==F then return true end end
return false
end
return C._value==F
end
local function displayText(F)
local G=C._optionButtons[F]
return G and G.Text or tostring(F)
end
local function updateLabel()
if k then
if#C._value==0 then x.Text=i.Placeholder or"None selected"
elseif#C._value==1 then x.Text=displayText(C._value[1])
else x.Text=tostring(#C._value).." selected"end
else
x.Text=C._value==nil and(i.Placeholder or"Choose…")or displayText(C._value)
end
for F,G in pairs(C._optionButtons)do
local H=isSelected(F)
if G.Label then G.Label.TextColor3=H and j:Get"Accent"or(G.Disabled and j:Get"Disabled"or j:Get"Text")end
if G.Button then
G.Button.BackgroundColor3=H and j:Get"AccentSoft"or j:Get"SurfaceRaised"
G.Button.BackgroundTransparency=H and 0.20 or 1
end
if G.Check then G.Check.Visible=H end
end
end

D=function()
local F=0
for G,H in pairs(C._optionButtons)do if H.Button.Visible then F+=1 end end
B.Visible=F==0
local G=0
for H,I in pairs(C._optionButtons)do
if I.Button.Visible then G+=I.Description and 38 or 29 end
end
local H=F==0 and 36 or math.min(C._maximumListHeight,G+11)
z.Size=UDim2.new(1,0,0,H)
q.Size=UDim2.new(1,0,0,m+(n and 36 or 4)+H)
end
local function applySearch()
if not n or not t then return end
local F=string.lower(t.Text)
for G,H in pairs(C._optionButtons)do
local I=string.lower(table.concat({H.Text or"",H.Description or""}," "))
H.Button.Visible=F==""or string.find(I,F,1,true)~=nil
end
if C._open then D()end
end
if n and t then
C:Connect(t:GetPropertyChangedSignal"Text",applySearch)
end

local function normalizedValue(F)
local G={}
for H,I in ipairs(C._options)do if not I.Disabled then G[I.Value]=true end end
if k then
assert(type(F)=="table","MultiSelect:SetValue espera una tabla")
local H,I={},{}
for J,K in ipairs(F)do
assert(G[K],"Opción no válida o deshabilitada: "..tostring(K))
if not I[K]then table.insert(H,K);I[K]=true end
end
assert(#H>=C._minSelected,"La selección no alcanza MinSelected")
assert(#H<=C._maxSelected,"La selección supera MaxSelected")
return H
end
assert(F==nil or G[F],"Opción no válida: "..tostring(F))
return F
end
function C.GetValue(F)
if k then return table.clone(F._value)end
return F._value
end
function C.SetValue(F,G,H)
if F._destroyed then return end
G=normalizedValue(G)
local I=F._value~=G
if k then
I=#F._value~=#G
if not I then
for J,K in ipairs(G)do if F._value[J]~=K then I=true;break end end
end
end
F._value=G
updateLabel()
if I and H==true and F._callback then task.spawn(F._callback,F:GetValue(),F)end
end
function C.Get(F)return F:GetValue()end
function C.Set(F,G,H)return F:SetValue(G,H)end
function C.SelectAll(F,G)
assert(F._multiple,"SelectAll solo está disponible en MultiSelect")
local H={}
for I,J in ipairs(F._options)do if not J.Disabled and#H<F._maxSelected then table.insert(H,J.Value)end end
F:SetValue(H,G==true)
end
function C.ClearSelection(F,G)
assert(F._multiple,"ClearSelection solo está disponible en MultiSelect")
if F._minSelected>0 then return false end
F:SetValue({},G==true);return true
end
function C.IsOpen(F)return F._open end
function C.Close(F)
if F._destroyed or not F._open then return end
F._open=false
z.Visible=false
z.Size=UDim2.new(1,0,0,0)
if t then t.Visible=false end
q.Size=UDim2.new(1,0,0,m)
g.Tweens:To(y,{Rotation=0},{Time=0.12})
end
function C.Open(F)
if F._destroyed then return end
if not F.Enabled or F._open then return end
F._open=true
if t then t.Visible=true end
z.Visible=true
applySearch()
D()
g.Tweens:To(y,{Rotation=180},{Time=0.12})
end
function C.ToggleOpen(F)
if F._destroyed or not F.Enabled then return end
if F._open then F:Close()else F:Open()end
end
function C.ClearOptions(F)
if F._destroyed then return end
for G,H in pairs(F._optionButtons)do
if H.Connection then H.Connection:Disconnect()end
if H.Button.Parent then H.Button:Destroy()end
F._cleanup:Remove(H.Connection,false)
end
table.clear(F._optionButtons)
table.clear(F._options)
F._value=k and{}or nil
F:Close()
updateLabel()
end
function C.AddOption(F,G)
assert(not F._destroyed,"Dropdown destruido")
local H=normalizeOption(G)
for I,J in ipairs(F._options)do assert(J.Value~=H.Value,"Opción duplicada: "..tostring(H.Value))end
table.insert(F._options,H)
local I=c.Create("TextButton",{Name="Option",Size=UDim2.new(1,0,0,H.Description and 38 or 29),
BackgroundColor3=j:Get"SurfaceRaised",BackgroundTransparency=1,AutoButtonColor=false,Text="",
Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
TextColor3=H.Disabled and j:Get"Disabled"or j:Get"Text",LayoutOrder=#F._options,Active=not H.Disabled,
TextTransparency=H.Disabled and 0.35 or 0},z)
c.Corner(I,7)
local J=9
if H.Icon then
d.Create(I,H.Icon,{Size=UDim2.fromOffset(15,15),Position=UDim2.new(0,8,0,H.Description and 6 or 7),
Color=H.Disabled and j:Get"Disabled"or j:Get"Accent",Fallback="circle",TextSize=14})
J=31
end
local K=c.Label(I,"OptionText",H.Text,UDim2.new(1,-(J+34),0,H.Description and 18 or 29),
UDim2.new(0,J,0,H.Description and 1 or 0),j:Get"Text",11,true)
K.TextTruncate=Enum.TextTruncate.AtEnd
local L
if H.Description then
L=c.Label(I,"OptionDescription",tostring(H.Description),UDim2.new(1,-(J+34),0,15),
UDim2.new(0,J,0,18),j:Get"MutedText",9,false)
L.TextTruncate=Enum.TextTruncate.AtEnd
end
local M=d.Create(I,"check",{Size=UDim2.fromOffset(14,14),Position=UDim2.new(1,-22,0.5,-7),
Color=j:Get"Accent",Fallback="check",TextSize=14})
M.Visible=false
local N=I.Activated:Connect(function()
if not F.Enabled then return end
F:FocusWindow()
if H.Disabled then return end
if k then
local N=table.clone(F._value)
local O
for P,Q in ipairs(N)do if Q==H.Value then table.remove(N,P);O=true;break end end
if O and#N<F._minSelected then return end
if not O and#N>=F._maxSelected then return end
if not O then table.insert(N,H.Value)end
F:SetValue(N,true)
else
F:SetValue(H.Value,true)
F:Close()
end
end)
I.MouseEnter:Connect(function()
if not H.Disabled and not F._destroyed then g.Tweens:To(I,{BackgroundTransparency=0.12},{Time=0.1})end
end)
I.MouseLeave:Connect(function()
if not H.Disabled and not F._destroyed then g.Tweens:To(I,{BackgroundTransparency=1},{Time=0.1})end
end)
F._cleanup:Add(N)
F._optionButtons[H.Value]={Button=I,Connection=N,Text=H.Text,Label=K,Description=L,Check=M,Disabled=H.Disabled}
applySearch()
updateLabel()
if g.Window and g.Window._ApplyZIndex then g.Window:_ApplyZIndex()end
end
function C.SetOptions(F,G)
assert(not F._destroyed,"Dropdown destruido")
assert(type(G)=="table","SetOptions espera una tabla")
F:ClearOptions()
for H,I in ipairs(G)do F:AddOption(I)end
updateLabel()
end
function C.RemoveOption(F,G)
if F._destroyed then return false end
local H=F._optionButtons[G]
if not H then return false end
if H.Connection then H.Connection:Disconnect();F._cleanup:Remove(H.Connection,false)end
if H.Button.Parent then H.Button:Destroy()end
F._optionButtons[G]=nil
for I,J in ipairs(F._options)do if J.Value==G then table.remove(F._options,I);break end end
if k then
local I={}
for J,K in ipairs(F._value)do if K~=G then table.insert(I,K)end end
F._value=I
elseif F._value==G then F._value=nil end
updateLabel()
return true
end
C:Connect(r.Activated,function()C:FocusWindow();C:ToggleOpen()end)
C:Connect(r.MouseEnter,function()
if C.Enabled then g.Tweens:To(r,{BackgroundColor3=j:Get"SurfaceHover"},{Time=0.1});g.Tweens:To(s,{Color=j:Get"Accent",Transparency=0.12},{Time=0.1})end
end)
C:Connect(r.MouseLeave,function()
if C.Enabled then g.Tweens:To(r,{BackgroundColor3=j:Get"SurfaceRaised"},{Time=0.1});g.Tweens:To(s,{Color=j:Get"BorderSubtle",Transparency=0.32},{Time=0.1})end
end)
function C.SetEnabled(F,G)
if F._destroyed then return end
b.SetEnabled(F,G)
r.Active=F.Enabled
r.Selectable=F.Enabled
if t then t.TextEditable=F.Enabled;t.Active=F.Enabled end
r.BackgroundTransparency=F.Enabled and 0 or 0.35
if not F.Enabled then F:Close()end
end
for F,G in ipairs(i.Options or{})do C:AddOption(G)end
if E==nil and k and C._minSelected>0 then
E={}
for F,G in ipairs(C._options)do
if not G.Disabled and#E<C._minSelected then table.insert(E,G.Value)end
end
end
if E~=nil then
local F,G=pcall(function()C:SetValue(E,false)end)
if not F then C:Destroy();error(G,2)end
end
C:SetEnabled(i.Enabled~=false)
return C
end

return f end function a.p():typeof(__modImpl())local b=a.cache.p if not b then b={c=__modImpl()}a.cache.p=b end return b.c end end do local function __modImpl()

local b=a.p()
local c={}
function c.new(d,e,f)
f=f or{}
local g=table.clone(f)
g.Multiple=true
return b.new(d,e,g)
end
return c end function a.q():typeof(__modImpl())local b=a.cache.q if not b then b={c=__modImpl()}a.cache.q=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.c()
local e={}
e.__index=e
setmetatable(e,{__index=b})

function e.new(f,g,h)
h=d.Options(h,"TextInput options")
local i=f.Theme
local j=d.String(h.Title,"Title","Text input",true)
local k=d.String(h.Value,"Value",h.Default or"",true)
local l=d.Callback(h.Callback)
local m=d.Callback(h.Validator,"Validator")
if h.MaxLength~=nil then
assert(type(h.MaxLength)=="number"and h.MaxLength>=1 and h.MaxLength%1==0,
"MaxLength debe ser un entero positivo")
end
local n=h.MultiLine==true
local o=h.Height or(n and(h.Description and 138 or 118)or(h.Description and 74 or 62))
local p=c.Create("Frame",{Name=h.Name or"TextInput",BackgroundColor3=i:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,h.Height or o)},g)
c.Corner(p,i:Get"CornerRadius")
local q=c.Label(p,"Title",j,UDim2.new(1,-20,0,20),UDim2.new(0,10,0,4),i:Get"Text",13,true)
local r=26
if h.Description then
c.Label(p,"Description",tostring(h.Description),UDim2.new(1,-20,0,16),UDim2.new(0,10,0,23),i:Get"MutedText",10)
r=42
end
local s=c.Create("TextBox",{Name="Input",Text=k,
PlaceholderText=h.Placeholder or"Type here…",PlaceholderColor3=i:Get"MutedText",
BackgroundColor3=i:Get"Background",BorderSizePixel=0,Size=UDim2.new(1,-20,0,h.InputHeight or(n and(h.Description and 56 or 62)or 27)),
Position=UDim2.new(0,10,0,r),Font=Enum.Font.Gotham,TextSize=12,
TextColor3=i:Get"Text",TextXAlignment=Enum.TextXAlignment.Left,
ClearTextOnFocus=false,MultiLine=h.MultiLine==true,TextWrapped=h.MultiLine==true},p)
c.Corner(s,5)
c.Padding(s,8,8,0,0)
local t=c.Label(p,"ValidationMessage","",UDim2.new(1,-20,0,15),UDim2.new(0,10,1,-16),i:Get"Danger",10)
t.Visible=false
local u=setmetatable({},e)
b.Initialize(u,f,p)
u.TextObject=q
u._box,u._error,u._callback,u._validator=s,t,l,m
u._value,u._maxLength=k,h.MaxLength
u.Required=h.Required==true
function u.GetValue(v)return v._value end
function u.SetValue(v,w,x)
if v._destroyed then return end
assert(type(w)=="string","TextInput:SetValue espera una cadena")
if v._maxLength then w=string.sub(w,1,v._maxLength)end
v._value=w
s.Text=w
t.Visible=false
if x==true and v._callback then task.spawn(v._callback,w,false,v)end
end
function u.SetText(v,w)v:SetValue(w,false)end
function u.GetText(v)return v:GetValue()end
function u.Validate(v)
if v._destroyed then return false,"Component destroyed"end
local w=s.Text
if v.Required and w==""then
t.Text="This field is required"
t.Visible=true
return false,t.Text
end
if v._validator then
local x,y,z=pcall(v._validator,w)
if not x or y==false then
t.Text=x and tostring(z or"Invalid value")or"Validation failed"
t.Visible=true
return false,t.Text
end
end
v._value=w
t.Visible=false
return true,w
end
u:Connect(s.Focused,function()u:FocusWindow()end)
u:Connect(s:GetPropertyChangedSignal"Text",function()
if u._maxLength and#s.Text>u._maxLength then
local v=string.sub(s.Text,1,u._maxLength)
s.Text=v
end
end)
u:Connect(s.FocusLost,function(v)
if not u.Enabled then return end
local w=u:Validate()
if not w then s.Text=u._value;return end
if u._callback then task.spawn(u._callback,u._value,v==true,u)end
end)
function u.SetEnabled(v,w)
if v._destroyed then return end
b.SetEnabled(v,w)
s.TextEditable=v.Enabled
s.Active=v.Enabled
s.BackgroundTransparency=v.Enabled and 0 or 0.4
end
u:SetEnabled(h.Enabled~=false)
return u
end

return e end function a.r():typeof(__modImpl())local b=a.cache.r if not b then b={c=__modImpl()}a.cache.r=b end return b.c end end do local function __modImpl()

local b=a.r()
local c={}
function c.new(d,e,f)
f=f or{}
local g=table.clone(f)
g.Name=f.Name or"NumericInput"
local h,i=f.Min,f.Max
local function isFinite(j)
return type(j)=="number"and j==j and j>-math.huge and j<math.huge
end
if h~=nil then assert(isFinite(h),"Min debe ser un número finito")end
if i~=nil then assert(isFinite(i),"Max debe ser un número finito")end
if f.Integer~=nil then assert(type(f.Integer)=="boolean","Integer debe ser booleano")end
if h~=nil and i~=nil then assert(i>=h,"Max debe ser mayor o igual a Min")end
g.Validator=function(j)
local k=tonumber(j)
if not k then return false,"Enter a valid number"end
if h~=nil and k<h then return false,"Minimum is "..tostring(h)end
if i~=nil and k>i then return false,"Maximum is "..tostring(i)end
if f.Integer and k%1~=0 then return false,"Enter a whole number"end
if type(f.Validator)=="function"then return f.Validator(k)end
return true
end
local j=f.Callback
g.Callback=function(k,l,m)
if type(j)=="function"then j(tonumber(k),l,m)end
end
local k=f.Value
if k==nil then k=f.Default end
if k~=nil then
assert(isFinite(k),"NumericInput Value debe ser un número finito")
if h~=nil then k=math.max(h,k)end
if i~=nil then k=math.min(i,k)end
if f.Integer then assert(k%1==0,"NumericInput Value debe ser entero")end
g.Value=tostring(k)
end
local l=b.new(d,e,g)
local m=l.GetValue
local n=l.SetValue
function l.GetValue(o)return tonumber(m(o))end
function l.SetValue(o,p,q)
if o._destroyed then return end
assert(isFinite(p),"NumericInput:SetValue espera un número finito")
if f.Integer then assert(p%1==0,"NumericInput:SetValue espera un entero")end
if h~=nil then p=math.max(h,p)end
if i~=nil then p=math.min(i,p)end
return n(o,tostring(p),q)
end
function l.GetNumber(o)return o:GetValue()end
return l
end
return c end function a.s():typeof(__modImpl())local b=a.cache.s if not b then b={c=__modImpl()}a.cache.s=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d={}
d.__index=d
setmetatable(d,{__index=b})
function d.new(e,f,g)
g=g or{}
local h=e.Theme
local i=c.Create("Frame",{Name=g.Name or"Label",BackgroundTransparency=1,
Size=UDim2.new(1,0,0,g.Height or 24)},f)
local j=c.Label(i,"Text",tostring(g.Text or g.Title or"Label"),UDim2.new(1,-4,1,0),UDim2.new(0,2,0,0),
g.Color or h:Get"Text",g.TextSize or 13,g.Bold==true)
j.TextWrapped=g.TextWrapped~=false
local k=setmetatable({},d);b.Initialize(k,e,i);k.TextObject=j
function k.SetText(l,m)if l._destroyed then return end;assert(type(m)=="string","SetText espera string");j.Text=m end
function k.GetText(l)return j.Text end
return k
end
return d end function a.t():typeof(__modImpl())local b=a.cache.t if not b then b={c=__modImpl()}a.cache.t=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d={}
d.__index=d
setmetatable(d,{__index=b})
function d.new(e,f,g)
g=g or{}
local h=e.Theme
local i=c.Create("Frame",{Name=g.Name or"Paragraph",BackgroundTransparency=1,
Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},f)
c.Create("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,3)},i)
local j
if g.Title and g.Title~=""then
j=c.Label(i,"Title",tostring(g.Title),UDim2.new(1,-4,0,20),UDim2.new(),h:Get"Text",13,true)
j.LayoutOrder=1
end
local k=c.Label(i,"Text",tostring(g.Text or g.Description or""),UDim2.new(1,-4,0,0),UDim2.new(),
g.Color or h:Get"MutedText",g.TextSize or 12,false)
k.AutomaticSize=Enum.AutomaticSize.Y
k.TextYAlignment=Enum.TextYAlignment.Top
k.LayoutOrder=2
local l=setmetatable({},d);b.Initialize(l,e,i);l.TextObject=k;l.TitleObject=j
function l.SetText(m,n)if m._destroyed then return end;assert(type(n)=="string","SetText espera string");k.Text=n end
function l.SetTitle(m,n)
if m._destroyed then return end
assert(type(n)=="string","SetTitle espera string")
if not j then j=c.Label(i,"Title",n,UDim2.new(1,-4,0,20),UDim2.new(),h:Get"Text",13,true);j.LayoutOrder=1;m.TitleObject=j
else j.Text=n end
end
return l
end
return d end function a.u():typeof(__modImpl())local b=a.cache.u if not b then b={c=__modImpl()}a.cache.u=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d={}
d.__index=d
setmetatable(d,{__index=b})
function d.new(e,f,g)
g=g or{}
local h=c.Create("Frame",{Name=g.Name or"Divider",BorderSizePixel=0,
BackgroundColor3=g.Color or e.Theme:Get"Border",
Size=UDim2.new(1,0,0,g.Thickness or 1)},f)
local i=setmetatable({},d);b.Initialize(i,e,h);return i
end
return d end function a.v():typeof(__modImpl())local b=a.cache.v if not b then b={c=__modImpl()}a.cache.v=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.k()
local e={}
e.__index=e
setmetatable(e,{__index=b})

function e.new(f,g,h)
h=h or{}
local i=f.Theme
local j=c.Create("Frame",{Name=h.Name or"Card",BackgroundColor3=h.BackgroundColor or i:Get"Surface",
BackgroundTransparency=h.BackgroundTransparency==nil and 0.03 or h.BackgroundTransparency,
BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},g)
c.Corner(j,i:Get"CornerRadius");c.Stroke(j,i:Get"BorderSubtle",0.60,1)
local k=0
if h.Accent==true then
local l=c.Create("Frame",{Name="AccentRule",Size=UDim2.new(1,0,0,2),BackgroundColor3=i:Get"Accent",BorderSizePixel=0},j)
l.LayoutOrder=0
c.Create("UIGradient",{Color=ColorSequence.new(i:Get"Accent",i:Get"AccentSecondary"),
Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.08),NumberSequenceKeypoint.new(1,0.72)}},l)
k=1
end
c.Create("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,7)},j)
c.Padding(j,12,12,11,12)
k+=1
if h.Image and h.Image~=""then
local l=c.Create("Frame",{Name="ImageContainer",BackgroundColor3=i:Get"SurfaceRaised",BorderSizePixel=0,
Size=UDim2.new(1,0,0,h.ImageHeight or 104),ClipsDescendants=true,LayoutOrder=k},j)
c.Corner(l,math.max(0,i:Get"CornerRadius"-2))
c.Create("ImageLabel",{Name="Image",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),
Image=tostring(h.Image),ScaleType=h.ImageScaleType or Enum.ScaleType.Crop},l)
k+=1
end
if h.Title and h.Title~=""then
local l=c.Create("Frame",{Name="TitleRow",Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,LayoutOrder=k},j)
if h.Icon then
d.Create(l,h.Icon,{Size=UDim2.fromOffset(17,17),Position=UDim2.new(0,0,0.5,-8.5),
Color=i:Get"Accent",Fallback="layers",TextSize=17})
end
local m=c.Label(l,"Title",h.Title,UDim2.new(1,h.Icon and-25 or 0,1,0),
UDim2.new(0,h.Icon and 25 or 0,0,0),i:Get"Text",13,true)
m.TextTruncate=Enum.TextTruncate.AtEnd
k+=1
end
if h.Description and h.Description~=""then
local l=c.Label(j,"Description",h.Description,UDim2.new(1,0,0,0),UDim2.new(),i:Get"MutedText",11)
l.AutomaticSize=Enum.AutomaticSize.Y;l.LayoutOrder=k;k+=1
end
local l=c.Create("Frame",{Name="Content",BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=k},j)
c.Create("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,7)},l)
local m=setmetatable({},e);b.Initialize(m,f,j)
m.Content=l
function m.Add(n,o,p)
assert(not n._destroyed,"Card destruida")
local q=f.Factory:Create(o,l,p or{},f)
n._children=n._children or{};table.insert(n._children,q)
if q.Frame then q.Frame.LayoutOrder=#n._children end
if f.Window and f.Window._ApplyZIndex then f.Window:_ApplyZIndex()end
return q
end
function m.SetEnabled(n,o)
if n._destroyed then return end
b.SetEnabled(n,o)
for p,q in ipairs(n._children or{})do if q.SetEnabled then q:SetEnabled(o)end end
end
for n,o in pairs{AddButton="Button",AddToggle="Toggle",AddSlider="Slider",AddDropdown="Dropdown",
AddMultiSelect="MultiSelect",AddTextInput="TextInput",AddNumericInput="NumericInput",AddLabel="Label",
AddParagraph="Paragraph",AddDivider="Divider",AddProgress="Progress",AddImage="Image",AddKeybind="Keybind",
AddSegmented="Segmented",AddCard="Card",AddCollapsible="Collapsible",AddForm="Form",AddBadge="Badge",AddStatusIndicator="StatusIndicator",AddMetricCard="MetricCard",AddKeyValueList="KeyValueList",AddDataTable="DataTable",AddItemCatalog="ItemCatalog",AddRadioGroup="RadioGroup",AddRangeSlider="RangeSlider",AddTextArea="TextArea",AddColorPicker="ColorPicker",AddEmptyState="EmptyState",AddLogViewer="LogViewer",AddTreeView="TreeView",AddCarousel="Carousel",AddCheckbox="Checkbox",AddSearchableDropdown="SearchableDropdown",AddMultiSelectDropdown="MultiSelectDropdown",
AddTagSelector="TagSelector",AddCheckboxGroup="CheckboxGroup",AddPrimaryButton="PrimaryButton",
AddSecondaryButton="SecondaryButton",AddDestructiveButton="DestructiveButton",AddIconButton="IconButton",
AddButtonGroup="ButtonGroup",AddAccordion="Accordion",AddProgressBar="Progress"}do
local p=o
m[n]=function(q,r)return q:Add(p,r)end
end
return m
end
return e end function a.w():typeof(__modImpl())local b=a.cache.w if not b then b={c=__modImpl()}a.cache.w=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.c()
local e={}
e.__index=e
setmetatable(e,{__index=b})
function e.new(f,g,h)
h=h or{}
local i=f.Theme
local j,k=d.Range(h.Min,h.Max,0,100)
local l=d.Number(h.Value,"Value",h.Default or j)
local m=c.Create("Frame",{Name=h.Name or"Progress",BackgroundTransparency=1,
Size=UDim2.new(1,0,0,h.Height or 42)},g)
local n=c.Label(m,"Title",tostring(h.Title or"Progress"),UDim2.new(0.75,0,0,18),UDim2.new(0,0,0,0),i:Get"Text",12,true)
local o=c.Label(m,"Value","",UDim2.new(0.25,0,0,18),UDim2.new(0.75,0,0,0),i:Get"MutedText",11)
o.TextXAlignment=Enum.TextXAlignment.Right
local p=c.Create("Frame",{Name="Track",BackgroundColor3=i:Get"Border",BorderSizePixel=0,
Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,8)},m);c.Corner(p,4)
local q=c.Create("Frame",{Name="Fill",BackgroundColor3=h.Color or i:Get"Accent",BorderSizePixel=0,
Size=UDim2.new(0,0,1,0)},p);c.Corner(q,4)
local r=setmetatable({},e);b.Initialize(r,f,m);r.TextObject=n
r._value,r._min,r._max,r._fill,r._amount=l,j,k,q,o
function r.GetValue(s)return s._value end
function r.SetValue(s,t)
if s._destroyed then return end
s._value=math.clamp(d.Number(t,"value"),j,k)
local u=(s._value-j)/(k-j)
f.Tweens:To(q,{Size=UDim2.new(u,0,1,0)},{Time=0.2})
o.Text=h.ShowPercent==false and tostring(s._value)or(tostring(math.floor(u*100+0.5)).."%")
end
r:SetValue(math.clamp(l,j,k))
return r
end
return e end function a.x():typeof(__modImpl())local b=a.cache.x if not b then b={c=__modImpl()}a.cache.x=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d={}
d.__index=d
setmetatable(d,{__index=b})
function d.new(e,f,g)
g=g or{}
local h=g.Width or 120
local i=g.Height or 90
local j=c.Create("ImageLabel",{Name=g.Name or"Image",BackgroundColor3=e.Theme:Get"Surface",
BackgroundTransparency=g.BackgroundTransparency==nil and 0 or g.BackgroundTransparency,
BorderSizePixel=0,Image=g.Image or"",Size=UDim2.new(1,0,0,i),
ScaleType=g.ScaleType or Enum.ScaleType.Fit,ImageColor3=g.ImageColor3 or Color3.new(1,1,1),
ImageTransparency=g.ImageTransparency or 0,ResampleMode=g.ResampleMode or Enum.ResamplerMode.Default},f)
if g.FixedWidth then j.Size=UDim2.fromOffset(h,i)end
if g.CornerRadius then c.Corner(j,g.CornerRadius)end
local k=setmetatable({},d);b.Initialize(k,e,j);k.ImageObject=j
function k.SetImage(l,m)if l._destroyed then return end;assert(type(m)=="string","SetImage espera string");j.Image=m end
function k.GetImage(l)return j.Image end
return k
end
return d end function a.y():typeof(__modImpl())local b=a.cache.y if not b then b={c=__modImpl()}a.cache.y=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.c()
local e={}
e.__index=e
setmetatable(e,{__index=b})
function e.new(f,g,h)
h=h or{}
local i,j=f.Theme,d.Callback(h.Callback)
local k=f.Services.UserInputService
local l=h.Value or h.Default or Enum.KeyCode.Unknown
assert(typeof(l)=="EnumItem"and l.EnumType==Enum.KeyCode,"Keybind Value debe ser Enum.KeyCode")
local m=c.Create("Frame",{Name=h.Name or"Keybind",BackgroundColor3=i:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,h.Height or 42)},g);c.Corner(m,i:Get"CornerRadius")
local n=c.Label(m,"Title",h.Title or"Keybind",UDim2.new(1,-112,1,0),UDim2.new(0,12,0,0),i:Get"Text",13,true)
local o=c.Create("TextButton",{Name="Capture",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),
Size=UDim2.fromOffset(94,28),BackgroundColor3=i:Get"SurfaceRaised",BorderSizePixel=0,
Text=l==Enum.KeyCode.Unknown and"Unassigned"or l.Name,TextColor3=i:Get"MutedText",
TextSize=11,Font=Enum.Font.GothamMedium,AutoButtonColor=false},m);c.Corner(o,5)
local p=setmetatable({},e);b.Initialize(p,f,m);p.TextObject=n
p._value,p._callback,p._capturing=l,j,false
function p.GetValue(q)return q._value end
function p.SetValue(q,r,s)
if q._destroyed then return end
assert(typeof(r)=="EnumItem"and r.EnumType==Enum.KeyCode,"Keybind:SetValue espera Enum.KeyCode")
local t=q._value~=r;q._value=r
o.Text=r==Enum.KeyCode.Unknown and"Unassigned"or r.Name
if t and s==true and q._callback then task.spawn(q._callback,r,q)end
end
function p.Capture(q)
if q._destroyed then return end
if not q.Enabled or q._capturing then return end
q._capturing=true;o.Text="Press a key…"
end
p:Connect(o.Activated,function()p:FocusWindow();p:Capture()end)
p._cleanup:Add(k.InputBegan:Connect(function(q,r)
if not p._capturing or r then return end
if q.UserInputType==Enum.UserInputType.Keyboard then
if q.KeyCode==Enum.KeyCode.Escape then p._capturing=false;p:SetValue(p._value,false);return end
p._capturing=false;p:SetValue(q.KeyCode,true)
end
end))
function p.SetEnabled(q,r)
if q._destroyed then return end
b.SetEnabled(q,r);o.Active=q.Enabled;o.Selectable=q.Enabled
if not q.Enabled then q._capturing=false;o.BackgroundTransparency=0.4 else o.BackgroundTransparency=0 end
end
p:SetEnabled(h.Enabled~=false)
return p
end
return e end function a.z():typeof(__modImpl())local b=a.cache.z if not b then b={c=__modImpl()}a.cache.z=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.c()
local e={}
e.__index=e
setmetatable(e,{__index=b})
function e.new(f,g,h)
h=d.Options(h,"Segmented options")
assert(type(h.Options)=="table"and#h.Options>0,"Segmented necesita Options")
local i,j=f.Theme,d.Callback(h.Callback)
local function optionValue(k)
if type(k)~="table"then return k end
if k.Value~=nil then return k.Value end
return k.Text
end
local k={}
for l,m in ipairs(h.Options)do
local n=optionValue(m)
assert(n~=nil and(type(n)=="string"or type(n)=="number"or type(n)=="boolean"),
"Cada opción de Segmented necesita Value/Text string, number o boolean")
if type(n)=="number"then assert(n==n and n>-math.huge and n<math.huge,"Value numérico debe ser finito")end
assert(not k[n],"Valor duplicado en Segmented: "..tostring(n))
k[n]=true
end
local l=h.Value
if l==nil then l=h.Default end
assert(l==nil or k[l],"Valor inicial no disponible en Segmented")
local m=c.Create("Frame",{Name=h.Name or"Segmented",BackgroundColor3=i:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,h.Height or 38)},g);c.Corner(m,i:Get"CornerRadius");c.Padding(m,3,3,3,3)
c.Create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,3)},m)
local n=setmetatable({},e);b.Initialize(n,f,m);n.TextObject=nil
n._buttons,n._options,n._callback={},{},j
local o=l
local function val(p)
if type(p)~="table"then return p end
if p.Value~=nil then return p.Value end
return p.Text
end
local function txt(p)
if type(p)~="table"then return tostring(p)end
if p.Text~=nil then return tostring(p.Text)end
return tostring(p.Value)
end
for p,q in ipairs(h.Options)do
local r=val(q);table.insert(n._options,r)
local s=c.Create("TextButton",{Name="Option",LayoutOrder=p,Size=UDim2.new(1/#h.Options,-3,1,0),
BackgroundColor3=i:Get"SurfaceRaised",BorderSizePixel=0,AutoButtonColor=false,
Text=txt(q),TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=i:Get"MutedText"},m)
c.Corner(s,5);n._buttons[r]=s
n:Connect(s.Activated,function()if n.Enabled then n:FocusWindow();n:SetValue(r,true)end end)
end
function n.GetValue(p)return p._value end
function n.SetValue(p,q,r)
if p._destroyed then return end
local s=false;for t,u in ipairs(p._options)do if u==q then s=true;break end end
assert(s,"Valor no disponible en Segmented")
local t=p._value~=q;p._value=q
for u,v in pairs(p._buttons)do
local w=u==q
v.BackgroundColor3=w and i:Get"Accent"or i:Get"SurfaceRaised"
v.TextColor3=w and i:Get"AccentText"or i:Get"MutedText"
end
if t and r==true and p._callback then task.spawn(p._callback,q,p)end
end
if o==nil then o=n._options[1]end
n._value=o;n:SetValue(n._value,false)
function n.SetEnabled(p,q)
if p._destroyed then return end
b.SetEnabled(p,q)
for r,s in pairs(p._buttons)do
s.Active=p.Enabled;s.Selectable=p.Enabled
s.TextTransparency=p.Enabled and 0 or 0.4
end
end
n:SetEnabled(h.Enabled~=false)
return n
end
return e end function a.A():typeof(__modImpl())local b=a.cache.A if not b then b={c=__modImpl()}a.cache.A=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d={}
d.__index=d
setmetatable(d,{__index=b})
function d.new(e,f,g)
g=g or{}
local h=e.Theme
local i=c.Create("Frame",{Name=g.Name or"Collapsible",BackgroundColor3=h:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,g.HeaderHeight or 36),ClipsDescendants=true},f)
c.Corner(i,h:Get"CornerRadius")
local j=c.Create("TextButton",{Name="Header",Size=UDim2.new(1,0,0,g.HeaderHeight or 36),
BackgroundTransparency=1,AutoButtonColor=false,Text="",TextXAlignment=Enum.TextXAlignment.Left},i)
local k=c.Label(j,"Title",g.Title or"Expandable section",UDim2.new(1,-42,1,0),UDim2.new(0,11,0,0),h:Get"Text",13,true)
local l=c.Label(j,"Arrow",g.Expanded==true and"−"or"+",UDim2.new(0,24,1,0),UDim2.new(1,-30,0,0),h:Get"MutedText",17,true)
l.TextXAlignment=Enum.TextXAlignment.Center
local m=c.Create("Frame",{Name="Content",BackgroundTransparency=1,
Position=UDim2.new(0,10,0,(g.HeaderHeight or 36)+5),Size=UDim2.new(1,-20,0,0),Visible=g.Expanded==true},i)
local n=c.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},m)
local o=setmetatable({},d);b.Initialize(o,e,i);o.TextObject=k
o:Connect(n:GetPropertyChangedSignal"AbsoluteContentSize",function()
if o._expanded then
m.Size=UDim2.new(1,-20,0,n.AbsoluteContentSize.Y)
i.Size=UDim2.new(1,0,0,o._headerHeight+5+n.AbsoluteContentSize.Y)
end
end)
o.Content,o._header,o._arrow,o._expanded,o._headerHeight=m,j,l,g.Expanded==true,g.HeaderHeight or 36
function o.Add(p,q,r)
assert(not p._destroyed,"Collapsible destruido")
local s=e.Factory:Create(q,m,r or{},e)
p._children=p._children or{};table.insert(p._children,s)
if s.Frame then s.Frame.LayoutOrder=#p._children end
if e.Window and e.Window._ApplyZIndex then e.Window:_ApplyZIndex()end
return s
end
for p,q in pairs{AddButton="Button",AddToggle="Toggle",AddSlider="Slider",AddDropdown="Dropdown",
AddMultiSelect="MultiSelect",AddTextInput="TextInput",AddNumericInput="NumericInput",AddLabel="Label",
AddParagraph="Paragraph",AddDivider="Divider",AddCard="Card",AddProgress="Progress",AddImage="Image",
AddKeybind="Keybind",AddSegmented="Segmented",AddCollapsible="Collapsible",AddForm="Form",AddBadge="Badge",AddStatusIndicator="StatusIndicator",AddMetricCard="MetricCard",AddKeyValueList="KeyValueList",AddDataTable="DataTable",AddItemCatalog="ItemCatalog",AddRadioGroup="RadioGroup",AddRangeSlider="RangeSlider",AddTextArea="TextArea",AddColorPicker="ColorPicker",AddEmptyState="EmptyState",AddLogViewer="LogViewer",AddTreeView="TreeView",AddCarousel="Carousel",AddCheckbox="Checkbox",AddSearchableDropdown="SearchableDropdown",AddMultiSelectDropdown="MultiSelectDropdown",
AddTagSelector="TagSelector",AddCheckboxGroup="CheckboxGroup",AddPrimaryButton="PrimaryButton",
AddSecondaryButton="SecondaryButton",AddDestructiveButton="DestructiveButton",AddIconButton="IconButton",
AddButtonGroup="ButtonGroup",AddAccordion="Accordion",AddProgressBar="Progress"}do
local r=q
o[p]=function(s,t)return s:Add(r,t)end
end
function o.SetExpanded(p,q)
if p._destroyed then return end
p._expanded=q==true
m.Visible=p._expanded
m.Size=UDim2.new(1,-20,0,p._expanded and n.AbsoluteContentSize.Y or 0)
i.Size=UDim2.new(1,0,0,p._headerHeight+(p._expanded and 5+n.AbsoluteContentSize.Y or 0))
l.Text=p._expanded and"−"or"+"
end
function o.IsExpanded(p)return p._expanded end
function o.SetEnabled(p,q)
if p._destroyed then return end
b.SetEnabled(p,q);j.Active=p.Enabled;j.Selectable=p.Enabled
if not p.Enabled then j.TextTransparency=0.4 else j.TextTransparency=0 end
for r,s in ipairs(p._children or{})do if s.SetEnabled then s:SetEnabled(q)end end
end
o:Connect(j.Activated,function()if not o.Enabled then return end;o:FocusWindow();o:SetExpanded(not o._expanded)end)
o:SetExpanded(g.Expanded==true)
o:SetEnabled(g.Enabled~=false)
return o
end
return d end function a.B():typeof(__modImpl())local b=a.cache.B if not b then b={c=__modImpl()}a.cache.B=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d={}
d.__index=d
setmetatable(d,{__index=b})
function d.new(e,f,g)
g=g or{}
assert(type(g)=="table","Form options debe ser una tabla")
local h=g.Fields
if h==nil then h={}end
assert(type(h)=="table","Fields debe ser una tabla")
if g.OnSubmit~=nil then assert(type(g.OnSubmit)=="function","OnSubmit debe ser una función")end
if g.SubmitText~=nil then assert(type(g.SubmitText)=="string","SubmitText debe ser una cadena")end
local i={}
for j,k in ipairs(h)do
assert(type(k)=="table","Cada field debe ser una tabla")
local l=k.Name or k.Key or k.Title
assert(type(l)=="string"and l~="","Cada campo del Form necesita Name, Key o Title")
assert(not i[l],"Nombre de campo duplicado: "..l)
i[l]=true
assert(k.Type==nil or type(k.Type)=="string","Type de cada field debe ser string")
end
local j=e.Theme
local k=c.Create("Frame",{Name=g.Name or"Form",BackgroundColor3=j:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},f)
c.Corner(k,j:Get"CornerRadius");c.Padding(k,10,10,10,10)
c.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7)},k)
local l=setmetatable({},d);b.Initialize(l,e,k);l.Fields,l._fieldConfig,l._fieldOrder={},h,{}
local m
local n,o=pcall(function()
for n,o in ipairs(l._fieldConfig)do
local p=table.clone(o)
local q=p.Name or p.Key or p.Title
local r=p.Type or"TextInput"
p.Type=nil
local s=e.Factory:Create(r,k,p,e)
l.Fields[q]=s
table.insert(l._fieldOrder,q)
l._children=l._children or{};table.insert(l._children,s)
if s.Frame then s.Frame.LayoutOrder=#l._children end
end
m=e.Factory:Create("Button",k,{Title=g.SubmitText or"Submit",Callback=function()
l:Submit()
end},e)
m.Frame.LayoutOrder=10000
l.SubmitButton=m
l._children=l._children or{};table.insert(l._children,m)
end)
if not n then
for p=#(l._children or{}),1,-1 do
local q=l._children[p]
if q and q.Destroy then pcall(q.Destroy,q)end
end
l._cleanup:Destroy()
if k.Parent then k:Destroy()end
error(o,2)
end
function l.GetValues(p)
local q={}
for r,s in ipairs(p._fieldOrder)do
local t=p.Fields[s]
if t and t.GetValue then q[s]=t:GetValue()end
end
return q
end
function l.Submit(p)
if p._destroyed then return nil,false,nil,"Form destroyed"end
for q,r in ipairs(p._fieldOrder)do
local s=p.Fields[r]
if s and type(s.Validate)=="function"then
local t,u=s:Validate()
if not t then return nil,false,r,u end
end
end
local q=p:GetValues()
if type(g.OnSubmit)=="function"then task.spawn(g.OnSubmit,q,p)end
return q,true
end
function l.GetField(p,q)return p.Fields[q]end
function l.SetEnabled(p,q)
if p._destroyed then return end
b.SetEnabled(p,q)
for r,s in pairs(p.Fields)do if s.SetEnabled then s:SetEnabled(q)end end
if m.SetEnabled then m:SetEnabled(q)end
end
l:SetEnabled(g.Enabled~=false)
return l
end
return d end function a.C():typeof(__modImpl())local b=a.cache.C if not b then b={c=__modImpl()}a.cache.C=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.k()

local e={}
e.__index=e
setmetatable(e,{__index=b})

local f={
Accent={Theme="Accent",Text="Accent",Transparency=0.86},
Success={Theme="Success",Text="Success",Transparency=0.87},
Warning={Theme="Warning",Text="Warning",Transparency=0.87},
Danger={Theme="Danger",Text="Danger",Transparency=0.87},
Info={Theme="Info",Text="Info",Transparency=0.87},
Neutral={Theme="BorderSubtle",Text="MutedText",Transparency=0.18},
}

function e.new(g,h,i)
i=i or{}
local j=g.Theme
local k=f[i.Variant]and i.Variant or"Neutral"
local l=f[k]
local m=tostring(i.Text or i.Title or"Badge")
local n=i.TextSize or 10
local o=i.Icon~=nil and i.Icon~=false
local p=o and 31 or 18
local q=i.Width or math.max(42,#m*n*0.61+p)
local r=c.Create("Frame",{
Name=i.Name or"Badge",
Size=UDim2.fromOffset(q,i.Height or 24),
BackgroundColor3=i.BackgroundColor or j:Get(l.Theme),
BackgroundTransparency=i.BackgroundTransparency==nil and l.Transparency or i.BackgroundTransparency,
BorderSizePixel=0,
ClipsDescendants=true,
},h)
c.Corner(r,i.Radius or 8)
local s=c.Stroke(r,i.StrokeColor or j:Get(l.Theme),i.StrokeTransparency or 0.64,1)

local t
if o then
t=d.Create(r,i.Icon,{
Name="BadgeIcon",Size=UDim2.fromOffset(12,12),Position=UDim2.new(0,7,0.5,-6),
Color=i.IconColor or j:Get(l.Text),Fallback="tag",TextSize=12,
})
end
local u=c.Label(r,"Text",m,
UDim2.new(1,-(o and 25 or 12),1,0),UDim2.new(0,o and 23 or 6,0,0),
i.TextColor or j:Get(l.Text),n,i.Bold~=false)
u.TextXAlignment=i.TextXAlignment or Enum.TextXAlignment.Center
u.TextTruncate=Enum.TextTruncate.AtEnd

local v=setmetatable({},e)
b.Initialize(v,g,r)
v.TextObject=u
v.IconObject=t
v.StrokeObject=s
v._variant=k
v._options=i

local function updateWidth()
r.Size=UDim2.fromOffset(i.Width or math.max(42,#u.Text*n*0.61+p),i.Height or 24)
end

function v.SetText(w,x)
if w._destroyed then return end
u.Text=tostring(x)
updateWidth()
end

function v.SetVariant(w,x)
if w._destroyed then return end
k=f[x]and x or"Neutral"
l=f[k]
w._variant=k
r.BackgroundColor3=i.BackgroundColor or j:Get(l.Theme)
r.BackgroundTransparency=i.BackgroundTransparency==nil and l.Transparency or i.BackgroundTransparency
u.TextColor3=i.TextColor or j:Get(l.Text)
s.Color=i.StrokeColor or j:Get(l.Theme)
if t then
if t:IsA"ImageLabel"then t.ImageColor3=i.IconColor or j:Get(l.Text)
else t.TextColor3=i.IconColor or j:Get(l.Text)end
end
end

function v.SetIcon(w,x)
if w._destroyed then return end
if t and t.Parent then t:Destroy()end
t=nil
o=x~=nil and x~=false
p=o and 31 or 18
if o then
t=d.Create(r,x,{Name="BadgeIcon",Size=UDim2.fromOffset(12,12),
Position=UDim2.new(0,7,0.5,-6),Color=i.IconColor or j:Get(l.Text),Fallback="tag",TextSize=12})
end
w.IconObject=t
u.Position=UDim2.new(0,o and 23 or 6,0,0)
u.Size=UDim2.new(1,-(o and 25 or 12),1,0)
updateWidth()
end

function v.GetVariant(w)
return w._variant
end

return v
end

return e end function a.D():typeof(__modImpl())local b=a.cache.D if not b then b={c=__modImpl()}a.cache.D=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d={};d.__index=d;setmetatable(d,{__index=b})
local function colorFor(e,f)
local g=string.lower(tostring(f or"offline"))
if g=="ready"or g=="running"or g=="online"or g=="success"or g=="connected"then return e:Get"Success"end
if g=="warning"or g=="pending"or g=="loading"or g=="initializing"then return e:Get"Warning"end
if g=="error"or g=="failed"or g=="offline"or g=="disconnected"then return e:Get"Danger"end
return e:Get"Accent"
end
function d.new(e,f,g)
g=g or{};local h=e.Theme
local i=c.Create("Frame",{Name=g.Name or"StatusIndicator",BackgroundTransparency=1,Size=UDim2.new(1,0,0,g.Height or 24)},f)
local j=c.Create("Frame",{Name="Dot",BackgroundColor3=colorFor(h,g.Status or"READY"),BorderSizePixel=0,
AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.fromOffset(8,8)},i);c.Corner(j,5)
local k=c.Label(i,"Label",tostring(g.Text or g.Status or"READY"),UDim2.new(1,-20,1,0),UDim2.new(0,18,0,0),h:Get"Text",g.TextSize or 12,g.Bold==true)
local l=setmetatable({},d);b.Initialize(l,e,i);l.TextObject=k;l._dot=j
function l.SetStatus(m,n,o)
if m._destroyed then return end
n=tostring(n or"READY");j.BackgroundColor3=colorFor(h,n);k.Text=tostring(o or n)
end
function l.SetText(m,n)if not m._destroyed then k.Text=tostring(n)end end
return l
end
return d end function a.E():typeof(__modImpl())local b=a.cache.E if not b then b={c=__modImpl()}a.cache.E=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.k()

local e={}
e.__index=e
setmetatable(e,{__index=b})

function e.new(f,g,h)
h=h or{}
local i=f.Theme
local j=h.Icon~=nil and h.Icon~=false
local k=c.Create("Frame",{
Name=h.Name or"MetricCard",
BackgroundColor3=i:Get(h.BackgroundTheme or"Surface"),
BackgroundTransparency=h.BackgroundTransparency or 0.02,
BorderSizePixel=0,
Size=UDim2.new(1,0,0,h.Height or 96),
ClipsDescendants=true,
},g)
c.Corner(k,h.CornerRadius or math.min(i:Get"CornerRadius",10))
c.Stroke(k,i:Get"BorderSubtle",0.56,1)
c.Padding(k,12,12,9,8)

local l,m
if j then
l=c.Create("Frame",{
Name="MetricIconTile",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
Size=UDim2.fromOffset(h.IconTileSize or 30,h.IconTileSize or 30),
BackgroundColor3=h.IconBackgroundColor or i:Get"AccentSoft",
BackgroundTransparency=0.12,BorderSizePixel=0,
},k)
c.Corner(l,8)
c.Stroke(l,h.IconStrokeColor or i:Get"BorderSubtle",0.45,1)
m=d.Create(l,h.Icon,{
Name="MetricIcon",Size=UDim2.fromOffset(16,16),Position=UDim2.new(0.5,-8,0.5,-8),
Color=h.IconColor or i:Get"Accent",Fallback="chart",TextSize=16,
})
end

local n=c.Label(k,"MetricTitle",tostring(h.Title or"Metric"),
UDim2.new(1,j and-40 or 0,0,17),UDim2.new(),i:Get"MutedText",10,true)
n.TextTruncate=Enum.TextTruncate.AtEnd

local o=c.Label(k,"MetricValue",tostring(h.Value==nil and"—"or h.Value),
UDim2.new(1,j and-40 or 0,0,34),UDim2.new(0,0,0,23),
h.ValueColor or i:Get"Text",h.ValueSize or 23,true)
o.TextTruncate=Enum.TextTruncate.AtEnd

local p=c.Label(k,"MetricDescription",tostring(h.Description or h.Change or""),
UDim2.new(1,0,0,15),UDim2.new(0,0,1,-17),h.DescriptionColor or i:Get"MutedText",10)
p.TextTruncate=Enum.TextTruncate.AtEnd

local q=setmetatable({},e)
b.Initialize(q,f,k)
q.TitleObject=n
q.ValueObject=o
q.DescriptionObject=p
q.IconObject=m
q.IconTile=l

function q.SetValue(r,s,t)
if r._destroyed then return end
o.Text=tostring(s)
if t~=nil then p.Text=tostring(t)end
end

function q.GetValue(r)
return o.Text
end

function q.SetDescription(r,s)
if not r._destroyed then p.Text=tostring(s)end
end

function q.SetTitle(r,s)
if not r._destroyed then n.Text=tostring(s)end
end

function q.SetIcon(r,s,t)
if r._destroyed then return end
if l and l.Parent then l:Destroy()end
l,m=nil,nil
if s~=nil and s~=false then
l=c.Create("Frame",{
Name="MetricIconTile",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
Size=UDim2.fromOffset(h.IconTileSize or 30,h.IconTileSize or 30),
BackgroundColor3=h.IconBackgroundColor or i:Get"AccentSoft",BackgroundTransparency=0.12,
BorderSizePixel=0,
},k)
c.Corner(l,8)
c.Stroke(l,h.IconStrokeColor or i:Get"BorderSubtle",0.45,1)
m=d.Create(l,s,{
Name="MetricIcon",Size=UDim2.fromOffset(16,16),Position=UDim2.new(0.5,-8,0.5,-8),
Color=t or h.IconColor or i:Get"Accent",Fallback="chart",TextSize=16,
})
end
r.IconTile,r.IconObject=l,m
n.Size=UDim2.new(1,l and-40 or 0,0,17)
o.Size=UDim2.new(1,l and-40 or 0,0,34)
end

return q
end

return e end function a.F():typeof(__modImpl())local b=a.cache.F if not b then b={c=__modImpl()}a.cache.F=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d={};d.__index=d;setmetatable(d,{__index=b})
function d.new(e,f,g)
g=g or{};local h=e.Theme
local i=c.Create("Frame",{Name=g.Name or"KeyValueList",BackgroundTransparency=1,
Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},f)
c.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,g.Spacing or 4)},i)
local j=setmetatable({},d);b.Initialize(j,e,i);j.Data={};j._rows={}
function j.SetData(k,l)
assert(type(l)=="table","SetData espera una tabla")
if k._destroyed then return end
for m,n in pairs(k._rows)do if n.Parent then n:Destroy()end end;table.clear(k._rows);k.Data=table.clone(l)
local m={}
for n,o in pairs(l)do table.insert(m,{Key=tostring(n),Value=tostring(o)})end
table.sort(m,function(n,o)return n.Key<o.Key end)
for n,o in ipairs(m)do
local p=c.Create("Frame",{Name="PropertyRow",BackgroundTransparency=n%2==0 and 0.65 or 1,
BackgroundColor3=h:Get"SurfaceRaised",Size=UDim2.new(1,0,0,26),LayoutOrder=n},i)
c.Label(p,"Key",o.Key,UDim2.new(0.42,-8,1,0),UDim2.new(0,5,0,0),h:Get"MutedText",11,true)
local q=c.Label(p,"Value",o.Value,UDim2.new(0.58,-8,1,0),UDim2.new(0.42,3,0,0),h:Get"Text",11)
q.TextXAlignment=Enum.TextXAlignment.Right;q.TextTruncate=Enum.TextTruncate.AtEnd
table.insert(k._rows,p)
end
end
function j.GetData(k)return table.clone(k.Data)end
j:SetData(g.Data or g.Items or{})
return j
end
return d end function a.G():typeof(__modImpl())local b=a.cache.G if not b then b={c=__modImpl()}a.cache.G=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d={};d.__index=d;setmetatable(d,{__index=b})

local function shallowData(e)
local f={};for g,h in ipairs(e or{})do f[g]=table.clone(h)end;return f
end

function d.new(e,f,g)
g=g or{};local h=e.Theme
assert(type(g.Columns or{})=="table","DataTable.Columns debe ser una tabla")
local i=g.Columns or{}
local j=c.Create("Frame",{Name=g.Name or"DataTable",BackgroundColor3=h:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,g.Height or 230),ClipsDescendants=true},f)
c.Corner(j,h:Get"CornerRadius");c.Stroke(j,h:Get"Border",0.45,1)
local k=c.Create("Frame",{Name="Header",BackgroundColor3=h:Get"SurfaceRaised",Size=UDim2.new(1,0,0,32),BorderSizePixel=0},j)
local l=c.Create("ScrollingFrame",{Name="Rows",BackgroundTransparency=1,Position=UDim2.new(0,0,0,32),
Size=UDim2.new(1,0,1,-32),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
ScrollBarThickness=4,BorderSizePixel=0},j)
c.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,1)},l)
local m=c.Label(l,"Empty",g.EmptyText or"No data available",UDim2.new(1,-16,0,36),UDim2.new(0,8,0,0),h:Get"MutedText",11)
m.TextXAlignment=Enum.TextXAlignment.Center
local n=setmetatable({},d);b.Initialize(n,e,j)
n.Columns,n.Data,n._selected,n._selectedRecord,n._sortKey,n._sortDescending=i,{},nil,nil,nil,false
n._rowConnections,n._rowObjects,n._headerButtons={},{},{}

local function colKey(o)return o.Key or o.Field or o.Title end
local function colWidth(o)
local p=tonumber(o.Width)
if p and p>0 and p<=1 then return p end
return 1/math.max(1,#i)
end
for o,p in ipairs(i)do
local q=c.Create("TextButton",{Name="Column_"..tostring(colKey(p)),BackgroundTransparency=1,
Size=UDim2.new(colWidth(p),-6,1,0),Position=UDim2.new(0,0,0,0),
Text=tostring(p.Title or colKey(p)or"Column"),Font=Enum.Font.GothamSemibold,TextSize=10,
TextColor3=h:Get"MutedText",TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,
LayoutOrder=o},k)

q.Position=UDim2.new(0,0,0,0)
q.Size=UDim2.new(colWidth(p),-8,1,0)
q.AnchorPoint=Vector2.new(0,0)
q.Position=UDim2.new(0,0,0,0)
c.Padding(q,6,2,0,0)
n._headerButtons[o]=q
end
c.Create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,0)},k)

local function disconnectRows()
for o,p in ipairs(n._rowConnections)do if p.Connected then p:Disconnect()end end
table.clear(n._rowConnections)
for o,p in ipairs(n._rowObjects)do if p.Parent then p:Destroy()end end
table.clear(n._rowObjects)
end
local function orderedData()
local o=shallowData(n.Data)
if n._sortKey then
local p,q=n._sortKey,n._sortDescending
table.sort(o,function(r,s)
local t,u=r[p],s[p]
if t==u then return tostring(r.Id or r.ID or"")<tostring(s.Id or s.ID or"")end
if t==nil then return false end;if u==nil then return true end
if type(t)=="number"and type(u)=="number"then return q and t>u or(not q and t<u)end
t,u=string.lower(tostring(t)),string.lower(tostring(u))
return q and t>u or(not q and t<u)
end)
end
return o
end
local function render()
if n._destroyed then return end
disconnectRows()
local o=orderedData();m.Visible=#o==0
m.Size=UDim2.new(1,-16,0,#o==0 and 36 or 0)
for p,q in ipairs(o)do
local r=q.Id or q.ID or p
local s=c.Create("TextButton",{Name="Row_"..tostring(p),LayoutOrder=p,
BackgroundColor3=n._selected==r and h:Get"SurfaceRaised"or h:Get"Surface",
BackgroundTransparency=n._selected==r and 0 or(p%2==0 and 0.24 or 0.48),BorderSizePixel=0,
Size=UDim2.new(1,0,0,g.RowHeight or 30),Text="",AutoButtonColor=false},l)
table.insert(n._rowObjects,s)
local t=0
for u,v in ipairs(i)do
local w=colWidth(v)
local x=colKey(v)
local y=q[x]
if type(v.Render)=="function"then
local z,A=pcall(v.Render,y,q,p)
if z then y=A else y="[render error]"end
end
local z=c.Label(s,"Cell_"..tostring(u),y==nil and"—"or tostring(y),
UDim2.new(w,-8,1,0),UDim2.new(t,0,0,0),h:Get"Text",10)
z.TextTruncate=Enum.TextTruncate.AtEnd
c.Padding(z,6,1,0,0)
t+=w
end
local u=s.Activated:Connect(function()
if n._destroyed then return end
n._selected=r;n._selectedRecord=table.clone(q)
if type(g.OnRowSelected)=="function"then task.spawn(g.OnRowSelected,table.clone(q),p,n)end
render()
end)
table.insert(n._rowConnections,u)
end
end
for o,p in ipairs(n._headerButtons)do
local q=i[o]
local r=p.Activated:Connect(function()
local r=colKey(q);if r==nil then return end
if n._sortKey==r then n._sortDescending=not n._sortDescending
else n._sortKey=r;n._sortDescending=false end
render()
end)
n._cleanup:Add(r)
end
function n.SetData(o,p)
assert(type(p)=="table","SetData espera una tabla")
if o._destroyed then return end
o.Data=shallowData(p);o._selected=nil;o._selectedRecord=nil;render()
end
function n.GetData(o)return shallowData(o.Data)end
function n.SetSort(o,p,q)
if o._destroyed then return end
o._sortKey=p;o._sortDescending=q==true;render()
end
function n.GetSelectedRow(o)
return o._selectedRecord and table.clone(o._selectedRecord)or nil
end
function n.Destroy(o)
if o._destroyed then return end
disconnectRows();b.Destroy(o)
end
n:SetData(g.Data or{})
return n
end
return d end function a.H():typeof(__modImpl())local b=a.cache.H if not b then b={c=__modImpl()}a.cache.H=b end return b.c end end do local function __modImpl()

local b=a.i()
local c=a.d()
local d=a.k()

local e={}
e.__index=e
setmetatable(e,{__index=b})

local f={
common=Color3.fromRGB(151,162,181),normal=Color3.fromRGB(151,162,181),basic=Color3.fromRGB(151,162,181),
comun=Color3.fromRGB(151,162,181),comunun=Color3.fromRGB(151,162,181),
uncommon=Color3.fromRGB(79,199,132),uncomun=Color3.fromRGB(79,199,132),
rare=Color3.fromRGB(89,165,255),raro=Color3.fromRGB(89,165,255),
epic=Color3.fromRGB(177,113,255),epico=Color3.fromRGB(177,113,255),
legendary=Color3.fromRGB(255,174,83),legendario=Color3.fromRGB(255,174,83),
mythic=Color3.fromRGB(255,93,128),mythical=Color3.fromRGB(255,93,128),mitico=Color3.fromRGB(255,93,128),
divine=Color3.fromRGB(255,220,111),divino=Color3.fromRGB(255,220,111),
limited=Color3.fromRGB(99,224,218),limitededition=Color3.fromRGB(99,224,218),limitado=Color3.fromRGB(99,224,218),
secret=Color3.fromRGB(246,98,180),secreto=Color3.fromRGB(246,98,180),
celestial=Color3.fromRGB(129,205,255),ancient=Color3.fromRGB(211,162,105),exotic=Color3.fromRGB(255,130,86),
}

local function itemId(g,h)
return g.Id or g.ID or g.Key or tostring(g.Name or g.Title or"Item").."#"..tostring(h)
end

local function firstValue(...)
for g=1,select("#",...)do
local h=select(g,...)
if h~=nil and h~=""then return h end
end
return nil
end

local function normalize(g)
assert(type(g)=="table","Items debe ser una tabla")
local h,i={},{}
for j,k in ipairs(g)do
if type(k)=="string"or type(k)=="number"then k={Name=tostring(k)}end
assert(type(k)=="table","Cada item debe ser una tabla, string o number")
local l=table.clone(k)
l.Name=tostring(firstValue(l.Name,l.Title,l.DisplayName,"Untitled item"))
l.Description=tostring(firstValue(l.Description,l.Subtitle,l.Info,""))
l.Id=itemId(l,j)
l.Image=firstValue(l.Image,l.Thumbnail,l.ThumbnailId,l.ImageId,l.PreviewImage,l.ImageAsset,l.AssetId,l.Asset)
l.Icon=firstValue(l.Icon,l.IconName,l.IconId,l.Symbol,l.IconAsset,l.Emblem)
l.Category=firstValue(l.Category,l.Type,l.Group)
l.Rarity=firstValue(l.Rarity,l.Quality,l.Tier)
l.Amount=firstValue(l.Amount,l.Count,l.Quantity,l.StackSize)
l.Price=firstValue(l.Price,l.Cost,l.Worth)
l.Tags=type(l.Tags)=="table"and table.clone(l.Tags)or(l.Tag and{l.Tag}or{})
l.Stats=type(l.Stats)=="table"and l.Stats or{}
l.Meta=type(l.Meta)=="table"and l.Meta or{}
assert(not i[l.Id],"ID de item duplicado: "..tostring(l.Id))
i[l.Id]=true
h[#h+1]=l
end
return h
end

local function inferIcon(g)

if g.Icon~=nil then return g.Icon end
local h=string.lower(tostring(g.Category or"").." "..g.Name)
local function hasAny(i)
for j,k in ipairs(i)do if h:find(k,1,true)then return true end end
return false
end
if hasAny{"sword","weapon","blade","espada","arma","hoja","katana"}then return"sword"end
if hasAny{"pet","animal","mascota","companion","compañero","perro","gato","dragon","dragón"}then return"paw"end
if hasAny{"coin","gold","money","currency","moneda","oro","dinero","cash","dollar","dólar"}then return"coins"end
if hasAny{"gem","crystal","diamond","cristal","gema","diamante","joya"}then return"gem"end
if hasAny{"potion","elixir","poción","pocion","elixir","brebaje"}then return"potion"end
if hasAny{"chest","crate","box","cofre","caja","baúl","baul","loot"}then return"box"end
if hasAny{"tool","gear","hammer","pickaxe","herramienta","martillo","pico"}then return"wrench"end
if hasAny{"badge","achievement","medal","insignia","logro","medalla"}then return"medal"end
if hasAny{"book","spell","tome","libro","hechizo","grimorio"}then return"book"end
if hasAny{"food","apple","bread","comida","manzana","pan","fruta"}then return"food"end
if hasAny{"armor","armour","shield","armadura","escudo"}then return"shield"end
if hasAny{"key","llave","token","ticket","boleto","pase"}then return"key"end
if hasAny{"car","vehicle","vehículo","vehiculo","coche","auto","truck","camión","camion"}then return"car"end
if hasAny{"house","home","casa","hogar","building","edificio"}then return"house"end
return"item"
end

local function rarityColor(g,h)
local i=string.lower(tostring(h or"")):gsub("[%s%._%-]+","")
return f[i]or g:Get"Accent"
end


local function iconColor(g,h)
if type(g.Icon)=="table"and(g.Icon.Color or g.Icon.ImageColor3 or g.Icon.Tint)then
return g.Icon.Color or g.Icon.ImageColor3 or g.Icon.Tint
end
return g.IconColor or rarityColor(h,g.Rarity)
end

local function createPill(g,h,i,j)
j=j or{}
local k=c.Create("Frame",{
Name=j.Name or"Pill",BackgroundColor3=i,BackgroundTransparency=j.Transparency or 0.84,
BorderSizePixel=0,Size=j.Size or UDim2.fromOffset(j.Width or 72,j.Height or 19),
Position=j.Position or UDim2.new(),AnchorPoint=j.AnchorPoint or Vector2.new(0,0),
},g)
c.Corner(k,6)
local l=c.Label(k,"Text",tostring(h),UDim2.new(1,-10,1,0),UDim2.new(0,5,0,0),i,j.TextSize or 9,true)
l.TextXAlignment=Enum.TextXAlignment.Center
l.TextTruncate=Enum.TextTruncate.AtEnd
return k
end

function e.new(g,h,i)
i=i or{}
local j=g.Theme
local k=math.clamp(tonumber(i.Height)or 330,160,900)
local l=i.Layout=="List"and"List"or"Grid"
local m=c.Create("Frame",{
Name=i.Name or"ItemCatalog",BackgroundTransparency=1,
Size=UDim2.new(1,0,0,k),
},h)


local n=c.Create("Frame",{Name="Toolbar",Size=UDim2.new(1,0,0,36),
BackgroundTransparency=1,BorderSizePixel=0},m)
local o=c.Create("Frame",{Name="SearchField",Size=UDim2.new(1,-158,1,0),
BackgroundColor3=j:Get"SurfaceInset",BorderSizePixel=0},n)
c.Corner(o,9)
local p=c.Stroke(o,j:Get"BorderSubtle",0.28,1)
d.Create(o,"search",{Size=UDim2.fromOffset(16,16),Position=UDim2.new(0,11,0.5,-8),Color=j:Get"MutedText",Fallback="search",TextSize=16})
local q=c.Create("TextBox",{
Name="Search",Position=UDim2.new(0,34,0,0),Size=UDim2.new(1,-42,1,0),
PlaceholderText=i.SearchPlaceholder or"Search items, tags, rarity…",Text="",ClearTextOnFocus=false,
BackgroundTransparency=1,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,
TextColor3=j:Get"Text",PlaceholderColor3=j:Get"MutedText",TextXAlignment=Enum.TextXAlignment.Left,
},o)
local r=c.Create("TextButton",{Name="Sort",Position=UDim2.new(1,-151,0,0),Size=UDim2.fromOffset(88,36),
BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,Text="   Name  ↑",TextColor3=j:Get"MutedText",
TextSize=10,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Center,AutoButtonColor=false},n)
c.Corner(r,9);c.Stroke(r,j:Get"BorderSubtle",0.55,1)
d.Create(r,"sort",{Size=UDim2.fromOffset(13,13),Position=UDim2.new(0,8,0.5,-6.5),Color=j:Get"Accent",Fallback="sort",TextSize=13})
local s=c.Create("TextButton",{Name="ToggleView",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
Size=UDim2.fromOffset(36,36),BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,
Text="",AutoButtonColor=false},n)
c.Corner(s,9);c.Stroke(s,j:Get"BorderSubtle",0.55,1)
local t=d.Create(s,l=="Grid"and"list"or"grid",{
Size=UDim2.fromOffset(16,16),Position=UDim2.new(0.5,-8,0.5,-8),Color=j:Get"Text",Fallback="grid",TextSize=16,
})

local u=c.Create("ScrollingFrame",{Name="CategoryFilters",Position=UDim2.new(0,0,0,43),
Size=UDim2.new(1,0,0,25),BackgroundTransparency=1,BorderSizePixel=0,
CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0,
ScrollingDirection=Enum.ScrollingDirection.X,Visible=i.ShowCategoryFilters~=false,
},m)
c.Create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,6),VerticalAlignment=Enum.VerticalAlignment.Center},u)

local v=i.ShowCategoryFilters==false and 43 or 76
local w=c.Create("ScrollingFrame",{Name="Items",Position=UDim2.new(0,0,0,v),
Size=UDim2.new(1,0,1,-v),BackgroundTransparency=1,BorderSizePixel=0,
CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,
ScrollBarImageColor3=j:Get"Border",ScrollingDirection=Enum.ScrollingDirection.Y,
},m)
c.Padding(w,2,6,2,8)
local x
if l=="Grid"then
x=c.Create("UIGridLayout",{
Name="GridLayout",SortOrder=Enum.SortOrder.LayoutOrder,
CellSize=UDim2.new(0.333,-8,0,i.CardHeight or 184),CellPadding=UDim2.fromOffset(8,8),
},w)
else
x=c.Create("UIListLayout",{
Name="ListLayout",SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7),
},w)
end
local y=c.Create("Frame",{Name="EmptyState",Position=UDim2.new(0,0,0,v),
Size=UDim2.new(1,0,1,-v),BackgroundTransparency=1,Visible=false,ZIndex=20,
},m)
local z=c.Create("Frame",{Name="IconTile",AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0.5,0,0.5,-37),Size=UDim2.fromOffset(40,40),
BackgroundColor3=j:Get"SurfaceRaised",BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=21},y)
c.Corner(z,12)
c.Stroke(z,j:Get"BorderSubtle",0.42,1)
d.Create(z,"search",{Size=UDim2.fromOffset(19,19),Position=UDim2.new(0.5,-9.5,0.5,-9.5),
Color=j:Get"MutedText",Fallback="search",TextSize=19,ZIndex=22})
local A=c.Label(y,"Title",tostring(i.EmptyTitle or"Nothing here yet"),
UDim2.new(1,-20,0,22),UDim2.new(0,10,0.5,-5),j:Get"Text",12,true);A.TextXAlignment=Enum.TextXAlignment.Center;A.ZIndex=21
local B=c.Label(y,"Description",tostring(i.EmptyText or"Try changing your search or filters."),
UDim2.new(1,-30,0,28),UDim2.new(0,15,0.5,17),j:Get"MutedText",10,false);B.TextXAlignment=Enum.TextXAlignment.Center;B.TextYAlignment=Enum.TextYAlignment.Top;B.ZIndex=21

local C=setmetatable({},e)
b.Initialize(C,g,m)
C.Items,C.Filter,C.SearchText,C.SortBy,C.SelectedId={},nil,"",i.SortBy or"Name",nil
C._rowItems,C._rowConnections={},{}
C._filterButtons,C._filterConnections={},{}
C._favorites={}
C._onSelect,C._onAction=i.OnItemSelected,i.OnAction
C._onFavoriteChanged=i.OnFavoriteChanged
C._maxRender=math.clamp(tonumber(i.MaxRender)or 72,10,500)
C._displayCount=C._maxRender
C._sortDescending=i.SortDescending==true
C._layoutMode=l
C._showFavorite=i.ShowFavorite~=false
C._sortFields=i.SortFields or{"Name","Rarity","Price","Amount"}
C._sortIndex=1
for D,E in ipairs(C._sortFields)do if E==C.SortBy then C._sortIndex=D;break end end

local function disconnectConnections(D)
for E,F in ipairs(D)do if F.Connected then F:Disconnect()end end
table.clear(D)
end
local function disconnectRows()
disconnectConnections(C._rowConnections)
for D,E in ipairs(C._rowItems)do if E.Parent then E:Destroy()end end
table.clear(C._rowItems)
end
local function addConnection(D)
table.insert(C._rowConnections,D)
end
local function itemIsFavorite(D)
if C._favorites[D.Id]~=nil then return C._favorites[D.Id]end
return D.Favorite==true or D.IsFavorite==true
end
local function updateSortText()
r.Text=tostring(C.SortBy or"Name")..(C._sortDescending and"  ↓"or"  ↑")
end
local function setSortKey(D,E)
C.SortBy=D
C._sortDescending=E==true
for F,G in ipairs(C._sortFields)do if G==D then C._sortIndex=F;break end end
updateSortText()
end
local function getRows()
local D,E={},string.lower(C.SearchText)
for F,G in ipairs(C.Items)do
local H=table.concat((function()
local H={}
for I,J in ipairs(G.Tags or{})do H[#H+1]=tostring(J)end
return H
end)()," ")
local I={}
for J,K in pairs(G.Meta or{})do I[#I+1]=tostring(J).." "..tostring(K)end
local J=string.lower(table.concat({G.Name,G.Description,tostring(G.Category or""),tostring(G.Rarity or""),tostring(G.Id),H,table.concat(I," ")}," "))
local K=E==""or string.find(J,E,1,true)~=nil
local L=false
if type(C.Filter)=="function"then local M,N=pcall(C.Filter,G);L=M and N==true end
local M=C.Filter==nil or L or G.Category==C.Filter or G.Rarity==C.Filter
local N=C._chipFilter==nil or G.Category==C._chipFilter or G.Rarity==C._chipFilter
if K and M and N then D[#D+1]=G end
end
if C.SortBy then
local F,G=C.SortBy,C._sortDescending
table.sort(D,function(H,I)
local J,K=H[F],I[F]
if J==nil and K~=nil then return false end
if K==nil and J~=nil then return true end
if J==K then return tostring(H.Id)<tostring(I.Id)end
if type(J)=="number"and type(K)=="number"then return G and J>K or(not G and J<K)end
J,K=string.lower(tostring(J or"")),string.lower(tostring(K or""))
return G and J>K or(not G and J<K)
end)
end
return D
end

local D
local E,F
C._detailsConnections={}
local function detailConnect(G,H)
table.insert(C._detailsConnections,G:Connect(H))
end
local function clearDetails()
for G,H in ipairs(C._detailsConnections)do
if H.Connected then H:Disconnect()end
end
table.clear(C._detailsConnections)
if E and E.Parent then E:Destroy()end
E,F=nil,nil
end
local function selectItem(G)
if C._destroyed or not C.Enabled then return end
C.SelectedId=G.Id
C:FocusWindow()
if type(C._onSelect)=="function"then task.spawn(C._onSelect,table.clone(G),C)end
D()
end
local function openDetails(G)
if C._destroyed or not C.Enabled then return false end
clearDetails()
C:FocusWindow()
C.SelectedId=G.Id
D()
local H=c.Create("TextButton",{Name="ItemDetailsOverlay",Size=UDim2.fromScale(1,1),
Position=UDim2.fromScale(0,0),BackgroundColor3=Color3.fromRGB(5,7,12),BackgroundTransparency=0.20,
BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=60},m)
E=H
local I=math.clamp(m.AbsoluteSize.X-28,250,420)
local J=math.clamp(m.AbsoluteSize.Y-28,220,360)
local K=c.Create("Frame",{Name="ItemDetails",AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(I,J),
BackgroundColor3=j:Get"Surface",BorderSizePixel=0,ZIndex=61,ClipsDescendants=true},H)
F=K
c.Corner(K,12);c.Stroke(K,j:Get"Border",0.08,1)
c.Create("UIGradient",{Rotation=90,Color=ColorSequence.new(j:Get"SurfaceRaised",j:Get"Surface")},K)
local L=c.Create("Frame",{Name="AccentRule",Size=UDim2.new(0.18,0,0,2),
BackgroundColor3=rarityColor(j,G.Rarity),BorderSizePixel=0,ZIndex=62},K)
c.Create("UIGradient",{Color=ColorSequence.new(rarityColor(j,G.Rarity),j:Get"AccentSecondary")},L)
local M=c.Create("TextButton",{Name="Close",AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-9,0,9),Size=UDim2.fromOffset(27,27),BackgroundColor3=j:Get"SurfaceInset",
BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=64},K)
c.Corner(M,8);c.Stroke(M,j:Get"BorderSubtle",0.4,1)
d.Create(M,"close",{Size=UDim2.fromOffset(14,14),Position=UDim2.new(0.5,-7,0.5,-7),
Color=j:Get"MutedText",TextSize=14,ZIndex=65})
detailConnect(M.Activated,clearDetails)

local N=c.Create("Frame",{Name="ItemHeader",Position=UDim2.new(0,14,0,14),
Size=UDim2.new(1,-28,0,76),BackgroundTransparency=1,ZIndex=62},K)
local O=c.Create("Frame",{Name="Artwork",Position=UDim2.new(0,0,0,0),
Size=UDim2.fromOffset(70,70),BackgroundColor3=j:Get"SurfaceInset",BorderSizePixel=0,
ClipsDescendants=true,ZIndex=63},N)
c.Corner(O,10);c.Stroke(O,rarityColor(j,G.Rarity),0.35,1)
if G.Image~=nil and G.Image~=""then
d.Create(O,G.Image,{Size=UDim2.fromScale(1,1),Position=UDim2.fromScale(0,0),
Color=Color3.new(1,1,1),Fallback=false,ScaleType=i.ImageScaleType or Enum.ScaleType.Crop,ZIndex=64})
else
d.Create(O,inferIcon(G),{Size=UDim2.fromOffset(32,32),Position=UDim2.new(0.5,-16,0.5,-16),
Color=iconColor(G,j),TextSize=32,ZIndex=64})
end
local P=c.Label(N,"ItemName",G.Name,UDim2.new(1,-118,0,24),UDim2.new(0,82,0,3),j:Get"Text",15,true)
P.ZIndex=63;P.TextTruncate=Enum.TextTruncate.AtEnd
local Q=c.Label(N,"ItemDescription",G.Description~=""and G.Description or tostring(G.Category or"No description available"),
UDim2.new(1,-84,0,31),UDim2.new(0,82,0,29),j:Get"MutedText",10)
Q.ZIndex=63;Q.TextYAlignment=Enum.TextYAlignment.Top;Q.TextTruncate=Enum.TextTruncate.AtEnd
local R=tostring(G.Rarity or G.Category or"ITEM")
local S=createPill(N,R,rarityColor(j,G.Rarity),{Position=UDim2.new(0,82,0,54),Width=math.clamp(26+#R*5,54,112),Height=18,TextSize=8,Transparency=0.82})
S.ZIndex=63

local T=102
local U=c.Create("ScrollingFrame",{Name="DetailsContent",Position=UDim2.new(0,14,0,T),
Size=UDim2.new(1,-28,1,-(T+58)),BackgroundTransparency=1,BorderSizePixel=0,
CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,
ScrollBarImageColor3=j:Get"Border",ScrollingDirection=Enum.ScrollingDirection.Y,ZIndex=62},K)
c.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},U)
c.Padding(U,0,3,0,5)
local V=0
local function addTextBlock(W,X,Y,Z,_)
V+=1
local aa=c.Label(U,W,X,UDim2.new(1,-2,0,Z or 18),UDim2.new(),Y or j:Get"Text",10,_==true)
aa.LayoutOrder=V;aa.ZIndex=63;aa.TextYAlignment=Enum.TextYAlignment.Top
return aa
end
if G.Tags and#G.Tags>0 then
local aa={}
for W,X in ipairs(G.Tags)do aa[#aa+1]=tostring(X)end
addTextBlock("Tags","TAGS   ·   "..table.concat(aa,"   /   "),j:Get"Accent",22,true)
end
local function addMap(aa,W)
local X={}
for Y in pairs(W or{})do X[#X+1]=Y end
table.sort(X,function(Y,Z)return tostring(Y)<tostring(Z)end)
if#X==0 then return end
V+=1
local Y=c.Label(U,"Group_"..aa,string.upper(aa),UDim2.new(1,0,0,15),UDim2.new(),j:Get"MutedText",8,true)
Y.LayoutOrder=V;Y.ZIndex=63
for Z,_ in ipairs(X)do
V+=1
local ab=c.Create("Frame",{Name="Property",LayoutOrder=V,Size=UDim2.new(1,-2,0,23),
BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,ZIndex=63},U)
c.Corner(ab,6)
local ac=c.Label(ab,"Key",tostring(_),UDim2.new(0.47,-8,1,0),UDim2.new(0,8,0,0),j:Get"MutedText",9,false)
ac.ZIndex=64;ac.TextTruncate=Enum.TextTruncate.AtEnd
local ad=c.Label(ab,"Value",tostring(W[_]),UDim2.new(0.53,-14,1,0),UDim2.new(0.47,2,0,0),j:Get"Text",9,true)
ad.ZIndex=64;ad.TextXAlignment=Enum.TextXAlignment.Right;ad.TextTruncate=Enum.TextTruncate.AtEnd
end
end
if next(G.Stats)then addMap("Statistics",G.Stats)end
if next(G.Meta)then addMap("Details",G.Meta)end
if V==0 then addTextBlock("NoMetadata","No extra metadata was provided for this item.",j:Get"MutedText",34,false)end

local aa=c.Create("Frame",{Name="Actions",AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,14,1,-12),
Size=UDim2.new(1,-28,0,34),BackgroundTransparency=1,ZIndex=63},K)
local ab={}
if G.ActionText or i.ActionText then
ab[#ab+1]={Text=G.ActionText or i.ActionText,Callback=G.Callback or C._onAction,Variant="Primary"}
end
if type(G.Actions)=="table"then for ac,ad in ipairs(G.Actions)do if#ab<3 and type(ad)=="table"then ab[#ab+1]=ad end end end
if#ab==0 then ab[1]={Text="Done",Variant="Secondary",Callback=clearDetails}end
local ac=7
local ad=math.max(64,(I-28-(#ab-1)*ac)/#ab)
for W,X in ipairs(ab)do
local Y=c.Create("TextButton",{Name="Action_"..W,
Position=UDim2.new(0,(W-1)*(ad+ac),0,0),Size=UDim2.new(0,ad,1,0),
BackgroundColor3=X.Variant=="Primary"and j:Get"Accent"or j:Get"SurfaceRaised",
BorderSizePixel=0,Text=tostring(X.Text or X.Title or"Action"),
TextColor3=X.Variant=="Primary"and j:Get"AccentText"or j:Get"Text",
TextSize=10,Font=Enum.Font.GothamSemibold,AutoButtonColor=false,ZIndex=64},aa)
c.Corner(Y,7)
detailConnect(Y.Activated,function()
if not C.Enabled or C._destroyed then return end
local Z=X.Callback or X.OnClick or(X==ab[1]and C._onAction)
if type(Z)=="function"then task.spawn(Z,table.clone(G),C)end
if X.CloseOnClick~=false then clearDetails()end
end)
end
if type(C._onDetailsOpened)=="function"then task.spawn(C._onDetailsOpened,table.clone(G),C)end
return true
end
local function setFavorite(aa,ab)
C._favorites[aa.Id]=ab==true
if type(C._onFavoriteChanged)=="function"then task.spawn(C._onFavoriteChanged,table.clone(aa),ab==true,C)end
D()
end
local function metadataText(aa)
local ab={}
if aa.Category then ab[#ab+1]=tostring(aa.Category)end
if aa.Rarity then ab[#ab+1]=tostring(aa.Rarity)end
if aa.Equipped==true or aa.IsEquipped==true then ab[#ab+1]="Equipped"end
if aa.Locked==true or aa.IsLocked==true then ab[#ab+1]="Locked"end
return table.concat(ab,"  ·  ")
end
local function valueText(aa)
local ab=firstValue(aa.Price,aa.Value,aa.Cost,aa.Worth)
if ab==nil then return nil end
if i.ValuePrefix then return tostring(i.ValuePrefix)..tostring(ab)end
if aa.Currency then return tostring(ab).." "..tostring(aa.Currency)end
return tostring(ab)
end
local function createFavoriteButton(aa,ab,ac)
if not C._showFavorite then return nil end
local ad=c.Create("TextButton",{
Name="Favorite",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-7,0,7),
Size=UDim2.fromOffset(ac and 25 or 28,ac and 25 or 28),
BackgroundColor3=j:Get"SurfaceInset",BackgroundTransparency=0.08,BorderSizePixel=0,
Text="",AutoButtonColor=false,
},aa)
c.Corner(ad,8);c.Stroke(ad,j:Get"BorderSubtle",0.35,1)
d.Create(ad,"heart",{Size=UDim2.fromOffset(14,14),Position=UDim2.new(0.5,-7,0.5,-7),
Color=itemIsFavorite(ab)and Color3.fromRGB(255,94,139)or j:Get"MutedText",Fallback="heart",TextSize=14})
addConnection(ad.Activated:Connect(function()
if C.Enabled and not C._destroyed then setFavorite(ab,not itemIsFavorite(ab))end
end))
return ad
end
local function createAction(aa,ab,ac,ad,G,H)
local I=c.Create("TextButton",{Name="Action",Position=ad,Size=G,
BackgroundColor3=j:Get"AccentSoft",BorderSizePixel=0,Text=tostring(ac or"Open"),
Font=Enum.Font.GothamSemibold,TextSize=10,TextColor3=j:Get"Accent",AutoButtonColor=false,
},aa)
c.Corner(I,7)
addConnection(I.MouseEnter:Connect(function()if C.Enabled then g.Tweens:To(I,{BackgroundColor3=j:Get"Accent",TextColor3=j:Get"AccentText"},{Time=0.1})end end))
addConnection(I.MouseLeave:Connect(function()if C.Enabled then g.Tweens:To(I,{BackgroundColor3=j:Get"AccentSoft",TextColor3=j:Get"Accent"},{Time=0.1})end end))
addConnection(I.Activated:Connect(function()
if not C.Enabled or C._destroyed then return end
C:FocusWindow()
local J=H or ab.Callback or C._onAction
if type(J)=="function"then task.spawn(J,table.clone(ab),C)end
end))
return I
end
local function createTags(aa,ab,ac)

local ad,G=0,0
local H=ac=="Grid"and 2 or 3
local function addBadge(I,J,K)
if G>=H then return false end
K=K or math.clamp(16+#tostring(I)*5,42,82)
createPill(aa,I,J,{Position=UDim2.new(0,ad,0,0),Width=K,Height=18,TextSize=8,Transparency=0.88})
ad+=K+5
G+=1
return true
end
if ab.Rarity then
addBadge(ab.Rarity,rarityColor(j,ab.Rarity))
elseif ab.Category then
addBadge(ab.Category,j:Get"Info")
end
if ab.Equipped==true or ab.IsEquipped==true then addBadge("EQUIPPED",j:Get"Success",62)end
if ab.Locked==true or ab.IsLocked==true then addBadge("LOCKED",j:Get"Warning",50)end
if G<H and type(ab.Tags)=="table"then
for I,J in ipairs(ab.Tags)do
if G>=H then break end
addBadge(tostring(J),j:Get"MutedText")
end
end
end
local function createCard(aa,ab)
local ac=C._layoutMode=="Grid"
local ad=C.SelectedId==aa.Id
local G=ac and(i.CardHeight or 184)or(i.RowHeight or 84)
local H=c.Create("Frame",{
Name="Item_"..tostring(aa.Id),LayoutOrder=ab,
BackgroundColor3=ad and j:Get"AccentSoft"or j:Get"Surface",
BorderSizePixel=0,Size=ac and UDim2.new(0.333,-8,0,G)or UDim2.new(1,-6,0,G),
ClipsDescendants=true,
},w)
c.Corner(H,10)
local I=c.Stroke(H,ad and j:Get"Accent"or j:Get"BorderSubtle",ad and 0.10 or 0.42,1)

local J=c.Create("TextButton",{Name="SelectItem",BackgroundTransparency=1,
BorderSizePixel=0,Size=UDim2.fromScale(1,1),Text="",AutoButtonColor=false,ZIndex=1},H)
table.insert(C._rowItems,H)
local K=aa.Image
local L=inferIcon(aa)
local M,N
if ac then
M=c.Create("Frame",{Name="Artwork",Position=UDim2.new(0,0,0,0),
Size=UDim2.new(1,0,0,74),BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,ClipsDescendants=true},H)
if K~=nil and K~=""then
N=d.Create(M,K,{Size=UDim2.fromScale(1,1),Position=UDim2.fromScale(0,0),
Color=Color3.new(1,1,1),Fallback=false,ScaleType=i.ImageScaleType or Enum.ScaleType.Crop})
else
c.Create("UIGradient",{Color=ColorSequence.new(j:Get"SurfaceRaised",j:Get"SurfaceInset"),Rotation=25},M)
c.Create("Frame",{Name="RarityRule",AnchorPoint=Vector2.new(0,1),
Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,2),BackgroundColor3=rarityColor(j,aa.Rarity),
BackgroundTransparency=aa.Rarity and 0.2 or 0.68,BorderSizePixel=0},M)
local O=c.Create("Frame",{Name="IconTile",AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromScale(0.5,0.48),Size=UDim2.fromOffset(48,48),BackgroundColor3=j:Get"SurfaceInset",
BackgroundTransparency=0.20,BorderSizePixel=0},M)
c.Corner(O,14);c.Stroke(O,rarityColor(j,aa.Rarity),0.66,1)
d.Create(O,L,{Size=UDim2.fromOffset(26,26),Position=UDim2.new(0.5,-13,0.5,-13),
Color=iconColor(aa,j),Fallback="item",TextSize=26})
end
if aa.Amount~=nil then
createPill(H,"×"..tostring(aa.Amount),j:Get"Text",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-7,0,7),Width=38,Height=19,TextSize=9,Transparency=0.16})
end
createFavoriteButton(H,aa,true)
local O=c.Label(H,"Name",aa.Name,
UDim2.new(1,-20,0,18),UDim2.new(0,10,0,81),j:Get"Text",11,true)
O.TextTruncate=Enum.TextTruncate.AtEnd
local P=c.Label(H,"Description",aa.Description~=""and aa.Description or tostring(aa.Category or""),
UDim2.new(1,-20,0,25),UDim2.new(0,10,0,101),j:Get"MutedText",9,false)
P.TextTruncate=Enum.TextTruncate.AtEnd;P.TextYAlignment=Enum.TextYAlignment.Top
local Q=c.Create("Frame",{Name="Tags",Position=UDim2.new(0,10,0,130),Size=UDim2.new(1,-20,0,18),
BackgroundTransparency=1,BorderSizePixel=0},H)
createTags(Q,aa,"Grid")
local R=valueText(aa)
if R then
local S=c.Label(H,"Value",R,UDim2.new(0.46,-12,0,18),UDim2.new(0,10,1,-25),j:Get"Accent",10,true)
S.TextTruncate=Enum.TextTruncate.AtEnd
end
local S=aa.ActionText or i.ActionText
if S then createAction(H,aa,S,UDim2.new(1,-78,1,-29),UDim2.fromOffset(68,22))end
local T=c.Create("TextButton",{Name="Details",Position=UDim2.new(1,S and-109 or-35,1,-29),
Size=UDim2.fromOffset(24,22),BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,
Text="",AutoButtonColor=false},H)
c.Corner(T,7);c.Stroke(T,j:Get"BorderSubtle",0.48,1)
d.Create(T,"info",{Size=UDim2.fromOffset(13,13),Position=UDim2.new(0.5,-6.5,0.5,-6.5),
Color=j:Get"MutedText",TextSize=13})
addConnection(T.Activated:Connect(function()openDetails(aa)end))
if type(aa.Actions)=="table"then
for U,V in ipairs(aa.Actions)do
if U<=2 and type(V)=="table"then
local W=c.Create("TextButton",{Name="ExtraAction",AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-((C._showFavorite and 40 or 7)+(U-1)*29),0,7),
Size=UDim2.fromOffset(25,25),BackgroundColor3=j:Get"SurfaceInset",BorderSizePixel=0,
Text="",AutoButtonColor=false},H)
c.Corner(W,8);c.Stroke(W,j:Get"BorderSubtle",0.35,1)
d.Create(W,V.Icon or V.Name or"more",{Size=UDim2.fromOffset(13,13),
Position=UDim2.new(0.5,-6.5,0.5,-6.5),Color=j:Get"Text",Fallback="item",TextSize=13})
addConnection(W.Activated:Connect(function()
if C.Enabled and type(V.Callback)=="function"then task.spawn(V.Callback,table.clone(aa),C)end
end))
end
end
end
else
M=c.Create("Frame",{Name="Artwork",Position=UDim2.new(0,10,0.5,-28),
Size=UDim2.fromOffset(56,56),BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,ClipsDescendants=true},H)
c.Corner(M,9)
if K~=nil and K~=""then
d.Create(M,K,{Size=UDim2.fromScale(1,1),Position=UDim2.fromScale(0,0),Color=Color3.new(1,1,1),Fallback=false,
ScaleType=i.ImageScaleType or Enum.ScaleType.Crop})
else
d.Create(M,L,{Size=UDim2.fromOffset(28,28),Position=UDim2.new(0.5,-14,0.5,-14),
Color=iconColor(aa,j),Fallback="item",TextSize=28})
end
local O=78
local P=(aa.ActionText or i.ActionText)and 100 or 14
local Q=c.Label(H,"Name",aa.Name,UDim2.new(1,-(O+P),0,18),UDim2.new(0,O,0,11),j:Get"Text",12,true)
Q.TextTruncate=Enum.TextTruncate.AtEnd
local R=aa.Description
local S=metadataText(aa)
if S~=""then R=R~=""and(R.."  ·  "..S)or S end
local T=c.Label(H,"Description",R,UDim2.new(1,-(O+P),0,16),UDim2.new(0,O,0,32),j:Get"MutedText",10,false)
T.TextTruncate=Enum.TextTruncate.AtEnd
local U=c.Create("Frame",{Name="Tags",Position=UDim2.new(0,O,0,52),Size=UDim2.new(1,-(O+P),0,18),
BackgroundTransparency=1,BorderSizePixel=0},H)
createTags(U,aa,"List")
local V=valueText(aa)
if V then
local W=c.Label(H,"Value",V,UDim2.new(0,140,0,15),UDim2.new(0,O,1,-20),j:Get"Accent",10,true)
W.TextTruncate=Enum.TextTruncate.AtEnd
end
createFavoriteButton(H,aa,true)
local W=aa.ActionText or i.ActionText
if W then createAction(H,aa,W,UDim2.new(1,-82,1,-31),UDim2.fromOffset(72,24))end
local X=c.Create("TextButton",{Name="Details",Position=UDim2.new(1,W and-111 or-38,1,-31),
Size=UDim2.fromOffset(24,24),BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,
Text="",AutoButtonColor=false},H)
c.Corner(X,7);c.Stroke(X,j:Get"BorderSubtle",0.48,1)
d.Create(X,"info",{Size=UDim2.fromOffset(13,13),Position=UDim2.new(0.5,-6.5,0.5,-6.5),
Color=j:Get"MutedText",TextSize=13})
addConnection(X.Activated:Connect(function()openDetails(aa)end))
end

J.ZIndex=1
for O,P in ipairs(H:GetChildren())do
if P:IsA"GuiObject"and P~=J then
P.ZIndex=math.max(P.ZIndex,2)
for Q,R in ipairs(P:GetDescendants())do
if R:IsA"GuiObject"then R.ZIndex=math.max(R.ZIndex,3)end
end
end
end
addConnection(J.Activated:Connect(function()selectItem(aa)end))
addConnection(H.MouseEnter:Connect(function()
if not C.Enabled then return end
g.Tweens:To(H,{BackgroundColor3=C.SelectedId==aa.Id and j:Get"SurfaceSelected"or j:Get"SurfaceHover"},{Time=0.12})
g.Tweens:To(I,{Color=C.SelectedId==aa.Id and j:Get"Accent"or j:Get"Border",Transparency=0.12},{Time=0.12})
end))
addConnection(H.MouseLeave:Connect(function()
if C._destroyed or not H.Parent then return end
g.Tweens:To(H,{BackgroundColor3=C.SelectedId==aa.Id and j:Get"SurfaceSelected"or j:Get"Surface"},{Time=0.12})
g.Tweens:To(I,{Color=C.SelectedId==aa.Id and j:Get"Accent"or j:Get"BorderSubtle",Transparency=C.SelectedId==aa.Id and 0.10 or 0.42},{Time=0.12})
end))
if aa.Locked==true or aa.IsLocked==true then
local O=c.Create("Frame",{Name="LockedOverlay",Size=UDim2.fromScale(1,1),
BackgroundColor3=j:Get"Background",BackgroundTransparency=0.42,BorderSizePixel=0,ZIndex=30},H)
d.Create(O,"lock",{Size=UDim2.fromOffset(20,20),Position=UDim2.new(0.5,-10,0.5,-10),
Color=j:Get"Warning",Fallback="lock",TextSize=20,ZIndex=31})
O.Active=false
end
end

local function updateGridCell()
if C._layoutMode~="Grid"then return end
local aa=w.AbsoluteSize.X
local ab=aa>=660 and 3 or(aa>=390 and 2 or 1)
local ac=math.max(145,(aa-(ab-1)*8-14)/ab)
x.CellSize=UDim2.new(0,ac,0,i.CardHeight or 184)
x.CellPadding=UDim2.fromOffset(8,8)
end

local function rebuildFilters()
disconnectConnections(C._filterConnections)
for aa,ab in ipairs(C._filterButtons)do if ab.Parent then ab:Destroy()end end
table.clear(C._filterButtons)
if not u.Visible then return end
local aa,ab={"All"},{All=true}
for ac,ad in ipairs(C.Items)do
for G,H in ipairs{ad.Category,ad.Rarity}do
if H~=nil and not ab[tostring(H)]then
ab[tostring(H)]=true
aa[#aa+1]=tostring(H)
end
end
end
table.sort(aa,function(ac,ad)if ac=="All"then return true elseif ad=="All"then return false else return string.lower(ac)<string.lower(ad)end end)
for ac,ad in ipairs(aa)do
local G=(ad=="All"and C._chipFilter==nil)or ad==C._chipFilter
local H=c.Create("TextButton",{Name="Filter_"..ad,LayoutOrder=ac,
Size=UDim2.fromOffset(math.clamp(20+#ad*6,44,110),24),BackgroundColor3=G and j:Get"AccentSoft"or j:Get"Surface",
BorderSizePixel=0,Text=ad,TextColor3=G and j:Get"Accent"or j:Get"MutedText",
TextSize=9,Font=Enum.Font.GothamSemibold,AutoButtonColor=false},u)
c.Corner(H,7)
if G then c.Stroke(H,j:Get"Accent",0.48,1)else c.Stroke(H,j:Get"BorderSubtle",0.48,1)end
table.insert(C._filterButtons,H)
table.insert(C._filterConnections,H.Activated:Connect(function()
if ad=="All"then C._chipFilter=nil else C._chipFilter=ad end
C._displayCount=C._maxRender
rebuildFilters();D()
end))
end
end

D=function()
if C._destroyed then return end
disconnectRows()
local aa=getRows()
local ab=math.min(#aa,C._displayCount)
y.Visible=#aa==0
w.Visible=#aa>0
for ac=1,ab do createCard(aa[ac],ac)end
if#aa>ab then
local ac=c.Create("TextButton",{Name="LoadMore",LayoutOrder=ab+1,
Size=C._layoutMode=="Grid"and UDim2.new(1,-8,0,32)or UDim2.new(1,-6,0,32),
BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,
Text="Show more   ·   "..tostring(#aa-ab).." remaining",
Font=Enum.Font.GothamSemibold,TextSize=10,TextColor3=j:Get"Accent",AutoButtonColor=false,
},w)
c.Corner(ac,8);c.Stroke(ac,j:Get"BorderSubtle",0.45,1)
table.insert(C._rowItems,ac)
addConnection(ac.Activated:Connect(function()
if C._destroyed then return end
C._displayCount=math.min(#aa,C._displayCount+C._maxRender)
D()
end))
end
updateGridCell()
end

local function setLayout(aa)
aa=aa=="List"and"List"or"Grid"
if aa==C._layoutMode then return end
C._layoutMode=aa
if x and x.Parent then x:Destroy()end
if t and t.Parent then t:Destroy()end
if aa=="Grid"then
x=c.Create("UIGridLayout",{Name="GridLayout",SortOrder=Enum.SortOrder.LayoutOrder,
CellSize=UDim2.new(0,200,0,i.CardHeight or 184),CellPadding=UDim2.fromOffset(8,8)},w)
t=d.Create(s,"list",{Name="Icon",Size=UDim2.fromOffset(16,16),Position=UDim2.new(0.5,-8,0.5,-8),Color=j:Get"Text",Fallback="list",TextSize=16})
else
x=c.Create("UIListLayout",{Name="ListLayout",SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,7)},w)
t=d.Create(s,"grid",{Name="Icon",Size=UDim2.fromOffset(16,16),Position=UDim2.new(0.5,-8,0.5,-8),Color=j:Get"Text",Fallback="grid",TextSize=16})
end
C._displayCount=C._maxRender
D()
end

C:Connect(q:GetPropertyChangedSignal"Text",function()
C.SearchText=q.Text
C._displayCount=C._maxRender
D()
end)
C:Connect(q.Focused,function()g.Tweens:To(p,{Color=j:Get"Accent",Transparency=0.05},{Time=0.12})end)
C:Connect(q.FocusLost,function()g.Tweens:To(p,{Color=j:Get"BorderSubtle",Transparency=0.28},{Time=0.12})end)
C:Connect(s.Activated,function()setLayout(C._layoutMode=="Grid"and"List"or"Grid")end)
C:Connect(r.Activated,function()
if#C._sortFields==0 then return end
if C._sortIndex>=#C._sortFields then C._sortIndex=1 else C._sortIndex+=1 end
setSortKey(C._sortFields[C._sortIndex],false)
D()
end)
C:Connect(r.MouseButton2Click,function()
setSortKey(C.SortBy,not C._sortDescending)
D()
end)
C:Connect(w:GetPropertyChangedSignal"AbsoluteSize",updateGridCell)
C._search=q
C._list=w
C._toolbar=n
C._empty=y

function C.SetItems(aa,ab)
assert(not aa._destroyed,"Catalog destruido")
aa.Items=normalize(ab)
aa.SelectedId=nil
aa._displayCount=aa._maxRender
rebuildFilters()
D()
end
function C.GetItems(aa)
local ab={}
for ac,ad in ipairs(aa.Items)do ab[ac]=table.clone(ad)end
return ab
end
function C.GetItem(aa,ab)
for ac,ad in ipairs(aa.Items)do if ad.Id==ab then return table.clone(ad)end end
return nil
end
function C.SetSearch(aa,ab)
aa.SearchText=tostring(ab or"");aa._displayCount=aa._maxRender
if q.Text~=aa.SearchText then q.Text=aa.SearchText else D()end
end
function C.SetFilter(aa,ab)
aa.Filter=ab;aa._displayCount=aa._maxRender;D()
end
function C.SetCategoryFilter(aa,ab)
if ab=="All"then aa._chipFilter=nil else aa._chipFilter=ab end
aa._displayCount=aa._maxRender;rebuildFilters();D()
end
function C.SetSort(aa,ab,ac)
assert(type(ab)=="string","SetSort espera una clave de ordenación")
setSortKey(ab,ac);aa._displayCount=aa._maxRender;D()
end
function C.SetLayout(aa,ab)setLayout(ab)end
function C.GetLayout(aa)return aa._layoutMode end
function C.GetSelected(aa)
for ab,ac in ipairs(aa.Items)do if ac.Id==aa.SelectedId then return table.clone(ac)end end
return nil
end
function C.Select(aa,ab,ac)
for ad,G in ipairs(aa.Items)do
if G.Id==ab then
aa.SelectedId=ab;D()
if ac==true and type(aa._onSelect)=="function"then task.spawn(aa._onSelect,table.clone(G),aa)end
return true
end
end
return false
end
function C.SetFavorite(aa,ab,ac)
for ad,G in ipairs(aa.Items)do if G.Id==ab then setFavorite(G,ac);return true end end
return false
end
function C.OpenDetails(aa,ab)
for ac,ad in ipairs(aa.Items)do if ad.Id==ab or tostring(ad.Id)==tostring(ab)then return openDetails(ad)end end
return false
end
function C.CloseDetails(aa)
if not E then return false end
clearDetails();return true
end
function C.GetDetailsOpen(aa)return E~=nil end
function C.GetFavorites(aa)
local ab={}
for ac,ad in ipairs(aa.Items)do if itemIsFavorite(ad)then ab[#ab+1]=table.clone(ad)end end
return ab
end
function C.SetEnabled(aa,ab)
b.SetEnabled(aa,ab)
q.TextEditable=aa.Enabled;r.Active=aa.Enabled;s.Active=aa.Enabled
for ac,ad in ipairs(aa._rowItems)do if ad:IsA"GuiObject"then ad.Active=aa.Enabled end end
end
function C.Destroy(aa)
if aa._destroyed then return end
clearDetails()
disconnectRows();disconnectConnections(aa._filterConnections)
b.Destroy(aa)
end

updateSortText()
C:SetItems(i.Items or{})
return C
end

return e end function a.I():typeof(__modImpl())local aa=a.cache.I if not aa then aa={c=__modImpl()}a.cache.I=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac={};ac.__index=ac;setmetatable(ac,{__index=aa})
local function normalize(ad)
if type(ad)~="table"then return{Value=ad,Text=tostring(ad),Disabled=false}end
local b=ad.Value;if b==nil then b=ad.Text end
assert(b~=nil,"RadioGroup option necesita Value o Text")
return{Value=b,Text=tostring(ad.Text or b),Description=ad.Description,Disabled=ad.Disabled==true}
end
function ac.new(ad,b,c)
c=c or{};local d=ad.Theme;local e=c.Callback
assert(e==nil or type(e)=="function","Callback debe ser función")
local f=ab.Create("Frame",{Name=c.Name or"RadioGroup",BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},b)
ab.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,c.Spacing or 4),
FillDirection=c.Direction=="Horizontal"and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical},f)
local g=setmetatable({},ac);aa.Initialize(g,ad,f);g.Options={};g._buttons={};g._value=c.Value
if c.Title then ab.Label(f,"Title",tostring(c.Title),UDim2.new(1,0,0,20),UDim2.new(),d:Get"Text",12,true).LayoutOrder=0 end
local function update()
for h,i in ipairs(g._buttons)do
local j=i.Option.Value==g._value
i.Dot.BackgroundColor3=j and d:Get"Accent"or d:Get"SurfaceRaised"
i.Stroke.Transparency=j and 0 or 1
i.Label.TextColor3=i.Option.Disabled and d:Get"Disabled"or d:Get"Text"
end
end
function g.SetValue(h,i,j)
if h._destroyed then return end
local k=false
for l,m in ipairs(h.Options)do if m.Value==i and not m.Disabled then k=true;break end end
assert(k or i==nil,"Valor no válido para RadioGroup: "..tostring(i))
local l=h._value~=i;h._value=i;update()
if l and j==true and e then task.spawn(e,i,h)end
end
function g.GetValue(h)return h._value end
function g.SetOptions(h,i)
assert(type(i)=="table","SetOptions espera tabla")
for j,k in ipairs(h._buttons)do if k.Frame.Parent then k.Frame:Destroy()end end
table.clear(h.Options);table.clear(h._buttons)
for j,k in ipairs(i)do
local l=normalize(k)
for m,n in ipairs(h.Options)do assert(n.Value~=l.Value,"RadioGroup contiene valores duplicados")end
table.insert(h.Options,l)
local m=ab.Create("TextButton",{Name="Radio_"..tostring(j),BackgroundColor3=d:Get"Surface",BorderSizePixel=0,
Size=c.Direction=="Horizontal"and UDim2.new(0,c.OptionWidth or 130,0,34)or UDim2.new(1,0,0,l.Description and 49 or 34),
Text="",AutoButtonColor=false,LayoutOrder=j},f)
ab.Corner(m,6)
local n=ab.Create("Frame",{Name="Dot",BackgroundColor3=d:Get"SurfaceRaised",BorderSizePixel=0,
Position=UDim2.new(0,9,0,l.Description and 14 or 10),Size=UDim2.fromOffset(14,14)},m);ab.Corner(n,10)
local o=ab.Stroke(n,d:Get"Accent",1,2)
local p=ab.Label(m,"Label",l.Text,UDim2.new(1,-38,0,l.Description and 19 or 34),UDim2.new(0,31,0,0),d:Get"Text",11,true)
if l.Description then ab.Label(m,"Description",tostring(l.Description),UDim2.new(1,-38,0,16),UDim2.new(0,31,0,23),d:Get"MutedText",9)end
local q={Option=l,Frame=m,Dot=n,Stroke=o,Label=p};table.insert(h._buttons,q)
h:Connect(m.Activated,function()if h.Enabled and not l.Disabled then h:FocusWindow();h:SetValue(l.Value,true)end end)
m.Active=not l.Disabled
end
if h._value~=nil then
local j=false;for k,l in ipairs(h.Options)do if l.Value==h._value and not l.Disabled then j=true end end
if not j then h._value=nil end
end
update()
end
g:SetOptions(c.Options or{})
return g
end
return ac end function a.J():typeof(__modImpl())local aa=a.cache.J if not aa then aa={c=__modImpl()}a.cache.J=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac=a.c()
local ad={};ad.__index=ad;setmetatable(ad,{__index=aa})
function ad.new(b,c,d)
d=d or{};local e=b.Theme
local f,g=ac.Range(d.Min,d.Max,0,100);assert(g>f,"RangeSlider Max debe ser mayor que Min")
local h=tonumber(d.Step)or 1;assert(h>0,"Step debe ser positivo")
local i=math.clamp(tonumber(d.MinValue)or f,f,g)
local j=math.clamp(tonumber(d.MaxValue)or g,f,g)
if i>j then i,j=j,i end
local k=ab.Create("Frame",{Name=d.Name or"RangeSlider",BackgroundTransparency=1,Size=UDim2.new(1,0,0,58)},c)
ab.Label(k,"Title",tostring(d.Title or"Range"),UDim2.new(0.65,0,0,18),UDim2.new(),e:Get"Text",12,true)
local l=ab.Label(k,"Value","",UDim2.new(0.35,0,0,18),UDim2.new(0.65,0,0,0),e:Get"MutedText",10)
l.TextXAlignment=Enum.TextXAlignment.Right
local m=ab.Create("Frame",{Name="Track",BackgroundColor3=e:Get"Border",BorderSizePixel=0,Position=UDim2.new(0,4,0,34),Size=UDim2.new(1,-8,0,5)},k);ab.Corner(m,4)
local n=ab.Create("Frame",{Name="SelectedRange",BackgroundColor3=e:Get"Accent",BorderSizePixel=0,Size=UDim2.new(1,0,1,0)},m);ab.Corner(n,4)
local function makeHandle(o)
local p=ab.Create("TextButton",{Name=o,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),
Size=UDim2.fromOffset(14,14),BackgroundColor3=e:Get"Text",BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=3},m)
ab.Corner(p,9);ab.Stroke(p,e:Get"Accent",0,2);return p
end
local o,p=makeHandle"MinimumHandle",makeHandle"MaximumHandle"
local q=setmetatable({},ad);aa.Initialize(q,b,k)
q.MinValue,q.MaxValue=i,j;q._min,q._max,q._step,q._callback=f,g,h,d.Callback
local function snap(r)return math.clamp(f+math.floor((r-f)/h+0.5)*h,f,g)end
local function update()
local r,s=(q.MinValue-f)/(g-f),(q.MaxValue-f)/(g-f)
o.Position=UDim2.new(r,0,0.5,0);p.Position=UDim2.new(s,0,0.5,0)
n.Position=UDim2.new(r,0,0,0);n.Size=UDim2.new(math.max(0,s-r),0,1,0)
l.Text=tostring(q.MinValue).." – "..tostring(q.MaxValue)
end
function q.GetValue(r)return r.MinValue,r.MaxValue end
function q.SetValue(r,s,t,u)
if r._destroyed then return end
s=snap(tonumber(s)or r.MinValue);t=snap(tonumber(t)or r.MaxValue)
if s>t then s,t=t,s end
local v=s~=r.MinValue or t~=r.MaxValue;r.MinValue,r.MaxValue=s,t;update()
if v and u==true and type(r._callback)=="function"then task.spawn(r._callback,s,t,r)end
end
local function beginDrag(r,s,t)
if not q.Enabled then return end
q:FocusWindow()
local u=b.Services.UserInputService
local v,w
local function setFromX(x)
local y=math.max(m.AbsoluteSize.X,1)
local z=math.clamp((x-m.AbsolutePosition.X)/y,0,1)
local A=snap(f+z*(g-f))
if s then q:SetValue(math.min(A,q.MaxValue),q.MaxValue,true)
else q:SetValue(q.MinValue,math.max(A,q.MinValue),true)end
end
setFromX(t.Position.X)
v=u.InputChanged:Connect(function(x)
if x.UserInputType==Enum.UserInputType.MouseMovement or x.UserInputType==Enum.UserInputType.Touch then setFromX(x.Position.X)end
end)
w=u.InputEnded:Connect(function(x)
if x.UserInputType==Enum.UserInputType.MouseButton1 or x.UserInputType==Enum.UserInputType.Touch then
if v then v:Disconnect();q._cleanup:Remove(v,false)end;if w then w:Disconnect();q._cleanup:Remove(w,false)end
end
end)
q._cleanup:Add(v);q._cleanup:Add(w)
end
q:Connect(o.InputBegan,function(r)if r.UserInputType==Enum.UserInputType.MouseButton1 or r.UserInputType==Enum.UserInputType.Touch then beginDrag(o,true,r)end end)
q:Connect(p.InputBegan,function(r)if r.UserInputType==Enum.UserInputType.MouseButton1 or r.UserInputType==Enum.UserInputType.Touch then beginDrag(p,false,r)end end)
function q.SetEnabled(r,s)aa.SetEnabled(r,s);o.Active=r.Enabled;p.Active=r.Enabled;o.BackgroundTransparency=r.Enabled and 0 or 0.5;p.BackgroundTransparency=o.BackgroundTransparency end
update();q:SetEnabled(d.Enabled~=false);return q
end
return ad end function a.K():typeof(__modImpl())local aa=a.cache.K if not aa then aa={c=__modImpl()}a.cache.K=aa end return aa.c end end do local function __modImpl()

local aa=a.r()
local ab={}
function ab.new(ac,ad,b)
b=table.clone(b or{})
b.Name=b.Name or"TextArea"
b.MultiLine=true
b.Height=b.Height or(b.Description and 138 or 118)
b.InputHeight=b.InputHeight or(b.Description and 56 or 62)
b.Title=b.Title or"Text area"
return aa.new(ac,ad,b)
end
return ab end function a.L():typeof(__modImpl())local aa=a.cache.L if not aa then aa={c=__modImpl()}a.cache.L=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac={};ac.__index=ac;setmetatable(ac,{__index=aa})
local function toHex(ad)
return string.format("#%02X%02X%02X",math.floor(ad.R*255+0.5),math.floor(ad.G*255+0.5),math.floor(ad.B*255+0.5))
end
local function fromHex(ad)
ad=string.gsub(ad,"#","")
if#ad~=6 or not string.match(ad,"^%x%x%x%x%x%x$")then return nil end
return Color3.fromRGB(tonumber(string.sub(ad,1,2),16),tonumber(string.sub(ad,3,4),16),tonumber(string.sub(ad,5,6),16))
end
function ac.new(ad,b,c)
c=c or{};local d=ad.Theme;local e=c.Callback
assert(e==nil or type(e)=="function","Callback debe ser función")
local f=typeof(c.Value)=="Color3"and c.Value or Color3.fromRGB(104,164,255)
local g=ab.Create("Frame",{Name=c.Name or"ColorPicker",BackgroundColor3=d:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,c.Height or 54)},b)
ab.Corner(g,d:Get"CornerRadius")
local h=ab.Label(g,"Title",tostring(c.Title or"Color"),UDim2.new(1,-110,0,20),UDim2.new(0,10,0,5),d:Get"Text",12,true)
local i=ab.Create("TextButton",{Name="Swatch",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),
Size=UDim2.fromOffset(35,28),BackgroundColor3=f,BorderSizePixel=0,Text="",AutoButtonColor=false},g)
ab.Corner(i,6);ab.Stroke(i,d:Get"Border",0,1)
local j=ab.Create("TextBox",{Name="HexInput",Position=UDim2.new(0,10,0,27),Size=UDim2.new(1,-65,0,20),
BackgroundColor3=d:Get"Background",BorderSizePixel=0,Text=toHex(f),ClearTextOnFocus=false,
Font=Enum.Font.Code,TextSize=11,TextColor3=d:Get"Text",
TextXAlignment=Enum.TextXAlignment.Left},g)
ab.Corner(j,4);ab.Padding(j,6,3,0,0)
local k=setmetatable({},ac);aa.Initialize(k,ad,g);k.TitleObject=h;k._value=f;k._swatch=i;k._hex=j;k._callback=e
function k.GetValue(l)return l._value end
function k.SetValue(l,m,n)
if l._destroyed then return end
assert(typeof(m)=="Color3","ColorPicker:SetValue espera Color3")
local o=m~=l._value;l._value=m;i.BackgroundColor3=m;j.Text=toHex(m)
if o and n==true and l._callback then task.spawn(l._callback,m,l)end
end
k:Connect(i.Activated,function()
if not k.Enabled then return end

j:CaptureFocus();k:FocusWindow()
end)
k:Connect(j.FocusLost,function()
local l=fromHex(j.Text)
if l then k:SetValue(l,true)else j.Text=toHex(k._value)end
end)
function k.SetEnabled(l,m)aa.SetEnabled(l,m);j.TextEditable=l.Enabled;i.Active=l.Enabled end
k:SetEnabled(c.Enabled~=false)
return k
end
return ac end function a.M():typeof(__modImpl())local aa=a.cache.M if not aa then aa={c=__modImpl()}a.cache.M=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac=a.k()

local ad={}
ad.__index=ad
setmetatable(ad,{__index=aa})

function ad.new(b,c,d)
d=d or{}
local e=b.Theme
local f=ab.Create("Frame",{
Name=d.Name or"EmptyState",BackgroundTransparency=1,
Size=UDim2.new(1,0,0,d.Height or(d.ActionText and 132 or 94)),
},c)

local g=ab.Create("Frame",{
Name="IconTile",AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,0),
Size=UDim2.fromOffset(d.IconTileSize or 34,d.IconTileSize or 34),
BackgroundColor3=e:Get"SurfaceRaised",BackgroundTransparency=0.26,BorderSizePixel=0,
},f)
ab.Corner(g,11)
ab.Stroke(g,e:Get"BorderSubtle",0.52,1)
local h=ac.Create(g,d.Icon or"search",{
Name="Icon",Size=UDim2.fromOffset(18,18),Position=UDim2.new(0.5,-9,0.5,-9),
Color=d.IconColor or e:Get"MutedText",Fallback="search",TextSize=18,
})

local i=42
local j=ab.Label(f,"Title",tostring(d.Title or"Nothing here yet"),
UDim2.new(1,-12,0,20),UDim2.new(0,6,0,i),e:Get"Text",12,true)
j.TextXAlignment=Enum.TextXAlignment.Center

local k=ab.Label(f,"Description",tostring(d.Description or"Items will appear here when available."),
UDim2.new(1,-24,0,30),UDim2.new(0,12,0,i+22),e:Get"MutedText",10)
k.TextXAlignment=Enum.TextXAlignment.Center
k.TextYAlignment=Enum.TextYAlignment.Top
k.TextTruncate=Enum.TextTruncate.AtEnd

local l
if type(d.ActionText)=="string"and d.ActionText~=""then
l=ab.Create("TextButton",{
Name="ActionButton",AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,i+55),
Size=UDim2.fromOffset(d.ActionWidth or math.clamp(32+#d.ActionText*6,90,210),28),
BackgroundColor3=e:Get"AccentSoft",BorderSizePixel=0,
Text=d.ActionText,TextColor3=e:Get"Accent",TextSize=10,
Font=Enum.Font.GothamSemibold,AutoButtonColor=false,
},f)
ab.Corner(l,8)
ab.Stroke(l,e:Get"Accent",0.58,1)
end

local m=setmetatable({},ad)
aa.Initialize(m,b,f)
m.TitleObject=j
m._description=k
m.IconObject=h
m.IconTile=g
m.ActionButton=l

function m.SetTitle(n,o)
if not n._destroyed then j.Text=tostring(o)end
end

function m.SetDescription(n,o)
if not n._destroyed then k.Text=tostring(o)end
end

function m.SetIcon(n,o)
if n._destroyed then return end
if h and h.Parent then h:Destroy()end
h=ac.Create(g,o or"search",{
Name="Icon",Size=UDim2.fromOffset(18,18),Position=UDim2.new(0.5,-9,0.5,-9),
Color=d.IconColor or e:Get"MutedText",Fallback="search",TextSize=18,
})
n.IconObject=h
end

function m.SetAction(n,o,p)
if n._destroyed then return end
if not l and type(o)=="string"and o~=""then
l=ab.Create("TextButton",{
Name="ActionButton",AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,i+55),
Size=UDim2.fromOffset(d.ActionWidth or math.clamp(32+#o*6,90,210),28),
BackgroundColor3=e:Get"AccentSoft",BorderSizePixel=0,
Text=o,TextColor3=e:Get"Accent",TextSize=10,
Font=Enum.Font.GothamSemibold,AutoButtonColor=false,
},f)
ab.Corner(l,8)
ab.Stroke(l,e:Get"Accent",0.58,1)
n.ActionButton=l
elseif l then
l.Text=tostring(o or"")
l.Visible=o~=nil and o~=""
end
if l then
if n._actionConnection then n._actionConnection:Disconnect();n._actionConnection=nil end
if type(p)=="function"then
n._actionConnection=n:Connect(l.Activated,function()
if n.Enabled and not n._destroyed then task.spawn(p,n)end
end)
end
end
end

if l and type(d.Callback)=="function"then
m._actionConnection=m:Connect(l.Activated,function()
if m.Enabled and not m._destroyed then task.spawn(d.Callback,m)end
end)
end

return m
end

return ad end function a.N():typeof(__modImpl())local aa=a.cache.N if not aa then aa={c=__modImpl()}a.cache.N=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac={};ac.__index=ac;setmetatable(ac,{__index=aa})
local function color(ad,b)
b=string.upper(tostring(b or"INFO"))
if b=="ERROR"then return ad:Get"Danger"end
if b=="WARN"or b=="WARNING"then return Color3.fromRGB(241,184,75)end
if b=="SUCCESS"then return ad:Get"Success"end
return ad:Get"MutedText"
end
function ac.new(ad,b,c)
c=c or{};local d=ad.Theme
local e=ab.Create("Frame",{Name=c.Name or"LogViewer",BackgroundColor3=d:Get"Background",BorderSizePixel=0,
Size=UDim2.new(1,0,0,c.Height or 190),ClipsDescendants=true},b)
ab.Corner(e,d:Get"CornerRadius");ab.Stroke(e,d:Get"Border",0.4,1)
local f=ab.Create("ScrollingFrame",{Name="Logs",BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,0,0,4),
Size=UDim2.new(1,0,1,-8),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4},e)
ab.Padding(f,8,6,3,3)
ab.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)},f)
local g=setmetatable({},ac);aa.Initialize(g,ad,e);g.Lines={};g._lineFrames={};g._maxLines=math.clamp(tonumber(c.MaxLines)or 200,10,2000);g._body=f
local function redraw()
for h,i in ipairs(g._lineFrames)do if i.Parent then i:Destroy()end end;table.clear(g._lineFrames)
for h,i in ipairs(g.Lines)do
local j=ab.Create("Frame",{Name="LogLine",LayoutOrder=h,BackgroundTransparency=1,Size=UDim2.new(1,0,0,17)},f)
ab.Label(j,"Timestamp",tostring(i.Time or""),UDim2.new(0,58,1,0),UDim2.new(),d:Get"MutedText",9)
ab.Label(j,"Level",string.upper(tostring(i.Level or"INFO")),UDim2.new(0,46,1,0),UDim2.new(0,60,0,0),color(d,i.Level),9,true)
local k=ab.Label(j,"Message",tostring(i.Message or""),UDim2.new(1,-112,1,0),UDim2.new(0,109,0,0),d:Get"Text",10)
k.TextTruncate=Enum.TextTruncate.AtEnd;table.insert(g._lineFrames,j)
end
task.defer(function()if f.Parent then f.CanvasPosition=Vector2.new(0,math.max(0,f.AbsoluteCanvasSize.Y-f.AbsoluteSize.Y))end end)
end
function g.Append(h,i,j)
if h._destroyed then return end
table.insert(h.Lines,{Time=os.date"%H:%M:%S",Level=j or"INFO",Message=tostring(i)})
while#h.Lines>h._maxLines do table.remove(h.Lines,1)end
redraw()
end
function g.SetLines(h,i)
assert(type(i)=="table","SetLines espera una tabla")
h.Lines={}
for j,k in ipairs(i)do
if type(k)=="table"then table.insert(h.Lines,{Time=tostring(k.Time or os.date"%H:%M:%S"),Level=k.Level or"INFO",Message=tostring(k.Message or k.Text or"")})
else table.insert(h.Lines,{Time=os.date"%H:%M:%S",Level="INFO",Message=tostring(k)})end
end
while#h.Lines>h._maxLines do table.remove(h.Lines,1)end;redraw()
end
function g.GetLines(h)local i={};for j,k in ipairs(h.Lines)do i[j]=table.clone(k)end;return i end
function g.Clear(h)h.Lines={};redraw()end
g:SetLines(c.Lines or{})
return g
end
return ac end function a.O():typeof(__modImpl())local aa=a.cache.O if not aa then aa={c=__modImpl()}a.cache.O=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac=a.k()
local ad={};ad.__index=ad;setmetatable(ad,{__index=aa})

local function copyNode(b,c,d)
if type(b)=="string"or type(b)=="number"then b={Name=tostring(b)}end
assert(type(b)=="table","Cada nodo debe ser una tabla, string o number")
local e=table.clone(b)
e.Name=tostring(e.Name or e.Title or"Node")
e.Id=tostring(e.Id or e.ID or(c.."/"..e.Name))
assert(not d[e.Id],"TreeView contiene IDs duplicados: "..e.Id);d[e.Id]=true
e.Children=e.Children or{}
assert(type(e.Children)=="table","Node.Children debe ser una tabla")
local f={}
for g,h in ipairs(e.Children)do f[g]=copyNode(h,e.Id.."/"..g,d)end
e.Children=f
return e
end
local function normalize(b)
assert(type(b)=="table","Nodes debe ser una tabla")
local c,d={},{}
for e,f in ipairs(b)do d[e]=copyNode(f,"root/"..e,c)end
return d
end
function ad.new(b,c,d)
d=d or{};local e=b.Theme
local f=ab.Create("Frame",{Name=d.Name or"TreeView",BackgroundColor3=e:Get"Surface",BorderSizePixel=0,
Size=UDim2.new(1,0,0,d.Height or 230),ClipsDescendants=true},c)
ab.Corner(f,e:Get"CornerRadius");ab.Stroke(f,e:Get"Border",0.45,1)
local g=ab.Create("ScrollingFrame",{Name="Nodes",BackgroundTransparency=1,BorderSizePixel=0,
Position=UDim2.new(0,0,0,4),Size=UDim2.new(1,0,1,-8),CanvasSize=UDim2.new(),
AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4},f)
ab.Padding(g,5,5,3,3)
ab.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},g)
local h=setmetatable({},ad);aa.Initialize(h,b,f)
h.Nodes,h.Expanded,h.SelectedId={},{},nil;h._rows,h._connections={},{};h._onSelect=d.OnNodeSelected
local function cleanupRows()
for i,j in ipairs(h._connections)do if j.Connected then j:Disconnect()end end
table.clear(h._connections)
for i,j in ipairs(h._rows)do if j.Parent then j:Destroy()end end
table.clear(h._rows)
end
local function flatten(i,j,k)
for l,m in ipairs(i)do
k[#k+1]={Node=m,Depth=j}
if#m.Children>0 and h.Expanded[m.Id]then flatten(m.Children,j+1,k)end
end
end
local i
i=function()
if h._destroyed then return end
cleanupRows()
local j={};flatten(h.Nodes,0,j)
for k,l in ipairs(j)do
local m,n=l.Node,l.Depth
local o=h.SelectedId==m.Id
local p=ab.Create("Frame",{Name="NodeRow",LayoutOrder=k,
BackgroundColor3=o and e:Get"AccentSoft"or e:Get"Surface",
BackgroundTransparency=o and 0 or 1,BorderSizePixel=0,Size=UDim2.new(1,-3,0,29)},g)
ab.Corner(p,6)
if o then ab.Stroke(p,e:Get"Accent",0.6,1)end
table.insert(h._rows,p)
local q=n*15
local r=ab.Create("TextButton",{Name="Expand",BackgroundTransparency=1,Position=UDim2.new(0,q,0,0),
Size=UDim2.fromOffset(23,29),Text=#m.Children==0 and""or(h.Expanded[m.Id]and"⌄"or"›"),
TextColor3=e:Get"MutedText",Font=Enum.Font.GothamSemibold,TextSize=15,AutoButtonColor=false,Active=#m.Children>0},p)
local s=ab.Create("TextButton",{Name="Select",BackgroundTransparency=1,
Position=UDim2.new(0,q+24,0,0),Size=UDim2.new(1,-(q+29),1,0),Text="",
AutoButtonColor=false,Active=true},p)
local t=m.Icon or(#m.Children>0 and(h.Expanded[m.Id]and"folder"or"folder")or"file")
ac.Create(s,t,{Name="Icon",Size=UDim2.fromOffset(15,15),
Position=UDim2.new(0,1,0.5,-7.5),Color=m.Color or e:Get"Accent",Fallback=#m.Children>0 and"folder"or"file",TextSize=14})
local u=ab.Label(s,"Name",m.Name,UDim2.new(1,-24,1,0),UDim2.new(0,22,0,0),e:Get"Text",11,o)
u.TextTruncate=Enum.TextTruncate.AtEnd
table.insert(h._connections,p.MouseEnter:Connect(function()
if h.Enabled and h.SelectedId~=m.Id then b.Tweens:To(p,{BackgroundTransparency=0.45,BackgroundColor3=e:Get"SurfaceHover"},{Time=0.10})end
end))
table.insert(h._connections,p.MouseLeave:Connect(function()
if p.Parent and not h._destroyed and h.SelectedId~=m.Id then b.Tweens:To(p,{BackgroundTransparency=1,BackgroundColor3=e:Get"Surface"},{Time=0.10})end
end))
table.insert(h._connections,r.Activated:Connect(function()
if h._destroyed or#m.Children==0 then return end
h.Expanded[m.Id]=not h.Expanded[m.Id];i()
end))
table.insert(h._connections,s.Activated:Connect(function()
if h._destroyed then return end
h.SelectedId=m.Id;h:FocusWindow();i()
if type(h._onSelect)=="function"then task.spawn(h._onSelect,table.clone(m),h)end
end))
end
end
function h.SetNodes(j,k)
assert(not j._destroyed,"TreeView destruido")
j.Nodes=normalize(k);j.Expanded={}
local function seed(l)
for m,n in ipairs(l)do
if n.Expanded==true or d.ExpandAll==true then j.Expanded[n.Id]=true end
seed(n.Children)
end
end
seed(j.Nodes);j.SelectedId=nil;i()
end
function h.GetNodes(j)return normalize(j.Nodes)end
function h.SetExpanded(j,k,l)if j._destroyed then return false end;j.Expanded[tostring(k)]=l==true;i();return true end
function h.ExpandAll(j)
local function visit(k)for l,m in ipairs(k)do if#m.Children>0 then j.Expanded[m.Id]=true end;visit(m.Children)end end
visit(j.Nodes);i()
end
function h.CollapseAll(j)table.clear(j.Expanded);i()end
function h.Select(j,k,l)
local m
local function visit(n)for o,p in ipairs(n)do if p.Id==tostring(k)then m=p;return end;visit(p.Children);if m then return end end end
visit(j.Nodes);if not m then return false end
j.SelectedId=m.Id;i();if l==true and type(j._onSelect)=="function"then task.spawn(j._onSelect,table.clone(m),j)end;return true
end
function h.GetSelected(j)
local k;local function visit(l)for m,n in ipairs(l)do if n.Id==j.SelectedId then k=n;return end;visit(n.Children);if k then return end end end
visit(j.Nodes);return k and table.clone(k)or nil
end
function h.Destroy(j)if j._destroyed then return end;cleanupRows();aa.Destroy(j)end
h:SetNodes(d.Nodes or{})
return h
end
return ad end function a.P():typeof(__modImpl())local aa=a.cache.P if not aa then aa={c=__modImpl()}a.cache.P=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac=a.k()

local ad={}
ad.__index=ad
setmetatable(ad,{__index=aa})

local b={
common=Color3.fromRGB(151,162,181),uncommon=Color3.fromRGB(79,199,132),
rare=Color3.fromRGB(89,165,255),epic=Color3.fromRGB(177,113,255),
legendary=Color3.fromRGB(255,174,83),mythic=Color3.fromRGB(255,93,128),
}

local function inferIcon(c)
if c.Icon then return c.Icon end
local d=string.lower(tostring(c.Category or"").." "..tostring(c.Name or c.Title or""))
if d:find("pet",1,true)or d:find("animal",1,true)then return"paw"end
if d:find("sword",1,true)or d:find("weapon",1,true)then return"sword"end
if d:find("gem",1,true)or d:find("crystal",1,true)then return"gem"end
if d:find("coin",1,true)or d:find("gold",1,true)then return"coins"end
if d:find("potion",1,true)then return"potion"end
return"item"
end

function ad.new(c,d,e)
e=e or{}
local f=c.Theme
local g=math.clamp(tonumber(e.Height)or 168,104,360)
local h=ab.Create("Frame",{Name=e.Name or"Carousel",BackgroundTransparency=1,
Size=UDim2.new(1,0,0,g)},d)
local i
if e.Title then
i=ab.Label(h,"Title",tostring(e.Title),UDim2.new(1,0,0,21),UDim2.new(),f:Get"Text",12,true)
i.TextTruncate=Enum.TextTruncate.AtEnd
end
local j=ab.Create("ScrollingFrame",{Name="Items",BackgroundTransparency=1,BorderSizePixel=0,
Position=UDim2.new(0,0,0,i and 25 or 0),Size=UDim2.new(1,0,1,i and-25 or 0),
CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=3,
ScrollBarImageColor3=f:Get"Border",ScrollingDirection=Enum.ScrollingDirection.X},h)
ab.Create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,8),VerticalAlignment=Enum.VerticalAlignment.Center},j)
ab.Padding(j,2,8,2,5)

local k=setmetatable({},ad)
aa.Initialize(k,c,h)
k.Items={};k.SelectedId=nil;k._rows={};k._connections={};k._onSelect=e.OnItemSelected
local function cleanupRows()
for l,m in ipairs(k._connections)do if m.Connected then m:Disconnect()end end
table.clear(k._connections)
for l,m in ipairs(k._rows)do if m.Parent then m:Destroy()end end
table.clear(k._rows)
end
local function render()
cleanupRows()
for l,m in ipairs(k.Items)do
local n=k.SelectedId==m.Id
local o=i and g-32 or g-8
local p=ab.Create("TextButton",{Name="CarouselItem",LayoutOrder=l,
Size=UDim2.fromOffset(e.CardWidth or 166,o),
BackgroundColor3=n and f:Get"AccentSoft"or f:Get"Surface",
BorderSizePixel=0,Text="",AutoButtonColor=false},j)
ab.Corner(p,10)
ab.Stroke(p,n and f:Get"Accent"or f:Get"BorderSubtle",n and 0.10 or 0.28,1)
table.insert(k._rows,p)
local q=math.clamp(tonumber(e.ImageHeight)or 66,38,math.max(38,o-60))
local r=ab.Create("Frame",{Name="Artwork",Position=UDim2.new(0,7,0,7),
Size=UDim2.new(1,-14,0,q),BackgroundColor3=f:Get"SurfaceRaised",
BorderSizePixel=0,ClipsDescendants=true},p)
ab.Corner(r,7)
local s=m.Image or m.Thumbnail or m.ThumbnailId or m.ImageId
if s~=nil and s~=""then
ac.Create(r,s,{Size=UDim2.fromScale(1,1),Position=UDim2.fromScale(0,0),
Color=Color3.new(1,1,1),Fallback=false,ScaleType=e.ImageScaleType or Enum.ScaleType.Crop})
else
ab.Create("UIGradient",{Color=ColorSequence.new(f:Get"SurfaceRaised",f:Get"AccentSoft"),Rotation=18},r)
ac.Create(r,inferIcon(m),{Size=UDim2.fromOffset(27,27),
Position=UDim2.new(0.5,-13.5,0.5,-13.5),Color=f:Get"Accent",Fallback="item",TextSize=27})
end
local t=tostring(m.Rarity or m.Quality or"")
if t~=""then
local u=b[string.lower(t)]or f:Get"Accent"
local v=math.clamp(18+#t*5,48,86)
local w=ab.Create("Frame",{Name="Rarity",Position=UDim2.new(0,6,0,6),
Size=UDim2.fromOffset(v,17),BackgroundColor3=u,BackgroundTransparency=0.16,BorderSizePixel=0},r)
ab.Corner(w,5)
local x=ab.Label(w,"Text",string.upper(t),UDim2.new(1,-8,1,0),UDim2.new(0,4,0,0),Color3.fromRGB(14,18,26),8,true)
x.TextXAlignment=Enum.TextXAlignment.Center;x.TextTruncate=Enum.TextTruncate.AtEnd
end
if m.Amount~=nil or m.Count~=nil then
local u=tostring(m.Amount or m.Count)
local v=ab.Create("Frame",{Name="Amount",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),
Size=UDim2.fromOffset(math.clamp(#u*7+12,30,56),18),BackgroundColor3=f:Get"SurfaceInset",
BackgroundTransparency=0.12,BorderSizePixel=0},r)
ab.Corner(v,5)
local w=ab.Label(v,"Text","×"..u,UDim2.fromScale(1,1),UDim2.new(),f:Get"Text",9,true)
w.TextXAlignment=Enum.TextXAlignment.Center
end
local u=14+q
local v=ab.Label(p,"Title",tostring(m.Title or m.Name or"Item"),
UDim2.new(1,-16,0,19),UDim2.new(0,8,0,u),f:Get"Text",11,true)
v.TextTruncate=Enum.TextTruncate.AtEnd
local w=ab.Label(p,"Description",tostring(m.Description or m.Category or""),
UDim2.new(1,-16,0,24),UDim2.new(0,8,0,u+20),f:Get"MutedText",9)
w.TextTruncate=Enum.TextTruncate.AtEnd;w.TextYAlignment=Enum.TextYAlignment.Top
if m.Locked==true or m.IsLocked==true then
local x=ab.Create("Frame",{Name="Locked",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-7,1,-7),
Size=UDim2.fromOffset(23,23),BackgroundColor3=f:Get"SurfaceInset",BorderSizePixel=0},p)
ab.Corner(x,7)
ac.Create(x,"lock",{Size=UDim2.fromOffset(13,13),Position=UDim2.new(0.5,-6.5,0.5,-6.5),Color=f:Get"Warning",TextSize=13})
end
table.insert(k._connections,p.MouseEnter:Connect(function()
if k.Enabled and not n then c.Tweens:To(p,{BackgroundColor3=f:Get"SurfaceHover"},{Time=0.10})end
end))
table.insert(k._connections,p.MouseLeave:Connect(function()
if p.Parent and not k._destroyed and k.SelectedId~=m.Id then c.Tweens:To(p,{BackgroundColor3=f:Get"Surface"},{Time=0.10})end
end))
table.insert(k._connections,p.Activated:Connect(function()
if not k.Enabled or k._destroyed then return end
k.SelectedId=m.Id;render()
if type(k._onSelect)=="function"then task.spawn(k._onSelect,table.clone(m),k)end
end))
end
end
function k.SetItems(l,m)
assert(type(m)=="table","SetItems espera tabla")
l.Items={};local n={}
for o,p in ipairs(m)do
if type(p)=="string"or type(p)=="number"then p={Name=tostring(p)}end
assert(type(p)=="table","Cada item del carrusel debe ser una tabla, string o number")
local q=table.clone(p);q.Id=tostring(q.Id or q.ID or q.Name or q.Title or o)
assert(not n[q.Id],"Carousel contiene IDs duplicados: "..q.Id)
n[q.Id]=true;l.Items[o]=q
end
l.SelectedId=nil;render()
end
function k.GetItems(l)
local m={};for n,o in ipairs(l.Items)do m[n]=table.clone(o)end;return m
end
function k.Select(l,m,n)
for o,p in ipairs(l.Items)do
if p.Id==tostring(m)then
l.SelectedId=p.Id;render()
if n==true and type(l._onSelect)=="function"then task.spawn(l._onSelect,table.clone(p),l)end
return true
end
end
return false
end
function k.GetSelected(l)
for m,n in ipairs(l.Items)do if n.Id==l.SelectedId then return table.clone(n)end end
return nil
end
function k.Destroy(l)
if l._destroyed then return end
cleanupRows();aa.Destroy(l)
end
k:SetItems(e.Items or{})
return k
end
return ad end function a.Q():typeof(__modImpl())local aa=a.cache.Q if not aa then aa={c=__modImpl()}a.cache.Q=aa end return aa.c end end do local function __modImpl()

local aa={
Button=a.l(),
Checkbox=a.m(),
Toggle=a.n(),
Slider=a.o(),
Dropdown=a.p(),
MultiSelect=a.q(),
TextInput=a.r(),
NumericInput=a.s(),
Label=a.t(),
Paragraph=a.u(),
Divider=a.v(),
Card=a.w(),
Progress=a.x(),
Image=a.y(),
Keybind=a.z(),
Segmented=a.A(),
Collapsible=a.B(),
Form=a.C(),
Badge=a.D(),
StatusIndicator=a.E(),
MetricCard=a.F(),
KeyValueList=a.G(),
DataTable=a.H(),
ItemCatalog=a.I(),
RadioGroup=a.J(),
RangeSlider=a.K(),
TextArea=a.L(),
ColorPicker=a.M(),
EmptyState=a.N(),
LogViewer=a.O(),
TreeView=a.P(),
Carousel=a.Q(),
}

local ab={
normal="Button",button="Button",boton="Button",toggle="Toggle",interruptor="Toggle",checkbox="Checkbox",
primarybutton="Button",secondarybutton="Button",destructivebutton="Button",actionbutton="Button",iconbutton="Button",
imagebutton="Button",textbutton="Button",closebutton="Button",expandbutton="Button",copybutton="Button",splitbutton="Button",floatingactionbutton="Button",
buttongroup="Segmented",
slider="Slider",deslizador="Slider",dropdown="Dropdown",despegable="Dropdown",
multiselect="MultiSelect",selectmultiple="MultiSelect",multiselectdropdown="MultiSelect",checkboxgroup="MultiSelect",tagselector="MultiSelect",textinput="TextInput",campo="TextInput",
numericinput="NumericInput",number="NumericInput",label="Label",etiqueta="Label",
paragraph="Paragraph",parrafo="Paragraph",divider="Divider",separador="Divider",
card="Card",tarjeta="Card",itemcard="Card",productcard="Card",gamecard="Card",informationcard="Card",profilecard="Card",selectablecard="Card",progress="Progress",progreso="Progress",image="Image",imagen="Image",
keybind="Keybind",segmented="Segmented",segmentado="Segmented",collapsible="Collapsible",
expandible="Collapsible",form="Form",formulario="Form",
badge="Badge",tag="Badge",statusindicator="StatusIndicator",status="StatusIndicator",
metriccard="MetricCard",statisticscard="MetricCard",metric="MetricCard",
keyvaluelist="KeyValueList",propertylist="KeyValueList",keyvalue="KeyValueList",
datatable="DataTable",leaderboard="DataTable",activitytable="DataTable",timeline="LogViewer",
itemcatalog="ItemCatalog",objectcatalog="ItemCatalog",inventorylist="ItemCatalog",itemlist="ItemCatalog",searchpanel="ItemCatalog",
radiogroup="RadioGroup",rangslider="RangeSlider",rangeslider="RangeSlider",range="RangeSlider",
textarea="TextArea",text_area="TextArea",colorpicker="ColorPicker",color="ColorPicker",
emptystate="EmptyState",empty="EmptyState",logviewer="LogViewer",consoleviewer="LogViewer",
treeview="TreeView",hierarchicallist="TreeView",carousel="Carousel",horizontalcarousel="Carousel",
accordion="Collapsible",collapsiblesection="Collapsible",searchabledropdown="Dropdown",progressbar="Progress",
itemcatalog="ItemCatalog",selectablegrid="ItemCatalog",selectablelist="ItemCatalog",objectgrid="ItemCatalog",
}

local ac={}
ac.__index=ac
function ac.new(ad)return setmetatable({Context=ad},ac)end
function ac.Create(ad,b,c,d,e)
assert(type(b)=="string","ComponentFactory:Create espera un tipo string")
assert(typeof(c)=="Instance","ComponentFactory:Create espera un parent Instance")
local f=string.lower(b)
local g=aa[b]and b or ab[f]
assert(g and aa[g],"Componente desconocido: "..b)
local h=e or ad.Context
assert(not(h.Framework and h.Framework._destroyed),"Harkening ya fue destruido")
local i=table.clone(d or{})
if f=="searchabledropdown"then i.Searchable=true end
if f=="multiselectdropdown"or f=="checkboxgroup"or f=="tagselector"then i.Multiple=true end
local j={primarybutton="Primary",secondarybutton="Secondary",destructivebutton="Destructive",actionbutton="Primary",closebutton="Secondary",expandbutton="Secondary",splitbutton="Secondary",floatingactionbutton="Primary",copybutton="Secondary"}
if j[f]then i.Variant=i.Variant or j[f]end
if f=="iconbutton"or f=="imagebutton"then i.IconOnly=true end
local k=aa[g].new(h,c,i)


if h.Lifecycle then h.Lifecycle:Add(k)end
return k
end
function ac.GetAvailable(ad)
local b={}
for c in pairs(aa)do table.insert(b,c)end
table.sort(b)
return b
end
return ac end function a.R():typeof(__modImpl())local aa=a.cache.R if not aa then aa={c=__modImpl()}a.cache.R=aa end return aa.c end end do local function __modImpl()

local aa={}
aa.__index=aa
function aa.new()
return setmetatable({_resources={},_destroyed=false},aa)
end
function aa.Add(ab,ac)
if not ac then return ac end
if ab._destroyed then
if ac.Destroy then ac:Destroy()end
return ac
end
ab._resources[ac]=true
return ac
end
function aa.Remove(ab,ac)
ab._resources[ac]=nil
end
function aa.Destroy(ab)
if ab._destroyed then return end
ab._destroyed=true
local ac={}
for ad in pairs(ab._resources)do table.insert(ac,ad)end
for ad=#ac,1,-1 do
local b=ac[ad]
if type(b.Destroy)=="function"then
local c,d=pcall(b.Destroy,b)
if not c then warn("[Harkening] No se pudo destruir recurso: "..tostring(d))end
end
end
table.clear(ab._resources)
end
return aa end function a.S():typeof(__modImpl())local aa=a.cache.S if not aa then aa={c=__modImpl()}a.cache.S=aa end return aa.c end end do local function __modImpl()

local aa=a.d()
local ab=a.k()
local ac={}
ac.__index=ac

local ad={
AddButton="Button",AddToggle="Toggle",AddSlider="Slider",AddDropdown="Dropdown",
AddMultiSelect="MultiSelect",AddTextInput="TextInput",AddNumericInput="NumericInput",AddLabel="Label",
AddParagraph="Paragraph",AddDivider="Divider",AddCard="Card",AddProgress="Progress",AddImage="Image",
AddKeybind="Keybind",AddSegmented="Segmented",AddCollapsible="Collapsible",AddForm="Form",AddBadge="Badge",
AddStatusIndicator="StatusIndicator",AddMetricCard="MetricCard",AddKeyValueList="KeyValueList",AddDataTable="DataTable",
AddItemCatalog="ItemCatalog",AddRadioGroup="RadioGroup",AddRangeSlider="RangeSlider",AddTextArea="TextArea",
AddColorPicker="ColorPicker",AddEmptyState="EmptyState",AddLogViewer="LogViewer",AddTreeView="TreeView",
AddCarousel="Carousel",AddCheckbox="Checkbox",AddSearchableDropdown="SearchableDropdown",AddMultiSelectDropdown="MultiSelectDropdown",
AddTagSelector="TagSelector",AddCheckboxGroup="CheckboxGroup",AddPrimaryButton="PrimaryButton",
AddSecondaryButton="SecondaryButton",AddDestructiveButton="DestructiveButton",AddIconButton="IconButton",
AddButtonGroup="ButtonGroup",AddAccordion="Accordion",AddProgressBar="Progress",
}

function ac.new(b,c,d)
d=d or{}
local e=b.Theme
local f=tostring(d.Title or d.Name or"")
local g=tostring(d.Description or"")
local h=aa.Create("Frame",{
Name=d.Name or(f~=""and f or"Section"),
BackgroundColor3=d.BackgroundColor or e:Get"Surface",
BackgroundTransparency=d.BackgroundTransparency==nil and 0.22 or d.BackgroundTransparency,
BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
ClipsDescendants=d.Collapsible==true,
},c)
aa.Corner(h,d.CornerRadius or math.max(8,e:Get"CornerRadius"-1))
local i=aa.Stroke(h,e:Get"BorderSubtle",0.64,1)
aa.Padding(h,12,12,10,12)
aa.Create("UIListLayout",{
FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,d.Spacing or 8),
},h)

local j=0
if d.Accent==true then
local k=aa.Create("Frame",{
Name="AccentRule",LayoutOrder=0,Size=UDim2.new(1,0,0,2),
BackgroundColor3=e:Get"Accent",BorderSizePixel=0,
},h)
aa.Corner(k,4)
aa.Create("UIGradient",{Color=ColorSequence.new(e:Get"Accent",e:Get"AccentSecondary"),
Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.08),NumberSequenceKeypoint.new(1,0.7)}},k)
j=1
end

local k=aa.Create("Frame",{
Name="SectionHeader",LayoutOrder=j,Size=UDim2.new(1,0,0,g~=""and 39 or 25),
BackgroundTransparency=1,BorderSizePixel=0,
},h)
local l=0
local m
if d.Icon then
m=aa.Create("Frame",{Name="IconHolder",Position=UDim2.new(0,0,0,1),Size=UDim2.fromOffset(24,24),
BackgroundColor3=e:Get"AccentSoft",BorderSizePixel=0},k)
aa.Corner(m,7)
ab.Create(m,d.Icon,{Size=UDim2.fromOffset(14,14),Position=UDim2.new(0.5,-7,0.5,-7),
Color=e:Get"Accent",Fallback="layers",TextSize=14})
l=32
end
local n=aa.Label(k,"Title",f,UDim2.new(1,-(l+(d.Collapsible and 34 or 0)),0,23),
UDim2.new(0,l,0,0),e:Get"Text",13,true)
n.TextTruncate=Enum.TextTruncate.AtEnd
local o
if g~=""then
o=aa.Label(k,"Description",g,
UDim2.new(1,-(l+(d.Collapsible and 34 or 0)),0,16),UDim2.new(0,l,0,22),e:Get"MutedText",10)
o.TextTruncate=Enum.TextTruncate.AtEnd
end
local p,q
if d.Collapsible then
p=aa.Create("TextButton",{Name="Collapse",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
Size=UDim2.fromOffset(27,25),BackgroundColor3=e:Get"SurfaceRaised",BorderSizePixel=0,
Text="",AutoButtonColor=false},k)
aa.Corner(p,7)
q=ab.Create(p,"chevron-down",{Size=UDim2.fromOffset(14,14),
Position=UDim2.new(0.5,-7,0.5,-7),Color=e:Get"MutedText",Fallback="chevron-down",TextSize=14})
end

local r=aa.Create("Frame",{
Name="Components",LayoutOrder=j+1,BackgroundTransparency=1,
Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
},h)
aa.Create("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,d.Spacing or 8)},r)

local s=setmetatable({Frame=h,Content=r,Header=k,TitleObject=n,
DescriptionObject=o,Context=b,Components={},_destroyed=false,
Expanded=d.Expanded~=false,_collapsible=d.Collapsible==true,_stroke=i,
},ac)
function s.Add(t,u,v)
assert(not t._destroyed,"No se pueden agregar componentes a una sección destruida")
local w=b.Factory:Create(u,r,v or{},b)
table.insert(t.Components,w)
if w.Frame then w.Frame.LayoutOrder=#t.Components end
if b.Window and b.Window._ApplyZIndex then b.Window:_ApplyZIndex()end
return w
end
function s.SetExpanded(t,u)
if t._destroyed or not t._collapsible then return end
t.Expanded=u==true
r.Visible=t.Expanded
if q then
local v=t.Expanded and 0 or-90
if q:IsA"GuiObject"then b.Tweens:To(q,{Rotation=v},{Time=0.13})end
end
b.Tweens:To(i,{Transparency=t.Expanded and 0.28 or 0.52},{Time=0.13})
end
function s.ToggleExpanded(t)t:SetExpanded(not t.Expanded)end
function s.SetTitle(t,u)
if t._destroyed then return end
assert(type(u)=="string","SetTitle espera string")
n.Text=u
end
function s.Destroy(t)
if t._destroyed then return end
t._destroyed=true
for u,v in ipairs(t.Components)do if v.Destroy then v:Destroy()end end
table.clear(t.Components)
if h.Parent then h:Destroy()end
end
for t,u in pairs(ad)do
local v=u
s[t]=function(w,x)return w:Add(v,x)end
end
if p then
p.Activated:Connect(function()s:ToggleExpanded()end)
s:SetExpanded(s.Expanded)
end
return s
end

return ac end function a.T():typeof(__modImpl())local aa=a.cache.T if not aa then aa={c=__modImpl()}a.cache.T=aa end return aa.c end end do local function __modImpl()

local aa=a.d()
local ab=a.a()
local ac=a.k()
local ad=a.T()

local b={}
b.__index=b

function b.new(c,d)
d=d or{}
local e,f=c.Context,c.Context.Theme
local g=tostring(d.Title or d.Name or"Tab")
local h=tostring(d.Id or g)
local i=d.Icon or ac.DefaultFor(g)

local j=aa.Create("TextButton",{
Name="Tab_"..h,Size=UDim2.new(1,0,0,39),
BackgroundColor3=f:Get"SurfaceHover",BackgroundTransparency=1,BorderSizePixel=0,
AutoButtonColor=false,Text="",LayoutOrder=#c.Tabs+1,
},c.TabButtons)
aa.Corner(j,9)
local k=aa.Stroke(j,f:Get"BorderSubtle",1,1)
local l=aa.Create("Frame",{
Name="ActiveIndicator",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
Size=UDim2.new(0,3,0,18),BackgroundColor3=f:Get"Accent",BorderSizePixel=0,
Visible=false,
},j)
aa.Corner(l,5)
local m=aa.Create("Frame",{
Name="IconHolder",Position=UDim2.new(0,8,0.5,-13),Size=UDim2.fromOffset(26,26),
BackgroundColor3=f:Get"SurfaceRaised",BackgroundTransparency=0.28,BorderSizePixel=0,
},j)
aa.Corner(m,8)
local n=ac.Create(m,i,{
Size=UDim2.fromOffset(15,15),Position=UDim2.new(0.5,-7.5,0.5,-7.5),
Color=f:Get"MutedText",Fallback="layers",TextSize=15,
})
local o=aa.Label(j,"Title",g,UDim2.new(1,-54,1,0),UDim2.new(0,43,0,0),f:Get"MutedText",11,true)
o.TextTruncate=Enum.TextTruncate.AtEnd
local p
if d.Badge~=nil then
p=aa.Create("TextLabel",{
Name="Badge",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),
Size=UDim2.fromOffset(22,18),BackgroundColor3=f:Get"AccentSoft",BorderSizePixel=0,
Text=tostring(d.Badge),TextColor3=f:Get"Accent",TextSize=9,Font=Enum.Font.GothamBold,
},j)
aa.Corner(p,6)
o.Size=UDim2.new(1,-78,1,0)
end

local q=aa.Create("ScrollingFrame",{
Name="Page_"..h,BackgroundTransparency=1,BorderSizePixel=0,
Position=UDim2.new(),Size=UDim2.fromScale(1,1),CanvasSize=UDim2.new(),
AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,
ScrollBarImageColor3=f:Get"Border",ScrollingDirection=Enum.ScrollingDirection.Y,
Visible=false,
},c.Pages)
aa.Padding(q,17,17,14,20)
aa.Create("UIListLayout",{
FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,
Padding=UDim.new(0,13),
},q)

local r=aa.Create("Frame",{
Name="PageHeader",LayoutOrder=0,BackgroundTransparency=1,
Size=UDim2.new(1,0,0,d.Description and 68 or 57),
},q)
local s=aa.Label(r,"Eyebrow",tostring(d.Eyebrow or"HARKENING  /  WORKSPACE"),
UDim2.new(1,-5,0,12),UDim2.new(0,1,0,0),f:Get"Accent",8,true)
s.TextXAlignment=Enum.TextXAlignment.Left
local t=aa.Label(r,"PageTitle",g,
UDim2.new(1,-5,0,27),UDim2.new(0,0,0,13),f:Get"Text",20,true)
t.TextTruncate=Enum.TextTruncate.AtEnd
local u
if d.Description and d.Description~=""then
u=aa.Label(r,"PageDescription",tostring(d.Description),
UDim2.new(1,-5,0,17),UDim2.new(0,1,0,42),f:Get"MutedText",10,false)
u.TextTruncate=Enum.TextTruncate.AtEnd
end
aa.Create("Frame",{
Name="HeaderDivider",Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),
BackgroundColor3=f:Get"BorderSubtle",BackgroundTransparency=0.18,BorderSizePixel=0,
},r)

local v=setmetatable({
Window=c,Context=e,Title=g,Id=h,
Button=j,Page=q,TitleObject=o,PageTitleObject=t,
PageDescriptionObject=u,Sections={},_destroyed=false,
_cleanup=ab.new(),_active=false,_buttonStroke=k,
_indicator=l,_icon=n,_iconHolder=m,
},b)

function v.AddSection(w,x)
assert(not w._destroyed,"Tab destruida")
if type(x)=="string"then x={Title=x}end
x=x or{}
local y=ad.new(e,q,x)
table.insert(w.Sections,y)
y.Frame.LayoutOrder=#w.Sections
if e.Window and e.Window._ApplyZIndex then e.Window:_ApplyZIndex()end
return y
end
function v.SetTitle(w,x)
if w._destroyed then return end
assert(type(x)=="string","SetTitle espera string")
w.Title,o.Text,t.Text=x,x,x
j.Name="Tab_"..tostring(x)
end
function v.SetDescription(w,x)
if w._destroyed then return end
assert(type(x)=="string","SetDescription espera string")
if u then u.Text=x
elseif x~=""then
u=aa.Label(r,"PageDescription",x,UDim2.new(1,-5,0,17),UDim2.new(0,1,0,42),f:Get"MutedText",10)
u.TextTruncate=Enum.TextTruncate.AtEnd
w.PageDescriptionObject=u
r.Size=UDim2.new(1,0,0,68)
end
end
function v.SetActive(w,x)
if w._destroyed then return end
w._active=x==true
j.BackgroundTransparency=w._active and 0.06 or 1
j.BackgroundColor3=w._active and(f:Get"SurfaceSelected"or f:Get"AccentSoft")or f:Get"SurfaceHover"
o.TextColor3=w._active and f:Get"Text"or f:Get"MutedText"
l.Visible=w._active
m.BackgroundColor3=f:Get"SurfaceRaised"
m.BackgroundTransparency=w._active and 0.04 or 0.28
if n then
if n:IsA"ImageLabel"then n.ImageColor3=w._active and f:Get"Accent"or f:Get"MutedText"
else n.TextColor3=w._active and f:Get"Accent"or f:Get"MutedText"end
end
q.Visible=w._active
if w._active then
e.Tweens:To(k,{Color=f:Get"Accent",Transparency=0.52},{Time=0.14})
e.Tweens:To(l,{Size=UDim2.new(0,3,0,22)},{Time=0.12})
else
e.Tweens:To(k,{Color=f:Get"BorderSubtle",Transparency=1},{Time=0.12})
e.Tweens:To(l,{Size=UDim2.new(0,3,0,14)},{Time=0.12})
end
end
function v.Destroy(w)
if w._destroyed then return end
w._destroyed=true
for x,y in ipairs(w.Sections)do y:Destroy()end
table.clear(w.Sections)
w._cleanup:Destroy()
if j.Parent then j:Destroy()end
if q.Parent then q:Destroy()end
end
v._cleanup:Add(j.Activated:Connect(function()c:ShowTab(v)end))
v._cleanup:Add(j.MouseEnter:Connect(function()
if not v._active and not v._destroyed then e.Tweens:To(j,{BackgroundTransparency=0.45},{Time=0.12})end
end))
v._cleanup:Add(j.MouseLeave:Connect(function()
if not v._active and not v._destroyed then e.Tweens:To(j,{BackgroundTransparency=1},{Time=0.12})end
end))
return v
end

return b end function a.U():typeof(__modImpl())local aa=a.cache.U if not aa then aa={c=__modImpl()}a.cache.U=aa end return aa.c end end do local function __modImpl()

local aa=a.d()
local ab=a.b()
local ac=a.a()
local ad=a.c()
local b=a.k()
local c=a.U()

local d={}
d.__index=d

local e=58

local function safeSize(f,g)
return typeof(f)=="UDim2"and f or g
end

function d.new(f,g,h)
g=ab.Merge(ab.Window,ad.Options(g,"Window options"))
g.Title=ad.String(g.Title,"Title","Harkening UI",true)
g.Description=ad.String(g.Description,"Description","",true)
assert(typeof(g.Size)=="UDim2","Size debe ser UDim2")
assert(typeof(g.Position)=="UDim2","Position debe ser UDim2")
assert(typeof(g.MinSize)=="Vector2"and typeof(g.MaxSize)=="Vector2","MinSize y MaxSize deben ser Vector2")
local function finite(i)return type(i)=="number"and i==i and i>-math.huge and i<math.huge end
assert(finite(g.MinSize.X)and finite(g.MinSize.Y)and g.MinSize.X>=1 and g.MinSize.Y>=1,
"MinSize debe contener dimensiones positivas y finitas")
assert(finite(g.MaxSize.X)and finite(g.MaxSize.Y)and g.MaxSize.X>=g.MinSize.X and g.MaxSize.Y>=g.MinSize.Y,
"MaxSize debe ser finito y no puede ser menor que MinSize")
for i,j in ipairs{"Animation","AdaptiveSize","Draggable","Resizable","Minimizable","Maximizable","Closable"}do
assert(type(g[j])=="boolean",j.." debe ser booleano")
end
if g.SidebarWidth~=nil then assert(finite(g.SidebarWidth)and g.SidebarWidth>=0,"SidebarWidth debe ser un número finito >= 0")end
assert(g.CloseBehavior=="Hide"or g.CloseBehavior=="Destroy","CloseBehavior debe ser Hide o Destroy")

local i=table.clone(f)
i.Window=nil
local j=i.Theme
local k=i.Services.Workspace
local l=g.Size or UDim2.fromOffset(780,520)

local m=aa.Create("ImageLabel",{
Name=(g.Name or"HarkeningWindow").."_Shadow",
AnchorPoint=Vector2.new(0.5,0.5),Position=g.Position,
Size=UDim2.new(l.X.Scale,l.X.Offset+46,l.Y.Scale,l.Y.Offset+46),
BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://6015897843",
ImageColor3=j:Get"Shadow"or Color3.new(0,0,0),ImageTransparency=0.48,
ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),
ZIndex=9,Visible=g.Visible~=false,
},i.Gui)
local n=aa.Create("Frame",{
Name=g.Name or"HarkeningWindow",AnchorPoint=Vector2.new(0.5,0.5),
Position=g.Position,Size=safeSize(l,UDim2.fromOffset(780,520)),
BackgroundColor3=j:Get"Background",BorderSizePixel=0,ClipsDescendants=true,
Active=true,Visible=g.Visible~=false,ZIndex=10,
},i.Gui)
aa.Corner(n,j:Get"CornerRadius")
aa.Stroke(n,j:Get"Border",0.50,1)
aa.Create("UIGradient",{
Rotation=90,
Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,j:Get"Surface"),
ColorSequenceKeypoint.new(0.48,j:Get"Background"),
ColorSequenceKeypoint.new(1,j:Get"SurfaceInset"),
},
},n)

local o=aa.Create("UISizeConstraint",{
MinSize=g.MinSize,MaxSize=g.MaxSize,
},n)


local p=aa.Create("Frame",{
Name="Topbar",Size=UDim2.new(1,0,0,e),
BackgroundColor3=j:Get"Surface",BorderSizePixel=0,ZIndex=11,
},n)
aa.Corner(p,j:Get"CornerRadius")
aa.Create("UIGradient",{
Rotation=90,
Color=ColorSequence.new(j:Get"SurfaceRaised",j:Get"Surface"),
},p)


aa.Create("Frame",{
Name="TopbarLowerFill",Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0.5,0),
BackgroundColor3=j:Get"Surface",BorderSizePixel=0,ZIndex=11,
},p)
aa.Create("Frame",{
Name="HeaderDivider",Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),
BackgroundColor3=j:Get"BorderSubtle",BackgroundTransparency=0.16,BorderSizePixel=0,ZIndex=12,
},p)
local q=aa.Create("Frame",{
Name="AccentLine",Position=UDim2.new(0,0,0,0),Size=UDim2.new(0.13,0,0,2),
BackgroundColor3=j:Get"Accent",BorderSizePixel=0,ZIndex=13,
},p)
aa.Create("UIGradient",{
Color=ColorSequence.new{
ColorSequenceKeypoint.new(0,j:Get"Accent"),
ColorSequenceKeypoint.new(1,j:Get"AccentSecondary"),
},
},q)

local r=aa.Create("Frame",{
Name="BrandMark",Position=UDim2.new(0,15,0.5,-16),Size=UDim2.fromOffset(32,32),
BackgroundColor3=j:Get"AccentSoft",BorderSizePixel=0,ZIndex=12,
},p)
aa.Corner(r,9)
aa.Stroke(r,j:Get"Accent",0.68,1)
b.Create(r,g.Icon or"sparkles",{
Name="BrandIcon",Size=UDim2.fromOffset(18,18),Position=UDim2.new(0.5,-9,0.5,-9),
Color=j:Get"Accent",Fallback="H",TextSize=18,ZIndex=13,
})
local s=58
local t={}
local function headerButton(u,v,w,x,y)
local z=aa.Create("TextButton",{
Name=u,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12-(w*36),0.5,0),
Size=UDim2.fromOffset(28,28),BackgroundColor3=y or j:Get"SurfaceRaised",
BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=13,Selectable=true,
},p)
aa.Corner(z,8)
local A=aa.Stroke(z,j:Get"BorderSubtle",0.48,1)
local B=x or j:Get"MutedText"
local C=b.Create(z,v,{Name="Icon",Size=UDim2.fromOffset(14,14),Position=UDim2.new(0.5,-7,0.5,-7),
Color=B,Fallback=v,TextSize=15,ZIndex=14})
z.MouseEnter:Connect(function()
if not z.Parent then return end
i.Tweens:To(z,{BackgroundColor3=u=="Close"and j:Get"Danger"or j:Get"SurfaceHover"},{Time=0.12})
i.Tweens:To(A,{Transparency=0.15,Color=u=="Close"and j:Get"Danger"or j:Get"Accent"},{Time=0.12})
if C then
if C:IsA"ImageLabel"then i.Tweens:To(C,{ImageColor3=u=="Close"and Color3.new(1,1,1)or j:Get"Accent"},{Time=0.12})
else i.Tweens:To(C,{TextColor3=u=="Close"and Color3.new(1,1,1)or j:Get"Accent"},{Time=0.12})end
end
end)
z.MouseLeave:Connect(function()
if not z.Parent then return end
i.Tweens:To(z,{BackgroundColor3=y or j:Get"SurfaceRaised"},{Time=0.12})
i.Tweens:To(A,{Transparency=0.48,Color=j:Get"BorderSubtle"},{Time=0.12})
if C then
if C:IsA"ImageLabel"then i.Tweens:To(C,{ImageColor3=B},{Time=0.12})
else i.Tweens:To(C,{TextColor3=B},{Time=0.12})end
end
end)
table.insert(t,z)
return z
end
local u=0
local v,w,x
if g.Closable then x=headerButton("Close","close",u,j:Get"Danger");u+=1 end
if g.Maximizable then w=headerButton("Maximize","maximize",u);u+=1 end
if g.Minimizable then v=headerButton("Minimize","minimize",u);u+=1 end

local y=u>0 and(u*36+8)or 14
local z=aa.Label(p,"Title",g.Title,
UDim2.new(1,-(s+y+12),0,g.Description~=""and 23 or 30),
UDim2.new(0,s,0,g.Description~=""and 7 or 14),j:Get"Text",15,true)
z.ZIndex=12
z.TextTruncate=Enum.TextTruncate.AtEnd
local A
if g.Description~=""then
A=aa.Label(p,"Description",g.Description,
UDim2.new(1,-(s+y+12),0,16),UDim2.new(0,s,0,30),j:Get"MutedText",10)
A.ZIndex=12
A.TextTruncate=Enum.TextTruncate.AtEnd
end

local B=aa.Create("Frame",{
Name="Sidebar",Position=UDim2.new(0,0,0,e),
Size=UDim2.new(0,g.SidebarWidth,1,-e),
BackgroundColor3=j:Get"Surface",BorderSizePixel=0,ZIndex=11,
},n)
aa.Create("Frame",{
Name="SidebarDivider",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
Size=UDim2.new(0,1,1,0),BackgroundColor3=j:Get"BorderSubtle",BorderSizePixel=0,ZIndex=12,
},B)
local C=aa.Label(B,"NavigationLabel","WORKSPACE",UDim2.new(1,-28,0,14),UDim2.new(0,14,0,14),j:Get"MutedText",9,true)
C.ZIndex=12
local D=aa.Create("ScrollingFrame",{
Name="TabButtons",BackgroundTransparency=1,BorderSizePixel=0,
Position=UDim2.new(0,8,0,38),Size=UDim2.new(1,-16,1,-94),CanvasSize=UDim2.new(),
AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,
ScrollBarImageColor3=j:Get"Border",ScrollingDirection=Enum.ScrollingDirection.Y,ZIndex=12,
},B)
aa.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},D)
local E=aa.Create("Frame",{
Name="SidebarFooter",AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,10,1,-10),
Size=UDim2.new(1,-20,0,34),BackgroundColor3=j:Get"SurfaceRaised",BorderSizePixel=0,ZIndex=12,
},B)
aa.Corner(E,8)
aa.Stroke(E,j:Get"BorderSubtle",0.62,1)
local F=aa.Create("Frame",{Name="StatusDot",Position=UDim2.new(0,10,0.5,-3),Size=UDim2.fromOffset(6,6),
BackgroundColor3=j:Get"Success",BorderSizePixel=0,ZIndex=13},E)
aa.Corner(F,99)
local G=aa.Label(E,"FooterTitle","HARKENING UI",UDim2.new(1,-28,0,12),
UDim2.new(0,23,0,4),j:Get"Text",9,true);G.ZIndex=13
local H=aa.Label(E,"FooterSubtitle","READY TO USE",UDim2.new(1,-28,0,11),
UDim2.new(0,23,0,17),j:Get"MutedText",8,false);H.ZIndex=13

local I=aa.Create("Frame",{
Name="ContentHost",Position=UDim2.new(0,g.SidebarWidth,0,e),
Size=UDim2.new(1,-g.SidebarWidth,1,-e),
BackgroundColor3=j:Get"Background",BorderSizePixel=0,ClipsDescendants=true,ZIndex=11,
},n)
local J=aa.Create("Frame",{
Name="Pages",Position=UDim2.new(),Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,ClipsDescendants=true,ZIndex=12,
},I)
local K
if g.Resizable then
K=aa.Create("TextButton",{
Name="ResizeHandle",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,0,1,0),
Size=UDim2.fromOffset(24,24),BackgroundColor3=j:Get"SurfaceRaised",BackgroundTransparency=0.25,
BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=80,
},n)
aa.Corner(K,7)
b.Create(K,"resize",{Size=UDim2.fromOffset(13,13),Position=UDim2.new(0.5,-6.5,0.5,-6.5),
Color=j:Get"MutedText",Fallback="resize",TextSize=14,ZIndex=81})
end

local L=setmetatable({
Id=g.Id,Options=g,Frame=n,Shadow=m,Context=i,Manager=h,
Tabs={},ActiveTab=nil,Visible=n.Visible,Minimized=false,Maximized=false,
_destroyed=false,_savedSize=n.Size,_savedPosition=n.Position,_legacyTabs={},
TitleObject=z,DescriptionObject=A,Topbar=p,Sidebar=B,Pages=J,
TabButtons=D,SizeConstraint=o,_cleanup=ac.new(),
_sidebarFooterTitle=G,_sidebarFooterSubtitle=H,
},d)
i.Window=L

local M=i.Tweens
i.Tweens={}
function i.Tweens.To(N,O,P,Q)
local R=table.clone(Q or{})
if R.Enabled==nil then R.Enabled=g.Animation end
return M:To(O,P,R)
end
function i.Tweens.Cancel(N,O)return M:Cancel(O)end
function i.Tweens.Sequence(N,O,P,Q)
local R=table.clone(Q or{})
if R.Enabled==nil then R.Enabled=g.Animation end
if R.Enabled==false then
return{Play=function()for S,T in ipairs(P)do for U,V in pairs(T.Properties or{})do O[U]=V end end end,Cancel=function()end}
end
return M:Sequence(O,P,R)
end
L.Context=i

local function syncShadow()
if not m.Parent or not n.Parent then return end
m.AnchorPoint=n.AnchorPoint
m.Position=n.Position
m.Size=UDim2.new(n.Size.X.Scale,n.Size.X.Offset+46,n.Size.Y.Scale,n.Size.Y.Offset+46)
m.Visible=n.Visible
m.ZIndex=math.max(1,(L._zBase or 10)-1)
end

function L._ApplyZIndex(N,O)
if N._destroyed or not n.Parent then return end
O=O or N._zBase or 10
N._zBase=O
n.ZIndex=O
if m.Parent then m.ZIndex=math.max(1,O-1)end
local P=n:GetDescendants()
local function depth(Q)
local R,S=0,Q
while S and S~=n do R+=1;S=S.Parent end
return R
end
table.sort(P,function(Q,R)return depth(Q)<depth(R)end)
for Q,R in ipairs(P)do
if R:IsA"GuiObject"then R.ZIndex=O+math.clamp(depth(R),1,50)end
end
end

local function responsiveLayout()
if L._destroyed or not n.Parent then return end
local N=n.AbsoluteSize.X
local O=g.SidebarWidth or 168
local P=N<560 and math.clamp(O,112,124)or math.clamp(O,145,205)
B.Size=UDim2.new(0,P,1,-e)
I.Position=UDim2.new(0,P,0,e)
I.Size=UDim2.new(1,-P,1,-e)
C.Visible=N>=390
H.Visible=N>=560
E.Size=UDim2.new(1,-20,0,N<560 and 30 or 34)
D.Size=UDim2.new(1,-16,1,-(N<560 and 82 or 94))
D.Position=UDim2.new(0,8,0,N<560 and 28 or 38)
end

function L.Focus(N)
if not N._destroyed then h:Focus(N)end
end
function L.SetVisible(N,O)
if N._destroyed then return end
N.Visible=O==true
n.Visible=N.Visible
if m.Parent then m.Visible=N.Visible end
if not N.Visible then i.Input:CancelOwner(N);i.Input:CancelScope(N)else N:Focus()end
end
function L.Show(N)N:SetVisible(true)end
function L.Hide(N)N:SetVisible(false)end
function L.SetTitle(N,O)
if N._destroyed then return end
assert(type(O)=="string","SetTitle espera string")
z.Text=O
end
function L.SetDescription(N,O)
if N._destroyed then return end
assert(type(O)=="string","SetDescription espera string")
if A then A.Text=O
elseif O~=""then
A=aa.Label(p,"Description",O,UDim2.new(1,-200,0,16),UDim2.new(0,s,0,30),j:Get"MutedText",10)
A.ZIndex=12;A.TextTruncate=Enum.TextTruncate.AtEnd
N.DescriptionObject=A
end
N:_ApplyZIndex()
end
function L.AddTab(N,O)
assert(not N._destroyed,"Ventana destruida")
if type(O)=="string"then O={Title=O}end
O=O or{}
local P=c.new(N,O)
table.insert(N.Tabs,P)
if not N.ActiveTab or O.Selected==true then N:ShowTab(P)end
N:_ApplyZIndex()
return P
end
function L.ShowTab(N,O)
local P
for Q,R in ipairs(N.Tabs)do
if R==O or R.Title==O or R.Id==O then P=R;break end
end
if not P then return false end
i.Input:CancelScope(N)
for Q,R in ipairs(N.Tabs)do
local S=R==P
if R.SetActive then R:SetActive(S)else
R.Page.Visible=S
R.Button.BackgroundTransparency=S and 0 or 1
R.TitleObject.TextColor3=S and j:Get"Text"or j:Get"MutedText"
end
end
N.ActiveTab=P
N:Focus()
return true
end
function L.CrearSeccion(N,O)
assert(type(O)=="string"and O~="","CrearSeccion necesita un nombre")
if N._legacyTabs[O]then return N._legacyTabs[O].Section end
local P=N:AddTab{Title=O}
local Q=P:AddSection{Title=O}
N._legacyTabs[O]={Tab=P,Section=Q}
return Q
end
function L.MostrarSeccion(N,O)
local P=N._legacyTabs[O]
return N:ShowTab(P and P.Tab or O)
end
function L.CambiarInfoDeContenedorInformacion(N,O)
O=O or{}
N:SetTitle(tostring(O.Titulo or O.Title or""))
N:SetDescription(tostring(O.Descripcion or O.Description or""))
end
function L.SetMinimized(N,O)
if N._destroyed or not g.Minimizable then return end
O=O==true
if O==N.Minimized then return end
if O and N.Maximized then N:SetMaximized(false)end
N.Minimized=O
if O then
N._savedSize=n.Size
N._savedConstraintMin,N._savedConstraintMax=o.MinSize,o.MaxSize
o.MinSize=Vector2.new(math.min(o.MinSize.X,n.AbsoluteSize.X),e)
o.MaxSize=Vector2.new(math.max(o.MaxSize.X,n.AbsoluteSize.X),math.max(o.MaxSize.Y,e))
i.Input:CancelOwner(N);i.Input:CancelScope(N)
B.Visible=false;I.Visible=false
if K then K.Visible=false end
i.Tweens:To(n,{Size=UDim2.new(N._savedSize.X.Scale,N._savedSize.X.Offset,0,e)},{Time=0.18,Enabled=g.Animation})
else
o.MinSize=N._savedConstraintMin or g.MinSize
o.MaxSize=N._savedConstraintMax or g.MaxSize
B.Visible=true;I.Visible=true
if K then K.Visible=true end
i.Tweens:To(n,{Size=N._savedSize},{Time=0.18,Enabled=g.Animation})
responsiveLayout()
end
end
function L.SetMaximized(N,O)
if N._destroyed or not g.Maximizable then return end
O=O==true
if O==N.Maximized then return end
if O then
if N.Minimized then N:SetMinimized(false)end
N._restoreSize,N._restorePosition=n.Size,n.Position
local P=k.CurrentCamera
if P then
local Q=P.ViewportSize
local R=UDim2.fromOffset(math.max(300,Q.X-28),math.max(240,Q.Y-28))
local S=g.MaxSize
R=UDim2.fromOffset(math.min(R.X.Offset,S.X),math.min(R.Y.Offset,S.Y))
n.AnchorPoint=Vector2.new(0.5,0.5)
n.Position=UDim2.fromScale(0.5,0.5)
i.Tweens:To(n,{Size=R},{Time=0.2,Enabled=g.Animation})
end
else
n.AnchorPoint=Vector2.new(0.5,0.5)
if N._restorePosition then n.Position=N._restorePosition end
if N._restoreSize then i.Tweens:To(n,{Size=N._restoreSize},{Time=0.2,Enabled=g.Animation})end
end
N.Maximized=O
if K then K.Visible=g.Resizable and not O end
if w then
local P=w:FindFirstChild"Icon"
if P then
if P:IsA"TextLabel"then P.Text=b.Glyph(O and"restore"or"maximize")
elseif P:IsA"ImageLabel"then P.Image=O and"rbxassetid://9886659001"or"rbxassetid://9886659406"end
end
end
end
function L.Close(N)
if g.CloseBehavior=="Destroy"then N:Destroy()else N:Hide()end
end
function L.AdaptToViewport(N)
if not g.AdaptiveSize or N._destroyed or N.Minimized or N.Maximized then return end
local O=k.CurrentCamera
if not O then return end
local P=O.ViewportSize
local Q=g.Size
local R=Q.X.Scale*P.X+Q.X.Offset
local S=Q.Y.Scale*P.Y+Q.Y.Offset
if R<=0 then R=780 end
if S<=0 then S=520 end
local T=math.max(300,P.X-24)
local U=math.max(240,P.Y-24)
local V=g.MinSize
local W,X=math.min(V.X,T),math.min(V.Y,U)
o.MinSize=Vector2.new(W,X)
o.MaxSize=Vector2.new(math.min(g.MaxSize.X,T),math.min(g.MaxSize.Y,U))
n.Size=UDim2.fromOffset(math.clamp(R,W,math.max(W,T)),
math.clamp(S,X,math.max(X,U)))
N._savedSize=n.Size
responsiveLayout()
end
function L.Destroy(N)
if N._destroyed then return end
N._destroyed=true
i.Input:CancelOwner(N);i.Input:CancelScope(N);i.Tweens:Cancel(n)
for O,P in ipairs(N.Tabs)do P:Destroy()end
table.clear(N.Tabs)
N._cleanup:Destroy()
h:Remove(N)
if m.Parent then m:Destroy()end
if n.Parent then n:Destroy()end
end

if g.Draggable then
L._cleanup:Add(p.InputBegan:Connect(function(N)
if N.UserInputType~=Enum.UserInputType.MouseButton1 and N.UserInputType~=Enum.UserInputType.Touch then return end
local O=N.Position
local function over(P)
if not P then return false end
local Q,R=P.AbsolutePosition,P.AbsoluteSize
return O.X>=Q.X and O.X<=Q.X+R.X and O.Y>=Q.Y and O.Y<=Q.Y+R.Y
end
if over(x)or over(v)or over(w)then return end
L:Focus()
local P,Q=N.Position,n.Position
i.Input:BeginDrag(N,function(R)
local S=R-P
n.Position=UDim2.new(Q.X.Scale,Q.X.Offset+S.X,
Q.Y.Scale,Q.Y.Offset+S.Y)
end,nil,L,L)
end))
end
if x then L._cleanup:Add(x.Activated:Connect(function()L:Focus();L:Close()end))end
if v then L._cleanup:Add(v.Activated:Connect(function()L:Focus();L:SetMinimized(not L.Minimized)end))end
if w then L._cleanup:Add(w.Activated:Connect(function()L:Focus();L:SetMaximized(not L.Maximized)end))end
if K then
L._cleanup:Add(K.InputBegan:Connect(function(N)
if N.UserInputType~=Enum.UserInputType.MouseButton1 and N.UserInputType~=Enum.UserInputType.Touch then return end
if L.Maximized or L.Minimized then return end
L:Focus()
local O,P=N.Position,n.AbsoluteSize
i.Input:BeginDrag(N,function(Q)
local R=Q-O
local S,T=g.MinSize,g.MaxSize
local U=math.clamp(P.X+R.X,S.X,T.X)
local V=math.clamp(P.Y+R.Y,S.Y,T.Y)
n.Size=UDim2.fromOffset(U,V);L._savedSize=n.Size
end,nil,L,L)
end))
end
L._cleanup:Add(n:GetPropertyChangedSignal"AbsoluteSize":Connect(function()
responsiveLayout()
syncShadow()
end))
L._cleanup:Add(n:GetPropertyChangedSignal"Position":Connect(syncShadow))
L._cleanup:Add(n:GetPropertyChangedSignal"Size":Connect(syncShadow))
L._cleanup:Add(n:GetPropertyChangedSignal"Visible":Connect(syncShadow))
local function connectCamera(N)
if L._cameraConnection then L._cameraConnection:Disconnect();L._cameraConnection=nil end
if N then L._cameraConnection=N:GetPropertyChangedSignal"ViewportSize":Connect(function()
if L.Maximized then L:SetMaximized(false);L:SetMaximized(true)else L:AdaptToViewport()end
end)end
end
L._cleanup:Add(function()if L._cameraConnection then L._cameraConnection:Disconnect();L._cameraConnection=nil end end)
L._cleanup:Add(k:GetPropertyChangedSignal"CurrentCamera":Connect(function()connectCamera(k.CurrentCamera);L:AdaptToViewport()end))
connectCamera(k.CurrentCamera)
L:_ApplyZIndex()
L:AdaptToViewport()
syncShadow()
return L
end

return d end function a.V():typeof(__modImpl())local aa=a.cache.V if not aa then aa={c=__modImpl()}a.cache.V=aa end return aa.c end end do local function __modImpl()

local aa=a.V()
local ab={}
ab.__index=ab
function ab.new(ac)
return setmetatable({Context=ac,_windows={},_focusOrder={},_counter=0,_destroyed=false},ab)
end
function ab.Create(ac,ad)
assert(not ac._destroyed,"WindowManager ya fue destruido")
ad=table.clone(ad or{})
ac._counter+=1
local b=ad.Id or("Window"..tostring(ac._counter))
assert(type(b)=="string"and b~="","Window Id debe ser una cadena no vacía")
assert(ac._windows[b]==nil,"Ya existe una ventana con Id "..b)
ad.Id=b
local c=aa.new(ac.Context,ad,ac)
c.Id=b
ac._windows[b]=c
table.insert(ac._focusOrder,c)
if ac.Context.Lifecycle then ac.Context.Lifecycle:Add(c)end
ac:Focus(c)
return c
end
function ab.Get(ac,ad)return ac._windows[ad]end
function ab.GetAll(ac)
local ad={}
for b,c in ipairs(ac._focusOrder)do if not c._destroyed then table.insert(ad,c)end end
return ad
end
function ab.Focus(ac,ad)
if ac._destroyed or not ad or ad._destroyed then return end
local b
for c,d in ipairs(ac._focusOrder)do
if d==ad then table.remove(ac._focusOrder,c);b=true;break end
end
if not b then return end
table.insert(ac._focusOrder,ad)
for c,d in ipairs(ac._focusOrder)do
d:_ApplyZIndex(10+c*100)
end
end
function ab.Remove(ac,ad)
if not ad then return end
if ac._windows[ad.Id]==ad then ac._windows[ad.Id]=nil end
for b=#ac._focusOrder,1,-1 do if ac._focusOrder[b]==ad then table.remove(ac._focusOrder,b)end end
if ac.Context.Lifecycle then ac.Context.Lifecycle:Remove(ad)end
for b,c in ipairs(ac._focusOrder)do if not c._destroyed then c:_ApplyZIndex(10+b*100)end end
end
function ab.Show(ac,ad)
local b=ac:Get(ad);if b then b:Show()end;return b
end
function ab.Hide(ac,ad)
local b=ac:Get(ad);if b then b:Hide()end;return b
end
function ab.Destroy(ac,ad)
local b=ac:Get(ad);if b then b:Destroy()end
end
function ab.DestroyAll(ac)
local ad=ac:GetAll()
for b=#ad,1,-1 do ad[b]:Destroy()end
end
function ab.Destroy(ac)
if ac._destroyed then return end
ac:DestroyAll()
ac._destroyed=true
table.clear(ac._windows);table.clear(ac._focusOrder)
end
return ab end function a.W():typeof(__modImpl())local aa=a.cache.W if not aa then aa={c=__modImpl()}a.cache.W=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac=a.k()

local ad={}
ad.__index=ad
setmetatable(ad,{__index=aa})

local function runTween(b,c,d,e)
if b and b.Tweens and b.Tweens.To then
b.Tweens:To(c,d,{Time=e or 0.16})
else
for f,g in pairs(d)do c[f]=g end
end
end

function ad.new(b,c)
c=c or{}
assert(type(c)=="table","Modal options debe ser una tabla")
if c.Size~=nil then assert(typeof(c.Size)=="UDim2","Modal Size debe ser UDim2")end
for d,e in ipairs{"OnConfirm","OnCancel"}do
if c[e]~=nil then assert(type(c[e])=="function",e.." debe ser una función")end
end
for d,e in ipairs{"Title","Description","ConfirmText","CancelText"}do
if c[e]~=nil then assert(type(c[e])=="string",e.." debe ser una cadena")end
end

local d=b.Theme
local e=ab.Create("Frame",{
Name=c.Name or"ModalOverlay",Size=UDim2.fromScale(1,1),Position=UDim2.fromScale(0,0),
BackgroundColor3=Color3.fromRGB(4,6,10),BackgroundTransparency=1,
BorderSizePixel=0,Active=c.BlockInput~=false,Visible=false,ZIndex=10000,
},b.Gui)
local f=ab.Create("TextButton",{
Name="Backdrop",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
Text="",AutoButtonColor=false,ZIndex=10000,Active=true,
},e)
local g=c.Size or UDim2.fromOffset(390,c.Description and 222 or 184)
local h=ab.Create("ImageLabel",{Name="DialogShadow",AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(g.X.Scale,g.X.Offset+42,g.Y.Scale,g.Y.Offset+42),
BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://6015897843",
ImageColor3=d:Get"Shadow"or Color3.new(0,0,0),ImageTransparency=0.52,
ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),ZIndex=10000,
},e)
local i=ab.Create("Frame",{
Name="Dialog",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
Size=g,
BackgroundColor3=d:Get"Surface",BorderSizePixel=0,ZIndex=10001,
},e)
ab.Corner(i,d:Get"CornerRadius"+2)
ab.Stroke(i,d:Get"Border",0.12,1)
ab.Create("UIGradient",{Rotation=90,Color=ColorSequence.new(d:Get"SurfaceRaised",d:Get"Surface")},i)

local j=ab.Create("Frame",{Name="AccentRule",Size=UDim2.new(0.18,0,0,2),
BackgroundColor3=d:Get"Accent",BorderSizePixel=0,ZIndex=10002},i)
ab.Create("UIGradient",{Color=ColorSequence.new(d:Get"Accent",d:Get"AccentSecondary")},j)
ab.Padding(i,18,18,17,15)

local k=ab.Create("Frame",{Name="IconBox",Position=UDim2.new(0,0,0,13),
Size=UDim2.fromOffset(38,38),BackgroundColor3=c.Variant=="Destructive"and d:Get"Danger"or d:Get"AccentSoft",
BackgroundTransparency=0.16,BorderSizePixel=0,ZIndex=10002},i)
ab.Corner(k,11)
ab.Stroke(k,c.Variant=="Destructive"and d:Get"Danger"or d:Get"Accent",0.58,1)
ac.Create(k,c.Icon or(c.Variant=="Destructive"and"warning"or"sparkles"),{
Size=UDim2.fromOffset(19,19),Position=UDim2.new(0.5,-9.5,0.5,-9.5),
Color=c.Variant=="Destructive"and d:Get"Danger"or d:Get"Accent",TextSize=19,
})

local l=ab.Create("TextButton",{Name="Close",AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,0,0,10),Size=UDim2.fromOffset(28,28),
BackgroundColor3=d:Get"SurfaceRaised",BorderSizePixel=0,
Text="",AutoButtonColor=false,ZIndex=10003},i)
ab.Corner(l,8);ab.Stroke(l,d:Get"BorderSubtle",0.55,1)
ac.Create(l,"close",{Size=UDim2.fromOffset(14,14),Position=UDim2.new(0.5,-7,0.5,-7),Color=d:Get"MutedText",TextSize=15})

local m=ab.Label(i,"Title",c.Title or"Confirm action",
UDim2.new(1,-104,0,25),UDim2.new(0,50,0,15),d:Get"Text",16,true)
m.ZIndex=10003;m.TextTruncate=Enum.TextTruncate.AtEnd
local n=ab.Label(i,"Description",c.Description or"Are you sure you want to continue?",
UDim2.new(1,-2,0,62),UDim2.new(0,0,0,61),d:Get"MutedText",11)
n.ZIndex=10003;n.TextYAlignment=Enum.TextYAlignment.Top
n.TextWrapped=true

local o=ab.Create("Frame",{Name="Footer",AnchorPoint=Vector2.new(0,1),
Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,ZIndex=10002},i)
local p=ab.Create("TextButton",{Name="Cancel",AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-98,0,0),Size=UDim2.fromOffset(90,34),
BackgroundColor3=d:Get"SurfaceRaised",BorderSizePixel=0,
Text=c.CancelText or"Cancel",TextColor3=d:Get"Text",TextSize=11,
Font=Enum.Font.GothamSemibold,AutoButtonColor=false,ZIndex=10003},o)
ab.Corner(p,8);ab.Stroke(p,d:Get"BorderSubtle",0.4,1)
local q=ab.Create("TextButton",{Name="Confirm",AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(90,34),
BackgroundColor3=c.Variant=="Destructive"and d:Get"Danger"or d:Get"Accent",BorderSizePixel=0,
Text=c.ConfirmText or"Confirm",TextColor3=d:Get"AccentText",TextSize=11,
Font=Enum.Font.GothamSemibold,AutoButtonColor=false,ZIndex=10003},o)
ab.Corner(q,8)

local r=setmetatable({},ad)
aa.Initialize(r,b,e)
r.Dialog=i;r.Shadow=h;r.TextObject=m;r._closing=false;r._openGeneration=0
r:Connect(f.Activated,function()
if c.CloseOnOverlayClick==true then
if c.OnCancel then task.spawn(c.OnCancel,r)end
r:Close()
end
end)
r:Connect(l.Activated,function()
if c.OnCancel then task.spawn(c.OnCancel,r)end
r:Close()
end)
r:Connect(p.Activated,function()
if not r.Enabled then return end
if c.OnCancel then task.spawn(c.OnCancel,r)end
r:Close()
end)
r:Connect(q.Activated,function()
if not r.Enabled or r._closing then return end
local s=true
if c.OnConfirm then
local t,u=pcall(c.OnConfirm,r)
s=t and u~=false
if not t then warn("[Harkening] Modal OnConfirm: "..tostring(u))end
end
if s and c.CloseOnConfirm~=false then r:Close()end
end)
for s,t in ipairs{p,q,l}do
r:Connect(t.MouseEnter,function()
if t==q then runTween(b,t,{BackgroundColor3=c.Variant=="Destructive"and d:Get"Danger"or d:Get"AccentSecondary"},0.1)
else runTween(b,t,{BackgroundColor3=d:Get"SurfaceHover"},0.1)end
end)
r:Connect(t.MouseLeave,function()
if t==q then runTween(b,t,{BackgroundColor3=c.Variant=="Destructive"and d:Get"Danger"or d:Get"Accent"},0.1)
elseif t==p then runTween(b,t,{BackgroundColor3=d:Get"SurfaceRaised"},0.1)
else runTween(b,t,{BackgroundColor3=d:Get"SurfaceRaised"},0.1)end
end)
end

function r.Open(s)
if s._destroyed then return false end
s._closing=false;s._openGeneration+=1
e.Visible=true;e.BackgroundTransparency=1
i.Position=UDim2.new(0.5,0,0.5,10)
h.Position=i.Position
runTween(b,e,{BackgroundTransparency=c.OverlayTransparency or 0.32},0.18)
runTween(b,i,{Position=UDim2.fromScale(0.5,0.5)},0.2)
runTween(b,h,{Position=UDim2.fromScale(0.5,0.5),ImageTransparency=0.52},0.2)
return true
end
function r.Close(s)
if s._destroyed or s._closing then return end
s._closing=true;s._openGeneration+=1
local t=s._openGeneration
runTween(b,e,{BackgroundTransparency=1},0.14)
runTween(b,i,{Position=UDim2.new(0.5,0,0.5,8)},0.14)
runTween(b,h,{Position=UDim2.new(0.5,0,0.5,8),ImageTransparency=1},0.14)
task.delay(0.16,function()
if s._destroyed or t~=s._openGeneration then return end
if c.DestroyOnClose==false then e.Visible=false;s._closing=false
else s:Destroy()end
end)
end
if c.Visible~=false then r:Open()else e.Visible=false end
return r
end
return ad end function a.X():typeof(__modImpl())local aa=a.cache.X if not aa then aa={c=__modImpl()}a.cache.X=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac=a.k()

local ad={}
ad.__index=ad
setmetatable(ad,{__index=aa})

local b={
AddButton="Button",AddToggle="Toggle",AddSlider="Slider",AddDropdown="Dropdown",
AddMultiSelect="MultiSelect",AddTextInput="TextInput",AddNumericInput="NumericInput",
AddLabel="Label",AddParagraph="Paragraph",AddDivider="Divider",AddCard="Card",
AddProgress="Progress",AddImage="Image",AddKeybind="Keybind",AddSegmented="Segmented",
AddCollapsible="Collapsible",AddForm="Form",AddBadge="Badge",AddStatusIndicator="StatusIndicator",
AddMetricCard="MetricCard",AddKeyValueList="KeyValueList",AddDataTable="DataTable",AddItemCatalog="ItemCatalog",
AddRadioGroup="RadioGroup",AddRangeSlider="RangeSlider",AddTextArea="TextArea",AddColorPicker="ColorPicker",
AddEmptyState="EmptyState",AddLogViewer="LogViewer",AddTreeView="TreeView",AddCarousel="Carousel",
AddCheckbox="Checkbox",AddSearchableDropdown="SearchableDropdown",AddMultiSelectDropdown="MultiSelectDropdown",
AddTagSelector="TagSelector",AddCheckboxGroup="CheckboxGroup",AddPrimaryButton="PrimaryButton",
AddSecondaryButton="SecondaryButton",AddDestructiveButton="DestructiveButton",AddIconButton="IconButton",
AddButtonGroup="ButtonGroup",AddAccordion="Accordion",AddProgressBar="Progress",
}

function ad.new(c,d)
d=d or{}
assert(type(d)=="table","Popup options debe ser una tabla")
local e=c.Theme
local f=d.Parent or c.Gui
local g=tostring(d.Title or"")
local h=tostring(d.Description or"")
local i=g~=""or h~=""or d.Icon~=nil or d.ShowCloseButton==true
local j=i and(h~=""and 58 or 44)or 0
local k=d.Position or UDim2.fromScale(0.5,0.5)
local l=d.Size or UDim2.fromOffset(310,230)
local m=d.ZIndex or 9000
local n=ab.Create("ImageLabel",{Name=(d.Name or"Popup").."_Shadow",
AnchorPoint=d.AnchorPoint or Vector2.new(0,0),Position=k,
Size=UDim2.new(l.X.Scale,l.X.Offset+38,l.Y.Scale,l.Y.Offset+38),
BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://6015897843",
ImageColor3=e:Get"Shadow"or Color3.new(0,0,0),ImageTransparency=0.5,
ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450),
Visible=d.Visible==true,ZIndex=math.max(1,m-1),
},f)
local o=ab.Create("Frame",{
Name=d.Name or"Popup",AnchorPoint=d.AnchorPoint or Vector2.new(0,0),
Position=k,Size=l,
BackgroundColor3=e:Get"Surface",BorderSizePixel=0,Visible=d.Visible==true,
ZIndex=m,ClipsDescendants=true,
},f)
ab.Corner(o,e:Get"CornerRadius"+1)
ab.Stroke(o,e:Get"Border",0.26,1)
ab.Create("UIGradient",{Rotation=90,Color=ColorSequence.new(e:Get"SurfaceRaised",e:Get"Surface")},o)
local p=ab.Create("Frame",{Name="AccentRule",Size=UDim2.new(0.16,0,0,2),
BackgroundColor3=e:Get"Accent",BorderSizePixel=0,ZIndex=o.ZIndex+1},o)
ab.Create("UIGradient",{Color=ColorSequence.new(e:Get"Accent",e:Get"AccentSecondary"),
Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.04),NumberSequenceKeypoint.new(1,0.72)}},p)
local q
if i then
q=ab.Create("Frame",{Name="Header",Position=UDim2.fromOffset(0,2),Size=UDim2.new(1,0,0,j),
BackgroundTransparency=1,BorderSizePixel=0,ZIndex=o.ZIndex+1},o)
local r=14
if d.Icon then
local s=ab.Create("Frame",{Name="IconBox",Position=UDim2.new(0,12,0,10),Size=UDim2.fromOffset(28,28),
BackgroundColor3=e:Get"AccentSoft",BorderSizePixel=0,ZIndex=o.ZIndex+2},q)
ab.Corner(s,8)
ac.Create(s,d.Icon,{Size=UDim2.fromOffset(15,15),Position=UDim2.new(0.5,-7.5,0.5,-7.5),Color=e:Get"Accent",TextSize=15})
r=49
end
if g~=""then
local s=ab.Label(q,"Title",g,UDim2.new(1,-(r+(d.ShowCloseButton and 48 or 20)),0,21),
UDim2.new(0,r,0,h~=""and 7 or 11),e:Get"Text",13,true)
s.TextTruncate=Enum.TextTruncate.AtEnd
end
if h~=""then
local s=ab.Label(q,"Description",h,UDim2.new(1,-(r+22),0,19),UDim2.new(0,r,0,29),e:Get"MutedText",9)
s.TextTruncate=Enum.TextTruncate.AtEnd
end
if d.ShowCloseButton==true then
local s=ab.Create("TextButton",{Name="Close",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,9),
Size=UDim2.fromOffset(26,26),BackgroundColor3=e:Get"SurfaceRaised",BorderSizePixel=0,
Text="",AutoButtonColor=false,ZIndex=o.ZIndex+2},q)
ab.Corner(s,7);ab.Stroke(s,e:Get"BorderSubtle",0.5,1)
ac.Create(s,"close",{Size=UDim2.fromOffset(13,13),Position=UDim2.new(0.5,-6.5,0.5,-6.5),Color=e:Get"MutedText",TextSize=14})
s.Activated:Connect(function()self:Close()end)
end
ab.Create("Frame",{Name="HeaderDivider",Position=UDim2.new(0,12,1,-1),Size=UDim2.new(1,-24,0,1),
BackgroundColor3=e:Get"BorderSubtle",BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=o.ZIndex+2},q)
end
local r=ab.Create("ScrollingFrame",{Name="Content",BackgroundTransparency=1,
Position=UDim2.new(0,0,0,j+4),Size=UDim2.new(1,0,1,-(j+8)),
ZIndex=o.ZIndex+1,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
ScrollBarThickness=3,ScrollBarImageColor3=e:Get"Border",BorderSizePixel=0},o)
ab.Padding(r,12,12,8,12)
ab.Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7)},r)

local s=setmetatable({},ad)
aa.Initialize(s,c,o)
s.Content=r;s.Header=q;s._openGeneration=0;s.Shadow=n
local function syncShadow()
if not n.Parent or not o.Parent then return end
n.AnchorPoint=o.AnchorPoint
n.Position=o.Position
n.Size=UDim2.new(o.Size.X.Scale,o.Size.X.Offset+38,o.Size.Y.Scale,o.Size.Y.Offset+38)
n.Visible=o.Visible
n.ZIndex=math.max(1,o.ZIndex-1)
end
s:Connect(o:GetPropertyChangedSignal"Position",syncShadow)
s:Connect(o:GetPropertyChangedSignal"Size",syncShadow)
s:Connect(o:GetPropertyChangedSignal"Visible",syncShadow)
function s._ApplyZIndex(t)
if t._destroyed or not o.Parent then return end
o.ZIndex=d.ZIndex or 9000
if n.Parent then n.ZIndex=math.max(1,o.ZIndex-1)end
for u,v in ipairs(o:GetDescendants())do
if v:IsA"GuiObject"then
local w,x=1,v.Parent
while x and x~=o do w+=1;x=x.Parent end
v.ZIndex=o.ZIndex+math.clamp(w,1,50)
end
end
end
function s.Add(t,u,v)
assert(not t._destroyed,"Popup destruido")
local w=c.Factory:Create(u,r,v or{},c)
t._children=t._children or{};table.insert(t._children,w)
if w.Frame then w.Frame.LayoutOrder=#t._children end
t:_ApplyZIndex()
return w
end
for t,u in pairs(b)do
local v=u
s[t]=function(w,x)return w:Add(v,x)end
end
function s.SetTitle(t,u)
if t._destroyed then return end
local v=q and q:FindFirstChild"Title"
if v and v:IsA"TextLabel"then v.Text=tostring(u or"")end
end
function s.Open(t)
if t._destroyed then return false end
t._openGeneration+=1
o.Visible=true
n.Visible=true
o.BackgroundTransparency=1
local u=d.Position or UDim2.fromScale(0.5,0.5)
o.Position=UDim2.new(u.X.Scale,u.X.Offset,u.Y.Scale,u.Y.Offset+6)
c.Tweens:To(o,{BackgroundTransparency=0,Position=u},{Time=0.16})
t:_ApplyZIndex()
return true
end
function s.Close(t)
if t._destroyed or not o.Visible then return end
t._openGeneration+=1
local u=t._openGeneration
local v=d.Position or UDim2.fromScale(0.5,0.5)
c.Tweens:To(o,{BackgroundTransparency=1,Position=UDim2.new(v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset+6)},{Time=0.12})
task.delay(0.13,function()
if not t._destroyed and u==t._openGeneration then o.Visible=false;n.Visible=false end
end)
end
function s.Destroy(t)
if t._destroyed then return end
if n.Parent then n:Destroy()end
aa.Destroy(t)
end
s._closeConnections={}
s:_ApplyZIndex()
syncShadow()
if d.Visible==true then s:Open()end
return s
end
return ad end function a.Y():typeof(__modImpl())local aa=a.cache.Y if not aa then aa={c=__modImpl()}a.cache.Y=aa end return aa.c end end do local function __modImpl()

local aa=a.i()
local ab=a.d()
local ac=a.k()

local ad={}
ad.__index=ad
setmetatable(ad,{__index=aa})

local b={
Success={Color="Success",Icon="success"},
Error={Color="Danger",Icon="error"},
Warning={Color="Warning",Icon="warning"},
Info={Color="Info",Icon="info"},
Default={Color="Accent",Icon="bell"},
}

function ad.new(c,d)
d=d or{}
local e=c.Theme
local f=b[d.Type or d.Variant or"Default"]and(d.Type or d.Variant or"Default")or"Default"
local g=b[f]
local h=d.Color or e:Get(g.Color)
local i=math.clamp(tonumber(d.Width)or 336,240,480)
local j=d.Description~=nil and tostring(d.Description)~=""
local k=math.clamp(tonumber(d.Height)or(j and 92 or 70),62,160)
local l=UDim2.new(1,i+30,0,d.OffsetY or 24)
local m=ab.Create("Frame",{Name="Notification",AnchorPoint=Vector2.new(1,0),
Position=l,Size=UDim2.fromOffset(i,k),BackgroundColor3=e:Get"Surface",
BorderSizePixel=0,ZIndex=11000,ClipsDescendants=true},c.Gui)
ab.Corner(m,11);ab.Stroke(m,e:Get"Border",0.12,1)
ab.Create("UIGradient",{Rotation=90,Color=ColorSequence.new(e:Get"SurfaceRaised",e:Get"Surface")},m)
ab.Create("Frame",{Name="AccentBar",BackgroundColor3=h,BorderSizePixel=0,
Size=UDim2.new(0,3,1,-16),Position=UDim2.new(0,0,0,8),ZIndex=11001},m)
local n=ab.Create("Frame",{Name="IconHolder",Position=UDim2.new(0,13,0,14),
Size=UDim2.fromOffset(34,34),BackgroundColor3=h,BackgroundTransparency=0.86,
BorderSizePixel=0,ZIndex=11001},m)
ab.Corner(n,9);ab.Stroke(n,h,0.62,1)
ac.Create(n,d.Icon or g.Icon,{Size=UDim2.fromOffset(17,17),
Position=UDim2.new(0.5,-8.5,0.5,-8.5),Color=h,TextSize=17})
local o=ab.Label(m,"Title",tostring(d.Title or"Notification"),
UDim2.new(1,-104,0,20),UDim2.new(0,57,0,13),e:Get"Text",12,true)
o.ZIndex=11002;o.TextTruncate=Enum.TextTruncate.AtEnd
local p=ab.Label(m,"Type",tostring(d.Label or string.upper(f)),UDim2.new(1,-104,0,13),
UDim2.new(0,57,0,33),h,8,true)
p.ZIndex=11002;p.TextTruncate=Enum.TextTruncate.AtEnd
local q
if j then
q=ab.Label(m,"Description",tostring(d.Description),UDim2.new(1,-70,0,math.max(18,k-58)),
UDim2.new(0,13,0,55),e:Get"MutedText",10,false)
q.ZIndex=11002;q.TextYAlignment=Enum.TextYAlignment.Top
end
local r=ab.Create("TextButton",{Name="Close",AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-8,0,8),Size=UDim2.fromOffset(24,24),BackgroundColor3=e:Get"SurfaceRaised",
BackgroundTransparency=0.1,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=11003},m)
ab.Corner(r,7)
ac.Create(r,"close",{Size=UDim2.fromOffset(12,12),Position=UDim2.new(0.5,-6,0.5,-6),Color=e:Get"MutedText",TextSize=13})
local s=ab.Create("Frame",{Name="Lifetime",Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),
BackgroundColor3=h,BorderSizePixel=0,ZIndex=11004},m)

local t=setmetatable({},ad)
aa.Initialize(t,c,m)
t.TextObject=o;t._offsetY=d.OffsetY or 24;t._closing=false
t._timer=nil;t._closeThread=nil
t._cleanup:Add(function()
for u,v in ipairs{"_timer","_closeThread"}do
local w=t[v];t[v]=nil
if w then pcall(task.cancel,w)end
end
end)
t:Connect(r.Activated,function()t:Close()end)
t:Connect(r.MouseEnter,function()c.Tweens:To(r,{BackgroundColor3=e:Get"SurfaceHover"},{Time=0.1})end)
t:Connect(r.MouseLeave,function()c.Tweens:To(r,{BackgroundColor3=e:Get"SurfaceRaised"},{Time=0.1})end)
c.Tweens:To(m,{Position=UDim2.new(1,-18,0,t._offsetY)},{Time=0.24,Style=Enum.EasingStyle.Quint})

function t.SetOffsetY(u,v)
if u._destroyed then return end
u._offsetY=tonumber(v)or 24
if m.Parent then c.Tweens:To(m,{Position=UDim2.new(1,-18,0,u._offsetY)},{Time=0.16})end
end
function t.SetType(u,v)
if u._destroyed then return end
local w=b[v]or b.Default
local x=e:Get(w.Color)
p.Text=string.upper(v or"Default");p.TextColor3=x
s.BackgroundColor3=x
n.BackgroundColor3=x
h=x
end
function t.Close(u)
if u._destroyed or u._closing then return end
u._closing=true
if u._timer then pcall(task.cancel,u._timer);u._timer=nil end
c.Tweens:To(m,{Position=UDim2.new(1,i+30,0,u._offsetY),BackgroundTransparency=1},{Time=0.16})
u._closeThread=task.delay(0.18,function()
u._closeThread=nil
if not u._destroyed then u:Destroy()end
end)
end
local u=tonumber(d.Duration)
if u==nil then u=4 end
if u>0 then
c.Tweens:To(s,{Size=UDim2.new(0,0,0,2)},{Time=u,EasingStyle=Enum.EasingStyle.Linear})
t._timer=task.delay(u,function()t._timer=nil;if not t._destroyed then t:Close()end end)
else
s.Visible=false
end
return t
end
return ad end function a.Z():typeof(__modImpl())local aa=a.cache.Z if not aa then aa={c=__modImpl()}a.cache.Z=aa end return aa.c end end do local function __modImpl()


local aa=a.d()
local ab=a.a()

local ac={}
ac.__index=ac

local ad={
TopLeft={Anchor=Vector2.new(0,0),Position=UDim2.new(0,16,0,16)},
TopRight={Anchor=Vector2.new(1,0),Position=UDim2.new(1,-16,0,16)},
BottomLeft={Anchor=Vector2.new(0,1),Position=UDim2.new(0,16,1,-16)},
BottomRight={Anchor=Vector2.new(1,1),Position=UDim2.new(1,-16,1,-16)},
TopCenter={Anchor=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,16)},
BottomCenter={Anchor=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-16)},
}

local b={
Enabled=true,Title="HARKENING UI",Text="",ShowLogo=true,LogoText="H",LogoImage=nil,
ShowGameName=true,ShowGameIcon=true,ShowFPS=true,ShowClock=false,
Position="TopRight",Style="Compact",Status="RUNNING",
BackgroundTransparency=0.12,Width=300,
}

function ac.new(c,d)
d=d or{}
local e=setmetatable({Context=c,Options={},_cleanup=ab.new(),_destroyed=false,_visible=false,
_fpsElapsed=0,_fpsFrames=0,_fps=0,_status="RUNNING"},ac)
for f,g in pairs(b)do e.Options[f]=g end
for f,g in pairs(d)do e.Options[f]=g end
e._status=tostring(e.Options.Status or"RUNNING")

local f=c.Theme
local g=ad[e.Options.Position]or ad.TopRight
local h=math.clamp(tonumber(e.Options.Width)or 300,190,520)
local i=e.Options.Style=="Expanded"
local j=i and 68 or 42
local k=aa.Create("Frame",{
Name="HarkeningWatermark",AnchorPoint=g.Anchor,Position=g.Position,
Size=UDim2.fromOffset(h,j),BackgroundColor3=f:Get"Surface",
BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=10000,
},c.Gui)
aa.Corner(k,f:Get"CornerRadius")
local l=aa.Stroke(k,f:Get"Accent",1,1)
aa.Padding(k,10,10,7,7)
local m=aa.Create("Frame",{Name="Header",BackgroundTransparency=1,Size=UDim2.new(1,0,0,28),ZIndex=10001},k)
local n=aa.Create("Frame",{Name="Logo",BackgroundColor3=f:Get"Accent",BorderSizePixel=0,
Size=UDim2.fromOffset(27,27),Visible=e.Options.ShowLogo~=false,ZIndex=10002},m)
aa.Corner(n,7)
local o=aa.Label(n,"LogoGlyph",tostring(e.Options.LogoText or"H"),UDim2.fromScale(1,1),UDim2.new(),f:Get"AccentText",14,true)
o.TextXAlignment=Enum.TextXAlignment.Center
local p=aa.Create("ImageLabel",{Name="LogoImage",BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(19,19),Image=tostring(e.Options.LogoImage or""),
ScaleType=Enum.ScaleType.Fit,Visible=e.Options.LogoImage~=nil and e.Options.LogoImage~="",ZIndex=10003},n)
o.Visible=not p.Visible
local q=e.Options.ShowLogo==false and 0 or 35
local r=aa.Label(m,"ProjectTitle",tostring(e.Options.Title or"HARKENING UI"),
UDim2.new(1,-q-88,0,18),UDim2.new(0,q,0,1),f:Get"Text",12,true)
r.TextTruncate=Enum.TextTruncate.AtEnd
local s=aa.Label(m,"Status",e._status,UDim2.new(0,83,0,15),UDim2.new(1,-83,0,2),f:Get"Success",9,true)
s.TextXAlignment=Enum.TextXAlignment.Right
local t=aa.Label(m,"Stats","",UDim2.new(0,83,0,15),UDim2.new(1,-83,0,15),f:Get"MutedText",9)
t.TextXAlignment=Enum.TextXAlignment.Right

local u=aa.Create("Frame",{Name="Details",BackgroundTransparency=1,Position=UDim2.new(0,0,0,31),
Size=UDim2.new(1,0,0,24),Visible=i,ZIndex=10001},k)
local v=aa.Create("ImageLabel",{Name="GameIcon",BackgroundColor3=f:Get"SurfaceRaised",
BackgroundTransparency=0,BorderSizePixel=0,Size=UDim2.fromOffset(20,20),
Image="rbxthumb://type=GameIcon&id="..tostring(game.PlaceId).."&w=150&h=150",
ScaleType=Enum.ScaleType.Fit,Visible=e.Options.ShowGameIcon~=false,ZIndex=10002},u)
aa.Corner(v,5)
local w=aa.Label(u,"GameName",tostring(game.Name),
UDim2.new(1,(e.Options.ShowGameIcon==false and 0 or-27),0,20),UDim2.new(0,(e.Options.ShowGameIcon==false and 0 or 27),0,0),
f:Get"MutedText",10)
w.TextTruncate=Enum.TextTruncate.AtEnd
local x=aa.Label(k,"Clock","",UDim2.new(1,-12,0,12),UDim2.new(0,1,1,-13),f:Get"MutedText",9)
x.Visible=e.Options.ShowClock==true and i

e.Frame,e._stroke,e._logo,e._title,e._statusLabel=k,l,n,r,s
e._stats,e._details,e._gameIcon,e._gameName,e._clock=t,u,v,w,x
e._logoText,e._logoImage,e._header,e._height=o,p,m,j
e._shownPosition=g.Position
e:_ApplyOptions(e.Options)

if e.Options.ShowGameName~=false then

task.spawn(function()
local y=c.Services.MarketplaceService
if not y or game.PlaceId<=0 then return end
local z,A=pcall(function()return y:GetProductInfo(game.PlaceId)end)
if z and type(A)=="table"and type(A.Name)=="string"and not e._destroyed then
e._gameName.Text=A.Name
end
end)
end

e._cleanup:Add(c.Services.RunService.Heartbeat:Connect(function(y)
if e._destroyed then return end
e._fpsElapsed+=y
e._fpsFrames+=1
if e._fpsElapsed>=0.5 then
e._fps=math.floor(e._fpsFrames/math.max(e._fpsElapsed,0.001)+0.5)
e._fpsElapsed,e._fpsFrames=0,0
e:_UpdateReadouts()
end
end))
if e.Options.Enabled~=false then e:Show(false)end
return e
end

function ac._UpdateReadouts(c)
if c._destroyed then return end
local d={}
if c.Options.ShowFPS~=false then table.insert(d,tostring(c._fps).." FPS")end
if c.Options.Text and c.Options.Text~=""then table.insert(d,tostring(c.Options.Text))end
c._stats.Text=table.concat(d,"  •  ")
c._stats.Visible=#d>0
if c.Options.ShowClock==true then c._clock.Text=os.date"%H:%M:%S"end
c._statusLabel.Text=c._status
c._statusLabel.TextColor3=c._status=="ERROR"and c.Context.Theme:Get"Danger"
or(c._status=="READY"and c.Context.Theme:Get"Success"or c.Context.Theme:Get"Accent")
end

function ac._ApplyOptions(c,d)
if c._destroyed then return end
local e=c.Context.Theme
local f=ad[d.Position]or ad.TopRight
local g=d.Style=="Expanded"
c.Frame.AnchorPoint=f.Anchor
c._shownPosition=f.Position
c.Frame.Position=f.Position
c.Frame.Size=UDim2.fromOffset(math.clamp(tonumber(d.Width)or 300,190,520),g and 68 or 42)
c.Frame.BackgroundTransparency=math.clamp(tonumber(d.BackgroundTransparency)or 0.12,0,1)
c._title.Text=tostring(d.Title or"HARKENING UI")
c._logo.Visible=d.ShowLogo~=false
c._logoImage.Image=tostring(d.LogoImage or"")
c._logoImage.Visible=d.LogoImage~=nil and d.LogoImage~=""
c._logoText.Text=tostring(d.LogoText or"H")
c._logoText.Visible=not c._logoImage.Visible
c._title.Position=UDim2.new(0,d.ShowLogo==false and 0 or 35,0,1)
c._title.Size=UDim2.new(1,(d.ShowLogo==false and-88 or-123),0,18)
c._gameIcon.Visible=d.ShowGameIcon~=false
c._gameName.Visible=d.ShowGameName~=false
c._gameName.Position=UDim2.new(0,d.ShowGameIcon==false and 0 or 27,0,0)
c._gameName.Size=UDim2.new(1,d.ShowGameIcon==false and 0 or-27,0,20)
c._details.Visible=g and d.ShowGameName~=false
c._clock.Visible=g and d.ShowClock==true
c._clock.Position=UDim2.new(0,1,1,-14)
c._statusLabel.Visible=d.ShowStatus~=false
c._stats.Visible=d.ShowFPS~=false or(d.Text~=nil and d.Text~="")
c._stroke.Color=e:Get"Accent"
c:_UpdateReadouts()
end

function ac.Update(c,d)
assert(type(d)=="table","UpdateWatermark espera una tabla")
if c._destroyed then return end
local e=c.Options.Enabled~=false
for f,g in pairs(d)do c.Options[f]=g end
if d.Status~=nil then c._status=tostring(d.Status)end
c:_ApplyOptions(c.Options)
if d.Enabled==false then
c:Hide()
elseif d.Enabled==true and not e then
c:Show(false)
end
end
function ac.SetStatus(c,d)
assert(type(d)=="string","SetStatus espera una cadena")
c._status=d
c:_UpdateReadouts()
end
function ac.SetVisible(c,d)
if c._destroyed then return end
if d then c:Show(false)else c:Hide()end
end
function ac.Show(c,d)
if c._destroyed then return end
c._visible=true
c.Frame.Visible=true
local e=c._shownPosition
if d or not c.Context.Tweens.Enabled then
c.Frame.Position=e
c.Frame.BackgroundTransparency=math.clamp(tonumber(c.Options.BackgroundTransparency)or 0.12,0,1)
c._stroke.Transparency=0.35
c._title.TextTransparency,c._statusLabel.TextTransparency,c._stats.TextTransparency=0,0,0
c._logoText.TextTransparency,c._gameName.TextTransparency,c._clock.TextTransparency=0,0,0
return
end
local f=e+UDim2.fromOffset(0,c.Options.Position and string.find(c.Options.Position,"Bottom")and 8 or-8)
c.Frame.Position=f
c.Frame.BackgroundTransparency=1
c._stroke.Transparency=1
for g,h in ipairs{c._title,c._statusLabel,c._stats,c._logoText,c._gameName,c._clock}do h.TextTransparency=1 end
c.Context.Tweens:To(c.Frame,{Position=e,BackgroundTransparency=math.clamp(tonumber(c.Options.BackgroundTransparency)or 0.12,0,1)},{Time=0.24})
c.Context.Tweens:To(c._stroke,{Transparency=0.35},{Time=0.3})
for g,h in ipairs{c._title,c._statusLabel,c._stats,c._logoText,c._gameName,c._clock}do
task.delay((g-1)*0.025,function()
if not c._destroyed and c._visible and h.Parent then c.Context.Tweens:To(h,{TextTransparency=0},{Time=0.18})end
end)
end
end
function ac.Hide(c)
if c._destroyed or not c._visible then return end
c._visible=false
if not c.Context.Tweens.Enabled then c.Frame.Visible=false;return end
local d=c.Options.Position and string.find(c.Options.Position,"Bottom")and 8 or-8
c.Context.Tweens:To(c.Frame,{Position=c._shownPosition+UDim2.fromOffset(0,d),BackgroundTransparency=1},{Time=0.16})
task.delay(0.18,function()if not c._destroyed and not c._visible then c.Frame.Visible=false end end)
end
function ac.IsVisible(c)return c._visible end
function ac.Destroy(c)
if c._destroyed then return end
c._destroyed=true
c._cleanup:Destroy()
if c.Context and c.Context.Tweens and c.Frame then
c.Context.Tweens:Cancel(c.Frame)
for d,e in ipairs(c.Frame:GetDescendants())do c.Context.Tweens:Cancel(e)end
end
if c.Frame and c.Frame.Parent then c.Frame:Destroy()end
c.Frame=nil
end

return ac end function a._():typeof(__modImpl())local aa=a.cache._ if not aa then aa={c=__modImpl()}a.cache._=aa end return aa.c end end do local function __modImpl()

local aa=a.a()
local ab=a.b()
local ac=a.c()
local ad=a.d()
local b=a.e()
local c=a.f()
local d=a.g()
local e=a.h()
local f=a.R()
local g=a.S()
local h=a.W()
local i=a.X()
local j=a.Y()
local k=a.Z()
local l=a.j()
local m=a._()

local n=setmetatable({},{__mode="k"})

local o={}
o.__index=o
o.Version="2.2.3"

function o.new(p)
p=ab.Merge(ab.Framework,ac.Options(p,"Harkening.new options"))
p.Name=ac.String(p.Name,"Name","Harkening UI",false)
assert(type(p.Theme)=="table","Theme debe ser una tabla")
assert(type(p.Animation)=="boolean","Animation debe ser booleano")
assert(type(p.ResetOnSpawn)=="boolean","ResetOnSpawn debe ser booleano")
p.DisplayOrder=ac.Number(p.DisplayOrder,"DisplayOrder",50)
assert(p.DisplayOrder%1==0,"DisplayOrder debe ser un entero")
assert(type(p.Debug)=="boolean","Debug debe ser booleano")
local q=b.new(p)
local r=q:ResolveParent()


local s=n[r]
local t=s and s[p.Name]
if t and not t._destroyed then t:Destroy()end
local u=r:FindFirstChild(p.Name)
if u and u:IsA"ScreenGui"and u:GetAttribute"HarkeningOwned"==true then u:Destroy()end
local v=q:GetServices()
local w=ad.Create("ScreenGui",{Name=p.Name or"HarkeningUI",ResetOnSpawn=p.ResetOnSpawn,
DisplayOrder=p.DisplayOrder,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=false},r)
w:SetAttribute("HarkeningOwned",true)
w:SetAttribute("HarkeningVersion",o.Version)
local x=aa.new()
local y=g.new()
local z=c.new(p.Theme)
local A=d.new(p.Animation,v.TweenService)
local B=e.new(x,v.UserInputService)
local C={
Gui=w,Theme=z,Tweens=A,Input=B,Cleanup=x,
Environment=q,Services=v,Lifecycle=y,Options=p,
}
local D=setmetatable({Options=p,Gui=w,Environment=q,Services=v,
Theme=z,Tweens=A,Input=B,Cleanup=x,Lifecycle=y,
Windows=nil,_destroyed=false,_resources={},_notifications={}},o)
C.Framework=D
local E=h.new(C)
C.WindowManager=E
local F=f.new(C)
C.Factory=F
D.Context=C
D.Windows=E
D.Components=F
D.Componentes=F
D.Icons=l
D._registryParent,D._registryName=r,p.Name
n[r]=n[r]or{}
n[r][p.Name]=D


if p.Watermark~=false and type(p.Watermark)=="table"and p.Watermark.Enabled~=false then
D.Watermark=m.new(C,p.Watermark)
end
return D
end

function o.CreateWindow(p,q)
assert(not p._destroyed,"Harkening ya fue destruido")
return p.Windows:Create(q or{})
end
function o.GetWindow(p,q)return p.Windows:Get(q)end
function o.GetWindows(p)return p.Windows:GetAll()end
function o.ShowWindow(p,q)return p.Windows:Show(q)end
function o.HideWindow(p,q)return p.Windows:Hide(q)end
function o.DestroyWindow(p,q)return p.Windows:Destroy(q)end
function o.SetTheme(p,q)p.Theme:SetTheme(q)end
function o.GetTheme(p)return p.Theme:GetAll()end
function o.GetAvailableComponents(p)return p.Components:GetAvailable()end
function o.SetWatermarkVisible(p,q)
if p._destroyed then return end
if not p.Watermark then
if q==true then
local r=type(p.Options.Watermark)=="table"and table.clone(p.Options.Watermark)or{}
r.Enabled=true
p.Watermark=m.new(p.Context,r)
end
return
end
p.Watermark:SetVisible(q==true)
end
function o.UpdateWatermark(p,q)
assert(type(q)=="table","UpdateWatermark espera una tabla")
if p._destroyed then return end
if not p.Watermark then
local r=type(p.Options.Watermark)=="table"and table.clone(p.Options.Watermark)or{}
for s,t in pairs(q)do r[s]=t end
r.Enabled=true
p.Watermark=m.new(p.Context,r)
else
p.Watermark:Update(q)
end
end
function o.GetWatermark(p)return p.Watermark end
function o.SetStatus(p,q)if p.Watermark then p.Watermark:SetStatus(q)end end

function o.CreateModal(p,q)
assert(not p._destroyed,"Harkening ya fue destruido")
return p.Lifecycle:Add(i.new(p.Context,q or{}))
end
function o.CreatePopup(p,q)
assert(not p._destroyed,"Harkening ya fue destruido")
return p.Lifecycle:Add(j.new(p.Context,q or{}))
end
function o.Notify(p,q)
assert(not p._destroyed,"Harkening ya fue destruido")
q=table.clone(q or{})
local r=q.Height or(q.Description and 82 or 62)
if q.OffsetY==nil then q.OffsetY=24+#p._notifications*(r+10)end
local s=k.new(p.Context,q)
table.insert(p._notifications,s)
s._onDestroy=function()
for t=#p._notifications,1,-1 do
if p._notifications[t]==s then table.remove(p._notifications,t);break end
end
if not p._destroyed then
local t=24
for u,v in ipairs(p._notifications)do
if not v._destroyed then
v:SetOffsetY(t)
local w=v.Frame and v.Frame.Size.Y.Offset or 62
t+=w+10
end
end
end
end
return p.Lifecycle:Add(s)
end


o.CrearVentanaPrincipal=o.CreateWindow
o.ObtenerVentana=o.GetWindow
o.MostrarVentana=o.ShowWindow
o.OcultarVentana=o.HideWindow
o.CambiarTema=o.SetTheme
o.MostrarNotificacion=o.Notify
o.MostrarMarcaDeAgua=o.SetWatermarkVisible
o.ActualizarMarcaDeAgua=o.UpdateWatermark

function o.Destroy(p)
if p._destroyed then return end
p._destroyed=true
local q=p._registryParent and n[p._registryParent]
if q and q[p._registryName]==p then q[p._registryName]=nil end
p.Windows:Destroy()
if p.Watermark then p.Watermark:Destroy();p.Watermark=nil end
p.Lifecycle:Destroy()
p.Input:Destroy()
p.Tweens:Destroy()
p.Theme:Destroy()
p.Cleanup:Destroy()
if p.Gui and p.Gui.Parent then p.Gui:Destroy()end
end

return o end function a.aa():typeof(__modImpl())local aa=a.cache.aa if not aa then aa={c=__modImpl()}a.cache.aa=aa end return aa.c end end end


local aa=a.aa()
local ab={Version=aa.Version,Icons=a.j()}

function ab.new(ac)
return aa.new(ac)
end

ab.Create=ab.new
ab.Crear=ab.new

return ab