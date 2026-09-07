local LucidUI = {}
LucidUI.Version = "0.3.0"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
	Background = Color3.fromRGB(2,2,3),
	Topbar = Color3.fromRGB(5,5,7),
	Surface = Color3.fromRGB(7,7,10),
	Surface2 = Color3.fromRGB(11,11,15),
	Surface3 = Color3.fromRGB(16,16,22),
	Hover = Color3.fromRGB(22,22,30),
	Accent = Color3.fromRGB(112,82,255),
	Text = Color3.fromRGB(246,246,250),
	Muted = Color3.fromRGB(128,128,145),
	Border = Color3.fromRGB(30,30,40),
	Success = Color3.fromRGB(69,210,139),
	Warning = Color3.fromRGB(255,191,74),
	Danger = Color3.fromRGB(255,82,105),
	Favorite = Color3.fromRGB(255,197,65)
}
LucidUI.Theme = Theme

local Icons = {
	Settings = "rbxassetid://130679451576739"
}
LucidUI.Icons = Icons

local function new(class, props, parent)
	local o = Instance.new(class)
	for k,v in pairs(props or {}) do o[k] = v end
	o.Parent = parent
	return o
end

local function corner(o,r)
	return new("UICorner",{CornerRadius=UDim.new(0,r or 8)},o)
end

local function stroke(o,c,t)
	return new("UIStroke",{Color=c or Theme.Border,Thickness=1,Transparency=t or 0},o)
end

local function pad(o,l,r,t,b)
	return new("UIPadding",{
		PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),
		PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0)
	},o)
end

local function tween(o,time,props)
	local x=TweenService:Create(o,TweenInfo.new(time or .16,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),props)
	x:Play()
	return x
end

local function label(parent,text,size,color,bold)
	return new("TextLabel",{
		BackgroundTransparency=1,BorderSizePixel=0,Text=text or "",
		TextColor3=color or Theme.Text,TextSize=size or 13,
		Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center
	},parent)
end

local function button(parent,text,size,color,bold)
	return new("TextButton",{
		BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,
		Text=text or "",TextColor3=color or Theme.Text,TextSize=size or 13,
		Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
	},parent)
end

local function normalizeIcon(id)
	if not id then return nil end
	local s=tostring(id)
	if s:find("rbxasset",1,true) then return s end
	return "rbxassetid://"..s
end

local function image(parent,id,size)
	return new("ImageLabel",{
		BackgroundTransparency=1,BorderSizePixel=0,Image=normalizeIcon(id),
		ImageColor3=Theme.Muted,Size=UDim2.fromOffset(size or 17,size or 17)
	},parent)
end


local function lineIcon(parent,kind,size,color)
	size=size or 18
	color=color or Theme.Muted
	local holder=new("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromOffset(size,size)},parent)
	local function line(x,y,w,h,rotation)
		local f=new("Frame",{
			AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,x,0,y),
			Size=UDim2.fromOffset(w,h),Rotation=rotation or 0,
			BackgroundColor3=color,BorderSizePixel=0
		},holder)
		corner(f,3)
		return f
	end
	if kind=="Search" then
		local ring=new("Frame",{
			Position=UDim2.fromOffset(2,2),Size=UDim2.fromOffset(size-7,size-7),
			BackgroundTransparency=1,BorderSizePixel=0
		},holder)
		corner(ring,50)
		local st=stroke(ring,color,0)
		st.Thickness=2
		line(size-4,size-4,7,2,45)
	elseif kind=="Star" then
		local cx,cy=size/2,size/2
		for i=0,4 do
			local a1=math.rad(-90+i*144)
			local a2=math.rad(-90+(i+1)*144)
			local r=size*.39
			local x1=cx+math.cos(a1)*r
			local y1=cy+math.sin(a1)*r
			local x2=cx+math.cos(a2)*r
			local y2=cy+math.sin(a2)*r
			local dx,dy=x2-x1,y2-y1
			local len=math.sqrt(dx*dx+dy*dy)
			local seg=line((x1+x2)/2,(y1+y2)/2,len,1.6,math.deg(math.atan2(dy,dx)))
			seg.Name="Segment"
		end
	elseif kind=="Close" then
		line(size/2,size/2,size*.62,2,45)
		line(size/2,size/2,size*.62,2,-45)
	elseif kind=="Minus" then
		line(size/2,size/2,size*.62,2,0)
	end
	holder:SetAttribute("LucidLineIcon",true)
	return holder
end

local function setLineIconColor(holder,newColor)
	if not holder then return end
	for _,d in ipairs(holder:GetDescendants()) do
		if d:IsA("Frame") and d~=holder and d.BackgroundTransparency<1 then
			d.BackgroundColor3=newColor
		elseif d:IsA("UIStroke") then
			d.Color=newColor
		end
	end
end

local function safeParent(gui)
	local ok=pcall(function() gui.Parent=CoreGui end)
	if not ok then gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui") end
end

local function drag(handle,target)
	local active=false
	local startMouse,startPos
	handle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			active=true startMouse=i.Position startPos=target.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if active and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d=i.Position-startMouse
			target.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then active=false end
	end)
end

local Window={}
Window.__index=Window
local Tab={}
Tab.__index=Tab
local Section={}
Section.__index=Section

function LucidUI:CreateWindow(o)
	o=o or {}
	local self=setmetatable({},Window)
	self.Title=o.Title or "LucidUI"
	self.Subtitle=o.Subtitle or "dark interface"
	self.Size=o.Size or UDim2.fromOffset(840,520)
	self.Tabs={}
	self.Components={}
	self.FavoriteMode=false
	self.Visible=true
	self.CurrentTab=nil
	self.FavoritesTab=nil

	local old=CoreGui:FindFirstChild("LucidUI_V3")
	if old then old:Destroy() end

	local gui=new("ScreenGui",{Name="LucidUI_V3",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
	safeParent(gui)
	self.Gui=gui

	local shadow=new("Frame",{
		AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
		Size=self.Size+UDim2.fromOffset(26,26),BackgroundColor3=Color3.new(),
		BackgroundTransparency=.34,BorderSizePixel=0
	},gui)
	corner(shadow,18)

	local main=new("Frame",{
		AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=self.Size,
		BackgroundColor3=Theme.Background,BorderSizePixel=0,ClipsDescendants=true
	},gui)
	corner(main,14)
	stroke(main,Theme.Border,.05)

	self.Main=main
	self.Shadow=shadow

	local top=new("Frame",{Size=UDim2.new(1,0,0,64),BackgroundColor3=Theme.Topbar,BorderSizePixel=0},main)
	self.Topbar=top

	local title=label(top,self.Title,17,Theme.Text,true)
	title.Position=UDim2.fromOffset(18,8)
	title.Size=UDim2.new(0,180,0,23)

	local subtitle=label(top,self.Subtitle,10,Theme.Muted,false)
	subtitle.Position=UDim2.fromOffset(18,31)
	subtitle.Size=UDim2.new(0,180,0,18)

	local controls=new("Frame",{
		AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),
		Size=UDim2.fromOffset(122,34),BackgroundTransparency=1
	},top)
	local cl=new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,7)},controls)

	local fav=new("TextButton",{
		LayoutOrder=1,Size=UDim2.fromOffset(34,34),BackgroundColor3=Theme.Surface2,
		BorderSizePixel=0,AutoButtonColor=false,Text=""
	},controls)
	corner(fav,8)
	local favGlyph=lineIcon(fav,"Star",17,Theme.Muted)
	favGlyph.AnchorPoint=Vector2.new(.5,.5)
	favGlyph.Position=UDim2.fromScale(.5,.5)

	local mini=button(controls,"—",18,Theme.Muted,true)
	mini.LayoutOrder=2 mini.Size=UDim2.fromOffset(34,34) mini.BackgroundTransparency=0 mini.BackgroundColor3=Theme.Surface2 corner(mini,8)

	local close=button(controls,"×",19,Theme.Muted,true)
	close.LayoutOrder=3 close.Size=UDim2.fromOffset(34,34) close.BackgroundTransparency=0 close.BackgroundColor3=Theme.Surface2 corner(close,8)

	local tabbar=new("Frame",{
		Position=UDim2.fromOffset(205,0),Size=UDim2.new(1,-350,1,0),
		BackgroundTransparency=1,ClipsDescendants=true
	},top)

	local tabs=new("ScrollingFrame",{
		Size=UDim2.new(1,-46,1,0),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=0,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.X
	},tabbar)
	local tabLayout=new("UIListLayout",{
		FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,
		Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder
	},tabs)
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabs.CanvasSize=UDim2.fromOffset(tabLayout.AbsoluteContentSize.X+10,0)
	end)

	local searchButton=new("TextButton",{
		AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),
		Size=UDim2.fromOffset(36,36),BackgroundColor3=Theme.Surface2,BorderSizePixel=0,
		AutoButtonColor=false,Text=""
	},tabbar)
	corner(searchButton,9)
	local searchGlyph=lineIcon(searchButton,"Search",17,Theme.Muted)
	searchGlyph.AnchorPoint=Vector2.new(.5,.5)
	searchGlyph.Position=UDim2.fromScale(.5,.5)

	local body=new("Frame",{Position=UDim2.fromOffset(0,64),Size=UDim2.new(1,0,1,-64),BackgroundTransparency=1},main)

	local pageHolder=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},body)
	self.Content=pageHolder
	self.TabBar=tabs

	local searchOverlay=new("Frame",{
		Visible=false,Position=UDim2.fromOffset(14,12),Size=UDim2.new(1,-28,1,-24),
		BackgroundColor3=Theme.Surface,BorderSizePixel=0,ZIndex=100
	},body)
	corner(searchOverlay,12)
	stroke(searchOverlay,Theme.Border,.05)

	local search=new("TextBox",{
		Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-28,0,42),
		BackgroundColor3=Theme.Surface2,BorderSizePixel=0,Text="",
		PlaceholderText="Search tabs, sections and options...",PlaceholderColor3=Theme.Muted,
		TextColor3=Theme.Text,TextSize=13,Font=Enum.Font.Gotham,ClearTextOnFocus=false,
		TextXAlignment=Enum.TextXAlignment.Left,ZIndex=101
	},searchOverlay)
	corner(search,9)
	pad(search,13,13,0,0)

	local results=new("ScrollingFrame",{
		Position=UDim2.fromOffset(14,66),Size=UDim2.new(1,-28,1,-80),
		BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,
		ScrollBarImageColor3=Theme.Border,CanvasSize=UDim2.new(),ZIndex=101
	},searchOverlay)
	local rl=new("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},results)
	rl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		results.CanvasSize=UDim2.fromOffset(0,rl.AbsoluteContentSize.Y+10)
	end)

	self.SearchOverlay=searchOverlay
	self.SearchBox=search
	self.SearchResults=results
	self.FavoriteButton=fav

	local function setVisible(state)
		self.Visible=state
		main.Visible=state
		shadow.Visible=state
		if state then
			main.Size=self.Size-UDim2.fromOffset(24,24)
			main.BackgroundTransparency=.08
			tween(main,.18,{Size=self.Size,BackgroundTransparency=0})
		end
	end
	self.SetVisible=setVisible

	close.MouseButton1Click:Connect(function() setVisible(false) end)

	mini.MouseButton1Click:Connect(function()
		if main.Size.Y.Offset<=66 then
			tween(main,.2,{Size=self.Size})
		else
			tween(main,.2,{Size=UDim2.fromOffset(self.Size.X.Offset,64)})
		end
	end)

	UserInputService.InputBegan:Connect(function(i,processed)
		if processed then return end
		if i.KeyCode==Enum.KeyCode.Tab then setVisible(not self.Visible) end
	end)

	fav.MouseButton1Click:Connect(function()
		self.FavoriteMode=not self.FavoriteMode
		tween(fav,.14,{
			BackgroundColor3=self.FavoriteMode and Color3.fromRGB(40,31,12) or Theme.Surface2
		})
		setLineIconColor(favGlyph,self.FavoriteMode and Theme.Favorite or Theme.Muted)
		for _,c in ipairs(self.Components) do
			if c.Star then c.Star.Visible=self.FavoriteMode end
		end
		if not self.FavoriteMode then self:_BuildFavorites() end
	end)

	searchButton.MouseButton1Click:Connect(function()
		searchOverlay.Visible=not searchOverlay.Visible
		if searchOverlay.Visible then
			search:CaptureFocus()
			self:_Search(search.Text)
		end
	end)

	search.FocusLost:Connect(function(enter)
		if enter and search.Text=="" then searchOverlay.Visible=false end
	end)

	search:GetPropertyChangedSignal("Text"):Connect(function() self:_Search(search.Text) end)

	drag(top,main)

	game:GetService("RunService").RenderStepped:Connect(function()
		if not gui.Parent then return end
		shadow.Position=main.Position
		shadow.Size=main.Size+UDim2.fromOffset(26,26)
		shadow.Visible=main.Visible
	end)

	return self
