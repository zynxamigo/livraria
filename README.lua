------- EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
local LucidUI = {}
LucidUI.Version = "6.0.0"

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local GLOBAL_ENV = (getgenv and getgenv()) or _G
local REGISTRY_KEY = "__LUCID_UI_RUNTIME_REGISTRY_V6"

local function cleanupKnownLibraries()
	local registry = GLOBAL_ENV[REGISTRY_KEY]
	if type(registry) == "table" then
		if type(registry.Destroy) == "function" then
			pcall(registry.Destroy)
		end
		if registry.Gui and typeof(registry.Gui) == "Instance" then
			pcall(function()
				registry.Gui:Destroy()
			end)
		end
	end

	local roots = {
		CoreGui,
		LP and LP:FindFirstChild("PlayerGui")
	}

	local knownNames = {
		"LucidUI",
		"LucidUI_V3",
		"LucidUI_V4",
		"LucidUI_V5",
		"LucidUI_V6",
		"Rayfield",
		"RayfieldLibrary",
		"Orion",
		"OrionLib",
		"Obsidian",
		"ObsidianUI"
	}

	for _, root in ipairs(roots) do
		if root then
			for _, name in ipairs(knownNames) do
				local gui = root:FindFirstChild(name)
				if gui then
					pcall(function()
						gui:Destroy()
					end)
				end
			end

			for _, child in ipairs(root:GetChildren()) do
				if child:IsA("ScreenGui") then
					local marker = child:GetAttribute("LucidLibraryRuntime")
					if marker == true then
						pcall(function()
							child:Destroy()
						end)
					end
				end
			end
		end
	end
end

cleanupKnownLibraries()

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

	local gui=New("ScreenGui",{Name="LucidUI_V6",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=false},nil)
	SafeParent(gui)
	self.Gui=gui
	gui:SetAttribute("LucidLibraryRuntime", true)
	gui:SetAttribute("LucidLibraryName", "LucidUI")
	gui:SetAttribute("LucidLibraryVersion", LucidUI.Version)

	GLOBAL_ENV[REGISTRY_KEY] = {
		Gui = gui,
		Destroy = function()
			if gui and gui.Parent then
				gui:Destroy()
			end
		end
	}

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
		if v and self.FirstP then
			UIS.MouseIconEnabled=true
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
	if type(o)=="string" then o={Name=o} end
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
	if type(o)=="string" then o={Name=o} end
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
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then mouse() end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
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

	local button=Button(
		controls,
		c.Bind and c.Bind.Name or "None",
		11,
		self.Window.Theme.Text,
		true
	)
	button.AnchorPoint=Vector2.new(1,.5)
	button.Position=UDim2.new(1,0,.5,0)
	button.Size=UDim2.fromOffset(100,32)
	button.BackgroundTransparency=0
	button.BackgroundColor3=self.Window.Theme.Control
	Corner(button,7)

	function c:Set(v)
		self.Bind=v
		button.Text=v and v.Name or "None"
		if o.Flag then
			self.Window.Flags[o.Flag]=v and v.Name or nil
		end
	end

	function c:Get()
		return self.Bind
	end

	button.MouseButton1Click:Connect(function()
		if c.Binding then
			return
		end

		c.Binding=true
		button.Text="Press key..."

		local connection
		connection=UIS.InputBegan:Connect(function(input)
			if input.UserInputType~=Enum.UserInputType.Keyboard then
				return
			end

			connection:Disconnect()
			c.Binding=false

			if input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.Backspace then
				c:Set(nil)
			else
				c:Set(input.KeyCode)
			end
		end)
	end)

	table.insert(
		self.Window.Connections,
		UIS.InputBegan:Connect(function(input,processed)
			if processed or c.Binding then
				return
			end

			if c.Bind and input.KeyCode==c.Bind then
				task.spawn(
					o.Callback or function()
					end,
					c.Bind
				)
			end
		end)
	)

	return c
end

function Section:AddNumberbox(o)
	o=o or {}
	local value=tonumber(o.Default) or 0
	local _,controls,c=self:_Base(o,o.Description and 64 or 56)
	c.Type="Numberbox"

	local box=New(
		"TextBox",
		{
			AnchorPoint=Vector2.new(1,.5),
			Position=UDim2.new(1,0,.5,0),
			Size=UDim2.fromOffset(110,32),
			BackgroundColor3=self.Window.Theme.Control,
			BorderSizePixel=0,
			Text=tostring(value),
			TextColor3=self.Window.Theme.Text,
			TextSize=11,
			Font=Enum.Font.Gotham,
			ClearTextOnFocus=false
		},
		controls
	)
	Corner(box,7)

	local function set(v,fire)
		v=tonumber(v)
		if not v then
			box.Text=tostring(value)
			return
		end

		if o.Min then
			v=math.max(o.Min,v)
		end

		if o.Max then
			v=math.min(o.Max,v)
		end

		value=v
		box.Text=tostring(value)

		if o.Flag then
			self.Window.Flags[o.Flag]=value
		end

		if fire then
			task.spawn(
				o.Callback or function()
				end,
				value
			)
		end
	end

	box.FocusLost:Connect(function()
		set(box.Text,true)
	end)

	c.Set=function(_,v)
		set(v,true)
	end

	c.Get=function()
		return value
	end

	return c
end

function Section:AddParagraph(o)
	o=o or {}

	local card=New(
		"Frame",
		{
			Size=UDim2.new(1,0,0,o.Height or 92),
			BackgroundColor3=self.Window.Theme.Card,
			BorderSizePixel=0
		},
		self.Frame
	)
	Corner(card,8)
	Pad(card,13,13,10,10)

	local layout=New(
		"UIListLayout",
		{
			Padding=UDim.new(0,5),
			SortOrder=Enum.SortOrder.LayoutOrder
		},
		card
	)

	local title=Label(
		card,
		o.Name or o.Title or "Paragraph",
		13,
		self.Window.Theme.Text,
		true
	)
	title.Size=UDim2.new(1,0,0,20)

	local text=Label(
		card,
		o.Content or o.Text or "",
		11,
		self.Window.Theme.Muted,
		false
	)
	text.Size=UDim2.new(1,0,0,o.Height and o.Height-45 or 47)
	text.TextWrapped=true
	text.TextTruncate=Enum.TextTruncate.None
	text.TextYAlignment=Enum.TextYAlignment.Top

	local c={
		Type="Paragraph",
		Card=card
	}

	function c:Set(v)
		text.Text=tostring(v or "")
	end

	return c
end

function Section:AddDivider(o)
	o=o or {}

	local holder=New(
		"Frame",
		{
			Size=UDim2.new(1,0,0,24),
			BackgroundTransparency=1
		},
		self.Frame
	)

	local line=New(
		"Frame",
		{
			AnchorPoint=Vector2.new(.5,.5),
			Position=UDim2.fromScale(.5,.5),
			Size=UDim2.new(1,-10,0,1),
			BackgroundColor3=self.Window.Theme.Border,
			BorderSizePixel=0
		},
		holder
	)

	return {
		Type="Divider",
		Frame=holder,
		Line=line
	}
end

function Section:AddHeader(o)
	if type(o)=="string" then
		o={
			Name=o
		}
	end

	o=o or {}

	local holder=New(
		"Frame",
		{
			Size=UDim2.new(1,0,0,34),
			BackgroundTransparency=1
		},
		self.Frame
	)

	local title=Label(
		holder,
		o.Name or "Header",
		15,
		self.Window.Theme.Text,
		true
	)
	title.Size=UDim2.fromScale(1,1)

	return {
		Type="Header",
		Frame=holder,
		Text=title
	}
end

