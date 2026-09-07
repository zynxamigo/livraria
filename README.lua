------LUCIANO HUUUUKKLLLLLLLLLLL
local LucidUI = {}
LucidUI.Version = "5.2.0-stable"

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

	local controls=New("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.fromOffset(108,34),BackgroundTransparency=1,ZIndex=7},top)
	New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,7)},controls)
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
	local bind=Button(row,c.Bind and c.Bind.Name or "+",11,self.Window.Theme.Muted,true)
	bind.Position=UDim2.fromOffset(0,0) bind.Size=UDim2.fromOffset(48,32)
	bind.BackgroundTransparency=0 bind.BackgroundColor3=self.Window.Theme.Control Corner(bind,7)
	local track=Button(row,"",1,self.Window.Theme.Text,false)
	track.Position=UDim2.fromOffset(62,4) track.Size=UDim2.fromOffset(44,24)
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
	local card,controls,c=self:_Base(o,o.Description and 64 or 56)
	c.Type="Dropdown"
	local b=Button(controls,value and tostring(value) or (o.Placeholder or "Select"),11,self.Window.Theme.Text,false)
	b.AnchorPoint=Vector2.new(1,.5) b.Position=UDim2.new(1,0,.5,0) b.Size=UDim2.fromOffset(145,32) b.BackgroundTransparency=0 b.BackgroundColor3=self.Window.Theme.Control Corner(b,7)
	local popup
	local function close() if popup then popup:Destroy() popup=nil end end
	b.MouseButton1Click:Connect(function()
		if popup then close() return end
		popup=New("Frame",{Position=UDim2.fromOffset(b.AbsolutePosition.X,b.AbsolutePosition.Y+b.AbsoluteSize.Y+5),Size=UDim2.fromOffset(b.AbsoluteSize.X,math.min(180,#items*32+8)),BackgroundColor3=self.Window.Theme.Panel,BorderSizePixel=0,ZIndex=100},self.Window.Gui)
		Corner(popup,8) Stroke(popup,self.Window.Theme.Border,1) Pad(popup,4,4,4,4)
		New("UIListLayout",{Padding=UDim.new(0,3)},popup)
		for _,v in ipairs(items) do
			local it=Button(popup,tostring(v),11,self.Window.Theme.Text,false)
			it.Size=UDim2.new(1,0,0,28) it.BackgroundTransparency=0 it.BackgroundColor3=self.Window.Theme.Card it.ZIndex=101 Corner(it,6)
			it.MouseButton1Click:Connect(function() value=v b.Text=tostring(v) close() if o.Flag then self.Window.Flags[o.Flag]=v end task.spawn(o.Callback or function() end,v) end)
		end
	end)
	c.Set=function(_,v) value=v b.Text=tostring(v) end c.Get=function() return value end
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

	for _,value in ipairs(o.Default or {}) do
		selected[value]=true
	end

	local card,controls,c=self:_Base(
		o,
		o.Description and 64 or 56
	)

	c.Type="MultiDropdown"

	local button=Button(
		controls,
		"Select",
		11,
		self.Window.Theme.Text,
		false
	)

	button.AnchorPoint=Vector2.new(1,.5)
	button.Position=UDim2.new(1,0,.5,0)
	button.Size=UDim2.fromOffset(145,32)
	button.BackgroundTransparency=0
	button.BackgroundColor3=self.Window.Theme.Control

	Corner(
		button,
		7
	)

	local popup=nil

	local function getArray()
		local result={}

		for _,value in ipairs(values) do
			if selected[value] then
				table.insert(
					result,
					value
				)
			end
		end

		return result
	end

	local function refreshText()
		local list=getArray()

		if #list==0 then
			button.Text=o.Placeholder or "Select"
		elseif #list==1 then
			button.Text=tostring(list[1])
		else
			button.Text=tostring(#list).." selected"
		end
	end

	local function fire()
		local list=getArray()

		if o.Flag then
			self.Window.Flags[o.Flag]=list
		end

		task.spawn(
			o.Callback or function()
			end,
			list
		)
	end

	local function close()
		if popup then
			popup:Destroy()
			popup=nil
		end
	end

	button.MouseButton1Click:Connect(function()
		if popup then
			close()
			return
		end

		local height=math.min(
			210,
			#values*34+8
		)

		popup=New(
			"Frame",
			{
				Position=UDim2.fromOffset(
					button.AbsolutePosition.X,
					button.AbsolutePosition.Y+button.AbsoluteSize.Y+5
				),
				Size=UDim2.fromOffset(
					button.AbsoluteSize.X,
					height
				),
				BackgroundColor3=self.Window.Theme.Panel,
				BorderSizePixel=0,
				ZIndex=120
			},
			self.Window.Gui
		)

		Corner(
			popup,
			8
		)

		Stroke(
			popup,
			self.Window.Theme.Border,
			1
		)

		Pad(
			popup,
			4,
			4,
			4,
			4
		)

		New(
			"UIListLayout",
			{
				Padding=UDim.new(0,3)
			},
			popup
		)

		for _,value in ipairs(values) do
			local item=Button(
				popup,
				"",
				11,
				self.Window.Theme.Text,
				false
			)

			item.Size=UDim2.new(
				1,
				0,
				0,
				30
			)

			item.BackgroundTransparency=0
			item.BackgroundColor3=self.Window.Theme.Card
			item.ZIndex=121

			Corner(
				item,
				6
			)

			local mark=New(
				"Frame",
				{
					Position=UDim2.fromOffset(8,8),
					Size=UDim2.fromOffset(14,14),
					BackgroundColor3=selected[value] and self.Window.Theme.Accent or self.Window.Theme.Control,
					BorderSizePixel=0,
					ZIndex=122
				},
				item
			)

			Corner(
				mark,
				4
			)

			local text=Label(
				item,
				tostring(value),
				11,
				self.Window.Theme.Text,
				false
			)

			text.Position=UDim2.fromOffset(
				30,
				0
			)

			text.Size=UDim2.new(
				1,
				-34,
				1,
				0
			)

			text.ZIndex=122

			item.MouseButton1Click:Connect(function()
				selected[value]=not selected[value]

				mark.BackgroundColor3=selected[value] and self.Window.Theme.Accent or self.Window.Theme.Control

				refreshText()
				fire()
			end)
		end
	end)

	function c:Get()
		return getArray()
	end

	function c:Set(list)
		selected={}

		for _,value in ipairs(list or {}) do
			selected[value]=true
		end

		refreshText()
		fire()
	end

	function c:Close()
		close()
	end

	refreshText()

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

function Window:Destroy()
	for _,c in ipairs(self.Connections) do
		pcall(function() c:Disconnect() end)
	end
	if self.Gui then
		pcall(function() self.Gui:Destroy() end)
	end
end

return LucidUI