end

function Window:AddTab(o,iconId)
	if type(o)=="string" then o={Name=o,Icon=iconId} end
	o=o or {}
	local t=setmetatable({},Tab)
	t.Window=self
	t.Name=o.Name or "Tab"
	t.Icon=o.Icon
	t.Sections={}
	t.Internal=o.Internal==true

	local b=button(self.TabBar,"",12,Theme.Muted,true)
	b.Size=UDim2.fromOffset(o.Icon and 112 or 92,36)
	b.BackgroundTransparency=1
	b.BackgroundColor3=Theme.Surface2
	corner(b,9)

	local ico
	if o.Icon then
		ico=image(b,o.Icon,15)
		ico.Position=UDim2.new(0,10,.5,-7)
	end

	local tx=label(b,t.Name,12,Theme.Muted,true)
	tx.Position=UDim2.fromOffset(o.Icon and 32 or 10,0)
	tx.Size=UDim2.new(1,-(o.Icon and 40 or 20),1,0)
	tx.TextXAlignment=Enum.TextXAlignment.Center

	local indicator=new("Frame",{
		AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,0),
		Size=UDim2.new(0,0,0,2),BackgroundColor3=Theme.Accent,BorderSizePixel=0
	},b)
	corner(indicator,4)

	local page=new("ScrollingFrame",{
		Visible=false,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=Theme.Border,CanvasSize=UDim2.new()
	},self.Content)
	pad(page,18,18,18,18)
	local layout=new("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},page)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+36)
	end)

	t.Button=b t.Label=tx t.IconObject=ico t.Indicator=indicator t.Page=page
	table.insert(self.Tabs,t)

	b.MouseButton1Click:Connect(function() self:SelectTab(t) end)
	b.MouseEnter:Connect(function()
		if self.CurrentTab~=t then tween(b,.12,{BackgroundTransparency=.35}) end
	end)
	b.MouseLeave:Connect(function()
		if self.CurrentTab~=t then tween(b,.12,{BackgroundTransparency=1}) end
	end)

	if not self.CurrentTab and not t.Internal then self:SelectTab(t) end
	return t
end

function Window:SelectTab(tab)
	self.SearchOverlay.Visible=false
	for _,t in ipairs(self.Tabs) do
		local active=t==tab
		t.Page.Visible=active
		tween(t.Button,.14,{BackgroundTransparency=active and 0 or 1,BackgroundColor3=Theme.Surface2})
		tween(t.Label,.14,{TextColor3=active and Theme.Text or Theme.Muted})
		tween(t.Indicator,.14,{Size=active and UDim2.new(.65,0,0,2) or UDim2.new(0,0,0,2)})
		if t.IconObject then tween(t.IconObject,.14,{ImageColor3=active and Theme.Accent or Theme.Muted}) end
	end
	self.CurrentTab=tab
end

function Tab:AddSection(name)
	local s=setmetatable({},Section)
	s.Window=self.Window
	s.Tab=self
	s.Name=name or "Section"

	local frame=new("Frame",{
		Size=UDim2.new(1,0,0,54),AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundColor3=Theme.Surface,BorderSizePixel=0
	},self.Page)
	corner(frame,11)
	stroke(frame,Theme.Border,.2)
	pad(frame,12,12,10,12)

	local title=label(frame,s.Name,11,Theme.Muted,true)
	title.Size=UDim2.new(1,0,0,22)

	local content=new("Frame",{
		Position=UDim2.fromOffset(0,30),Size=UDim2.new(1,0,0,0),
		AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1
	},frame)
	new("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},content)

	s.Frame=frame s.Content=content
	table.insert(self.Sections,s)
	return s
end

function Section:_Card(name,description,height)
	local card=new("Frame",{
		Size=UDim2.new(1,0,0,height or 48),BackgroundColor3=Theme.Surface2,BorderSizePixel=0
	},self.Content)
	corner(card,9)
	stroke(card,Theme.Border,.45)

	local title=label(card,name,13,Theme.Text,true)
	title.Position=UDim2.fromOffset(12,description and 5 or 0)
	title.Size=UDim2.new(1,-210,description and 0 or 1,description and 20 or 0)

	if description then
		local d=label(card,description,10,Theme.Muted,false)
		d.Position=UDim2.fromOffset(12,26)
		d.Size=UDim2.new(1,-210,0,16)
	end

	local star=new("TextButton",{
		Visible=self.Window.FavoriteMode,AnchorPoint=Vector2.new(1,.5),
		Position=UDim2.new(1,-9,.5,0),Size=UDim2.fromOffset(24,24),
		BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,
		Text="",ZIndex=10
	},card)
	local starGlyph=lineIcon(star,"Star",15,Theme.Muted)
	starGlyph.AnchorPoint=Vector2.new(.5,.5)
	starGlyph.Position=UDim2.fromScale(.5,.5)
	starGlyph.ZIndex=11

	local component={
		Name=name,Description=description or "",Tab=self.Tab,Section=self,
		Card=card,Star=star,Favorited=false
	}
	table.insert(self.Window.Components,component)

	star.MouseButton1Click:Connect(function()
		component.Favorited=not component.Favorited
		setLineIconColor(starGlyph,component.Favorited and Theme.Favorite or Theme.Muted)
		self.Window:_BuildFavorites()
	end)

	return card,component
end

function Section:AddButton(o)
	if type(o)=="string" then o={Name=o} end
	o=o or {}
	local card,c=self:_Card(o.Name or "Button",o.Description,o.Description and 56 or 48)
	local run=button(card,o.ActionText or "Run",11,Theme.Text,true)
	run.AnchorPoint=Vector2.new(1,.5) run.Position=UDim2.new(1,-42,.5,0)
	run.Size=UDim2.fromOffset(64,28) run.BackgroundTransparency=0 run.BackgroundColor3=Theme.Surface3 corner(run,7)
	run.MouseEnter:Connect(function() tween(run,.1,{BackgroundColor3=Theme.Accent}) end)
	run.MouseLeave:Connect(function() tween(run,.1,{BackgroundColor3=Theme.Surface3}) end)
	run.MouseButton1Click:Connect(function() task.spawn(o.Callback or function() end) end)
	c.Fire=function() task.spawn(o.Callback or function() end) end
	return c
end

function Section:AddToggle(o)
	o=o or {}
	local value=o.Default==true
	local card,c=self:_Card(o.Name or "Toggle",o.Description,o.Description and 56 or 48)
	local track=button(card,"",1,Theme.Text,false)
	track.AnchorPoint=Vector2.new(1,.5) track.Position=UDim2.new(1,-42,.5,0)
	track.Size=UDim2.fromOffset(42,24) track.BackgroundTransparency=0
	track.BackgroundColor3=value and Theme.Accent or Theme.Surface3 corner(track,20)
	local knob=new("Frame",{
		AnchorPoint=Vector2.new(0,.5),Position=value and UDim2.new(0,20,.5,0) or UDim2.new(0,3,.5,0),
		Size=UDim2.fromOffset(18,18),BackgroundColor3=Theme.Text,BorderSizePixel=0
	},track)
	corner(knob,20)
	local function set(v,fire)
		value=not not v
		tween(track,.14,{BackgroundColor3=value and Theme.Accent or Theme.Surface3})
		tween(knob,.14,{Position=value and UDim2.new(0,20,.5,0) or UDim2.new(0,3,.5,0)})
		if fire then task.spawn(o.Callback or function() end,value) end
	end
	track.MouseButton1Click:Connect(function() set(not value,true) end)
	c.Set=function(_,v) set(v,true) end
	c.Get=function() return value end
	return c
end

function Section:AddSlider(o)
	o=o or {}
	local min,max=o.Min or 0,o.Max or 100
	local value=math.clamp(o.Default or min,min,max)
	local card,c=self:_Card(o.Name or "Slider",o.Description,68)
	local val=label(card,tostring(value)..(o.Suffix or ""),11,Theme.Muted,true)
	val.AnchorPoint=Vector2.new(1,0) val.Position=UDim2.new(1,-42,0,7) val.Size=UDim2.fromOffset(70,18) val.TextXAlignment=Enum.TextXAlignment.Right
	local bar=new("Frame",{Position=UDim2.new(0,12,1,-18),Size=UDim2.new(1,-56,0,7),BackgroundColor3=Theme.Surface3,BorderSizePixel=0},card)
	corner(bar,8)
	local fill=new("Frame",{Size=UDim2.new((value-min)/(max-min),0,1,0),BackgroundColor3=Theme.Accent,BorderSizePixel=0},bar)
	corner(fill,8)
	local dragging=false
	local function setX(x,fire)
		local a=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
		local raw=min+(max-min)*a
		local step=o.Step or 1
		value=math.clamp(math.floor(raw/step+.5)*step,min,max)
		fill.Size=UDim2.new((value-min)/(max-min),0,1,0)
		val.Text=tostring(value)..(o.Suffix or "")
		if fire then task.spawn(o.Callback or function() end,value) end
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true setX(i.Position.X,true) end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setX(i.Position.X,true) end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
	end)
	c.Get=function() return value end
	c.Set=function(_,v)
		value=math.clamp(v,min,max) fill.Size=UDim2.new((value-min)/(max-min),0,1,0)
		val.Text=tostring(value)..(o.Suffix or "") task.spawn(o.Callback or function() end,value)
	end
	return c
end

function Section:AddTextbox(o)
	o=o or {}
	local card,c=self:_Card(o.Name or "Textbox",o.Description,52)
	local box=new("TextBox",{
		AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-42,.5,0),
		Size=UDim2.fromOffset(180,30),BackgroundColor3=Theme.Surface3,BorderSizePixel=0,
		Text=o.Default or "",PlaceholderText=o.Placeholder or "Type...",
		PlaceholderColor3=Theme.Muted,TextColor3=Theme.Text,TextSize=11,
		Font=Enum.Font.Gotham,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left
	},card)
	corner(box,7) pad(box,9,9,0,0)
	box.FocusLost:Connect(function(enter)
		if not o.EnterOnly or enter then task.spawn(o.Callback or function() end,box.Text,enter) end
	end)
	c.Get=function() return box.Text end
	c.Set=function(_,v) box.Text=tostring(v) end
	return c
end