function Section:AddProgress(o)
	o=o or {}
	local value=math.clamp(o.Default or 0,o.Min or 0,o.Max or 100)
	local min=o.Min or 0
	local max=o.Max or 100

	local card=New(
		"Frame",
		{
			Size=UDim2.new(1,0,0,68),
			BackgroundColor3=self.Window.Theme.Card,
			BorderSizePixel=0
		},
		self.Frame
	)
	Corner(card,8)

	local title=Label(
		card,
		o.Name or "Progress",
		13,
		self.Window.Theme.Text,
		true
	)
	title.Position=UDim2.fromOffset(13,7)
	title.Size=UDim2.new(1,-80,0,20)

	local amount=Label(
		card,
		"",
		11,
		self.Window.Theme.Muted,
		true
	)
	amount.AnchorPoint=Vector2.new(1,0)
	amount.Position=UDim2.new(1,-13,0,7)
	amount.Size=UDim2.fromOffset(60,20)
	amount.TextXAlignment=Enum.TextXAlignment.Right

	local bar=New(
		"Frame",
		{
			Position=UDim2.fromOffset(13,43),
			Size=UDim2.new(1,-26,0,8),
			BackgroundColor3=self.Window.Theme.Control,
			BorderSizePixel=0
		},
		card
	)
	Corner(bar,8)

	local fill=New(
		"Frame",
		{
			Size=UDim2.fromScale(0,1),
			BackgroundColor3=self.Window.Theme.Accent,
			BorderSizePixel=0
		},
		bar
	)
	Corner(fill,8)

	local c={
		Type="Progress",
		Card=card
	}

	function c:Set(v)
		value=math.clamp(tonumber(v) or min,min,max)
		local alpha=(value-min)/(max-min)
		amount.Text=string.format(
			o.Format or "%d%%",
			value
		)
		Tween(
			fill,
			.12,
			{
				Size=UDim2.fromScale(alpha,1)
			}
		)
	end

	function c:Get()
		return value
	end

	c:Set(value)
	return c
end

function Window:Notify(o)
	if type(o)=="string" then
		o={
			Title="Lucid",
			Content=o
		}
	end

	o=o or {}

	if not self.NotificationHolder then
		local holder=New(
			"Frame",
			{
				Name="Notifications",
				AnchorPoint=Vector2.new(1,1),
				Position=UDim2.new(1,-18,1,-18),
				Size=UDim2.fromOffset(330,420),
				BackgroundTransparency=1,
				ZIndex=300
			},
			self.Gui
		)

		New(
			"UIListLayout",
			{
				VerticalAlignment=Enum.VerticalAlignment.Bottom,
				HorizontalAlignment=Enum.HorizontalAlignment.Right,
				Padding=UDim.new(0,8)
			},
			holder
		)

		self.NotificationHolder=holder
	end

	local card=New(
		"Frame",
		{
			Size=UDim2.fromOffset(310,0),
			AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundColor3=self.Theme.Panel,
			BorderSizePixel=0,
			ZIndex=301
		},
		self.NotificationHolder
	)
	Corner(card,10)
	Stroke(card,self.Neon and self.Theme.Accent or self.Theme.Border,1)
	Pad(card,12,12,10,10)

	local layout=New(
		"UIListLayout",
		{
			Padding=UDim.new(0,4),
			SortOrder=Enum.SortOrder.LayoutOrder
		},
		card
	)

	local title=Label(
		card,
		o.Title or "Notification",
		13,
		self.Theme.Text,
		true
	)
	title.Size=UDim2.new(1,0,0,20)
	title.ZIndex=302

	local content=Label(
		card,
		o.Content or o.Description or "",
		11,
		self.Theme.Muted,
		false
	)
	content.AutomaticSize=Enum.AutomaticSize.Y
	content.Size=UDim2.new(1,0,0,0)
	content.TextWrapped=true
	content.TextTruncate=Enum.TextTruncate.None
	content.ZIndex=302

	task.delay(o.Duration or 4,function()
		if card and card.Parent then
			Tween(
				card,
				.18,
				{
					BackgroundTransparency=1
				}
			)
			task.wait(.2)
			if card then
				card:Destroy()
			end
		end
	end)

	return card
end

function Window:SaveConfig(name)
	if not writefile then
		return false,"writefile unavailable"
	end

	local data={
		Version=LucidUI.Version,
		Flags=self.Flags
	}

	local ok,encoded=pcall(
		function()
			return HttpService:JSONEncode(data)
		end
	)

	if not ok then
		return false,encoded
	end

	local folder="LucidUI"
	if makefolder and isfolder and not isfolder(folder) then
		pcall(makefolder,folder)
	end

	local path=folder.."/"..tostring(name or "default")..".json"
	local success,err=pcall(writefile,path,encoded)

	return success,err
end

function Window:LoadConfig(name)
	if not readfile then
		return false,"readfile unavailable"
	end

	local path="LucidUI/"..tostring(name or "default")..".json"
	local ok,raw=pcall(readfile,path)

	if not ok then
		return false,raw
	end

	local decoded
	ok,decoded=pcall(
		function()
			return HttpService:JSONDecode(raw)
		end
	)

	if not ok then
		return false,decoded
	end

	for key,value in pairs(decoded.Flags or {}) do
		self.Flags[key]=value
	end

	return true,decoded
end

function Window:GetFlag(name)
	return self.Flags[name]
end

function Window:SetFlag(name,value)
	self.Flags[name]=value
end

function Window:SetBackgroundTransparency(v)
	self.Tint.BackgroundTransparency=math.clamp(v,0,1)
end

function Window:SetSize(size)
	self.Size=size
	Tween(
		self.Main,
		.16,
		{
			Size=size
		}
	)
end

function Window:Center()
	Tween(
		self.Main,
		.16,
		{
			Position=UDim2.fromScale(.5,.5)
		}
	)
end

function Window:SetTitle(text)
	self.Title=tostring(text)
end

function Window:SetToggleKey(key)
	self.ToggleKey=key
end

function Window:Destroy()
	for _,c in ipairs(self.Connections) do
		pcall(function()
			c:Disconnect()
		end)
	end

	if self.Gui then
		pcall(function()
			self.Gui:Destroy()
		end)
	end

	if GLOBAL_ENV[REGISTRY_KEY] and GLOBAL_ENV[REGISTRY_KEY].Gui==self.Gui then
		GLOBAL_ENV[REGISTRY_KEY]=nil
	end
end

