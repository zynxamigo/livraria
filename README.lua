local LucidUI = {}
LucidUI.Version = "5.5.0-rebuild"

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local function RemovePreviousLucid()
	local roots = {
		CoreGui,
		LP and LP:FindFirstChild("PlayerGui")
	}

	for _, root in ipairs(roots) do
		if root then
			for _, child in ipairs(root:GetChildren()) do
				if child:IsA("ScreenGui") then
					if child.Name == "LucidUI_V5_SAFE" or child.Name == "LucidUI_V5_2" or child:GetAttribute("LucidUIRuntime") == true then
						pcall(function()
							child:Destroy()
						end)
					end
				end
			end
		end
	end
end

RemovePreviousLucid()

local DEFAULT = {
	Background = Color3.fromRGB(7,7,10),
	Topbar = Color3.fromRGB(10,10,14),
	Panel = Color3.fromRGB(12,12,17),
	Card = Color3.fromRGB(17,17,23),
	CardHover = Color3.fromRGB(22,22,30),
	Control = Color3.fromRGB(27,27,36),
	Border = Color3.fromRGB(38,38,49),
	Text = Color3.fromRGB(245,245,249),
	Muted = Color3.fromRGB(137,137,153),
	Accent = Color3.fromRGB(116,82,255),
	Danger = Color3.fromRGB(255,82,105),
	Success = Color3.fromRGB(72,214,146)
}

local function New(class, props, parent)
	local x = Instance.new(class)
	for k,v in pairs(props or {}) do x[k]=v end
	x.Parent=parent
	return x
end

local function Tween(x,t,p)
	local tw=TweenService:Create(x,TweenInfo.new(t or .15,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),p)
	tw:Play()
	return tw
end

local function Corner(x,r)
	return New("UICorner",{CornerRadius=UDim.new(0,r)},x)
end

local function Stroke(x,c,t)
	return New("UIStroke",{Color=c,Thickness=t or 1},x)
end

local function Pad(x,l,r,t,b)
	return New("UIPadding",{PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r),PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b)},x)
end

local function Label(parent,text,size,color,bold)
	return New("TextLabel",{
		BackgroundTransparency=1,
		BorderSizePixel=0,
		Text=text or "",
		TextColor3=color,
		TextSize=size or 13,
		Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment=Enum.TextXAlignment.Left,
		TextYAlignment=Enum.TextYAlignment.Center,
		TextTruncate=Enum.TextTruncate.AtEnd
	},parent)
end

local function Button(parent,text,size,color,bold)
	return New("TextButton",{
		BackgroundTransparency=1,
		BorderSizePixel=0,
		AutoButtonColor=false,
		Text=text or "",
		TextColor3=color,
		TextSize=size or 12,
		Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextTruncate=Enum.TextTruncate.AtEnd
	},parent)
end

local function SafeParent(gui)
	local ok=pcall(function() gui.Parent=CoreGui end)
	if not ok then gui.Parent=LP:WaitForChild("PlayerGui") end
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
	self.Options=o
	self.Title=o.Title or "Lucid"
	self.Subtitle=o.Subtitle or "Interface"
	self.Size=o.Size or UDim2.fromOffset(860,540)
	self.FirstP=o.FirstP==true
	self.ToggleKey=o.ToggleKey or Enum.KeyCode.Tab
	self.Visible=true
	self.Tabs={}
	self.CurrentTab=nil
	self.Connections={}
	self.Flags={}
	self.Theme={}
	for k,v in pairs(DEFAULT) do self.Theme[k]=v end

	local style=o.Style or {}
	self.Shape=style.Shape or "Rounded"
	self.Neon=style.Neon==true
	if style.Accent then self.Theme.Accent=style.Accent end
	self.Radius=self.Shape=="Square" and 0 or self.Shape=="Soft" and 7 or 13

	for _,root in ipairs({CoreGui,LP:FindFirstChild("PlayerGui")}) do
		if root then
			local old=root:FindFirstChild("LucidUI_V5")
			if old then old:Destroy() end
		end
	end

	local gui=New("ScreenGui",{Name="LucidUI_V5_2",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=false},nil)
	SafeParent(gui)
	self.Gui=gui
	gui:SetAttribute("LucidUIRuntime",true)

	if o.Loading~=false then
		local loading=New("Frame",{
			Name="LucidLoading",
			Size=UDim2.fromScale(1,1),
			BackgroundColor3=Color3.fromRGB(5,5,8),
			BorderSizePixel=0,
			ZIndex=900
		},gui)

		local logo=Label(loading,o.LoadingTitle or self.Title,28,self.Theme.Text,true)
		logo.AnchorPoint=Vector2.new(.5,.5)
		logo.Position=UDim2.new(.5,0,.5,-18)
		logo.Size=UDim2.fromOffset(420,42)
		logo.TextXAlignment=Enum.TextXAlignment.Center
		logo.ZIndex=901

		local status=Label(loading,o.LoadingText or "Initializing interface",11,self.Theme.Muted,false)
		status.AnchorPoint=Vector2.new(.5,.5)
		status.Position=UDim2.new(.5,0,.5,20)
		status.Size=UDim2.fromOffset(420,24)
		status.TextXAlignment=Enum.TextXAlignment.Center
		status.ZIndex=901

		local track=New("Frame",{
			AnchorPoint=Vector2.new(.5,.5),
			Position=UDim2.new(.5,0,.5,53),
			Size=UDim2.fromOffset(220,3),
			BackgroundColor3=self.Theme.Control,
			BorderSizePixel=0,
			ZIndex=901
		},loading)
		Corner(track,3)

		local fill=New("Frame",{
			Size=UDim2.fromScale(0,1),
			BackgroundColor3=self.Theme.Accent,
			BorderSizePixel=0,
			ZIndex=902
		},track)
		Corner(fill,3)

		task.spawn(function()
			Tween(fill,.35,{Size=UDim2.fromScale(.45,1)})
			task.wait(.12)
			status.Text="Loading components"
			Tween(fill,.28,{Size=UDim2.fromScale(.78,1)})
			task.wait(.12)
			status.Text="Ready"
			Tween(fill,.2,{Size=UDim2.fromScale(1,1)})
			task.wait(.18)
			Tween(loading,.2,{BackgroundTransparency=1})
			Tween(logo,.2,{TextTransparency=1})
			Tween(status,.2,{TextTransparency=1})
			task.wait(.22)
			if loading then loading:Destroy() end
		end)
	end

	local main=New("Frame",{
		AnchorPoint=Vector2.new(.5,.5),
		Position=UDim2.fromScale(.5,.5),
		Size=self.Size,
		BackgroundColor3=self.Theme.Background,
		BorderSizePixel=0,
		ClipsDescendants=true
	},gui)
	Corner(main,self.Radius)
	local mainStroke=Stroke(main,self.Neon and self.Theme.Accent or self.Theme.Border,self.Neon and 2 or 1)
	self.Main=main
	self.MainStroke=mainStroke

	local bg=New("ImageLabel",{
		Name="BackgroundImage",
		Size=UDim2.fromScale(1,1),
		BackgroundTransparency=1,
		Image="",
		ImageTransparency=1,
		ScaleType=Enum.ScaleType.Crop,
		ZIndex=0
	},main)
	self.BackgroundImage=bg

	local tint=New("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=self.Theme.Background,BackgroundTransparency=.08,BorderSizePixel=0,ZIndex=1},main)
	self.Tint=tint

	local top=New("Frame",{Size=UDim2.new(1,0,0,68),BackgroundColor3=self.Theme.Topbar,BorderSizePixel=0,ZIndex=5},main)
	self.Topbar=top

	local title=Label(top,self.Title,17,self.Theme.Text,true)
	title.Position=UDim2.fromOffset(18,9)
	title.Size=UDim2.fromOffset(175,23)
	title.ZIndex=6
	local subtitle=Label(top,self.Subtitle,10,self.Theme.Muted,false)
	subtitle.Position=UDim2.fromOffset(18,33)
	subtitle.Size=UDim2.fromOffset(175,18)
	subtitle.ZIndex=6

	local tabs=New("ScrollingFrame",{
		Position=UDim2.fromOffset(205,0),
		Size=UDim2.new(1,-335,1,0),
		BackgroundTransparency=1,
		BorderSizePixel=0,
		ScrollBarThickness=0,
		CanvasSize=UDim2.new(),
		ScrollingDirection=Enum.ScrollingDirection.X,
		ZIndex=6
	},top)
	local tabLayout=New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,6)},tabs)
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabs.CanvasSize=UDim2.fromOffset(tabLayout.AbsoluteContentSize.X+8,0)
	end)
	self.TabBar=tabs

	local controls=New("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.fromOffset(150,34),BackgroundTransparency=1,ZIndex=7},top)
	New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,7)},controls)
	self.FavoriteMode=false
	self.Favorites={}
	self.FavoriteTab=nil

	local star=Button(controls,"☆",19,self.Theme.Muted,true)
	star.Size=UDim2.fromOffset(34,34)
	star.BackgroundTransparency=0
	star.BackgroundColor3=self.Theme.Card
	Corner(star,8)
	self.FavoriteButton=star

	local mini=Button(controls,"—",17,self.Theme.Muted,true)
	mini.Size=UDim2.fromOffset(34,34) mini.BackgroundTransparency=0 mini.BackgroundColor3=self.Theme.Card Corner(mini,8)
	local close=Button(controls,"×",19,self.Theme.Muted,true)
	close.Size=UDim2.fromOffset(34,34) close.BackgroundTransparency=0 close.BackgroundColor3=self.Theme.Card Corner(close,8)

	local body=New("Frame",{Position=UDim2.fromOffset(0,68),Size=UDim2.new(1,0,1,-68),BackgroundTransparency=1,ZIndex=2},main)
	self.Content=body

	local dragging=false
	local dragStart,startPos
	table.insert(self.Connections,top.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dragStart=i.Position startPos=main.Position end
	end))
	table.insert(self.Connections,UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
			local d=i.Position-dragStart
			main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
		end
	end))
	table.insert(self.Connections,UIS.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
	end))

	function self:SetVisible(v)
		self.Visible=v
		main.Visible=v
		if self.FirstP then
			UIS.MouseIconEnabled=v
		end
	end

	function self:Toggle()
		self:SetVisible(not self.Visible)
	end

	local function refreshFavoriteButton()
		star.Text=self.FavoriteMode and "★" or "☆"
		star.TextColor3=self.FavoriteMode and self.Theme.Accent or self.Theme.Muted
	end

	star.MouseButton1Click:Connect(function()
		self.FavoriteMode=not self.FavoriteMode
		refreshFavoriteButton()
		self:Notify({
			Title="Favorites",
			Content=self.FavoriteMode and "Favorite mode: click an option to add/remove it." or "Favorite mode disabled.",
			Duration=2
		})
	end)

	close.MouseButton1Click:Connect(function() self:SetVisible(false) end)
	mini.MouseButton1Click:Connect(function()
		if main.Size.Y.Offset<=70 then Tween(main,.18,{Size=self.Size}) else Tween(main,.18,{Size=UDim2.fromOffset(self.Size.X.Offset,68)}) end
	end)

	table.insert(self.Connections,UIS.InputBegan:Connect(function(i,processed)
		if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==self.ToggleKey then
			self:Toggle()
			return
		end
		if processed then return end
		for _,tab in ipairs(self.Tabs) do
			for _,sec in ipairs(tab.Sections) do
				for _,comp in ipairs(sec.Components) do
					if comp.Type=="Toggle" and comp.Bind and i.KeyCode==comp.Bind and not comp.Binding then
						comp:Set(not comp:Get(),true)
					end
				end
			end
		end
	end))

	if style.Background then
		local b=style.Background
		if type(b)=="string" then self:SetBackground(b,0.25)
		elseif type(b)=="table" and b.Enabled~=false then self:SetBackground(b.Image or b.Url,b.Transparency or .25) end
	end

	return self