function Section:AddDropdown(o)
	o=o or {}
	local values=o.Values or {}
	local current=o.Default or values[1]
	local card,c=self:_Card(o.Name or "Dropdown",o.Description,52)
	local pick=button(card,current and tostring(current) or "Select",11,Theme.Text,false)
	pick.AnchorPoint=Vector2.new(1,.5) pick.Position=UDim2.new(1,-42,.5,0)
	pick.Size=UDim2.fromOffset(155,30) pick.BackgroundTransparency=0 pick.BackgroundColor3=Theme.Surface3 corner(pick,7)
	local popup
	local function closePop() if popup then popup:Destroy() popup=nil end end
	pick.MouseButton1Click:Connect(function()
		if popup then closePop() return end
		popup=new("Frame",{
			Position=UDim2.fromOffset(pick.AbsolutePosition.X+pick.AbsoluteSize.X-190,pick.AbsolutePosition.Y+pick.AbsoluteSize.Y+5),
			Size=UDim2.fromOffset(190,math.min(#values*34+12,200)),
			BackgroundColor3=Theme.Surface,BorderSizePixel=0,ZIndex=130
		},self.Window.Gui)
		self.Window:RegisterPopup(popup)
		corner(popup,9) stroke(popup,Theme.Border,.05)
		local list=new("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.fromOffset(0,#values*34+8),ZIndex=31},popup)
		pad(list,6,6,6,6)
		new("UIListLayout",{Padding=UDim.new(0,4)},list)
		for _,v in ipairs(values) do
			local b=button(list,tostring(v),11,Theme.Text,false)
			b.Size=UDim2.new(1,0,0,30) b.BackgroundTransparency=0 b.BackgroundColor3=Theme.Surface2 b.ZIndex=32 corner(b,6)
			b.MouseButton1Click:Connect(function()
				current=v pick.Text=tostring(v) closePop() task.spawn(o.Callback or function() end,v)
			end)
		end
	end)
	c.Get=function() return current end
	c.Set=function(_,v) current=v pick.Text=tostring(v) task.spawn(o.Callback or function() end,v) end
	return c
end

function Section:AddPlayerDropdown(o)
	o=o or {}
	local selected=nil
	local card,c=self:_Card(o.Name or "Player",o.Description,52)
	local pick=button(card,"Select player",11,Theme.Text,false)
	pick.AnchorPoint=Vector2.new(1,.5) pick.Position=UDim2.new(1,-42,.5,0)
	pick.Size=UDim2.fromOffset(170,30) pick.BackgroundTransparency=0 pick.BackgroundColor3=Theme.Surface3 corner(pick,7)
	local popup
	local connections={}
	local function cleanup()
		for _,x in ipairs(connections) do x:Disconnect() end
		table.clear(connections)
		if popup then popup:Destroy() popup=nil end
	end
	pick.MouseButton1Click:Connect(function()
		if popup then cleanup() return end
		popup=new("Frame",{
			Position=UDim2.fromOffset(pick.AbsolutePosition.X+pick.AbsoluteSize.X-290,pick.AbsolutePosition.Y+pick.AbsoluteSize.Y+5),
			Size=UDim2.fromOffset(290,275),BackgroundColor3=Theme.Surface,
			BorderSizePixel=0,ZIndex=140
		},self.Window.Gui)
		self.Window:RegisterPopup(popup)
		corner(popup,10) stroke(popup,Theme.Border,.05)
		local search=new("TextBox",{
			Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,0,34),
			BackgroundColor3=Theme.Surface2,BorderSizePixel=0,Text="",
			PlaceholderText="Search player...",PlaceholderColor3=Theme.Muted,
			TextColor3=Theme.Text,TextSize=11,Font=Enum.Font.Gotham,
			ClearTextOnFocus=false,ZIndex=141
		},popup)
		corner(search,7) pad(search,10,10,0,0)
		local list=new("ScrollingFrame",{
			Position=UDim2.fromOffset(8,50),Size=UDim2.new(1,-16,1,-58),
			BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,
			ScrollBarImageColor3=Theme.Border,CanvasSize=UDim2.new(),ZIndex=141
		},popup)
		new("UIListLayout",{Padding=UDim.new(0,5)},list)
		local function rebuild()
			for _,x in ipairs(list:GetChildren()) do if x:IsA("TextButton") then x:Destroy() end end
			local q=search.Text:lower()
			local count=0
			for _,plr in ipairs(Players:GetPlayers()) do
				local hay=(plr.Name.." "..plr.DisplayName):lower()
				if q=="" or hay:find(q,1,true) then
					count+=1
					local row=button(list,"",11,Theme.Text,false)
					row.Size=UDim2.new(1,0,0,44) row.BackgroundTransparency=0 row.BackgroundColor3=Theme.Surface2 row.ZIndex=142 corner(row,7)
					local avatar=new("ImageLabel",{Position=UDim2.fromOffset(5,5),Size=UDim2.fromOffset(34,34),BackgroundColor3=Theme.Surface3,BorderSizePixel=0,ZIndex=143},row)
					corner(avatar,18)
					task.spawn(function()
						local ok,img=pcall(function() return Players:GetUserThumbnailAsync(plr.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
						if ok and avatar.Parent then avatar.Image=img end
					end)
					local dn=label(row,plr.DisplayName,11,Theme.Text,true)
					dn.Position=UDim2.fromOffset(47,4) dn.Size=UDim2.new(1,-52,0,19) dn.ZIndex=143
					local un=label(row,"@"..plr.Name,9,Theme.Muted,false)
					un.Position=UDim2.fromOffset(47,22) un.Size=UDim2.new(1,-52,0,16) un.ZIndex=143
					row.MouseButton1Click:Connect(function()
						selected=plr pick.Text=plr.DisplayName cleanup() task.spawn(o.Callback or function() end,plr)
					end)
				end
			end
			list.CanvasSize=UDim2.fromOffset(0,count*49)
		end
		rebuild()
		table.insert(connections,search:GetPropertyChangedSignal("Text"):Connect(rebuild))
		table.insert(connections,Players.PlayerAdded:Connect(rebuild))
		table.insert(connections,Players.PlayerRemoving:Connect(function(p)
			if selected==p then selected=nil pick.Text="Select player" end
			rebuild()
		end))
	end)
	c.Get=function() return selected end
	c.Set=function(_,p) selected=p pick.Text=p and p.DisplayName or "Select player" if p then task.spawn(o.Callback or function() end,p) end end
	return c
end

function Window:_BuildFavorites()
	local count=0
	for _,c in ipairs(self.Components) do if c.Favorited then count+=1 end end
	if count==0 then
		if self.FavoritesTab then self.FavoritesTab.Button.Visible=false end
		return
	end
	if not self.FavoritesTab then
		self.FavoritesTab=self:AddTab({Name="Favorites",Internal=true})
		self.FavoritesTab.Button.LayoutOrder=-100
	end
	self.FavoritesTab.Button.Visible=true
	local page=self.FavoritesTab.Page
	for _,x in ipairs(page:GetChildren()) do
		if x:IsA("Frame") then x:Destroy() end
	end
	local section=self.FavoritesTab:AddSection("Quick access")
	for _,c in ipairs(self.Components) do
		if c.Favorited and c.Tab~=self.FavoritesTab then
			local row=button(section.Content,"",12,Theme.Text,false)
			row.Size=UDim2.new(1,0,0,48) row.BackgroundTransparency=0 row.BackgroundColor3=Theme.Surface2 corner(row,8) stroke(row,Theme.Border,.45)
			local n=label(row,c.Name,12,Theme.Text,true)
			n.Position=UDim2.fromOffset(12,4) n.Size=UDim2.new(1,-24,0,20)
			local path=label(row,c.Tab.Name.."  ›  "..c.Section.Name,9,Theme.Muted,false)
			path.Position=UDim2.fromOffset(12,25) path.Size=UDim2.new(1,-24,0,15)
			row.MouseButton1Click:Connect(function()
				self:SelectTab(c.Tab)
				tween(c.Card,.12,{BackgroundColor3=Theme.Hover})
				task.delay(.35,function() if c.Card.Parent then tween(c.Card,.18,{BackgroundColor3=Theme.Surface2}) end end)
			end)
		end
	end
end

function Window:_Search(q)
	q=(q or ""):lower()
	for _,x in ipairs(self.SearchResults:GetChildren()) do if x:IsA("TextButton") then x:Destroy() end end
	if q=="" then
		for _,c in ipairs(self.Components) do
			local row=button(self.SearchResults,"",12,Theme.Text,false)
			row.Size=UDim2.new(1,0,0,48) row.BackgroundTransparency=0 row.BackgroundColor3=Theme.Surface2 row.ZIndex=102 corner(row,8)
			local n=label(row,c.Name,12,Theme.Text,true) n.Position=UDim2.fromOffset(12,4) n.Size=UDim2.new(1,-24,0,20) n.ZIndex=103
			local p=label(row,c.Tab.Name.."  ›  "..c.Section.Name,9,Theme.Muted,false) p.Position=UDim2.fromOffset(12,25) p.Size=UDim2.new(1,-24,0,15) p.ZIndex=103
			row.MouseButton1Click:Connect(function() self.SearchBox.Text="" self:SelectTab(c.Tab) end)
		end
		return
	end
	for _,c in ipairs(self.Components) do
		local hay=(c.Name.." "..c.Description.." "..c.Tab.Name.." "..c.Section.Name):lower()
		if hay:find(q,1,true) then
			local row=button(self.SearchResults,"",12,Theme.Text,false)
			row.Size=UDim2.new(1,0,0,48) row.BackgroundTransparency=0 row.BackgroundColor3=Theme.Surface2 row.ZIndex=102 corner(row,8)
			local n=label(row,c.Name,12,Theme.Text,true) n.Position=UDim2.fromOffset(12,4) n.Size=UDim2.new(1,-24,0,20) n.ZIndex=103
			local p=label(row,c.Tab.Name.."  ›  "..c.Section.Name,9,Theme.Muted,false) p.Position=UDim2.fromOffset(12,25) p.Size=UDim2.new(1,-24,0,15) p.ZIndex=103
			row.MouseButton1Click:Connect(function()
				self.SearchBox.Text="" self:SelectTab(c.Tab)
				tween(c.Card,.12,{BackgroundColor3=Theme.Hover})
				task.delay(.35,function() if c.Card.Parent then tween(c.Card,.18,{BackgroundColor3=Theme.Surface2}) end end)
			end)
		end
	end
end

function Window:Notify(o)
	o=o or {}
	local holder=self.Gui:FindFirstChild("LucidNotifications")
	if not holder then
		holder=new("Frame",{
			Name="LucidNotifications",AnchorPoint=Vector2.new(1,0),
			Position=UDim2.new(1,-16,0,16),Size=UDim2.fromOffset(330,500),
			BackgroundTransparency=1
		},self.Gui)
		new("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},holder)
	end
	local card=new("TextButton",{
		Size=UDim2.new(1,0,0,0),BackgroundColor3=Theme.Surface,
		BackgroundTransparency=0,BorderSizePixel=0,Text="",AutoButtonColor=false,
		ClipsDescendants=true
	},holder)
	corner(card,8) stroke(card,Theme.Border,.05)
	local accent=o.Type=="Success" and Theme.Success or o.Type=="Warning" and Theme.Warning or (o.Type=="Error" or o.Type=="Danger") and Theme.Danger or Theme.Accent
	local strip=new("Frame",{Size=UDim2.fromOffset(4,70),BackgroundColor3=accent,BorderSizePixel=0},card)
	local title=label(card,o.Title or "LucidUI",13,Theme.Text,true) title.Position=UDim2.fromOffset(14,8) title.Size=UDim2.new(1,-28,0,20)
	local desc=label(card,o.Description or o.Content or "",11,Theme.Muted,false) desc.Position=UDim2.fromOffset(14,30) desc.Size=UDim2.new(1,-28,0,30) desc.TextWrapped=true desc.TextYAlignment=Enum.TextYAlignment.Top
	local duration=o.Duration or o.Time or 4
	tween(card,.2,{Size=UDim2.new(1,0,0,70)})
	local dead=false
	local function kill()
		if dead then return end dead=true
		tween(card,.16,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1})
		task.delay(.18,function() if card then card:Destroy() end end)
	end
	card.MouseButton1Click:Connect(kill)
	task.delay(duration,kill)
end


local function lucidDeepCopy(value)
	if type(value) ~= "table" then return value end
	local out = {}
	for k,v in pairs(value) do out[lucidDeepCopy(k)] = lucidDeepCopy(v) end
	return out
end

local function lucidDisconnectAll(list)
	for _,connection in ipairs(list or {}) do
		pcall(function() connection:Disconnect() end)
	end
	table.clear(list)
end

local function lucidSerialize(value)
	local t = typeof(value)
	if t == "Color3" then
		return {__type="Color3",R=value.R,G=value.G,B=value.B}
	elseif t == "EnumItem" then
		return {__type="EnumItem",Enum=tostring(value.EnumType),Name=value.Name}
	elseif type(value) == "table" then
		local out={}
		for k,v in pairs(value) do out[k]=lucidSerialize(v) end
		return out
	end
	return value
end

local function lucidDeserialize(value)
	if type(value) ~= "table" then return value end
	if value.__type == "Color3" then
		return Color3.new(value.R,value.G,value.B)
	end
	local out={}
	for k,v in pairs(value) do
		if k ~= "__type" then out[k]=lucidDeserialize(v) end
	end
	return out
end

local function lucidJsonEncode(value)
	return game:GetService("HttpService"):JSONEncode(lucidSerialize(value))
end

local function lucidJsonDecode(value)
	return lucidDeserialize(game:GetService("HttpService"):JSONDecode(value))
end

LucidUI.Components = LucidUI.Components or {}
LucidUI.Themes = LucidUI.Themes or {}

LucidUI.Themes.Void = lucidDeepCopy(Theme)
LucidUI.Themes.Blackout = {
	Background=Color3.fromRGB(0,0,0),
	Topbar=Color3.fromRGB(3,3,4),
	Surface=Color3.fromRGB(5,5,7),
	Surface2=Color3.fromRGB(8,8,11),
	Surface3=Color3.fromRGB(13,13,18),
	Hover=Color3.fromRGB(19,19,27),
	Accent=Color3.fromRGB(105,76,255),
	Text=Color3.fromRGB(248,248,252),
	Muted=Color3.fromRGB(120,120,138),
	Border=Color3.fromRGB(26,26,36),
	Success=Color3.fromRGB(69,210,139),
	Warning=Color3.fromRGB(255,191,74),
	Danger=Color3.fromRGB(255,82,105),
	Favorite=Color3.fromRGB(255,197,65)
}
LucidUI.Themes.Amethyst = {
	Background=Color3.fromRGB(3,2,6),
	Topbar=Color3.fromRGB(7,5,11),
	Surface=Color3.fromRGB(10,7,15),
	Surface2=Color3.fromRGB(15,11,22),
	Surface3=Color3.fromRGB(22,16,31),
	Hover=Color3.fromRGB(30,22,42),
	Accent=Color3.fromRGB(139,92,246),
	Text=Color3.fromRGB(248,247,252),
	Muted=Color3.fromRGB(143,134,158),
	Border=Color3.fromRGB(39,31,51),
	Success=Color3.fromRGB(69,210,139),
	Warning=Color3.fromRGB(255,191,74),
	Danger=Color3.fromRGB(255,82,105),
	Favorite=Color3.fromRGB(255,197,65)
}

function LucidUI:RegisterTheme(name,data)
	LucidUI.Themes[name]=data
end

function LucidUI:GetTheme(name)
	return LucidUI.Themes[name]
end

function LucidUI:RegisterIcon(name,id)
	LucidUI.Icons[name]=normalizeIcon(id)
end

function LucidUI:GetIcon(name)
	return LucidUI.Icons[name]
end

local OriginalCreateWindowV4 = LucidUI.CreateWindow

function LucidUI:CreateWindow(options)
	options=options or {}
	local loading=options.Loading
	if loading == nil then loading=true end

	local loadingGui
	if loading then
		loadingGui=new("ScreenGui",{Name="LucidLoading",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
		safeParent(loadingGui)

		local root=new("Frame",{
			AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
			Size=UDim2.fromOffset(82,82),BackgroundColor3=Theme.Surface,
			BackgroundTransparency=1,BorderSizePixel=0
		},loadingGui)
		corner(root,18)
		stroke(root,Theme.Border,1)

		local mark=label(root,"L",28,Theme.Text,true)
		mark.AnchorPoint=Vector2.new(.5,.5)
		mark.Position=UDim2.fromScale(.5,.43)
		mark.Size=UDim2.fromOffset(44,44)
		mark.TextXAlignment=Enum.TextXAlignment.Center
		mark.TextTransparency=1

		local name=label(root,options.Title or "LUCID",10,Theme.Muted,true)
		name.AnchorPoint=Vector2.new(.5,1)
		name.Position=UDim2.new(.5,0,1,-10)
		name.Size=UDim2.fromOffset(160,16)
		name.TextXAlignment=Enum.TextXAlignment.Center
		name.TextTransparency=1

		local line=new("Frame",{
			AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,0),
			Size=UDim2.new(0,0,0,2),BackgroundColor3=Theme.Accent,
			BorderSizePixel=0
		},root)
		corner(line,4)

		tween(root,.28,{Size=UDim2.fromOffset(260,110),BackgroundTransparency=0})
		tween(mark,.22,{TextTransparency=0})
		task.wait(.12)
		tween(name,.22,{TextTransparency=0})
		tween(line,.7,{Size=UDim2.new(.84,0,0,2)})
		task.wait(options.LoadingTime or .75)
		tween(root,.22,{Size=UDim2.fromOffset(300,120),BackgroundTransparency=1})
		tween(mark,.18,{TextTransparency=1})
		tween(name,.18,{TextTransparency=1})
		task.wait(.2)
	end

	local window=OriginalCreateWindowV4(self,options)
	window.Flags={}
	window.FlagObjects={}
	window.Connections={}
	window.Popups={}
	window.Modals={}
	window.ThemeName=options.Theme or "Void"
	window.ConfigFolder=options.ConfigFolder or "LucidUI"
	window.ConfigName=options.ConfigName or "default"
	window.ToggleKey=options.ToggleKey or Enum.KeyCode.Tab
	window.CommandKey=options.CommandKey or Enum.KeyCode.K
	window.CommandModifier=options.CommandModifier or Enum.KeyCode.LeftControl
	window._ModifierDown=false
	window._Destroyed=false

	if loadingGui then loadingGui:Destroy() end

	window.Main.Size=window.Size-UDim2.fromOffset(34,34)
	window.Main.BackgroundTransparency=1
	window.Shadow.BackgroundTransparency=1
	tween(window.Main,.3,{Size=window.Size,BackgroundTransparency=0})
	tween(window.Shadow,.3,{BackgroundTransparency=.34})

	window:_CreateCommandPalette()
	window:_CreateModalLayer()
	window:_CreateToastCenter()

	table.insert(window.Connections,UserInputService.InputBegan:Connect(function(input,processed)
		if input.KeyCode==window.CommandModifier then
			window._ModifierDown=true
		end
		if not processed and input.KeyCode==window.CommandKey and window._ModifierDown then
			window:ToggleCommandPalette()
		end
	end))

	table.insert(window.Connections,UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode==window.CommandModifier then
			window._ModifierDown=false
		end
	end))

	return window
end

function Window:RegisterFlag(flag,object,default)
	if not flag or flag=="" then return end
	self.Flags[flag]=default
	self.FlagObjects[flag]=object
end

function Window:SetFlag(flag,value,fire)
	self.Flags[flag]=value
	local object=self.FlagObjects[flag]
	if object and object.Set then
		object:Set(value,fire~=false)
	end
end

function Window:GetFlag(flag)
	return self.Flags[flag]
end

function Window:GetFlags()
	return lucidDeepCopy(self.Flags)
end

function Window:SetAccent(color)
	Theme.Accent=color
	if self.FavoriteButton then
		self.FavoriteButton.BackgroundColor3=self.FavoriteMode and Color3.fromRGB(40,31,12) or Theme.Surface2
	end
	for _,tab in ipairs(self.Tabs) do
		if tab.Indicator then tab.Indicator.BackgroundColor3=color end
	end
end

function Window:SetTheme(name)
	local source=LucidUI.Themes[name]
	if not source then return false end
	self.ThemeName=name
	for k,v in pairs(source) do Theme[k]=v end
	self.Main.BackgroundColor3=Theme.Background
	self.Topbar.BackgroundColor3=Theme.Topbar
	for _,tab in ipairs(self.Tabs) do
		tab.Button.BackgroundColor3=Theme.Surface2
		tab.Label.TextColor3=tab==self.CurrentTab and Theme.Text or Theme.Muted
		if tab.IconObject then
			tab.IconObject.ImageColor3=tab==self.CurrentTab and Theme.Accent or Theme.Muted
		end
		tab.Indicator.BackgroundColor3=Theme.Accent
	end
	for _,component in ipairs(self.Components) do
		if component.Card and component.Card.Parent then
			component.Card.BackgroundColor3=Theme.Surface2
		end
	end
	return true
end

function Window:Show()
	self.SetVisible(true)
end

function Window:Hide()
	self.SetVisible(false)
end

function Window:Toggle()
	self.SetVisible(not self.Visible)
end

function Window:Destroy()
	if self._Destroyed then return end
	self._Destroyed=true
	lucidDisconnectAll(self.Connections)
	if self.Gui then self.Gui:Destroy() end
end

function Window:ClosePopups(except)
	for popup,_ in pairs(self.Popups) do
		if popup~=except and popup and popup.Parent then
			popup:Destroy()
			self.Popups[popup]=nil
		end
	end
end


function Window:ClampPopup(popup)
	task.defer(function()
		if not popup or not popup.Parent then return end
		local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
		local x=math.clamp(popup.AbsolutePosition.X,8,math.max(8,viewport.X-popup.AbsoluteSize.X-8))
		local y=math.clamp(popup.AbsolutePosition.Y,8,math.max(8,viewport.Y-popup.AbsoluteSize.Y-8))
		popup.Position=UDim2.fromOffset(x,y)
	end)
	return popup
end

function Window:RegisterPopup(popup)
	self:ClosePopups(popup)
	self.Popups[popup]=true
	self:ClampPopup(popup)
	return popup
end

function Window:_CreateModalLayer()
	local layer=new("Frame",{
		Name="ModalLayer",Visible=false,Size=UDim2.fromScale(1,1),
		BackgroundColor3=Color3.new(),BackgroundTransparency=.35,
		BorderSizePixel=0,ZIndex=300
	},self.Gui)
	self.ModalLayer=layer
end

function Window:Confirm(options)
	options=options or {}
	local layer=self.ModalLayer
	layer.Visible=true
	for _,child in ipairs(layer:GetChildren()) do child:Destroy() end

	local card=new("Frame",{
		AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
		Size=UDim2.fromOffset(390,190),BackgroundColor3=Theme.Surface,
		BorderSizePixel=0,ZIndex=301
	},layer)
	corner(card,12)
	stroke(card,Theme.Border,.05)

	local title=label(card,options.Title or "Confirm",16,Theme.Text,true)
	title.Position=UDim2.fromOffset(18,16)
	title.Size=UDim2.new(1,-36,0,24)
	title.ZIndex=302

	local body=label(card,options.Content or options.Description or "Are you sure?",12,Theme.Muted,false)
	body.Position=UDim2.fromOffset(18,48)
	body.Size=UDim2.new(1,-36,0,70)
	body.TextWrapped=true
	body.TextYAlignment=Enum.TextYAlignment.Top
	body.ZIndex=302

	local cancel=button(card,options.CancelText or "Cancel",11,Theme.Text,true)
	cancel.Position=UDim2.new(1,-194,1,-52)
	cancel.Size=UDim2.fromOffset(80,32)
	cancel.BackgroundTransparency=0
	cancel.BackgroundColor3=Theme.Surface3
	cancel.ZIndex=302
	corner(cancel,8)

	local accept=button(card,options.AcceptText or "Confirm",11,Theme.Text,true)
	accept.Position=UDim2.new(1,-106,1,-52)
	accept.Size=UDim2.fromOffset(88,32)
	accept.BackgroundTransparency=0
	accept.BackgroundColor3=Theme.Accent
	accept.ZIndex=302
	corner(accept,8)

	local function close()
		layer.Visible=false
		for _,child in ipairs(layer:GetChildren()) do child:Destroy() end
	end

	cancel.MouseButton1Click:Connect(function()
		close()
		if options.OnCancel then task.spawn(options.OnCancel) end
	end)

	accept.MouseButton1Click:Connect(function()
		close()
		if options.Callback then task.spawn(options.Callback,true) end
	end)
end

function Window:_CreateToastCenter()
	local center=new("Frame",{
		Name="ToastCenter",AnchorPoint=Vector2.new(1,0),
		Position=UDim2.new(1,-16,0,16),Size=UDim2.fromOffset(340,560),
		BackgroundTransparency=1
	},self.Gui)
	new("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},center)
	self.ToastCenter=center
end

function Window:Toast(options)
	options=options or {}
	local card=new("Frame",{
		Size=UDim2.new(1,0,0,0),BackgroundColor3=Theme.Surface,
		BorderSizePixel=0,ClipsDescendants=true
	},self.ToastCenter)
	corner(card,9)
	stroke(card,Theme.Border,.08)

	local iconBox=new("Frame",{
		Position=UDim2.fromOffset(10,12),Size=UDim2.fromOffset(34,34),
		BackgroundColor3=Theme.Surface3,BorderSizePixel=0
	},card)
	corner(iconBox,8)

	local mark=label(iconBox,options.Mark or "L",14,options.Color or Theme.Accent,true)
	mark.Size=UDim2.fromScale(1,1)
	mark.TextXAlignment=Enum.TextXAlignment.Center

	local title=label(card,options.Title or "Lucid",12,Theme.Text,true)
	title.Position=UDim2.fromOffset(54,9)
	title.Size=UDim2.new(1,-70,0,20)

	local desc=label(card,options.Content or "",10,Theme.Muted,false)
	desc.Position=UDim2.fromOffset(54,29)
	desc.Size=UDim2.new(1,-70,0,28)
	desc.TextWrapped=true
	desc.TextYAlignment=Enum.TextYAlignment.Top

	local life=options.Duration or 4
	local progress=new("Frame",{
		AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),
		Size=UDim2.new(1,0,0,2),BackgroundColor3=options.Color or Theme.Accent,
		BorderSizePixel=0
	},card)

	tween(card,.2,{Size=UDim2.new(1,0,0,66)})
	tween(progress,life,{Size=UDim2.new(0,0,0,2)})
	task.delay(life,function()
		if not card.Parent then return end
		tween(card,.16,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1})
		task.wait(.17)
		if card then card:Destroy() end
	end)
end

function Window:_CreateCommandPalette()
	local overlay=new("Frame",{
		Name="CommandPalette",Visible=false,Size=UDim2.fromScale(1,1),
		BackgroundColor3=Color3.new(),BackgroundTransparency=.45,
		BorderSizePixel=0,ZIndex=200
	},self.Gui)

	local card=new("Frame",{
		AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,90),
		Size=UDim2.fromOffset(540,390),BackgroundColor3=Theme.Surface,
		BorderSizePixel=0,ZIndex=201
	},overlay)
	corner(card,12)
	stroke(card,Theme.Border,.05)

	local search=new("TextBox",{
		Position=UDim2.fromOffset(12,12),Size=UDim2.new(1,-24,0,42),
		BackgroundColor3=Theme.Surface2,BorderSizePixel=0,Text="",
		PlaceholderText="Type a command or option...",PlaceholderColor3=Theme.Muted,
		TextColor3=Theme.Text,TextSize=12,Font=Enum.Font.Gotham,
		ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202
	},card)
	corner(search,8)
	pad(search,12,12,0,0)

	local results=new("ScrollingFrame",{
		Position=UDim2.fromOffset(12,64),Size=UDim2.new(1,-24,1,-76),
		BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,
		CanvasSize=UDim2.new(),ZIndex=202
	},card)
	local layout=new("UIListLayout",{Padding=UDim.new(0,6)},results)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		results.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8)
	end)

	self.CommandOverlay=overlay
	self.CommandSearch=search
	self.CommandResults=results

	local function rebuild()
		for _,child in ipairs(results:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		local q=search.Text:lower()
		for _,component in ipairs(self.Components) do
			local hay=(component.Name.." "..component.Description.." "..component.Tab.Name.." "..component.Section.Name):lower()
			if q=="" or hay:find(q,1,true) then
				local row=button(results,"",11,Theme.Text,false)
				row.Size=UDim2.new(1,0,0,46)
				row.BackgroundTransparency=0
				row.BackgroundColor3=Theme.Surface2
				row.ZIndex=203
				corner(row,7)

				local n=label(row,component.Name,11,Theme.Text,true)
				n.Position=UDim2.fromOffset(10,3)
				n.Size=UDim2.new(1,-20,0,20)
				n.ZIndex=204

				local path=label(row,component.Tab.Name.."  ›  "..component.Section.Name,9,Theme.Muted,false)
				path.Position=UDim2.fromOffset(10,23)
				path.Size=UDim2.new(1,-20,0,16)
				path.ZIndex=204

				row.MouseButton1Click:Connect(function()
					overlay.Visible=false
					self:Show()
					self:SelectTab(component.Tab)
					if component.Card then
						tween(component.Card,.12,{BackgroundColor3=Theme.Hover})
						task.delay(.35,function()
							if component.Card and component.Card.Parent then
								tween(component.Card,.18,{BackgroundColor3=Theme.Surface2})
							end
						end)
					end
				end)
			end
		end
	end

	search:GetPropertyChangedSignal("Text"):Connect(rebuild)
	self._RebuildCommands=rebuild
end

function Window:ToggleCommandPalette()
	self.CommandOverlay.Visible=not self.CommandOverlay.Visible
	if self.CommandOverlay.Visible then
		self.CommandSearch.Text=""
		self._RebuildCommands()
		self.CommandSearch:CaptureFocus()
	end
end

function Window:SaveConfig(name)
	name=name or self.ConfigName
	if not writefile or not isfolder or not makefolder then return false,"filesystem unavailable" end
	if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
	local path=self.ConfigFolder.."/"..name..".json"
	local ok,err=pcall(function()
		writefile(path,lucidJsonEncode(self.Flags))
	end)
	return ok,err
end

function Window:LoadConfig(name)
	name=name or self.ConfigName
	if not readfile or not isfile then return false,"filesystem unavailable" end
	local path=self.ConfigFolder.."/"..name..".json"
	if not isfile(path) then return false,"config not found" end
	local ok,data=pcall(function() return lucidJsonDecode(readfile(path)) end)
	if not ok then return false,data end
	for flag,value in pairs(data) do
		self:SetFlag(flag,value,true)
	end
	return true
end

function Window:DeleteConfig(name)
	name=name or self.ConfigName
	if not delfile or not isfile then return false,"filesystem unavailable" end
	local path=self.ConfigFolder.."/"..name..".json"
	if isfile(path) then delfile(path) end
	return true
end

function Window:ListConfigs()
	if not listfiles or not isfolder then return {} end
	if not isfolder(self.ConfigFolder) then return {} end
	local out={}
	for _,path in ipairs(listfiles(self.ConfigFolder)) do
		local name=path:match("([^/\\]+)%.json$")
		if name then table.insert(out,name) end
	end
	return out
end

function Tab:AddSubTabs(options)
	options=options or {}
	local holder=new("Frame",{
		Size=UDim2.new(1,0,0,46),AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundColor3=Theme.Surface,BorderSizePixel=0
	},self.Page)
	corner(holder,10)
	stroke(holder,Theme.Border,.25)
	pad(holder,8,8,8,8)

	local bar=new("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1},holder)
	local layout=new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},bar)

	local pages=new("Frame",{
		Position=UDim2.fromOffset(0,42),Size=UDim2.new(1,0,0,0),
		AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1
	},holder)

	local object={Tabs={},Current=nil}

	function object:Add(name)
		local b=button(bar,name,10,Theme.Muted,true)
		b.Size=UDim2.fromOffset(100,32)
		b.BackgroundTransparency=0
		b.BackgroundColor3=Theme.Surface2
		corner(b,7)

		local page=new("Frame",{
			Visible=false,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1
		},pages)
		new("UIListLayout",{Padding=UDim.new(0,7)},page)

		local sub={Name=name,Button=b,Page=page}
		function sub:AddLabel(text)
			local l=label(page,text,11,Theme.Text,false)
			l.Size=UDim2.new(1,0,0,30)
			return l
		end
		function sub:AddButton(opts)
			opts=opts or {}
			local x=button(page,opts.Name or "Button",11,Theme.Text,true)
			x.Size=UDim2.new(1,0,0,38)
			x.BackgroundTransparency=0
			x.BackgroundColor3=Theme.Surface2
			corner(x,7)
			x.MouseButton1Click:Connect(opts.Callback or function() end)
			return x
		end

		table.insert(object.Tabs,sub)

		local function select()
			for _,t in ipairs(object.Tabs) do
				local active=t==sub
				t.Page.Visible=active
				t.Button.TextColor3=active and Theme.Text or Theme.Muted
				t.Button.BackgroundColor3=active and Theme.Surface3 or Theme.Surface2
			end
			object.Current=sub
		end

		b.MouseButton1Click:Connect(select)
		if not object.Current then select() end
		return sub
	end

	return object