LucidUI.Components = {}
LucidUI.Components["Button"] = {
	Name = "Button",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Toggle"] = {
	Name = "Toggle",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Slider"] = {
	Name = "Slider",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Textbox"] = {
	Name = "Textbox",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Dropdown"] = {
	Name = "Dropdown",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["RadioGroup"] = {
	Name = "RadioGroup",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["ButtonGroup"] = {
	Name = "ButtonGroup",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Keybind"] = {
	Name = "Keybind",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Numberbox"] = {
	Name = "Numberbox",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Paragraph"] = {
	Name = "Paragraph",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Divider"] = {
	Name = "Divider",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Header"] = {
	Name = "Header",
	Available = true,
	Version = "6.0.0"
}
LucidUI.Components["Progress"] = {
	Name = "Progress",
	Available = true,
	Version = "6.0.0"
}

function Window:GetRuntimeValue1(fallback)
	local value = self.Flags["RuntimeValue1"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue1(value)
	self.Flags["RuntimeValue1"] = value

	return value
end

function Window:GetRuntimeValue2(fallback)
	local value = self.Flags["RuntimeValue2"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue2(value)
	self.Flags["RuntimeValue2"] = value

	return value
end

function Window:GetRuntimeValue3(fallback)
	local value = self.Flags["RuntimeValue3"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue3(value)
	self.Flags["RuntimeValue3"] = value

	return value
end

function Window:GetRuntimeValue4(fallback)
	local value = self.Flags["RuntimeValue4"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue4(value)
	self.Flags["RuntimeValue4"] = value

	return value
end

function Window:GetRuntimeValue5(fallback)
	local value = self.Flags["RuntimeValue5"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue5(value)
	self.Flags["RuntimeValue5"] = value

	return value
end

function Window:GetRuntimeValue6(fallback)
	local value = self.Flags["RuntimeValue6"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue6(value)
	self.Flags["RuntimeValue6"] = value

	return value
end

function Window:GetRuntimeValue7(fallback)
	local value = self.Flags["RuntimeValue7"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue7(value)
	self.Flags["RuntimeValue7"] = value

	return value
end

function Window:GetRuntimeValue8(fallback)
	local value = self.Flags["RuntimeValue8"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue8(value)
	self.Flags["RuntimeValue8"] = value

	return value
end

function Window:GetRuntimeValue9(fallback)
	local value = self.Flags["RuntimeValue9"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue9(value)
	self.Flags["RuntimeValue9"] = value

	return value
end

function Window:GetRuntimeValue10(fallback)
	local value = self.Flags["RuntimeValue10"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue10(value)
	self.Flags["RuntimeValue10"] = value

	return value
end

function Window:GetRuntimeValue11(fallback)
	local value = self.Flags["RuntimeValue11"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue11(value)
	self.Flags["RuntimeValue11"] = value

	return value
end

function Window:GetRuntimeValue12(fallback)
	local value = self.Flags["RuntimeValue12"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue12(value)
	self.Flags["RuntimeValue12"] = value

	return value
end

function Window:GetRuntimeValue13(fallback)
	local value = self.Flags["RuntimeValue13"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue13(value)
	self.Flags["RuntimeValue13"] = value

	return value
end

function Window:GetRuntimeValue14(fallback)
	local value = self.Flags["RuntimeValue14"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue14(value)
	self.Flags["RuntimeValue14"] = value

	return value
end

function Window:GetRuntimeValue15(fallback)
	local value = self.Flags["RuntimeValue15"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue15(value)
	self.Flags["RuntimeValue15"] = value

	return value
end

function Window:GetRuntimeValue16(fallback)
	local value = self.Flags["RuntimeValue16"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue16(value)
	self.Flags["RuntimeValue16"] = value

	return value
end

function Window:GetRuntimeValue17(fallback)
	local value = self.Flags["RuntimeValue17"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue17(value)
	self.Flags["RuntimeValue17"] = value

	return value
end

function Window:GetRuntimeValue18(fallback)
	local value = self.Flags["RuntimeValue18"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue18(value)
	self.Flags["RuntimeValue18"] = value

	return value
end

function Window:GetRuntimeValue19(fallback)
	local value = self.Flags["RuntimeValue19"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue19(value)
	self.Flags["RuntimeValue19"] = value

	return value
end

function Window:GetRuntimeValue20(fallback)
	local value = self.Flags["RuntimeValue20"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue20(value)
	self.Flags["RuntimeValue20"] = value

	return value
end

function Window:GetRuntimeValue21(fallback)
	local value = self.Flags["RuntimeValue21"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue21(value)
	self.Flags["RuntimeValue21"] = value

	return value
end

function Window:GetRuntimeValue22(fallback)
	local value = self.Flags["RuntimeValue22"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue22(value)
	self.Flags["RuntimeValue22"] = value

	return value
end

function Window:GetRuntimeValue23(fallback)
	local value = self.Flags["RuntimeValue23"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue23(value)
	self.Flags["RuntimeValue23"] = value

	return value
end

function Window:GetRuntimeValue24(fallback)
	local value = self.Flags["RuntimeValue24"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue24(value)
	self.Flags["RuntimeValue24"] = value

	return value
end

function Window:GetRuntimeValue25(fallback)
	local value = self.Flags["RuntimeValue25"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue25(value)
	self.Flags["RuntimeValue25"] = value

	return value
end

function Window:GetRuntimeValue26(fallback)
	local value = self.Flags["RuntimeValue26"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue26(value)
	self.Flags["RuntimeValue26"] = value

	return value
end

function Window:GetRuntimeValue27(fallback)
	local value = self.Flags["RuntimeValue27"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue27(value)
	self.Flags["RuntimeValue27"] = value

	return value
end

function Window:GetRuntimeValue28(fallback)
	local value = self.Flags["RuntimeValue28"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue28(value)
	self.Flags["RuntimeValue28"] = value

	return value
end

function Window:GetRuntimeValue29(fallback)
	local value = self.Flags["RuntimeValue29"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue29(value)
	self.Flags["RuntimeValue29"] = value

	return value
end

function Window:GetRuntimeValue30(fallback)
	local value = self.Flags["RuntimeValue30"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue30(value)
	self.Flags["RuntimeValue30"] = value

	return value
end

function Window:GetRuntimeValue31(fallback)
	local value = self.Flags["RuntimeValue31"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue31(value)
	self.Flags["RuntimeValue31"] = value

	return value
end

function Window:GetRuntimeValue32(fallback)
	local value = self.Flags["RuntimeValue32"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue32(value)
	self.Flags["RuntimeValue32"] = value

	return value
end

function Window:GetRuntimeValue33(fallback)
	local value = self.Flags["RuntimeValue33"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue33(value)
	self.Flags["RuntimeValue33"] = value

	return value
end

function Window:GetRuntimeValue34(fallback)
	local value = self.Flags["RuntimeValue34"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue34(value)
	self.Flags["RuntimeValue34"] = value

	return value
end

function Window:GetRuntimeValue35(fallback)
	local value = self.Flags["RuntimeValue35"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue35(value)
	self.Flags["RuntimeValue35"] = value

	return value
end

function Window:GetRuntimeValue36(fallback)
	local value = self.Flags["RuntimeValue36"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue36(value)
	self.Flags["RuntimeValue36"] = value

	return value
end

function Window:GetRuntimeValue37(fallback)
	local value = self.Flags["RuntimeValue37"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue37(value)
	self.Flags["RuntimeValue37"] = value

	return value
end

function Window:GetRuntimeValue38(fallback)
	local value = self.Flags["RuntimeValue38"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue38(value)
	self.Flags["RuntimeValue38"] = value

	return value
end

function Window:GetRuntimeValue39(fallback)
	local value = self.Flags["RuntimeValue39"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue39(value)
	self.Flags["RuntimeValue39"] = value

	return value
end

function Window:GetRuntimeValue40(fallback)
	local value = self.Flags["RuntimeValue40"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue40(value)
	self.Flags["RuntimeValue40"] = value

	return value
end

function Window:GetRuntimeValue41(fallback)
	local value = self.Flags["RuntimeValue41"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue41(value)
	self.Flags["RuntimeValue41"] = value

	return value
end

function Window:GetRuntimeValue42(fallback)
	local value = self.Flags["RuntimeValue42"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue42(value)
	self.Flags["RuntimeValue42"] = value

	return value
end

function Window:GetRuntimeValue43(fallback)
	local value = self.Flags["RuntimeValue43"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue43(value)
	self.Flags["RuntimeValue43"] = value

	return value
end

function Window:GetRuntimeValue44(fallback)
	local value = self.Flags["RuntimeValue44"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue44(value)
	self.Flags["RuntimeValue44"] = value

	return value
end

function Window:GetRuntimeValue45(fallback)
	local value = self.Flags["RuntimeValue45"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue45(value)
	self.Flags["RuntimeValue45"] = value

	return value
end

function Window:GetRuntimeValue46(fallback)
	local value = self.Flags["RuntimeValue46"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue46(value)
	self.Flags["RuntimeValue46"] = value

	return value
end

function Window:GetRuntimeValue47(fallback)
	local value = self.Flags["RuntimeValue47"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue47(value)
	self.Flags["RuntimeValue47"] = value

	return value
end

function Window:GetRuntimeValue48(fallback)
	local value = self.Flags["RuntimeValue48"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue48(value)
	self.Flags["RuntimeValue48"] = value

	return value
end

function Window:GetRuntimeValue49(fallback)
	local value = self.Flags["RuntimeValue49"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue49(value)
	self.Flags["RuntimeValue49"] = value

	return value
end

function Window:GetRuntimeValue50(fallback)
	local value = self.Flags["RuntimeValue50"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue50(value)
	self.Flags["RuntimeValue50"] = value

	return value
end

function Window:GetRuntimeValue51(fallback)
	local value = self.Flags["RuntimeValue51"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue51(value)
	self.Flags["RuntimeValue51"] = value

	return value
end

function Window:GetRuntimeValue52(fallback)
	local value = self.Flags["RuntimeValue52"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue52(value)
	self.Flags["RuntimeValue52"] = value

	return value
end

function Window:GetRuntimeValue53(fallback)
	local value = self.Flags["RuntimeValue53"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue53(value)
	self.Flags["RuntimeValue53"] = value

	return value
end

function Window:GetRuntimeValue54(fallback)
	local value = self.Flags["RuntimeValue54"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue54(value)
	self.Flags["RuntimeValue54"] = value

	return value
end

function Window:GetRuntimeValue55(fallback)
	local value = self.Flags["RuntimeValue55"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue55(value)
	self.Flags["RuntimeValue55"] = value

	return value
end

function Window:GetRuntimeValue56(fallback)
	local value = self.Flags["RuntimeValue56"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue56(value)
	self.Flags["RuntimeValue56"] = value

	return value
end

function Window:GetRuntimeValue57(fallback)
	local value = self.Flags["RuntimeValue57"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue57(value)
	self.Flags["RuntimeValue57"] = value

	return value
end

function Window:GetRuntimeValue58(fallback)
	local value = self.Flags["RuntimeValue58"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue58(value)
	self.Flags["RuntimeValue58"] = value

	return value
end

function Window:GetRuntimeValue59(fallback)
	local value = self.Flags["RuntimeValue59"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue59(value)
	self.Flags["RuntimeValue59"] = value

	return value
end

function Window:GetRuntimeValue60(fallback)
	local value = self.Flags["RuntimeValue60"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue60(value)
	self.Flags["RuntimeValue60"] = value

	return value
end

function Window:GetRuntimeValue61(fallback)
	local value = self.Flags["RuntimeValue61"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue61(value)
	self.Flags["RuntimeValue61"] = value

	return value
end

function Window:GetRuntimeValue62(fallback)
	local value = self.Flags["RuntimeValue62"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue62(value)
	self.Flags["RuntimeValue62"] = value

	return value
end

function Window:GetRuntimeValue63(fallback)
	local value = self.Flags["RuntimeValue63"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue63(value)
	self.Flags["RuntimeValue63"] = value

	return value
end

function Window:GetRuntimeValue64(fallback)
	local value = self.Flags["RuntimeValue64"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue64(value)
	self.Flags["RuntimeValue64"] = value

	return value
end

function Window:GetRuntimeValue65(fallback)
	local value = self.Flags["RuntimeValue65"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue65(value)
	self.Flags["RuntimeValue65"] = value

	return value
end

function Window:GetRuntimeValue66(fallback)
	local value = self.Flags["RuntimeValue66"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue66(value)
	self.Flags["RuntimeValue66"] = value

	return value
end

function Window:GetRuntimeValue67(fallback)
	local value = self.Flags["RuntimeValue67"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue67(value)
	self.Flags["RuntimeValue67"] = value

	return value
end

function Window:GetRuntimeValue68(fallback)
	local value = self.Flags["RuntimeValue68"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue68(value)
	self.Flags["RuntimeValue68"] = value

	return value
end

function Window:GetRuntimeValue69(fallback)
	local value = self.Flags["RuntimeValue69"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue69(value)
	self.Flags["RuntimeValue69"] = value

	return value
end

function Window:GetRuntimeValue70(fallback)
	local value = self.Flags["RuntimeValue70"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue70(value)
	self.Flags["RuntimeValue70"] = value

	return value
end

function Window:GetRuntimeValue71(fallback)
	local value = self.Flags["RuntimeValue71"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue71(value)
	self.Flags["RuntimeValue71"] = value

	return value
end

function Window:GetRuntimeValue72(fallback)
	local value = self.Flags["RuntimeValue72"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue72(value)
	self.Flags["RuntimeValue72"] = value

	return value
end

function Window:GetRuntimeValue73(fallback)
	local value = self.Flags["RuntimeValue73"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue73(value)
	self.Flags["RuntimeValue73"] = value

	return value
end

function Window:GetRuntimeValue74(fallback)
	local value = self.Flags["RuntimeValue74"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue74(value)
	self.Flags["RuntimeValue74"] = value

	return value
end

function Window:GetRuntimeValue75(fallback)
	local value = self.Flags["RuntimeValue75"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue75(value)
	self.Flags["RuntimeValue75"] = value

	return value
end

function Window:GetRuntimeValue76(fallback)
	local value = self.Flags["RuntimeValue76"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue76(value)
	self.Flags["RuntimeValue76"] = value

	return value
end

function Window:GetRuntimeValue77(fallback)
	local value = self.Flags["RuntimeValue77"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue77(value)
	self.Flags["RuntimeValue77"] = value

	return value
end

function Window:GetRuntimeValue78(fallback)
	local value = self.Flags["RuntimeValue78"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue78(value)
	self.Flags["RuntimeValue78"] = value

	return value
end

function Window:GetRuntimeValue79(fallback)
	local value = self.Flags["RuntimeValue79"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue79(value)
	self.Flags["RuntimeValue79"] = value

	return value
end

function Window:GetRuntimeValue80(fallback)
	local value = self.Flags["RuntimeValue80"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue80(value)
	self.Flags["RuntimeValue80"] = value

	return value
end

function Window:GetRuntimeValue81(fallback)
	local value = self.Flags["RuntimeValue81"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue81(value)
	self.Flags["RuntimeValue81"] = value

	return value
end

function Window:GetRuntimeValue82(fallback)
	local value = self.Flags["RuntimeValue82"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue82(value)
	self.Flags["RuntimeValue82"] = value

	return value
end

function Window:GetRuntimeValue83(fallback)
	local value = self.Flags["RuntimeValue83"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue83(value)
	self.Flags["RuntimeValue83"] = value

	return value
end

function Window:GetRuntimeValue84(fallback)
	local value = self.Flags["RuntimeValue84"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue84(value)
	self.Flags["RuntimeValue84"] = value

	return value
end

function Window:GetRuntimeValue85(fallback)
	local value = self.Flags["RuntimeValue85"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue85(value)
	self.Flags["RuntimeValue85"] = value

	return value
end

function Window:GetRuntimeValue86(fallback)
	local value = self.Flags["RuntimeValue86"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue86(value)
	self.Flags["RuntimeValue86"] = value

	return value
end

function Window:GetRuntimeValue87(fallback)
	local value = self.Flags["RuntimeValue87"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue87(value)
	self.Flags["RuntimeValue87"] = value

	return value
end

function Window:GetRuntimeValue88(fallback)
	local value = self.Flags["RuntimeValue88"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue88(value)
	self.Flags["RuntimeValue88"] = value

	return value
end

function Window:GetRuntimeValue89(fallback)
	local value = self.Flags["RuntimeValue89"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue89(value)
	self.Flags["RuntimeValue89"] = value

	return value
end

function Window:GetRuntimeValue90(fallback)
	local value = self.Flags["RuntimeValue90"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue90(value)
	self.Flags["RuntimeValue90"] = value

	return value
end

function Window:GetRuntimeValue91(fallback)
	local value = self.Flags["RuntimeValue91"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue91(value)
	self.Flags["RuntimeValue91"] = value

	return value
end

function Window:GetRuntimeValue92(fallback)
	local value = self.Flags["RuntimeValue92"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue92(value)
	self.Flags["RuntimeValue92"] = value

	return value
end

function Window:GetRuntimeValue93(fallback)
	local value = self.Flags["RuntimeValue93"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue93(value)
	self.Flags["RuntimeValue93"] = value

	return value
end

function Window:GetRuntimeValue94(fallback)
	local value = self.Flags["RuntimeValue94"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue94(value)
	self.Flags["RuntimeValue94"] = value

	return value
end

function Window:GetRuntimeValue95(fallback)
	local value = self.Flags["RuntimeValue95"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue95(value)
	self.Flags["RuntimeValue95"] = value

	return value
end

function Window:GetRuntimeValue96(fallback)
	local value = self.Flags["RuntimeValue96"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue96(value)
	self.Flags["RuntimeValue96"] = value

	return value
end

function Window:GetRuntimeValue97(fallback)
	local value = self.Flags["RuntimeValue97"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue97(value)
	self.Flags["RuntimeValue97"] = value

	return value
end

function Window:GetRuntimeValue98(fallback)
	local value = self.Flags["RuntimeValue98"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue98(value)
	self.Flags["RuntimeValue98"] = value

	return value
end

function Window:GetRuntimeValue99(fallback)
	local value = self.Flags["RuntimeValue99"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue99(value)
	self.Flags["RuntimeValue99"] = value

	return value
end

function Window:GetRuntimeValue100(fallback)
	local value = self.Flags["RuntimeValue100"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue100(value)
	self.Flags["RuntimeValue100"] = value

	return value
end

function Window:GetRuntimeValue101(fallback)
	local value = self.Flags["RuntimeValue101"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue101(value)
	self.Flags["RuntimeValue101"] = value

	return value
end

function Window:GetRuntimeValue102(fallback)
	local value = self.Flags["RuntimeValue102"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue102(value)
	self.Flags["RuntimeValue102"] = value

	return value
end

function Window:GetRuntimeValue103(fallback)
	local value = self.Flags["RuntimeValue103"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue103(value)
	self.Flags["RuntimeValue103"] = value

	return value
end

function Window:GetRuntimeValue104(fallback)
	local value = self.Flags["RuntimeValue104"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue104(value)
	self.Flags["RuntimeValue104"] = value

	return value
end

function Window:GetRuntimeValue105(fallback)
	local value = self.Flags["RuntimeValue105"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue105(value)
	self.Flags["RuntimeValue105"] = value

	return value
end

function Window:GetRuntimeValue106(fallback)
	local value = self.Flags["RuntimeValue106"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue106(value)
	self.Flags["RuntimeValue106"] = value

	return value
end

function Window:GetRuntimeValue107(fallback)
	local value = self.Flags["RuntimeValue107"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue107(value)
	self.Flags["RuntimeValue107"] = value

	return value
end

function Window:GetRuntimeValue108(fallback)
	local value = self.Flags["RuntimeValue108"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue108(value)
	self.Flags["RuntimeValue108"] = value

	return value
end

function Window:GetRuntimeValue109(fallback)
	local value = self.Flags["RuntimeValue109"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue109(value)
	self.Flags["RuntimeValue109"] = value

	return value
end

function Window:GetRuntimeValue110(fallback)
	local value = self.Flags["RuntimeValue110"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue110(value)
	self.Flags["RuntimeValue110"] = value

	return value
end

function Window:GetRuntimeValue111(fallback)
	local value = self.Flags["RuntimeValue111"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue111(value)
	self.Flags["RuntimeValue111"] = value

	return value
end

function Window:GetRuntimeValue112(fallback)
	local value = self.Flags["RuntimeValue112"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue112(value)
	self.Flags["RuntimeValue112"] = value

	return value
end

function Window:GetRuntimeValue113(fallback)
	local value = self.Flags["RuntimeValue113"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue113(value)
	self.Flags["RuntimeValue113"] = value

	return value
end

function Window:GetRuntimeValue114(fallback)
	local value = self.Flags["RuntimeValue114"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue114(value)
	self.Flags["RuntimeValue114"] = value

	return value
end

function Window:GetRuntimeValue115(fallback)
	local value = self.Flags["RuntimeValue115"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue115(value)
	self.Flags["RuntimeValue115"] = value

	return value
end

function Window:GetRuntimeValue116(fallback)
	local value = self.Flags["RuntimeValue116"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue116(value)
	self.Flags["RuntimeValue116"] = value

	return value
end

function Window:GetRuntimeValue117(fallback)
	local value = self.Flags["RuntimeValue117"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue117(value)
	self.Flags["RuntimeValue117"] = value

	return value
end

function Window:GetRuntimeValue118(fallback)
	local value = self.Flags["RuntimeValue118"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue118(value)
	self.Flags["RuntimeValue118"] = value

	return value
end

function Window:GetRuntimeValue119(fallback)
	local value = self.Flags["RuntimeValue119"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue119(value)
	self.Flags["RuntimeValue119"] = value

	return value
end

function Window:GetRuntimeValue120(fallback)
	local value = self.Flags["RuntimeValue120"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue120(value)
	self.Flags["RuntimeValue120"] = value

	return value
end

function Window:GetRuntimeValue121(fallback)
	local value = self.Flags["RuntimeValue121"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue121(value)
	self.Flags["RuntimeValue121"] = value

	return value
end

function Window:GetRuntimeValue122(fallback)
	local value = self.Flags["RuntimeValue122"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue122(value)
	self.Flags["RuntimeValue122"] = value

	return value
end

function Window:GetRuntimeValue123(fallback)
	local value = self.Flags["RuntimeValue123"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue123(value)
	self.Flags["RuntimeValue123"] = value

	return value
end

function Window:GetRuntimeValue124(fallback)
	local value = self.Flags["RuntimeValue124"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue124(value)
	self.Flags["RuntimeValue124"] = value

	return value
end

function Window:GetRuntimeValue125(fallback)
	local value = self.Flags["RuntimeValue125"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue125(value)
	self.Flags["RuntimeValue125"] = value

	return value
end

function Window:GetRuntimeValue126(fallback)
	local value = self.Flags["RuntimeValue126"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue126(value)
	self.Flags["RuntimeValue126"] = value

	return value
end

function Window:GetRuntimeValue127(fallback)
	local value = self.Flags["RuntimeValue127"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue127(value)
	self.Flags["RuntimeValue127"] = value

	return value
end

function Window:GetRuntimeValue128(fallback)
	local value = self.Flags["RuntimeValue128"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue128(value)
	self.Flags["RuntimeValue128"] = value

	return value
end

function Window:GetRuntimeValue129(fallback)
	local value = self.Flags["RuntimeValue129"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue129(value)
	self.Flags["RuntimeValue129"] = value

	return value
end

function Window:GetRuntimeValue130(fallback)
	local value = self.Flags["RuntimeValue130"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue130(value)
	self.Flags["RuntimeValue130"] = value

	return value
end

function Window:GetRuntimeValue131(fallback)
	local value = self.Flags["RuntimeValue131"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue131(value)
	self.Flags["RuntimeValue131"] = value

	return value
end

function Window:GetRuntimeValue132(fallback)
	local value = self.Flags["RuntimeValue132"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue132(value)
	self.Flags["RuntimeValue132"] = value

	return value
end

function Window:GetRuntimeValue133(fallback)
	local value = self.Flags["RuntimeValue133"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue133(value)
	self.Flags["RuntimeValue133"] = value

	return value
end

function Window:GetRuntimeValue134(fallback)
	local value = self.Flags["RuntimeValue134"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue134(value)
	self.Flags["RuntimeValue134"] = value

	return value
end

function Window:GetRuntimeValue135(fallback)
	local value = self.Flags["RuntimeValue135"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue135(value)
	self.Flags["RuntimeValue135"] = value

	return value
end

function Window:GetRuntimeValue136(fallback)
	local value = self.Flags["RuntimeValue136"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue136(value)
	self.Flags["RuntimeValue136"] = value

	return value
end

function Window:GetRuntimeValue137(fallback)
	local value = self.Flags["RuntimeValue137"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue137(value)
	self.Flags["RuntimeValue137"] = value

	return value
end

function Window:GetRuntimeValue138(fallback)
	local value = self.Flags["RuntimeValue138"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue138(value)
	self.Flags["RuntimeValue138"] = value

	return value
end

function Window:GetRuntimeValue139(fallback)
	local value = self.Flags["RuntimeValue139"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue139(value)
	self.Flags["RuntimeValue139"] = value

	return value
end

function Window:GetRuntimeValue140(fallback)
	local value = self.Flags["RuntimeValue140"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue140(value)
	self.Flags["RuntimeValue140"] = value

	return value
end

function Window:GetRuntimeValue141(fallback)
	local value = self.Flags["RuntimeValue141"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue141(value)
	self.Flags["RuntimeValue141"] = value

	return value
end

function Window:GetRuntimeValue142(fallback)
	local value = self.Flags["RuntimeValue142"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue142(value)
	self.Flags["RuntimeValue142"] = value

	return value
end

function Window:GetRuntimeValue143(fallback)
	local value = self.Flags["RuntimeValue143"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue143(value)
	self.Flags["RuntimeValue143"] = value

	return value
end

function Window:GetRuntimeValue144(fallback)
	local value = self.Flags["RuntimeValue144"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue144(value)
	self.Flags["RuntimeValue144"] = value

	return value
end

function Window:GetRuntimeValue145(fallback)
	local value = self.Flags["RuntimeValue145"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue145(value)
	self.Flags["RuntimeValue145"] = value

	return value
end

function Window:GetRuntimeValue146(fallback)
	local value = self.Flags["RuntimeValue146"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue146(value)
	self.Flags["RuntimeValue146"] = value

	return value
end

function Window:GetRuntimeValue147(fallback)
	local value = self.Flags["RuntimeValue147"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue147(value)
	self.Flags["RuntimeValue147"] = value

	return value
end

function Window:GetRuntimeValue148(fallback)
	local value = self.Flags["RuntimeValue148"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue148(value)
	self.Flags["RuntimeValue148"] = value

	return value
end

function Window:GetRuntimeValue149(fallback)
	local value = self.Flags["RuntimeValue149"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue149(value)
	self.Flags["RuntimeValue149"] = value

	return value
end

function Window:GetRuntimeValue150(fallback)
	local value = self.Flags["RuntimeValue150"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue150(value)
	self.Flags["RuntimeValue150"] = value

	return value
end

function Window:GetRuntimeValue151(fallback)
	local value = self.Flags["RuntimeValue151"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue151(value)
	self.Flags["RuntimeValue151"] = value

	return value
end

function Window:GetRuntimeValue152(fallback)
	local value = self.Flags["RuntimeValue152"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue152(value)
	self.Flags["RuntimeValue152"] = value

	return value
end

function Window:GetRuntimeValue153(fallback)
	local value = self.Flags["RuntimeValue153"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue153(value)
	self.Flags["RuntimeValue153"] = value

	return value
end

function Window:GetRuntimeValue154(fallback)
	local value = self.Flags["RuntimeValue154"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue154(value)
	self.Flags["RuntimeValue154"] = value

	return value
end

function Window:GetRuntimeValue155(fallback)
	local value = self.Flags["RuntimeValue155"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue155(value)
	self.Flags["RuntimeValue155"] = value

	return value
end

function Window:GetRuntimeValue156(fallback)
	local value = self.Flags["RuntimeValue156"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue156(value)
	self.Flags["RuntimeValue156"] = value

	return value
end

function Window:GetRuntimeValue157(fallback)
	local value = self.Flags["RuntimeValue157"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue157(value)
	self.Flags["RuntimeValue157"] = value

	return value
end

function Window:GetRuntimeValue158(fallback)
	local value = self.Flags["RuntimeValue158"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue158(value)
	self.Flags["RuntimeValue158"] = value

	return value
end

function Window:GetRuntimeValue159(fallback)
	local value = self.Flags["RuntimeValue159"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue159(value)
	self.Flags["RuntimeValue159"] = value

	return value
end

function Window:GetRuntimeValue160(fallback)
	local value = self.Flags["RuntimeValue160"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue160(value)
	self.Flags["RuntimeValue160"] = value

	return value
end

function Window:GetRuntimeValue161(fallback)
	local value = self.Flags["RuntimeValue161"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue161(value)
	self.Flags["RuntimeValue161"] = value

	return value
end

function Window:GetRuntimeValue162(fallback)
	local value = self.Flags["RuntimeValue162"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue162(value)
	self.Flags["RuntimeValue162"] = value

	return value
end

function Window:GetRuntimeValue163(fallback)
	local value = self.Flags["RuntimeValue163"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue163(value)
	self.Flags["RuntimeValue163"] = value

	return value
end

function Window:GetRuntimeValue164(fallback)
	local value = self.Flags["RuntimeValue164"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue164(value)
	self.Flags["RuntimeValue164"] = value

	return value
end

function Window:GetRuntimeValue165(fallback)
	local value = self.Flags["RuntimeValue165"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue165(value)
	self.Flags["RuntimeValue165"] = value

	return value
end

function Window:GetRuntimeValue166(fallback)
	local value = self.Flags["RuntimeValue166"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue166(value)
	self.Flags["RuntimeValue166"] = value

	return value
end

function Window:GetRuntimeValue167(fallback)
	local value = self.Flags["RuntimeValue167"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue167(value)
	self.Flags["RuntimeValue167"] = value

	return value
end

function Window:GetRuntimeValue168(fallback)
	local value = self.Flags["RuntimeValue168"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue168(value)
	self.Flags["RuntimeValue168"] = value

	return value
end

function Window:GetRuntimeValue169(fallback)
	local value = self.Flags["RuntimeValue169"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue169(value)
	self.Flags["RuntimeValue169"] = value

	return value
end

function Window:GetRuntimeValue170(fallback)
	local value = self.Flags["RuntimeValue170"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue170(value)
	self.Flags["RuntimeValue170"] = value

	return value
end

function Window:GetRuntimeValue171(fallback)
	local value = self.Flags["RuntimeValue171"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue171(value)
	self.Flags["RuntimeValue171"] = value

	return value
end

function Window:GetRuntimeValue172(fallback)
	local value = self.Flags["RuntimeValue172"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue172(value)
	self.Flags["RuntimeValue172"] = value

	return value
end

function Window:GetRuntimeValue173(fallback)
	local value = self.Flags["RuntimeValue173"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue173(value)
	self.Flags["RuntimeValue173"] = value

	return value
end

function Window:GetRuntimeValue174(fallback)
	local value = self.Flags["RuntimeValue174"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue174(value)
	self.Flags["RuntimeValue174"] = value

	return value
end

function Window:GetRuntimeValue175(fallback)
	local value = self.Flags["RuntimeValue175"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue175(value)
	self.Flags["RuntimeValue175"] = value

	return value
end

function Window:GetRuntimeValue176(fallback)
	local value = self.Flags["RuntimeValue176"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue176(value)
	self.Flags["RuntimeValue176"] = value

	return value
end

function Window:GetRuntimeValue177(fallback)
	local value = self.Flags["RuntimeValue177"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue177(value)
	self.Flags["RuntimeValue177"] = value

	return value
end

function Window:GetRuntimeValue178(fallback)
	local value = self.Flags["RuntimeValue178"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue178(value)
	self.Flags["RuntimeValue178"] = value

	return value
end

function Window:GetRuntimeValue179(fallback)
	local value = self.Flags["RuntimeValue179"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue179(value)
	self.Flags["RuntimeValue179"] = value

	return value
end

function Window:GetRuntimeValue180(fallback)
	local value = self.Flags["RuntimeValue180"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue180(value)
	self.Flags["RuntimeValue180"] = value

	return value
end

function Window:GetRuntimeValue181(fallback)
	local value = self.Flags["RuntimeValue181"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue181(value)
	self.Flags["RuntimeValue181"] = value

	return value
end

function Window:GetRuntimeValue182(fallback)
	local value = self.Flags["RuntimeValue182"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue182(value)
	self.Flags["RuntimeValue182"] = value

	return value
end

function Window:GetRuntimeValue183(fallback)
	local value = self.Flags["RuntimeValue183"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue183(value)
	self.Flags["RuntimeValue183"] = value

	return value
end

function Window:GetRuntimeValue184(fallback)
	local value = self.Flags["RuntimeValue184"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue184(value)
	self.Flags["RuntimeValue184"] = value

	return value
end

function Window:GetRuntimeValue185(fallback)
	local value = self.Flags["RuntimeValue185"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue185(value)
	self.Flags["RuntimeValue185"] = value

	return value
end

function Window:GetRuntimeValue186(fallback)
	local value = self.Flags["RuntimeValue186"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue186(value)
	self.Flags["RuntimeValue186"] = value

	return value
end

function Window:GetRuntimeValue187(fallback)
	local value = self.Flags["RuntimeValue187"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue187(value)
	self.Flags["RuntimeValue187"] = value

	return value
end

function Window:GetRuntimeValue188(fallback)
	local value = self.Flags["RuntimeValue188"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue188(value)
	self.Flags["RuntimeValue188"] = value

	return value
end

function Window:GetRuntimeValue189(fallback)
	local value = self.Flags["RuntimeValue189"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue189(value)
	self.Flags["RuntimeValue189"] = value

	return value
end

function Window:GetRuntimeValue190(fallback)
	local value = self.Flags["RuntimeValue190"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue190(value)
	self.Flags["RuntimeValue190"] = value

	return value
end

function Window:GetRuntimeValue191(fallback)
	local value = self.Flags["RuntimeValue191"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue191(value)
	self.Flags["RuntimeValue191"] = value

	return value
end

function Window:GetRuntimeValue192(fallback)
	local value = self.Flags["RuntimeValue192"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue192(value)
	self.Flags["RuntimeValue192"] = value

	return value
end

function Window:GetRuntimeValue193(fallback)
	local value = self.Flags["RuntimeValue193"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue193(value)
	self.Flags["RuntimeValue193"] = value

	return value
end

function Window:GetRuntimeValue194(fallback)
	local value = self.Flags["RuntimeValue194"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue194(value)
	self.Flags["RuntimeValue194"] = value

	return value
end

function Window:GetRuntimeValue195(fallback)
	local value = self.Flags["RuntimeValue195"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue195(value)
	self.Flags["RuntimeValue195"] = value

	return value
end

function Window:GetRuntimeValue196(fallback)
	local value = self.Flags["RuntimeValue196"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue196(value)
	self.Flags["RuntimeValue196"] = value

	return value
end

function Window:GetRuntimeValue197(fallback)
	local value = self.Flags["RuntimeValue197"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue197(value)
	self.Flags["RuntimeValue197"] = value

	return value
end

function Window:GetRuntimeValue198(fallback)
	local value = self.Flags["RuntimeValue198"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue198(value)
	self.Flags["RuntimeValue198"] = value

	return value
end

function Window:GetRuntimeValue199(fallback)
	local value = self.Flags["RuntimeValue199"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue199(value)
	self.Flags["RuntimeValue199"] = value

	return value
end

function Window:GetRuntimeValue200(fallback)
	local value = self.Flags["RuntimeValue200"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue200(value)
	self.Flags["RuntimeValue200"] = value

	return value
end

function Window:GetRuntimeValue201(fallback)
	local value = self.Flags["RuntimeValue201"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue201(value)
	self.Flags["RuntimeValue201"] = value

	return value
end

function Window:GetRuntimeValue202(fallback)
	local value = self.Flags["RuntimeValue202"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue202(value)
	self.Flags["RuntimeValue202"] = value

	return value
end

function Window:GetRuntimeValue203(fallback)
	local value = self.Flags["RuntimeValue203"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue203(value)
	self.Flags["RuntimeValue203"] = value

	return value
end

function Window:GetRuntimeValue204(fallback)
	local value = self.Flags["RuntimeValue204"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue204(value)
	self.Flags["RuntimeValue204"] = value

	return value
end

function Window:GetRuntimeValue205(fallback)
	local value = self.Flags["RuntimeValue205"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue205(value)
	self.Flags["RuntimeValue205"] = value

	return value
end

function Window:GetRuntimeValue206(fallback)
	local value = self.Flags["RuntimeValue206"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue206(value)
	self.Flags["RuntimeValue206"] = value

	return value
end

function Window:GetRuntimeValue207(fallback)
	local value = self.Flags["RuntimeValue207"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue207(value)
	self.Flags["RuntimeValue207"] = value

	return value
end

function Window:GetRuntimeValue208(fallback)
	local value = self.Flags["RuntimeValue208"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue208(value)
	self.Flags["RuntimeValue208"] = value

	return value
end

function Window:GetRuntimeValue209(fallback)
	local value = self.Flags["RuntimeValue209"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue209(value)
	self.Flags["RuntimeValue209"] = value

	return value
end

function Window:GetRuntimeValue210(fallback)
	local value = self.Flags["RuntimeValue210"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue210(value)
	self.Flags["RuntimeValue210"] = value

	return value
end

function Window:GetRuntimeValue211(fallback)
	local value = self.Flags["RuntimeValue211"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue211(value)
	self.Flags["RuntimeValue211"] = value

	return value
end

function Window:GetRuntimeValue212(fallback)
	local value = self.Flags["RuntimeValue212"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue212(value)
	self.Flags["RuntimeValue212"] = value

	return value
end

function Window:GetRuntimeValue213(fallback)
	local value = self.Flags["RuntimeValue213"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue213(value)
	self.Flags["RuntimeValue213"] = value

	return value
end

function Window:GetRuntimeValue214(fallback)
	local value = self.Flags["RuntimeValue214"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue214(value)
	self.Flags["RuntimeValue214"] = value

	return value
end

function Window:GetRuntimeValue215(fallback)
	local value = self.Flags["RuntimeValue215"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue215(value)
	self.Flags["RuntimeValue215"] = value

	return value
end

function Window:GetRuntimeValue216(fallback)
	local value = self.Flags["RuntimeValue216"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue216(value)
	self.Flags["RuntimeValue216"] = value

	return value
end

function Window:GetRuntimeValue217(fallback)
	local value = self.Flags["RuntimeValue217"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue217(value)
	self.Flags["RuntimeValue217"] = value

	return value
end

function Window:GetRuntimeValue218(fallback)
	local value = self.Flags["RuntimeValue218"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue218(value)
	self.Flags["RuntimeValue218"] = value

	return value
end

function Window:GetRuntimeValue219(fallback)
	local value = self.Flags["RuntimeValue219"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue219(value)
	self.Flags["RuntimeValue219"] = value

	return value
end

function Window:GetRuntimeValue220(fallback)
	local value = self.Flags["RuntimeValue220"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue220(value)
	self.Flags["RuntimeValue220"] = value

	return value
end

function Window:GetRuntimeValue221(fallback)
	local value = self.Flags["RuntimeValue221"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue221(value)
	self.Flags["RuntimeValue221"] = value

	return value
end

function Window:GetRuntimeValue222(fallback)
	local value = self.Flags["RuntimeValue222"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue222(value)
	self.Flags["RuntimeValue222"] = value

	return value
end

function Window:GetRuntimeValue223(fallback)
	local value = self.Flags["RuntimeValue223"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue223(value)
	self.Flags["RuntimeValue223"] = value

	return value
end

function Window:GetRuntimeValue224(fallback)
	local value = self.Flags["RuntimeValue224"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue224(value)
	self.Flags["RuntimeValue224"] = value

	return value
end

function Window:GetRuntimeValue225(fallback)
	local value = self.Flags["RuntimeValue225"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue225(value)
	self.Flags["RuntimeValue225"] = value

	return value
end

function Window:GetRuntimeValue226(fallback)
	local value = self.Flags["RuntimeValue226"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue226(value)
	self.Flags["RuntimeValue226"] = value

	return value
end

function Window:GetRuntimeValue227(fallback)
	local value = self.Flags["RuntimeValue227"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue227(value)
	self.Flags["RuntimeValue227"] = value

	return value
end

function Window:GetRuntimeValue228(fallback)
	local value = self.Flags["RuntimeValue228"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue228(value)
	self.Flags["RuntimeValue228"] = value

	return value
end

function Window:GetRuntimeValue229(fallback)
	local value = self.Flags["RuntimeValue229"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue229(value)
	self.Flags["RuntimeValue229"] = value

	return value
end

function Window:GetRuntimeValue230(fallback)
	local value = self.Flags["RuntimeValue230"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue230(value)
	self.Flags["RuntimeValue230"] = value

	return value
end

function Window:GetRuntimeValue231(fallback)
	local value = self.Flags["RuntimeValue231"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue231(value)
	self.Flags["RuntimeValue231"] = value

	return value
end

function Window:GetRuntimeValue232(fallback)
	local value = self.Flags["RuntimeValue232"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue232(value)
	self.Flags["RuntimeValue232"] = value

	return value
end

function Window:GetRuntimeValue233(fallback)
	local value = self.Flags["RuntimeValue233"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue233(value)
	self.Flags["RuntimeValue233"] = value

	return value
end

function Window:GetRuntimeValue234(fallback)
	local value = self.Flags["RuntimeValue234"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue234(value)
	self.Flags["RuntimeValue234"] = value

	return value
end

function Window:GetRuntimeValue235(fallback)
	local value = self.Flags["RuntimeValue235"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue235(value)
	self.Flags["RuntimeValue235"] = value

	return value
end

function Window:GetRuntimeValue236(fallback)
	local value = self.Flags["RuntimeValue236"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue236(value)
	self.Flags["RuntimeValue236"] = value

	return value
end

function Window:GetRuntimeValue237(fallback)
	local value = self.Flags["RuntimeValue237"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue237(value)
	self.Flags["RuntimeValue237"] = value

	return value
end

function Window:GetRuntimeValue238(fallback)
	local value = self.Flags["RuntimeValue238"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue238(value)
	self.Flags["RuntimeValue238"] = value

	return value
end

function Window:GetRuntimeValue239(fallback)
	local value = self.Flags["RuntimeValue239"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue239(value)
	self.Flags["RuntimeValue239"] = value

	return value
end

function Window:GetRuntimeValue240(fallback)
	local value = self.Flags["RuntimeValue240"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue240(value)
	self.Flags["RuntimeValue240"] = value

	return value
end

function Window:GetRuntimeValue241(fallback)
	local value = self.Flags["RuntimeValue241"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue241(value)
	self.Flags["RuntimeValue241"] = value

	return value
end

function Window:GetRuntimeValue242(fallback)
	local value = self.Flags["RuntimeValue242"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue242(value)
	self.Flags["RuntimeValue242"] = value

	return value
end

function Window:GetRuntimeValue243(fallback)
	local value = self.Flags["RuntimeValue243"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue243(value)
	self.Flags["RuntimeValue243"] = value

	return value
end

function Window:GetRuntimeValue244(fallback)
	local value = self.Flags["RuntimeValue244"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue244(value)
	self.Flags["RuntimeValue244"] = value

	return value
end

function Window:GetRuntimeValue245(fallback)
	local value = self.Flags["RuntimeValue245"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue245(value)
	self.Flags["RuntimeValue245"] = value

	return value
end

function Window:GetRuntimeValue246(fallback)
	local value = self.Flags["RuntimeValue246"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue246(value)
	self.Flags["RuntimeValue246"] = value

	return value
end

function Window:GetRuntimeValue247(fallback)
	local value = self.Flags["RuntimeValue247"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue247(value)
	self.Flags["RuntimeValue247"] = value

	return value
end

function Window:GetRuntimeValue248(fallback)
	local value = self.Flags["RuntimeValue248"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue248(value)
	self.Flags["RuntimeValue248"] = value

	return value
end

function Window:GetRuntimeValue249(fallback)
	local value = self.Flags["RuntimeValue249"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue249(value)
	self.Flags["RuntimeValue249"] = value

	return value
end

function Window:GetRuntimeValue250(fallback)
	local value = self.Flags["RuntimeValue250"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue250(value)
	self.Flags["RuntimeValue250"] = value

	return value
end

function Window:GetRuntimeValue251(fallback)
	local value = self.Flags["RuntimeValue251"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue251(value)
	self.Flags["RuntimeValue251"] = value

	return value
end

function Window:GetRuntimeValue252(fallback)
	local value = self.Flags["RuntimeValue252"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue252(value)
	self.Flags["RuntimeValue252"] = value

	return value
end

function Window:GetRuntimeValue253(fallback)
	local value = self.Flags["RuntimeValue253"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue253(value)
	self.Flags["RuntimeValue253"] = value

	return value
end

function Window:GetRuntimeValue254(fallback)
	local value = self.Flags["RuntimeValue254"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue254(value)
	self.Flags["RuntimeValue254"] = value

	return value
end

function Window:GetRuntimeValue255(fallback)
	local value = self.Flags["RuntimeValue255"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue255(value)
	self.Flags["RuntimeValue255"] = value

	return value
end

function Window:GetRuntimeValue256(fallback)
	local value = self.Flags["RuntimeValue256"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue256(value)
	self.Flags["RuntimeValue256"] = value

	return value
end

function Window:GetRuntimeValue257(fallback)
	local value = self.Flags["RuntimeValue257"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue257(value)
	self.Flags["RuntimeValue257"] = value

	return value
end

function Window:GetRuntimeValue258(fallback)
	local value = self.Flags["RuntimeValue258"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue258(value)
	self.Flags["RuntimeValue258"] = value

	return value
end

function Window:GetRuntimeValue259(fallback)
	local value = self.Flags["RuntimeValue259"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue259(value)
	self.Flags["RuntimeValue259"] = value

	return value
end

function Window:GetRuntimeValue260(fallback)
	local value = self.Flags["RuntimeValue260"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue260(value)
	self.Flags["RuntimeValue260"] = value

	return value
end

function Window:GetRuntimeValue261(fallback)
	local value = self.Flags["RuntimeValue261"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue261(value)
	self.Flags["RuntimeValue261"] = value

	return value
end

function Window:GetRuntimeValue262(fallback)
	local value = self.Flags["RuntimeValue262"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue262(value)
	self.Flags["RuntimeValue262"] = value

	return value
end

function Window:GetRuntimeValue263(fallback)
	local value = self.Flags["RuntimeValue263"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue263(value)
	self.Flags["RuntimeValue263"] = value

	return value
end

function Window:GetRuntimeValue264(fallback)
	local value = self.Flags["RuntimeValue264"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue264(value)
	self.Flags["RuntimeValue264"] = value

	return value
end

function Window:GetRuntimeValue265(fallback)
	local value = self.Flags["RuntimeValue265"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue265(value)
	self.Flags["RuntimeValue265"] = value

	return value
end

function Window:GetRuntimeValue266(fallback)
	local value = self.Flags["RuntimeValue266"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue266(value)
	self.Flags["RuntimeValue266"] = value

	return value
end

function Window:GetRuntimeValue267(fallback)
	local value = self.Flags["RuntimeValue267"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue267(value)
	self.Flags["RuntimeValue267"] = value

	return value
end

function Window:GetRuntimeValue268(fallback)
	local value = self.Flags["RuntimeValue268"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue268(value)
	self.Flags["RuntimeValue268"] = value

	return value
end

function Window:GetRuntimeValue269(fallback)
	local value = self.Flags["RuntimeValue269"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue269(value)
	self.Flags["RuntimeValue269"] = value

	return value
end

function Window:GetRuntimeValue270(fallback)
	local value = self.Flags["RuntimeValue270"]

	if value == nil then
		return fallback
	end

	return value
end

function Window:SetRuntimeValue270(value)
	self.Flags["RuntimeValue270"] = value

	return value
end

return LucidUI