end

function Window:SetBackground(source,transparency)
	if not source or source=="" then
		self.BackgroundImage.Image=""
		self.BackgroundImage.ImageTransparency=1
		return false
	end
	local image=source
	if tostring(source):match("^https?://") then
		if getcustomasset and writefile and game.HttpGet then
			local ext=tostring(source):match("%.([%w]+)[%?]?") or "png"
			local path="LucidUI_Background."..ext
			local ok,data=pcall(function() return game:HttpGet(source) end)
			if ok then
				local ok2=pcall(function() writefile(path,data) end)
				if ok2 then
					local ok3,asset=pcall(function() return getcustomasset(path) end)
					if ok3 then image=asset else return false end
				else return false end
			else return false end
		else
			return false
		end
	elseif not tostring(source):find("rbxasset",1,true) then
		image="rbxassetid://"..tostring(source)
	end
	self.BackgroundImage.Image=image
	self.BackgroundImage.ImageTransparency=math.clamp(transparency or .25,0,1)
	return true
end

function Window:SetAccent(color)
	self.Theme.Accent=color
	if self.Neon then self.MainStroke.Color=color end
	for _,tab in ipairs(self.Tabs) do
		if tab==self.CurrentTab then tab.Indicator.BackgroundColor3=color end
		for _,sec in ipairs(tab.Sections) do
			for _,c in ipairs(sec.Components) do
				if c.RefreshTheme then c:RefreshTheme() end
			end
		end
	end
end

function Window:SetNeon(v)
	self.Neon=v==true
	self.MainStroke.Color=self.Neon and self.Theme.Accent or self.Theme.Border
	self.MainStroke.Thickness=self.Neon and 2 or 1
end

function Window:SetShape(shape)
	self.Shape=shape
	self.Radius=shape=="Square" and 0 or shape=="Soft" and 7 or 13
	local c=self.Main:FindFirstChildOfClass("UICorner")
	if c then c.CornerRadius=UDim.new(0,self.Radius) end
end

function Window:AddTab(o)
	if type(o)=="string" then
		o={
			Name=o
		}
	end
	o=o or {}
	local t=setmetatable({Window=self,Name=o.Name or "Tab",Sections={}},Tab)
	local b=Button(self.TabBar,t.Name,12,self.Theme.Muted,true)
	b.Size=UDim2.fromOffset(math.max(88,math.min(150,34+#t.Name*7)),36)
	b.BackgroundTransparency=1
	b.BackgroundColor3=self.Theme.Card
	Corner(b,8)
	local ind=New("Frame",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,0),Size=UDim2.new(0,0,0,2),BackgroundColor3=self.Theme.Accent,BorderSizePixel=0},b)
	Corner(ind,2)
	local page=New("ScrollingFrame",{Visible=false,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=self.Theme.Border,CanvasSize=UDim2.new()},self.Content)
	Pad(page,18,18,18,18)
	local layout=New("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},page)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+36) end)
	t.Button=b t.Indicator=ind t.Page=page
	table.insert(self.Tabs,t)
	b.MouseButton1Click:Connect(function() self:SelectTab(t) end)
	if not self.CurrentTab then self:SelectTab(t) end
	return t
end

function Window:SelectTab(tab)
	for _,t in ipairs(self.Tabs) do
		local on=t==tab
		t.Page.Visible=on
		Tween(t.Button,.12,{BackgroundTransparency=on and 0 or 1,TextColor3=on and self.Theme.Text or self.Theme.Muted})
		Tween(t.Indicator,.12,{Size=on and UDim2.new(.55,0,0,2) or UDim2.new(0,0,0,2)})
	end
	self.CurrentTab=tab
end

function Tab:AddSection(name)
	local s=setmetatable({Window=self.Window,Tab=self,Name=name or "Section",Components={}},Section)
	local frame=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=self.Window.Theme.Panel,BorderSizePixel=0},self.Page)
	Corner(frame,10) Stroke(frame,self.Window.Theme.Border,1) Pad(frame,12,12,12,12)
	local layout=New("UIListLayout",{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder},frame)
	local title=Label(frame,s.Name,11,self.Window.Theme.Muted,true)
	title.Size=UDim2.new(1,0,0,24)
	s.Frame=frame
	table.insert(self.Sections,s)
	return s
end

function Section:_Base(o,height)
	o=o or {}
	local w=self.Window
	local card=New("Frame",{Size=UDim2.new(1,0,0,height or 58),BackgroundColor3=w.Theme.Card,BorderSizePixel=0},self.Frame)
	Corner(card,8)
	local textArea=New("Frame",{Position=UDim2.fromOffset(13,0),Size=UDim2.new(1,-190,1,0),BackgroundTransparency=1},card)
	local title=Label(textArea,o.Name or "Option",13,w.Theme.Text,true)
	if o.Description then
		title.Position=UDim2.fromOffset(0,7) title.Size=UDim2.new(1,0,0,20)
		local desc=Label(textArea,o.Description,10,w.Theme.Muted,false)
		desc.Position=UDim2.fromOffset(0,28) desc.Size=UDim2.new(1,0,0,16)
	else
		title.Size=UDim2.fromScale(1,1)
	end
	local controls=New("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.fromOffset(160,height or 58),BackgroundTransparency=1},card)
	local c={Window=w,Section=self,Card=card,Controls=controls,Name=o.Name or "Option"}
	table.insert(self.Components,c)

	card.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 and w.FavoriteMode then
			w:ToggleFavorite(c)
		end
	end)

	return card,controls,c