end

function Section:AddParagraph(o)
	if type(o)=="string" then o={Title="",Content=o} end
	o=o or {}
	local card,c=self:_Card(o.Title or o.Name or "Paragraph",nil,o.Height or 92)
	local body=label(card,o.Content or o.Description or "",11,Theme.Muted,false)
	body.Position=UDim2.fromOffset(12,30)
	body.Size=UDim2.new(1,-54,1,-40)
	body.TextWrapped=true
	body.TextYAlignment=Enum.TextYAlignment.Top
	c.Set=function(_,text) body.Text=tostring(text) end
	c.Get=function() return body.Text end
	return c
end

function Section:AddDivider(o)
	o=o or {}
	local text=type(o)=="string" and o or o.Text
	local frame=new("Frame",{Size=UDim2.new(1,0,0,text and 30 or 16),BackgroundTransparency=1},self.Content)
	local line=new("Frame",{
		AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
		Size=UDim2.new(1,0,0,1),BackgroundColor3=Theme.Border,BorderSizePixel=0
	},frame)
	if text then
		local tag=label(frame,text,9,Theme.Muted,true)
		tag.AnchorPoint=Vector2.new(.5,.5)
		tag.Position=UDim2.fromScale(.5,.5)
		tag.Size=UDim2.fromOffset(math.max(70,#text*7+18),22)
		tag.BackgroundTransparency=0
		tag.BackgroundColor3=Theme.Surface
		tag.TextXAlignment=Enum.TextXAlignment.Center
	end
	return frame
end

function Section:AddBadge(o)
	o=o or {}
	local card,c=self:_Card(o.Name or "Badge",o.Description,48)
	local badge=label(card,o.Text or "NEW",9,o.Color or Theme.Text,true)
	badge.AnchorPoint=Vector2.new(1,.5)
	badge.Position=UDim2.new(1,-42,.5,0)
	badge.Size=UDim2.fromOffset(o.Width or 62,24)
	badge.BackgroundTransparency=0
	badge.BackgroundColor3=o.Background or Theme.Surface3
	badge.TextXAlignment=Enum.TextXAlignment.Center
	corner(badge,12)
	c.Set=function(_,text) badge.Text=tostring(text) end
	return c
end

function Section:AddProgress(o)
	o=o or {}
	local value=math.clamp(o.Default or 0,o.Min or 0,o.Max or 100)
	local min,max=o.Min or 0,o.Max or 100
	local card,c=self:_Card(o.Name or "Progress",o.Description,66)
	local valueLabel=label(card,tostring(value)..(o.Suffix or "%"),10,Theme.Muted,true)
	valueLabel.AnchorPoint=Vector2.new(1,0)
	valueLabel.Position=UDim2.new(1,-42,0,7)
	valueLabel.Size=UDim2.fromOffset(70,18)
	valueLabel.TextXAlignment=Enum.TextXAlignment.Right

	local track=new("Frame",{
		Position=UDim2.new(0,12,1,-17),Size=UDim2.new(1,-56,0,6),
		BackgroundColor3=Theme.Surface3,BorderSizePixel=0
	},card)
	corner(track,8)

	local fill=new("Frame",{
		Size=UDim2.new((value-min)/(max-min),0,1,0),
		BackgroundColor3=o.Color or Theme.Accent,BorderSizePixel=0
	},track)
	corner(fill,8)

	local function set(v)
		value=math.clamp(v,min,max)
		tween(fill,.18,{Size=UDim2.new((value-min)/(max-min),0,1,0)})
		valueLabel.Text=tostring(value)..(o.Suffix or "%")
	end
	c.Set=function(_,v) set(v) end
	c.Get=function() return value end
	return c
end

function Section:AddNumberbox(o)
	o=o or {}
	local value=tonumber(o.Default) or 0
	local min,max=o.Min or -math.huge,o.Max or math.huge
	local step=o.Step or 1
	local card,c=self:_Card(o.Name or "Number",o.Description,52)

	local minus=button(card,"−",16,Theme.Text,true)
	minus.AnchorPoint=Vector2.new(1,.5)
	minus.Position=UDim2.new(1,-142,.5,0)
	minus.Size=UDim2.fromOffset(30,30)
	minus.BackgroundTransparency=0
	minus.BackgroundColor3=Theme.Surface3
	corner(minus,7)

	local box=new("TextBox",{
		AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-78,.5,0),
		Size=UDim2.fromOffset(58,30),BackgroundColor3=Theme.Surface3,
		BorderSizePixel=0,Text=tostring(value),TextColor3=Theme.Text,
		TextSize=11,Font=Enum.Font.GothamBold,ClearTextOnFocus=false
	},card)
	corner(box,7)

	local plus=button(card,"+",15,Theme.Text,true)
	plus.AnchorPoint=Vector2.new(1,.5)
	plus.Position=UDim2.new(1,-42,.5,0)
	plus.Size=UDim2.fromOffset(30,30)
	plus.BackgroundTransparency=0
	plus.BackgroundColor3=Theme.Surface3
	corner(plus,7)

	local function set(v,fire)
		value=math.clamp(tonumber(v) or value,min,max)
		if o.Decimals then
			local m=10^o.Decimals
			value=math.floor(value*m+.5)/m
		end
		box.Text=tostring(value)
		if fire then task.spawn(o.Callback or function() end,value) end
		if o.Flag then self.Window.Flags[o.Flag]=value end
	end

	minus.MouseButton1Click:Connect(function() set(value-step,true) end)
	plus.MouseButton1Click:Connect(function() set(value+step,true) end)
	box.FocusLost:Connect(function() set(box.Text,true) end)

	c.Set=function(_,v,fire) set(v,fire~=false) end
	c.Get=function() return value end
	if o.Flag then self.Window:RegisterFlag(o.Flag,c,value) end
	return c
end

function Section:AddKeybind(o)
	o=o or {}
	local current=o.Default or Enum.KeyCode.Unknown
	local listening=false
	local card,c=self:_Card(o.Name or "Keybind",o.Description,52)

	local key=button(card,current.Name,10,Theme.Text,true)
	key.AnchorPoint=Vector2.new(1,.5)
	key.Position=UDim2.new(1,-42,.5,0)
	key.Size=UDim2.fromOffset(100,30)
	key.BackgroundTransparency=0
	key.BackgroundColor3=Theme.Surface3
	corner(key,7)

	key.MouseButton1Click:Connect(function()
		listening=true
		key.Text="..."
		tween(key,.12,{BackgroundColor3=Theme.Hover})
	end)

	local connection=UserInputService.InputBegan:Connect(function(input,processed)
		if listening and input.UserInputType==Enum.UserInputType.Keyboard then
			listening=false
			current=input.KeyCode
			key.Text=current.Name
			key.BackgroundColor3=Theme.Surface3
			if o.Flag then self.Window.Flags[o.Flag]=current.Name end
			if o.Changed then task.spawn(o.Changed,current) end
			return
		end
		if not processed and input.KeyCode==current then
			task.spawn(o.Callback or function() end,current)
		end
	end)
	table.insert(self.Window.Connections,connection)

	c.Set=function(_,v)
		if typeof(v)=="EnumItem" then current=v
		elseif type(v)=="string" and Enum.KeyCode[v] then current=Enum.KeyCode[v] end
		key.Text=current.Name
	end
	c.Get=function() return current end
	if o.Flag then self.Window:RegisterFlag(o.Flag,c,current.Name) end
	return c
end

function Section:AddButtonGroup(o)
	o=o or {}
	local card,c=self:_Card(o.Name or "Actions",o.Description,58)
	local holder=new("Frame",{
		Position=UDim2.new(.36,0,.5,-16),Size=UDim2.new(.64,-42,0,32),
		BackgroundTransparency=1
	},card)
	local layout=new("UIListLayout",{
		FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,
		Padding=UDim.new(0,5)
	},holder)
	for _,item in ipairs(o.Buttons or {}) do
		local b=button(holder,item.Name or "Action",10,Theme.Text,true)
		b.Size=UDim2.fromOffset(item.Width or 76,30)
		b.BackgroundTransparency=0
		b.BackgroundColor3=Theme.Surface3
		corner(b,7)
		b.MouseEnter:Connect(function() tween(b,.1,{BackgroundColor3=Theme.Hover}) end)
		b.MouseLeave:Connect(function() tween(b,.1,{BackgroundColor3=Theme.Surface3}) end)
		b.MouseButton1Click:Connect(item.Callback or function() end)
	end
	return c
end

function Section:AddRadioGroup(o)
	o=o or {}
	local values=o.Values or {}
	local selected=o.Default or values[1]
	local height=50+#values*34
	local card,c=self:_Card(o.Name or "Radio",o.Description,height)
	local holder=new("Frame",{
		Position=UDim2.fromOffset(12,42),Size=UDim2.new(1,-54,0,#values*32),
		BackgroundTransparency=1
	},card)
	new("UIListLayout",{Padding=UDim.new(0,3)},holder)
	local rows={}

	local function set(v,fire)
		selected=v
		for value,row in pairs(rows) do
			row.Dot.BackgroundColor3=value==selected and Theme.Accent or Theme.Surface3
			row.Text.TextColor3=value==selected and Theme.Text or Theme.Muted
		end
		if o.Flag then self.Window.Flags[o.Flag]=selected end
		if fire then task.spawn(o.Callback or function() end,selected) end
	end

	for _,value in ipairs(values) do
		local row=button(holder,"",10,Theme.Text,false)
		row.Size=UDim2.new(1,0,0,29)
		local dot=new("Frame",{
			Position=UDim2.new(0,2,.5,-7),Size=UDim2.fromOffset(14,14),
			BackgroundColor3=value==selected and Theme.Accent or Theme.Surface3,
			BorderSizePixel=0
		},row)
		corner(dot,10)
		stroke(dot,Theme.Border,.2)
		local tx=label(row,tostring(value),10,value==selected and Theme.Text or Theme.Muted,false)
		tx.Position=UDim2.fromOffset(25,0)
		tx.Size=UDim2.new(1,-25,1,0)
		rows[value]={Dot=dot,Text=tx}
		row.MouseButton1Click:Connect(function() set(value,true) end)
	end

	c.Set=function(_,v,fire) set(v,fire~=false) end
	c.Get=function() return selected end
	if o.Flag then self.Window:RegisterFlag(o.Flag,c,selected) end
	return c
end

function Section:AddMultiDropdown(o)
	o=o or {}
	local values=o.Values or {}
	local selected={}
	for _,v in ipairs(o.Default or {}) do selected[v]=true end
	local card,c=self:_Card(o.Name or "Multi Dropdown",o.Description,52)
	local pick=button(card,"Select",10,Theme.Text,false)
	pick.AnchorPoint=Vector2.new(1,.5)
	pick.Position=UDim2.new(1,-42,.5,0)
	pick.Size=UDim2.fromOffset(180,30)
	pick.BackgroundTransparency=0
	pick.BackgroundColor3=Theme.Surface3
	corner(pick,7)
	local popup

	local function array()
		local out={}
		for _,v in ipairs(values) do if selected[v] then table.insert(out,v) end end
		return out
	end

	local function refresh()
		local a=array()
		if #a==0 then pick.Text="Select"
		elseif #a==1 then pick.Text=tostring(a[1])
		else pick.Text=tostring(#a).." selected" end
		if o.Flag then self.Window.Flags[o.Flag]=a end
	end
	refresh()

	pick.MouseButton1Click:Connect(function()
		if popup then popup:Destroy() popup=nil return end
		popup=new("Frame",{
			Position=UDim2.fromOffset(pick.AbsolutePosition.X+pick.AbsoluteSize.X-210,pick.AbsolutePosition.Y+pick.AbsoluteSize.Y+5),
			Size=UDim2.fromOffset(210,math.min(#values*35+12,220)),
			BackgroundColor3=Theme.Surface,BorderSizePixel=0,ZIndex=160
		},self.Window.Gui)
		corner(popup,9)
		stroke(popup,Theme.Border,.05)
		self.Window:RegisterPopup(popup)

		local list=new("ScrollingFrame",{
			Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
			ScrollBarThickness=2,CanvasSize=UDim2.fromOffset(0,#values*35+8),ZIndex=161
		},popup)
		pad(list,6,6,6,6)
		new("UIListLayout",{Padding=UDim.new(0,4)},list)

		for _,value in ipairs(values) do
			local row=button(list,"",10,Theme.Text,false)
			row.Size=UDim2.new(1,0,0,31)
			row.BackgroundTransparency=0
			row.BackgroundColor3=Theme.Surface2
			row.ZIndex=162
			corner(row,6)

			local check=new("Frame",{
				Position=UDim2.new(0,7,.5,-7),Size=UDim2.fromOffset(14,14),
				BackgroundColor3=selected[value] and Theme.Accent or Theme.Surface3,
				BorderSizePixel=0,ZIndex=163
			},row)
			corner(check,4)

			local tx=label(row,tostring(value),10,Theme.Text,false)
			tx.Position=UDim2.fromOffset(29,0)
			tx.Size=UDim2.new(1,-35,1,0)
			tx.ZIndex=163

			row.MouseButton1Click:Connect(function()
				selected[value]=not selected[value]
				check.BackgroundColor3=selected[value] and Theme.Accent or Theme.Surface3
				refresh()
				task.spawn(o.Callback or function() end,array())
			end)
		end
	end)

	c.Get=function() return array() end
	c.Set=function(_,items,fire)
		table.clear(selected)
		for _,v in ipairs(items or {}) do selected[v]=true end
		refresh()
		if fire~=false then task.spawn(o.Callback or function() end,array()) end
	end
	if o.Flag then self.Window:RegisterFlag(o.Flag,c,array()) end
	return c
end

function Section:AddColorPicker(o)
	o=o or {}
	local value=o.Default or Color3.fromRGB(255,255,255)
	local hue,sat,val=Color3.toHSV(value)
	local card,c=self:_Card(o.Name or "Color",o.Description,52)

	local preview=button(card,"",1,Theme.Text,false)
	preview.AnchorPoint=Vector2.new(1,.5)
	preview.Position=UDim2.new(1,-42,.5,0)
	preview.Size=UDim2.fromOffset(54,28)
	preview.BackgroundTransparency=0
	preview.BackgroundColor3=value
	corner(preview,7)
	stroke(preview,Theme.Border,.2)

	local popup
	local function setColor(color,fire)
		value=color
		hue,sat,val=Color3.toHSV(value)
		preview.BackgroundColor3=value
		if o.Flag then self.Window.Flags[o.Flag]=value end
		if fire then task.spawn(o.Callback or function() end,value) end
	end

	preview.MouseButton1Click:Connect(function()
		if popup then popup:Destroy() popup=nil return end
		popup=new("Frame",{
			Position=UDim2.fromOffset(preview.AbsolutePosition.X+preview.AbsoluteSize.X-250,preview.AbsolutePosition.Y+preview.AbsoluteSize.Y+5),
			Size=UDim2.fromOffset(250,225),BackgroundColor3=Theme.Surface,
			BorderSizePixel=0,ZIndex=170
		},self.Window.Gui)
		corner(popup,10)
		stroke(popup,Theme.Border,.05)
		self.Window:RegisterPopup(popup)

		local sv=new("Frame",{
			Position=UDim2.fromOffset(10,10),Size=UDim2.new(1,-20,0,150),
			BackgroundColor3=Color3.fromHSV(hue,1,1),BorderSizePixel=0,ZIndex=171
		},popup)
		corner(sv,7)

		local white=new("UIGradient",{
			Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1)),
			Transparency=NumberSequence.new({
				NumberSequenceKeypoint.new(0,0),
				NumberSequenceKeypoint.new(1,1)
			})
		},sv)

		local black=new("Frame",{
			Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(),
			BackgroundTransparency=1,BorderSizePixel=0,ZIndex=172
		},sv)
		corner(black,7)
		local bg=new("UIGradient",{
			Rotation=90,
			Color=ColorSequence.new(Color3.new(),Color3.new()),
			Transparency=NumberSequence.new({
				NumberSequenceKeypoint.new(0,1),
				NumberSequenceKeypoint.new(1,0)
			})
		},black)

		local hueBar=new("Frame",{
			Position=UDim2.fromOffset(10,170),Size=UDim2.new(1,-20,0,18),
			BorderSizePixel=0,ZIndex=171
		},popup)
		corner(hueBar,6)
		new("UIGradient",{
			Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),
				ColorSequenceKeypoint.new(.17,Color3.fromHSV(.17,1,1)),
				ColorSequenceKeypoint.new(.33,Color3.fromHSV(.33,1,1)),
				ColorSequenceKeypoint.new(.5,Color3.fromHSV(.5,1,1)),
				ColorSequenceKeypoint.new(.67,Color3.fromHSV(.67,1,1)),
				ColorSequenceKeypoint.new(.83,Color3.fromHSV(.83,1,1)),
				ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))
			})
		},hueBar)

		local hex=new("TextBox",{
			Position=UDim2.fromOffset(10,196),Size=UDim2.new(1,-20,0,22),
			BackgroundColor3=Theme.Surface2,BorderSizePixel=0,
			Text=string.format("#%02X%02X%02X",math.floor(value.R*255),math.floor(value.G*255),math.floor(value.B*255)),
			TextColor3=Theme.Text,TextSize=10,Font=Enum.Font.Gotham,
			ClearTextOnFocus=false,ZIndex=171
		},popup)
		corner(hex,6)

		local draggingSV=false
		local draggingHue=false

		local function updateSV(pos)
			local x=math.clamp((pos.X-sv.AbsolutePosition.X)/sv.AbsoluteSize.X,0,1)
			local y=math.clamp((pos.Y-sv.AbsolutePosition.Y)/sv.AbsoluteSize.Y,0,1)
			sat=x val=1-y
			setColor(Color3.fromHSV(hue,sat,val),true)
			hex.Text=string.format("#%02X%02X%02X",math.floor(value.R*255),math.floor(value.G*255),math.floor(value.B*255))
		end

		local function updateHue(pos)
			hue=math.clamp((pos.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1)
			sv.BackgroundColor3=Color3.fromHSV(hue,1,1)
			setColor(Color3.fromHSV(hue,sat,val),true)
			hex.Text=string.format("#%02X%02X%02X",math.floor(value.R*255),math.floor(value.G*255),math.floor(value.B*255))
		end

		sv.InputBegan:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingSV=true updateSV(i.Position) end
		end)
		hueBar.InputBegan:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingHue=true updateHue(i.Position) end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseMovement then
				if draggingSV then updateSV(i.Position) end
				if draggingHue then updateHue(i.Position) end
			end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingSV=false draggingHue=false end
		end)

		hex.FocusLost:Connect(function()
			local s=hex.Text:gsub("#","")
			if #s==6 then
				local r=tonumber(s:sub(1,2),16)
				local g=tonumber(s:sub(3,4),16)
				local b=tonumber(s:sub(5,6),16)
				if r and g and b then setColor(Color3.fromRGB(r,g,b),true) end
			end
		end)
	end)

	c.Get=function() return value end
	c.Set=function(_,v,fire) setColor(v,fire~=false) end
	if o.Flag then self.Window:RegisterFlag(o.Flag,c,value) end
	return c
end

function Section:AddCollapsible(o)
	o=o or {}
	local open=o.DefaultOpen==true
	local baseHeight=o.Height or 140
	local card,c=self:_Card(o.Name or "Collapsible",o.Description,48)
	card.ClipsDescendants=true

	local arrow=button(card,open and "−" or "+",16,Theme.Muted,true)
	arrow.AnchorPoint=Vector2.new(1,.5)
	arrow.Position=UDim2.new(1,-42,0,24)
	arrow.Size=UDim2.fromOffset(28,28)
	arrow.BackgroundTransparency=0
	arrow.BackgroundColor3=Theme.Surface3
	corner(arrow,7)

	local content=new("Frame",{
		Visible=open,Position=UDim2.fromOffset(12,52),
		Size=UDim2.new(1,-54,0,baseHeight-64),BackgroundTransparency=1
	},card)
	new("UIListLayout",{Padding=UDim.new(0,5)},content)

	local function set(v)
		open=v
		arrow.Text=open and "−" or "+"
		content.Visible=open
		tween(card,.18,{Size=UDim2.new(1,0,0,open and baseHeight or 48)})
	end
	arrow.MouseButton1Click:Connect(function() set(not open) end)
	if open then card.Size=UDim2.new(1,0,0,baseHeight) end

	local api={Component=c,Content=content}
	function api:AddLabel(text)
		local x=label(content,text,10,Theme.Muted,false)
		x.Size=UDim2.new(1,0,0,28)
		return x
	end
	function api:AddButton(opts)
		opts=opts or {}
		local x=button(content,opts.Name or "Button",10,Theme.Text,true)
		x.Size=UDim2.new(1,0,0,32)
		x.BackgroundTransparency=0
		x.BackgroundColor3=Theme.Surface3
		corner(x,7)
		x.MouseButton1Click:Connect(opts.Callback or function() end)
		return x
	end
	function api:Set(v) set(v) end
	function api:Get() return open end
	return api