end

function Section:AddButton(o)
	if type(o)=="string" then
		o={
			Name=o
		}
	end
	o=o or {}
	local _,controls,c=self:_Base(o,o.Description and 62 or 54)
	c.Type="Button"
	local b=Button(controls,o.ActionText or "Run",11,self.Window.Theme.Text,true)
	b.AnchorPoint=Vector2.new(1,.5) b.Position=UDim2.new(1,0,.5,0) b.Size=UDim2.fromOffset(72,30)
	b.BackgroundTransparency=0 b.BackgroundColor3=self.Window.Theme.Control Corner(b,7)
	b.MouseButton1Click:Connect(function() task.spawn(o.Callback or function() end) end)
	c.Fire=function() task.spawn(o.Callback or function() end) end
	return c
end

function Section:AddToggle(o)
	o=o or {}
	local _,controls,c=self:_Base(o,o.Description and 64 or 56)
	c.Type="Toggle"
	c.Value=o.Default==true
	c.Bind=o.Bind
	c.Binding=false

	local row=New("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(126,32),BackgroundTransparency=1},controls)
	local bindable=o.Bindable~=false
	local bind=Button(row,c.Bind and c.Bind.Name or "+",11,self.Window.Theme.Muted,true)
	bind.Position=UDim2.fromOffset(0,0)
	bind.Size=UDim2.fromOffset(48,32)
	bind.BackgroundTransparency=0
	bind.BackgroundColor3=self.Window.Theme.Control
	bind.Visible=bindable
	Corner(bind,7)
	local track=Button(row,"",1,self.Window.Theme.Text,false)
	track.Position=bindable and UDim2.fromOffset(62,4) or UDim2.fromOffset(82,4)
	track.Size=UDim2.fromOffset(44,24)
	track.BackgroundTransparency=0 Corner(track,20)
	local knob=New("Frame",{AnchorPoint=Vector2.new(0,.5),Size=UDim2.fromOffset(18,18),BackgroundColor3=self.Window.Theme.Text,BorderSizePixel=0},track)
	Corner(knob,20)

	function c:RefreshTheme()
		track.BackgroundColor3=self.Value and self.Window.Theme.Accent or self.Window.Theme.Control
	end
	function c:Set(v,fire)
		self.Value=v==true
		Tween(track,.12,{BackgroundColor3=self.Value and self.Window.Theme.Accent or self.Window.Theme.Control})
		Tween(knob,.12,{Position=self.Value and UDim2.new(0,23,.5,0) or UDim2.new(0,3,.5,0)})
		if o.Flag then self.Window.Flags[o.Flag]=self.Value end
		if fire then task.spawn(o.Callback or function() end,self.Value) end
	end
	function c:Get() return self.Value end
	function c:SetBind(key)
		self.Bind=key
		bind.Text=key and key.Name or "+"
	end

	track.MouseButton1Click:Connect(function() c:Set(not c.Value,true) end)
	bind.MouseButton1Click:Connect(function()
		if not bindable then return end
		if c.Binding then return end
		c.Binding=true bind.Text="..."
		local conn
		conn=UIS.InputBegan:Connect(function(i)
			if i.UserInputType~=Enum.UserInputType.Keyboard then return end
			conn:Disconnect()
			c.Binding=false
			if i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.Backspace then c:SetBind(nil) else c:SetBind(i.KeyCode) end
		end)
	end)
	c:Set(c.Value,false)
	return c
end

function Section:AddSlider(o)
	o=o or {}
	local min,max=o.Min or 0,o.Max or 100
	local value=math.clamp(o.Default or min,min,max)
	local card,_,c=self:_Base(o,76)
	c.Type="Slider"
	local valueLabel=Label(card,"",11,self.Window.Theme.Muted,true)
	valueLabel.AnchorPoint=Vector2.new(1,0) valueLabel.Position=UDim2.new(1,-14,0,7) valueLabel.Size=UDim2.fromOffset(70,18) valueLabel.TextXAlignment=Enum.TextXAlignment.Right
	local bar=New("Frame",{Position=UDim2.new(0,13,1,-18),Size=UDim2.new(1,-26,0,7),BackgroundColor3=self.Window.Theme.Control,BorderSizePixel=0},card)
	Corner(bar,7)
	local fill=New("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=self.Window.Theme.Accent,BorderSizePixel=0},bar) Corner(fill,7)
	local hit=Button(bar,"",1,self.Window.Theme.Text,false) hit.Size=UDim2.new(1,0,1,12) hit.Position=UDim2.fromOffset(0,-6)
	local dragging=false
	local function set(v,fire)
		value=math.clamp(v,min,max)
		if o.Round~=false then value=math.floor(value+.5) end
		local a=(value-min)/(max-min)
		valueLabel.Text=tostring(value)..(o.Suffix or "")
		Tween(fill,.08,{Size=UDim2.fromScale(a,1)})
		if o.Flag then self.Window.Flags[o.Flag]=value end
		if fire then task.spawn(o.Callback or function() end,value) end
	end
	local function mouse()
		local a=math.clamp((UIS:GetMouseLocation().X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
		set(min+(max-min)*a,true)
	end
	hit.MouseButton1Down:Connect(function() dragging=true mouse() end)
	table.insert(self.Window.Connections,UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then mouse() end
	end))
	table.insert(self.Window.Connections,UIS.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
	end))
	c.Set=function(_,v) set(v,true) end c.Get=function() return value end
	c.RefreshTheme=function() fill.BackgroundColor3=self.Window.Theme.Accent end
	set(value,false)
	return c
end

function Section:AddTextbox(o)
	o=o or {}
	local _,controls,c=self:_Base(o,o.Description and 64 or 56)
	c.Type="Textbox"
	local box=New("TextBox",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(145,32),BackgroundColor3=self.Window.Theme.Control,BorderSizePixel=0,Text=o.Default or "",PlaceholderText=o.Placeholder or "Type...",PlaceholderColor3=self.Window.Theme.Muted,TextColor3=self.Window.Theme.Text,TextSize=11,Font=Enum.Font.Gotham,ClearTextOnFocus=false},controls)
	Corner(box,7) Pad(box,10,10,0,0)
	box.FocusLost:Connect(function(enter) if o.Flag then self.Window.Flags[o.Flag]=box.Text end task.spawn(o.Callback or function() end,box.Text,enter) end)
	c.Set=function(_,v) box.Text=tostring(v or "") end c.Get=function() return box.Text end
	return c
end

function Section:AddDropdown(o)
	o=o or {}
	local items=o.Options or o.Values or {}
	local value=o.Default
	local baseHeight=o.Description and 64 or 56

	local card=New("Frame",{
		Size=UDim2.new(1,0,0,baseHeight),
		BackgroundColor3=self.Window.Theme.Card,
		BorderSizePixel=0,
		ClipsDescendants=true
	},self.Frame)
	Corner(card,8)

	local title=Label(card,o.Name or "Dropdown",13,self.Window.Theme.Text,true)
	title.Position=UDim2.fromOffset(13,o.Description and 7 or 0)
	title.Size=UDim2.new(1,-190,o.Description and 0 or 1,o.Description and 20 or 0)

	if o.Description then
		local desc=Label(card,o.Description,10,self.Window.Theme.Muted,false)
		desc.Position=UDim2.fromOffset(13,28)
		desc.Size=UDim2.new(1,-190,0,16)
	end

	local button=Button(card,value and tostring(value) or (o.Placeholder or "Select"),11,self.Window.Theme.Text,false)
	button.AnchorPoint=Vector2.new(1,0)
	button.Position=UDim2.new(1,-12,0,12)
	button.Size=UDim2.fromOffset(145,32)
	button.BackgroundTransparency=0
	button.BackgroundColor3=self.Window.Theme.Control
	Corner(button,7)

	local list=New("Frame",{
		Position=UDim2.fromOffset(12,baseHeight),
		Size=UDim2.new(1,-24,0,0),
		BackgroundTransparency=1,
		Visible=false
	},card)
	local layout=New("UIListLayout",{Padding=UDim.new(0,4)},list)

	local c={Type="Dropdown",Window=self.Window,Section=self,Card=card,Name=o.Name or "Dropdown"}
	table.insert(self.Components,c)
	local open=false

	local function setOpen(state)
		open=state
		list.Visible=open
		local h=open and (#items*32+math.max(0,#items-1)*4+12) or 0
		list.Size=UDim2.new(1,-24,0,h)
		Tween(card,.15,{Size=UDim2.new(1,0,0,baseHeight+h)})
	end

	for _,itemValue in ipairs(items) do
		local item=Button(list,tostring(itemValue),11,self.Window.Theme.Text,false)
		item.Size=UDim2.new(1,0,0,32)
		item.BackgroundTransparency=0
		item.BackgroundColor3=self.Window.Theme.Control
		Corner(item,6)
		item.MouseButton1Click:Connect(function()
			value=itemValue
			button.Text=tostring(itemValue)
			setOpen(false)
			if o.Flag then self.Window.Flags[o.Flag]=value end
			task.spawn(o.Callback or function() end,value)
		end)
	end

	button.MouseButton1Click:Connect(function()
		setOpen(not open)
	end)

	card.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 and self.Window.FavoriteMode then
			self.Window:ToggleFavorite(c)
		end
	end)

	function c:Set(v)
		value=v
		button.Text=tostring(v)
	end

	function c:Get()
		return value
	end

	function c:SetOpen(v)
		setOpen(v)
	end

	return c
end

function Section:AddRadioGroup(o)
	o=o or {}
	local opts=o.Options or {}
	local h=44+#opts*34
	local card=New("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=self.Window.Theme.Card,BorderSizePixel=0},self.Frame)
	Corner(card,8)
	local title=Label(card,o.Name or "Options",13,self.Window.Theme.Text,true)
	title.Position=UDim2.fromOffset(13,8) title.Size=UDim2.new(1,-26,0,22)
	local list=New("Frame",{Position=UDim2.fromOffset(13,38),Size=UDim2.new(1,-26,0,#opts*34),BackgroundTransparency=1},card)
	New("UIListLayout",{Padding=UDim.new(0,2)},list)
	local c={Type="RadioGroup",Window=self.Window,Section=self,Card=card,Value=o.Default}
	table.insert(self.Components,c)
	local rows={}
	local function set(v,fire)
		c.Value=v
		for val,row in pairs(rows) do
			row.Dot.BackgroundColor3=val==v and self.Window.Theme.Accent or self.Window.Theme.Control
			row.Text.TextColor3=val==v and self.Window.Theme.Text or self.Window.Theme.Muted
		end
		if fire then task.spawn(o.Callback or function() end,v) end
	end
	for _,v in ipairs(opts) do
		local row=Button(list,"",1,self.Window.Theme.Text,false) row.Size=UDim2.new(1,0,0,32)
		local dot=New("Frame",{Position=UDim2.fromOffset(2,8),Size=UDim2.fromOffset(16,16),BackgroundColor3=self.Window.Theme.Control,BorderSizePixel=0},row) Corner(dot,16)
		local tx=Label(row,tostring(v),11,self.Window.Theme.Muted,false) tx.Position=UDim2.fromOffset(28,0) tx.Size=UDim2.new(1,-28,1,0)
		rows[v]={Dot=dot,Text=tx}
		row.MouseButton1Click:Connect(function() set(v,true) end)
	end
	c.Set=function(_,v) set(v,true) end c.Get=function() return c.Value end
	set(c.Value,false)
	return c
end

function Section:AddButtonGroup(o)
	o=o or {}
	local opts=o.Options or {}
	local card=New("Frame",{Size=UDim2.new(1,0,0,86),BackgroundColor3=self.Window.Theme.Card,BorderSizePixel=0},self.Frame)
	Corner(card,8)
	local title=Label(card,o.Name or "Actions",13,self.Window.Theme.Text,true)
	title.Position=UDim2.fromOffset(13,8) title.Size=UDim2.new(1,-26,0,22)
	local row=New("Frame",{Position=UDim2.fromOffset(13,42),Size=UDim2.new(1,-26,0,32),BackgroundTransparency=1},card)
	New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6)},row)
	for _,item in ipairs(opts) do
		local name=type(item)=="table" and (item.Name or item[1]) or tostring(item)
		local cb=type(item)=="table" and (item.Callback or item[2]) or function() end
		local b=Button(row,name,11,self.Window.Theme.Text,true)
		b.Size=UDim2.fromOffset(math.max(70,math.min(130,30+#name*6)),32) b.BackgroundTransparency=0 b.BackgroundColor3=self.Window.Theme.Control Corner(b,7)
		b.MouseButton1Click:Connect(function() task.spawn(cb) end)
	end
	return {Type="ButtonGroup",Card=card}
end


function Window:_EnsureFavoritesTab()
	if self.FavoriteTab then
		return self.FavoriteTab
	end

	local tab=self:AddTab("Favorites")
	tab.IsFavorites=true
	self.FavoriteTab=tab
	return tab
end

function Window:_RebuildFavorites()
	local tab=self:_EnsureFavoritesTab()

	for _,section in ipairs(tab.Sections) do
		if section.Frame then
			section.Frame:Destroy()
		end
	end

	tab.Sections={}

	local section=tab:AddSection("Quick access")

	if next(self.Favorites)==nil then
		section:AddParagraph({
			Name="No favorites",
			Content="Press the star in the top bar, then click an option."
		})
		return
	end

	for component,_ in pairs(self.Favorites) do
		if component and component.Card and component.Card.Parent then
			section:AddButton({
				Name=component.Name or component.Type or "Option",
				ActionText="Open",
				Callback=function()
					local originalSection=component.Section
					if originalSection and originalSection.Tab then
						self:SelectTab(originalSection.Tab)
					end
				end
			})
		end
	end
end

function Window:ToggleFavorite(component)
	if not component then return end

	if self.Favorites[component] then
		self.Favorites[component]=nil
		self:Notify({Title="Favorites",Content=(component.Name or "Option").." removed.",Duration=1.5})
	else
		self.Favorites[component]=true
		self:Notify({Title="Favorites",Content=(component.Name or "Option").." added.",Duration=1.5})
	end

	self:_RebuildFavorites()
end

function Window:AddAppearanceTab()
	local tab=self:AddTab("Lucid")
	local sec=tab:AddSection("Appearance")
	sec:AddDropdown({Name="Shape",Options={"Rounded","Soft","Square"},Default=self.Shape,Callback=function(v) self:SetShape(v) end})
	sec:AddToggle({Name="Neon border",Default=self.Neon,Callback=function(v) self:SetNeon(v) end})
	sec:AddTextbox({Name="Background",Description="Asset ID, rbxassetid:// ou URL quando o ambiente suportar",Placeholder="URL / Asset ID",Callback=function(v) self:SetBackground(v,.25) end})
	sec:AddSlider({Name="Background opacity",Min=0,Max=100,Default=75,Suffix="%",Callback=function(v) self.BackgroundImage.ImageTransparency=1-v/100 end})
	return tab
end


function Section:AddKeybind(o)
	o=o or {}
	local _,controls,c=self:_Base(o,o.Description and 64 or 56)
	c.Type="Keybind"
	c.Bind=o.Default or o.Bind
	c.Binding=false
	local b=Button(controls,c.Bind and c.Bind.Name or "None",11,self.Window.Theme.Text,true)
	b.AnchorPoint=Vector2.new(1,.5)
	b.Position=UDim2.new(1,0,.5,0)
	b.Size=UDim2.fromOffset(100,32)
	b.BackgroundTransparency=0
	b.BackgroundColor3=self.Window.Theme.Control
	Corner(b,7)
	function c:SetBind(key)
		self.Bind=key
		b.Text=key and key.Name or "None"
	end
	function c:Get()
		return self.Bind
	end
	b.MouseButton1Click:Connect(function()
		if c.Binding then return end
		c.Binding=true
		b.Text="..."
		local conn
		conn=UIS.InputBegan:Connect(function(input)
			if input.UserInputType~=Enum.UserInputType.Keyboard then return end
			conn:Disconnect()
			c.Binding=false
			if input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.Backspace then
				c:SetBind(nil)
			else
				c:SetBind(input.KeyCode)
			end
		end)
	end)
	table.insert(self.Window.Connections,UIS.InputBegan:Connect(function(input,processed)
		if processed or c.Binding then return end
		if c.Bind and input.KeyCode==c.Bind then
			task.spawn(o.Callback or function() end,c.Bind)
		end
	end))
	return c
end

function Section:AddParagraph(o)
	o=o or {}
	local card=New("Frame",{Size=UDim2.new(1,0,0,o.Height or 88),BackgroundColor3=self.Window.Theme.Card,BorderSizePixel=0},self.Frame)
	Corner(card,8)
	local title=Label(card,o.Name or o.Title or "Paragraph",13,self.Window.Theme.Text,true)
	title.Position=UDim2.fromOffset(13,8)
	title.Size=UDim2.new(1,-26,0,20)
	local text=Label(card,o.Content or o.Text or "",11,self.Window.Theme.Muted,false)
	text.Position=UDim2.fromOffset(13,32)
	text.Size=UDim2.new(1,-26,1,-42)
	text.TextWrapped=true
	text.TextTruncate=Enum.TextTruncate.None
	text.TextYAlignment=Enum.TextYAlignment.Top
	local c={Type="Paragraph",Card=card}
	function c:Set(v) text.Text=tostring(v or "") end
	return c
end

function Section:AddDivider()
	local frame=New("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1},self.Frame)
	New("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(1,-12,0,1),BackgroundColor3=self.Window.Theme.Border,BorderSizePixel=0},frame)
	return {Type="Divider",Frame=frame}
end

function Window:Notify(o)
	if type(o)=="string" then
		o={
			Content=o
		}
	end
	o=o or {}
	if not self.NotificationHolder then
		self.NotificationHolder=New("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-16,1,-16),Size=UDim2.fromOffset(310,400),BackgroundTransparency=1,ZIndex=200},self.Gui)
		New("UIListLayout",{VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,7)},self.NotificationHolder)
	end
	local card=New("Frame",{Size=UDim2.fromOffset(300,72),BackgroundColor3=self.Theme.Panel,BorderSizePixel=0,ZIndex=201},self.NotificationHolder)
	Corner(card,9)
	Stroke(card,self.Neon and self.Theme.Accent or self.Theme.Border,1)
	local title=Label(card,o.Title or "Lucid",12,self.Theme.Text,true)
	title.Position=UDim2.fromOffset(12,8)
	title.Size=UDim2.new(1,-24,0,19)
	title.ZIndex=202
	local content=Label(card,o.Content or o.Description or "",10,self.Theme.Muted,false)
	content.Position=UDim2.fromOffset(12,29)
	content.Size=UDim2.new(1,-24,0,32)
	content.TextWrapped=true
	content.TextTruncate=Enum.TextTruncate.None
	content.ZIndex=202
	task.delay(o.Duration or 4,function()
		if card and card.Parent then card:Destroy() end
	end)
	return card
end


function Section:AddMultiDropdown(o)
	o=o or {}
	local values=o.Options or o.Values or {}
	local selected={}
	for _,v in ipairs(o.Default or {}) do selected[v]=true end
	local baseHeight=o.Description and 64 or 56

	local card=New("Frame",{
		Size=UDim2.new(1,0,0,baseHeight),
		BackgroundColor3=self.Window.Theme.Card,
		BorderSizePixel=0,
		ClipsDescendants=true
	},self.Frame)
	Corner(card,8)

	local title=Label(card,o.Name or "Multi Dropdown",13,self.Window.Theme.Text,true)
	title.Position=UDim2.fromOffset(13,o.Description and 7 or 0)
	title.Size=UDim2.new(1,-190,o.Description and 0 or 1,o.Description and 20 or 0)

	if o.Description then
		local desc=Label(card,o.Description,10,self.Window.Theme.Muted,false)
		desc.Position=UDim2.fromOffset(13,28)
		desc.Size=UDim2.new(1,-190,0,16)
	end

	local button=Button(card,"Select",11,self.Window.Theme.Text,false)
	button.AnchorPoint=Vector2.new(1,0)
	button.Position=UDim2.new(1,-12,0,12)
	button.Size=UDim2.fromOffset(145,32)
	button.BackgroundTransparency=0
	button.BackgroundColor3=self.Window.Theme.Control
	Corner(button,7)

	local list=New("Frame",{
		Position=UDim2.fromOffset(12,baseHeight),
		Size=UDim2.new(1,-24,0,0),
		BackgroundTransparency=1,
		Visible=false
	},card)
	New("UIListLayout",{Padding=UDim.new(0,4)},list)

	local c={Type="MultiDropdown",Window=self.Window,Section=self,Card=card,Name=o.Name or "Multi Dropdown"}
	table.insert(self.Components,c)
	local open=false
	local marks={}

	local function array()
		local result={}
		for _,v in ipairs(values) do
			if selected[v] then table.insert(result,v) end
		end
		return result
	end

	local function refresh()
		local a=array()
		button.Text=#a==0 and (o.Placeholder or "Select") or (#a==1 and tostring(a[1]) or tostring(#a).." selected")
		for v,mark in pairs(marks) do
			mark.BackgroundColor3=selected[v] and self.Window.Theme.Accent or self.Window.Theme.Control
		end
	end

	local function setOpen(state)
		open=state
		list.Visible=open
		local h=open and (#values*32+math.max(0,#values-1)*4+12) or 0
		list.Size=UDim2.new(1,-24,0,h)
		Tween(card,.15,{Size=UDim2.new(1,0,0,baseHeight+h)})
	end

	for _,v in ipairs(values) do
		local row=Button(list,"",1,self.Window.Theme.Text,false)
		row.Size=UDim2.new(1,0,0,32)
		row.BackgroundTransparency=0
		row.BackgroundColor3=self.Window.Theme.Control
		Corner(row,6)

		local mark=New("Frame",{
			Position=UDim2.fromOffset(9,9),
			Size=UDim2.fromOffset(14,14),
			BackgroundColor3=self.Window.Theme.Control,
			BorderSizePixel=0
		},row)
		Corner(mark,4)
		marks[v]=mark

		local text=Label(row,tostring(v),11,self.Window.Theme.Text,false)
		text.Position=UDim2.fromOffset(32,0)
		text.Size=UDim2.new(1,-38,1,0)

		row.MouseButton1Click:Connect(function()
			selected[v]=not selected[v]
			refresh()
			local a=array()
			if o.Flag then self.Window.Flags[o.Flag]=a end
			task.spawn(o.Callback or function() end,a)
		end)
	end

	button.MouseButton1Click:Connect(function() setOpen(not open) end)
	card.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 and self.Window.FavoriteMode then
			self.Window:ToggleFavorite(c)
		end
	end)

	function c:Get() return array() end
	function c:Set(a)
		selected={}
		for _,v in ipairs(a or {}) do selected[v]=true end
		refresh()
	end
	function c:SetOpen(v) setOpen(v) end

	refresh()
	return c
end

function Section:AddStatus(o)
	o=o or {}

	local card=New(
		"Frame",
		{
			Size=UDim2.new(1,0,0,50),
			BackgroundColor3=self.Window.Theme.Card,
			BorderSizePixel=0
		},
		self.Frame
	)

	Corner(
		card,
		8
	)

	local dot=New(
		"Frame",
		{
			AnchorPoint=Vector2.new(0,.5),
			Position=UDim2.new(0,13,.5,0),
			Size=UDim2.fromOffset(10,10),
			BackgroundColor3=o.Color or self.Window.Theme.Success,
			BorderSizePixel=0
		},
		card
	)

	Corner(
		dot,
		10
	)

	local title=Label(
		card,
		o.Name or "Status",
		12,
		self.Window.Theme.Text,
		true
	)

	title.Position=UDim2.fromOffset(
		32,
		0
	)

	title.Size=UDim2.new(
		1,
		-130,
		1,
		0
	)

	local value=Label(
		card,
		o.Value or "Ready",
		11,
		self.Window.Theme.Muted,
		true
	)

	value.AnchorPoint=Vector2.new(
		1,
		0
	)

	value.Position=UDim2.new(
		1,
		-13,
		0,
		0
	)

	value.Size=UDim2.fromOffset(
		90,
		50
	)

	value.TextXAlignment=Enum.TextXAlignment.Right

	local c={
		Type="Status",
		Card=card
	}

	function c:Set(text,color)
		value.Text=tostring(text or "")

		if color then
			dot.BackgroundColor3=color
		end
	end

	return c
end

function Section:AddBadge(o)
	o=o or {}

	local card,controls,c=self:_Base(
		o,
		o.Description and 64 or 56
	)

	c.Type="Badge"

	local badge=Label(
		controls,
		o.Value or o.Text or "NEW",
		10,
		o.TextColor or self.Window.Theme.Text,
		true
	)

	badge.AnchorPoint=Vector2.new(
		1,
		.5
	)

	badge.Position=UDim2.new(
		1,
		0,
		.5,
		0
	)

	badge.Size=UDim2.fromOffset(
		o.Width or 72,
		26
	)

	badge.BackgroundTransparency=0
	badge.BackgroundColor3=o.Color or self.Window.Theme.Accent
	badge.TextXAlignment=Enum.TextXAlignment.Center

	Corner(
		badge,
		7
	)

	function c:Set(text,color)
		badge.Text=tostring(text or "")

		if color then
			badge.BackgroundColor3=color
		end
	end

	return c
end

function Section:AddCollapsible(o)
	o=o or {}

	local open=o.DefaultOpen~=false

	local root=New(
		"Frame",
		{
			Size=UDim2.new(1,0,0,48),
			AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundColor3=self.Window.Theme.Card,
			BorderSizePixel=0
		},
		self.Frame
	)

	Corner(
		root,
		8
	)

	local header=Button(
		root,
		"",
		1,
		self.Window.Theme.Text,
		false
	)

	header.Size=UDim2.new(
		1,
		0,
		0,
		48
	)

	local title=Label(
		header,
		o.Name or "Collapsible",
		12,
		self.Window.Theme.Text,
		true
	)

	title.Position=UDim2.fromOffset(
		13,
		0
	)

	title.Size=UDim2.new(
		1,
		-50,
		1,
		0
	)

	local arrow=Label(
		header,
		open and "−" or "+",
		16,
		self.Window.Theme.Muted,
		true
	)

	arrow.AnchorPoint=Vector2.new(
		1,
		0
	)

	arrow.Position=UDim2.new(
		1,
		-13,
		0,
		0
	)

	arrow.Size=UDim2.fromOffset(
		28,
		48
	)

	arrow.TextXAlignment=Enum.TextXAlignment.Center

	local content=New(
		"Frame",
		{
			Position=UDim2.fromOffset(0,48),
			Size=UDim2.new(1,0,0,0),
			AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1,
			Visible=open
		},
		root
	)

	Pad(
		content,
		12,
		12,
		0,
		12
	)

	local layout=New(
		"UIListLayout",
		{
			Padding=UDim.new(0,7),
			SortOrder=Enum.SortOrder.LayoutOrder
		},
		content
	)

	local c={
		Type="Collapsible",
		Card=root,
		Content=content
	}

	function c:SetOpen(value)
		open=value==true
		content.Visible=open
		arrow.Text=open and "−" or "+"
	end

	function c:GetOpen()
		return open
	end

	function c:AddText(text)
		local label=Label(
			content,
			tostring(text or ""),
			11,
			self.Window.Theme.Muted,
			false
		)

		label.Size=UDim2.new(
			1,
			0,
			0,
			22
		)

		return label
	end

	header.MouseButton1Click:Connect(function()
		c:SetOpen(
			not open
		)
	end)

	return c
end

function Window:SetBackgroundImage(source,transparency)
	return self:SetBackground(
		source,
		transparency
	)
end

function Window:ClearBackground()
	self.BackgroundImage.Image=""
	self.BackgroundImage.ImageTransparency=1
end

function Window:GetTheme()
	local copy={}

	for key,value in pairs(self.Theme) do
		copy[key]=value
	end

	return copy
end

function Window:SetTheme(theme)
	if type(theme)~="table" then
		return
	end

	for key,value in pairs(theme) do
		if self.Theme[key]~=nil then
			self.Theme[key]=value
		end
	end

	self.Main.BackgroundColor3=self.Theme.Background
	self.Topbar.BackgroundColor3=self.Theme.Topbar
	self.MainStroke.Color=self.Neon and self.Theme.Accent or self.Theme.Border

	for _,tab in ipairs(self.Tabs) do
		tab.Indicator.BackgroundColor3=self.Theme.Accent
	end
end

function Window:ResetTheme()
	for key,value in pairs(DEFAULT) do
		self.Theme[key]=value
	end

	self:SetTheme(
		self.Theme
	)
end

function Window:GetFlags()
	local copy={}

	for key,value in pairs(self.Flags) do
		copy[key]=value
	end

	return copy
end

function Window:ClearFlags()
	table.clear(
		self.Flags
	)
end

function Window:Show()
	self:SetVisible(
		true
	)
end

function Window:Hide()
	self:SetVisible(
		false
	)
end

function Window:IsVisible()
	return self.Visible
end


function Section:AddColorPicker(o)
	o=o or {}
	local value=o.Default or self.Window.Theme.Accent
	local baseHeight=o.Description and 64 or 56
	local card=New("Frame",{
		Size=UDim2.new(1,0,0,baseHeight),
		BackgroundColor3=self.Window.Theme.Card,
		BorderSizePixel=0,
		ClipsDescendants=true
	},self.Frame)
	Corner(card,8)

	local title=Label(card,o.Name or "Color",13,self.Window.Theme.Text,true)
	title.Position=UDim2.fromOffset(13,o.Description and 7 or 0)
	title.Size=UDim2.new(1,-190,o.Description and 0 or 1,o.Description and 20 or 0)
	if o.Description then
		local desc=Label(card,o.Description,10,self.Window.Theme.Muted,false)
		desc.Position=UDim2.fromOffset(13,28)
		desc.Size=UDim2.new(1,-190,0,16)
	end

	local preview=Button(card,"",1,self.Window.Theme.Text,false)
	preview.AnchorPoint=Vector2.new(1,0)
	preview.Position=UDim2.new(1,-12,0,12)
	preview.Size=UDim2.fromOffset(42,32)
	preview.BackgroundTransparency=0
	preview.BackgroundColor3=value
	Corner(preview,7)

	local panel=New("Frame",{
		Position=UDim2.fromOffset(12,baseHeight),
		Size=UDim2.new(1,-24,0,184),
		BackgroundTransparency=1,
		Visible=false
	},card)

	local palette=New("Frame",{
		Size=UDim2.new(1,0,0,120),
		BackgroundColor3=Color3.new(1,1,1),
		BorderSizePixel=0
	},panel)
	Corner(palette,7)

	local hue=New("UIGradient",{
		Color=ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(.17,Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(.34,Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(.51,Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(.68,Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(.85,Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
		})
	},palette)

	local shade=New("Frame",{
		Size=UDim2.fromScale(1,1),
		BackgroundColor3=Color3.new(1,1,1),
		BackgroundTransparency=1,
		BorderSizePixel=0
	},palette)
	Corner(shade,7)
	New("UIGradient",{
		Rotation=90,
		Transparency=NumberSequence.new({
			NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(1,0)
		}),
		Color=ColorSequence.new(Color3.new(0,0,0))
	},shade)

	local hex=New("TextBox",{
		Position=UDim2.fromOffset(0,132),
		Size=UDim2.new(1,0,0,34),
		BackgroundColor3=self.Window.Theme.Control,
		BorderSizePixel=0,
		Text=string.format("#%02X%02X%02X",math.floor(value.R*255+.5),math.floor(value.G*255+.5),math.floor(value.B*255+.5)),
		PlaceholderText="#RRGGBB",
		PlaceholderColor3=self.Window.Theme.Muted,
		TextColor3=self.Window.Theme.Text,
		TextSize=11,
		Font=Enum.Font.Gotham,
		ClearTextOnFocus=false
	},panel)
	Corner(hex,7)

	local c={Type="ColorPicker",Window=self.Window,Section=self,Card=card,Name=o.Name or "Color"}
	table.insert(self.Components,c)
	local open=false

	local function apply(v,fire)
		value=v
		preview.BackgroundColor3=value
		hex.Text=string.format("#%02X%02X%02X",math.floor(value.R*255+.5),math.floor(value.G*255+.5),math.floor(value.B*255+.5))
		if o.Flag then self.Window.Flags[o.Flag]=hex.Text end
		if fire then task.spawn(o.Callback or function() end,value) end
	end

	local function setOpen(state)
		open=state
		panel.Visible=open
		Tween(card,.15,{Size=UDim2.new(1,0,0,baseHeight+(open and 196 or 0))})
	end

	local dragging=false
	local function pick()
		local pos=UIS:GetMouseLocation()
		local x=math.clamp((pos.X-palette.AbsolutePosition.X)/palette.AbsoluteSize.X,0,1)
		local y=math.clamp((pos.Y-palette.AbsolutePosition.Y)/palette.AbsoluteSize.Y,0,1)
		apply(Color3.fromHSV(x,1,1-y*.88),true)
	end

	palette.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 then
			dragging=true
			pick()
		end
	end)

	table.insert(self.Window.Connections,UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then pick() end
	end))
	table.insert(self.Window.Connections,UIS.InputEnded:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
	end))

	hex.FocusLost:Connect(function()
		local clean=hex.Text:gsub("#",""):gsub("%s","")
		if #clean==6 then
			local r=tonumber(clean:sub(1,2),16)
			local g=tonumber(clean:sub(3,4),16)
			local b=tonumber(clean:sub(5,6),16)
			if r and g and b then
				apply(Color3.fromRGB(r,g,b),true)
				return
			end
		end
		hex.Text=string.format("#%02X%02X%02X",math.floor(value.R*255+.5),math.floor(value.G*255+.5),math.floor(value.B*255+.5))
	end)

	preview.MouseButton1Click:Connect(function() setOpen(not open) end)

	function c:Set(v)
		if typeof(v)=="Color3" then apply(v,true) end
	end
	function c:Get() return value end
	function c:SetOpen(v) setOpen(v) end

	return c
end

function Section:AddPlayerDropdown(o)
	o=o or {}
	local selected=o.Default
	local card,controls,c=self:_Base(o,o.Description and 70 or 62)
	c.Type="PlayerDropdown"

	local button=Button(controls,selected and selected.DisplayName or "Select player",11,self.Window.Theme.Text,false)
	button.AnchorPoint=Vector2.new(1,.5)
	button.Position=UDim2.new(1,0,.5,0)
	button.Size=UDim2.fromOffset(155,34)
	button.BackgroundTransparency=0
	button.BackgroundColor3=self.Window.Theme.Control
	Corner(button,7)

	local popup

	local function close()
		if popup then
			popup:Destroy()
			popup=nil
		end
	end

	local function selectPlayer(player)
		selected=player
		button.Text=player and player.DisplayName or "Select player"
		close()
		if o.Flag then
			self.Window.Flags[o.Flag]=player and player.Name or nil
		end
		task.spawn(o.Callback or function() end,player)
	end

	button.MouseButton1Click:Connect(function()
		if popup then
			close()
			return
		end

		popup=New("Frame",{
			Position=UDim2.fromOffset(
				math.max(8,button.AbsolutePosition.X-95),
				button.AbsolutePosition.Y+button.AbsoluteSize.Y+5
			),
			Size=UDim2.fromOffset(250,300),
			BackgroundColor3=self.Window.Theme.Panel,
			BorderSizePixel=0,
			ZIndex=180
		},self.Window.Gui)
		Corner(popup,9)
		Stroke(popup,self.Window.Theme.Border,1)
		Pad(popup,8,8,8,8)

		local search=New("TextBox",{
			Size=UDim2.new(1,0,0,32),
			BackgroundColor3=self.Window.Theme.Control,
			BorderSizePixel=0,
			Text="",
			PlaceholderText="Search player...",
			PlaceholderColor3=self.Window.Theme.Muted,
			TextColor3=self.Window.Theme.Text,
			TextSize=11,
			Font=Enum.Font.Gotham,
			ClearTextOnFocus=false,
			ZIndex=181
		},popup)
		Corner(search,7)
		Pad(search,10,10,0,0)

		local list=New("ScrollingFrame",{
			Position=UDim2.fromOffset(0,40),
			Size=UDim2.new(1,0,1,-40),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			ScrollBarThickness=2,
			ScrollBarImageColor3=self.Window.Theme.Border,
			CanvasSize=UDim2.new(),
			ZIndex=181
		},popup)

		local layout=New("UIListLayout",{
			Padding=UDim.new(0,5),
			SortOrder=Enum.SortOrder.LayoutOrder
		},list)

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+4)
		end)

		local entries={}

		local function add(player)
			local row=Button(list,"",1,self.Window.Theme.Text,false)
			row.Size=UDim2.new(1,-4,0,50)
			row.BackgroundTransparency=0
			row.BackgroundColor3=self.Window.Theme.Card
			row.ZIndex=182
			Corner(row,7)

			local avatar=New("ImageLabel",{
				Position=UDim2.fromOffset(7,7),
				Size=UDim2.fromOffset(36,36),
				BackgroundColor3=self.Window.Theme.Control,
				BorderSizePixel=0,
				Image="",
				ZIndex=183
			},row)
			Corner(avatar,18)

			task.spawn(function()
				local ok,image=pcall(function()
					return Players:GetUserThumbnailAsync(
						player.UserId,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size100x100
					)
				end)
				if ok and avatar.Parent then
					avatar.Image=image
				end
			end)

			local display=Label(row,player.DisplayName,11,self.Window.Theme.Text,true)
			display.Position=UDim2.fromOffset(52,6)
			display.Size=UDim2.new(1,-58,0,19)
			display.ZIndex=183

			local username=Label(row,"@"..player.Name,10,self.Window.Theme.Muted,false)
			username.Position=UDim2.fromOffset(52,25)
			username.Size=UDim2.new(1,-58,0,18)
			username.ZIndex=183

			row.MouseButton1Click:Connect(function()
				selectPlayer(player)
			end)

			table.insert(entries,{
				Player=player,
				Row=row
			})
		end

		for _,player in ipairs(Players:GetPlayers()) do
			add(player)
		end

		local function filter()
			local q=string.lower(search.Text)

			for _,entry in ipairs(entries) do
				local player=entry.Player
				local hay=string.lower(player.DisplayName.." "..player.Name)
				entry.Row.Visible=q=="" or string.find(hay,q,1,true)~=nil
			end
		end

		search:GetPropertyChangedSignal("Text"):Connect(filter)
	end)

	function c:Get()
		return selected
	end

	function c:Set(player)
		selectPlayer(player)
	end

	return c
end

function Window:OpenConfirm(o)
	o=o or {}

	local overlay=New("TextButton",{
		Size=UDim2.fromScale(1,1),
		BackgroundColor3=Color3.new(0,0,0),
		BackgroundTransparency=.35,
		BorderSizePixel=0,
		Text="",
		AutoButtonColor=false,
		ZIndex=400
	},self.Gui)

	local box=New("Frame",{
		AnchorPoint=Vector2.new(.5,.5),
		Position=UDim2.fromScale(.5,.5),
		Size=UDim2.fromOffset(360,170),
		BackgroundColor3=self.Theme.Panel,
		BorderSizePixel=0,
		ZIndex=401
	},overlay)
	Corner(box,12)
	Stroke(box,self.Neon and self.Theme.Accent or self.Theme.Border,1)

	local title=Label(box,o.Title or "Confirm",15,self.Theme.Text,true)
	title.Position=UDim2.fromOffset(18,15)
	title.Size=UDim2.new(1,-36,0,24)
	title.ZIndex=402

	local content=Label(box,o.Content or "Are you sure?",11,self.Theme.Muted,false)
	content.Position=UDim2.fromOffset(18,46)
	content.Size=UDim2.new(1,-36,0,55)
	content.TextWrapped=true
	content.TextTruncate=Enum.TextTruncate.None
	content.TextYAlignment=Enum.TextYAlignment.Top
	content.ZIndex=402

	local cancel=Button(box,o.CancelText or "Cancel",11,self.Theme.Text,true)
	cancel.Position=UDim2.new(1,-174,1,-47)
	cancel.Size=UDim2.fromOffset(74,32)
	cancel.BackgroundTransparency=0
	cancel.BackgroundColor3=self.Theme.Control
	cancel.ZIndex=402
	Corner(cancel,7)

	local confirm=Button(box,o.ConfirmText or "Confirm",11,self.Theme.Text,true)
	confirm.Position=UDim2.new(1,-92,1,-47)
	confirm.Size=UDim2.fromOffset(74,32)
	confirm.BackgroundTransparency=0
	confirm.BackgroundColor3=o.Danger and self.Theme.Danger or self.Theme.Accent
	confirm.ZIndex=402
	Corner(confirm,7)

	cancel.MouseButton1Click:Connect(function()
		overlay:Destroy()
		task.spawn(o.OnCancel or function() end)
	end)

	confirm.MouseButton1Click:Connect(function()
		overlay:Destroy()
		task.spawn(o.OnConfirm or function() end)
	end)

	return overlay
end

function Window:SetWatermark(o)
	if o==false then
		if self.Watermark then
			self.Watermark:Destroy()
			self.Watermark=nil
		end
		return
	end

	if type(o)=="string" then
		o={Text=o}
	end

	o=o or {}

	if self.Watermark then
		self.Watermark:Destroy()
	end

	local frame=New("Frame",{
		Position=o.Position or UDim2.fromOffset(14,14),
		Size=UDim2.fromOffset(o.Width or 190,30),
		BackgroundColor3=self.Theme.Panel,
		BorderSizePixel=0,
		ZIndex=220
	},self.Gui)
	Corner(frame,7)
	Stroke(frame,self.Neon and self.Theme.Accent or self.Theme.Border,1)

	local text=Label(frame,o.Text or self.Title.."  |  "..LucidUI.Version,10,self.Theme.Text,true)
	text.Position=UDim2.fromOffset(9,0)
	text.Size=UDim2.new(1,-18,1,0)
	text.ZIndex=221

	self.Watermark=frame
	return frame
end

function Window:AddFloatingButton(o)
	o=o or {}

	local button=Button(self.Gui,o.Text or "+",o.TextSize or 18,self.Theme.Text,true)
	button.AnchorPoint=Vector2.new(1,1)
	button.Position=o.Position or UDim2.new(1,-18,1,-18)
	button.Size=UDim2.fromOffset(o.Size or 48,o.Size or 48)
	button.BackgroundTransparency=0
	button.BackgroundColor3=o.Color or self.Theme.Accent
	button.ZIndex=230
	Corner(button,o.Round==false and 9 or 24)
	Stroke(button,self.Neon and self.Theme.Accent or self.Theme.Border,1)

	button.MouseButton1Click:Connect(function()
		task.spawn(o.Callback or function()
			self:Toggle()
		end)
	end)

	return button
end

function Window:CreateConfigManager()
	local manager={}
	manager.Window=self

	local function folder()
		return "LucidUI"
	end

	local function path(name)
		return folder().."/"..tostring(name or "default")..".json"
	end

	function manager:IsSupported()
		return writefile~=nil and readfile~=nil
	end

	function manager:Save(name)
		if not writefile then
			return false,"writefile unavailable"
		end

		if makefolder and isfolder and not isfolder(folder()) then
			pcall(makefolder,folder())
		end

		local data={
			Version=LucidUI.Version,
			Flags=self.Window:GetFlags(),
			Style={
				Shape=self.Window.Shape,
				Neon=self.Window.Neon,
				Accent={
					R=math.floor(self.Window.Theme.Accent.R*255+.5),
					G=math.floor(self.Window.Theme.Accent.G*255+.5),
					B=math.floor(self.Window.Theme.Accent.B*255+.5)
				}
			}
		}

		local ok,encoded=pcall(function()
			return HttpService:JSONEncode(data)
		end)

		if not ok then
			return false,encoded
		end

		return pcall(writefile,path(name),encoded)
	end

	function manager:Load(name)
		if not readfile then
			return false,"readfile unavailable"
		end

		local ok,raw=pcall(readfile,path(name))
		if not ok then
			return false,raw
		end

		local decoded
		ok,decoded=pcall(function()
			return HttpService:JSONDecode(raw)
		end)

		if not ok then
			return false,decoded
		end

		for key,value in pairs(decoded.Flags or {}) do
			self.Window.Flags[key]=value
		end

		local style=decoded.Style or {}

		if style.Shape then
			self.Window:SetShape(style.Shape)
		end

		if style.Neon~=nil then
			self.Window:SetNeon(style.Neon)
		end

		if style.Accent then
			self.Window:SetAccent(Color3.fromRGB(
				style.Accent.R or 116,
				style.Accent.G or 82,
				style.Accent.B or 255
			))
		end

		return true,decoded
	end

	function manager:Delete(name)
		if not delfile then
			return false,"delfile unavailable"
		end

		return pcall(delfile,path(name))
	end

	function manager:Exists(name)
		if not isfile then
			return false
		end

		local ok,result=pcall(isfile,path(name))
		return ok and result
	end

	return manager
end

function Window:AddLibrarySettings()
	local tab=self:AddTab("Library")
	local appearance=tab:AddSection("Appearance")

	appearance:AddDropdown({
		Name="Window shape",
		Description="Choose the corner style",
		Options={"Rounded","Soft","Square"},
		Default=self.Shape,
		Callback=function(value)
			self:SetShape(value)
		end
	})

	appearance:AddColorPicker({
		Name="Accent color",
		Description="Changes the main Lucid accent",
		Default=self.Theme.Accent,
		Callback=function(value)
			self:SetAccent(value)
		end
	})

	appearance:AddToggle({
		Name="Neon",
		Description="Accent border glow style",
		Default=self.Neon,
		Bindable=false,
		Callback=function(value)
			self:SetNeon(value)
		end
	})

	appearance:AddSlider({
		Name="Background opacity",
		Description="Opacity of the custom image",
		Min=0,
		Max=100,
		Default=75,
		Suffix="%",
		Callback=function(value)
			self.BackgroundImage.ImageTransparency=1-(value/100)
		end
	})

	appearance:AddTextbox({
		Name="Background image",
		Description="Asset ID, rbxassetid:// or URL when supported",
		Placeholder="Paste URL or asset ID",
		Callback=function(value)
			if value=="" then
				self:ClearBackground()
			else
				self:SetBackground(value,self.BackgroundImage.ImageTransparency)
			end
		end
	})

	appearance:AddButtonGroup({
		Name="Presets",
		Options={
			{
				Name="Dark",
				Callback=function()
					self:SetAccent(Color3.fromRGB(116,82,255))
					self:SetNeon(false)
					self:SetShape("Rounded")
				end
			},
			{
				Name="Neon",
				Callback=function()
					self:SetNeon(true)
				end
			},
			{
				Name="Square",
				Callback=function()
					self:SetShape("Square")
				end
			}
		}
	})

	local interface=tab:AddSection("Interface")

	interface:AddSlider({
		Name="UI scale",
		Description="Changes the size of the whole interface",
		Min=70,
		Max=130,
		Default=100,
		Suffix="%",
		Callback=function(value)
			local scale=self.Main:FindFirstChild("LucidUIScale")
			if not scale then
				scale=New("UIScale",{Name="LucidUIScale",Scale=1},self.Main)
			end
			scale.Scale=value/100
		end
	})

	interface:AddSlider({
		Name="Panel transparency",
		Description="Transparency of the main window",
		Min=0,
		Max=60,
		Default=0,
		Suffix="%",
		Callback=function(value)
			self.Main.BackgroundTransparency=value/100
			self.Topbar.BackgroundTransparency=value/100
		end
	})

	interface:AddToggle({
		Name="Watermark",
		Description="Shows the Lucid watermark",
		Default=false,
		Bindable=false,
		Callback=function(value)
			if value then
				self:SetWatermark({Text=self.Title.."  |  "..LucidUI.Version})
			else
				self:SetWatermark(false)
			end
		end
	})

	interface:AddButton({
		Name="Center window",
		Description="Moves the interface back to the center",
		ActionText="Center",
		Callback=function()
			self:Center()
		end
	})

	local config=tab:AddSection("Config Manager")
	local manager=self:CreateConfigManager()

	local nameBox=config:AddTextbox({
		Name="Config name",
		Placeholder="default"
	})

	config:AddButtonGroup({
		Name="Config",
		Options={
			{
				Name="Save",
				Callback=function()
					local name=nameBox:Get()
					if name=="" then
						name="default"
					end
					local ok=manager:Save(name)
					self:Notify({
						Title="Config",
						Content=ok and "Saved: "..name or "Save failed"
					})
				end
			},
			{
				Name="Load",
				Callback=function()
					local name=nameBox:Get()
					if name=="" then
						name="default"
					end
					local ok=manager:Load(name)
					self:Notify({
						Title="Config",
						Content=ok and "Loaded: "..name or "Load failed"
					})
				end
			},
			{
				Name="Delete",
				Callback=function()
					local name=nameBox:Get()
					if name=="" then
						name="default"
					end
					self:OpenConfirm({
						Title="Delete config",
						Content="Delete '"..name.."'?",
						Danger=true,
						OnConfirm=function()
							manager:Delete(name)
						end
					})
				end
			}
		}
	})

	return tab
end

function Window:Destroy()
	for _,c in ipairs(self.Connections) do
		pcall(function() c:Disconnect() end)
	end
	if self.Gui then
		pcall(function() self.Gui:Destroy() end)
	end
end

return LucidUI