end

function Section:AddStatus(o)
	o=o or {}
	local state=o.State or "Online"
	local colors={
		Online=Theme.Success,
		Warning=Theme.Warning,
		Offline=Theme.Danger,
		Idle=Theme.Muted
	}
	local card,c=self:_Card(o.Name or "Status",o.Description,48)
	local dot=new("Frame",{
		AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-112,.5,0),
		Size=UDim2.fromOffset(8,8),BackgroundColor3=o.Color or colors[state] or Theme.Muted,
		BorderSizePixel=0
	},card)
	corner(dot,8)
	local text=label(card,state,10,Theme.Muted,true)
	text.AnchorPoint=Vector2.new(1,.5)
	text.Position=UDim2.new(1,-42,.5,0)
	text.Size=UDim2.fromOffset(62,24)
	text.TextXAlignment=Enum.TextXAlignment.Right
	c.Set=function(_,newState,color)
		state=newState
		text.Text=tostring(newState)
		dot.BackgroundColor3=color or colors[newState] or Theme.Muted
	end
	return c
end

function Section:AddImage(o)
	o=o or {}
	local height=o.Height or 180
	local card,c=self:_Card(o.Name or "Image",nil,height)
	local img=new("ImageLabel",{
		Position=UDim2.fromOffset(10,34),Size=UDim2.new(1,-52,1,-44),
		BackgroundColor3=Theme.Surface3,BorderSizePixel=0,
		Image=normalizeIcon(o.Image or o.AssetId or ""),ScaleType=o.ScaleType or Enum.ScaleType.Crop
	},card)
	corner(img,8)
	c.Set=function(_,id) img.Image=normalizeIcon(id) end
	return c
end

function Section:AddSearchList(o)
	o=o or {}
	local values=o.Values or {}
	local height=o.Height or 260
	local card,c=self:_Card(o.Name or "Search List",nil,height)

	local search=new("TextBox",{
		Position=UDim2.fromOffset(12,34),Size=UDim2.new(1,-54,0,32),
		BackgroundColor3=Theme.Surface3,BorderSizePixel=0,Text="",
		PlaceholderText=o.Placeholder or "Search...",PlaceholderColor3=Theme.Muted,
		TextColor3=Theme.Text,TextSize=10,Font=Enum.Font.Gotham,
		ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left
	},card)
	corner(search,7)
	pad(search,9,9,0,0)

	local list=new("ScrollingFrame",{
		Position=UDim2.fromOffset(12,74),Size=UDim2.new(1,-54,1,-86),
		BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,
		CanvasSize=UDim2.new()
	},card)
	local layout=new("UIListLayout",{Padding=UDim.new(0,4)},list)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+6)
	end)

	local function rebuild()
		for _,child in ipairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		local q=search.Text:lower()
		for _,value in ipairs(values) do
			local text=type(value)=="table" and (value.Name or value.Text or tostring(value)) or tostring(value)
			if q=="" or text:lower():find(q,1,true) then
				local row=button(list,text,10,Theme.Text,false)
				row.Size=UDim2.new(1,0,0,30)
				row.BackgroundTransparency=0
				row.BackgroundColor3=Theme.Surface2
				corner(row,6)
				row.MouseButton1Click:Connect(function()
					task.spawn(o.Callback or function() end,value)
				end)
			end
		end
	end
	search:GetPropertyChangedSignal("Text"):Connect(rebuild)
	rebuild()
	c.Refresh=function(_,newValues) values=newValues or values rebuild() end
	return c
end

function Section:AddConsole(o)
	o=o or {}
	local height=o.Height or 250
	local card,c=self:_Card(o.Name or "Console",nil,height)

	local console=new("ScrollingFrame",{
		Position=UDim2.fromOffset(12,34),Size=UDim2.new(1,-54,1,-46),
		BackgroundColor3=Color3.fromRGB(3,3,5),BorderSizePixel=0,
		ScrollBarThickness=2,CanvasSize=UDim2.new()
	},card)
	corner(console,7)
	pad(console,8,8,8,8)
	local layout=new("UIListLayout",{Padding=UDim.new(0,3)},console)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		console.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+12)
		console.CanvasPosition=Vector2.new(0,math.max(0,layout.AbsoluteContentSize.Y-console.AbsoluteSize.Y))
	end)

	local api={Component=c}
	function api:Log(text,color)
		local row=label(console,tostring(text),10,color or Theme.Muted,false)
		row.Size=UDim2.new(1,0,0,17)
		row.Font=Enum.Font.Code
		return row
	end
	function api:Info(text) return api:Log("[INFO] "..tostring(text),Theme.Muted) end
	function api:Success(text) return api:Log("[OK] "..tostring(text),Theme.Success) end
	function api:Warn(text) return api:Log("[WARN] "..tostring(text),Theme.Warning) end
	function api:Error(text) return api:Log("[ERROR] "..tostring(text),Theme.Danger) end
	function api:Clear()
		for _,child in ipairs(console:GetChildren()) do
			if child:IsA("TextLabel") then child:Destroy() end
		end
	end
	return api
end

function Section:AddMiniGraph(o)
	o=o or {}
	local height=o.Height or 160
	local card,c=self:_Card(o.Name or "Graph",o.Description,height)
	local graph=new("Frame",{
		Position=UDim2.fromOffset(12,38),Size=UDim2.new(1,-54,1,-50),
		BackgroundColor3=Theme.Surface3,BorderSizePixel=0,ClipsDescendants=true
	},card)
	corner(graph,7)
	local points=o.Values or {10,30,22,55,48,80,64}
	local segments={}

	local function render()
		for _,s in ipairs(segments) do s:Destroy() end
		table.clear(segments)
		if #points<2 then return end
		local maxValue=o.Max or 100
		for i=1,#points-1 do
			local x1=(i-1)/(#points-1)
			local x2=i/(#points-1)
			local y1=1-math.clamp(points[i]/maxValue,0,1)
			local y2=1-math.clamp(points[i+1]/maxValue,0,1)
			local a=Vector2.new(x1*graph.AbsoluteSize.X,y1*graph.AbsoluteSize.Y)
			local b=Vector2.new(x2*graph.AbsoluteSize.X,y2*graph.AbsoluteSize.Y)
			local d=b-a
			local line=new("Frame",{
				AnchorPoint=Vector2.new(0,.5),
				Position=UDim2.fromOffset(a.X,a.Y),
				Size=UDim2.fromOffset(d.Magnitude,2),
				Rotation=math.deg(math.atan2(d.Y,d.X)),
				BackgroundColor3=o.Color or Theme.Accent,
				BorderSizePixel=0
			},graph)
			corner(line,3)
			table.insert(segments,line)
		end
	end
	graph:GetPropertyChangedSignal("AbsoluteSize"):Connect(render)
	task.defer(render)

	c.Set=function(_,newPoints) points=newPoints or points render() end
	c.Push=function(_,v)
		table.insert(points,v)
		if #points>(o.MaxPoints or 20) then table.remove(points,1) end
		render()
	end
	c.Get=function() return lucidDeepCopy(points) end
	return c
end

function Section:AddTooltip(target,text)
	local tip=new("TextLabel",{
		Visible=false,BackgroundColor3=Theme.Surface,
		BorderSizePixel=0,Text=tostring(text),TextColor3=Theme.Text,
		TextSize=9,Font=Enum.Font.Gotham,AutomaticSize=Enum.AutomaticSize.XY,
		ZIndex=500
	},self.Window.Gui)
	pad(tip,8,8,5,5)
	corner(tip,6)
	stroke(tip,Theme.Border,.1)

	target.MouseEnter:Connect(function()
		tip.Visible=true
	end)
	target.MouseLeave:Connect(function()
		tip.Visible=false
	end)
	UserInputService.InputChanged:Connect(function(i)
		if tip.Visible and i.UserInputType==Enum.UserInputType.MouseMovement then
			tip.Position=UDim2.fromOffset(i.Position.X+14,i.Position.Y+14)
		end
	end)
	return tip
end

function Section:AddContextMenu(target,items)
	local window=self.Window
	target.MouseButton2Click:Connect(function()
		window:ClosePopups()
		local mouse=UserInputService:GetMouseLocation()
		local menu=new("Frame",{
			Position=UDim2.fromOffset(mouse.X,mouse.Y),
			Size=UDim2.fromOffset(180,#items*34+10),
			BackgroundColor3=Theme.Surface,BorderSizePixel=0,ZIndex=450
		},window.Gui)
		corner(menu,8)
		stroke(menu,Theme.Border,.05)
		pad(menu,5,5,5,5)
		new("UIListLayout",{Padding=UDim.new(0,4)},menu)
		window:RegisterPopup(menu)
		for _,item in ipairs(items) do
			local b=button(menu,item.Name or "Action",10,item.Danger and Theme.Danger or Theme.Text,false)
			b.Size=UDim2.new(1,0,0,30)
			b.BackgroundTransparency=0
			b.BackgroundColor3=Theme.Surface2
			b.ZIndex=451
			corner(b,6)
			b.MouseButton1Click:Connect(function()
				menu:Destroy()
				task.spawn(item.Callback or function() end)
			end)
		end
	end)
end

function Section:AddConfigManager(o)
	o=o or {}
	local card,c=self:_Card(o.Name or "Config Manager",o.Description,120)
	local nameBox=new("TextBox",{
		Position=UDim2.fromOffset(12,42),Size=UDim2.new(1,-54,0,30),
		BackgroundColor3=Theme.Surface3,BorderSizePixel=0,
		Text=o.Default or self.Window.ConfigName,PlaceholderText="Config name",
		PlaceholderColor3=Theme.Muted,TextColor3=Theme.Text,TextSize=10,
		Font=Enum.Font.Gotham,ClearTextOnFocus=false
	},card)
	corner(nameBox,7)

	local holder=new("Frame",{
		Position=UDim2.fromOffset(12,80),Size=UDim2.new(1,-54,0,30),
		BackgroundTransparency=1
	},card)
	local layout=new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},holder)

	local function make(text,callback)
		local b=button(holder,text,9,Theme.Text,true)
		b.Size=UDim2.fromOffset(72,28)
		b.BackgroundTransparency=0
		b.BackgroundColor3=Theme.Surface3
		corner(b,6)
		b.MouseButton1Click:Connect(callback)
	end

	make("Save",function()
		local ok,err=self.Window:SaveConfig(nameBox.Text)
		self.Window:Toast({Title="Config",Content=ok and "Saved successfully." or tostring(err),Color=ok and Theme.Success or Theme.Danger})
	end)
	make("Load",function()
		local ok,err=self.Window:LoadConfig(nameBox.Text)
		self.Window:Toast({Title="Config",Content=ok and "Loaded successfully." or tostring(err),Color=ok and Theme.Success or Theme.Danger})
	end)
	make("Delete",function()
		self.Window:Confirm({
			Title="Delete config",
			Content="Delete config '"..nameBox.Text.."'?",
			AcceptText="Delete",
			Callback=function()
				local ok,err=self.Window:DeleteConfig(nameBox.Text)
				self.Window:Toast({Title="Config",Content=ok and "Deleted." or tostring(err),Color=ok and Theme.Success or Theme.Danger})
			end
		})
	end)
	return c
end

function Section:AddThemeManager(o)
	o=o or {}
	local names={}
	for name,_ in pairs(LucidUI.Themes) do table.insert(names,name) end
	table.sort(names)
	return self:AddDropdown({
		Name=o.Name or "Theme",
		Description=o.Description or "Change Lucid appearance",
		Values=names,
		Default=self.Window.ThemeName,
		Callback=function(value)
			self.Window:SetTheme(value)
			if o.Callback then task.spawn(o.Callback,value) end
		end
	})
end

function Section:AddNotificationTester(o)
	o=o or {}
	return self:AddButton({
		Name=o.Name or "Notification Test",
		Description=o.Description or "Show a Lucid notification",
		ActionText="Test",
		Callback=function()
			self.Window:Toast({
				Title=o.Title or "Lucid",
				Content=o.Content or "Everything is working.",
				Color=o.Color or Theme.Accent,
				Duration=o.Duration or 4
			})
		end
	})
end

function Section:AddSpacer(height)
	return new("Frame",{Size=UDim2.new(1,0,0,height or 10),BackgroundTransparency=1},self.Content)
end

function Section:AddHeader(o)
	if type(o)=="string" then o={Text=o} end
	o=o or {}
	local holder=new("Frame",{Size=UDim2.new(1,0,0,o.Height or 42),BackgroundTransparency=1},self.Content)
	local text=label(holder,o.Text or "Header",o.Size or 16,o.Color or Theme.Text,true)
	text.Size=UDim2.fromScale(1,1)
	return text
end

function Section:AddAvatar(o)
	o=o or {}
	local player=o.Player or Players.LocalPlayer
	local card,c=self:_Card(o.Name or "Profile",o.Description,74)
	local avatar=new("ImageLabel",{
		Position=UDim2.fromOffset(12,12),Size=UDim2.fromOffset(50,50),
		BackgroundColor3=Theme.Surface3,BorderSizePixel=0
	},card)
	corner(avatar,25)
	local display=label(card,player.DisplayName,12,Theme.Text,true)
	display.Position=UDim2.fromOffset(74,13)
	display.Size=UDim2.new(1,-116,0,20)
	local username=label(card,"@"..player.Name,10,Theme.Muted,false)
	username.Position=UDim2.fromOffset(74,34)
	username.Size=UDim2.new(1,-116,0,18)
	task.spawn(function()
		local ok,img=pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
		end)
		if ok and avatar.Parent then avatar.Image=img end
	end)
	c.Set=function(_,p)
		player=p
		display.Text=p.DisplayName
		username.Text="@"..p.Name
		task.spawn(function()
			local ok,img=pcall(function()
				return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
			end)
			if ok and avatar.Parent then avatar.Image=img end
		end)
	end
	return c
end

function Section:AddChips(o)
	o=o or {}
	local selected={}
	local card,c=self:_Card(o.Name or "Tags",o.Description,84)
	local holder=new("Frame",{
		Position=UDim2.fromOffset(12,42),Size=UDim2.new(1,-54,0,32),
		BackgroundTransparency=1
	},card)
	new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},holder)
	for _,value in ipairs(o.Values or {}) do
		local chip=button(holder,tostring(value),9,Theme.Muted,true)
		chip.Size=UDim2.fromOffset(math.max(55,#tostring(value)*7+18),28)
		chip.BackgroundTransparency=0
		chip.BackgroundColor3=Theme.Surface3
		corner(chip,14)
		chip.MouseButton1Click:Connect(function()
			selected[value]=not selected[value]
			chip.TextColor3=selected[value] and Theme.Text or Theme.Muted
			chip.BackgroundColor3=selected[value] and Theme.Accent or Theme.Surface3
			local out={}
			for _,v in ipairs(o.Values or {}) do if selected[v] then table.insert(out,v) end end
			task.spawn(o.Callback or function() end,out)
		end)
	end
	return c
end

function Section:AddLoadingBar(o)
	o=o or {}
	local card,c=self:_Card(o.Name or "Loading",o.Description,66)
	local track=new("Frame",{
		Position=UDim2.new(0,12,1,-17),Size=UDim2.new(1,-54,0,5),
		BackgroundColor3=Theme.Surface3,BorderSizePixel=0
	},card)
	corner(track,5)
	local fill=new("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=o.Color or Theme.Accent,BorderSizePixel=0},track)
	corner(fill,5)
	local running=false
	c.Start=function(_,duration)
		if running then return end
		running=true
		fill.Size=UDim2.new(0,0,1,0)
		local tw=tween(fill,duration or 2,{Size=UDim2.new(1,0,1,0)})
		tw.Completed:Connect(function()
			running=false
			if o.Callback then task.spawn(o.Callback) end
		end)
	end
	c.Reset=function()
		running=false
		fill.Size=UDim2.new(0,0,1,0)
	end
	return c
end

function Section:AddCopyButton(o)
	o=o or {}
	return self:AddButton({
		Name=o.Name or "Copy",
		Description=o.Description,
		ActionText=o.ActionText or "Copy",
		Callback=function()
			if setclipboard then
				setclipboard(tostring(o.Text or ""))
				self.Window:Toast({Title="Clipboard",Content="Copied.",Color=Theme.Success})
			else
				self.Window:Toast({Title="Clipboard",Content="Clipboard unavailable.",Color=Theme.Warning})
			end
			if o.Callback then task.spawn(o.Callback) end
		end
	})
end

function Section:AddDangerButton(o)
	o=o or {}
	local component=self:AddButton(o)
	local card=component.Card
	for _,child in ipairs(card:GetChildren()) do
		if child:IsA("TextButton") and child~=component.Star then
			child.BackgroundColor3=Color3.fromRGB(48,14,20)
			child.TextColor3=Theme.Danger
		end
	end
	return component
end

function Window:CreateWatermark(text)
	local mark=label(self.Gui,text or self.Title,10,Theme.Muted,true)
	mark.Position=UDim2.fromOffset(12,12)
	mark.Size=UDim2.fromOffset(220,26)
	mark.BackgroundTransparency=.08
	mark.BackgroundColor3=Theme.Surface
	mark.TextXAlignment=Enum.TextXAlignment.Center
	corner(mark,7)
	stroke(mark,Theme.Border,.1)
	return {
		Set=function(_,value) mark.Text=tostring(value) end,
		Show=function() mark.Visible=true end,
		Hide=function() mark.Visible=false end,
		Destroy=function() mark:Destroy() end
	}
end

function Window:CreateFloatingButton(o)
	o=o or {}
	local b=button(self.Gui,o.Text or "L",o.TextSize or 14,Theme.Text,true)
	b.AnchorPoint=Vector2.new(1,1)
	b.Position=o.Position or UDim2.new(1,-18,1,-18)
	b.Size=UDim2.fromOffset(o.Size or 46,o.Size or 46)
	b.BackgroundTransparency=0
	b.BackgroundColor3=o.Color or Theme.Surface
	b.ZIndex=150
	corner(b,o.Round and 50 or 12)
	stroke(b,Theme.Border,.05)
	b.MouseButton1Click:Connect(o.Callback or function() self:Toggle() end)
	return b
end

function Window:AddCommand(name,callback,description)
	self.CustomCommands=self.CustomCommands or {}
	table.insert(self.CustomCommands,{Name=name,Callback=callback,Description=description or ""})
end

function Window:Pulse()
	self.Main.BackgroundColor3=Theme.Surface2
	tween(self.Main,.25,{BackgroundColor3=Theme.Background})
end


LucidUI.APICatalog = {
	Window={
		"CreateWindow","AddTab","SelectTab","Show","Hide","Toggle","Destroy",
		"Notify","Toast","Confirm","SetTheme","SetAccent","SaveConfig","LoadConfig",
		"DeleteConfig","ListConfigs","GetFlag","SetFlag","GetFlags","ToggleCommandPalette",
		"CreateWatermark","CreateFloatingButton","AddCommand","Pulse"
	},
	Section={
		"AddButton","AddToggle","AddSlider","AddTextbox","AddDropdown","AddPlayerDropdown",
		"AddParagraph","AddDivider","AddBadge","AddProgress","AddNumberbox","AddKeybind",
		"AddButtonGroup","AddRadioGroup","AddMultiDropdown","AddColorPicker","AddCollapsible",
		"AddStatus","AddImage","AddSearchList","AddConsole","AddMiniGraph","AddTooltip",
		"AddContextMenu","AddConfigManager","AddThemeManager","AddNotificationTester",
		"AddSpacer","AddHeader","AddAvatar","AddChips","AddLoadingBar","AddCopyButton",
		"AddDangerButton"
	},
	Tab={"AddSection","AddSubTabs"}
}

LucidUI.Version="0.4.0"

return LucidUI
